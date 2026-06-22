//! Schema functions

use anyhow::Result;

use crate::lyxal_core_db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::lyxal_core_db::exec::physical_expr::EvalContext;
use crate::lyxal_core_db::expr::Kind;
use crate::lyxal_core_functions::args::FromArgs;
use crate::lyxal_core_db::val::Value;

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
	) -> crate::lyxal_core_db::exec::BoxFut<'a, Result<Value>> {
		Box::pin(async move {
			let args = FromArgs::from_args("schema::table::exists", args)?;
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options();
			crate::lyxal_core_functions::schema::table::exists((frozen, opt), args).await
		})
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	registry.register(SchemaTableExists);
}
