use crate::backup_codes::{BackupCodeService, BackupCodeSet};
use crate::totp::{TotpConfig, TotpService};
use crate::webauthn::WebAuthnService;
use lyxal_core::{CoreError, Result};
use lyxal_iam::UserService;
use uuid::Uuid;

/// Service handling high-level Multi-Factor Authentication logic.
/// It coordinates between specific MFA methods (TOTP, Backup Codes)
/// and the user's identity state.
#[derive(Clone)]
pub struct MfaService {
    user_service: UserService,
    webauthn_service: Option<WebAuthnService>,
}

impl MfaService {
    /// Creates a new instance of MfaService.
    pub fn new(user_service: UserService, webauthn_service: Option<WebAuthnService>) -> Self {
        Self {
            user_service,
            webauthn_service,
        }
    }

    /// Initiates a new TOTP setup for a user.
    /// This generates the secret that the user must scan with their authenticator app.
    pub async fn start_totp_setup(&self, user_id: Uuid) -> Result<TotpConfig> {
        let user = self.user_service.get_user_by_id(user_id).await?;
        let email = user
            .primary_email
            .unwrap_or_else(|| "user@lyxal.identity".to_string());

        // Generate setup for "Lyxal Identity"
        TotpService::generate_new_setup("Lyxal Identity", &email)
    }

    /// Completes the TOTP setup by verifying the first code provided by the user.
    /// In a real scenario, the secret would be stored in the database after successful verification.
    pub async fn verify_and_enable_totp(
        &self,
        user_id: Uuid,
        secret: &str,
        code: &str,
    ) -> Result<()> {
        let is_valid = TotpService::verify_code(secret, code)?;

        if !is_valid {
            return Err(CoreError::Unauthorized(
                "Invalid TOTP verification code".to_string(),
            ));
        }

        // TODO: Persist the TOTP secret in the database for the user
        // self.user_service.update_user_mfa_settings(user_id, ...).await?;

        tracing::info!("MFA: TOTP enabled for user {}", user_id);
        Ok(())
    }

    /// Verifies a TOTP challenge during the login flow.
    pub async fn verify_totp_login(&self, user_id: Uuid, code: &str) -> Result<bool> {
        // 1. Fetch the stored secret for the user from DB
        // let secret = self.repository.get_totp_secret(user_id).await?;
        let secret = "DUMMY_SECRET_FROM_DB";

        TotpService::verify_code(secret, code)
    }

    /// Generates and stores a new set of backup codes for the user.
    pub async fn generate_backup_codes(&self, user_id: Uuid) -> Result<Vec<String>> {
        let (plain_codes, _hashed_set) = BackupCodeService::generate_codes(user_id, 10)?;

        // TODO: Save hashed_set in the database
        // self.repository.save_backup_codes(user_id, hashed_set).await?;

        tracing::info!("MFA: New backup codes generated for user {}", user_id);
        Ok(plain_codes)
    }

    /// Verifies a login attempt using a backup code.
    pub async fn verify_backup_code_login(&self, user_id: Uuid, code: &str) -> Result<()> {
        // 1. Fetch hashed backup codes from DB
        // let mut stored_set = self.repository.get_backup_codes(user_id).await?;

        // Placeholder for real DB logic
        let mut dummy_set = BackupCodeSet {
            user_id,
            codes: Vec::new(),
            generated_at: chrono::Utc::now(),
        };

        BackupCodeService::verify_and_consume(code, &mut dummy_set)?;

        // 2. Update the used status in DB
        // self.repository.update_backup_codes(user_id, dummy_set).await?;

        tracing::info!("MFA: Backup code consumed for user {}", user_id);
        Ok(())
    }

    /// Starts a WebAuthn registration ceremony.
    pub async fn start_webauthn_registration(
        &self,
        user_id: Uuid,
    ) -> Result<(
        webauthn_rs::prelude::CreationChallengeResponse,
        webauthn_rs::prelude::RegistrationState,
    )> {
        let webauthn = self.webauthn_service.as_ref().ok_or_else(|| {
            CoreError::Internal(anyhow::anyhow!("WebAuthn service is not configured"))
        })?;

        let user = self.user_service.get_user_by_id(user_id).await?;
        let username = user.username.as_deref().unwrap_or("unknown_user");

        webauthn.start_registration(user_id, username)
    }

    /// Completes WebAuthn registration.
    pub async fn finish_webauthn_registration(
        &self,
        user_id: Uuid,
        reg_response: webauthn_rs::prelude::RegisterPublicKeyCredential,
        state: webauthn_rs::prelude::RegistrationState,
    ) -> Result<()> {
        let webauthn = self.webauthn_service.as_ref().ok_or_else(|| {
            CoreError::Internal(anyhow::anyhow!("WebAuthn service is not configured"))
        })?;

        let passkey = webauthn.finish_registration(reg_response, state)?;

        // TODO: Persist the passkey in the database
        // self.repository.save_passkey(user_id, passkey).await?;

        tracing::info!("MFA: WebAuthn Passkey registered for user {}", user_id);
        Ok(())
    }
}
