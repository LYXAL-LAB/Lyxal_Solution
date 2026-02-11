use crate::consensus::RaftRole;
use anyhow::{anyhow, Result};
use lyxal_sync::protocol::{RaftLogEntry, RaftMessage};
use parking_lot::RwLock;
use std::collections::{HashMap, HashSet};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tracing::{debug, error, info, warn};

/// Configuration for the Raft consensus engine.
pub struct RaftConfig {
	pub election_timeout_min: Duration,
	pub election_timeout_max: Duration,
	pub heartbeat_interval: Duration,
}

impl Default for RaftConfig {
	fn default() -> Self {
		let min_ms = std::env::var("LYXAL_RAFT_ELECTION_MIN_MS")
			.ok()
			.and_then(|s| s.parse().ok())
			.unwrap_or(1000);
		let max_ms = std::env::var("LYXAL_RAFT_ELECTION_MAX_MS")
			.ok()
			.and_then(|s| s.parse().ok())
			.unwrap_or(2000);
		let heartbeat_ms = std::env::var("LYXAL_RAFT_HEARTBEAT_MS")
			.ok()
			.and_then(|s| s.parse().ok())
			.unwrap_or(300);

		Self {
			election_timeout_min: Duration::from_millis(min_ms),
			election_timeout_max: Duration::from_millis(max_ms),
			heartbeat_interval: Duration::from_millis(heartbeat_ms),
		}
	}
}

/// The internal state of a Raft node.
pub struct RaftState {
	pub current_term: u64,
	pub voted_for: Option<u128>,
	pub log: Vec<RaftLogEntry>,
	pub commit_index: u64,
	pub last_applied: u64,
	pub role: RaftRole,
	pub votes_received: HashSet<u128>,
}

impl RaftState {
	/// Returns the index of the last entry in the log.
	pub fn last_index(&self) -> u64 {
		self.log.last().map(|e| e.index).unwrap_or(0)
	}

	/// Returns the term of the last entry in the log.
	pub fn last_term(&self) -> u64 {
		self.log.last().map(|e| e.term).unwrap_or(0)
	}

	/// Truncates the log to the given index (removes everything AFTER index).
	pub fn truncate_after(&mut self, index: u64) {
		if index < self.log.len() as u64 {
			self.log.truncate(index as usize);
		}
	}
}

/// A node in the Raft consensus group.
/// This struct implements the core state machine logic for distributed consensus.
pub struct RaftNode {
	pub node_id: u128,
	pub config: RaftConfig,
	pub state: Arc<RwLock<RaftState>>,
	pub peers: Arc<RwLock<Vec<u128>>>,

	// Leader specific state (volatile)
	pub next_index: Arc<RwLock<HashMap<u128, u64>>>,
	pub match_index: Arc<RwLock<HashMap<u128, u64>>>,

	// Timer state for election and heartbeats
	pub last_heartbeat: Arc<RwLock<Instant>>,
	pub election_timeout: Arc<RwLock<Duration>>,
}

impl RaftNode {
	/// Creates a new RaftNode with a randomized election timeout.
	pub fn new(node_id: u128, peers: Vec<u128>) -> Self {
		let config = RaftConfig::default();
		let election_timeout = Self::random_election_timeout(
			config.election_timeout_min.as_millis() as u64,
			config.election_timeout_max.as_millis() as u64,
		);
		Self {
			node_id,
			config,
			state: Arc::new(RwLock::new(RaftState {
				current_term: 0,
				voted_for: None,
				log: Vec::new(),
				commit_index: 0,
				last_applied: 0,
				role: RaftRole::Follower,
				votes_received: HashSet::new(),
			})),
			peers: Arc::new(RwLock::new(peers)),
			next_index: Arc::new(RwLock::new(HashMap::new())),
			match_index: Arc::new(RwLock::new(HashMap::new())),
			last_heartbeat: Arc::new(RwLock::new(Instant::now())),
			election_timeout: Arc::new(RwLock::new(election_timeout)),
		}
	}

	fn random_election_timeout(min_ms: u64, max_ms: u64) -> Duration {
		Duration::from_millis(fastrand::u64(min_ms..max_ms))
	}

