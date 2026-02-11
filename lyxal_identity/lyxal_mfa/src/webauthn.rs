use lyxal_core::{CoreError, Result};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use uuid::Uuid;
use webauthn_rs::prelude::*;

/// WebAuthnService handles the logic for Passkeys (FIDO2/WebAuthn).
/// It manages registration and authentication ceremonies.
#[derive(Clone)]
pub struct WebAuthnService {
    inner: Arc<Webauthn>,
}

impl WebAuthnService {
    /// Creates a new WebAuthnService instance.
    ///
    /// # Arguments
    /// * `rp_id` - Relying Party Identifier (e.g., "auth.lyxal.com").
    /// * `rp_origin` - Relying Party Origin (e.g., "https://auth.lyxal.com").
    pub fn new(rp_id: &str, rp_origin: &str) -> Result<Self> {
        let rp_origin_url = Url::parse(rp_origin)
            .map_err(|e| CoreError::Validation(format!("Invalid RP Origin URL: {}", e)))?;

        let webauthn_config = WebauthnBuilder::new(rp_id, &rp_origin_url)
            .map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to initialize WebAuthn: {}", e))
            })?
            .build()
            .map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to build WebAuthn instance: {}", e))
            })?;

        Ok(Self {
            inner: Arc::new(webauthn_config),
        })
    }

    /// Starts a registration ceremony for a new Passkey.
    ///
    /// # Arguments
    /// * `user_id` - The ID of the user.
    /// * `username` - The display name of the user.
    pub fn start_registration(
        &self,
        user_id: Uuid,
        username: &str,
    ) -> Result<(CreationChallengeResponse, RegistrationState)> {
        self.inner
            .start_passkey_registration(user_id, username, username, None)
            .map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("WebAuthn Registration start failed: {}", e))
            })
    }

    /// Completes the registration ceremony and returns the new Passkey credentials.
    pub fn finish_registration(
        &self,
        reg_response: RegisterPublicKeyCredential,
        state: RegistrationState,
    ) -> Result<Passkey> {
        self.inner
            .finish_passkey_registration(&reg_response, &state)
            .map_err(|e| CoreError::Unauthorized(format!("Passkey registration failed: {}", e)))
    }

    /// Starts an authentication ceremony (Login with Passkey).
    ///
    /// # Arguments
    /// * `allow_credentials` - List of previously registered passkeys for this user.
    pub fn start_authentication(
        &self,
        allow_credentials: &[Passkey],
    ) -> Result<(RequestChallengeResponse, AuthenticationState)> {
        self.inner
            .start_passkey_authentication(allow_credentials)
            .map_err(|e| {
                CoreError::Internal(anyhow::anyhow!(
                    "WebAuthn Authentication start failed: {}",
                    e
                ))
            })
    }

    /// Completes the authentication ceremony.
    pub fn finish_authentication(
        &self,
        auth_response: AuthenticationPublicKeyCredential,
        state: AuthenticationState,
    ) -> Result<AuthenticationResult> {
        self.inner
            .finish_passkey_authentication(&auth_response, &state)
            .map_err(|e| CoreError::Unauthorized(format!("Passkey authentication failed: {}", e)))
    }
}

/// Represents a stored Passkey in the database.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct StoredPasskey {
    pub id: Uuid,
    pub user_id: Uuid,
    pub name: String,
    pub passkey: Passkey,
    pub created_at: chrono::DateTime<chrono::Utc>,
}

/// Result of a successful WebAuthn authentication.
pub struct AuthenticationResult {
    pub user_id: Uuid,
    pub credential_id: Vec<u8>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_webauthn_init() {
        let service = WebAuthnService::new("localhost", "http://localhost:3000");
        assert!(service.is_ok());
    }

    #[test]
    fn test_registration_start() {
        let service = WebAuthnService::new("localhost", "http://localhost:3000").unwrap();
        let user_id = Uuid::new_v4();
        let result = service.start_registration(user_id, "testuser");
        assert!(result.is_ok());
    }
}
