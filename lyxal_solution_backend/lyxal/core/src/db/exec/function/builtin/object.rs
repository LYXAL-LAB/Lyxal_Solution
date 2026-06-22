//! Object functions

use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(ObjectEntries, "object::entries", (object: Any) -> Any, crate::function::object::entries);
define_pure_function!(ObjectFromEntries, "object::from_entries", (entries: Any) -> Any, crate::function::object::from_entries);
define_pure_function!(ObjectIsEmpty, "object::is_empty", (object: Any) -> Bool, crate::function::object::is_empty);
define_pure_function!(ObjectKeys, "object::keys", (object: Any) -> Any, crate::function::object::keys);
define_pure_function!(ObjectLen, "object::len", (object: Any) -> Int, crate::function::object::len);
define_pure_function!(ObjectValues, "object::values", (object: Any) -> Any, crate::function::object::values);

// Two argument functions
define_pure_function!(ObjectExtend, "object::extend", (base: Any, extension: Any) -> Any, crate::function::object::extend);
define_pure_function!(ObjectRemove, "object::remove", (object: Any, keys: Any) -> Any, crate::function::object::remove);

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
