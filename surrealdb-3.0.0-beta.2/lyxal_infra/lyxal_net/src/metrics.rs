use dashmap::DashMap;
use parking_lot::Mutex;
use serde::Serialize;
use std::sync::atomic::{AtomicU32, AtomicU64, AtomicUsize, Ordering};
use std::sync::Arc;

#[derive(Debug, Serialize)]
pub struct HistoSnapshot {
	pub count: u64,
	pub min: u64,
	pub max: u64,
	pub p50: u64,
	pub p95: u64,
	pub p99: u64,
}

pub struct Histo {
	samples: Mutex<Vec<u64>>,
	cap: usize,
	count: AtomicU64,
	min: AtomicU64,
	max: AtomicU64,
}

impl Histo {
	pub fn new(cap: usize) -> Self {
		Self {
			samples: Mutex::new(Vec::with_capacity(cap)),
			cap,
			count: AtomicU64::new(0),
			min: AtomicU64::new(u64::MAX),
			max: AtomicU64::new(0),
		}
	}

	pub fn observe(&self, val: u64) {
		self.count.fetch_add(1, Ordering::Relaxed);

		// Update Min/Max (Relaxed is fine for metrics)
		let mut current_min = self.min.load(Ordering::Relaxed);
		while val < current_min {
			match self.min.compare_exchange_weak(
				current_min,
				val,
				Ordering::Relaxed,
				Ordering::Relaxed,
			) {
				Ok(_) => break,
				Err(actual) => current_min = actual,
			}
		}

		let mut current_max = self.max.load(Ordering::Relaxed);
		while val > current_max {
			match self.max.compare_exchange_weak(
				current_max,
				val,
				Ordering::Relaxed,
				Ordering::Relaxed,
			) {
				Ok(_) => break,
				Err(actual) => current_max = actual,
			}
		}

		let mut lock = self.samples.lock();
		if lock.len() < self.cap {
			lock.push(val);
		} else {
			// Simple ring buffer simulation: replace a random or the next index
			// For simplicity in P10.1, we'll just wrap around if we wanted a real ring,
			// but fixed-size sample for percentiles is often enough.
			let idx = (self.count.load(Ordering::Relaxed) as usize) % self.cap;
			lock[idx] = val;
		}
	}

	pub fn snapshot(&self) -> HistoSnapshot {
		let mut lock = self.samples.lock();
		if lock.is_empty() {
			return HistoSnapshot {
				count: 0,
				min: 0,
				max: 0,
				p50: 0,
				p95: 0,
				p99: 0,
			};
		}

		lock.sort_unstable();
		let len = lock.len();

		HistoSnapshot {
			count: self.count.load(Ordering::Relaxed),
			min: self.min.load(Ordering::Relaxed),
			max: self.max.load(Ordering::Relaxed),
			p50: lock[len / 2],
			p95: lock[(len * 95) / 100],
			p99: lock[(len * 99) / 100],
		}
	}
}

#[derive(Serialize)]
pub struct MetricsSnapshot {
	pub node_id: u128,
	pub counters: CountersSnapshot,
	pub gauges: GaugesSnapshot,
	pub latencies: LatenciesSnapshot,
}

#[derive(Serialize)]
pub struct CountersSnapshot {
	pub deltas_sent: u64,
	pub deltas_received: u64,
	pub snapshots_generated: u64,
	pub snapshots_applied: u64,
	pub snapshot_raw_bytes: u64,
	pub snapshot_compressed_bytes: u64,
	pub frames_rejected_hmac: u64,
	pub frames_rejected_replay: u64,
	pub fallback_heap_reads: u64,
	pub log_missing_detected: u64,
	pub realm_mismatch_rejects: u64,
	pub trust_rejections: u64,
	pub identity_mismatch_rejections: u64,
}

