extern crate lyxal_revision as revision;

pub mod batch;
pub mod bplustree;
mod cache;
mod checkpoint;
mod clock;
mod commit;
mod compaction;
mod comparator;
mod compression;
mod discard;
mod error;
mod iter;
mod levels;
mod lockfile;
mod lsm;
pub mod metrics;
mod memtable;
mod oracle;
mod snapshot;
mod sstable;
mod task;
mod transaction;
mod data;
mod vfs;
mod vlog;
pub mod wal;

#[cfg(test)]
mod test;

use std::path::PathBuf;
use std::sync::Arc;



pub use data::DataRef;
pub use comparator::{BytewiseComparator, Comparator, InternalKeyComparator, TimestampComparator};
pub use clock::{DefaultLogicalClock, LogicalClock};
pub use error::{Error, Result};
pub use lsm::{Tree, TreeBuilder};
pub use transaction::{Durability, Mode, ReadOptions, Transaction, WriteOptions};
pub use vfs::remove_file;

/// An optimised trait for converting values to bytes only when needed
pub trait IntoBytes {
	/// Convert the key to a slice of bytes
	fn as_slice(&self) -> &[u8];
	/// Convert the key to an owned bytes slice
	fn into_bytes(self) -> Value;
}

impl IntoBytes for &[u8] {
	fn as_slice(&self) -> &[u8] {
		self
	}

	fn into_bytes(self) -> Value {
		self.to_vec()
	}
}

impl<const N: usize> IntoBytes for &[u8; N] {
	fn as_slice(&self) -> &[u8] {
		&self[..]
	}

	fn into_bytes(self) -> Value {
		self.to_vec()
	}
}

impl IntoBytes for Vec<u8> {
	fn as_slice(&self) -> &[u8] {
		self.as_slice()
	}

	fn into_bytes(self) -> Value {
		self
	}
}

impl IntoBytes for &Vec<u8> {
	fn as_slice(&self) -> &[u8] {
		&self[..]
	}

	fn into_bytes(self) -> Value {
		self.clone()
	}
}

impl IntoBytes for &str {
	fn as_slice(&self) -> &[u8] {
		self.as_bytes()
	}

	fn into_bytes(self) -> Value {
		self.as_bytes().to_vec()
	}
}

impl IntoBytes for Box<[u8]> {
	fn as_slice(&self) -> &[u8] {
		self.as_ref()
	}

	fn into_bytes(self) -> Value {
		self.into_vec()
	}
}

/// Type alias for iterator results containing key-value pairs
/// Value is optional to support keys-only iteration without allocating empty
/// values
pub type IterResult = Result<(Key, Option<Value>)>;

/// The Key type used throughout the LSM tree
pub type Key = Vec<u8>;

/// The Value type used throughout the LSM tree
pub type Value = Vec<u8>;

/// Type alias for version/timestamp values
pub type Version = u64;

/// Type alias for iterator results containing only keys
pub type KeysResult = Result<Key>;

/// Type alias for iterator results containing keys and values
pub type RangeResult = Result<(Key, Value)>;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum VLogChecksumLevel {
	/// No checksum verification - fastest but no data integrity protection
	#[default]
	Disabled = 0,
	/// Full verification - recalculate checksum of value content
	Full = 1,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum WalRecoveryMode {
	/// Attempt automatic repair of corrupted WAL segments and retry replay.
	#[default]
	TolerateCorruptedWithRepair,

	/// Fail immediately on any WAL corruption (no repair attempted).
	AbsoluteConsistency,
}

/// Priority for I/O operations to support QoS.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum IoPriority {
	/// Foreground operations (User requests, RTC) - High priority.
	#[default]
	Foreground,
	/// Background operations (Compaction, GC) - Low priority.
	Background,
}

tokio::task_local! {
	pub static CURRENT_IO_PRIORITY: IoPriority;
}

/// VLog mmap mode to control how value mappings are handled.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum VLogMmapMode {
	/// If mmap fails, fallback to heap read with a warning.
	#[default]
	Auto,
	/// If mmap fails, return an error.
	Required,
	/// Do not use mmap for VLog reads.
	Disabled,
}

#[derive(Clone)]
pub struct Options {
	pub block_size: usize,
	pub block_restart_interval: usize,
	pub filter_policy: Option<Arc<dyn FilterPolicy>>,
	pub comparator: Arc<dyn Comparator>,
	pub(crate) internal_comparator: Arc<InternalKeyComparator>,
	pub compression_per_level: Vec<CompressionType>,
	pub(crate) block_cache: Arc<cache::BlockCache>,
	pub path: PathBuf,
	pub level_count: u8,
	pub max_memtable_size: usize,
	pub index_partition_size: usize,

