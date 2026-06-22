//! Sequence functions

use anyhow::Result;

use crate::error::Error;
use crate::db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::db::exec::physical_expr::EvalContext;
use crate::db::expr::Kind;
use crate::db::val::Value;

// =========================================================================
// sequence::nextval - Get the next value from a sequence
// =========================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct SequenceNextval;

impl ScalarFunction for SequenceNextval {
	fn name(&self) -> &'static str {
		"sequence::nextval"
	}

	fn signature(&self) -> Signature {
		Signature::new().arg("sequence", Kind::String).returns(Kind::Int)
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
			let frozen = ctx.exec_ctx.ctx();
			let opt = ctx.exec_ctx.options().ok_or_else(|| {
				anyhow::anyhow!(Error::Internal(
					"No options available for sequence operation".to_string()
				))
			})?;

			// Get the sequence name from args
			let seq = args.into_iter().next().unwrap_or(Value::None);

			crate::function::sequence::nextval((frozen, opt), (seq,)).await
		})
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	registry.register(SequenceNextval);
}
