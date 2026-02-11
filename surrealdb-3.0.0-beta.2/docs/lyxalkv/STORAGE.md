/db_root/
├── manifest/           # Manifest files (source of truth)
├── sstables/           # L0..Ln SSTable files (.sst)
├── vlog/               # Value Log segments (.vlog)
├── wal/                # Write-Ahead Log segments (.wal)
├── discard_stats/      # GC efficiency metadata
├── versioned_index/    # B+ Tree index for history
└── LOCK                # Process lock file
```

---

## 2. SSTable Format (.sst)

SSTables are sorted, immutable files. They use a block-based format inspired by LevelDB but optimized for key-only storage (WiscKey).

### File Layout
| Component | Description |
| :--- | :--- |
| **Data Blocks** | Multiple compressed blocks containing `InternalKey` and `ValueLocation`. |
| **Index Blocks** | Maps the last key of each data block to its offset. |
| **Filter Block** | Bloom filter for fast "key-not-found" checks. |
| **Footer** | Fixed-size (48 bytes). Contains pointers to index and filter blocks. |

### Internal Key Structure
Within blocks, keys are stored as:
`| User Key | Sequence (56b) | Type (8b) | Timestamp (64b) |`

---

## 3. Value Log (VLog) Format

The VLog is an append-only sequence of value records. It is the primary storage for values exceeding the `vlog_value_threshold`.

### VLog Entry
| Field | Size | Description |
| :--- | :--- | :--- |
| **Key Length** | 4 bytes | Size of the key. |
| **Value Length** | 4 bytes | Size of the value. |
| **Key** | Variable | The key associated with this value (for GC verification). |
| **Value** | Variable | The raw value data. |
| **CRC32** | 4 bytes | Checksum of the key + value. |

### Value Pointer
When a value is stored in VLog, the SSTable stores a `ValuePointer`:
`| File ID (32b) | Offset (64b) | Length (32b) |`

---

## 4. Write-Ahead Log (WAL) Format

The WAL ensures durability. It is organized into segments.

### Record Structure
| Field | Description |
| :--- | :--- |
| **Length** | 4 bytes (u32). |
| **Checksum** | 4 bytes (CRC32C). |
| **Type** | 1 byte (Full, First, Middle, Last). |
| **Payload** | The serialized `Batch`. |

### Batch Format
A Batch is the atomic unit of write:
- **Header**: `| Starting Sequence (64b) | Entry Count (32b) |`
- **Entries**: Sequence of `| Type | Key Len | Key | Value Len | Value | Timestamp |`

---

## 5. Manifest Format

The manifest is the source of truth for the database state. It uses a binary format updated via atomic swaps.

### Header
- **Version**: 2 bytes.
- **Next Table ID**: 8 bytes.
- **Log Number**: 8 bytes (Active WAL number).
- **Last Sequence**: 8 bytes.

### Level Metadata
A list of levels, each containing a sorted list of SSTable IDs and their key ranges.

---

## 6. Discard Statistics

Stored in the `discard_stats/` directory, these files track the amount of "dead" data in each VLog file.
- **Format**: Mapping of `FileID -> DiscardedBytes`.
- **Usage**: The VLog GC Manager uses this to select the best candidate for compaction (highest discard ratio).

---
*For transaction details, see [TRANSACTIONS.md](./TRANSACTIONS.md). For operational guides, see [OPERATIONS.md](./OPERATIONS.md).*