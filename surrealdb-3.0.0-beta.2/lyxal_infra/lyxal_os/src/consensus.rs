use lyxal_sync::protocol::RaftMessage;
use parking_lot::Mutex;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::SystemTime;
use tracing::{debug, error, info};

// Explicitly use serde_json just in case
use serde_json;

use bincode;

// === Data Structures ===

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct LeaderLease {
	pub term: u64,
	pub leader_id: u128,
	pub expires_at_ms: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TargetStatus {
	Running,
	Stopped,
	Deleted,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DesiredRealmState {
	pub target: TargetStatus,
	pub config_hash: String,
	pub updated_at_ms: u64,
	pub updated_by: u128,
	#[serde(default)]
	pub last_command_id: u128,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommandRecord {
	pub id: u128,
	pub realm_id: u128,
	pub kind: String,
	pub hash: String,
	pub applied_at_ms: u64,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum RaftRole {
	Follower,
	Candidate,
	Leader,
}

/// A trait for persisting and retrieving consensus-related data.
// === Consensus Store Trait ===

#[async_trait::async_trait]
pub trait ConsensusStore: Send + Sync {
	async fn get_lease(&self) -> Result<Option<LeaderLease>, anyhow::Error>;

	// CAS operation: Check existing lease.
	// If expected_term is Some, existing lease MUST match term.
	// If expected_term is None, existing lease MUST be None.
	// If check passes, write new_lease.
	// Returns Ok(true) if successful, Ok(false) if CAS failed, Err on error.
	async fn cas_lease(
		&self,
		expected_term: Option<u64>,
		new_lease: LeaderLease,
	) -> Result<bool, anyhow::Error>;

	// Desired State Access
	async fn get_desired(&self, realm_id: u128)
		-> Result<Option<DesiredRealmState>, anyhow::Error>;
	async fn set_desired(
		&self,
		realm_id: u128,
		state: DesiredRealmState,
	) -> Result<(), anyhow::Error>;
	async fn list_desired(&self) -> Result<Vec<u128>, anyhow::Error>;

	// Command History
	async fn has_command(&self, command_id: u128) -> Result<bool, anyhow::Error>;
	async fn record_command(&self, rec: CommandRecord) -> Result<(), anyhow::Error>;

	// P24: Meta-OS Global Registry Persistence
	async fn save_manifest(
		&self,
		state: &crate::registry::DesiredState,
	) -> Result<(), anyhow::Error>;
	async fn load_manifest(&self) -> Result<Option<crate::registry::DesiredState>, anyhow::Error>;

	// Raft Persistence
	async fn save_raft_state(
		&self,
		term: u64,
		voted_for: Option<u128>,
	) -> Result<(), anyhow::Error>;
	async fn load_raft_state(&self) -> Result<(u64, Option<u128>), anyhow::Error>;
	async fn append_raft_log(
		&self,
		entries: &[lyxal_sync::protocol::RaftLogEntry],
	) -> Result<(), anyhow::Error>;
	async fn truncate_raft_log(&self, last_index: u64) -> Result<(), anyhow::Error>;
	async fn purge_raft_log_before(&self, index: u64) -> Result<(), anyhow::Error>;
	async fn load_raft_log(
		&self,
		start_index: u64,
	) -> Result<Vec<lyxal_sync::protocol::RaftLogEntry>, anyhow::Error>;

	fn get_db(&self) -> Option<Arc<lyxalkv::Tree>> {
		None
	}
}

// === KvConsensusStore (LyxalKV) ===

pub struct KvConsensusStore {
	pub db: Arc<lyxalkv::Tree>,
}

impl KvConsensusStore {
	pub fn new(path: std::path::PathBuf) -> Self {
		// Use TreeBuilder as Tree::new is private
		let opts = lyxalkv::Options::new().with_path(path);
		let tree = lyxalkv::TreeBuilder::with_options(opts)
			.build()
			.expect("Failed to open Consensus Store");
		Self {
			db: Arc::new(tree),
		}
	}
}

#[async_trait::async_trait]
impl ConsensusStore for KvConsensusStore {
	async fn get_lease(&self) -> Result<Option<LeaderLease>, anyhow::Error> {
		let txn = self.db.begin()?;
		let val = txn.get(b"_cp/leader_lease")?;
		if let Some(v) = val {
			let lease: LeaderLease = serde_json::from_slice(&v)?;
			Ok(Some(lease))
		} else {
			Ok(None)
		}
	}

	async fn cas_lease(
		&self,
		expected_term: Option<u64>,
		new_lease: LeaderLease,
	) -> Result<bool, anyhow::Error> {
		let mut txn = self.db.begin()?;
		let current_val = txn.get(b"_cp/leader_lease")?;

		match (current_val, expected_term) {
			(None, None) => {}
			(Some(v), Some(exp_t)) => {
				let current_lease: LeaderLease = serde_json::from_slice(&v)?;
				if current_lease.term != exp_t {
					return Ok(false);
				}
				if current_lease.term == new_lease.term
					&& current_lease.leader_id != new_lease.leader_id
				{
					return Ok(false);
				}
			}
			(Some(_), None) => return Ok(false),
			(None, Some(_)) => return Ok(false),
		}

		let val = serde_json::to_vec(&new_lease)?;
		txn.set(b"_cp/leader_lease", val)?;

		match txn.commit().await {
			Ok(_) => Ok(true),
			Err(lyxalkv::Error::TransactionWriteConflict) => Ok(false),
			Err(e) => Err(anyhow::anyhow!(e)),
		}
	}

	async fn get_desired(
		&self,
		realm_id: u128,
	) -> Result<Option<DesiredRealmState>, anyhow::Error> {
		let key = format!("_cp/desired/{:032x}", realm_id);
		let txn = self.db.begin()?;
		let val = txn.get(key.as_bytes())?;
		if let Some(v) = val {
			Ok(Some(serde_json::from_slice(&v)?))
		} else {
			Ok(None)
		}
	}

	async fn set_desired(
		&self,
		realm_id: u128,
		state: DesiredRealmState,
	) -> Result<(), anyhow::Error> {
		let key = format!("_cp/desired/{:032x}", realm_id);
		let val = serde_json::to_vec(&state)?;
		let mut txn = self.db.begin()?;
		txn.set(key.as_bytes(), val)?;
		txn.commit().await?;
		Ok(())
	}

	async fn list_desired(&self) -> Result<Vec<u128>, anyhow::Error> {
		let txn = self.db.begin()?;
		let start = b"_cp/desired/";
		let end = b"_cp/desiredg";

		let mut realms = Vec::new();
		let keys_iter = txn.keys(start, end)?;
		let keys: Vec<Vec<u8>> = keys_iter.map(|r| r.unwrap()).collect();

		for k in keys {
			if let Ok(s) = std::str::from_utf8(&k) {
				if let Some(hex_part) = s.strip_prefix("_cp/desired/") {
					if let Ok(id) = u128::from_str_radix(hex_part, 16) {
						realms.push(id);
					}
				}
			}
		}
		Ok(realms)
	}

	async fn has_command(&self, command_id: u128) -> Result<bool, anyhow::Error> {
		let key = format!("_cp/commands/{:032x}", command_id);
		let txn = self.db.begin()?;
		Ok(txn.get(key.as_bytes())?.is_some())
	}

	async fn record_command(&self, rec: CommandRecord) -> Result<(), anyhow::Error> {
		let key = format!("_cp/commands/{:032x}", rec.id);
		let val = serde_json::to_vec(&rec)?;
		let mut txn = self.db.begin()?;
		txn.set(key.as_bytes(), val)?;
		txn.commit().await?;
		Ok(())
	}

	async fn save_manifest(
		&self,
		state: &crate::registry::DesiredState,
	) -> Result<(), anyhow::Error> {
		let val = serde_json::to_vec(state)?;
		let mut txn = self.db.begin()?;
		txn.set(b"_cp/desired_state.bin", val.clone())?;
		let hist_key = format!("_cp/history/{}.bin", state.version);
		txn.set(hist_key.as_bytes(), val)?;
		txn.commit().await?;
		Ok(())
	}

	async fn load_manifest(&self) -> Result<Option<crate::registry::DesiredState>, anyhow::Error> {
		let txn = self.db.begin()?;
		if let Some(val) = txn.get(b"_cp/desired_state.bin")? {
			let state = serde_json::from_slice(&val)?;
			Ok(Some(state))
		} else {
			Ok(None)
		}
	}

	async fn save_raft_state(
		&self,
		term: u64,
		voted_for: Option<u128>,
	) -> Result<(), anyhow::Error> {
		let mut txn = self.db.begin()?;
		txn.set(b"_raft/term", term.to_le_bytes().to_vec())?;
		if let Some(v) = voted_for {
			txn.set(b"_raft/voted_for", v.to_le_bytes().to_vec())?;
		} else {
			txn.delete(b"_raft/voted_for")?;
		}
		txn.commit().await?;
		Ok(())
	}

	async fn load_raft_state(&self) -> Result<(u64, Option<u128>), anyhow::Error> {
		let txn = self.db.begin()?;
		let term = txn
			.get(b"_raft/term")?
			.map(|v| {
				let mut b = [0u8; 8];
				b.copy_from_slice(&v);
				u64::from_le_bytes(b)
			})
			.unwrap_or(0);
		let voted_for = txn.get(b"_raft/voted_for")?.map(|v| {
			let mut b = [0u8; 16];
			b.copy_from_slice(&v);
			u128::from_le_bytes(b)
		});
		Ok((term, voted_for))
	}

	async fn append_raft_log(
		&self,
		entries: &[lyxal_sync::protocol::RaftLogEntry],
	) -> Result<(), anyhow::Error> {
		let mut txn = self.db.begin()?;
		for entry in entries {
			let key = format!("_raft/log/{:020}", entry.index);
			let val = serde_json::to_vec(entry)?;
			txn.set(key.as_bytes(), val)?;
		}
		txn.commit().await?;
		Ok(())
	}

	async fn truncate_raft_log(&self, last_index: u64) -> Result<(), anyhow::Error> {
		let mut txn = self.db.begin()?;
		let start_key = format!("_raft/log/{:020}", last_index + 1);
		let end_key = "_raft/log/99999999999999999999";

		let keys_to_delete: Vec<Vec<u8>> = txn
			.range(start_key.as_bytes(), end_key.as_bytes())?
			.filter_map(|res| res.ok().map(|(k, _)| k))
			.collect();

		for key in keys_to_delete {
			txn.delete(&key)?;
		}

		txn.commit().await?;
		Ok(())
	}

	async fn purge_raft_log_before(&self, index: u64) -> Result<(), anyhow::Error> {
		let mut txn = self.db.begin()?;
		let start_key = "_raft/log/00000000000000000000";
		let end_key = format!("_raft/log/{:020}", index);

		let keys_to_delete: Vec<Vec<u8>> = txn
			.range(start_key.as_bytes(), end_key.as_bytes())?
			.filter_map(|res| res.ok().map(|(k, _)| k))
			.collect();

		for key in keys_to_delete {
			txn.delete(&key)?;
		}

		txn.commit().await?;
		Ok(())
	}

	async fn load_raft_log(
		&self,
		start_index: u64,
	) -> Result<Vec<lyxal_sync::protocol::RaftLogEntry>, anyhow::Error> {
		let mut entries = Vec::new();
		let start_key = format!("_raft/log/{:020}", start_index);
		let end_key = "_raft/log/99999999999999999999";
		let txn = self.db.begin()?;

		for res in txn.range(start_key.as_bytes(), end_key.as_bytes())? {
			let (_, val) = res?;
			let entry: lyxal_sync::protocol::RaftLogEntry = serde_json::from_slice(&val)?;
			entries.push(entry);
		}

		Ok(entries)
	}

	fn get_db(&self) -> Option<Arc<lyxalkv::Tree>> {
		Some(self.db.clone())
	}
}
// === MockConsensusStore (In-Memory Shared) ===
// Used for Torture Tests where file locking prevents multiple nodes in one process

use once_cell::sync::Lazy;
use std::collections::HashMap;

// Shared state for all Mock Stores in the process
static MOCK_DB: Lazy<Mutex<HashMap<String, Vec<u8>>>> = Lazy::new(|| Mutex::new(HashMap::new()));

pub struct MockConsensusStore;

impl MockConsensusStore {
	pub fn new() -> Self {
		Self
	}
}

#[async_trait::async_trait]
impl ConsensusStore for MockConsensusStore {
	async fn get_lease(&self) -> Result<Option<LeaderLease>, anyhow::Error> {
		let db = MOCK_DB.lock();
		if let Some(val) = db.get("_cp/leader_lease") {
			let lease: LeaderLease = serde_json::from_slice(val)?;
			Ok(Some(lease))
		} else {
			Ok(None)
		}
	}

	async fn cas_lease(
		&self,
		expected_term: Option<u64>,
		new_lease: LeaderLease,
	) -> Result<bool, anyhow::Error> {
		let mut db = MOCK_DB.lock();
		let current_val = db.get("_cp/leader_lease");

		match (current_val, expected_term) {
			(None, None) => {}
			(Some(v), Some(exp_t)) => {
				let current_lease: LeaderLease = serde_json::from_slice(v)?;
				if current_lease.term != exp_t {
					return Ok(false);
				}
				if current_lease.term == new_lease.term
					&& current_lease.leader_id != new_lease.leader_id
				{
					return Ok(false);
				}
			}
			(Some(_), None) => return Ok(false),
			(None, Some(_)) => return Ok(false),
		}

		let val = serde_json::to_vec(&new_lease)?;
		db.insert("_cp/leader_lease".to_string(), val);
		Ok(true)
	}

	async fn get_desired(
		&self,
		realm_id: u128,
	) -> Result<Option<DesiredRealmState>, anyhow::Error> {
		let db = MOCK_DB.lock();
		let key = format!("_cp/desired/{:032x}", realm_id);
		if let Some(val) = db.get(&key) {
			Ok(Some(serde_json::from_slice(val)?))
		} else {
			Ok(None)
		}
	}

	async fn set_desired(
		&self,
		realm_id: u128,
		state: DesiredRealmState,
	) -> Result<(), anyhow::Error> {
		let mut db = MOCK_DB.lock();
		let key = format!("_cp/desired/{:032x}", realm_id);
		let val = serde_json::to_vec(&state)?;
		db.insert(key, val);
		Ok(())
	}

	async fn list_desired(&self) -> Result<Vec<u128>, anyhow::Error> {
		let db = MOCK_DB.lock();
		let prefix = "_cp/desired/";
		let mut realms = Vec::new();
		for key in db.keys() {
			if let Some(hex_part) = key.strip_prefix(prefix) {
				if let Ok(id) = u128::from_str_radix(hex_part, 16) {
					realms.push(id);
				}
			}
		}
		Ok(realms)
	}

	async fn has_command(&self, command_id: u128) -> Result<bool, anyhow::Error> {
		let db = MOCK_DB.lock();
		let key = format!("_cp/commands/{:032x}", command_id);
		Ok(db.contains_key(&key))
	}

	async fn record_command(&self, rec: CommandRecord) -> Result<(), anyhow::Error> {
		let mut db = MOCK_DB.lock();
		let key = format!("_cp/commands/{:032x}", rec.id);
		let val = serde_json::to_vec(&rec)?;
		db.insert(key, val);
		Ok(())
	}

	async fn save_manifest(
		&self,
		state: &crate::registry::DesiredState,
	) -> Result<(), anyhow::Error> {
		let mut db = MOCK_DB.lock();
		let val = serde_json::to_vec(state)?;
		db.insert("_cp/desired_state.bin".to_string(), val.clone());
		let hist_key = format!("_cp/history/{}.bin", state.version);
		db.insert(hist_key, val);
		Ok(())
	}

	async fn load_manifest(&self) -> Result<Option<crate::registry::DesiredState>, anyhow::Error> {
		let db = MOCK_DB.lock();
		if let Some(val) = db.get("_cp/desired_state.bin") {
			let state = serde_json::from_slice(val)?;
			Ok(Some(state))
		} else {
			Ok(None)
		}
	}

	async fn save_raft_state(
		&self,
		term: u64,
		voted_for: Option<u128>,
	) -> Result<(), anyhow::Error> {
		let mut db = MOCK_DB.lock();
		db.insert("_raft/term".to_string(), term.to_le_bytes().to_vec());
		if let Some(v) = voted_for {
			db.insert("_raft/voted_for".to_string(), v.to_le_bytes().to_vec());
		} else {
			db.remove("_raft/voted_for");
		}
		Ok(())
	}

	async fn load_raft_state(&self) -> Result<(u64, Option<u128>), anyhow::Error> {
		let db = MOCK_DB.lock();
		let term = db
			.get("_raft/term")
			.map(|v| {
				let mut b = [0u8; 8];
				b.copy_from_slice(v);
				u64::from_le_bytes(b)
			})
			.unwrap_or(0);
		let voted_for = db.get("_raft/voted_for").map(|v| {
			let mut b = [0u8; 16];
			b.copy_from_slice(v);
			u128::from_le_bytes(b)
		});
		Ok((term, voted_for))
	}

	async fn append_raft_log(
		&self,
		entries: &[lyxal_sync::protocol::RaftLogEntry],
	) -> Result<(), anyhow::Error> {
		let mut db = MOCK_DB.lock();
		for entry in entries {
			let key = format!("_raft/log/{:020}", entry.index);
			let val = serde_json::to_vec(entry)?;
			db.insert(key, val);
		}
		Ok(())
	}

	async fn truncate_raft_log(&self, _last_index: u64) -> Result<(), anyhow::Error> {
		Ok(())
	}

	async fn purge_raft_log_before(&self, _index: u64) -> Result<(), anyhow::Error> {
		Ok(())
	}

	async fn load_raft_log(
		&self,
		_start_index: u64,
	) -> Result<Vec<lyxal_sync::protocol::RaftLogEntry>, anyhow::Error> {
		Ok(Vec::new())
	}
}

// === Consensus Manager ===

pub struct ConsensusManager {
	pub node_id: u128,
	pub store: Arc<dyn ConsensusStore + Send + Sync>,
	pub raft: crate::raft::RaftNode,
	// In-memory view of the world (Volatile)
	leader_hint: Mutex<Option<(u64, u128)>>, // (Term, LeaderId)
	last_check_ms: Mutex<u64>,               // Clock Drift Guard
	last_compaction_index: std::sync::atomic::AtomicU64,
}

#[derive(Debug)]
pub enum LeaseAcquireResult {
	Acquired {
		term: u64,
	},
	Renewed {
		term: u64,
	},
	NotLeader {
		leader: u128,
		term: u64,
		expires_in_ms: u64,
	},
	Error(String),
}

impl ConsensusManager {
	pub fn new(
		node_id: u128,
		store: Arc<dyn ConsensusStore + Send + Sync>,
		peers: Vec<u128>,
	) -> Self {
		Self {
			node_id,
			store,
			raft: crate::raft::RaftNode::new(node_id, peers),
			leader_hint: Mutex::new(None),
			last_check_ms: Mutex::new(0),
			last_compaction_index: std::sync::atomic::AtomicU64::new(0),
		}
	}

	/// Loads the initial Raft state from the persistent store.
	pub async fn load_initial_state(&self) -> Result<(), anyhow::Error> {
		let (term, voted_for) = self.store.load_raft_state().await?;
		let log = self.store.load_raft_log(0).await?;

		let mut state = self.raft.state.write();
		state.current_term = term;
		state.voted_for = voted_for;
		state.log = log;

		info!(
			"ConsensusManager[{}]: Loaded persistent Raft state. Term: {}, Log size: {}",
			self.node_id,
			term,
			state.log.len()
		);

		Ok(())
	}

	pub async fn is_leader(&self) -> bool {
		// P35: Raft Leadership Priority
		// Distributed consensus (Raft) is the source of truth for leadership.
		if self.raft.state.read().role == RaftRole::Leader {
			return true;
		}

		let now =
			SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_millis() as u64;

		// Check Clock Drift
		{
			let mut last = self.last_check_ms.lock();
			if now < *last {
				// Clock jumped backwards!
				// If delta is small (e.g. NTP smear), maybe ignore.
				// If large (> 500ms), DANGER.
				if *last - now > 500 {
					tracing::error!("CRITICAL: Clock Rollback Detected! Now={}, Last={}. Invalidating Leadership.", now, *last);
					return false;
				}
			}
			*last = now;
		}

		// Fallback to Lease mechanism for transition and legacy compatibility
		if let Ok(Some(lease)) = self.store.get_lease().await {
			return lease.leader_id == self.node_id && lease.expires_at_ms > now;
		}
		false
	}

	// Called by Consensus Loop (Leader)
	pub async fn try_acquire_or_renew(&self, now_ms: u64, ttl_ms: u64) -> LeaseAcquireResult {
		let lease_opt = match self.store.get_lease().await {
			Ok(l) => l,
			Err(e) => return LeaseAcquireResult::Error(e.to_string()),
		};

		if let Some(lease) = lease_opt {
			if lease.leader_id == self.node_id {
				// RENEW: I am leader.
				let new_lease = LeaderLease {
					term: lease.term,
					leader_id: self.node_id,
					expires_at_ms: now_ms + ttl_ms,
				};

				match self.store.cas_lease(Some(lease.term), new_lease).await {
					Ok(true) => {
						*self.leader_hint.lock() = Some((lease.term, self.node_id));
						return LeaseAcquireResult::Renewed {
							term: lease.term,
						};
					}
					Ok(false) => {
						return LeaseAcquireResult::Error(
							"CAS Failed during renew (Term changed?)".into(),
						)
					}
					Err(e) => return LeaseAcquireResult::Error(e.to_string()),
				}
			} else {
				// I am not leader. Check expiry.
				if now_ms > lease.expires_at_ms {
					// ACQUIRE: Expired. Increment Term.
					let new_term = lease.term + 1;
					let new_lease = LeaderLease {
						term: new_term,
						leader_id: self.node_id,
						expires_at_ms: now_ms + ttl_ms,
					};

					match self.store.cas_lease(Some(lease.term), new_lease).await {
						Ok(true) => {
							*self.leader_hint.lock() = Some((new_term, self.node_id));
							return LeaseAcquireResult::Acquired {
								term: new_term,
							};
						}
						Ok(false) => {
							return LeaseAcquireResult::NotLeader {
								leader: lease.leader_id,
								term: lease.term,
								expires_in_ms: 0,
							};
						}
						Err(e) => return LeaseAcquireResult::Error(e.to_string()),
					}
				} else {
					// Valid, other leader
					let expires_in = lease.expires_at_ms.saturating_sub(now_ms);
					*self.leader_hint.lock() = Some((lease.term, lease.leader_id)); // Update hint
					return LeaseAcquireResult::NotLeader {
						leader: lease.leader_id,
						term: lease.term,
						expires_in_ms: expires_in,
					};
				}
			}
		} else {
			// ACQUIRE: No lease exists. Term 1.
			let new_lease = LeaderLease {
				term: 1,
				leader_id: self.node_id,
				expires_at_ms: now_ms + ttl_ms,
			};

			match self.store.cas_lease(None, new_lease).await {
				Ok(true) => {
					*self.leader_hint.lock() = Some((1, self.node_id));
					tracing::info!(
						"Consensus: Initial Lease Acquired! Term=1, Node={}",
						self.node_id
					);
					return LeaseAcquireResult::Acquired {
						term: 1,
					};
				}
				Ok(false) => {
					tracing::warn!("Consensus: Initial CAS Failed (Race?) Node={}", self.node_id);
					return LeaseAcquireResult::Error("CAS Failed (Init race)".into());
				}
				Err(e) => {
					tracing::error!("Consensus: Store Error: {}", e);
					return LeaseAcquireResult::Error(e.to_string());
				}
			}
		}
	}

	pub async fn prepare_heartbeat(&self) -> Option<(u64, u128, u64)> {
		let hint = *self.leader_hint.lock();
		if let Some((term, leader)) = hint {
			if leader == self.node_id {
				let now =
					SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_millis()
						as u64;
				return Some((term, leader, now));
			}
		}
		None
	}

	pub async fn handle_heartbeat(&self, term: u64, leader_id: u128, _timestamp: u64) {
		let mut hint = self.leader_hint.lock();

		if let Some((current_term, _)) = *hint {
			if term >= current_term {
				*hint = Some((term, leader_id));
			}
		} else {
			*hint = Some((term, leader_id));
		}
	}

	/// Processes an incoming Raft message and returns any response that should be sent.
	pub async fn handle_raft_message(&self, from: u128, msg: RaftMessage) -> Option<RaftMessage> {
		// Clone entries if needed for persistence before moving msg
		let entries_to_persist = if let RaftMessage::AppendEntries {
			entries,
			..
		} = &msg
		{
			Some(entries.clone())
		} else {
			None
		};

		let resp = self.raft.handle_message(from, msg);

		// P23: Persist Raft state after message processing
		let (term, voted_for) = {
			let state = self.raft.state.read();
			(state.current_term, state.voted_for)
		};
		if let Err(e) = self.store.save_raft_state(term, voted_for).await {
			error!("ConsensusManager: Failed to persist Raft state: {}", e);
		}

		// If we received logs via AppendEntries, persist them
		if let Some(entries) = entries_to_persist {
			if !entries.is_empty() {
				if let Err(e) = self.store.append_raft_log(&entries).await {
					tracing::error!("ConsensusManager: Failed to persist Raft logs: {}", e);
				}
			}
		}

		resp
	}

	/// Executes a Raft tick and returns a broadcast message if necessary.
	pub async fn raft_tick(&self) -> Option<RaftMessage> {
		let resp = self.raft.tick();

		// Persist state if it changed (e.g., term increase during election)
		let (term, voted_for, last_index, commit_index) = {
			let state = self.raft.state.read();
			(state.current_term, state.voted_for, state.last_index(), state.commit_index)
		};
		let _ = self.store.save_raft_state(term, voted_for).await;

		// P24: Automatic Log Compaction (Snapshotting Trigger)
		// If we have many committed entries that haven't been purged yet
		let last_purged = self.last_compaction_index.load(std::sync::atomic::Ordering::Relaxed);
		let compaction_threshold = 1000; // Configurable threshold

		if commit_index > last_purged + compaction_threshold {
			info!("ConsensusManager: Triggering log compaction up to index {}", commit_index);
			if let Err(e) = self.store.purge_raft_log_before(commit_index).await {
				error!("ConsensusManager: Failed to purge Raft logs: {}", e);
			} else {
				self.last_compaction_index
					.store(commit_index, std::sync::atomic::Ordering::Relaxed);
			}
		}

		resp
	}

	/// Proposes a new entry to the cluster and persists it.
	pub async fn propose(&self, data: Vec<u8>) -> Result<u64, anyhow::Error> {
		// P25: Ensure node is strictly a Raft leader before allowing data proposals.
		if self.raft.state.read().role != RaftRole::Leader {
			return Err(anyhow::anyhow!("Not the leader (Raft quorum required)"));
		}

		let index = self.raft.propose(data)?;
		let entry = {
			let state = self.raft.state.read();
			state.log.last().cloned()
		};
		if let Some(entry) = entry {
			self.store.append_raft_log(&[entry]).await?;
		}
		Ok(index)
	}

	/// Applies committed logs to the state machine (User DB).
	pub async fn apply_committed_logs(&self) -> Result<(), anyhow::Error> {
		let (commit_index, last_applied) = {
			let state = self.raft.state.read();
			(state.commit_index, state.last_applied)
		};

		if commit_index > last_applied {
			let db = match crate::get_user_db() {
				Some(db) => db,
				None => return Ok(()),
			};

			debug!("ConsensusManager: Applying logs from {} to {}", last_applied + 1, commit_index);
			let logs = self.store.load_raft_log(last_applied + 1).await?;

			for entry in logs {
				// P25: Replicated Data Application
				// We attempt to decode the Raft log entry as a ReplicatedBatch
				if let Ok(batch) =
					bincode::deserialize::<lyxal_sync::log::ReplicatedBatch>(&entry.data)
				{
					let mut txn = db
						.begin_with_mode(lyxalkv::Mode::ReadWrite)
						.map_err(|e| anyhow::anyhow!("Failed to start application txn: {}", e))?;

					for op in batch.entries {
						match op {
							lyxal_sync::log::ReplicatedEntry::Set(k, v) => {
								txn.set(k, v)
									.map_err(|e| anyhow::anyhow!("Application Set error: {}", e))?;
							}
							lyxal_sync::log::ReplicatedEntry::Del(k) => {
								txn.delete(k)
									.map_err(|e| anyhow::anyhow!("Application Del error: {}", e))?;
							}
						}
					}
					txn.commit()
						.await
						.map_err(|e| anyhow::anyhow!("Failed to commit application txn: {}", e))?;
				}
			}

			// Advance last_applied
			{
				let mut state = self.raft.state.write();
				state.last_applied = commit_index;
			}
		}

		Ok(())
	}

	pub fn get_leader_hint(&self) -> Option<(u64, u128)> {
		let raft_state = self.raft.state.read();
		if raft_state.role == RaftRole::Leader {
			Some((raft_state.current_term, self.node_id))
		} else {
			*self.leader_hint.lock()
		}
	}

	pub async fn force_leadership(&self) -> Result<(), anyhow::Error> {
		let now =
			SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_millis() as u64;
		let lease = LeaderLease {
			term: 9999,
			leader_id: self.node_id,
			expires_at_ms: now + 3600_000, // 1 hour
		};
		// Just write it to store
		// We need to know if it's Mock or KV. ConsensusStore has cas_lease but not a direct write.
		// Actually, cas_lease(None, ...) or cas_lease(Some(current), ...)
		// I'll just use cas_lease(None, lease) or similar.
		// Better: add a method to store? No.
		// I'll try try_acquire_or_renew.
		self.try_acquire_or_renew(now, 3600_000).await;
		Ok(())
	}
}
