use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::OnceLock;

/// Metrics collected by the LyxalKV engine.
/// These are designed to be read by external systems (e.g., Lyxal OS)
/// for monitoring and telemetry.
#[derive(Debug, Default)]
pub struct EngineMetrics {
    /// Bloom filter hits (key found in filter)
    pub bloom_hits: AtomicU64,
    /// Bloom filter misses (key not in filter)
    pub bloom_misses: AtomicU64,
    /// Block cache hits
    pub block_cache_hits: AtomicU64,
    /// Block cache misses
    pub block_cache_misses: AtomicU64,
    
    /// Total bytes written to WAL.
    pub wal_bytes_written: AtomicU64,
    /// Total bytes read from WAL.
    pub wal_bytes_read: AtomicU64,
    /// Total bytes written to SSTables.
    pub sstable_bytes_written: AtomicU64,
    /// Total bytes read from SSTables.
    pub sstable_bytes_read: AtomicU64,
    /// Total bytes added to memtables.
    pub memtable_bytes_added: AtomicU64,

    /// Number of compactions completed.
    pub compactions_completed: AtomicU64,
    /// Total time spent in compactions (nanoseconds).
    pub compaction_nanos: AtomicU64,
    /// Total time spent in fsync operations (nanoseconds).
    pub sync_nanos: AtomicU64,
    
    /// Number of WAL recoveries performed.
    pub wal_recoveries: AtomicU64,
    /// Total time spent in WAL recovery (nanoseconds).
    pub wal_recovery_time_ns: AtomicU64,

    /// Total read latency (nanoseconds).
    pub read_nanos: AtomicU64,
    /// Total write latency (nanoseconds).
    pub write_nanos: AtomicU64,
    
    /// Active transactions count.
    pub active_transactions: AtomicU64,
    /// Active snapshots count.
    pub active_snapshots: AtomicU64,

    /// Number of ZSTD compressions.
    pub zstd_compressions: AtomicU64,
    /// Total time spent in ZSTD compression (nanoseconds).
    pub zstd_compression_time_ns: AtomicU64,
    /// Number of ZSTD decompressions.
    pub zstd_decompressions: AtomicU64,
    /// Total time spent in ZSTD decompression (nanoseconds).
    pub zstd_decompression_time_ns: AtomicU64,
    
    /// Number of LZ4/Snappy compressions.
    pub lz4_compressions: AtomicU64,
    /// Total time spent in LZ4/Snappy compression (nanoseconds).
    pub lz4_compression_time_ns: AtomicU64,
    /// Number of LZ4/Snappy decompressions.
    pub lz4_decompressions: AtomicU64,
    /// Total time spent in LZ4/Snappy decompression (nanoseconds).
    pub lz4_decompression_time_ns: AtomicU64,
}

static METRICS: OnceLock<EngineMetrics> = OnceLock::new();

impl EngineMetrics {
    /// Returns the global instance of EngineMetrics.
    pub fn get() -> &'static Self {
        METRICS.get_or_init(Self::default)
    }

    pub fn new() -> Self {
        Self::default()
    }

    /// Increments a counter.
    pub fn inc(&self, counter: &AtomicU64) {
        counter.fetch_add(1, Ordering::Relaxed);
    }

    /// Adds a value to a counter.
    pub fn add(&self, counter: &AtomicU64, val: u64) {
        counter.fetch_add(val, Ordering::Relaxed);
    }

    /// Adds a duration to a timer (in nanoseconds).
    pub fn add_duration(&self, timer: &AtomicU64, duration: std::time::Duration) {
        timer.fetch_add(duration.as_nanos() as u64, Ordering::Relaxed);
    }

    /// Records read latency.
    pub fn record_read_latency(&self, nanos: u64) {
        self.read_nanos.fetch_add(nanos, Ordering::Relaxed);
    }

    /// Records write latency.
    pub fn record_write_latency(&self, nanos: u64) {
        self.write_nanos.fetch_add(nanos, Ordering::Relaxed);
    }

    /// Reads the current value of a counter.
    pub fn read(&self, counter: &AtomicU64) -> u64 {
        counter.load(Ordering::Relaxed)
    }
}

