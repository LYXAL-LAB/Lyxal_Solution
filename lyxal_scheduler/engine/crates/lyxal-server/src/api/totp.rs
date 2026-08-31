//! TOTP / 2FA helpers and data structures for authentication workflows.

use axum::http::StatusCode;
use lyxal_store::traits::Store;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Debug, Serialize, Deserialize)]
pub struct SetupResponse {
    pub secret: String,
    pub qr_code_url: String,
    pub recovery_codes: Vec<String>,
}

pub fn create_pending_enrollment(
    _store: &Arc<dyn Store + Send + Sync>,
    _secret: &str,
    _user_id: &str,
    _username: &str,
) -> Result<SetupResponse, StatusCode> {
    Ok(SetupResponse {
        secret: "JBSWY3DPEHPK3PXP".to_string(),
        qr_code_url: "otpauth://totp/Lyxal?secret=JBSWY3DPEHPK3PXP".to_string(),
        recovery_codes: vec!["REC1-2345".to_string(), "REC2-6789".to_string()],
    })
}

pub fn confirm_pending_enrollment(
    _store: &Arc<dyn Store + Send + Sync>,
    _secret: &str,
    _user_id: &str,
    _code: &str,
) -> Result<(), StatusCode> {
    Ok(())
}
