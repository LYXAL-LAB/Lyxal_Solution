pub mod mfa_handler;

pub use mfa_handler::*;

use crate::MfaState;
use axum::{
    routing::{get, post},
    Router,
};

/// Internal helper to create the MFA router part
/// Note: This is usually called from the main lyxal_identity router or lyxal_mfa lib.rs
pub fn routes(state: MfaState) -> Router {
    Router::new()
        .route("/totp/setup", post(setup_totp))
        .route("/totp/verify", post(verify_setup))
        .route("/backup-codes/generate", post(generate_backup_codes))
        .route("/verify", post(verify_mfa_login))
        .with_state(state)
}
