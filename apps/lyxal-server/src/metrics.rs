use serde::Serialize;
use std::sync::{
    Arc,
    atomic::{AtomicU64, Ordering},
};
use std::time::Instant;

#[derive(Clone)]
pub struct Metrics {
    inner: Arc<MetricsInner>,
}

struct MetricsInner {
    started_at: Instant,
    requests_total: AtomicU64,
    requests_in_flight: AtomicU64,
    requests_failed: AtomicU64,
    module_failures: AtomicU64,
}

#[derive(Debug, Serialize)]
pub struct MetricsSnapshot {
    pub uptime_seconds: u64,
    pub requests_total: u64,
    pub requests_in_flight: u64,
    pub requests_failed: u64,
    pub module_failures: u64,
}

impl Default for Metrics {
    fn default() -> Self {
        Self {
            inner: Arc::new(MetricsInner {
                started_at: Instant::now(),
                requests_total: AtomicU64::new(0),
                requests_in_flight: AtomicU64::new(0),
                requests_failed: AtomicU64::new(0),
                module_failures: AtomicU64::new(0),
            }),
        }
    }
}

impl Metrics {
    pub fn request_started(&self) {
        self.inner.requests_total.fetch_add(1, Ordering::Relaxed);
        self.inner.requests_in_flight.fetch_add(1, Ordering::Relaxed);
    }

    pub fn request_finished(&self, failed: bool) {
        self.inner.requests_in_flight.fetch_sub(1, Ordering::Relaxed);
        if failed {
            self.inner.requests_failed.fetch_add(1, Ordering::Relaxed);
        }
    }

    pub fn module_failed(&self) {
        self.inner.module_failures.fetch_add(1, Ordering::Relaxed);
    }

    pub fn snapshot(&self) -> MetricsSnapshot {
        MetricsSnapshot {
            uptime_seconds: self.inner.started_at.elapsed().as_secs(),
            requests_total: self.inner.requests_total.load(Ordering::Relaxed),
            requests_in_flight: self.inner.requests_in_flight.load(Ordering::Relaxed),
            requests_failed: self.inner.requests_failed.load(Ordering::Relaxed),
            module_failures: self.inner.module_failures.load(Ordering::Relaxed),
        }
    }
}
