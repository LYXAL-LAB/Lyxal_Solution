use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Base, Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct RemoveAccessStatement {
	pub name: Expr,
	pub base: Base,
	pub if_exists: bool,
}

impl Default for RemoveAccessStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			base: Base::default(),
			if_exists: false,
		}
	}
}

impl ToSql for RemoveAccessStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "REMOVE ACCESS");
		if self.if_exists {
			write_sql!(f, sql_fmt, " IF EXISTS");
		}
		write_sql!(f, sql_fmt, " {} ON {}", CoverStmts(&self.name), self.base);
	}
}

impl From<RemoveAccessStatement> for crate::lyxal_core_db::expr::statements::RemoveAccessStatement {
	fn from(v: RemoveAccessStatement) -> Self {
		crate::lyxal_core_db::expr::statements::RemoveAccessStatement {
			name: v.name.into(),
			base: v.base.into(),
			if_exists: v.if_exists,
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::RemoveAccessStatement> for RemoveAccessStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::RemoveAccessStatement) -> Self {
		RemoveAccessStatement {
			name: v.name.into(),
			base: v.base.into(),
			if_exists: v.if_exists,
		}
	}
}
