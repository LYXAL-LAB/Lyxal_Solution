use surrealdb_types::{SqlFormat, ToSql, write_sql};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct UseStatement {
	pub ns: Option<String>,
	pub db: Option<String>,
}

impl ToSql for UseStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		f.push_str("USE");
		if let Some(ref v) = self.ns {
			write_sql!(f, fmt, " NS {v}");
		}
		if let Some(ref v) = self.db {
			write_sql!(f, fmt, " DB {v}");
		}
	}
}

impl From<UseStatement> for crate::expr::statements::UseStatement {
	fn from(v: UseStatement) -> Self {
		Self {
			ns: v.ns,
			db: v.db,
		}
	}
}

impl From<crate::expr::statements::UseStatement> for UseStatement {
	fn from(v: crate::expr::statements::UseStatement) -> Self {
		Self {
			ns: v.ns,
			db: v.db,
		}
	}
}
