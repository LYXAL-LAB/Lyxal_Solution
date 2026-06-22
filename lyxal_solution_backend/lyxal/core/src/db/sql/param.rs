use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::EscapeKwFreeIdent;

#[derive(Clone, Debug, Default, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct Param(String);

impl Param {
	/// Create a new identifier
	///
	/// This function checks if the string has a null byte, returns None if it
	/// has.
	pub fn new(str: String) -> Self {
		Self(str)
	}

	// Convert into a string.
	pub fn into_string(self) -> String {
		self.0
	}
}

impl ToSql for Param {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "${}", EscapeKwFreeIdent(&self.0))
	}
}

impl From<Param> for crate::db::expr::Param {
	fn from(v: Param) -> Self {
		Self::new(v.0)
	}
}

impl From<crate::db::expr::Param> for Param {
	fn from(v: crate::db::expr::Param) -> Self {
		Self::new(v.into_string())
	}
}
