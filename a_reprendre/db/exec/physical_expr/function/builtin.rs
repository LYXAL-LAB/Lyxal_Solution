//! Built-in function expression - math::abs(), string::len(), etc.

use std::sync::Arc;

use async_trait::async_trait;
use lyxal_types_core::{SqlFormat, ToSql};

use super::helpers::{args_access_mode, args_required_context, evaluate_args};
use crate::lyxal_core_db::exec::AccessMode;
use crate::lyxal_core_db::exec::physical_expr::{EvalContext, PhysicalExpr};
use crate::lyxal_core_db::expr::FlowResult;
use crate::lyxal_core_db::val::Value;

/// Built-in function expression - math::abs(), string::len(), etc.
///
/// These functions are registered in the FunctionRegistry at startup.
#[derive(Debug, Clone)]
pub struct BuiltinFunctionExec {
	pub(crate) name: String,
	pub(crate) arguments: Vec<Arc<dyn PhysicalExpr>>,
	/// The required context level for this function (looked up at planning time).
	pub(crate) func_required_context: crate::lyxal_core_db::exec::ContextLevel,
}

#[cfg_attr(target_family = "wasm", async_trait(?Send))]
#[cfg_attr(not(target_family = "wasm"), async_trait)]
impl PhysicalExpr for BuiltinFunctionExec {
	fn name(&self) -> &'static str {
		"BuiltinFunction"
	}

	fn required_context(&self) -> crate::lyxal_core_db::exec::ContextLevel {
		// Built-in functions need either their declared context level or
		// whatever context their arguments need, whichever is higher
		let args_ctx = args_required_context(&self.arguments);
		args_ctx.max(self.func_required_context)
	}

	async fn evaluate(&self, ctx: EvalContext<'_>) -> FlowResult<Value> {
		// Check if function is allowed by capabilities
		ctx.check_allowed_function(&self.name)?;

		// Look up the function in the registry
		let registry = ctx.exec_ctx.function_registry();
		let func = registry.get(&self.name).ok_or_else(|| {
			anyhow::anyhow!("Unknown function '{}' - not found in function registry", self.name)
		})?;

		// Evaluate all arguments
		let args = evaluate_args(&self.arguments, ctx.clone()).await?;

		// Invoke the function based on whether it's pure or needs context
		if func.is_pure() && !func.is_async() {
			Ok(func.invoke(args)?)
		} else {
			Ok(func.invoke_async(&ctx, args).await?)
		}
	}

	fn access_mode(&self) -> AccessMode {
		// api::invoke and connector functions with side effects are read-write
		let func_mode = if self.name == "api::invoke"
			|| self.name == "connector::call"
			|| self.name == "connector::health"
			|| self.name == "connector::batch"
		{
			AccessMode::ReadWrite
		} else {
			AccessMode::ReadOnly
		};
		func_mode.combine(args_access_mode(&self.arguments))
	}
}

impl ToSql for BuiltinFunctionExec {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		f.push_str(&self.name);
		f.push_str("(...)");
	}
}
