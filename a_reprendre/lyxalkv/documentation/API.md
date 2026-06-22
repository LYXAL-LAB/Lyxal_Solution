# LyxalKV API Reference

## `Options`

The `Options` struct configures the behavior of the storage engine.

### Builder Methods

| Method | Description | Default |
| :--- | :--- | :--- |
| `with_path(PathBuf)` | Sets the database directory path. | `""` |
| `with_block_size(usize)` | Size of data blocks in SSTables. | 64KB |
| `with_block_cache_capacity(u64)` | Size of the in-memory block cache. | 1MB |
| `with_compression_per_level(Vec<CompressionType>)` | Compression algo per level (None, Snappy, Zstd). | None |
| `with_vlog_gc_discard_ratio(f64)` | Threshold to trigger Value Log GC (0.0-1.0). | 0.5 |
| `with_chaos_read_prob(u32)` | Probability (0-1000) of read failures. | 0 |
| `with_chaos_write_prob(u32)` | Probability (0-1000) of write failures. | 0 |
| `with_io_bg_limit(u64)` | Background I/O bandwidth limit (bytes/sec). | 0 (Unlimited) |

## `Tree`

The main entry point for the database.

*   `Tree::new(opts: Options) -> Result<Tree>`: Opens or creates a database.
*   `begin() -> Result<Transaction>`: Starts a read-write transaction.
*   `read() -> Result<Transaction>`: Starts a read-only transaction (snapshot).

## `Transaction`

Provides ACID guarantees for a set of operations.

*   `set(key: &[u8], value: &[u8]) -> Result<()>`: Inserts or updates a key.
*   `get(key: &[u8]) -> Result<Option<Vec<u8>>>`: Retrieves a value.
*   `delete(key: &[u8]) -> Result<()>`: Deletes a key.
*   `commit() -> Result<()>`: Commits changes.
*   `rollback() -> Result<()>`: Discards changes.