	// VLog configuration
	pub vlog_max_file_size: u64,
	pub vlog_checksum_verification: VLogChecksumLevel,
	/// If true, disables `VLog` creation entirely
	pub enable_vlog: bool,
	/// Discard ratio threshold for triggering `VLog` garbage collection (0.0 -
	/// 1.0) Default: 0.5 (50% discardable data triggers GC)
	pub vlog_gc_discard_ratio: f64,
	/// If value size is less than this, it will be stored inline in `SSTable`
	pub vlog_value_threshold: usize,
	/// Controls how mmap is used for VLog reads.
	pub vlog_mmap_mode: VLogMmapMode,

	// Versioned query configuration
	/// If true, enables versioned queries with timestamp tracking
	pub enable_versioning: bool,
	/// History retention period in nanoseconds (0 means no retention limit)
	/// Default: 0 (no retention limit)
	pub versioned_history_retention_ns: u64,
	/// Logical clock for time-based operations
	pub(crate) clock: Arc<dyn LogicalClock>,

	// Shutdown configuration
	/// If true, flush active memtable to SSTable during shutdown.
	/// If false, skip flush for faster shutdown.
	///
	/// DEFAULT: false
	pub flush_on_close: bool,

	// WAL recovery configuration
	/// Controls behavior when WAL corruption is detected during recovery.
	/// Default: TolerateCorruptedWithRepair (attempt repair and continue)
	pub wal_recovery_mode: WalRecoveryMode,

	// --- Chaos & QoS ---
	/// Probability of read failure (0-1000)
	pub chaos_read_prob: u32,
	/// Probability of write failure (0-1000)
	pub chaos_write_prob: u32,
	/// Background I/O limit in bytes/sec (0 = unlimited)
	pub io_bg_limit_bytes: u64,
	/// Foreground I/O limit in bytes/sec (0 = unlimited)
	pub io_fg_limit_bytes: u64,
}

impl Default for Options {
	fn default() -> Self {
		let bf = sstable::bloom::LevelDBBloomFilter::new(10);
		// Initialize the logical clock
		let clock = Arc::new(clock::DefaultLogicalClock::new());

		let comparator: Arc<dyn Comparator> = Arc::new(comparator::BytewiseComparator::default());
		let internal_comparator = Arc::new(InternalKeyComparator::new(Arc::clone(&comparator)));

		Self {
			block_size: 64 * 1024, // 64KB
			block_restart_interval: 16,
			comparator,
			internal_comparator,
			compression_per_level: Vec::new(),
			filter_policy: Some(Arc::new(bf)),
			block_cache: Arc::new(cache::BlockCache::with_capacity_bytes(1 << 20)), // 1MB cache
			path: PathBuf::from(""),
			level_count: 6,
			max_memtable_size: 100 * 1024 * 1024,  // 100 MB
			index_partition_size: 16384,           // 16KB
			vlog_max_file_size: 256 * 1024 * 1024, // 256MB
			vlog_checksum_verification: VLogChecksumLevel::Disabled,
			enable_vlog: false,
			vlog_gc_discard_ratio: 0.5, // 50% default
			vlog_value_threshold: 4096, // 4KB default
			vlog_mmap_mode: VLogMmapMode::Disabled,
			enable_versioning: false,
			versioned_history_retention_ns: 0, // No retention limit by default
			clock,
			flush_on_close: true,
			wal_recovery_mode: WalRecoveryMode::default(),
			// Defaults for Chaos & QoS
			chaos_read_prob: 0,
			chaos_write_prob: 0,
			io_bg_limit_bytes: 0,
			io_fg_limit_bytes: 0,
		}
	}
}

impl Options {
	pub fn new() -> Self {
		Self::default()
	}

	pub const fn with_block_size(mut self, value: usize) -> Self {
		self.block_size = value;
		self
	}

	pub const fn with_block_restart_interval(mut self, value: usize) -> Self {
		self.block_restart_interval = value;
		self
	}

	pub fn with_filter_policy(mut self, value: Option<Arc<dyn FilterPolicy>>) -> Self {
		self.filter_policy = value;
		self
	}

	pub fn with_comparator(mut self, value: Arc<dyn Comparator>) -> Self {
		self.internal_comparator = Arc::new(InternalKeyComparator::new(Arc::clone(&value)));
		self.comparator = value;
		self
	}

	pub fn without_compression(mut self) -> Self {
		self.compression_per_level = Vec::new();
		self
	}

	pub fn with_compression_per_level(mut self, levels: Vec<CompressionType>) -> Self {
		self.compression_per_level = levels;
		self
	}

