use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::{CoverStmts, EscapeKwFreeIdent};
use crate::db::sql::{Expr, Kind};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct SetStatement {
	pub name: String,
	pub what: Expr,
	pub kind: Option<Kind>,
}

impl ToSql for SetStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "LET ${}", EscapeKwFreeIdent(&self.name));
		if let Some(ref kind) = self.kind {
			write_sql!(f, fmt, ": {}", kind);
		}
		write_sql!(f, fmt, " = {}", CoverStmts(&self.what));
	}
}

impl From<SetStatement> for crate::db::expr::statements::SetStatement {
	fn from(v: SetStatement) -> Self {
		crate::db::expr::statements::SetStatement {
			name: v.name,
			what: v.what.into(),
			kind: v.kind.map(Into::into),
		}
	}
}

impl From<crate::db::expr::statements::SetStatement> for SetStatement {
	fn from(v: crate::db::expr::statements::SetStatement) -> Self {
		SetStatement {
			name: v.name,
			what: v.what.into(),
			kind: v.kind.map(Into::into),
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::db::syn;

	#[test]
	fn check_type() {
		let query = syn::parse("LET $param = 5").unwrap();
		assert_eq!(query.to_sql(), "LET $param = 5;");

		let query = syn::parse("LET $param: number = 5").unwrap();
		assert_eq!(query.to_sql(), "LET $param: number = 5;");
	}
}
