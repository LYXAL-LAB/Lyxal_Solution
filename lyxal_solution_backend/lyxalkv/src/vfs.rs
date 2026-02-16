use std::fs::File as StdFile;
use std::io::{Cursor, Read, Seek, SeekFrom, Write};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::{Arc, Weak};

use std::sync::atomic::{AtomicU32, Ordering};

/// Controller for injecting chaos into VFS operations for deterministic simulation.
#[derive(Debug, Default)]
pub struct ChaosController {
    // Probability of failure (0 to 1000, where 1000 is 100%)
    pub write_failure_prob: AtomicU32,
    pub read_failure_prob: AtomicU32,
    pub sync_failure_prob: AtomicU32,
    // Enable "bit rot" simulation
    #[allow(dead_code)]
    pub bit_rot_prob: AtomicU32,
}

static CHAOS_CONTROLLER: OnceLock<ChaosController> = OnceLock::new();

impl ChaosController {
    pub fn get() -> &'static Self {
        CHAOS_CONTROLLER.get_or_init(Self::default)
    }

    /// Sets the probability of read failures (0-1000).
    #[allow(dead_code)]
    pub fn set_read_failure_prob(&self, prob: u32) {
        self.read_failure_prob.store(prob, Ordering::Relaxed);
    }

    /// Sets the probability of write failures (0-1000).
    #[allow(dead_code)]
    pub fn set_write_failure_prob(&self, prob: u32) {
        self.write_failure_prob.store(prob, Ordering::Relaxed);
    }

    /// Sets the probability of sync failures (0-1000).
    #[allow(dead_code)]
    pub fn set_sync_failure_prob(&self, prob: u32) {
        self.sync_failure_prob.store(prob, Ordering::Relaxed);
    }

    /// Sets the probability of bit rot (0-1000).
    #[allow(dead_code)]
    pub fn set_bit_rot_prob(&self, prob: u32) {
        self.bit_rot_prob.store(prob, Ordering::Relaxed);
    }

    fn should_fail(prob: &AtomicU32) -> bool {
        let p = prob.load(Ordering::Relaxed);
        if p == 0 { return false; }
        // Simple deterministic-ish "random" using a counter or thread-local state could go here.
        // For now, we use a simple fastrand if available or a placeholder.
        fastrand::u32(0..1000) < p
    }
}

/// Wrapper around std::fs::File that enforces I/O QoS and allows chaos injection.
#[derive(Debug)]
pub struct SysFile {
    inner: StdFile,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IoHint {
    Sequential,
    Random,
    SequentialWriteThrough,
    Normal,
}

impl SysFile {
    pub fn new(file: StdFile) -> Self {
        Self { inner: file }
    }

    pub fn open<P: AsRef<Path>>(path: P) -> std::io::Result<Self> {
        Self::open_with_hint(path, IoHint::Normal)
    }

    pub fn open_with_hint<P: AsRef<Path>>(path: P, hint: IoHint) -> std::io::Result<Self> {
        let mut opts = StdFile::options();
        opts.read(true);

        #[cfg(windows)]
        {
            use std::os::windows::fs::OpenOptionsExt;
            match hint {
                IoHint::Sequential => {
                    opts.custom_flags(0x08000000); // FILE_FLAG_SEQUENTIAL_SCAN
                }
                IoHint::Random => {
                    opts.custom_flags(0x10000000); // FILE_FLAG_RANDOM_ACCESS
                }
                IoHint::SequentialWriteThrough => {
                    // FILE_FLAG_SEQUENTIAL_SCAN (0x08000000) | FILE_FLAG_WRITE_THROUGH (0x80000000)
                    opts.custom_flags(0x08000000 | 0x80000000);
                }
                IoHint::Normal => {}
            }
        }

        let path = path.as_ref();
        let mut attempts = 0;
        loop {
            match opts.open(path) {
                Ok(f) => return Ok(Self::new(f)),
                Err(e) if attempts < 10 && e.kind() == std::io::ErrorKind::PermissionDenied => {
                    attempts += 1;
                    std::thread::sleep(std::time::Duration::from_millis(10 * attempts));
                }
                Err(e) => return Err(e),
            }
        }
    }

