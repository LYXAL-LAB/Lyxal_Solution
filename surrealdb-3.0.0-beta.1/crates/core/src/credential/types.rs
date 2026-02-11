//! Credential type definitions

use std::time::Duration;

/// Encrypted credential value wrapper
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct EncryptedValue {
    /// Encrypted data (base64 encoded)
    pub ciphertext: String,
    /// Nonce used for encryption (base64 encoded)
    pub nonce: String,
}

impl EncryptedValue {
    pub fn new(ciphertext: String, nonce: String) -> Self {
        Self { ciphertext, nonce }
    }
}

/// Runtime credential type (after decryption)
#[derive(Clone, Debug)]
pub enum CredentialValue {
    /// Simple string value (API key, secret)
    Simple(String),
    /// OAuth tokens with optional refresh
    OAuth {
        access_token: String,
        refresh_token: Option<String>,
        expires_in: Option<Duration>,
    },
}

impl CredentialValue {
    /// Get the primary value (access token or simple value)
    pub fn as_str(&self) -> &str {
        match self {
            Self::Simple(s) => s,
            Self::OAuth { access_token, .. } => access_token,
        }
    }
}