	/// Entry point for all incoming Raft messages from the network.
	/// Returns an optional response message to be sent back to the sender.
	pub fn handle_message(&self, from: u128, msg: RaftMessage) -> Option<RaftMessage> {
		// P25: Dynamic Peer Discovery
		// If we receive a message from a node not in our peer list, add it to volatile state.
		{
			let mut peers = self.peers.write();
			if from != self.node_id && !peers.contains(&from) {
				info!("Raft[{}]: Discovered new peer {}. Adding to cluster.", self.node_id, from);
				peers.push(from);

				// Initialize leader state for this peer if we are leader
				if self.state.read().role == RaftRole::Leader {
					let last_index = self.state.read().last_index();
					self.next_index.write().insert(from, last_index + 1);
					self.match_index.write().insert(from, 0);
				}
			}
		}

		match msg {
			RaftMessage::RequestVote {
				term,
				candidate_id,
				last_log_index,
				last_log_term,
			} => self.process_request_vote(term, candidate_id, last_log_index, last_log_term),
			RaftMessage::VoteResponse {
				term,
				vote_granted,
			} => {
				self.process_vote_response(from, term, vote_granted);
				None
			}
			RaftMessage::AppendEntries {
				term,
				leader_id,
				prev_log_index,
				prev_log_term,
				entries,
				leader_commit,
			} => self.process_append_entries(
				term,
				leader_id,
				prev_log_index,
				prev_log_term,
				entries,
				leader_commit,
			),
			RaftMessage::AppendResponse {
				term,
				success,
				match_index,
			} => {
				self.process_append_response(from, term, success, match_index);
				None
			}
		}
	}

	fn process_request_vote(
		&self,
		term: u64,
		candidate_id: u128,
		last_log_index: u64,
		last_log_term: u64,
	) -> Option<RaftMessage> {
		let mut state = self.state.write();

		if term > state.current_term
			|| (term == state.current_term
				&& state.role != RaftRole::Follower
				&& candidate_id > self.node_id)
		{
			info!(
				"Raft[{}]: Term {} (or tie-break) >= current {}. Stepping down to Follower.",
				self.node_id, term, state.current_term
			);
			state.current_term = term;
			state.role = RaftRole::Follower;
			state.voted_for = None;
			state.votes_received.clear();
		}

		let mut vote_granted = false;
		if term == state.current_term
			&& (state.voted_for.is_none() || state.voted_for == Some(candidate_id))
			&& self.is_log_up_to_date(&state, last_log_index, last_log_term)
		{
			info!("Raft[{}]: Granting vote to {} for term {}", self.node_id, candidate_id, term);
			vote_granted = true;
			state.voted_for = Some(candidate_id);
			*self.last_heartbeat.write() = Instant::now();
		}

		Some(RaftMessage::VoteResponse {
			term: state.current_term,
			vote_granted,
		})
	}

	fn is_log_up_to_date(&self, state: &RaftState, last_index: u64, last_term: u64) -> bool {
		let my_last_index = state.last_index();
		let my_last_term = state.last_term();

		if last_term != my_last_term {
			last_term > my_last_term
		} else {
			last_index >= my_last_index
		}
	}

