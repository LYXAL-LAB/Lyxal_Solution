use anyhow::Result;

use crate::lyxal_core_db::val::{Bytes, Value};

pub fn len((bytes,): (Bytes,)) -> Result<Value> {
	Ok(bytes.len().into())
}
