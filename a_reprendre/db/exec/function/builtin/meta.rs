//! Meta functions (aliases for record functions)

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(MetaId, "meta::id", (record: Any) -> Any, crate::lyxal_core_functions::record::id);
define_pure_function!(MetaTb, "meta::tb", (record: Any) -> String, crate::lyxal_core_functions::record::tb);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, MetaId, MetaTb);
}
