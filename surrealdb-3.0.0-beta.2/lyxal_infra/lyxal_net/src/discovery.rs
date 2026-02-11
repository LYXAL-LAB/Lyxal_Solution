use crate::config::StaticConfig;
use log::{debug, info, warn};
use rand::Rng; // For jitter
use std::collections::{HashMap, HashSet};
use std::net::SocketAddr;
use std::time::{Duration, Instant};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CandidateSource {
	Seed,
	Hint,
}

#[derive(Debug, Clone)]
struct CandidateState {
	failures: u32,
	next_attempt: Instant,
	last_seen: Instant,
	source: CandidateSource,
	expires_at: Option<Instant>, // None for seeds
	realm_id: u128,              // P20.8: Candidates must be tagged
}

pub struct DiscoveryManager {
	candidates: HashMap<SocketAddr, CandidateState>,
	in_flight: HashSet<SocketAddr>,
	config: StaticConfig,

	// Rate Limiting State
	dial_history: Vec<Instant>, // Sliding window of dial times
}

impl DiscoveryManager {
	pub fn new(config: StaticConfig) -> Self {
		let mut candidates = HashMap::new();

		// 1. Parse Seeds
		for seed_str in &config.seeds {
			match seed_str.parse::<SocketAddr>() {
				Ok(addr) => {
					candidates.insert(
						addr,
						CandidateState {
							failures: 0,
							next_attempt: Instant::now(), // Ready immediately
							last_seen: Instant::now(),
							source: CandidateSource::Seed,
							expires_at: None,          // Seeds never expire
							realm_id: config.realm_id, // Seeds tagged with own realm
						},
					);
				}
				Err(e) => {
					warn!("Invalid Seed Address '{}': {}. Ignoring.", seed_str, e);
				}
			}
		}

		Self {
			candidates,
			in_flight: HashSet::new(),
			config,
			dial_history: Vec::new(),
		}
	}

	/// Called by the bootstrap loop to get a list of addresses to dial.
	/// respecting: max_outbound, max_candidates, rate_limits, cooldowns, in_flight, active_set.
	pub fn get_dial_candidates(
		&mut self,
		current_outbound_count: usize,
		active_peers: &HashSet<SocketAddr>,
		bind_addr_chk: &str, // Simple check if known
	) -> Vec<SocketAddr> {
		debug!(
			"Discovery: Checking candidates. Active: {}, Max: {}, Candidates: {}",
			current_outbound_count,
			self.config.max_outbound_peers,
			self.candidates.len()
		);

		// 1. Check Max Outbound
		if current_outbound_count >= self.config.max_outbound_peers {
			debug!("Discovery: Max outbound peers reached. Skipping dial.");
			return Vec::new();
		}
		let slots_available = self.config.max_outbound_peers - current_outbound_count;

		// 2. Check Rate Limit (Global)
		let now = Instant::now();
		let window = Duration::from_secs(self.config.dial_rate_limit.window_secs);
		// Clean history
		self.dial_history.retain(|t| now.duration_since(*t) < window);

		if self.dial_history.len() >= self.config.dial_rate_limit.max_dials {
			debug!(
				"Discovery Rate Limit reached ({}/window). Skipping dial.",
				self.dial_history.len()
			);
			return Vec::new();
		}

		let mut selected = Vec::new();
		let mut count = 0;

		// Iterate candidates (Prioritize Seeds?)
		// Ideally we sort by (Seed > Hint) and (next_attempt asc).
		// For simplicity: iterate all, filter eligible, then pick best `n`.

		let mut eligible: Vec<SocketAddr> = self
			.candidates
			.iter()
			.filter(|(addr, state)| {
				// A. Not active
				if active_peers.contains(addr) {
					return false;
				}

				// B. Not in flight
				if self.in_flight.contains(addr) {
					return false;
				}

				// C. Not self (Basic String check against config bind_addr)
				// The caller passes canonical bind_addr, or we check against config.bind_addr.
				// Note: config.bind_addr might be "0.0.0.0".
				// Ideally active_peers check handles connected state.
				// Self check: "Don't dial own public IP if deduced?". Use simple string dedup if passed.
				if addr.to_string() == self.config.bind_addr {
					return false;
				}
				if addr.to_string() == bind_addr_chk {
					return false;
				}

				// D. Cooldown / Backoff
				if now < state.next_attempt {
					return false;
				}

				// E. TTL
				if let Some(expiry) = state.expires_at {
					if now > expiry {
						return false;
					}
				}

				// F. Realm Filter (P20.8: Strict Isolation)
				if state.realm_id != self.config.realm_id {
					return false;
				}

				true
			})
			.map(|(addr, _)| *addr)
			.collect();

		// Limit to available slots and rate limit capacity
		let limit = std::cmp::min(
			slots_available,
			self.config.dial_rate_limit.max_dials - self.dial_history.len(),
		);

		// Shuffle or Sort? Seeds first.
		eligible.sort_by(|a, b| {
			let sa = self.candidates.get(a).unwrap();
			let sb = self.candidates.get(b).unwrap();
			// Source: Seed < Hint (Seed is 0, Hint 1) -> Seed first? Source enum: Seed=0.
			// Using derives, source enum ord might assume declaration order.
			// Let's implement manually if tricky.
			// Just use failure count? Less failures first.
			let rank_a = (
				if sa.source == CandidateSource::Seed {
					0
				} else {
					1
				},
				sa.failures,
			);
			let rank_b = (
				if sb.source == CandidateSource::Seed {
					0
				} else {
					1
				},
				sb.failures,
			);
			rank_a.cmp(&rank_b)
		});

		for addr in eligible.into_iter().take(limit) {
			self.in_flight.insert(addr);
			self.dial_history.push(now);
			selected.push(addr);
		}

		selected
	}

