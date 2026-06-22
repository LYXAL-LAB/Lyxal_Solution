use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Base, Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct RemoveUserStatement {
	pub name: Expr,
	pub base: Base,
	pub if_exists: bool,
}

impl Default for RemoveUserStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			base: Base::default(),
			if_exists: false,
		}
	}
}

impl ToSql for RemoveUserStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "REMOVE USER");
		if self.if_exists {
			write_sql!(f, sql_fmt, " IF EXISTS");
		}
		write_sql!(f, sql_fmt, " {} ON {}", CoverStmts(&self.name), self.base);
	}
}

impl From<RemoveUserStatement> for crate::lyxal_core_db::expr::statements::RemoveUserStatement {
	fn from(v: RemoveUserStatement) -> Self {
		crate::lyxal_core_db::expr::statements::RemoveUserStatement {
			name: v.name.into(),
			if_exists: v.if_exists,
			base: v.base.into(),
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::RemoveUserStatement> for RemoveUserStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::RemoveUserStatement) -> Self {
		RemoveUserStatement {
			name: v.name.into(),
			if_exists: v.if_exists,
			base: v.base.into(),
		}
	}
}
