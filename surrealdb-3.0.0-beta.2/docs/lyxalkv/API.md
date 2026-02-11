# LyxalKV API Guide

This document provides a comprehensive guide to using the LyxalKV API. It is designed to help developers and AI agents integrate LyxalKV into their applications or understand how to interact with the storage engine.

## 1. Core Components

To use LyxalKV, you primarily interact with three structs:
- `Options`: Configuration for the database instance.
- `Tree` / `TreeBuilder`: The main database handle used to manage lifecycle and start transactions.
- `Transaction`: The interface for all data operations (Get, Set, Delete, Scan).

## 2. Initializing the Engine

The `TreeBuilder` provides a fluent API to configure and open a LyxalKV instance.

```rust
use lyxalkv::{Options, TreeBuilder};
use std::path::PathBuf;

async fn init_db() -> Result<lyxalkv::Tree, lyxalkv::Error> {
    let opts = Options::new()
        .with_path(PathBuf::from("./data/mydb"))
        .with_max_memtable_size(64 * 1024 * 1024) // 64MB
        .with_versioning(true, 0)                  // Enable Time-Travel
        .with_enable_vlog(true);                   // Separate keys/values

    let tree = TreeBuilder::with_options(opts).build()?;
    Ok(tree)
}
```

## 3. Transactional Operations

All interactions with data occur within a transaction to guarantee consistency.

### Write Transaction (Read-Write)
```rust
let mut txn = tree.begin()?;

// Insert or Update
txn.set(b"key1", b"value1")?;

// Delete
txn.delete(b"key1")?;

// Commit changes
txn.commit().await?;
```

### Read Transaction
For better performance and concurrency, use the `view` helper or a `ReadOnly` mode for queries.

```rust
// Using the view helper
tree.view(|txn| {
    let val = txn.get(b"key1")?;
    println!("Value: {:?}", val);
    Ok(())
})?;

// Manual Read-Only transaction
let txn = tree.begin_with_mode(lyxalkv::Mode::ReadOnly)?;
let val = txn.get(b"key1")?;
```

## 4. Range Scans and Iterators

LyxalKV provides powerful iterators for range queries.

```rust
let txn = tree.begin()?;
let start = b"user:100";
let end = b"user:200";

// Standard Range Scan
let mut iter = txn.range(start, end)?;
for result in iter {
    let (key, value) = result?;
    println!("Key: {:?}, Value: {:?}", key, value);
}

// Prefix Scan helper (if available in your version)
// Standard pattern for prefix: range(prefix, prefix + 0xFF)
```

## 5. Versioned Queries (Time Travel)

If `with_versioning(true)` was set during initialization, you can access the history of any key.

```rust
// Get value at a specific Unix timestamp (nanoseconds)
let historical_val = txn.get_at_version(b"key1", 1625097600000000000)?;

// Scan all historical versions of a key
let versions = txn.scan_all_versions(b"key1", b"key1_end", None)?;
for (key, value, timestamp, is_deletion) in versions {
    println!("TS: {}, Deletion: {}, Data: {:?}", timestamp, is_deletion, value);
}
```

## 6. Maintenance and Checkpoints

### Atomic Checkpoints
Create a consistent backup of the database without stopping it.

```rust
use lyxalkv::checkpoint::DatabaseCheckpoint;

let checkpoint_mgr = DatabaseCheckpoint::new(tree.core());
checkpoint_mgr.create_checkpoint("./backups/snapshot_2023_10_27")?;
```

### Manual Flush
Force the current memtable to be written to an SSTable.
```rust
tree.flush()?;
```

### Clean Shutdown
Always call `close()` to ensure all background tasks are stopped and the WAL is synced.
```rust
tree.close().await?;
```

## 7. Error Handling

LyxalKV uses a custom `Error` enum. Key variants to handle:

- `Error::TransactionConflict`: Occurs during optimistic concurrency control if two transactions write to the same key simultaneously. **Action: Retry the transaction.**
- `Error::Io`: Underlying disk error.
- `Error::Corruption`: Data integrity failure (e.g., checksum mismatch).
- `Error::EmptyKey`: Attempting to use a zero-length key.

## 8. IA / Developer Tips

- **Key Design**: LyxalKV sorts keys lexicographically. Use fixed-width prefixes for efficient grouping.
- **Value Size**: Values larger than the `vlog_value_threshold` (default 4KB) are stored in the VLog. If your workload has only small values, consider disabling VLog for lower latency.
- **Durability**: By default, commits use `Durability::Eventual`. For critical data requiring an `fsync` on every commit, use `txn.with_durability(Durability::Immediate)`.
```markdown