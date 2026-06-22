use anyhow::Result;

use crate::db::val::{Bytes, Value};

pub(crate) fn len((bytes,): (Bytes,)) -> Result<Value> {
	Ok(bytes.len().into())
}