    pub fn create<P: AsRef<Path>>(path: P) -> std::io::Result<Self> {
        let path = path.as_ref();
        let mut attempts = 0;
        loop {
            match StdFile::create(path) {
                Ok(f) => return Ok(Self::new(f)),
                Err(e) if attempts < 10 && e.kind() == std::io::ErrorKind::PermissionDenied => {
                    attempts += 1;
                    std::thread::sleep(std::time::Duration::from_millis(10 * attempts));
                }
                Err(e) => return Err(e),
            }
        }
    }

    pub fn options() -> std::fs::OpenOptions {
        std::fs::OpenOptions::new()
    }

    pub fn options_with_hint(hint: IoHint) -> std::fs::OpenOptions {
        let mut opts = std::fs::OpenOptions::new();
        #[cfg(windows)]
        {
            use std::os::windows::fs::OpenOptionsExt;
            match hint {
                IoHint::Sequential => {
                    opts.custom_flags(0x08000000); // FILE_FLAG_SEQUENTIAL_SCAN
                }
                IoHint::Random => {
                    opts.custom_flags(0x10000000); // FILE_FLAG_RANDOM_ACCESS
                }
                IoHint::SequentialWriteThrough => {
                    // FILE_FLAG_SEQUENTIAL_SCAN (0x08000000) | FILE_FLAG_WRITE_THROUGH (0x80000000)
                    opts.custom_flags(0x08000000 | 0x80000000);
                }
                IoHint::Normal => {}
            }
        }
        opts
    }

    pub fn try_lock_exclusive(&self) -> std::io::Result<()> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            self.inner.try_lock_exclusive()
        }
        #[cfg(target_arch = "wasm32")]
        Ok(())
    }

    pub fn unlock(&self) -> std::io::Result<()> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            self.inner.unlock()
        }
        #[cfg(target_arch = "wasm32")]
        Ok(())
    }

    pub fn sync_all(&self) -> std::io::Result<()> {
        if ChaosController::should_fail(&ChaosController::get().sync_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected sync_all failure"));
        }
        self.inner.sync_all()
    }

    pub fn sync_data(&self) -> std::io::Result<()> {
        if ChaosController::should_fail(&ChaosController::get().sync_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected sync_data failure"));
        }
        self.inner.sync_data()
    }

    pub fn metadata(&self) -> std::io::Result<std::fs::Metadata> {
        self.inner.metadata()
    }

    pub fn set_len(&self, size: u64) -> std::io::Result<()> {
        self.inner.set_len(size)
    }

    pub fn inner(&self) -> &StdFile {
        &self.inner
    }
}

impl Read for SysFile {
    fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().read_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected read failure"));
        }
        IoScheduler::get().request_io(buf.len());
        std::io::Read::read(&mut self.inner, buf)
    }
}

impl Write for SysFile {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().write_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected write failure"));
        }
        IoScheduler::get().request_io(buf.len());
        std::io::Write::write(&mut self.inner, buf)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        if ChaosController::should_fail(&ChaosController::get().sync_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected sync failure"));
        }
        std::io::Write::flush(&mut self.inner)
    }
}

impl Seek for SysFile {
    fn seek(&mut self, pos: SeekFrom) -> std::io::Result<u64> {
        std::io::Seek::seek(&mut self.inner, pos)
    }
}

