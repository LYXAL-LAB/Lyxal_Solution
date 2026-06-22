# LyxalKV

**LyxalKV** is a high-performance, embedded, ACID-compliant key-value store written in Rust. It is designed for mission-critical applications requiring extreme reliability, predictable latency, and advanced testing capabilities.

 LyxalKV introduces **Chaos Engineering** and **Quality of Service (QoS)** controls directly into the storage engine, making it suitable for distributed systems and financial workloads.

## 🚀 Key Features

*   **ACID Transactions**: Full support for Snapshot Isolation (SI) with optimistic concurrency control.
*   **WiscKey Architecture**: Separates keys (LSM-Tree) from values (Value Log) to minimize I/O amplification.
*   **Versioned Key-Value Store**: Built-in Multi-Version Concurrency Control (MVCC) with time-travel queries.
*   **Chaos Engineering**: Integrated failure injection (read/write errors, latency) for robust testing.
*   **QoS IO Scheduler**: Token-bucket based I/O limiting to prevent background tasks (compaction) from stalling user requests.
*   **Rust 2024 Ready**: Modern codebase utilizing the latest Rust features for safety and performance.

## 📦 Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
lyxalkv = { path = "../lyxalkv" } # Or git dependency
```

## 🛠️ Usage

### Basic Example

```rust
use lyxalkv::{Options, Tree};
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. Configure the engine
    let opts = Options::new()
        .with_path("data.db".into())
        .with_vlog_max_file_size(64 * 1024 * 1024); // 64MB VLog files

    // 2. Open the database
    let tree = Tree::new(opts).await?;

    // 3. Write data in a transaction
    let mut tx = tree.begin().await?;
    tx.set(b"user:123", b"Alice").await?;
    tx.commit().await?;

    // 4. Read data
    let mut tx = tree.begin().await?;
    let val = tx.get(b"user:123").await?;
    println!("Found: {:?}", val);

    Ok(())
}
```

### 🛡️ Advanced Configuration: Chaos & QoS

LyxalKV exposes advanced controls for resilience testing and performance tuning.

#### Chaos Engineering
Simulate disk failures to verify your application's error handling.

```rust
let opts = Options::new()
    // 1 in 1000 reads will fail with an I/O error
    .with_chaos_read_prob(1) 
    // 5 in 1000 writes will fail
    .with_chaos_write_prob(5); 
```

#### Quality of Service (QoS)
Limit the I/O bandwidth used by background tasks (compaction, GC) to ensure foreground latency stability.

```rust
let opts = Options::new()
    // Limit background tasks to 10 MB/s
    .with_io_bg_limit(10 * 1024 * 1024)
    // Limit foreground tasks (optional, usually unlimited)
    .with_io_fg_limit(0); 
```

## 🏗️ Architecture

LyxalKV separates the storage of keys and values:
*   **LSM-Tree**: Stores keys and metadata. Compact and cache-friendly.
*   **Value Log (VLog)**: Stores the actual values. Reduces write amplification for large values.
*   **Oracle**: Manages transaction timestamps and conflict detection.

## 🤝 Contributing

We welcome contributions! Please see the `CONTRIBUTING.md` file for guidelines.

## 📄 License

Apache 2.0
