use serde::{Deserialize, Serialize};
use lyxal_core::Result;
use webauthn_rs::prelude::*;
use std::sync::Arc;

pub struct WebAuthnService {
    inner: Arc<Webauthn>,
}

impl WebAuthnService {
    pub fn new(rp_id: &str, rp_origin: &str) -> Self {
        let rp_origin = Url::parse(rp_origin).expect("Invalid RP Origin");
        let builder = WebauthnBuilder::new(rp_id, &rp_origin).expect("Invalid WebAuthn Builder");
        Self {
            inner: Arc::new(builder.build().expect("Failed to build WebAuthn")),
        }
    }

    pub fn start_registration(&self, user_id: &str, user_name: &str) -> Result<(CreationChallengeResponse, RegistrationState)> {
        let user_unique_id = uuid::Uuid::parse_str(user_id).unwrap_or_default();
        self.inner.start_passkey_registration(user_unique_id, user_name, user_name, None)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))
    }

    pub fn finish_registration(&self, reg_state: RegistrationState, response: RegisterPublicKeyCredential) -> Result<Passkey> {
        self.inner.finish_passkey_registration(&response, &reg_state)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))
    }

    pub fn start_authentication(&self, allow_credentials: Vec<Passkey>) -> Result<(RequestChallengeResponse, AuthenticationState)> {
        self.inner.start_passkey_authentication(&allow_credentials)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))
    }

    pub fn finish_authentication(&self, auth_state: AuthenticationState, response: PublicKeyCredential) -> Result<PasskeyAuthentication> {
        self.inner.finish_passkey_authentication(&response, &auth_state)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))
    }
}
