use async_trait::async_trait;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Represents an Authorization Code grant.
/// This is used during the OAuth2 "Authorization Code Flow" to temporarily
/// store information between the authorize and token requests.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorizationCode {
    /// The actual authorization code string (secret)
    pub code: String,
    /// The client (application) that requested the code
    pub client_id: Uuid,
    /// The user who authorized the request
    pub user_id: Uuid,
    /// The redirect URI provided in the initial request
    pub redirect_uri: String,
    /// The scopes approved by the user
    pub scopes: Vec<String>,
    /// Optional PKCE code challenge
    pub code_challenge: Option<String>,
    /// Optional PKCE code challenge method (S256 or plain)
    pub code_challenge_method: Option<String>,
    /// Optional OIDC nonce
    pub nonce: Option<String>,
    /// When the code expires (usually very short-lived, e.g., 5-10 minutes)
    pub expires_at: DateTime<Utc>,
    /// When the code was created
    pub created_at: DateTime<Utc>,
}

impl AuthorizationCode {
    /// Creates a new AuthorizationCode instance with default expiration.
    pub fn new(
        code: String,
        client_id: Uuid,
        user_id: Uuid,
        redirect_uri: String,
        scopes: Vec<String>,
        expires_in_minutes: i64,
    ) -> Self {
        let now = Utc::now();
        Self {
            code,
            client_id,
            user_id,
            redirect_uri,
            scopes,
            code_challenge: None,
            code_challenge_method: None,
            nonce: None,
            expires_at: now + chrono::Duration::minutes(expires_in_minutes),
            created_at: now,
        }
    }

    /// Checks if the authorization code has expired.
    pub fn is_expired(&self) -> bool {
        self.expires_at < Utc::now()
    }

    /// Validates a PKCE code verifier against the stored challenge.
    pub fn validate_pkce(&self, code_verifier: &str) -> bool {
        let challenge = match &self.code_challenge {
            Some(c) => c,
            None => return true, // No PKCE required for this grant
        };

        match self.code_challenge_method.as_deref() {
            Some("S256") => {
                use base64::Engine;
                use sha2::{Digest, Sha256};
                let hash = Sha256::digest(code_verifier.as_bytes());
                let encoded = base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(hash);
                &encoded == challenge
            }
            Some("plain") | None => code_verifier == challenge,
            _ => false,
        }
    }
}

/// Trait defining the requirements for an Authorization Code repository.
#[async_trait]
pub trait GrantRepository: Send + Sync {
    /// Persists a new authorization code.
    async fn save_code(&self, code: AuthorizationCode) -> lyxal_core::Result<()>;

    /// Retrieves and optionally deletes (codes must be single-use) an authorization code.
    async fn consume_code(&self, code: &str) -> lyxal_core::Result<Option<AuthorizationCode>>;

    /// Cleans up expired codes from the storage.
    async fn cleanup_expired_codes(&self) -> lyxal_core::Result<()>;
}
