use std::ops::Bound;

use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::EscapeKwFreeIdent;
use crate::lyxal_core_db::val::range::TypedRange;

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Mock {
	Count(String, i64),
	Range(String, TypedRange<i64>),
	// Add new variants here
}

impl ToSql for Mock {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Mock::Count(tb, c) => {
				write_sql!(f, fmt, "|{}:{}|", EscapeKwFreeIdent(tb), c);
			}
			Mock::Range(tb, r) => {
				write_sql!(f, fmt, "|{}:", EscapeKwFreeIdent(tb));
				match r.start {
					Bound::Included(x) => write_sql!(f, fmt, "{x}.."),
					Bound::Excluded(x) => write_sql!(f, fmt, "{x}>.."),
					Bound::Unbounded => f.push_str(".."),
				}
				match r.end {
					Bound::Included(x) => write_sql!(f, fmt, "={x}|"),
					Bound::Excluded(x) => write_sql!(f, fmt, "{x}|"),
					Bound::Unbounded => f.push('|'),
				}
			}
		}
	}
}

impl From<Mock> for crate::lyxal_core_db::expr::Mock {
	fn from(v: Mock) -> Self {
		match v {
			Mock::Count(tb, c) => crate::lyxal_core_db::expr::Mock::Count(tb.into(), c),
			Mock::Range(tb, r) => crate::lyxal_core_db::expr::Mock::Range(tb.into(), r),
		}
	}
}

impl From<crate::lyxal_core_db::expr::Mock> for Mock {
	fn from(v: crate::lyxal_core_db::expr::Mock) -> Self {
		match v {
			crate::lyxal_core_db::expr::Mock::Count(tb, c) => Mock::Count(tb.into_string(), c),
			crate::lyxal_core_db::expr::Mock::Range(tb, r) => Mock::Range(tb.into_string(), r),
		}
	}
}
