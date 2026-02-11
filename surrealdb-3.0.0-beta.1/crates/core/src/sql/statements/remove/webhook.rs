//! REMOVE WEBHOOK SQL statement

use surrealdb_types::{SqlFormat, ToSql, write_sql};

use crate::fmt::CoverStmts;
use crate::sql::{Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct RemoveWebhookStatement {
    pub name: Expr,
    pub if_exists: bool,
}

impl Default for RemoveWebhookStatement {
    fn default() -> Self {
        Self {
            name: Expr::Literal(Literal::None),
            if_exists: false,
        }
    }
}

impl ToSql for RemoveWebhookStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        write_sql!(f, sql_fmt, "REMOVE WEBHOOK");
        if self.if_exists {
            write_sql!(f, sql_fmt, " IF EXISTS");
        }
        write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
    }
}

impl From<RemoveWebhookStatement> for crate::expr::statements::RemoveWebhookStatement {
    fn from(v: RemoveWebhookStatement) -> Self {
        crate::expr::statements::RemoveWebhookStatement {
            name: v.name.into(),
            if_exists: v.if_exists,
        }
    }
}

impl From<crate::expr::statements::RemoveWebhookStatement> for RemoveWebhookStatement {
    fn from(v: crate::expr::statements::RemoveWebhookStatement) -> Self {
        RemoveWebhookStatement {
            name: v.name.into(),
            if_exists: v.if_exists,
        }
    }
}
