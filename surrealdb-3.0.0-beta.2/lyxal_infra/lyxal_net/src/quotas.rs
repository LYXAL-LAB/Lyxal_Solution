use std::sync::atomic::{AtomicUsize, AtomicU32, AtomicU64, Ordering};
use std::sync::Arc;
use tokio::sync::Mutex; // Using Tokio Mutex for last_refill potentially, or std if simple
use std::time::Instant;
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RealmQuota {
    pub max_peers: usize,
    pub max_snapshots_per_hour: u32,
    pub snapshot_bucket_size: u32,
    /// Maximum bandwidth in bytes per second
    pub bandwidth_limit_bps: u64,
}

impl Default for RealmQuota {
    fn default() -> Self {
        Self {
            max_peers: 50,
            max_snapshots_per_hour: 6, // 1 per 10 min
            snapshot_bucket_size: 1,
            bandwidth_limit_bps: 10 * 1024 * 1024, // 10MB/s default
        }
    }
}

#[derive(Debug)]
pub struct RealmRuntimeStats {
    pub active_peers: AtomicUsize,
    pub snapshot_tokens: AtomicU32,
    pub bandwidth_tokens: AtomicU64,
    pub last_refill: std::sync::Mutex<Instant>,
    pub realm_id: u128,
}

impl RealmRuntimeStats {
    pub fn new(realm_id: u128, quota: &RealmQuota) -> Self {
        Self {
            active_peers: AtomicUsize::new(0),
            snapshot_tokens: AtomicU32::new(quota.snapshot_bucket_size),
            bandwidth_tokens: AtomicU64::new(quota.bandwidth_limit_bps),
            last_refill: std::sync::Mutex::new(Instant::now()),
            realm_id,
        }
    }

    /// Consumes bandwidth tokens and refills if necessary.
    /// Returns the number of bytes that can be sent (0 if throttled).
    pub fn consume_bandwidth(&self, amount: u64, quota: &RealmQuota) -> u64 {
        let mut last_refill = self.last_refill.lock().unwrap();
        let now = Instant::now();
        let elapsed = now.duration_since(*last_refill).as_secs_f64();

        if elapsed > 0.1 {
            // Refill tokens
            let refill = (elapsed * quota.bandwidth_limit_bps as f64) as u64;
            let current = self.bandwidth_tokens.load(Ordering::Acquire);
            let next = (current + refill).min(quota.bandwidth_limit_bps * 2); // Burst up to 2s
            self.bandwidth_tokens.store(next, Ordering::Release);
            *last_refill = now;
        }

        let current = self.bandwidth_tokens.load(Ordering::Acquire);
        if current >= amount {
            self.bandwidth_tokens.fetch_sub(amount, Ordering::SeqCst);
            amount
        } else {
            self.bandwidth_tokens.store(0, Ordering::Release);
            current
        }
    }
}

pub struct PeerSlotGuard {
    stats: Arc<RealmRuntimeStats>,
}

impl PeerSlotGuard {
    pub fn new(stats: Arc<RealmRuntimeStats>) -> Self {
        Self { stats }
    }
}

impl Drop for PeerSlotGuard {
    fn drop(&mut self) {
        let prev = self.stats.active_peers.fetch_sub(1, Ordering::SeqCst);
        // Metrics sync could happen here if needed, or we rely on pulling directly from these atomics

        // Link to global metrics for visibility
        if let metrics = crate::metrics::get_metrics() {
             metrics.realm_active_peers.insert(self.stats.realm_id, Arc::new(AtomicUsize::new(prev - 1)));
             // Actually, the metrics collector map stores Arc<Atomic>, so we should ideally update THAT atomic
             // But here we have local stat. We can rely on a pull-model or just update global metric here.
             // For P10/P21 simple implementation: we update the global metric gauge.
             // Better yet: MetricsCollector should access these Realm Runtime Stats? No, MetricsCollector is global.
             // Let's just update the gauge in MetricsCollector on change for "real-time" view.
             if let Some(gauge) = metrics.realm_active_peers.get(&self.stats.realm_id) {
                 gauge.store(prev - 1, Ordering::Relaxed);
             }
        }
    }
}
