use surrealdb_types::{SqlFormat, ToSql, write_sql};

use crate::fmt::CoverStmts;
use crate::sql::{Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct RemoveSchedulerStatement {
	pub name: Expr,
	pub if_exists: bool,
}

impl Default for RemoveSchedulerStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			if_exists: false,
		}
	}
}

impl ToSql for RemoveSchedulerStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "REMOVE SCHEDULER");
		if self.if_exists {
			write_sql!(f, sql_fmt, " IF EXISTS");
		}
		write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
	}
}

impl From<RemoveSchedulerStatement> for crate::expr::statements::RemoveSchedulerStatement {
	fn from(v: RemoveSchedulerStatement) -> Self {
		crate::expr::statements::RemoveSchedulerStatement {
			name: v.name.into(),
			if_exists: v.if_exists,
		}
	}
}

impl From<crate::expr::statements::RemoveSchedulerStatement> for RemoveSchedulerStatement {
	fn from(v: crate::expr::statements::RemoveSchedulerStatement) -> Self {
		RemoveSchedulerStatement {
			name: v.name.into(),
			if_exists: v.if_exists,
		}
	}
}

