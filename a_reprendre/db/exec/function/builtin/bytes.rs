//! Bytes functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(BytesLen, "bytes::len", (value: Any) -> Int, crate::lyxal_core_functions::bytes::len);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, BytesLen);
}
