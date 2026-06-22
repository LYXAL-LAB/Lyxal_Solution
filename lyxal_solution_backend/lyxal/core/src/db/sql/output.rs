use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::Field;
use crate::db::sql::field::{Fields, Selector};

#[derive(Clone, Debug, Default, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum Output {
	#[default]
	None,
	Null,
	Diff,
	After,
	Before,
	Fields(Fields),
}

impl ToSql for Output {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		f.push_str("RETURN ");
		match self {
			// TODO: This none here is really annoying for parsing and formatting.
			// it conflicts with value NONE. Ideally we should find some way to differentiate with
			// `NONE` the clause and `NONE` the value.
			Self::None => f.push_str("NONE"),
			Self::Null => f.push_str("NULL"),
			Self::Diff => f.push_str("DIFF"),
			Self::After => f.push_str("AFTER"),
			Self::Before => f.push_str("BEFORE"),
			Self::Fields(v) => {
				// We need to escape a possible `RETURN NONE` where `NONE` is a value
				match v {
					Fields::Select(fields) => {
						let mut iter = fields.iter();
						match iter.next() {
							Some(Field::Single(Selector {
								expr,
								alias,
							})) => {
								// Check for a expression with none on the left like `NONE + 1`
								// which will be mistaken for the `NONE` clause formatted above.
								let has_left_none = expr.has_left_none_null();
								if has_left_none {
									f.push('(');
									expr.fmt_sql(f, fmt);
									f.push(')');
								} else {
									CoverStmts(expr).fmt_sql(f, fmt);
								}
								if let Some(alias) = alias {
									write_sql!(f, fmt, " AS {alias}");
								}
							}
							Some(x) => {
								x.fmt_sql(f, fmt);
							}
							None => {}
						}

						for x in iter {
							write_sql!(f, fmt, ", {x}")
						}
					}
					x => x.fmt_sql(f, fmt),
				}
			}
		}
	}
}

impl From<Output> for crate::db::expr::Output {
	fn from(v: Output) -> Self {
		match v {
			Output::None => Self::None,
			Output::Null => Self::Null,
			Output::Diff => Self::Diff,
			Output::After => Self::After,
			Output::Before => Self::Before,
			Output::Fields(v) => Self::Fields(v.into()),
		}
	}
}

impl From<crate::db::expr::Output> for Output {
	fn from(v: crate::db::expr::Output) -> Self {
		match v {
			crate::db::expr::Output::None => Self::None,
			crate::db::expr::Output::Null => Self::Null,
			crate::db::expr::Output::Diff => Self::Diff,
			crate::db::expr::Output::After => Self::After,
			crate::db::expr::Output::Before => Self::Before,
			crate::db::expr::Output::Fields(v) => Self::Fields(v.into()),
		}
	}
}
