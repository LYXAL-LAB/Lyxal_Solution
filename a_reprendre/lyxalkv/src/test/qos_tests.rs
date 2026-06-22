use std::time::Instant;
use tempfile::tempdir;
use crate::{IoPriority, CURRENT_IO_PRIORITY, TreeBuilder};

#[tokio::test]
async fn test_io_qos_throttling() {
    let dir = tempdir().unwrap();
    // Create the tree using the builder
    let tree = TreeBuilder::new()
        .with_path(dir.path().to_path_buf())
        .build()
        .unwrap();

    // --- Warm up ---
    // Perform a small write to ensure file system caches and allocation are initialized
    {
        let mut tx = tree.begin().unwrap();
        tx.set(b"warmup", vec![0u8; 1024]).unwrap();
        tx.commit().await.unwrap();
    }

    // 1. Foreground test (Default)
    // Writing 10MB in foreground.
    let data = vec![0u8; 10 * 1024 * 1024];
    let start = Instant::now();
    {
        let mut tx = tree.begin().unwrap();
        tx.set(b"foreground_key", data.clone()).unwrap();
        tx.commit().await.unwrap();
    }
    let duration_fg = start.elapsed();
    println!("Foreground 10MB write took: {:?}", duration_fg);

    // 2. Background test
    // Writing 10MB in background should be throttled.
    // Scheduler: 10MB/s refill, 2MB burst.
    // 10MB needs 8MB beyond burst. 8MB / 10MB/s = 0.8s.
    let start = Instant::now();
    CURRENT_IO_PRIORITY.scope(IoPriority::Background, async {
        let mut tx = tree.begin().unwrap();
        tx.set(b"background_key", data).unwrap();
        tx.commit().await.unwrap();
    }).await;
    let duration_bg = start.elapsed();
    println!("Background 10MB write took: {:?}", duration_bg);

    // Verify throttling effect
    // On Windows, foreground can be slow, but background should still be slower due to explicit sleep.
    // We expect BG to be at least 500ms for 10MB (Target ~800ms).
    assert!(duration_bg >= duration_fg, "Background should be slower than or equal to Foreground. BG: {:?}, FG: {:?}", duration_bg, duration_fg);
    assert!(duration_bg.as_millis() >= 400, "Background I/O should be throttled. Got: {:?}", duration_bg);
}
