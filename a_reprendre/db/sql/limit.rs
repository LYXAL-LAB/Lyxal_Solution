use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Limit(pub(crate) Expr);

impl ToSql for Limit {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "LIMIT {}", CoverStmts(&self.0))
	}
}

impl From<Limit> for crate::lyxal_core_db::expr::Limit {
	fn from(value: Limit) -> Self {
		Self(value.0.into())
	}
}

impl From<crate::lyxal_core_db::expr::Limit> for Limit {
	fn from(value: crate::lyxal_core_db::expr::Limit) -> Self {
		Limit(value.0.into())
	}
}
