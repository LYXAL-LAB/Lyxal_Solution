//! Record functions

use anyhow::Result;
use reblessive::tree::TreeStack;

use crate::db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::db::exec::physical_expr::EvalContext;
use crate::db::expr::Kind;
use crate::function::args::FromArgs;
use crate::db::val::Value;
use crate::{define_pure_function, register_functions};

define_pure_function!(RecordId, "crate::function::record::id", (record: Any) -> Any, crate::function::record::id);
define_pure_function!(RecordTb, "crate::function::record::tb", (record: Any) -> String, crate::function::record::tb);
define_pure_function!(RecordTable, "crate::db::key::record::table", (record: Any) -> String, crate::function::record::tb);

// =========================================================================
// crate::function::record::exists - Check if a record exists in the database
// =========================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct RecordExists;

impl ScalarFunction for RecordExists {
	fn name(&self) -> &'static str {
		"crate::function::record::exists"
	}

	fn signature(&self) -> Signature {
		Signature::new().arg("record", Kind::Any).returns(Kind::Bool)
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
			let args = FromArgs::from_args("crate::function::record::exists", args)?;
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options();
			// Note: CursorDoc is not available in the streaming executor context
			let doc = None;
			let mut stack = TreeStack::new();
			stack
				.enter(|stk| async move {
					crate::function::record::exists((stk, frozen, opt, doc), args).await
				})
				.finish()
				.await
		})
	}
}

// =========================================================================
// crate::db::key::record::is_edge - Check if a record is an edge
// =========================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct RecordIsEdge;

impl ScalarFunction for RecordIsEdge {
	fn name(&self) -> &'static str {
		"crate::db::key::record::is_edge"
	}

	fn signature(&self) -> Signature {
		Signature::new().arg("record", Kind::Any).returns(Kind::Bool)
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
			let args = FromArgs::from_args("crate::db::key::record::is_edge", args)?;
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options();
			// Note: CursorDoc is not available in the streaming executor context
			let doc = None;
			let mut stack = TreeStack::new();
			stack
				.enter(|stk| async move {
					crate::function::record::is::edge((stk, frozen, opt, doc), args).await
				})
				.finish()
				.await
		})
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(registry, RecordId, RecordTb, RecordTable);
	registry.register(RecordExists);
	registry.register(RecordIsEdge);
}