#[derive(Serialize)]
pub struct GaugesSnapshot {
	pub peer_count: u64,
	pub active_transfers: u64,
	pub healthy_peers: u64,
	pub lagging_peers: u64,
	pub syncing_peers: u64,
	pub needs_snapshot_peers: u64,
}

#[derive(Serialize)]
pub struct LatenciesSnapshot {
	pub apply_delta_ms: HistoSnapshot,
	pub apply_snapshot_ms: HistoSnapshot,
	pub snapshot_build_ms: HistoSnapshot,
	pub snapshot_transfer_ms: HistoSnapshot,
	pub clock_flush_ms: HistoSnapshot,
}

pub struct MetricsCollector {
	node_id: u128,
	// Counters
	pub deltas_sent: AtomicU64,
	pub deltas_received: AtomicU64,
	pub snapshots_generated: AtomicU64,
	pub snapshots_applied: AtomicU64,
	pub snapshot_raw_bytes: AtomicU64,
	pub snapshot_compressed_bytes: AtomicU64,
	pub frames_rejected_hmac: AtomicU64,
	pub frames_rejected_replay: AtomicU64,
	pub fallback_heap_reads: AtomicU64,
	pub log_missing_detected: AtomicU64,
	pub realm_mismatch_rejects: AtomicU64,
	pub trust_rejections: AtomicU64,
	pub identity_mismatch_rejections: AtomicU64,

	// Gauges
	pub peer_count: AtomicU64,
	pub active_transfers: AtomicU64,
	pub healthy_peers: AtomicU64,
	pub lagging_peers: AtomicU64,
	pub syncing_peers: AtomicU64,
	pub needs_snapshot_peers: AtomicU64,

	// Histos
	pub apply_delta_ms: Histo,
	pub apply_snapshot_ms: Histo,
	pub snapshot_build_ms: Histo,
	pub snapshot_transfer_ms: Histo,
	pub clock_flush_ms: Histo,

	// P21: Realm-scoped Fairness Metrics (Store gauges/counters per realm)
	// Key: realm_id
	pub realm_active_peers: DashMap<u128, Arc<AtomicUsize>>,
	pub realm_snapshot_tokens: DashMap<u128, Arc<AtomicU32>>,
	pub realm_quota_rejects_peers: DashMap<u128, Arc<AtomicU64>>,
	pub realm_quota_rejects_snapshots: DashMap<u128, Arc<AtomicU64>>,
}

impl MetricsCollector {
	pub fn new(node_id: u128) -> Self {
		Self {
			node_id,
			deltas_sent: AtomicU64::new(0),
			deltas_received: AtomicU64::new(0),
			snapshots_generated: AtomicU64::new(0),
			snapshots_applied: AtomicU64::new(0),
			snapshot_raw_bytes: AtomicU64::new(0),
			snapshot_compressed_bytes: AtomicU64::new(0),
			frames_rejected_hmac: AtomicU64::new(0),
			frames_rejected_replay: AtomicU64::new(0),
			fallback_heap_reads: AtomicU64::new(0),
			log_missing_detected: AtomicU64::new(0),
			realm_mismatch_rejects: AtomicU64::new(0),
			trust_rejections: AtomicU64::new(0),
			identity_mismatch_rejections: AtomicU64::new(0),

			peer_count: AtomicU64::new(0),
			active_transfers: AtomicU64::new(0),
			healthy_peers: AtomicU64::new(0),
			lagging_peers: AtomicU64::new(0),
			syncing_peers: AtomicU64::new(0),
			needs_snapshot_peers: AtomicU64::new(0),

			apply_delta_ms: Histo::new(1024),
			apply_snapshot_ms: Histo::new(1024),
			snapshot_build_ms: Histo::new(1024),
			snapshot_transfer_ms: Histo::new(1024),
			clock_flush_ms: Histo::new(1024),

			realm_active_peers: DashMap::new(),
			realm_snapshot_tokens: DashMap::new(),
			realm_quota_rejects_peers: DashMap::new(),
			realm_quota_rejects_snapshots: DashMap::new(),
		}
	}

