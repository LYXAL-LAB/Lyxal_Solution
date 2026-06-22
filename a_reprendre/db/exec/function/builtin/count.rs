//! Count function

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(Count, "count", (value: Any) -> Int, crate::lyxal_core_functions::count::count);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, Count);
}
