use revision::revisioned;
use lyxal_types::{SqlFormat, ToSql};

use crate::db::expr::language::Language;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
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
		let stmt: crate::db::sql::filter::Filter = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