	pub fn report_success(&mut self, addr: SocketAddr) {
		if self.in_flight.remove(&addr) {
			if let Some(state) = self.candidates.get_mut(&addr) {
				state.failures = 0;
				state.next_attempt = Instant::now(); // Reset, ready if dropped
				state.last_seen = Instant::now();
			}
		}
	}

	pub fn report_failure(&mut self, addr: SocketAddr) {
		if self.in_flight.remove(&addr) {
			if let Some(state) = self.candidates.get_mut(&addr) {
				state.failures += 1;

				// Exponential Backoff
				let base = self.config.backoff.base_ms as u64;
				let max = self.config.backoff.max_ms as u64;

				// base * 2^(failures-1)
				let exp = 1u32.checked_shl(state.failures.min(10) - 1).unwrap_or(1) as u64; // Cap shift to avoid overflow
				let mut backoff_ms = base.saturating_mul(exp).min(max);

				// Jitter
				if self.config.backoff.jitter {
					let jitter = rand::thread_rng().gen_range(0..=250); // 0-250ms
					backoff_ms = backoff_ms.saturating_add(jitter);
				}

				state.next_attempt = Instant::now() + Duration::from_millis(backoff_ms);
				info!(
					"Discovery: Dial failed for {}. Failures: {}. Backoff: {}ms",
					addr, state.failures, backoff_ms
				);
			}
		}
	}

	// P17.4 / P20.8 Gossip Hints integration
	pub fn add_hints(&mut self, hints: Vec<(SocketAddr, u128)>) {
		let now = Instant::now();
		let max_candidates = self.config.max_candidates;
		let ttl = Duration::from_secs(self.config.candidate_ttl_secs);

		for (addr, realm_id) in hints {
			if realm_id != self.config.realm_id {
				continue; // P20.8: Anti-Mixup. Ignore hints for other realms.
			}

			// Infrastructure Filter: Ignore ephemeral ports from SurrealDB discovery
			// We only accept hints on ports used by our seeds or known P2P infrastructure ports
			let is_known_infra_port = self
				.config
				.seeds
				.iter()
				.filter_map(|s| s.parse::<std::net::SocketAddr>().ok())
				.any(|a| a.port() == addr.port())
				|| addr.port() == 9000
				|| addr.port() == 9001;

			if !is_known_infra_port {
				debug!("Discovery: Dropping hint with ephemeral port: {}", addr);
				continue;
			}
			if self.candidates.len() >= max_candidates {
				// Simple eviction: remove expired? Or random hint?
				self.candidates.retain(|_, s| {
					if s.source == CandidateSource::Seed {
						return true;
					} // Keep seeds
					if let Some(exp) = s.expires_at {
						if now > exp {
							return false;
						}
					}
					true
				});
				if self.candidates.len() >= max_candidates {
					continue; // Still full, drop hint
				}
			}

			self.candidates.entry(addr).or_insert(CandidateState {
				failures: 0,
				next_attempt: now,
				last_seen: now,
				source: CandidateSource::Hint,
				expires_at: Some(now + ttl),
				realm_id,
			});
		}
	}

	/// P24: Purge dead candidates to prevent memory bloat and useless dials.
	/// Seeds are NEVER purged.
	pub fn cleanup_dead_candidates(&mut self) {
		let now = Instant::now();
		let max_failures = 10; // Threshold for persistent failures
		let max_inactivity = Duration::from_secs(3600 * 24); // 24 hours

		self.candidates.retain(|_, state| {
			if state.source == CandidateSource::Seed {
				return true;
			}

			// 1. If expired by TTL
			if let Some(expiry) = state.expires_at {
				if now > expiry {
					return false;
				}
			}

			// 2. If too many failures and not seen recently
			if state.failures >= max_failures
				&& now.duration_since(state.last_seen) > max_inactivity
			{
				return false;
			}

			true
		});
	}
}
