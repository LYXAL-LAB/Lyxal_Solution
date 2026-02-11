//! Lyxal MFA Module
//!
//! This module provides Multi-Factor Authentication (MFA) capabilities, including:
//! - Time-based One-Time Password (TOTP)
//! - Backup codes management
//! - WebAuthn / Passkeys support (Planned)
//! - MFA challenge and verification flows

pub mod backup_codes;
pub mod handlers;
pub mod services;
pub mod totp;
pub mod webauthn;

use axum::{
    routing::{get, post},
    Router,
};
use lyxal_core::LyxalConfig;
use std::sync::Arc;

pub use backup_codes::{BackupCodeService, BackupCodeSet};
pub use handlers::*;
pub use services::mfa_service::MfaService;
pub use totp::{TotpConfig, TotpService};
pub use webauthn::WebAuthnService;

/// Result type for Lyxal MFA operations
pub type MfaResult<T> = Result<T, lyxal_core::CoreError>;

/// Enum representing supported MFA methods
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum MfaMethod {
    Totp,
    BackupCode,
    WebAuthn,
}

/// Structure for an MFA verification challenge
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct MfaChallenge {
    pub user_id: uuid::Uuid,
    pub method: MfaMethod,
    pub challenge_id: String,
}

/// Shared state for the MFA module
#[derive(Clone)]
pub struct MfaState {
    pub mfa_service: MfaService,
    pub config: Arc<LyxalConfig>,
}

/// Creates the MFA router
pub fn router(state: MfaState) -> Router {
    Router::new()
        .route("/mfa/totp/setup", post(setup_totp))
        .route("/mfa/totp/verify", post(verify_setup))
        .route("/mfa/backup-codes/generate", post(generate_backup_codes))
        .route("/mfa/verify", post(verify_mfa_login))
        // WebAuthn / Passkeys
        .route(
            "/mfa/webauthn/register/start",
            post(handlers::start_webauthn_reg),
        )
        .route(
            "/mfa/webauthn/register/finish",
            post(handlers::finish_webauthn_reg),
        )
        .route(
            "/mfa/webauthn/authenticate/start",
            post(handlers::start_webauthn_auth),
        )
        .route(
            "/mfa/webauthn/authenticate/finish",
            post(handlers::finish_webauthn_auth),
        )
        .with_state(state)
}
