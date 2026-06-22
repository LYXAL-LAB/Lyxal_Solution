use lyxal_types::{SqlFormat, ToSql};

use crate::db::expr::Expr;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum UseStatement {
	Ns(Expr),
	Db(Expr),
	NsDb(Expr, Expr),
	Default,
}

impl ToSql for UseStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let stmt: crate::db::sql::statements::r#use::UseStatement = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
