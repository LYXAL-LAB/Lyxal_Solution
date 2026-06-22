use std::cmp::Ordering;

use anyhow::Result;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::ParameterCapturePass;
use crate::lyxal_core_db::expr::{Expr, Kind, Param};
use crate::lyxal_core_db::val::{Closure, Value};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct ClosureExpr {
	pub args: Vec<(Param, Kind)>,
	pub returns: Option<Kind>,
	pub body: Expr,
}

impl PartialOrd for ClosureExpr {
	fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
		Some(self.cmp(other))
	}
}
impl Ord for ClosureExpr {
	fn cmp(&self, _: &Self) -> Ordering {
		Ordering::Equal
	}
}

impl ClosureExpr {
	#[instrument(level = "trace", name = "ClosureExpr::compute", skip_all)]
	pub(crate) async fn compute(&self, ctx: &FrozenContext) -> Result<Value> {
		let captures = ParameterCapturePass::capture(ctx, &self.body);

		Ok(Value::Closure(Box::new(Closure::Expr {
			args: self.args.clone(),
			returns: self.returns.clone(),
			captures,
			body: self.body.clone(),
		})))
	}
}

impl ToSql for ClosureExpr {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let closure: crate::lyxal_core_db::sql::Closure = self.clone().into();
		closure.fmt_sql(f, sql_fmt);
	}
}
