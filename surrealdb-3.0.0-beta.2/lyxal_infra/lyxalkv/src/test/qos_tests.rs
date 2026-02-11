use std::time::Instant;
use tempfile::tempdir;
use crate::{IoPriority, CURRENT_IO_PRIORITY, Options, TreeBuilder};

#[tokio::test]
async fn test_io_qos_throttling() {
    let dir = tempdir().unwrap();
    // Create the tree using the builder
    let tree = TreeBuilder::new()
        .with_path(dir.path().to_path_buf())
        .build()
        .unwrap();

    // 1. Foreground test (Default)
    // Writing 5MB in foreground should be relatively fast.
    // (Note: Local SSD might be very fast, but let's baseline it)
    let data = vec![0u8; 5 * 1024 * 1024];
    let start = Instant::now();
    {
        let mut tx = tree.begin().unwrap();
        tx.set(b"foreground_key", data.clone()).unwrap();
        tx.commit().await.unwrap();
    }
    let duration_fg = start.elapsed();
    println!("Foreground 5MB write took: {:?}", duration_fg);

    // 2. Background test
    // Writing 5MB in background should be throttled.
    // Scheduler: 10MB/s refill, 2MB burst.
    // 5MB needs 3MB beyond burst. 3MB / 10MB/s = 0.3s.
    let start = Instant::now();
    CURRENT_IO_PRIORITY.scope(IoPriority::Background, async {
        let mut tx = tree.begin().unwrap();
        tx.set(b"background_key", data).unwrap();
        tx.commit().await.unwrap();
    }).await;
    let duration_bg = start.elapsed();
    println!("Background 5MB write took: {:?}", duration_bg);

    // Verify throttling effect
    // Even if local IO is 500MB/s (10ms for 5MB), background should take ~300ms.
    assert!(duration_bg > duration_fg, "Background should be slower than Foreground. BG: {:?}, FG: {:?}", duration_bg, duration_fg);
    assert!(duration_bg.as_millis() >= 200, "Background I/O should be throttled to at least 200ms for 5MB (Target ~300ms). Got: {:?}", duration_bg);
}