	pub fn snapshot(&self) -> MetricsSnapshot {
		MetricsSnapshot {
			node_id: self.node_id,
			counters: CountersSnapshot {
				deltas_sent: self.deltas_sent.load(Ordering::Relaxed),
				deltas_received: self.deltas_received.load(Ordering::Relaxed),
				snapshots_generated: self.snapshots_generated.load(Ordering::Relaxed),
				snapshots_applied: self.snapshots_applied.load(Ordering::Relaxed),
				snapshot_raw_bytes: self.snapshot_raw_bytes.load(Ordering::Relaxed),
				snapshot_compressed_bytes: self.snapshot_compressed_bytes.load(Ordering::Relaxed),
				frames_rejected_hmac: self.frames_rejected_hmac.load(Ordering::Relaxed),
				frames_rejected_replay: self.frames_rejected_replay.load(Ordering::Relaxed),
				fallback_heap_reads: self.fallback_heap_reads.load(Ordering::Relaxed),
				log_missing_detected: self.log_missing_detected.load(Ordering::Relaxed),
				realm_mismatch_rejects: self.realm_mismatch_rejects.load(Ordering::Relaxed),
				trust_rejections: self.trust_rejections.load(Ordering::Relaxed),
				identity_mismatch_rejections: self
					.identity_mismatch_rejections
					.load(Ordering::Relaxed),
			},
			gauges: GaugesSnapshot {
				peer_count: self.peer_count.load(Ordering::Relaxed),
				active_transfers: self.active_transfers.load(Ordering::Relaxed),
				healthy_peers: self.healthy_peers.load(Ordering::Relaxed),
				lagging_peers: self.lagging_peers.load(Ordering::Relaxed),
				syncing_peers: self.syncing_peers.load(Ordering::Relaxed),
				needs_snapshot_peers: self.needs_snapshot_peers.load(Ordering::Relaxed),
			},
			latencies: LatenciesSnapshot {
				apply_delta_ms: self.apply_delta_ms.snapshot(),
				apply_snapshot_ms: self.apply_snapshot_ms.snapshot(),
				snapshot_build_ms: self.snapshot_build_ms.snapshot(),
				snapshot_transfer_ms: self.snapshot_transfer_ms.snapshot(),
				clock_flush_ms: self.clock_flush_ms.snapshot(),
			},
		}
	}
}

lazy_static::lazy_static! {
	static ref GLOBAL_METRICS: Mutex<Option<Arc<MetricsCollector>>> = Mutex::new(None);
}

pub fn init_metrics(node_id: u128) -> Arc<MetricsCollector> {
	let mut lock = GLOBAL_METRICS.lock();
	if let Some(m) = &*lock {
		// If already initialized with a real node_id, return it.
		// If it was lazy-initialized with 0, we replace it with the real one.
		if m.node_id != 0 || node_id == 0 {
			return m.clone();
		}
	}
	let collector = Arc::new(MetricsCollector::new(node_id));
	*lock = Some(collector.clone());
	collector
}

pub fn get_metrics() -> Arc<MetricsCollector> {
	let mut lock = GLOBAL_METRICS.lock();
	if let Some(m) = &*lock {
		return m.clone();
	}
	// Fallback for embedded mode: initialize with node_id 0 if accessed before bootstrap
	let collector = Arc::new(MetricsCollector::new(0));
	*lock = Some(collector.clone());
	collector
}

pub fn spawn_dashboard_reporter(collector: Arc<MetricsCollector>) {
	tokio::spawn(async move {
		let mut interval = tokio::time::interval(std::time::Duration::from_secs(10));
		loop {
			interval.tick().await;
			let snap = collector.snapshot();
			if let Ok(json) = serde_json::to_string(&snap) {
				log::info!("DASHBOARD: {}", json);
			}
		}
	});
}
