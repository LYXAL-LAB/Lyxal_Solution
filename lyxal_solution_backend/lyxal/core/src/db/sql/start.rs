use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct Start(pub Expr);

impl ToSql for Start {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "START {}", CoverStmts(&self.0));
	}
}

impl From<Start> for crate::db::expr::Start {
	fn from(value: Start) -> Self {
		crate::db::expr::Start(value.0.into())
	}
}

impl From<crate::db::expr::Start> for Start {
	fn from(value: crate::db::expr::Start) -> Self {
		Start(value.0.into())
	}
}
