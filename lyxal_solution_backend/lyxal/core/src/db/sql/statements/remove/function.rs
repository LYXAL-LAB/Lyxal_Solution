use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::EscapeKwFreeIdent;

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct RemoveFunctionStatement {
	pub name: String,
	pub if_exists: bool,
}

impl ToSql for RemoveFunctionStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		// Bypass ident display since we don't want backticks arround the ident.
		write_sql!(f, fmt, "REMOVE FUNCTION");
		if self.if_exists {
			write_sql!(f, fmt, " IF EXISTS");
		}
		write_sql!(f, fmt, " fn::{}", EscapeKwFreeIdent(&self.name));
	}
}

impl From<RemoveFunctionStatement> for crate::db::expr::statements::RemoveFunctionStatement {
	fn from(v: RemoveFunctionStatement) -> Self {
		crate::db::expr::statements::RemoveFunctionStatement {
			name: v.name,
			if_exists: v.if_exists,
		}
	}
}
impl From<crate::db::expr::statements::RemoveFunctionStatement> for RemoveFunctionStatement {
	fn from(v: crate::db::expr::statements::RemoveFunctionStatement) -> Self {
		RemoveFunctionStatement {
			name: v.name,
			if_exists: v.if_exists,
		}
	}
}