	fn process_append_entries(
		&self,
		term: u64,
		leader_id: u128,
		prev_log_index: u64,
		prev_log_term: u64,
		entries: Vec<RaftLogEntry>,
		leader_commit: u64,
	) -> Option<RaftMessage> {
		let mut state = self.state.write();

		if term < state.current_term {
			return Some(RaftMessage::AppendResponse {
				term: state.current_term,
				success: false,
				match_index: 0,
			});
		}

		// Reset election timer on valid heartbeat
		*self.last_heartbeat.write() = Instant::now();

		if term > state.current_term
			|| (term == state.current_term
				&& state.role != RaftRole::Follower
				&& leader_id > self.node_id)
		{
			info!(
				"Raft[{}]: Recognizing superior leader {} for term {} (stepping down)",
				self.node_id, leader_id, term
			);
			state.current_term = term;
			state.role = RaftRole::Follower;
			state.voted_for = Some(leader_id);
			state.votes_received.clear();
		}

		// 2. Reply false if log doesn't contain an entry at prevLogIndex whose term matches prevLogTerm
		if prev_log_index > 0 {
			if state.log.len() < prev_log_index as usize {
				debug!(
					"Raft[{}]: Log too short ({} < {})",
					self.node_id,
					state.log.len(),
					prev_log_index
				);
				return Some(RaftMessage::AppendResponse {
					term: state.current_term,
					success: false,
					match_index: 0,
				});
			}
			if state.log[prev_log_index as usize - 1].term != prev_log_term {
				debug!("Raft[{}]: Term mismatch at prev index {}", self.node_id, prev_log_index);
				return Some(RaftMessage::AppendResponse {
					term: state.current_term,
					success: false,
					match_index: 0,
				});
			}
		}

		// 3. If an existing entry conflicts with a new one (same index but different terms),
		// delete the existing entry and all that follow it.
		// 4. Append any new entries not already in the log.
		let mut curr_idx = prev_log_index;
		for entry in entries {
			curr_idx += 1;
			if curr_idx <= state.last_index() {
				if state.log[curr_idx as usize - 1].term != entry.term {
					state.truncate_after(curr_idx - 1);
					state.log.push(entry);
				}
			} else {
				state.log.push(entry);
			}
		}

		// 5. If leaderCommit > commitIndex, set commitIndex = min(leaderCommit, index of last new entry)
		if leader_commit > state.commit_index {
			state.commit_index = leader_commit.min(state.log.len() as u64);
			debug!("Raft[{}]: Commit index updated to {}", self.node_id, state.commit_index);
		}

		Some(RaftMessage::AppendResponse {
			term: state.current_term,
			success: true,
			match_index: state.log.len() as u64,
		})
	}

	fn process_vote_response(&self, from: u128, term: u64, vote_granted: bool) {
		let mut state = self.state.write();
		if state.role != RaftRole::Candidate || term != state.current_term {
			return;
		}

		if vote_granted {
			debug!("Raft[{}]: Received vote from {} for term {}", self.node_id, from, term);
			state.votes_received.insert(from);

			let total_nodes = self.peers.read().len() + 1;
			let quorum = (total_nodes / 2) + 1;

			if state.votes_received.len() >= quorum {
				info!(
					"Raft[{}]: Quorum reached ({} votes). Promoting to Leader.",
					self.node_id,
					state.votes_received.len()
				);
				drop(state);
				self.promote_to_leader();
			}
		}
	}

	fn process_append_response(&self, from: u128, term: u64, success: bool, match_index: u64) {
		let mut state = self.state.write();
		if state.role != RaftRole::Leader || term != state.current_term {
			return;
		}

		if success {
			self.match_index.write().insert(from, match_index);
			self.next_index.write().insert(from, match_index + 1);
			self.update_commit_index(&mut state);
		} else {
			// Step back and retry: decrement nextIndex for this peer
			let mut next = self.next_index.write();
			let entry = next.entry(from).or_insert(1);
			*entry = (*entry).saturating_sub(1).max(1);
			debug!("Raft[{}]: Decremented next_index for {} to {}", self.node_id, from, *entry);
		}
	}

	fn update_commit_index(&self, state: &mut RaftState) {
		let match_indices = self.match_index.read();
		let mut indices: Vec<u64> = match_indices.values().copied().collect();
		indices.push(state.last_index());
		indices.sort();

		// Find the largest N such that a quorum of nodes has matchIndex[i] >= N
		let quorum_idx = (self.peers.read().len() + 1) / 2;
		if indices.len() > quorum_idx {
			let n = indices[indices.len() - quorum_idx - 1];
			if n > state.commit_index
				&& n > 0 && state.log[n as usize - 1].term == state.current_term
			{
				state.commit_index = n;
				info!("Raft[{}]: Leader advanced commit index to {}", self.node_id, n);
			}
		}
	}

