use surrealdb_types::{SqlFormat, ToSql, write_sql};
use super::DefineKind;
use crate::fmt::CoverStmts;
use crate::sql::base::Base;
use crate::sql::{Expr, Literal};

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct DefineSchedulerStatement {
    pub kind: DefineKind,
    pub name: Expr,
    pub base: Base,
    pub enabled: bool,
    pub action: Expr,
    pub comment: Expr,
}

impl ToSql for DefineSchedulerStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        f.push_str("DEFINE SCHEDULER");
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => f.push_str(" OVERWRITE"),
            DefineKind::IfNotExists => f.push_str(" IF NOT EXISTS"),
        }
        write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
        write_sql!(f, sql_fmt, " ON {}", self.base);
        write_sql!(f, sql_fmt, " ACTION {}", CoverStmts(&self.action));
        if !self.enabled {
            f.push_str(" DISABLED");
        }
        if !matches!(self.comment, Expr::Literal(Literal::None)) {
            write_sql!(f, sql_fmt, " COMMENT {}", CoverStmts(&self.comment));
        }
    }
}

