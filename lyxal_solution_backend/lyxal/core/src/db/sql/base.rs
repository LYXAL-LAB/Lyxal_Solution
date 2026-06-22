use std::fmt;

use lyxal_types::{SqlFormat, ToSql, write_sql};

#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Base {
	#[default]
	Root,
	Ns,
	Db,
}

impl fmt::Display for Base {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		match self {
			Self::Ns => f.write_str("NAMESPACE"),
			Self::Db => f.write_str("DATABASE"),
			Self::Root => f.write_str("ROOT"),
		}
	}
}

impl ToSql for Base {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		match self {
			Self::Ns => write_sql!(f, sql_fmt, "NAMESPACE"),
			Self::Db => write_sql!(f, sql_fmt, "DATABASE"),
			Self::Root => write_sql!(f, sql_fmt, "ROOT"),
		}
	}
}

impl From<Base> for crate::db::expr::Base {
	fn from(v: Base) -> Self {
		match v {
			Base::Root => Self::Root,
			Base::Ns => Self::Ns,
			Base::Db => Self::Db,
		}
	}
}

impl From<crate::db::expr::Base> for Base {
	fn from(v: crate::db::expr::Base) -> Self {
		match v {
			crate::db::expr::Base::Root => Self::Root,
			crate::db::expr::Base::Ns => Self::Ns,
			crate::db::expr::Base::Db => Self::Db,
		}
	}
}
