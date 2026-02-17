#[cfg(test)]
mod tests {
    #[cfg(feature = "mmap_read")]
    use crate::vlog::*;
    #[cfg(feature = "mmap_read")]
    use crate::Options;
    #[cfg(feature = "mmap_read")]
    use crate::VLogChecksumLevel;
    #[cfg(feature = "mmap_read")]
    use crate::VLogMmapMode;
    #[cfg(feature = "mmap_read")]
    // use crate::data::DataRef;
    #[cfg(feature = "mmap_read")]
    use std::sync::Arc;
    #[cfg(feature = "mmap_read")]
    use tempfile::tempdir;
    #[cfg(feature = "mmap_read")]
    use std::time::Duration;

    #[cfg(feature = "mmap_read")]
    fn setup_vlog(mmap_mode: VLogMmapMode) -> (Arc<VLog>, tempfile::TempDir) {
        let dir = tempdir().unwrap();
        let mut opts = Options::default();
        opts.path = dir.path().to_path_buf();
        opts.vlog_mmap_mode = mmap_mode;
        opts.vlog_checksum_verification = VLogChecksumLevel::Full;
        
        // Create necessary directories
        std::fs::create_dir_all(opts.vlog_dir()).unwrap();
        std::fs::create_dir_all(opts.discard_stats_dir()).unwrap();
        std::fs::create_dir_all(opts.delete_list_dir()).unwrap();

        let vlog = VLog::new(Arc::new(opts), None).unwrap();
        (Arc::new(vlog), dir)
    }

    #[tokio::test]
    #[cfg(feature = "mmap_read")]
    async fn test_vlog_zero_copy_basic() {
        let (vlog, _dir) = setup_vlog(VLogMmapMode::Auto);
        let key = b"key1";
        let value = b"value1_large_enough_to_not_be_inline_but_we_test_vlog_directly";
        
        let pointer = vlog.append(key, value).unwrap();
        vlog.flush().unwrap();
        
        // Test get_dataref (Zero-copy)
        let data_ref = vlog.get_dataref(&pointer).unwrap();
        assert!(data_ref.is_mmap(), "Should be mmap-backed");
        assert_eq!(data_ref.as_slice(), value);
        
        // Test standard get (which now uses get_dataref internally)
        let retrieved = vlog.get(&pointer).unwrap();
        assert_eq!(retrieved, value);
    }

    #[tokio::test]
    #[cfg(feature = "mmap_read")]
    async fn test_vlog_reader_drop_safety() {
        let (vlog, _dir) = setup_vlog(VLogMmapMode::Auto);
        let key = b"key_drop";
        let value = b"value_drop";
        let pointer = vlog.append(key, value).unwrap();
        vlog.flush().unwrap();
        
        let data_ref = vlog.get_dataref(&pointer).unwrap();
        assert_eq!(data_ref.as_slice(), value);
        
        // Drop the vlog object
        drop(vlog);
        
        // DataRef should still be valid because it carries Arc<MmapHandle>
        assert_eq!(data_ref.as_slice(), value, "DataRef must remain valid after VLog drop");
    }

    #[tokio::test]
    #[cfg(feature = "mmap_read")]
    async fn test_vlog_deferred_delete_tombstone() {
        let (vlog, _dir) = setup_vlog(VLogMmapMode::Auto);
        let key = b"key_tomb";
        let value = b"value_tomb";
        let pointer = vlog.append(key, value).unwrap();
        vlog.flush().unwrap();
        
        let data_ref = vlog.get_dataref(&pointer).unwrap();
        let path = vlog.vlog_file_path(pointer.file_id);
        
        assert!(path.exists());

        // Simulate manual removal/tombstone via crate::vfs::remove_file
        crate::vfs::remove_file(&path).unwrap();
        
        // File should still exist because data_ref holds a mapping
        assert!(path.exists(), "File should survive tombstone while mapped");
        assert_eq!(data_ref.as_slice(), value);
        
        drop(data_ref);
        
        // Now it should eventually disappear (handle OS latency on Windows)
        let mut deleted = false;
        for _ in 0..20 {
            if !path.exists() {
                deleted = true;
                break;
            }
            std::thread::sleep(Duration::from_millis(100));
        }
        assert!(deleted, "File should be physically deleted after last DataRef drop");
    }

    #[tokio::test]
    #[cfg(feature = "mmap_read")]
    async fn test_vlog_mmap_required_fail_fast() {
        let dir = tempdir().unwrap();
        let mut opts = Options::default();
        opts.path = dir.path().to_path_buf();
        opts.vlog_mmap_mode = VLogMmapMode::Required;
        
        // Create necessary directories
        std::fs::create_dir_all(opts.vlog_dir()).unwrap();
        std::fs::create_dir_all(opts.discard_stats_dir()).unwrap();
        std::fs::create_dir_all(opts.delete_list_dir()).unwrap();

        let vlog = VLog::new(Arc::new(opts), None).unwrap();
        let pointer = vlog.append(b"k", b"v").unwrap();
        vlog.flush().unwrap();
        
        let data_ref = vlog.get_dataref(&pointer).unwrap();
        assert!(data_ref.is_mmap());
    }

    #[tokio::test]
    #[cfg(feature = "mmap_read")]
    async fn test_vlog_checksum_on_mmap() {
        let (vlog, _dir) = setup_vlog(VLogMmapMode::Auto);
        let key = b"key_crc";
        let value = b"value_crc";
        let pointer = vlog.append(key, value).unwrap();
        vlog.flush().unwrap();
        
        // Test with checksum enabled
        let data_ref = vlog.get_dataref(&pointer).unwrap();
        assert_eq!(data_ref.as_slice(), value);
    }
}
