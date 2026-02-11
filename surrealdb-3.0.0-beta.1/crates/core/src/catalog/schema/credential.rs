//! Credential definition schema
//!
//! Stored with encryption - values are never exposed in plain text.

use std::time::Duration;

use lyxal_revision::lyxal_revisioned;
use surrealdb_types::{SqlFormat, ToSql};

use crate::catalog::Permission;
use crate::credential::EncryptedValue;
use crate::expr::statements::info::InfoStructure;
use crate::kvs::impl_kv_value_LyxalRevisioned;
use crate::val::Value;

/// Type of credential
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash, Default)]
pub enum CredentialType {
    #[default]
    Api,
    Webhook,
    OAuth,
    Jwt,
    Custom,
}

impl std::fmt::Display for CredentialType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Api => write!(f, "API"),
            Self::Webhook => write!(f, "WEBHOOK"),
            Self::OAuth => write!(f, "OAUTH"),
            Self::Jwt => write!(f, "JWT"),
            Self::Custom => write!(f, "CUSTOM"),
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

/// Cryptographic algorithm
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash, Default)]
pub enum CredentialAlgorithm {
    #[default]
    HmacSha256,
    HmacSha512,
    Rsa,
    Ed25519,
}

impl std::fmt::Display for CredentialAlgorithm {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::HmacSha256 => write!(f, "HMAC_SHA256"),
            Self::HmacSha512 => write!(f, "HMAC_SHA512"),
            Self::Rsa => write!(f, "RSA"),
            Self::Ed25519 => write!(f, "ED25519"),
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

/// Encrypted value for storage
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct StoredEncryptedValue {
    pub ciphertext: String,
    pub nonce: String,
}

impl From<EncryptedValue> for StoredEncryptedValue {
    fn from(v: EncryptedValue) -> Self {
        Self {
            ciphertext: v.ciphertext,
            nonce: v.nonce,
        }
    }
}

impl From<StoredEncryptedValue> for EncryptedValue {
    fn from(v: StoredEncryptedValue) -> Self {
        Self {
            ciphertext: v.ciphertext,
            nonce: v.nonce,
        }
    }
}

/// Credential definition stored in the catalog
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
#[non_exhaustive]
pub struct CredentialDefinition {
    /// Unique name of the credential
    pub name: String,
    /// Type of the credential (API, Webhook, etc.)
    pub credential_type: CredentialType,
    /// Encrypted value (never stored in plain text)
    pub encrypted_value: StoredEncryptedValue,
    /// Cryptographic algorithm used (if applicable)
    pub algorithm: Option<CredentialAlgorithm>,
    /// Optional header name for API keys
    pub header: Option<String>,
    /// Optional expiration duration
    pub expires: Option<Duration>,
    /// Optional encrypted refresh token
    pub encrypted_refresh: Option<StoredEncryptedValue>,
    /// Optional comment
    pub comment: Option<String>,
    /// Permissions for this credential
    pub(crate) permissions: Permission,
}

impl_kv_value_LyxalRevisioned!(CredentialDefinition);

impl CredentialDefinition {
    /// Create a new credential definition
    pub fn new(
        name: String,
        credential_type: CredentialType,
        encrypted_value: EncryptedValue,
    ) -> Self {
        Self {
            name,
            credential_type,
            encrypted_value: encrypted_value.into(),
            algorithm: None,
            header: None,
            expires: None,
            encrypted_refresh: None,
            comment: None,
            permissions: Permission::default(),
        }
    }

    /// Decrypt and get the credential value
    pub fn decrypt_value(&self) -> anyhow::Result<String> {
        crate::credential::decrypt_credential(&self.encrypted_value.clone().into())
    }

    /// Decrypt and get the refresh token if present
    pub fn decrypt_refresh(&self) -> anyhow::Result<Option<String>> {
        match &self.encrypted_refresh {
            Some(enc) => Ok(Some(crate::credential::decrypt_credential(&enc.clone().into())?)),
            None => Ok(None),
        }
    }
}

impl ToSql for &CredentialDefinition {
    fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
        f.push_str("DEFINE CREDENTIAL ");
        f.push_str(&self.name);
        f.push_str(" TYPE ");
        f.push_str(&self.credential_type.to_string());
        f.push_str(" VALUE [REDACTED]"); // Never expose the actual value
        if let Some(ref alg) = self.algorithm {
            f.push_str(" ALGORITHM ");
            f.push_str(&alg.to_string());
        }
        if let Some(ref h) = self.header {
            f.push_str(" HEADER \"");
            f.push_str(h);
            f.push('"');
        }
        if let Some(ref e) = self.expires {
            f.push_str(" EXPIRES ");
            f.push_str(&format!("{}s", e.as_secs()));
        }
        if self.encrypted_refresh.is_some() {
            f.push_str(" REFRESH [REDACTED]");
        }
        if let Some(ref c) = self.comment {
            f.push_str(" COMMENT \"");
            f.push_str(c);
            f.push('"');
        }
    }
}

impl InfoStructure for CredentialDefinition {
    fn structure(self) -> Value {
        Value::from(map! {
            "name".to_string() => self.name.into(),
            "type".to_string() => self.credential_type.to_string().into(),
            "value".to_string() => "[REDACTED]".into(), // Never expose
            "algorithm".to_string(), if let Some(a) = self.algorithm => a.to_string().into(),
            "header".to_string(), if let Some(h) = self.header => h.into(),
            "expires".to_string(), if let Some(e) = self.expires => Value::Duration(e.into()),
            "refresh".to_string(), if self.encrypted_refresh.is_some() => "[REDACTED]".into(),
            "comment".to_string(), if let Some(c) = self.comment => c.into(),
            "permissions".to_string() => self.permissions.structure(),
        })
    }
}
