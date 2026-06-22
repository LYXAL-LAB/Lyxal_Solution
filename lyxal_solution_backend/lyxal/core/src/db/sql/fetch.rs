use std::ops::Deref;

use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::Fmt;
use crate::db::sql::Expr;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Fetchs(
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::db::sql::arbitrary::atleast_one))]
	pub(crate) Vec<Fetch>,
);

impl Deref for Fetchs {
	type Target = Vec<Fetch>;
	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl ToSql for Fetchs {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "FETCH {}", Fmt::comma_separated(&self.0))
	}
}

impl From<Fetchs> for crate::db::expr::Fetchs {
	fn from(v: Fetchs) -> Self {
		Self::new(v.0.into_iter().map(Into::into).collect())
	}
}
impl From<crate::db::expr::Fetchs> for Fetchs {
	fn from(v: crate::db::expr::Fetchs) -> Self {
		Self(v.into_iter().map(Into::into).collect())
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Fetch(pub(crate) Expr);

impl ToSql for Fetch {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.0.fmt_sql(f, fmt);
	}
}

impl From<Fetch> for crate::db::expr::Fetch {
	fn from(v: Fetch) -> Self {
		crate::db::expr::Fetch(v.0.into())
	}
}

impl From<crate::db::expr::Fetch> for Fetch {
	fn from(v: crate::db::expr::Fetch) -> Self {
		Fetch(v.0.into())
	}
}
