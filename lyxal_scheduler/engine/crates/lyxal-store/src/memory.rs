//! In-memory store placeholder.
//!
//! Previously this module provided a thin wrapper around `SqliteStore::in_memory()`.
//! SQLite has been removed in favour of SurrealDB (`SurrealStore`).
//!
//! Contract tests and server integration tests that previously called
//! `create_memory_store()` / `SqliteStore::in_memory()` are temporarily
//! disabled and will be re-enabled once `SurrealStore` is implemented
//! (see `surreal.rs`).

use crate::traits::StoreError;

/// Placeholder — returns an error until SurrealStore is wired in.
/// Tests that need a real in-memory backend should use SurrealDB's
/// embedded mode or a testcontainer once available.
pub fn create_memory_store() -> Result<(), StoreError> {
    Err(StoreError::Database(
        "In-memory store not yet available: SurrealStore implementation pending".into(),
    ))
}