	pub fn with_l0_no_compression(mut self) -> Self {
		self.compression_per_level =
			vec![CompressionType::None, CompressionType::SnappyCompression];
		self
	}

	pub fn with_l0_no_compression_zstd(mut self) -> Self {
		self.compression_per_level = vec![CompressionType::None, CompressionType::ZstdCompression];
		self
	}

	pub fn with_zstd_compression(mut self) -> Self {
		self.compression_per_level = vec![CompressionType::ZstdCompression];
		self
	}

	pub fn with_path(mut self, value: PathBuf) -> Self {
		self.path = value;
		self
	}

	pub const fn with_level_count(mut self, value: u8) -> Self {
		self.level_count = value;
		self
	}

	pub const fn with_max_memtable_size(mut self, value: usize) -> Self {
		self.max_memtable_size = value;
		self
	}

	pub fn with_block_cache_capacity(mut self, capacity_bytes: u64) -> Self {
		self.block_cache = Arc::new(cache::BlockCache::with_capacity_bytes(capacity_bytes));
		self
	}

	pub const fn with_index_partition_size(mut self, size: usize) -> Self {
		self.index_partition_size = size;
		self
	}

	pub const fn with_vlog_max_file_size(mut self, value: u64) -> Self {
		self.vlog_max_file_size = value;
		self
	}

	pub const fn with_vlog_checksum_verification(mut self, value: VLogChecksumLevel) -> Self {
		self.vlog_checksum_verification = value;
		self
	}

	pub const fn with_enable_vlog(mut self, value: bool) -> Self {
		self.enable_vlog = value;
		self
	}

	pub fn with_vlog_gc_discard_ratio(mut self, value: f64) -> Self {
		assert!((0.0..=1.0).contains(&value), "VLog GC discard ratio must be between 0.0 and 1.0");
		self.vlog_gc_discard_ratio = value;
		self
	}

	pub fn with_versioning(mut self, value: bool, retention_ns: u64) -> Self {
		self.enable_versioning = value;
		self.versioned_history_retention_ns = retention_ns;
		if value {
			self.enable_vlog = true;
			self.vlog_value_threshold = 0;
		}
		self
	}

	pub const fn with_flush_on_close(mut self, value: bool) -> Self {
		self.flush_on_close = value;
		self
	}

	pub const fn with_wal_recovery_mode(mut self, mode: WalRecoveryMode) -> Self {
		self.wal_recovery_mode = mode;
		self
	}

	// --- Chaos & QoS Config ---

	/// Set the probability of read failure (0-1000).
	/// 0 = No failure (default)
	/// 1000 = Always fail
	pub const fn with_chaos_read_prob(mut self, prob: u32) -> Self {
		self.chaos_read_prob = prob;
		self
	}

	/// Set the probability of write failure (0-1000).
	pub const fn with_chaos_write_prob(mut self, prob: u32) -> Self {
		self.chaos_write_prob = prob;
		self
	}

	/// Set the background I/O limit in bytes per second.
	/// 0 = Unlimited (default)
	pub const fn with_io_bg_limit(mut self, limit: u64) -> Self {
		self.io_bg_limit_bytes = limit;
		self
	}

	/// Set the foreground I/O limit in bytes per second.
	/// 0 = Unlimited (default)
	pub const fn with_io_fg_limit(mut self, limit: u64) -> Self {
		self.io_fg_limit_bytes = limit;
		self
	}

	pub(crate) fn manifest_file_path(&self, id: u64) -> PathBuf {
		self.manifest_dir().join(format!("{id:020}.manifest"))
	}

	pub(crate) fn sstable_file_path(&self, id: u64) -> PathBuf {
		self.sstable_dir().join(format!("{id:020}.sst"))
	}

	pub(crate) fn vlog_file_path(&self, id: u64) -> PathBuf {
		self.vlog_dir().join(format!("{id:020}.vlog"))
	}

	pub(crate) fn wal_dir(&self) -> PathBuf {
		self.path.join("wal")
	}

	pub(crate) fn sstable_dir(&self) -> PathBuf {
		self.path.join("sstables")
	}

	pub(crate) fn vlog_dir(&self) -> PathBuf {
		self.path.join("vlog")
	}

	pub(crate) fn manifest_dir(&self) -> PathBuf {
		self.path.join("manifest")
	}

	pub(crate) fn discard_stats_dir(&self) -> PathBuf {
		self.path.join("discard_stats")
	}

	pub(crate) fn delete_list_dir(&self) -> PathBuf {
		self.path.join("delete_list")
	}

