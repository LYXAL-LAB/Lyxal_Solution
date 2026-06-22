use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Cond(pub(crate) Expr);

impl ToSql for Cond {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "WHERE {}", CoverStmts(&self.0))
	}
}

impl From<Cond> for crate::db::expr::Cond {
	fn from(v: Cond) -> Self {
		Self(v.0.into())
	}
}

impl From<crate::db::expr::Cond> for Cond {
	fn from(v: crate::db::expr::Cond) -> Self {
		Self(v.0.into())
	}
}
