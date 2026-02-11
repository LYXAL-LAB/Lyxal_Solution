//! REMOVE CREDENTIAL SQL statement

use surrealdb_types::{SqlFormat, ToSql, write_sql};
use crate::fmt::CoverStmts;
use crate::sql::Expr;

/// REMOVE CREDENTIAL statement SQL AST
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RemoveCredentialStatement {
    pub name: Expr,
    pub if_exists: bool,
}

impl ToSql for RemoveCredentialStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        f.push_str("REMOVE CREDENTIAL");
        if self.if_exists {
            f.push_str(" IF EXISTS");
        }
        write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
    }
}

// Conversion from sql:: to expr::
impl From<RemoveCredentialStatement> for crate::expr::statements::RemoveCredentialStatement {
    fn from(v: RemoveCredentialStatement) -> Self {
        crate::expr::statements::RemoveCredentialStatement {
            name: v.name.into(),
            if_exists: v.if_exists,
        }
    }
}

// Conversion from expr:: to sql::
impl From<crate::expr::statements::RemoveCredentialStatement> for RemoveCredentialStatement {
    fn from(v: crate::expr::statements::RemoveCredentialStatement) -> Self {
        RemoveCredentialStatement {
            name: v.name.into(),
            if_exists: v.if_exists,
        }
    }
}