#[cfg(unix)]
impl std::os::unix::prelude::FileExt for SysFile {
    fn read_at(&self, buf: &mut [u8], offset: u64) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().read_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected read_at failure"));
        }
        IoScheduler::get().request_io(buf.len());
        self.inner.read_at(buf, offset)
    }

    fn write_at(&self, buf: &[u8], offset: u64) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().write_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected write_at failure"));
        }
        IoScheduler::get().request_io(buf.len());
        self.inner.write_at(buf, offset)
    }
}

#[cfg(windows)]
impl std::os::windows::prelude::FileExt for SysFile {
    fn seek_read(&self, buf: &mut [u8], offset: u64) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().read_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected seek_read failure"));
        }
        IoScheduler::get().request_io(buf.len());
        self.inner.seek_read(buf, offset)
    }

    fn seek_write(&self, buf: &[u8], offset: u64) -> std::io::Result<usize> {
        if ChaosController::should_fail(&ChaosController::get().write_failure_prob) {
            return Err(std::io::Error::new(std::io::ErrorKind::Other, "Chaos VFS: injected seek_write failure"));
        }
        IoScheduler::get().request_io(buf.len());
        self.inner.seek_write(buf, offset)
    }
}

use memmap2::Mmap;
use parking_lot::Mutex;

#[cfg(not(target_arch = "wasm32"))]
use fs2::FileExt as LockFileExt;

use crate::data::MmapHandle;
use crate::error::{Error, Result};

use std::sync::OnceLock;

/// Global registry of active memory mappings to support deferred deletion.
static MMAP_REGISTRY: OnceLock<Mutex<HashMap<PathBuf, Weak<MmapHandle>>>> = OnceLock::new();

/// Global I/O scheduler to manage QoS priorities.
static IO_SCHEDULER: OnceLock<IoScheduler> = OnceLock::new();

/// Simple token bucket rate limiter for I/O QoS.
struct TokenBucket {
	tokens: f64,
	max_tokens: f64,
	refill_rate: f64,
	last_refill: std::time::Instant,
}

impl TokenBucket {
	fn new(max_tokens: f64, refill_rate: f64) -> Self {
		Self {
			tokens: max_tokens,
			max_tokens,
			refill_rate,
			last_refill: std::time::Instant::now(),
		}
	}

	fn consume(&mut self, amount: f64) -> std::time::Duration {
		let now = std::time::Instant::now();
		let elapsed = now.duration_since(self.last_refill).as_secs_f64();
		self.tokens = (self.tokens + elapsed * self.refill_rate).min(self.max_tokens);
		self.last_refill = now;

		if self.tokens >= amount {
			self.tokens -= amount;
			std::time::Duration::ZERO
		} else {
			let deficit = amount - self.tokens;
			let wait_time = deficit / self.refill_rate;
			self.tokens = 0.0;
			std::time::Duration::from_secs_f64(wait_time)
		}
	}
}

pub struct IoScheduler {
	background_limiter: Mutex<TokenBucket>,
	foreground_limiter: Mutex<TokenBucket>,
}

impl IoScheduler {
	pub fn get() -> &'static Self {
		IO_SCHEDULER.get_or_init(|| {
			// Default: 10MB/s for background I/O, with 2MB burst
			// Default: Unlimited (1GB/s) for foreground I/O
			IoScheduler {
				background_limiter: Mutex::new(TokenBucket::new(2.0 * 1024.0 * 1024.0, 10.0 * 1024.0 * 1024.0)),
				foreground_limiter: Mutex::new(TokenBucket::new(100.0 * 1024.0 * 1024.0, 1024.0 * 1024.0 * 1024.0)),
			}
		})
	}

	/// Updates the I/O quota for background operations (Compaction, GC).
	#[allow(dead_code)]
	pub fn set_background_limit(&self, rate_bytes_per_sec: f64, burst_bytes: f64) {
		let mut limiter = self.background_limiter.lock();
		limiter.refill_rate = rate_bytes_per_sec;
		limiter.max_tokens = burst_bytes;
		limiter.tokens = limiter.tokens.min(burst_bytes);
	}

	/// Updates the I/O quota for foreground operations (User requests).
	#[allow(dead_code)]
	pub fn set_foreground_limit(&self, rate_bytes_per_sec: f64, burst_bytes: f64) {
		let mut limiter = self.foreground_limiter.lock();
		limiter.refill_rate = rate_bytes_per_sec;
		limiter.max_tokens = burst_bytes;
		limiter.tokens = limiter.tokens.min(burst_bytes);
	}

	pub fn request_io(&self, amount: usize) {
		let priority = crate::CURRENT_IO_PRIORITY.try_with(|&p| p).unwrap_or_default();

		let wait_time = match priority {
			crate::IoPriority::Background => {
				self.background_limiter.lock().consume(amount as f64)
			}
			crate::IoPriority::Foreground => {
				self.foreground_limiter.lock().consume(amount as f64)
			}
		};

		if !wait_time.is_zero() {
			// Use blocking sleep since VFS operations are sync
			std::thread::sleep(wait_time);
		}
	}
}

