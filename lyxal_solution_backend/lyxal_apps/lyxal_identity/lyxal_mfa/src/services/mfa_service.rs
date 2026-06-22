use crate::backup_codes::{BackupCodeService, BackupCodeSet};
use crate::totp::{TotpConfig, TotpService};
use crate::webauthn::WebAuthnService;
use lyxal_core::{CoreError, Result};
use lyxal_iam::UserService;
use uuid::Uuid;
use sqlx::{PgPool, query};

/// Service handling high-level Multi-Factor Authentication logic.
/// It coordinates between specific MFA methods (TOTP, Backup Codes)
/// and the user's identity state.
#[derive(Clone)]
pub struct MfaService {
    user_service: UserService,
    webauthn_service: Option<WebAuthnService>,
    pool: PgPool,
}

impl MfaService {
    /// Creates a new instance of MfaService.
    pub fn new(user_service: UserService, webauthn_service: Option<WebAuthnService>, pool: PgPool) -> Self {
        Self {
            user_service,
            webauthn_service,
            pool,
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

        let now = chrono::Utc::now().timestamp_millis();
        let id = Uuid::new_v4().to_string();
        
        sqlx::query!(
            "INSERT INTO user_mfa_configurations (id, user_id, mfa_type, secret, is_enabled, created_at) VALUES ($1, $2, $3, $4, $5, $6)",
            id, user_id.to_string(), "totp", secret, true, now
        )
        .execute(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?;

        tracing::info!("MFA: TOTP enabled for user {}", user_id);
        Ok(())
    }

    /// Verifies a TOTP challenge during the login flow.
    pub async fn verify_totp_login(&self, user_id: Uuid, code: &str) -> Result<bool> {
        let config = sqlx::query!(
            "SELECT secret FROM user_mfa_configurations WHERE user_id = $1 AND mfa_type = $2 AND is_enabled = true",
            user_id.to_string(), "totp"
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?
        .ok_or_else(|| CoreError::Unauthorized("MFA not set up".to_string()))?;

        let secret = config.secret.ok_or_else(|| CoreError::Internal(anyhow::anyhow!("Secret missing")))?;
        TotpService::verify_code(&secret, code)
    }

    /// Generates and stores a new set of backup codes for the user.
    pub async fn generate_backup_codes(&self, user_id: Uuid) -> Result<Vec<String>> {
        let (plain_codes, _hashed_set) = BackupCodeService::generate_codes(user_id, 10)?;

        let now = chrono::Utc::now().timestamp_millis();
        let id = Uuid::new_v4().to_string();
        
        // We store backup codes as a JSON string for simplicity in this schema
        let codes_json = serde_json::to_string(&plain_codes).map_err(|e| CoreError::Internal(e.into()))?;

        sqlx::query!(
            "INSERT INTO user_mfa_configurations (id, user_id, mfa_type, secret, is_enabled, created_at) VALUES ($1, $2, $3, $4, $5, $6)",
            id, user_id.to_string(), "backup_codes", codes_json, true, now
        )
        .execute(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?;

        tracing::info!("MFA: New backup codes generated for user {}", user_id);
        Ok(plain_codes)
    }

    /// Verifies a login attempt using a backup code.
    pub async fn verify_backup_code_login(&self, user_id: Uuid, code: &str) -> Result<()> {
        let config = sqlx::query!(
            "SELECT id, secret FROM user_mfa_configurations WHERE user_id = $1 AND mfa_type = $2 AND is_enabled = true",
            user_id.to_string(), "backup_codes"
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?
        .ok_or_else(|| CoreError::Unauthorized("Backup codes not configured".to_string()))?;

        let secret = config.secret.ok_or_else(|| CoreError::Internal(anyhow::anyhow!("Secret missing")))?;
        let mut codes: Vec<String> = serde_json::from_str(&secret).map_err(|e| CoreError::Internal(e.into()))?;

        let mut backup_set = BackupCodeSet {
            user_id,
            codes: codes.clone(),
            generated_at: chrono::Utc::now(),
        };

        BackupCodeService::verify_and_consume(code, &mut backup_set)?;

        // Update the codes in DB (one has been consumed)
        let updated_codes_json = serde_json::to_string(&backup_set.codes).map_err(|e| CoreError::Internal(e.into()))?;
        let now = chrono::Utc::now().timestamp_millis();

        sqlx::query!(
            "UPDATE user_mfa_configurations SET secret = $1, last_used_at = $2 WHERE id = $3",
            updated_codes_json,
            now,
            config.id
        )
        .execute(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?;

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

        let now = chrono::Utc::now().timestamp_millis();
        let id = Uuid::new_v4().to_string();
        let passkey_json = serde_json::to_string(&passkey).map_err(|e| CoreError::Internal(e.into()))?;

        sqlx::query!(
            "INSERT INTO user_mfa_configurations (id, user_id, mfa_type, secret, is_enabled, created_at) VALUES ($1, $2, $3, $4, $5, $6)",
            id, user_id.to_string(), "webauthn", passkey_json, true, now
        )
        .execute(&self.pool)
        .await
        .map_err(|e| CoreError::Database(e.to_string()))?;

        tracing::info!("MFA: WebAuthn Passkey registered for user {}", user_id);
        Ok(())
    }
}
