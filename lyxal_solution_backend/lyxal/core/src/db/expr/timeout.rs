>>>> DELETE THIS

use anyhow::Result;
use reblessive::tree::Stk;
use lyxal_types::{SqlFormat, ToSql};

use crate::db::ctx::Context;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::expr::{Expr, Literal};
use crate::db::val::Duration;

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
		let stmt: crate::db::sql::timeout::Timeout = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
