//! Count function

use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(Count, "count", (value: Any) -> Int, crate::function::count::count);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, Count);
}
