use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::Expr;

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum UseStatement {
	Ns(Expr),
	Db(Expr),
	NsDb(Expr, Expr),
	Default,
}

impl ToSql for UseStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		f.push_str("USE");
		match self {
			UseStatement::Ns(ns) => write_sql!(f, fmt, " NS {}", CoverStmts(ns)),
			UseStatement::Db(db) => write_sql!(f, fmt, " DB {}", CoverStmts(db)),
			UseStatement::NsDb(ns, db) => {
				write_sql!(f, fmt, " NS {} DB {}", CoverStmts(ns), CoverStmts(db))
			}
			UseStatement::Default => {
				write_sql!(f, fmt, " DEFAULT")
			}
		}
	}
}

impl From<UseStatement> for crate::lyxal_core_db::expr::statements::UseStatement {
	fn from(v: UseStatement) -> Self {
		match v {
			UseStatement::Ns(ns) => crate::lyxal_core_db::expr::statements::UseStatement::Ns(ns.into()),
			UseStatement::Db(db) => crate::lyxal_core_db::expr::statements::UseStatement::Db(db.into()),
			UseStatement::NsDb(ns, db) => {
				crate::lyxal_core_db::expr::statements::UseStatement::NsDb(ns.into(), db.into())
			}
			UseStatement::Default => crate::lyxal_core_db::expr::statements::UseStatement::Default,
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::UseStatement> for UseStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::UseStatement) -> Self {
		match v {
			crate::lyxal_core_db::expr::statements::UseStatement::Ns(ns) => UseStatement::Ns(ns.into()),
			crate::lyxal_core_db::expr::statements::UseStatement::Db(db) => UseStatement::Db(db.into()),
			crate::lyxal_core_db::expr::statements::UseStatement::NsDb(ns, db) => {
				UseStatement::NsDb(ns.into(), db.into())
			}
			crate::lyxal_core_db::expr::statements::UseStatement::Default => UseStatement::Default,
		}
	}
}
