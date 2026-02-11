# LyxalKV Transaction Model & MVCC

LyxalKV implements a robust Multi-Version Concurrency Control (MVCC) system providing **Snapshot Isolation (SI)**. This document explains how transactions are managed, how conflicts are detected, and the role of the Oracle.

## 1. Multi-Version Concurrency Control (MVCC)

In LyxalKV, data is never overwritten in place. Instead, every update creates a new version of the key associated with a monotonic **Sequence Number (seq_num)**.

- **Non-blocking Reads**: Readers do not block writers. A reader operates on a consistent "snapshot" of the database as it existed when the transaction began.
- **Ordered Visibility**: The `visible_seq_num` ensures that a transaction only sees data committed before it started.

## 2. Transaction Modes

LyxalKV supports three transaction modes:

| Mode | Description |
| :--- | :--- |
| `ReadWrite` | Default mode. Can read data and buffer writes. Subject to conflict detection on commit. |
| `ReadOnly` | Optimized for queries. Uses a snapshot but cannot perform any write operations. |
| `WriteOnly` | Optimized for high-throughput ingestion where read-your-own-writes is not required. |

## 3. Snapshot Isolation (SI)

When a transaction starts, it captures the current `visible_seq_num` from the `CommitPipeline`. 

### Visibility Rules
A key-value pair is visible to a transaction if:
1. The key's `seq_num` is less than or equal to the transaction's `read_ts`.
2. The key is not marked as deleted (Tombstone) at that sequence number.
3. The key was not modified by the current transaction (unless Read-Your-Own-Writes is applied).

## 4. The Oracle & Conflict Detection

The **Oracle** is the component responsible for managing transaction timestamps and ensuring that concurrent transactions do not violate isolation invariants.

### Optimistic Concurrency Control (OCC)
LyxalKV uses a "First-Committer-Wins" strategy:
1. **Track**: Every `ReadWrite` transaction tracks its `start_timestamp`.
2. **Buffer**: Writes are buffered in a local `write_set` (in-memory BTreeMap).
3. **Validate**: Upon calling `commit()`, the Oracle checks if any other transaction has committed a write to the same keys between our `start_timestamp` and the current time.
4. **Conflict**: If a collision is detected, the transaction is aborted with a `TransactionConflict` error.

## 5. Native Versioning (Time Travel)

Because LyxalKV stores timestamps within its `InternalKey`, it supports **Versioned Queries**.

- **At Version**: `txn.get_at_version(key, timestamp)` allows retrieving data as it was at a specific point in history.
- **Scan All Versions**: `txn.scan_all_versions(key_range)` returns the complete history of a key, including updates and deletions.

## 6. Commit Process

The commit process follows these atomic steps:
1. **Oracle Prepare**: Check for conflicts and reserve a commit timestamp.
2. **Pipeline Enqueue**: Enter the `CommitPipeline` to ensure ordered WAL logging.
3. **Durability**: Wait for WAL sync (if `Durability::Immediate` is selected).
4. **Memory Apply**: Apply the batch to the active Memtable.
5. **Oracle Unregister**: Remove the transaction from the active tracking set.

## 7. Developer Best Practices

- **Short Transactions**: Keep `ReadWrite` transactions as short as possible to minimize the window for conflicts.
- **Use `view()`**: For read-only operations, use the `tree.view()` helper which automatically manages the `ReadOnly` transaction lifecycle.
- **Error Handling**: Always handle `Error::TransactionConflict` by retrying the transaction logic.

```rust
// Example of a retry loop for ReadWrite transactions
let mut attempts = 0;
loop {
    let mut txn = tree.begin()?;
    match do_work(&mut txn).await {
        Ok(_) => {
            txn.commit().await?;
            break;
        }
        Err(e) if e.is_conflict() && attempts < 3 => {
            attempts += 1;
            continue; 
        }
        Err(e) => return Err(e),
    }
}
```