pub fn log_debug(msg: &str) {
	log::debug!("{}", msg);
}


fn with_registry<F, R>(f: F) -> R
where
	F: FnOnce(&mut HashMap<PathBuf, Weak<MmapHandle>>) -> R,
{
	let registry = MMAP_REGISTRY.get_or_init(|| Mutex::new(HashMap::new()));
	let mut registry = registry.lock();
	f(&mut *registry)
}

pub trait File: Send + Sync {
	#[allow(unused)]
	fn write(&mut self, buf: &[u8]) -> Result<usize>;
	#[allow(unused)]
	fn flush(&mut self) -> Result<()>;
	#[allow(unused)]
	fn close(&mut self) -> Result<()>;
	#[allow(unused)]
	fn seek(&mut self, pos: SeekFrom) -> Result<u64>;
	#[allow(unused)]
	fn read(&mut self, buf: &mut [u8]) -> Result<usize>;
	#[allow(unused)]
	fn read_all(&mut self, buf: &mut Vec<u8>) -> Result<usize>;
	#[allow(unused)]
	fn lock(&self) -> Result<()>;
	#[allow(unused)]
	fn unlock(&self) -> Result<()>;
	fn read_at(&self, offset: u64, buf: &mut [u8]) -> Result<usize>;
	#[allow(unused)]
	fn write_at(&mut self, offset: u64, buf: &[u8]) -> Result<usize>;
	#[allow(unused)]
	fn sync(&self) -> Result<()>;
	#[allow(unused)]
	fn sync_data(&self) -> Result<()>;
	fn size(&self) -> Result<u64>;
	/// Map the file into memory for zero-copy access.
	fn map_read(&self, path: Option<std::path::PathBuf>) -> Result<Arc<MmapHandle>>;
}

/// Safely removes a file, handling deferred deletion if it's currently mapped.
	pub fn remove_file<P: AsRef<Path>>(path: P) -> Result<()> {
		let path = path.as_ref();
		let abs_path = path.canonicalize().unwrap_or_else(|_| path.to_path_buf());
		let abs_path = normalize_path(abs_path);

		let handle = with_registry(|registry| {
			registry.retain(|_, v| v.strong_count() > 0);

			if let Some(weak_handle) = registry.get(&abs_path) {
				weak_handle.upgrade()
			} else {
				None
			}
		});

		if let Some(handle) = handle {
			handle.tombstone();
			Ok(())
		} else {
			std::fs::remove_file(path).map_err(|e| {
				Error::Io(e.into())
			})
		}
	}

	fn normalize_path(path: PathBuf) -> PathBuf {
		let s = path.to_string_lossy();
		let s = if s.starts_with(r"\\?\") {
			&s[4..]
		} else {
			&s
		};
		// Windows is case-insensitive, normalize to lowercase for registry hits
		PathBuf::from(s.to_lowercase())
	}

