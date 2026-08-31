//! Authentication configuration & secrets domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

/// Configuration publique d'authentification — secrets remplacés par des flags *_configured.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthConfig {
    pub id: BookingRecordId,
    pub registration_enabled: bool,
    pub allowed_email_domains: Option<String>,
    pub oidc_enabled: bool,
    pub oidc_issuer_url: Option<String>,
    pub oidc_client_id: Option<String>,
    pub oidc_client_secret_configured: bool,
    pub oidc_auto_register: bool,
    pub google_oauth2_client_id: Option<String>,
    pub google_oauth2_client_secret_configured: bool,
    pub created_at: BookingDatetime,
    pub updated_at: BookingDatetime,
}

/// Structure interne stockant les ciphertexts scellés (interne `pub(crate)`).
#[derive(Clone, Deserialize)]
pub(crate) struct StoredAuthSecrets {
    pub oidc_client_secret_enc: Option<String>,
    pub google_oauth2_client_secret_enc: Option<String>,
}

impl std::fmt::Debug for StoredAuthSecrets {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("StoredAuthSecrets([REDACTED])")
    }
}
