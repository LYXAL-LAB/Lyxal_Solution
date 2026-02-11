# LyxalKV Architecture

This document provides a deep dive into the internal architecture of LyxalKV, explaining how the LSM-Tree, VLog, and Commit Pipeline work together to provide high-performance storage.

## 1. Core Design Philosophy: WiscKey

LyxalKV is based on the **WiscKey** architecture, which decouples keys from values to minimize **Write Amplification (WA)** and **Read Amplification (RA)**.

- **LSM-Tree (Log-Structured Merge-Tree)**: Stores only `InternalKeys` and `ValuePointers`. Since keys are small, the LSM-tree stays shallow, and compactions are extremely fast.
- **VLog (Value Log)**: An append-only log that stores the actual values. Values are never moved during standard LSM compactions, only during specialized VLog Garbage Collection (GC) cycles.

### Advantages for Cloud Storage
In cloud environments (AWS EBS, GCP Persistent Disk), IOPS are expensive. By separating keys and values, LyxalKV performs fewer disk writes during compaction compared to traditional LSM-trees like LevelDB or RocksDB.

---

## 2. The Storage Hierarchy

### In-Memory Components
1. **Active Memtable**: A lock-free skip-list (or B-Tree) that receives all incoming writes.
2. **Immutable Memtables**: Memtables that are full and waiting to be flushed to disk as SSTables.
3. **Block Cache**: An LRU/ARC cache for data blocks and index blocks to speed up reads.

### On-Disk Components
1. **WAL (Write-Ahead Log)**: Ensures durability. Every write is appended to the WAL before being applied to the Memtable.
2. **SSTables (Sorted String Tables)**: Organized in levels (L0 to Ln). 
    - **L0**: Overlapping key ranges (direct flushes from Memtable).
    - **L1+**: Non-overlapping key ranges, leveled for efficient binary search.
3. **VLog Files**: Segmented log files (e.g., `00001.vlog`) containing raw value data indexed by `ValuePointers`.
4. **Manifest**: The source of truth for the database state, tracking which SSTables belong to which level and the current WAL log number.

---

## 3. The Commit Pipeline

LyxalKV uses a high-concurrency, lock-free commit pipeline inspired by **Pebble**.

### Pipeline Stages
1. **Prepare**: The transaction is assigned a monotonic `seq_num`.
2. **WAL Write**: The batch is serialized and written to the Write-Ahead Log. This is the only serialized step in the pipeline.
3. **Memtable Apply**: Multiple transactions can apply their data to the Memtable in parallel.
4. **Publish**: The `visible_seq_num` is advanced atomically. A sequence number only becomes visible to readers once the data is fully present in the Memtable.

---

## 4. Key Structures

### Internal Key Format
Every key in LyxalKV is wrapped in an `InternalKey`:
`| User Key | Sequence Number (56 bits) | Type (8 bits) | Timestamp |`

- **Sequence Number**: Used for MVCC and visibility.
- **Type**: `Set`, `Delete`, `Merge`, or `Replace`.
- **Timestamp**: Used for native versioning and "Time Travel" queries.

### Value Pointer
When a value exceeds the `vlog_value_threshold`, it is stored in the VLog, and the LSM-tree stores a `ValuePointer`:
`| File ID | Offset | Length | Checksum |`

---

## 5. Compaction Strategy

### Leveled Compaction
LyxalKV follows a Leveled Compaction strategy to maintain a predictable number of files per level. 
- When Level `L` reaches its size threshold, a set of files is selected and merged with overlapping files in `L+1`.
- **Tombstone Removal**: Deleted keys (tombstones) are only removed when they reach the last level or after a configurable retention period.

### VLog Garbage Collection
Since values in the VLog are not moved by LSM compactions, they eventually become "stale" (when the corresponding key is deleted or updated).
- The **GC Manager** scans old VLog segments.
- For each entry, it checks the LSM-tree. If the current LSM entry still points to this VLog location, the value is "evacuated" (re-inserted at the head of the log).
- If the LSM-tree points elsewhere, the entry is skipped (collected).

---

## 6. System Invariants

To ensure data integrity, the following rules are enforced:
- **WAL-first**: Data must hit the WAL before it hits the Memtable.
- **Manifest Atomicity**: Any change to the level structure must be recorded in the manifest via an atomic file swap.
- **Ordered Flush**: During shutdown, immutable memtables are flushed in chronological order to ensure Table IDs correctly reflect data age.