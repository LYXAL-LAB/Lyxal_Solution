//! Shared store type alias for dependency injection.

use lyxal_store::traits::Store;
use std::sync::Arc;

/// A type-erased, cloneable store that satisfies all store sub-traits via
/// [`lyxal_store::traits::Store`]. The same alias is shared with `lyxal-mcp`
/// so the in-process MCP service factory can accept the server's store.
pub type DynStore = Arc<dyn Store + Send + Sync>;

/// Wrap any `Store` implementation as a `DynStore`.
pub fn dyn_store<S: Store + Send + Sync + 'static>(store: S) -> DynStore {
    Arc::new(store)
}
