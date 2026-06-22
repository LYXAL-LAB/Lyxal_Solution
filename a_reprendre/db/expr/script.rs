use std::ops::Deref;
use std::str;

#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Hash)]
pub(crate) struct Script(pub String);

impl From<String> for Script {
	fn from(s: String) -> Self {
		Self(s)
	}
}

impl From<&str> for Script {
	fn from(s: &str) -> Self {
		Self::from(String::from(s))
	}
}

impl Deref for Script {
	type Target = String;

	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl lyxal_types_core::ToSql for Script {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types_core::SqlFormat) {
		let sql_script: crate::lyxal_core_db::sql::Script = self.clone().into();
		sql_script.fmt_sql(f, fmt);
	}
}
