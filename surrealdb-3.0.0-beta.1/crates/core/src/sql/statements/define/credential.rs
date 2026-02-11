//! DEFINE CREDENTIAL SQL statement

use surrealdb_types::{SqlFormat, ToSql, write_sql};
use super::DefineKind;
use crate::fmt::CoverStmts;
use crate::sql::Expr;
use crate::catalog::Permission;

/// Type of credential
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum CredentialType {
    #[default]
    Api,
    Webhook,
    OAuth,
    Jwt,
    Custom,
}

impl ToSql for CredentialType {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::Api => f.push_str("API"),
            Self::Webhook => f.push_str("WEBHOOK"),
            Self::OAuth => f.push_str("OAUTH"),
            Self::Jwt => f.push_str("JWT"),
            Self::Custom => f.push_str("CUSTOM"),
        }
    }
}

/// Algorithm for cryptographic operations
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum CredentialAlgorithm {
    #[default]
    HmacSha256,
    HmacSha512,
    Rsa,
    Ed25519,
}

impl ToSql for CredentialAlgorithm {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::HmacSha256 => f.push_str("HMAC_SHA256"),
            Self::HmacSha512 => f.push_str("HMAC_SHA512"),
            Self::Rsa => f.push_str("RSA"),
            Self::Ed25519 => f.push_str("ED25519"),
        }
    }
}

/// DEFINE CREDENTIAL statement SQL AST
#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct DefineCredentialStatement {
    pub kind: DefineKind,
    pub name: Expr,
    pub credential_type: CredentialType,
    pub value: Expr,
    pub algorithm: Option<CredentialAlgorithm>,
    pub header: Option<Expr>,
    pub expires: Option<Expr>,
    pub refresh: Option<Expr>,
    pub comment: Option<Expr>,
    pub permissions: Permission,
}

impl ToSql for DefineCredentialStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        f.push_str("DEFINE CREDENTIAL");
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => f.push_str(" OVERWRITE"),
            DefineKind::IfNotExists => f.push_str(" IF NOT EXISTS"),
        }
        write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
        f.push_str(" TYPE ");
        self.credential_type.fmt_sql(f, sql_fmt);
        // Never show the actual value - security
        f.push_str(" VALUE [REDACTED]");
        if let Some(ref alg) = self.algorithm {
            f.push_str(" ALGORITHM ");
            alg.fmt_sql(f, sql_fmt);
        }
        if let Some(ref header) = self.header {
            write_sql!(f, sql_fmt, " HEADER {}", CoverStmts(header));
        }
        if let Some(ref expires) = self.expires {
            write_sql!(f, sql_fmt, " EXPIRES {}", CoverStmts(expires));
        }
        if self.refresh.is_some() {
            f.push_str(" REFRESH [REDACTED]");
        }
        if let Some(ref comment) = self.comment {
            write_sql!(f, sql_fmt, " COMMENT {}", CoverStmts(comment));
        }
    }
}

// Conversion from sql:: to expr::
impl From<DefineCredentialStatement> for crate::expr::statements::DefineCredentialStatement {
    fn from(v: DefineCredentialStatement) -> Self {
        crate::expr::statements::DefineCredentialStatement {
            kind: v.kind.into(),
            name: v.name.into(),
            credential_type: v.credential_type.into(),
            value: v.value.into(),
            algorithm: v.algorithm.map(|a| a.into()),
            header: v.header.map(|h| h.into()),
            expires: v.expires.map(|e| e.into()),
            refresh: v.refresh.map(|r| r.into()),
            comment: v.comment.map(|c| c.into()),
            permissions: v.permissions,
        }
    }
}

impl From<CredentialType> for crate::expr::statements::define::CredentialType {
    fn from(v: CredentialType) -> Self {
        match v {
            CredentialType::Api => Self::Api,
            CredentialType::Webhook => Self::Webhook,
            CredentialType::OAuth => Self::OAuth,
            CredentialType::Jwt => Self::Jwt,
            CredentialType::Custom => Self::Custom,
        }
    }
}

impl From<CredentialAlgorithm> for crate::expr::statements::define::CredentialAlgorithm {
    fn from(v: CredentialAlgorithm) -> Self {
        match v {
            CredentialAlgorithm::HmacSha256 => Self::HmacSha256,
            CredentialAlgorithm::HmacSha512 => Self::HmacSha512,
            CredentialAlgorithm::Rsa => Self::Rsa,
            CredentialAlgorithm::Ed25519 => Self::Ed25519,
        }
    }
}

// Conversion from expr:: to sql::
impl From<crate::expr::statements::DefineCredentialStatement> for DefineCredentialStatement {
    fn from(v: crate::expr::statements::DefineCredentialStatement) -> Self {
        DefineCredentialStatement {
            kind: v.kind.into(),
            name: v.name.into(),
            credential_type: v.credential_type.into(),
            value: v.value.into(),
            algorithm: v.algorithm.map(|a| a.into()),
            header: v.header.map(|h| h.into()),
            expires: v.expires.map(|e| e.into()),
            refresh: v.refresh.map(|r| r.into()),
            comment: v.comment.map(|c| c.into()),
            permissions: v.permissions,
        }
    }
}

impl From<crate::expr::statements::define::CredentialType> for CredentialType {
    fn from(v: crate::expr::statements::define::CredentialType) -> Self {
        match v {
            crate::expr::statements::define::CredentialType::Api => Self::Api,
            crate::expr::statements::define::CredentialType::Webhook => Self::Webhook,
            crate::expr::statements::define::CredentialType::OAuth => Self::OAuth,
            crate::expr::statements::define::CredentialType::Jwt => Self::Jwt,
            crate::expr::statements::define::CredentialType::Custom => Self::Custom,
        }
    }
}

impl From<crate::expr::statements::define::CredentialAlgorithm> for CredentialAlgorithm {
    fn from(v: crate::expr::statements::define::CredentialAlgorithm) -> Self {
        match v {
            crate::expr::statements::define::CredentialAlgorithm::HmacSha256 => Self::HmacSha256,
            crate::expr::statements::define::CredentialAlgorithm::HmacSha512 => Self::HmacSha512,
            crate::expr::statements::define::CredentialAlgorithm::Rsa => Self::Rsa,
            crate::expr::statements::define::CredentialAlgorithm::Ed25519 => Self::Ed25519,
        }
    }
}
