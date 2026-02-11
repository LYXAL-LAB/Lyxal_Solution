# Lyxal Revision System

`lyxal_revision` is a high-performance, version-aware serialization framework designed for the Lyxal ecosystem. It provides the mechanism for data structures to evolve over time without breaking compatibility with previously persisted data.

## 1. Core Philosophy

In a long-running distributed system like SurrealDB, data formats inevitably change. `lyxal_revision` solves this by:
-   **Explicit Versioning**: Every struct is tagged with a revision number.
-   **Backward Compatibility**: The deserialization logic can handle older versions of a struct.
-   **Zero-Overhead for Current Versions**: Optimized paths for the latest revision.

---

## 2. Key Components

### Traits
-   `LyxalRevisioned`: Defines the type's current revision and unique TypeID.
-   `SerializeLyxalRevisioned`: Interface for writing the type to a `std::io::Write` stream.
-   `DeserializeLyxalRevisioned`: Interface for reading the type from a `std::io::Read` stream.

### The Macro
The `lyxal_revisioned` derive macro automate the implementation of these traits.

---

## 3. Usage Example

```rust
use lyxal_revision::lyxal_revisioned;

#[lyxal_revisioned(lyxal_revision = 2)]
#[derive(Debug)]
pub struct UserProfile {
    pub id: u128,
    pub username: String,
    // Added in revision 2
    #[lyxal_revision(start = 2, default_value = "String::new()")]
    pub bio: String,
}
```

When this struct is deserialized:
-   If the incoming data is **Revision 1**, the `bio` field will be populated with an empty string.
-   If the incoming data is **Revision 2**, all fields are read normally.

---

## 4. Performance Optimizations

`lyxal_revision` includes specialized implementations for common types to minimize CPU and Memory overhead:

### Bulk I/O (Specialized feature)
For vectors of primitive types (e.g., `Vec<u8>`, `Vec<i32>`, `Vec<Uuid>`), the crate uses `unsafe` optimizations to perform bulk memory copies when the platform's endianness matches the wire format (Little-Endian).

### Check-free Pushing
During deserialization of collections, the crate uses `std::hint::assert_unchecked` to inform the compiler that bounds checks can be skipped after capacity has been reserved, significantly speeding up large data ingestion.

---

## 5. Supported Types

The system supports the following out-of-the-box:
-   **Primitives**: `bool`, `char`, `u8`-`u128`, `i8`-`i128`, `f32`, `f64`, `usize`, `isize`.
-   **Standard Collections**: `Vec`, `HashMap`, `BTreeMap`, `HashSet`, `BTreeSet`, `Option`, `Result`.
-   **Smart Pointers**: `Box`, `Arc`, `Cow`.
-   **External Crates** (via features): `chrono`, `uuid`, `rust_decimal`, `geo`, `roaring`, `imbl`.

---

## 6. Integration in the Ecosystem

-   **LyxalKV**: Uses revisions for storing metadata, manifest entries, and internal keys.
-   **LyxalSync**: Uses revisions for the Raft protocol messages and log entries to ensure protocol compatibility during rolling upgrades.
-   **LyxalNet**: Frames and session contexts are revisioned.

---
*For implementation details, refer to the source code in `crates/lyxal_revision/src/lib.rs`.*