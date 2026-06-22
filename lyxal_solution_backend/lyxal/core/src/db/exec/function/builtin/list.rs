use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// ─────────────────────────────────────────────────────────────
// Relie le parser SQL vers l'implémentation Rust
// ─────────────────────────────────────────────────────────────

define_pure_function!(ListDedupe, "list::dedupe", (array: Any, field: String) -> Any, crate::function::list::dedupe);
define_pure_function!(ListAggregate, "list::aggregate", (array: Any, field: String, op: String) -> Any, crate::function::list::aggregate);
define_pure_function!(ListSplitOut, "list::split_out", (array: Any, field: String) -> Any, crate::function::list::split_out);
define_pure_function!(ListDiff, "list::diff", (base: Any, new: Any, key: String) -> Any, crate::function::list::diff);

// ─────────────────────────────────────────────────────────────
// Fonction de registre appelée par le mod.rs parent
// ─────────────────────────────────────────────────────────────

pub fn register(registry: &mut FunctionRegistry) {
    register_functions!(
        registry,
        ListDedupe,
        ListAggregate,
        ListSplitOut,
        ListDiff,
    );
}
