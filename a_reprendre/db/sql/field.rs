use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::{Fmt};
use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Expr, Idiom};

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(::arbitrary::Arbitrary))]
pub(crate) enum Fields {
	/// Fields had the `VALUE` clause and should only return the given selector
	Value(Box<Selector>),
	/// Normal fields where an object with the selected fields is expected
	Select(
		#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::atleast_one))]
		Vec<Field>,
	),
}

impl Fields {
	// Shorthand for `Fields::Select(vec![Field::all])`
	pub fn all() -> Fields {
		Fields::Select(vec![Field::All])
	}

	pub fn contains_all(&self) -> bool {
		match self {
			Fields::Value(_) => false,
			Fields::Select(fields) => fields.iter().any(|x| matches!(x, Field::All)),
		}
	}
}

impl From<Fields> for crate::lyxal_core_db::expr::field::Fields {
	fn from(v: Fields) -> Self {
		match v {
			Fields::Value(x) => crate::lyxal_core_db::expr::field::Fields::Value(Box::new((*x).into())),
			Fields::Select(x) => {
				crate::lyxal_core_db::expr::field::Fields::Select(x.into_iter().map(From::from).collect())
			}
		}
	}
}

impl From<crate::lyxal_core_db::expr::field::Fields> for Fields {
	fn from(v: crate::lyxal_core_db::expr::field::Fields) -> Self {
		match v {
			crate::lyxal_core_db::expr::field::Fields::Value(x) => Fields::Value(Box::new((*x).into())),
			crate::lyxal_core_db::expr::field::Fields::Select(x) => {
				Fields::Select(x.into_iter().map(From::from).collect())
			}
		}
	}
}

impl ToSql for Fields {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Fields::Value(v) => {
				f.push_str("VALUE ");
				v.fmt_sql(f, fmt);
			}
			Fields::Select(x) => write_sql!(f, fmt, "{}", Fmt::comma_separated(x)),
		}
	}
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum Field {
	/// The `*` in `SELECT * FROM ...`
	#[default]
	All,
	/// The 'rating' in `SELECT rating FROM ...`
	Single(Selector),
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct Selector {
	pub expr: Expr,
	pub alias: Option<Idiom>,
}

impl ToSql for Field {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::All => f.push('*'),
			Self::Single(s) => s.fmt_sql(f, fmt),
		}
	}
}

impl From<Field> for crate::lyxal_core_db::expr::field::Field {
	fn from(v: Field) -> Self {
		match v {
			Field::All => Self::All,
			Field::Single(s) => crate::lyxal_core_db::expr::field::Field::Single(s.into()),
		}
	}
}

impl From<crate::lyxal_core_db::expr::field::Field> for Field {
	fn from(v: crate::lyxal_core_db::expr::field::Field) -> Self {
		match v {
			crate::lyxal_core_db::expr::field::Field::All => Self::All,
			crate::lyxal_core_db::expr::field::Field::Single(s) => Self::Single(s.into()),
		}
	}
}

impl ToSql for Selector {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "{}", &self.expr);
		if let Some(alias) = &self.alias {
			f.push_str(" AS ");
			alias.fmt_sql(f, fmt);
		}
	}
}

impl From<Selector> for crate::lyxal_core_db::expr::field::Selector {
	fn from(v: Selector) -> Self {
		crate::lyxal_core_db::expr::field::Selector {
			expr: v.expr.into(),
			alias: v.alias.map(Into::into),
		}
	}
}

impl From<crate::lyxal_core_db::expr::field::Selector> for Selector {
	fn from(v: crate::lyxal_core_db::expr::field::Selector) -> Self {
		Selector {
			expr: v.expr.into(),
			alias: v.alias.map(Into::into),
		}
	}
}
