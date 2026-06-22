use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::{EscapeKwFreeIdent, Fmt};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum With {
	NoIndex,
	Index(
		#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::db::sql::arbitrary::atleast_one))]
		Vec<String>,
	),
}

impl ToSql for With {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		f.push_str("WITH");
		match self {
			With::NoIndex => f.push_str(" NOINDEX"),
			With::Index(i) => {
				f.push_str(" INDEX ");
				write_sql!(
					f,
					fmt,
					"{}",
					Fmt::comma_separated(i.iter().map(|x| EscapeKwFreeIdent(x)))
				);
			}
		}
	}
}

impl From<With> for crate::db::expr::With {
	fn from(v: With) -> Self {
		match v {
			With::NoIndex => Self::NoIndex,
			With::Index(i) => Self::Index(i),
		}
	}
}
impl From<crate::db::expr::With> for With {
	fn from(v: crate::db::expr::With) -> Self {
		match v {
			crate::db::expr::With::NoIndex => Self::NoIndex,
			crate::db::expr::With::Index(i) => Self::Index(i),
		}
	}
}
