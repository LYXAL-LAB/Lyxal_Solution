//! Meta functions (aliases for record functions)

use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(MetaId, "meta::id", (record: Any) -> Any, crate::function::record::id);
define_pure_function!(MetaTb, "meta::tb", (record: Any) -> String, crate::function::record::tb);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, MetaId, MetaTb);
}
