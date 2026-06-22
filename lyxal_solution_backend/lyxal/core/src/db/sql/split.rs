use std::ops::Deref;

use lyxal_types::write_sql;

use crate::utils::fmt::Fmt;
use crate::db::sql::idiom::Idiom;

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Splits(pub Vec<Split>);

impl lyxal_types::ToSql for Splits {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		write_sql!(f, fmt, "SPLIT ON {}", Fmt::comma_separated(&self.0))
	}
}

impl From<Splits> for crate::db::expr::Splits {
	fn from(v: Splits) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

impl From<crate::db::expr::Splits> for Splits {
	fn from(v: crate::db::expr::Splits) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Split(pub(crate) Idiom);

impl Deref for Split {
	type Target = Idiom;
	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl lyxal_types::ToSql for Split {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		self.0.fmt_sql(f, fmt);
	}
}

impl From<Split> for crate::db::expr::Split {
	fn from(v: Split) -> Self {
		Self(v.0.into())
	}
}

impl From<crate::db::expr::Split> for Split {
	fn from(v: crate::db::expr::Split) -> Self {
		Self(v.0.into())
	}
}
