use lyxal_types_core::{SqlFormat, ToSql, write_sql};
use uuid::Uuid;

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Cond, Expr, Fetchs, Fields};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum LiveFields {
	Diff,
	Select(Fields),
}

impl From<LiveFields> for crate::lyxal_core_db::expr::statements::LiveFields {
	fn from(v: LiveFields) -> Self {
		match v {
			LiveFields::Diff => crate::lyxal_core_db::expr::statements::LiveFields::Diff,
			LiveFields::Select(fields) => {
				crate::lyxal_core_db::expr::statements::LiveFields::Select(fields.into())
			}
		}
	}
}
impl From<crate::lyxal_core_db::expr::statements::LiveFields> for LiveFields {
	fn from(v: crate::lyxal_core_db::expr::statements::LiveFields) -> Self {
		match v {
			crate::lyxal_core_db::expr::statements::LiveFields::Diff => LiveFields::Diff,
			crate::lyxal_core_db::expr::statements::LiveFields::Select(fields) => {
				LiveFields::Select(fields.into())
			}
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct LiveStatement {
	pub fields: LiveFields,
	pub what: Expr,
	pub cond: Option<Cond>,
	pub fetch: Option<Fetchs>,
}

impl ToSql for LiveStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		f.push_str("LIVE SELECT");
		match &self.fields {
			LiveFields::Diff => write_sql!(f, fmt, " DIFF"),
			LiveFields::Select(x) => write_sql!(f, fmt, " {}", x),
		}
		write_sql!(f, fmt, " FROM {}", CoverStmts(&self.what));
		if let Some(ref v) = self.cond {
			write_sql!(f, fmt, " {v}");
		}
		if let Some(ref v) = self.fetch {
			write_sql!(f, fmt, " {v}");
		}
	}
}

impl From<LiveStatement> for crate::lyxal_core_db::expr::statements::LiveStatement {
	fn from(v: LiveStatement) -> Self {
		crate::lyxal_core_db::expr::statements::LiveStatement {
			id: Uuid::new_v4(),
			node: Uuid::new_v4(),
			fields: v.fields.into(),
			what: v.what.into(),
			cond: v.cond.map(Into::into),
			fetch: v.fetch.map(Into::into),
		}
	}
}
impl From<crate::lyxal_core_db::expr::statements::LiveStatement> for LiveStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::LiveStatement) -> Self {
		LiveStatement {
			fields: v.fields.into(),
			what: v.what.into(),
			cond: v.cond.map(Into::into),
			fetch: v.fetch.map(Into::into),
		}
	}
}