pub type InMemoryFile = Vec<u8>;

impl File for InMemoryFile {
	fn write(&mut self, buf: &[u8]) -> Result<usize> {
		self.extend_from_slice(buf);
		Ok(buf.len())
	}

	fn flush(&mut self) -> Result<()> {
		Ok(()) // In-memory file doesn't need flushing
	}

	fn close(&mut self) -> Result<()> {
		Ok(()) // No specific action needed for closing an in-memory file
	}

	fn seek(&mut self, pos: SeekFrom) -> Result<u64> {
		let mut cursor = Cursor::new(self);
		cursor.seek(pos).map_err(|e| Error::Io(e.into()))?;
		Ok(cursor.position())
	}

	fn read(&mut self, buf: &mut [u8]) -> Result<usize> {
		let mut cursor = Cursor::new(self);
		cursor.read(buf).map_err(|e| Error::Io(e.into()))
	}

	fn read_all(&mut self, buf: &mut Vec<u8>) -> Result<usize> {
		buf.clear();
		buf.extend_from_slice(self);
		Ok(self.len())
	}

	fn lock(&self) -> Result<()> {
		Ok(()) // In-memory file doesn't support locking
	}

	fn unlock(&self) -> Result<()> {
		Ok(()) // In-memory file doesn't support unlocking
	}

	fn read_at(&self, offset: u64, buf: &mut [u8]) -> Result<usize> {
		let start = offset as usize;
		let end = std::cmp::min(start + buf.len(), self.len());
		let bytes_read = end - start;
		buf[..bytes_read].copy_from_slice(&self[start..end]);
		Ok(bytes_read)
	}

	fn write_at(&mut self, offset: u64, buf: &[u8]) -> Result<usize> {
		let start = offset as usize;
		let end = start + buf.len();

		// Ensure the vector is large enough
		if end > self.len() {
			self.resize(end, 0);
		}

		// Write the data
		self[start..end].copy_from_slice(buf);
		Ok(buf.len())
	}

	fn sync(&self) -> Result<()> {
		Ok(()) // In-memory file doesn't need syncing
	}

	fn sync_data(&self) -> Result<()> {
		Ok(()) // In-memory file doesn't need syncing
	}

	fn size(&self) -> Result<u64> {
		Ok(self.len() as u64)
	}

	fn map_read(&self, _path: Option<std::path::PathBuf>) -> Result<Arc<MmapHandle>> {
		Err(Error::Io(
			std::io::Error::new(
				std::io::ErrorKind::Unsupported,
				"InMemoryFile does not support memory mapping",
			)
			.into(),
		))
	}
}

