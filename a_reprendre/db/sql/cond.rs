use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Cond(pub(crate) Expr);

impl ToSql for Cond {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "WHERE {}", CoverStmts(&self.0))
	}
}

impl From<Cond> for crate::lyxal_core_db::expr::Cond {
	fn from(v: Cond) -> Self {
		Self(v.0.into())
	}
}

impl From<crate::lyxal_core_db::expr::Cond> for Cond {
	fn from(v: crate::lyxal_core_db::expr::Cond) -> Self {
		Self(v.0.into())
	}
}
