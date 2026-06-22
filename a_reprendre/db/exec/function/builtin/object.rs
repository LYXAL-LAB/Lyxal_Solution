//! Object functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(ObjectEntries, "object::entries", (object: Any) -> Any, crate::lyxal_core_functions::object::entries);
define_pure_function!(ObjectFromEntries, "object::from_entries", (entries: Any) -> Any, crate::lyxal_core_functions::object::from_entries);
define_pure_function!(ObjectIsEmpty, "object::is_empty", (object: Any) -> Bool, crate::lyxal_core_functions::object::is_empty);
define_pure_function!(ObjectKeys, "object::keys", (object: Any) -> Any, crate::lyxal_core_functions::object::keys);
define_pure_function!(ObjectLen, "object::len", (object: Any) -> Int, crate::lyxal_core_functions::object::len);
define_pure_function!(ObjectValues, "object::values", (object: Any) -> Any, crate::lyxal_core_functions::object::values);

// Two argument functions
define_pure_function!(ObjectExtend, "object::extend", (base: Any, extension: Any) -> Any, crate::lyxal_core_functions::object::extend);
define_pure_function!(ObjectRemove, "object::remove", (object: Any, keys: Any) -> Any, crate::lyxal_core_functions::object::remove);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		ObjectEntries,
		ObjectExtend,
		ObjectFromEntries,
		ObjectIsEmpty,
		ObjectKeys,
		ObjectLen,
		ObjectRemove,
		ObjectValues,
	);
}
