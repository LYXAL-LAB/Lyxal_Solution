use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::Expr;

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct KillStatement {
	// Uuid of Live Query
	// or Param resolving to Uuid of Live Query
	pub id: Expr,
}

impl ToSql for KillStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "KILL {}", CoverStmts(&self.id));
	}
}

impl From<KillStatement> for crate::db::expr::statements::KillStatement {
	fn from(v: KillStatement) -> Self {
		Self {
			id: v.id.into(),
		}
	}
}

impl From<crate::db::expr::statements::KillStatement> for KillStatement {
	fn from(v: crate::db::expr::statements::KillStatement) -> Self {
		Self {
			id: v.id.into(),
		}
	}
}
