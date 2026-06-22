use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::EscapeIdent;

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct RemoveModelStatement {
	pub name: String,
	pub version: String,
	pub if_exists: bool,
}

impl ToSql for RemoveModelStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "REMOVE MODEL");
		if self.if_exists {
			write_sql!(f, sql_fmt, " IF EXISTS");
		}
		write_sql!(f, sql_fmt, " ml::{}<{}>", EscapeIdent(&self.name), self.version);
	}
}

impl From<RemoveModelStatement> for crate::lyxal_core_db::expr::statements::RemoveModelStatement {
	fn from(v: RemoveModelStatement) -> Self {
		crate::lyxal_core_db::expr::statements::RemoveModelStatement {
			name: v.name,
			if_exists: v.if_exists,
			version: v.version,
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::RemoveModelStatement> for RemoveModelStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::RemoveModelStatement) -> Self {
		RemoveModelStatement {
			name: v.name,
			if_exists: v.if_exists,
			version: v.version,
		}
	}
}
