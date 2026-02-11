//! DEFINE CREDENTIAL statement
//!
//! Syntax:
//!   DEFINE CREDENTIAL <name>
//!     TYPE <API | WEBHOOK | OAUTH | JWT | CUSTOM>
//!     VALUE <expr>
//!     [ALGORITHM <HMAC_SHA256 | HMAC_SHA512 | RSA | ED25519>]
//!     [HEADER <string>]
//!     [EXPIRES <duration>]
//!     [REFRESH <expr>]
//!     [IF NOT EXISTS | OVERWRITE]
//!     [COMMENT <string>];

use std::fmt::{self, Display};

use anyhow::{Result, bail};
use reblessive::tree::Stk;

use super::DefineKind;
use crate::catalog::providers::{DatabaseProvider, NamespaceProvider};
use crate::catalog::Permission;
use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::err::Error;
use crate::expr::{Base, Expr, FlowResultExt as _};
use crate::iam::{Action, ResourceKind};
use crate::val::Value;

/// Type of credential
#[derive(Clone, Debug, Eq, PartialEq, Hash, Default)]
pub enum CredentialType {
    /// API key for outgoing API calls
    #[default]
    Api,
    /// Webhook signing secret for incoming verification
    Webhook,
    /// OAuth2 tokens (access + refresh)
    OAuth,
    /// JWT signing/verification key
    Jwt,
    /// Custom credential type
    Custom,
}

impl Display for CredentialType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Api => write!(f, "API"),
            Self::Webhook => write!(f, "WEBHOOK"),
            Self::OAuth => write!(f, "OAUTH"),
            Self::Jwt => write!(f, "JWT"),
            Self::Custom => write!(f, "CUSTOM"),
        }
    }
}

/// Algorithm for cryptographic operations
#[derive(Clone, Debug, Eq, PartialEq, Hash, Default)]
pub enum CredentialAlgorithm {
    #[default]
    HmacSha256,
    HmacSha512,
    Rsa,
    Ed25519,
}

impl Display for CredentialAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::HmacSha256 => write!(f, "HMAC_SHA256"),
            Self::HmacSha512 => write!(f, "HMAC_SHA512"),
            Self::Rsa => write!(f, "RSA"),
            Self::Ed25519 => write!(f, "ED25519"),
        }
    }
}

/// DEFINE CREDENTIAL statement
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
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

impl DefineCredentialStatement {
    /// Process this type returning a computed simple Value
    #[instrument(level = "trace", name = "DefineCredentialStatement::compute", skip_all)]
    pub(crate) async fn compute(
        &self,
        stk: &mut Stk,
        ctx: &FrozenContext,
        opt: &Options,
        _doc: Option<&CursorDoc>,
    ) -> Result<Value> {
        // Allowed to run?
        opt.is_allowed(Action::Edit, ResourceKind::Parameter, &Base::Db)?;

        // Get credential name
        let name: String = stk
            .run(|stk| self.name.compute(stk, ctx, opt, None))
            .await
            .catch_return()?
            .cast_to()?;

        // Get credential value (will be encrypted before storage)
        let value: String = stk
            .run(|stk| self.value.compute(stk, ctx, opt, None))
            .await
            .catch_return()?
            .cast_to()?;

        // Get optional header
        let header: Option<String> = if let Some(ref h) = self.header {
            Some(
                stk.run(|stk| h.compute(stk, ctx, opt, None))
                    .await
                    .catch_return()?
                    .cast_to()?,
            )
        } else {
            None
        };

        // Get optional expires duration
        let expires: Option<std::time::Duration> = if let Some(ref e) = self.expires {
            let v = stk.run(|stk| e.compute(stk, ctx, opt, None)).await.catch_return()?;
            match v {
                Value::Duration(d) => Some(d.into()),
                _ => None,
            }
        } else {
            None
        };

        // Get optional refresh token
        let refresh: Option<String> = if let Some(ref r) = self.refresh {
            Some(
                stk.run(|stk| r.compute(stk, ctx, opt, None))
                    .await
                    .catch_return()?
                    .cast_to()?,
            )
        } else {
            None
        };

        // Get optional comment
        let comment: Option<String> = if let Some(ref c) = self.comment {
            Some(
                stk.run(|stk| c.compute(stk, ctx, opt, None))
                    .await
                    .catch_return()?
                    .cast_to()?,
            )
        } else {
            None
        };

        // Fetch the transaction
        let txn = ctx.tx();

        // Check namespace and database
        let (ns_id, db_id) = ctx.get_ns_db_ids(opt).await?;
        let _ns = txn.expect_ns_by_name(opt.ns()?).await?;
        let _db = txn.expect_db_by_name(opt.ns()?, opt.db()?).await?;

        // Check if the definition exists
        if txn.get_db_credential(ns_id, db_id, &name).await.is_ok() {
            match self.kind {
                DefineKind::Default => {
                    if !opt.import {
                        bail!(Error::CrAlreadyExists {
                            name: name.clone(),
                        });
                    }
                }
                DefineKind::Overwrite => {}
                DefineKind::IfNotExists => return Ok(Value::None),
            }
        }

        // Encrypt the value before storage
        let encrypted_value = crate::credential::encrypt_credential(&value)?;
        let encrypted_refresh = refresh
            .as_ref()
            .map(|r| crate::credential::encrypt_credential(r))
            .transpose()?;

        // Create credential definition
        let credential_def = crate::catalog::CredentialDefinition {
            name: name.clone(),
            credential_type: self.credential_type.clone().into(),
            encrypted_value: encrypted_value.into(),
            algorithm: self.algorithm.clone().map(|a| a.into()),
            header,
            expires,
            encrypted_refresh: encrypted_refresh.map(|e| e.into()),
            comment,
            permissions: self.permissions.clone(),
        };

        // Store in the catalog
        txn.put_db_credential(ns_id, db_id, &credential_def).await?;

        // Emit system event
        tracing::info!(
            target: "surrealdb::credential",
            credential = %name,
            credential_type = %self.credential_type,
            "credential:defined"
        );

        // Clear the cache
        txn.clear_cache();

        Ok(Value::None)
    }
}

impl Display for DefineCredentialStatement {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "DEFINE CREDENTIAL")?;
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => write!(f, " OVERWRITE")?,
            DefineKind::IfNotExists => write!(f, " IF NOT EXISTS")?,
        }
        write!(f, " {:?}", self.name)?;
        write!(f, " TYPE {}", self.credential_type)?;
        write!(f, " VALUE [REDACTED]")?; // Never show the value
        if let Some(ref alg) = self.algorithm {
            write!(f, " ALGORITHM {}", alg)?;
        }
        if let Some(ref h) = self.header {
            write!(f, " HEADER {:?}", h)?;
        }
        if let Some(ref e) = self.expires {
            write!(f, " EXPIRES {:?}", e)?;
        }
        if self.refresh.is_some() {
            write!(f, " REFRESH [REDACTED]")?; // Never show refresh token
        }
        if let Some(ref c) = self.comment {
            write!(f, " COMMENT {:?}", c)?;
        }
        Ok(())
    }
}
