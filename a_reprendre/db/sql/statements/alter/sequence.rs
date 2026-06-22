use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::{EscapeKwIdent};
use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::Expr;

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
#[derive(Default)]
pub struct AlterSequenceStatement {
	pub name: String,
	pub if_exists: bool,
	pub timeout: Option<Expr>,
}

impl ToSql for AlterSequenceStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "ALTER SEQUENCE");
		if self.if_exists {
			write_sql!(f, fmt, " IF EXISTS");
		}
		write_sql!(f, fmt, " {}", EscapeKwIdent(&self.name, &["IF"]));
		if let Some(timeout) = &self.timeout {
			write_sql!(f, fmt, " TIMEOUT {}", timeout);
		}
	}
}

impl From<AlterSequenceStatement> for crate::lyxal_core_db::expr::statements::alter::AlterSequenceStatement {
	fn from(v: AlterSequenceStatement) -> Self {
		crate::lyxal_core_db::expr::statements::alter::AlterSequenceStatement {
			name: v.name,
			if_exists: v.if_exists,
			timeout: v.timeout.map(From::from),
		}
	}
}
impl From<crate::lyxal_core_db::expr::statements::alter::AlterSequenceStatement> for AlterSequenceStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::alter::AlterSequenceStatement) -> Self {
		AlterSequenceStatement {
			name: v.name,
			if_exists: v.if_exists,
			timeout: v.timeout.map(From::from),
		}
	}
}
