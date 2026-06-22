//! Set functions

use anyhow::Result;
use reblessive::tree::TreeStack;

use crate::db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::db::exec::physical_expr::EvalContext;
use crate::db::expr::Kind;
use crate::function::args::FromArgs;
use crate::db::val::Value;
use crate::{define_pure_function, register_functions};

// Single set argument functions
define_pure_function!(SetFirst, "set::first", (set: Any) -> Any, crate::function::set::first);
define_pure_function!(SetFlatten, "set::flatten", (set: Any) -> Any, crate::function::set::flatten);
define_pure_function!(SetIsEmpty, "set::is_empty", (set: Any) -> Bool, crate::function::set::is_empty);
define_pure_function!(SetLast, "set::last", (set: Any) -> Any, crate::function::set::last);
define_pure_function!(SetLen, "set::len", (set: Any) -> Int, crate::function::set::len);
define_pure_function!(SetMax, "set::max", (set: Any) -> Any, crate::function::set::max);
define_pure_function!(SetMin, "set::min", (set: Any) -> Any, crate::function::set::min);

// Two argument set functions
define_pure_function!(SetAdd, "set::add", (set: Any, value: Any) -> Any, crate::function::set::add);
define_pure_function!(SetAt, "set::at", (set: Any, index: Int) -> Any, crate::function::set::at);
define_pure_function!(SetComplement, "set::complement", (a: Any, b: Any) -> Any, crate::function::set::complement);
define_pure_function!(SetContains, "set::contains", (set: Any, value: Any) -> Bool, crate::function::set::contains);
define_pure_function!(SetDifference, "set::difference", (a: Any, b: Any) -> Any, crate::function::set::difference);
define_pure_function!(SetIntersect, "set::intersect", (a: Any, b: Any) -> Any, crate::function::set::intersect);
define_pure_function!(SetJoin, "set::join", (set: Any, separator: String) -> String, crate::function::set::join);
define_pure_function!(SetRemove, "set::remove", (set: Any, value: Any) -> Any, crate::function::set::remove);
define_pure_function!(SetUnion, "set::union", (a: Any, b: Any) -> Any, crate::function::set::union);

// Three argument set functions
define_pure_function!(SetSlice, "set::slice", (set: Any, start: Int, ?length: Int) -> Any, crate::function::set::slice);

// =========================================================================
// Closure-based set functions (require async execution with TreeStack)
// =========================================================================

/// Helper macro for creating closure-based set functions
macro_rules! define_set_closure_function {
	($struct_name:ident, $func_name:literal, $impl_path:path, $($arg:ident: $kind:ident),+ => $ret:ident) => {
		#[derive(Debug, Clone, Copy, Default)]
		pub struct $struct_name;

		impl ScalarFunction for $struct_name {
			fn name(&self) -> &'static str {
				$func_name
			}

			fn signature(&self) -> Signature {
				Signature::new()
					$(.arg(stringify!($arg), Kind::$kind))+
					.returns(Kind::$ret)
			}

			fn is_pure(&self) -> bool {
				false
			}

			fn is_async(&self) -> bool {
				true
			}

			fn invoke(&self, _args: Vec<Value>) -> Result<Value> {
				Err(anyhow::anyhow!("Function '{}' requires async execution", self.name()))
			}

			fn invoke_async<'a>(
				&'a self,
				ctx: &'a EvalContext<'_>,
				args: Vec<Value>,
			) -> crate::db::exec::BoxFut<'a, Result<Value>> {
				Box::pin(async move {
					let args = FromArgs::from_args($func_name, args)?;
					let frozen = ctx.exec_ctx.ctx();
					let opt = ctx.exec_ctx.options();
					// Note: CursorDoc is not available in the streaming executor context
					let doc = None;
					let mut stack = TreeStack::new();
					stack
						.enter(|stk| async move {
							$impl_path((stk, frozen, opt, doc), args).await
						})
						.finish()
						.await
				})
			}
		}
	};
}

// set::filter - Filter elements by closure/value
define_set_closure_function!(SetFilter, "set::filter", crate::function::set::filter, set: Any, check: Any => Any);

// set::find - Find first matching element
define_set_closure_function!(SetFind, "set::find", crate::function::set::find, set: Any, check: Any => Any);

// set::fold - Fold with accumulator and closure
define_set_closure_function!(SetFold, "set::fold", crate::function::set::fold, set: Any, init: Any, mapper: Any => Any);

// set::map - Transform elements with closure
define_set_closure_function!(SetMap, "set::map", crate::function::set::map, set: Any, mapper: Any => Any);

// set::reduce - Reduce set with closure
define_set_closure_function!(SetReduce, "set::reduce", crate::function::set::reduce, set: Any, mapper: Any => Any);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		SetAdd,
		SetAt,
		SetComplement,
		SetContains,
		SetDifference,
		SetFirst,
		SetFlatten,
		SetIntersect,
		SetIsEmpty,
		SetJoin,
		SetLast,
		SetLen,
		SetMax,
		SetMin,
		SetRemove,
		SetSlice,
		SetUnion,
	);

	// Register closure-based functions
	registry.register(SetFilter);
	registry.register(SetFind);
	registry.register(SetFold);
	registry.register(SetMap);
	registry.register(SetReduce);
}
