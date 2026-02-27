use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub enum MfaFactor {
    Totp,
    BackupCode,
    WebAuthn,
}

#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct UserMfaConfiguration {
    pub id: String,
    pub user_id: String,
    pub mfa_type: MfaFactor,
    pub is_enabled: bool,
    pub created_at: i64,
    pub last_used_at: Option<i64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MfaVerification {
    pub id: String,
    pub user_id: String,
    pub mfa_type: String,
    pub secret: String, // Encrypted or hashed
    pub is_verified: bool,
    pub created_at: i64,
    pub last_used_at: Option<i64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TotpSecret {
    pub secret: String,
    pub uri: String,
}

pub mod totp;
pub mod backup_codes;
pub mod webauthn;
pub mod handlers;
pub mod services;
