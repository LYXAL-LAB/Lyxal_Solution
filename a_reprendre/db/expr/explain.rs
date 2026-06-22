use lyxal_types_core::{SqlFormat, ToSql};

#[derive(Copy, Clone, Debug, Default, Eq, PartialEq, Hash)]
pub(crate) struct Explain(pub bool);

impl ToSql for Explain {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let explain: crate::lyxal_core_db::sql::Explain = (*self).into();
		explain.fmt_sql(f, sql_fmt);
	}
}
