use anyhow::Result;
use reblessive::tree::Stk;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::expr::Operation;
use crate::db::val::{Closure, Value};

pub(crate) async fn chain(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, Option<&Options>, Option<&CursorDoc>),
	(value, worker): (Value, Box<Closure>),
) -> Result<Value> {
	if let Some(opt) = opt {
		worker.invoke(stk, ctx, opt, doc, vec![value]).await
	} else {
		Ok(Value::None)
	}
}

pub(crate) async fn diff((val1, val2): (Value, Value)) -> Result<Value> {
	Ok(Operation::operations_to_value(val1.diff(&val2)))
}

pub(crate) async fn patch((mut val, diff): (Value, Value)) -> Result<Value> {
	val.patch(diff)?;
	Ok(val)
}