impl File for SysFile {
	fn write(&mut self, buf: &[u8]) -> Result<usize> {
		Write::write(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn flush(&mut self) -> Result<()> {
		Write::flush(self).map_err(|e| Error::Io(e.into()))
	}

	fn close(&mut self) -> Result<()> {
		Ok(())
	}

	fn seek(&mut self, pos: SeekFrom) -> Result<u64> {
		Seek::seek(self, pos).map_err(|e| Error::Io(e.into()))
	}

	fn read(&mut self, buf: &mut [u8]) -> Result<usize> {
		std::io::Read::read(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn read_all(&mut self, buf: &mut Vec<u8>) -> Result<usize> {
		std::io::Read::read_to_end(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn lock(&self) -> Result<()> {
		#[cfg(not(target_arch = "wasm32"))]
		{
			SysFile::try_lock_exclusive(self).map_err(|e| Error::Io(e.into()))
		}
		#[cfg(target_arch = "wasm32")]
		{
			// File locking is not supported on WASM
			Ok(())
		}
	}

	fn unlock(&self) -> Result<()> {
		#[cfg(not(target_arch = "wasm32"))]
		{
			SysFile::unlock(self).map_err(|e| Error::Io(e.into()))
		}
		#[cfg(target_arch = "wasm32")]
		{
			// File unlocking is not supported on WASM
			Ok(())
		}
	}

	fn read_at(&self, offset: u64, buf: &mut [u8]) -> Result<usize> {
		if ChaosController::should_fail(&ChaosController::get().read_failure_prob) {
			return Err(Error::Io(std::io::Error::new(
				std::io::ErrorKind::Other,
				"Chaos VFS: injected read_at failure",
			).into()));
		}
		#[cfg(unix)]
		{
			std::os::unix::prelude::FileExt::read_at(self, buf, offset)
				.map_err(|e| Error::Io(e.into()))
		}

		#[cfg(windows)]
		{
			use std::os::windows::fs::FileExt;
			let mut total = 0;
			while total < buf.len() {
				match self.seek_read(&mut buf[total..], offset + total as u64) {
					Ok(0) => break,
					Ok(n) => total += n,
					Err(e) if e.kind() == std::io::ErrorKind::Interrupted => continue,
					Err(e) => return Err(Error::Io(e.into())),
				}
			}
			Ok(total)
		}

		#[cfg(target_arch = "wasm32")]
		{
			// read_at is not supported on WASM, return an error
			Err(Error::Io(
				std::io::Error::new(
					std::io::ErrorKind::Unsupported,
					"read_at is not supported on WASM",
				)
				.into(),
			))
		}
	}

	fn write_at(&mut self, offset: u64, buf: &[u8]) -> Result<usize> {
		if ChaosController::should_fail(&ChaosController::get().write_failure_prob) {
			return Err(Error::Io(std::io::Error::new(
				std::io::ErrorKind::Other,
				"Chaos VFS: injected write_at failure",
			).into()));
		}
		#[cfg(unix)]
		{
			std::os::unix::prelude::FileExt::write_all_at(self, buf, offset)
				.map_err(|e| Error::Io(e.into()))?;
			Ok(buf.len())
		}

		#[cfg(windows)]
		{
			use std::os::windows::fs::FileExt;
			let mut total = 0;
			while total < buf.len() {
				match self.seek_write(&buf[total..], offset + total as u64) {
					Ok(0) => {
						return Err(Error::Io(std::io::Error::new(
							std::io::ErrorKind::WriteZero,
							"failed to write whole buffer",
						).into()))
					}
					Ok(n) => total += n,
					Err(e) if e.kind() == std::io::ErrorKind::Interrupted => continue,
					Err(e) => return Err(Error::Io(e.into())),
				}
			}
			Ok(total)
		}

		#[cfg(target_arch = "wasm32")]
		{
			// write_at is not supported on WASM, return an error
			Err(Error::Io(
				std::io::Error::new(
					std::io::ErrorKind::Unsupported,
					"write_at is not supported on WASM",
				)
				.into(),
			))
		}
	}

	fn sync(&self) -> Result<()> {
		let start = std::time::Instant::now();
		let res = SysFile::sync_all(self).map_err(|e| Error::Io(e.into()));
		crate::metrics::EngineMetrics::get().sync_nanos.fetch_add(start.elapsed().as_nanos() as u64, std::sync::atomic::Ordering::Relaxed);
		res
	}

	fn sync_data(&self) -> Result<()> {
		let start = std::time::Instant::now();
		let res = SysFile::sync_data(self).map_err(|e| Error::Io(e.into()));
		crate::metrics::EngineMetrics::get().sync_nanos.fetch_add(start.elapsed().as_nanos() as u64, std::sync::atomic::Ordering::Relaxed);
		res
	}

	fn size(&self) -> Result<u64> {
		match SysFile::metadata(self) {
			Ok(v) => Ok(v.len()),
			Err(e) => Err(Error::Io(e.into())),
		}
	}

	fn map_read(&self, path: Option<std::path::PathBuf>) -> Result<Arc<MmapHandle>> {
		let abs_path = path.as_ref().map(|p| p.canonicalize().unwrap_or_else(|_| p.to_path_buf()));
		let abs_path = abs_path.map(normalize_path);

		with_registry(|registry| {
			// Check if we already have a mapping for this file
			if let Some(abs_path) = &abs_path {
				if let Some(weak) = registry.get(abs_path) {
					if let Some(handle) = weak.upgrade() {
						return Ok(handle);
					}
				}
			}

			// Create new mapping
			// SAFETY: We checked file path validity and mapping logic
			let mmap = unsafe { Mmap::map(&self.inner).map_err(|e| Error::Io(e.into()))? };
			let handle = Arc::new(MmapHandle::new(mmap, abs_path.clone()));

			// Register it
			if let Some(abs_path) = abs_path {
				registry.insert(abs_path, Arc::downgrade(&handle));
			}

			Ok(handle)
		})
	}
}

impl File for StdFile {
	fn write(&mut self, buf: &[u8]) -> Result<usize> {
		IoScheduler::get().request_io(buf.len());
		Write::write(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn flush(&mut self) -> Result<()> {
		Write::flush(self).map_err(|e| Error::Io(e.into()))
	}

	fn close(&mut self) -> Result<()> {
		Ok(())
	}

	fn seek(&mut self, pos: SeekFrom) -> Result<u64> {
		Seek::seek(self, pos).map_err(|e| Error::Io(e.into()))
	}

	fn read(&mut self, buf: &mut [u8]) -> Result<usize> {
		IoScheduler::get().request_io(buf.len());
		std::io::Read::read(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn read_all(&mut self, buf: &mut Vec<u8>) -> Result<usize> {
		std::io::Read::read_to_end(self, buf).map_err(|e| Error::Io(e.into()))
	}

	fn lock(&self) -> Result<()> {
		#[cfg(not(target_arch = "wasm32"))]
		{
			LockFileExt::try_lock_exclusive(self).map_err(|e| Error::Io(e.into()))
		}
		#[cfg(target_arch = "wasm32")]
		{
			Ok(())
		}
	}

	fn unlock(&self) -> Result<()> {
		#[cfg(not(target_arch = "wasm32"))]
		{
			LockFileExt::unlock(self).map_err(|e| Error::Io(e.into()))
		}
		#[cfg(target_arch = "wasm32")]
		{
			Ok(())
		}
	}

	fn read_at(&self, offset: u64, buf: &mut [u8]) -> Result<usize> {
		IoScheduler::get().request_io(buf.len());
		#[cfg(unix)]
		{
			std::os::unix::prelude::FileExt::read_at(self, buf, offset)
				.map_err(|e| Error::Io(e.into()))
		}

		#[cfg(windows)]
		{
			use std::os::windows::fs::FileExt;
			let mut total = 0;
			while total < buf.len() {
				match self.seek_read(&mut buf[total..], offset + total as u64) {
					Ok(0) => break,
					Ok(n) => total += n,
					Err(e) if e.kind() == std::io::ErrorKind::Interrupted => continue,
					Err(e) => return Err(Error::Io(e.into())),
				}
			}
			Ok(total)
		}

		#[cfg(target_arch = "wasm32")]
		{
			Err(Error::Io(
				std::io::Error::new(
					std::io::ErrorKind::Unsupported,
					"read_at is not supported on WASM",
				)
				.into(),
			))
		}
	}

	fn write_at(&mut self, offset: u64, buf: &[u8]) -> Result<usize> {
		IoScheduler::get().request_io(buf.len());
		#[cfg(unix)]
		{
			std::os::unix::prelude::FileExt::write_all_at(self, buf, offset)
				.map_err(|e| Error::Io(e.into()))?;
			Ok(buf.len())
		}

		#[cfg(windows)]
		{
			use std::os::windows::fs::FileExt;
			let mut total = 0;
			while total < buf.len() {
				match self.seek_write(&buf[total..], offset + total as u64) {
					Ok(0) => {
						return Err(Error::Io(std::io::Error::new(
							std::io::ErrorKind::WriteZero,
							"failed to write whole buffer",
						).into()))
					}
					Ok(n) => total += n,
					Err(e) if e.kind() == std::io::ErrorKind::Interrupted => continue,
					Err(e) => return Err(Error::Io(e.into())),
				}
			}
			Ok(total)
		}

		#[cfg(target_arch = "wasm32")]
		{
			Err(Error::Io(
				std::io::Error::new(
					std::io::ErrorKind::Unsupported,
					"write_at is not supported on WASM",
				)
				.into(),
			))
		}
	}

	fn sync(&self) -> Result<()> {
		self.sync_all().map_err(|e| Error::Io(e.into()))
	}

	fn sync_data(&self) -> Result<()> {
		self.sync_data().map_err(|e| Error::Io(e.into()))
	}

	fn size(&self) -> Result<u64> {
		match self.metadata() {
			Ok(v) => Ok(v.len()),
			Err(e) => Err(Error::Io(e.into())),
		}
	}

	fn map_read(&self, path: Option<std::path::PathBuf>) -> Result<Arc<MmapHandle>> {
		let abs_path = path.as_ref().map(|p| p.canonicalize().unwrap_or_else(|_| p.to_path_buf()));
		let abs_path = abs_path.map(normalize_path);

		with_registry(|registry| {
			// Check if we already have a mapping for this file
			if let Some(abs_path) = &abs_path {
				if let Some(weak) = registry.get(abs_path) {
					if let Some(handle) = weak.upgrade() {
						return Ok(handle);
					}
				}
			}

			// Create new mapping
			// SAFETY: We checked file path validity and mapping logic
			let mmap = unsafe { Mmap::map(self).map_err(|e| Error::Io(e.into()))? };
			let handle = Arc::new(MmapHandle::new(mmap, abs_path.clone()));

			// Register it
			if let Some(abs_path) = abs_path {
				registry.insert(abs_path, Arc::downgrade(&handle));
			}

			Ok(handle)
		})
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use std::sync::{Arc, Barrier};
	use tempfile::TempDir;

	#[test]
	fn test_concurrent_read_at() {
		let temp_dir = TempDir::new().unwrap();
		let path = temp_dir.path().join("stress_test.dat");

		// Create a file with some predictable data
		let mut file = std::fs::File::create(&path).unwrap();
		let chunk_size = 1024 * 4; // 4 KB chunks
		let num_chunks = 200;
		for i in 0..num_chunks {
			let data = vec![(i % 256) as u8; chunk_size];
			std::io::Write::write_all(&mut file, &data).unwrap();
		}
		std::io::Write::flush(&mut file).unwrap();
		drop(file);

		// Re-open for reading
		let file = Arc::new(std::fs::File::open(&path).unwrap());
		let threads = 50;
		let barrier = Arc::new(Barrier::new(threads));
		let mut handles = vec![];

		for _ in 0..threads {
			let f = Arc::clone(&file);
			let b = Arc::clone(&barrier);
			handles.push(std::thread::spawn(move || {
				b.wait();
				for _ in 0..500 {
					let chunk_idx = fastrand::usize(..num_chunks);
					let offset = (chunk_idx * chunk_size) as u64;
					let mut buf = vec![0u8; chunk_size];
					let read = f.read_at(offset, &mut buf).unwrap();
					assert_eq!(read, chunk_size, "Read size mismatch at offset {}", offset);
					let expected_byte = (chunk_idx % 256) as u8;
					for (i, &byte) in buf.iter().enumerate() {
						if byte != expected_byte {
							panic!("Data corruption! Expected {} at offset {} + {}, got {}", expected_byte, offset, i, byte);
						}
					}
				}
			}));
		}

		for h in handles {
			h.join().unwrap();
		}
	}
}
