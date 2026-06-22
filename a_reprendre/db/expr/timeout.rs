>>>> DELETE THIS

use anyhow::Result;
use reblessive::tree::Stk;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::ctx::Context;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_db::expr::{Expr, Literal};
use crate::lyxal_core_db::val::Duration;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct Timeout(pub(crate) Expr);

impl Default for Timeout {
	fn default() -> Self {
		Self(Expr::Literal(Literal::Duration(Duration::default())))
	}
}

impl Timeout {
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &Context,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Duration> {
		Ok(compute_to!(stk, ctx, opt, doc, self.0 => Duration))
	}
}

impl ToSql for Timeout {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let stmt: crate::lyxal_core_db::sql::timeout::Timeout = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
