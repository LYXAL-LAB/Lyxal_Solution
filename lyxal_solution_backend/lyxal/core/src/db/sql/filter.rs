use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::QuoteStr;
use crate::db::sql::language::Language;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Filter {
	Ascii,
	EdgeNgram(u16, u16),
	Lowercase,
	Ngram(u16, u16),
	Snowball(Language),
	Uppercase,
	Mapper(String),
}

impl ToSql for Filter {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Ascii => f.push_str("ASCII"),
			Self::EdgeNgram(min, max) => write_sql!(f, fmt, "EDGENGRAM({min},{max})"),
			Self::Lowercase => f.push_str("LOWERCASE"),
			Self::Ngram(min, max) => write_sql!(f, fmt, "NGRAM({min},{max})"),
			Self::Snowball(lang) => write_sql!(f, fmt, "SNOWBALL({lang})"),
			Self::Uppercase => f.push_str("UPPERCASE"),
			Self::Mapper(path) => write_sql!(f, fmt, "MAPPER({})", QuoteStr(path)),
		}
	}
}

impl From<Filter> for crate::db::expr::Filter {
	fn from(v: Filter) -> Self {
		match v {
			Filter::Ascii => Self::Ascii,
			Filter::EdgeNgram(min, max) => Self::EdgeNgram(min, max),
			Filter::Lowercase => Self::Lowercase,
			Filter::Ngram(min, max) => Self::Ngram(min, max),
			Filter::Snowball(lang) => Self::Snowball(lang.into()),
			Filter::Uppercase => Self::Uppercase,
			Filter::Mapper(path) => Self::Mapper(path),
		}
	}
}

impl From<crate::db::expr::Filter> for Filter {
	fn from(v: crate::db::expr::Filter) -> Self {
		match v {
			crate::db::expr::Filter::Ascii => Self::Ascii,
			crate::db::expr::Filter::EdgeNgram(min, max) => Self::EdgeNgram(min, max),
			crate::db::expr::Filter::Lowercase => Self::Lowercase,
			crate::db::expr::Filter::Ngram(min, max) => Self::Ngram(min, max),
			crate::db::expr::Filter::Snowball(lang) => Self::Snowball(lang.into()),
			crate::db::expr::Filter::Uppercase => Self::Uppercase,
			crate::db::expr::Filter::Mapper(path) => Self::Mapper(path),
		}
	}
}