	/// Periodic heartbeat/election tick.
	/// Returns a message to broadcast if an action is required (Election or Heartbeat).
	pub fn tick(&self) -> Option<RaftMessage> {
		let mut state = self.state.write();
		let now = Instant::now();
		let elapsed = now.duration_since(*self.last_heartbeat.read());

		match state.role {
			RaftRole::Follower | RaftRole::Candidate => {
				if elapsed >= *self.election_timeout.read() {
					warn!(
						"Raft[{}]: Election timeout. Starting election for term {}",
						self.node_id,
						state.current_term + 1
					);
					return self.start_election(&mut state);
				}
			}
			RaftRole::Leader => {
				if elapsed >= self.config.heartbeat_interval {
					*self.last_heartbeat.write() = now;
					return Some(RaftMessage::AppendEntries {
						term: state.current_term,
						leader_id: self.node_id,
						prev_log_index: state.last_index(),
						prev_log_term: state.last_term(),
						entries: Vec::new(),
						leader_commit: state.commit_index,
					});
				}
			}
		}
		None
	}

	fn start_election(&self, state: &mut RaftState) -> Option<RaftMessage> {
		state.role = RaftRole::Candidate;
		state.current_term += 1;
		state.voted_for = Some(self.node_id);
		state.votes_received.clear();
		state.votes_received.insert(self.node_id); // Vote for self
		*self.last_heartbeat.write() = Instant::now();
		*self.election_timeout.write() = Self::random_election_timeout(
			self.config.election_timeout_min.as_millis() as u64,
			self.config.election_timeout_max.as_millis() as u64,
		);

		// P25: Consensus Quorum Logic
		let peers = self.peers.read();
		let total_nodes = peers.len() + 1;
		let quorum = (total_nodes / 2) + 1;

		if state.votes_received.len() >= quorum {
			// Majority reached (either via peers or standalone if peers.is_empty())

			// P25 Anti-Split-Brain: If we have no known peers, we must wait at least Term 4
			// to ensure we aren't just starting up faster than our neighbors.
			if total_nodes == 1 && state.current_term < 4 {
				debug!("Raft[{}]: Standalone quorum reached but waiting for potential peers (Term {}/4)...", self.node_id, state.current_term);
				return Some(RaftMessage::RequestVote {
					term: state.current_term,
					candidate_id: self.node_id,
					last_log_index: state.last_index(),
					last_log_term: state.last_term(),
				});
			}

			info!(
				"Raft[{}]: Elected leader for term {} (Quorum: {}/{})",
				self.node_id,
				state.current_term,
				state.votes_received.len(),
				total_nodes
			);
			state.role = RaftRole::Leader;

			let last_index = state.last_index();
			let mut next = self.next_index.write();
			let mut matched = self.match_index.write();

			for &peer_id in peers.iter() {
				next.insert(peer_id, last_index + 1);
				matched.insert(peer_id, 0);
			}

			return None;
		}

		let last_log_index = state.last_index();
		let last_log_term = state.last_term();

		Some(RaftMessage::RequestVote {
			term: state.current_term,
			candidate_id: self.node_id,
			last_log_index,
			last_log_term,
		})
	}

	/// Propose a new entry to the cluster log. Only valid if current node is Leader.
	pub fn propose(&self, data: Vec<u8>) -> Result<u64> {
		let mut state = self.state.write();
		if state.role != RaftRole::Leader {
			return Err(anyhow!("Not the leader"));
		}

		let entry = RaftLogEntry {
			term: state.current_term,
			index: state.last_index() + 1,
			data,
		};
		let index = entry.index;
		state.log.push(entry);

		// P25: Standalone commit logic
		// If we have no known peers and have been leader for a while, commit immediately.
		if self.peers.read().is_empty() && state.current_term > 4 {
			state.commit_index = index;
			debug!("Raft[{}]: Standalone commit for index {}", self.node_id, index);
		}

		Ok(index)
	}

	/// Promotes the node to leader state.
	pub fn promote_to_leader(&self) {
		let mut state = self.state.write();
		if state.role == RaftRole::Candidate {
			info!("Raft[{}]: Elected leader for term {}", self.node_id, state.current_term);
			state.role = RaftRole::Leader;

			let last_index = state.last_index();
			let mut next = self.next_index.write();
			let mut matched = self.match_index.write();

			for &peer_id in self.peers.read().iter() {
				next.insert(peer_id, last_index + 1);
				matched.insert(peer_id, 0);
			}
		}
	}
}
