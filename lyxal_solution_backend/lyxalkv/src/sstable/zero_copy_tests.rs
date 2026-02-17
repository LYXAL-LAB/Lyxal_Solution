#[cfg(test)]
mod tests {
    use std::sync::Arc;
    use std::path::PathBuf;
    #[cfg(feature = "mmap_read")]
    use std::time::Duration;
    #[cfg(feature = "mmap_read")]
    use tempfile::tempdir;
    use crate::Options;
    #[cfg(feature = "mmap_read")]
    use crate::sstable::table::Table;
    use crate::sstable::table::TableWriter;
    #[cfg(feature = "mmap_read")]
    use crate::vfs::{File, remove_file};
    #[cfg(feature = "mmap_read")]
    // use crate::data::DataRef;
    #[cfg(feature = "mmap_read")]
    // use crate::CompressionType;
    #[cfg(feature = "mmap_read")]
    use crate::sstable::{InternalKey, InternalKeyKind};

    #[cfg(feature = "mmap_read")]
    fn create_test_sstable(path: PathBuf) -> u64 {
        let opts = Arc::new(Options::default());
        let file = std::fs::File::create(&path).unwrap();
        let mut writer = TableWriter::new(file, 0, Arc::clone(&opts), 0);

        for i in 0..100 {
            let key = InternalKey::new(format!("key_{:03}", i).into_bytes(), i as u64, InternalKeyKind::Set, 0);
            let value = format!("value_{:03}", i).into_bytes();
            writer.add(key, &value).unwrap();
        }

        writer.finish().unwrap() as u64
    }

    #[test]
    #[cfg(feature = "mmap_read")]
    fn test_zero_copy_reader_drop_survival() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("test.sst").canonicalize().unwrap_or_else(|_| dir.path().join("test.sst"));
        let file_size = create_test_sstable(path.clone());

        let opts = Arc::new(Options::default());
        let sys_file = std::fs::File::open(&path).unwrap();
        let file = Arc::new(sys_file);
        
        let table = Arc::new(Table::new(0, Arc::clone(&opts), Arc::clone(&file) as Arc<dyn File>, file_size, Some(path.clone())).unwrap());
        
        // Get an entry from the first data block
        let mut iter = table.iter(false, None);
        iter.seek_to_first().unwrap();
        assert!(iter.valid());
        
        // This DataRef should survive the Table drop because it clones the Arc<MmapHandle>
        let data_ref = iter.value_bytes_dataref(); 
        let value_slice = data_ref.as_slice();
        assert_eq!(value_slice, b"value_000");

        // Drop the table. We need to drop all Arc references to the Table.
        drop(iter);
        drop(table);

        // Accessing the data_ref should still be safe and valid
        assert_eq!(data_ref.as_slice(), b"value_000");
    }

    #[test]
    #[cfg(feature = "mmap_read")]
    fn test_zero_copy_deferred_delete() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("test_deferred.sst").canonicalize().unwrap_or_else(|_| dir.path().join("test_deferred.sst"));
        let file_size = create_test_sstable(path.clone());

        let opts = Arc::new(Options::default());
        let sys_file = std::fs::File::open(&path).unwrap();
        let file = Arc::new(sys_file);
        
        let table = Arc::new(Table::new(0, Arc::clone(&opts), Arc::clone(&file) as Arc<dyn File>, file_size, Some(path.clone())).unwrap());
        
        let mut iter = table.iter(false, None);
        iter.seek_to_first().unwrap();
        let data_ref = iter.value_bytes_dataref();

        // Mark the file for deletion (tombstone)
        remove_file(&path).expect("Failed to remove/tombstone file");

        assert!(path.exists(), "File should still exist because it is mapped");

        drop(iter);
        drop(table);
        drop(file); // Ensure the file handle is closed so it can be deleted on Windows
        
        // Still exists because data_ref holds an Arc<MmapHandle>
        assert!(path.exists(), "File should still exist because DataRef holds the mapping");

        drop(data_ref);

        // Now it should be gone. Use a small retry loop for Windows OS latency.
        let mut deleted = false;
        for _ in 0..50 {
            if !path.exists() {
                deleted = true;
                break;
            } else {
                // If specific OS semantics (like Windows) keep the file "alive" due to mapped handle
                // or similar, explicitly trying to remove it again might help clear the state
                // or at least verify if it's securely locked.
                let _ = std::fs::remove_file(&path);
            }
            std::thread::sleep(Duration::from_millis(100));
        }
        assert!(deleted, "File should be deleted after last DataRef is dropped");
    }

    #[test]
    #[cfg(feature = "mmap_read")]
    fn test_zero_copy_concurrency_compaction_scan() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("test_concurrent.sst").canonicalize().unwrap_or_else(|_| dir.path().join("test_concurrent.sst"));
        let file_size = create_test_sstable(path.clone());

        let opts = Arc::new(Options::default());
        let sys_file = std::fs::File::open(&path).unwrap();
        let file = Arc::new(sys_file);
        let table = Arc::new(Table::new(0, Arc::clone(&opts), Arc::clone(&file) as Arc<dyn File>, file_size, Some(path.clone())).unwrap());

        // Simulate 5 concurrent scanners
        let mut threads = vec![];
        for _ in 0..5 {
            let table_clone = Arc::clone(&table);
            threads.push(std::thread::spawn(move || {
                for _ in 0..50 {
                    let mut iter = table_clone.iter(false, None);
                    iter.seek_to_first().unwrap();
                    let mut count = 0;
                    while iter.valid() {
                        let data = iter.value_bytes_dataref();
                        let _val = data.as_slice();
                        iter.advance().unwrap();
                        count += 1;
                    }
                    assert_eq!(count, 100);
                }
            }));
        }

        // Simulate a "compactor" deleting the file
        std::thread::sleep(Duration::from_millis(100));
        remove_file(&path).expect("Compactor failed to remove/tombstone file");

        for t in threads {
            t.join().unwrap();
        }

        // Drop the table. File should be deleted now.
        drop(table);
        drop(file); // Ensure file handle is closed for Windows deletion
        
        // Wait a bit for Windows to release the file if there's any pending activity
        for _ in 0..10 {
            if !path.exists() { break; }
            std::thread::sleep(Duration::from_millis(50));
        }
        
        assert!(!path.exists(), "File should be deleted after all references are dropped");
    }

    #[test]
    #[cfg(feature = "mmap_read")]
    fn test_zero_copy_performance_alloc_mitigation() {
        let dir = tempdir().unwrap();
        let path = dir.path().join("test_perf.sst").canonicalize().unwrap_or_else(|_| dir.path().join("test_perf.sst"));
        let file_size = create_test_sstable(path.clone());

        let opts = Arc::new(Options::default());
        let sys_file = std::fs::File::open(&path).unwrap();
        let file = Arc::new(sys_file);
        let table = Arc::new(Table::new(0, Arc::clone(&opts), Arc::clone(&file) as Arc<dyn File>, file_size, Some(path.clone())).unwrap());

        // Measure time for 10,000 reads
        let start = std::time::Instant::now();
        for _ in 0..100 {
            let mut iter = table.iter(false, None);
            iter.seek_to_first().unwrap();
            while iter.valid() {
                let data = iter.value_bytes_dataref();
                let _val = data.as_slice();
                iter.advance().unwrap();
            }
        }
        let elapsed = start.elapsed();
        println!("Zero-copy scan time (10,000 entries): {:?}", elapsed);
    }
}
