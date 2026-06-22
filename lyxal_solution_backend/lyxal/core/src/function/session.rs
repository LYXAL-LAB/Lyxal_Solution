use anyhow::Result;

use crate::db::ctx::FrozenContext;
use crate::db::expr::paths::{AC, DB, ID, IP, NS, OR, RD, TK};
use crate::db::val::Value;

pub(crate) fn ac(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(AC.as_ref()))
}

pub(crate) fn db(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(DB.as_ref()))
}

pub(crate) fn id(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(ID.as_ref()))
}

pub(crate) fn ip(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(IP.as_ref()))
}

pub(crate) fn ns(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(NS.as_ref()))
}

pub(crate) fn origin(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(OR.as_ref()))
}

pub(crate) fn rd(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(RD.as_ref()))
}

pub(crate) fn token(ctx: &FrozenContext, _: ()) -> Result<Value> {
	Ok(ctx.value("session").unwrap_or(&Value::None).pick(TK.as_ref()))
}
