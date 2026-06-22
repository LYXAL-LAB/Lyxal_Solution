use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::{Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct RemoveEventStatement {
	pub name: Expr,
	pub what: Expr,
	pub if_exists: bool,
}

impl Default for RemoveEventStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			what: Expr::Literal(Literal::None),
			if_exists: false,
		}
	}
}

impl ToSql for RemoveEventStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "REMOVE EVENT");
		if self.if_exists {
			write_sql!(f, fmt, " IF EXISTS");
		}
		write_sql!(f, fmt, " {} ON {}", CoverStmts(&self.name), CoverStmts(&self.what));
	}
}

impl From<RemoveEventStatement> for crate::db::expr::statements::RemoveEventStatement {
	fn from(v: RemoveEventStatement) -> Self {
		crate::db::expr::statements::RemoveEventStatement {
			name: v.name.into(),
			table_name: v.what.into(),
			if_exists: v.if_exists,
		}
	}
}

impl From<crate::db::expr::statements::RemoveEventStatement> for RemoveEventStatement {
	fn from(v: crate::db::expr::statements::RemoveEventStatement) -> Self {
		RemoveEventStatement {
			name: v.name.into(),
			what: v.table_name.into(),
			if_exists: v.if_exists,
		}
	}
}
