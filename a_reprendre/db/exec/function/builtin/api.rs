//! API functions for the streaming executor.

use anyhow::Result;
use reblessive::TreeStack;

use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::lyxal_core_db::exec::physical_expr::EvalContext;
use crate::lyxal_core_db::expr::Kind;
use crate::lyxal_core_functions::args::FromArgs;
use crate::lyxal_core_db::val::Value;

// =========================================================================
// api::invoke - Invoke a defined API endpoint
// =========================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct ApiInvoke;

impl ScalarFunction for ApiInvoke {
	fn name(&self) -> &'static str {
		"api::invoke"
	}

	fn signature(&self) -> Signature {
		Signature::new().arg("path", Kind::String).optional("request", Kind::Any).returns(Kind::Any)
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
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options().ok_or_else(|| {
				anyhow::anyhow!(Error::Internal("No options available for api::invoke".to_string()))
			})?;

			// Convert args using FromArgs (same conversion the legacy dispatch uses)
			let args = FromArgs::from_args("api::invoke", args)?;

			// Create a TreeStack for the reblessive stack required by api::invoke
			let mut stack = TreeStack::new();
			stack
				.enter(|stk| async move { crate::lyxal_core_functions::api::invoke((stk, frozen, opt), args).await })
				.finish()
				.await
		})
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	registry.register(ApiInvoke);
}
