use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use super::DefineKind;
use crate::lyxal_core_utils::fmt::{Fmt};
use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Expr, Index, Literal};

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct DefineIndexStatement {
	pub kind: DefineKind,
	pub name: Expr,
	pub what: Expr,
	pub cols: Vec<Expr>,
	pub index: Index,
	pub comment: Expr,
	pub concurrently: bool,
}

impl ToSql for DefineIndexStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "DEFINE INDEX");
		match self.kind {
			DefineKind::Default => {}
			DefineKind::Overwrite => write_sql!(f, sql_fmt, " OVERWRITE"),
			DefineKind::IfNotExists => write_sql!(f, sql_fmt, " IF NOT EXISTS"),
		}
		write_sql!(f, sql_fmt, " {} ON {}", &self.name, &self.what);
		if !self.cols.is_empty() {
			write_sql!(
				f,
				sql_fmt,
				" FIELDS {}",
				Fmt::comma_separated(self.cols.iter().map(CoverStmts))
			);
		}
		if Index::Idx != self.index {
			write_sql!(f, sql_fmt, " {}", self.index);
		}
		if !matches!(self.comment, Expr::Literal(Literal::None)) {
			write_sql!(f, sql_fmt, " COMMENT {}", &self.comment);
		}
		if self.concurrently {
			write_sql!(f, sql_fmt, " CONCURRENTLY");
		}
	}
}

impl From<DefineIndexStatement> for crate::lyxal_core_db::expr::statements::DefineIndexStatement {
	fn from(v: DefineIndexStatement) -> Self {
		Self {
			kind: v.kind.into(),
			name: v.name.into(),
			what: v.what.into(),
			cols: v.cols.into_iter().map(From::from).collect(),
			index: v.index.into(),
			comment: v.comment.into(),
			concurrently: v.concurrently,
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::DefineIndexStatement> for DefineIndexStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::DefineIndexStatement) -> Self {
		Self {
			kind: v.kind.into(),
			name: v.name.into(),
			what: v.what.into(),
			cols: v.cols.into_iter().map(From::from).collect(),
			index: v.index.into(),
			comment: v.comment.into(),
			concurrently: v.concurrently,
		}
	}
}
