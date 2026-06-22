use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::CoverStmts;
use crate::db::sql::{Block, Expr, Param};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct ForeachStatement {
	pub param: Param,
	pub range: Expr,
	pub block: Block,
}

impl ToSql for ForeachStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "FOR {} IN {} {}", self.param, CoverStmts(&self.range), self.block)
	}
}

impl From<ForeachStatement> for crate::db::expr::statements::ForeachStatement {
	fn from(v: ForeachStatement) -> Self {
		Self {
			param: v.param.into(),
			range: v.range.into(),
			block: v.block.into(),
		}
	}
}

impl From<crate::db::expr::statements::ForeachStatement> for ForeachStatement {
	fn from(v: crate::db::expr::statements::ForeachStatement) -> Self {
		Self {
			param: v.param.into(),
			range: v.range.into(),
			block: v.block.into(),
		}
	}
}
