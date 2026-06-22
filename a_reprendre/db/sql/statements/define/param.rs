use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use super::DefineKind;
use crate::lyxal_core_utils::fmt::{EscapeKwFreeIdent};
use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Expr, Literal, Permission};

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct DefineParamStatement {
	pub kind: DefineKind,
	pub name: String,
	pub value: Expr,
	pub comment: Expr,
	pub permissions: Permission,
}

impl ToSql for DefineParamStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "DEFINE PARAM");
		match self.kind {
			DefineKind::Default => {}
			DefineKind::Overwrite => write_sql!(f, fmt, " OVERWRITE"),
			DefineKind::IfNotExists => write_sql!(f, fmt, " IF NOT EXISTS"),
		}
		write_sql!(f, fmt, " ${} VALUE {}", EscapeKwFreeIdent(&self.name), &self.value);
		if !matches!(self.comment, Expr::Literal(Literal::None)) {
			write_sql!(f, fmt, " COMMENT {}", &self.comment);
		}
		let fmt = fmt.increment();
		write_sql!(f, fmt, " PERMISSIONS {}", self.permissions);
	}
}

impl From<DefineParamStatement> for crate::lyxal_core_db::expr::statements::DefineParamStatement {
	fn from(v: DefineParamStatement) -> Self {
		Self {
			kind: v.kind.into(),
			name: v.name,
			value: v.value.into(),
			comment: v.comment.into(),
			permissions: v.permissions.into(),
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::DefineParamStatement> for DefineParamStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::DefineParamStatement) -> Self {
		DefineParamStatement {
			kind: v.kind.into(),
			name: v.name,
			value: v.value.into(),
			comment: v.comment.into(),
			permissions: v.permissions.into(),
		}
	}
}