	pub(crate) fn versioned_index_dir(&self) -> PathBuf {
		self.path.join("versioned_index")
	}

	pub(crate) fn is_vlog_filename(&self, filename: &str) -> bool {
		filename.len() == 25
			&& std::path::Path::new(filename)
				.extension()
				.is_some_and(|ext| ext.eq_ignore_ascii_case("vlog"))
	}

	pub(crate) fn extract_vlog_file_id(&self, filename: &str) -> Option<u32> {
		if self.is_vlog_filename(filename) {
			if let Some(id_part) = filename.strip_suffix(".vlog") {
				if id_part.len() == 20 && id_part.chars().all(|c| c.is_ascii_digit()) {
					return id_part.parse::<u32>().ok();
				}
			}
		}
		None
	}

	pub fn validate(&self) -> Result<()> {
		// Validate VLog GC discard ratio
		if !(0.0..=1.0).contains(&self.vlog_gc_discard_ratio) {
			return Err(Error::InvalidArgument(
				"VLog GC discard ratio must be between 0.0 and 1.0".to_string(),
			));
		}

		// Validate versioned queries configuration
		if self.enable_versioning {
			// Versioned queries require VLog to be enabled
			if !self.enable_vlog {
				return Err(Error::InvalidArgument(
					"Versioned queries require VLog to be enabled. Set enable_vlog to true."
						.to_string(),
				));
			}

			// Versioned queries don't work well with value threshold (values should go to
			// VLog)
			if self.vlog_value_threshold > 0 {
				return Err(Error::InvalidArgument(
					"Versioned queries require all values to be stored in VLog. Set vlog_value_threshold to 0.".to_string(),
				));
			}
		}

		// Validate level count is reasonable
		if self.level_count == 0 {
			return Err(Error::InvalidArgument("Level count must be at least 1".to_string()));
		}

		Ok(())
	}
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum CompressionType {
	#[default]
	None = 0,
	SnappyCompression = 1,
	ZstdCompression = 2,
}

impl CompressionType {
	pub const fn as_str(&self) -> &'static str {
		match *self {
			Self::None => "none",
			Self::SnappyCompression => "snappy",
			Self::ZstdCompression => "zstd",
		}
	}
}

impl TryFrom<u8> for CompressionType {
	type Error = Error;

	fn try_from(byte: u8) -> Result<Self> {
		match byte {
			0 => Ok(Self::None),
			1 => Ok(Self::SnappyCompression),
			2 => Ok(Self::ZstdCompression),
			_ => Err(Error::Compression(format!("Unknown compression type: {}", byte))),
		}
	}
}

pub trait FilterPolicy: Send + Sync {
	fn name(&self) -> &str;
	fn may_contain(&self, filter: &[u8], key: &[u8]) -> bool;
	fn create_filter(&self, keys: &[Vec<u8>]) -> Vec<u8>;
}

use std::ops::Bound;

/// Type alias for InternalKey range bounds
pub(crate) type InternalKeyRangeBound = Bound<sstable::InternalKey>;
/// Type alias for InternalKey ranges
pub(crate) type InternalKeyRange = (InternalKeyRangeBound, InternalKeyRangeBound);

/// Converts user key bounds to InternalKeyRange for efficient iteration.
pub(crate) fn user_range_to_internal_range(
	lower: Bound<&[u8]>,
	upper: Bound<&[u8]>,
) -> InternalKeyRange {
	use sstable::{
		InternalKey,
		InternalKeyKind,
		INTERNAL_KEY_SEQ_NUM_MAX,
		INTERNAL_KEY_TIMESTAMP_MAX,
	};

	let start_bound = match lower {
		Bound::Unbounded => Bound::Unbounded,
		Bound::Included(key) => Bound::Included(InternalKey::new(
			key.to_vec(),
			INTERNAL_KEY_SEQ_NUM_MAX,
			InternalKeyKind::Max,
			INTERNAL_KEY_TIMESTAMP_MAX,
		)),
		Bound::Excluded(key) => {
			Bound::Excluded(InternalKey::new(key.to_vec(), 0, InternalKeyKind::Set, 0))
		}
	};

	let end_bound = match upper {
		Bound::Unbounded => Bound::Unbounded,
		Bound::Included(key) => {
			Bound::Included(InternalKey::new(key.to_vec(), 0, InternalKeyKind::Set, 0))
		}
		Bound::Excluded(key) => Bound::Excluded(InternalKey::new(
			key.to_vec(),
			INTERNAL_KEY_SEQ_NUM_MAX,
			InternalKeyKind::Max,
			INTERNAL_KEY_TIMESTAMP_MAX,
		)),
	};

	(start_bound, end_bound)
}
