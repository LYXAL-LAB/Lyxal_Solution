# LyxalKV Operations Guide

This guide provides operational instructions for managing LyxalKV in production environments, covering backups, recovery, and maintenance of the storage engine.

## 1. Backups via Atomic Checkpoints

LyxalKV supports consistent, point-in-time backups through its **Atomic Checkpoint** mechanism. Unlike a simple file copy, a checkpoint ensures that the resulting image is 100% consistent, even if the database is actively performing writes or compactions.

### How it Works:
1. **Flush**: The engine forces a flush of all active memtables to SSTables.
2. **Manifest Lock**: The system locks the manifest to prevent any background compactions from deleting files during the copy.
3. **Atomic Copy**: All required files (SSTables, active WAL, VLog segments, and Manifest) are hard-linked or copied to the backup directory.
4. **Metadata**: A `CHECKPOINT_METADATA` file is generated, containing the timestamp and sequence number of the snapshot.

### Usage (API):
```rust
use lyxalkv::checkpoint::DatabaseCheckpoint;

let checkpoint_mgr = DatabaseCheckpoint::new(tree.core());
checkpoint_mgr.create_checkpoint("/mnt/backups/today_snapshot")?;
```

---

## 2. Crash Recovery

LyxalKV is designed to be resilient to sudden power failures or process crashes.

### Recovery Sequence:
1. **WAL Replay**: Upon restart, the engine scans the `wal/` directory. It identifies the last flushed `log_number` from the manifest and replays all subsequent WAL records.
2. **Atomic Recovery**: Data is restored into the memtable, and the **Versioned Index** is re-populated to ensure "Time Travel" queries remain accurate.
3. **Automatic Repair**: If a WAL segment is partially corrupted due to a disk failure, LyxalKV can automatically attempt to repair the segment and recover as much data as possible (configurable via `WalRecoveryMode`).

---

## 3. VLog Garbage Collection (GC)

In a WiscKey architecture, the VLog is append-only. To reclaim space, LyxalKV uses a background GC process.

### Discard Tracking:
- Every time a key is updated or deleted in the LSM-tree, the size of the old value is recorded in the `discard_stats`.
- When a VLog segment's **Discard Ratio** exceeds the threshold (default: 50%), it becomes a candidate for GC.

### The GC Process:
- The GC manager reads the segment from the beginning.
- For each entry, it queries the LSM-tree (using a Snapshot) to see if that specific value is still the "current" one.
- If it is current, the value is moved to the head of the VLog (**Evacuation**).
- If it is stale, it is simply discarded.

---

## 4. Adaptive GC Management

To optimize performance for Cloud workloads, LyxalKV supports dynamic GC priorities.

| Priority | Behavior | When to use |
| :--- | :--- | :--- |
| `Normal` | Standard background cleanup. | Default operation. |
| `High` | Aggressive cleanup (lower threshold). | Nightly maintenance / low traffic. |
| `Disabled` | Pauses GC entirely. | During massive bulk ingestion. |

### Steering the GC:
The Kernel (`lyxal_os`) can instruct the storage engine to change its behavior based on system load:
```rust
// During low activity periods
tree.set_gc_priority(lyxalkv::vlog::GCPriority::High);
```

---

## 5. Maintenance Procedures

### Monitoring Disk Space
Regularly monitor the `vlog/` and `sstables/` directories. If disk usage grows despite high GC activity:
- Increase the GC aggressiveness.
- Check if an old **Snapshot** is pinning data (preventing it from being compacted).

### Handling "Access Denied" (Windows Only)
On Windows environments, some operations might occasionally fail with `os error 5` due to antivirus scanning or file indexing. LyxalKV includes an internal retry logic, but for production, it is highly recommended to **exclude the data directory from OS indexing**.

### Clean Shutdown
Always call `tree.close().await` before stopping the process. This ensures:
- All WAL data is flushed to SSTables.
- Background threads are cleanly joined.
- File locks are released.

---
*For technical implementation details, see [ARCHITECTURE.md](./ARCHITECTURE.md). For protocol details, see [SYNC.md](./SYNC.md).*