use anyhow::Result;

use crate::db::val::Value;

/// Returns a boolean that is false if the input is truthy and true otherwise.
pub(crate) fn not((val,): (Value,)) -> Result<Value> {
	Ok((!val.is_truthy()).into())
}
