# LyxalKV Documentation Overview

LyxalKV is a high-performance, persistent key-value storage engine written in Rust, specifically designed for cloud-native workloads and distributed databases (like SurrealDB). It implements a hybrid architecture combining **LSM-Tree** (Log-Structured Merge-Tree) and **VLog** (Value Log) based on the WiscKey paper, optimized for modern NVMe/SSD storage.

## 🚀 Key Features

- **WiscKey Architecture**: Separates keys (stored in the LSM-tree) from large values (stored in VLog) to minimize write amplification.
- **Multi-Version Concurrency Control (MVCC)**: Full support for Snapshot Isolation (SI), allowing non-blocking reads and consistent point-in-time views.
- **Versioned Queries**: Native support for "Time Travel" queries. You can query any key at a specific timestamp or scan history.
- **Lock-Free Commit Pipeline**: A high-concurrency pipeline inspired by Pebble, ensuring maximum write throughput.
- **Cloud-Native Resilience**:
    - Atomic Checkpoints for consistent backups.
    - Robust WAL (Write-Ahead Log) recovery with automatic corruption repair.
    - Zero-copy reads via memory-mapped files (mmap).

## 📂 Documentation Structure

| File | Description |
| :--- | :--- |
| [Architecture](./ARCHITECTURE.md) | Deep dive into LSM-Tree, VLog, and the Commit Pipeline. |
| [Transaction Model](./TRANSACTIONS.md) | Explanation of MVCC, Snapshot Isolation, and the Oracle. |
| [Storage Layout](./STORAGE.md) | Details on SSTable format, WAL segments, and VLog structures. |
| [Operations & Recovery](./OPERATIONS.md) | Guide on backups (checkpoints), recovery, and garbage collection (GC). |
| [API Guide](./API.md) | How to use the library as a developer or integrate it into other systems. |

## 🛠 Quick Start

To integrate LyxalKV into your Rust project:

```rust
use lyxalkv::{Options, TreeBuilder, Mode};

#[tokio::main]
async fn main() -> Result<(), lyxalkv::Error> {
    // 1. Configure options
    let opts = Options::new()
        .with_path("./data/db")
        .with_versioning(true, 0); // Enable time-travel

    // 2. Build the tree
    let tree = TreeBuilder::with_options(opts).build()?;

    // 3. Write data
    let mut txn = tree.begin()?;
    txn.set(b"user:123", b"John Doe")?;
    txn.commit().await?;

    // 4. Read data (Snapshot Isolation)
    let txn = tree.begin()?;
    let val = txn.get(b"user:123")?;
    println!("Found: {:?}", val);

    Ok(())
}
```

## 🏗 System Invariants (For IA & Devs)

When working on LyxalKV, the following invariants MUST be maintained:

1. **Commit Visibility**: A `seq_num` is only visible after the write has been successfully persisted to the Memtable.
2. **VLog Shadowing**: During Garbage Collection (GC), never re-insert a value unless it matches the latest version in the LSM-tree (checked via `is_stale`).
3. **Internal Key Order**: Keys are sorted by `user_key` (ascending) then `seq_num` (descending). This puts the latest version first during scans.
4. **Flush Order**: During shutdown, immutable memtables must be flushed before the active memtable to maintain table ID ordering (age).

---
*For more specific details, please refer to the specialized markdown files in this directory.*