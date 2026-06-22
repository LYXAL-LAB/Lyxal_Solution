//! Schema functions

use anyhow::Result;

use crate::db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::db::exec::physical_expr::EvalContext;
use crate::db::expr::Kind;
use crate::function::args::FromArgs;
use crate::db::val::Value;

// =========================================================================
// schema::table::exists - Check if a table exists
// =========================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct SchemaTableExists;

impl ScalarFunction for SchemaTableExists {
	fn name(&self) -> &'static str {
		"schema::table::exists"
	}

	fn signature(&self) -> Signature {
		Signature::new().arg("table", Kind::String).returns(Kind::Bool)
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
			let args = FromArgs::from_args("schema::table::exists", args)?;
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options();
			crate::function::schema::table::exists((frozen, opt), args).await
		})
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	registry.register(SchemaTableExists);
}
