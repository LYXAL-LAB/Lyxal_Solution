//! Not function

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(Not, "not", (value: Any) -> Bool, crate::lyxal_core_functions::not::not);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, Not);
}
