use serde::{Deserialize, Serialize};
use storekey::{BorrowDecode, Encode};
use lyxal_types::{SqlFormat, ToSql};

#[derive(
	Clone,
	Debug,
	Default,
	Eq,
	PartialEq,
	Serialize,
	PartialOrd,
	Deserialize,
	Hash,
	Encode,
	BorrowDecode,
)]
pub enum Dir {
	/// `<-`
	In,
	/// `->`
	Out,
	/// `<->`
	#[default]
	Both,
}

impl ToSql for Dir {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let dir: crate::db::sql::Dir = self.clone().into();
		dir.fmt_sql(f, sql_fmt);
	}
}
