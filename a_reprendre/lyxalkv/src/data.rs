use bytes::Bytes;
use memmap2::Mmap;
use std::ops::Deref;
use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

/// MmapHandle wraps a memory mapping and its associated file path.
/// It supports deferred deletion (deferred delete) when the file is "tombstoned".
#[derive(Debug)]
pub struct MmapHandle {
	mmap: Option<Mmap>,
	path: Option<PathBuf>,
	tombstoned: AtomicBool,

}

impl MmapHandle {
	pub fn new(mmap: Mmap, path: Option<PathBuf>) -> Self {
		Self {
			mmap: Some(mmap),
			path,
			tombstoned: AtomicBool::new(false),
		}

	}

	/// Mark the file as tombstoned. It will be deleted when the handle is dropped.
	pub fn tombstone(&self) {
		self.tombstoned.store(true, Ordering::SeqCst);
	}

	pub fn as_slice(&self) -> &[u8] {
		self.mmap.as_ref().unwrap()

	}
}

impl Deref for MmapHandle {
	type Target = [u8];

	fn deref(&self) -> &Self::Target {
		self.as_slice()
	}
}

impl Drop for MmapHandle {
	fn drop(&mut self) {
		// Explicitly drop the mmap BEFORE checking for tombstone/deletion.
		// On Windows, the file cannot be deleted if it is mapped.
		// Taking the Option drops the Mmap.
		let _ = self.mmap.take();

		if self.tombstoned.load(Ordering::SeqCst) {
			if let Some(path) = &self.path {
                // Give OS a moment to release the mapping handle
                std::thread::sleep(std::time::Duration::from_millis(10));

				// Attempt to delete the file. Failures are logged/ignored as it might
				// be already deleted or held by another process.
				if let Err(_) = std::fs::remove_file(path) {
                    // Ignored
                }
			}
		}
	}
}

/// DataOwner defines the backend storage for a DataRef.
/// This ensures that the underlying memory (mmap or heap) stays alive
/// as long as the DataRef is in use.
#[derive(Debug, Clone)]
pub enum DataOwner {
	/// Heap-allocated data using the bytes crate for efficient cloning.
	Heap(Bytes),
	/// Memory-mapped data from a file, managed with lifecycle awareness.
	Mmap(Arc<MmapHandle>),
}

/// DataRef is a safe, zero-copy handle to a range of bytes.
/// It MUST carry its owner to prevent use-after-free/unmap.
#[derive(Debug, Clone)]
pub struct DataRef {
	owner: DataOwner,
	offset: usize,
	length: usize,
}

impl DataRef {
	/// Create a new DataRef from a heap-allocated Bytes object.
	pub fn from_heap(bytes: Bytes) -> Self {
		let length = bytes.len();
		Self {
			owner: DataOwner::Heap(bytes),
			offset: 0,
			length,
		}
	}

	/// Create a new DataRef from a managed MmapHandle.
	pub fn from_mmap(handle: Arc<MmapHandle>, offset: usize, length: usize) -> Self {
		Self {
			owner: DataOwner::Mmap(handle),
			offset,
			length,
		}
	}

	/// Access the underlying data as a byte slice.
	pub fn as_slice(&self) -> &[u8] {
		match &self.owner {
			DataOwner::Heap(bytes) => &bytes[self.offset..self.offset + self.length],
			DataOwner::Mmap(handle) => &handle.mmap.as_ref().unwrap()[self.offset..self.offset + self.length],

		}
	}

	/// Create a sub-slice of the current DataRef.
	pub fn slice(&self, offset: usize, length: usize) -> Self {
		assert!(offset + length <= self.length, "DataRef sub-slice out of bounds");
		Self {
			owner: self.owner.clone(),
			offset: self.offset + offset,
			length,
		}
	}

	#[cfg(test)]
	pub fn owner_mmap(&self) -> Arc<MmapHandle> {
		match &self.owner {
			DataOwner::Mmap(handle) => Arc::clone(handle),
			_ => panic!("DataRef is not mmap-backed"),
		}
	}

	/// Length of the data.
	pub fn len(&self) -> usize {
		self.length
	}

	/// Whether the data is empty.
	pub fn is_empty(&self) -> bool {
		self.length == 0
	}

	/// Returns true if the data is backed by a memory mapping.
	pub fn is_mmap(&self) -> bool {
		matches!(self.owner, DataOwner::Mmap(_))
	}
}

impl Deref for DataRef {
	type Target = [u8];

	fn deref(&self) -> &Self::Target {
		self.as_slice()
	}
}

impl AsRef<[u8]> for DataRef {
	fn as_ref(&self) -> &[u8] {
		self.as_slice()
	}
}
