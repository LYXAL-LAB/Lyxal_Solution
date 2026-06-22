use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct Start(pub Expr);

impl ToSql for Start {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "START {}", CoverStmts(&self.0));
	}
}

impl From<Start> for crate::lyxal_core_db::expr::Start {
	fn from(value: Start) -> Self {
		crate::lyxal_core_db::expr::Start(value.0.into())
	}
}

impl From<crate::lyxal_core_db::expr::Start> for Start {
	fn from(value: crate::lyxal_core_db::expr::Start) -> Self {
		Start(value.0.into())
	}
}
