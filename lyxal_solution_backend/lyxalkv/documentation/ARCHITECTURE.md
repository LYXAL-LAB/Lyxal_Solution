# LyxalKV Architecture

## Overview

LyxalKV is a Log-Structured Merge-tree (LSM) key-value store that separates keys from values, inspired by **WiscKey**. This design significantly reduces write amplification, as values (which are often larger than keys) do not need to be repeatedly compacted in the LSM tree.

## Components

### 1. LSM-Tree (Keys)
*   **Memtable**: In-memory skiplist that buffers incoming writes. When full, it is flushed to disk as an SSTable.
*   **SSTables**: Sorted String Tables organized in levels (LevelDB style). They store keys and pointers to the Value Log.
*   **Compaction**: Background process that merges SSTables to reclaim space and maintain read performance.

### 2. Value Log (Values)
*   **VLog Files**: Append-only files storing the actual user values.
*   **Garbage Collection**: Because values are not compacted in the LSM tree, a separate GC process scans VLog files to discard values corresponding to deleted or overwritten keys.

### 3. Transaction Oracle
*   **Snapshot Isolation**: Uses a global logical clock to assign timestamps to transactions.
*   **Conflict Detection**: Tracks read and write sets to detect conflicts between concurrent transactions.
*   **Lock-Free**: Uses optimistic concurrency control for high throughput.

### 4. Virtual File System (VFS)
The VFS layer abstracts file system operations to provide advanced capabilities:
*   **ChaosController**: Intercepts I/O calls to inject simulated failures (errors, partial writes).
*   **IoScheduler**: Regulates I/O bandwidth using a Token Bucket algorithm. This ensures that heavy background operations (like compaction) do not starve foreground user queries.

## Data Flow

1.  **Write**:
    *   Transaction acquires a timestamp.
    *   Value is written to the **VLog** (append-only).
    *   Key + VLog Pointer is written to the **Memtable**.
    *   On commit, changes are made visible.

2.  **Read**:
    *   Search **Memtable**.
    *   If not found, search **SSTables** (LSM-Tree) to find the Key.
    *   Use the retrieved VLog Pointer to read the Value from the **VLog** file.

## Crash Recovery

*   **WAL (Write Ahead Log)**: All memtable writes are backed by a WAL for durability.
*   **Manifest**: Tracks the state of the LSM tree (active SSTables, current VLog file).
*   **Recovery**: On startup, the engine replays the WAL to reconstruct the Memtable and verifies VLog integrity (checksums).
