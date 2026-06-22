use crate::services::mfa_service::MfaService;
use axum::{
    extract::{Extension, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use lyxal_core::{CoreError, Result};
use lyxal_session::AuthContext;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// State for MFA handlers
#[derive(Clone)]
pub struct MfaState {
    pub mfa_service: MfaService,
}

/// Request to initiate TOTP setup
#[derive(Debug, Deserialize)]
pub struct TotpSetupRequest {
    pub user_id: Uuid,
}

/// Response containing TOTP setup details
#[derive(Debug, Serialize)]
pub struct TotpSetupResponse {
    pub secret: String,
    pub qr_code_url: String,
}

/// Request to verify and enable TOTP
#[derive(Debug, Deserialize)]
pub struct TotpVerifyRequest {
    pub secret: String,
    pub code: String,
}

/// Request to verify an MFA challenge during login
#[derive(Debug, Deserialize)]
pub struct MfaLoginRequest {
    pub user_id: Uuid,
    pub code: String,
    pub method: String, // "totp" or "backup_code"
}

/// Handler to start the TOTP setup process
pub async fn setup_totp(
    State(state): State<MfaState>,
    Extension(auth): Extension<AuthContext>,
) -> Result<impl IntoResponse> {
    let config = state.mfa_service.start_totp_setup(auth.user_id).await?;
    let qr_code_url = crate::totp::TotpService::get_qr_code_url(&config)?;

    Ok((
        StatusCode::OK,
        Json(TotpSetupResponse {
            secret: config.secret,
            qr_code_url,
        }),
    ))
}

/// Handler to verify and finalize TOTP setup
pub async fn verify_setup(
    State(state): State<MfaState>,
    Extension(auth): Extension<AuthContext>,
    Json(payload): Json<TotpVerifyRequest>,
) -> Result<impl IntoResponse> {
    state
        .mfa_service
        .verify_and_enable_totp(auth.user_id, &payload.secret, &payload.code)
        .await?;

    Ok(StatusCode::OK)
}

/// Handler to generate new backup codes
pub async fn generate_backup_codes(
    State(state): State<MfaState>,
    Extension(auth): Extension<AuthContext>,
) -> Result<impl IntoResponse> {
    let codes = state
        .mfa_service
        .generate_backup_codes(auth.user_id)
        .await?;

    Ok((StatusCode::OK, Json(codes)))
}

/// Handler for MFA verification during the login flow
pub async fn verify_mfa_login(
    State(state): State<MfaState>,
    Json(payload): Json<MfaLoginRequest>,
) -> Result<impl IntoResponse> {
    match payload.method.as_str() {
        "totp" => {
            let is_valid = state
                .mfa_service
                .verify_totp_login(payload.user_id, &payload.code)
                .await?;
            if !is_valid {
                return Err(CoreError::Unauthorized("Invalid TOTP code".to_string()));
            }
        }
        "backup_code" => {
            state
                .mfa_service
                .verify_backup_code_login(payload.user_id, &payload.code)
                .await?;
        }
        _ => return Err(CoreError::Validation("Unsupported MFA method".to_string())),
    }

    // Note: In a real flow, this would upgrade the session to "fully authenticated"
    Ok(StatusCode::OK)
}

/// Request for WebAuthn registration
#[derive(Debug, Deserialize)]
pub struct WebAuthnRegRequest {
    pub user_id: Uuid,
}

/// Handler to start WebAuthn registration
pub async fn start_webauthn_reg(
    State(state): State<MfaState>,
    Extension(auth): Extension<AuthContext>,
) -> Result<impl IntoResponse> {
    let (challenge, reg_state) = state
        .mfa_service
        .start_webauthn_registration(auth.user_id)
        .await?;

    // Note: reg_state must be stored in the session to be used in the finish step
    Ok((StatusCode::OK, Json(challenge)))
}

/// Handler to finish WebAuthn registration
pub async fn finish_webauthn_reg(
    State(state): State<MfaState>,
    Extension(auth): Extension<AuthContext>,
    Json(reg_response): Json<webauthn_rs::prelude::RegisterPublicKeyCredential>,
) -> Result<impl IntoResponse> {
    // Note: RegistrationState would be retrieved from the session
    let dummy_state = webauthn_rs::prelude::RegistrationState::new(
        webauthn_rs::prelude::Url::parse("https://auth.lyxal.com").unwrap(),
        webauthn_rs::prelude::Challenge::generate(),
        None,
        None,
    );

    state
        .mfa_service
        .finish_webauthn_registration(auth.user_id, reg_response, dummy_state)
        .await?;

    Ok(StatusCode::OK)
}

/// Handler to start WebAuthn authentication
pub async fn start_webauthn_auth(State(_state): State<MfaState>) -> Result<impl IntoResponse> {
    // Logic to start authentication ceremony
    Ok(StatusCode::NOT_IMPLEMENTED)
}

/// Handler to finish WebAuthn authentication
pub async fn finish_webauthn_auth(State(_state): State<MfaState>) -> Result<impl IntoResponse> {
    // Logic to verify authentication response
    Ok(StatusCode::NOT_IMPLEMENTED)
}
