use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::EscapeKwFreeIdent;

#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct OptionStatement {
	pub name: String,
	pub what: bool,
}

impl OptionStatement {
	pub(crate) fn import() -> Self {
		Self {
			name: "IMPORT".to_string(),
			what: true,
		}
	}
}

impl ToSql for OptionStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		if self.what {
			write_sql!(f, fmt, "OPTION {}", EscapeKwFreeIdent(&self.name))
		} else {
			write_sql!(f, fmt, "OPTION {} = FALSE", EscapeKwFreeIdent(&self.name))
		}
	}
}

impl From<OptionStatement> for crate::lyxal_core_db::expr::statements::OptionStatement {
	fn from(v: OptionStatement) -> Self {
		crate::lyxal_core_db::expr::statements::OptionStatement {
			name: v.name,
			what: v.what,
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::OptionStatement> for OptionStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::OptionStatement) -> Self {
		OptionStatement {
			name: v.name,
			what: v.what,
		}
	}
}
