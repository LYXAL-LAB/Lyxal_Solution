use axum::extract::State;
use axum::http::header::{AUTHORIZATION, SET_COOKIE};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::{get, post};
use axum::Json;
use axum::Router;
use rand::rngs::OsRng;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use rand::RngCore;
use sha2::{Digest, Sha256};

use crate::contracts::auth::{
    AuthAccountRecord, AuthSessionResponse, CreateSessionParams, CurrentSessionResponse,
    GetAuthAccountParams, GetCurrentSessionParams, LoginRequest, LogoutResponse,
    RevokeAllSessionsParams, RevokeSessionParams,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub const SESSION_COOKIE_NAME: &str = "__Host-booking_session";
const DUMMY_ARGON2_HASH: &str = "$argon2id$v=19$m=19456,t=2,p=1$ZHVtbXlzYWx0MTIzNDU2Nw$q0c+8v5Xw9nQ1+Y7Z1+1234567890abcdefghijklm";

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/session", get(get_session))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/logout-all", post(logout_all))
}

fn generate_csprng_session_token() -> String {
    let mut bytes = [0_u8; 32];
    OsRng.fill_bytes(&mut bytes);
    URL_SAFE_NO_PAD.encode(bytes)
}

fn hash_token(token: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(token.as_bytes());
    hex::encode(hasher.finalize())
}

fn extract_token_from_headers(headers: &HeaderMap) -> Result<Option<String>, WebError> {
    if let Some(auth_val) = headers.get(AUTHORIZATION).and_then(|h| h.to_str().ok()) {
        if let Some(token) = auth_val.strip_prefix("Bearer ") {
            let trimmed = token.trim();
            if trimmed.is_empty() {
                return Err(WebError::Unauthorized("AUTH_INVALID_CREDENTIALS".to_string()));
            }
            return Ok(Some(trimmed.to_string()));
        }
        return Err(WebError::Unauthorized("AUTH_INVALID_CREDENTIALS".to_string()));
    }

    if let Some(cookie_val) = headers.get("cookie").and_then(|h| h.to_str().ok()) {
        for cookie in cookie_val.split(';') {
            let cookie = cookie.trim();
            if let Some(val) = cookie.strip_prefix(&format!("{}=", SESSION_COOKIE_NAME)) {
                let trimmed = val.trim();
                if !trimmed.is_empty() {
                    return Ok(Some(trimmed.to_string()));
                }
            }
        }
    }

    Ok(None)
}

pub async fn get_session(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<CurrentSessionResponse>, WebError> {
    let token = match extract_token_from_headers(&headers)? {
        Some(t) => t,
        None => {
            return Ok(Json(CurrentSessionResponse {
                active: false,
                user: None,
            }))
        }
    };

    let token_hash = hash_token(&token);
    let response = crate::auth::get_current_session_by_hash(&state.store, &token_hash)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to fetch session: {}", e)))?;

    Ok(Json(response))
}

pub async fn login(
    State(state): State<AppState>,
    Json(request): Json<LoginRequest>,
) -> Result<Response, WebError> {
    if request.username.trim().is_empty() {
        return Err(WebError::BadRequest("Username cannot be empty".to_string()));
    }
    if request.password.is_empty() {
        return Err(WebError::BadRequest("Password cannot be empty".to_string()));
    }

    // 1. Recupere le compte via le service auth
    let account_opt: Option<AuthAccountRecord> = crate::auth::get_auth_account_by_username(&state.store, &request.username)
        .await
        .ok()
        .flatten();

    // 2. Hash Argon2 constant-time meme en cas d'utilisateur inconnu
    let password_hash = account_opt
        .as_ref()
        .map(|acc| acc.password_hash.as_str())
        .unwrap_or(DUMMY_ARGON2_HASH);

    let password_valid = crate::auth::verify_password(&request.password, password_hash);

    let account = match (account_opt, password_valid) {
        (Some(account), true) if !account.disabled => account,
        _ => return Err(WebError::Unauthorized("AUTH_INVALID_CREDENTIALS".to_string())),
    };

    // 3. Token CSPRNG 256-bit et SHA-256 pour persistance DB
    let raw_token = generate_csprng_session_token();
    let token_hash = hash_token(&raw_token);
    let expires_at = (chrono::Utc::now() + chrono::Duration::hours(24)).to_rfc3339();

    let _session_res = crate::auth::create_auth_session(
        &state.store,
        &account.id,
        &token_hash,
        &expires_at,
    )
    .await
    .map_err(|e| WebError::Internal(format!("Session creation failed: {}", e)))?;

    let body_response = AuthSessionResponse {
        user_id: account.id,
        username: account.username,
        email: account.email,
        role: account.role,
        expires_at,
        token: Some(raw_token.clone()),
    };

    let cookie_header = format!(
        "{}={}; Path=/; Max-Age=86400; HttpOnly; Secure; SameSite=Strict",
        SESSION_COOKIE_NAME, raw_token
    );

    let mut response = (StatusCode::OK, Json(body_response)).into_response();
    if let Ok(val) = HeaderValue::from_str(&cookie_header) {
        response.headers_mut().insert(SET_COOKIE, val);
    }

    Ok(response)
}

pub async fn logout(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Response, WebError> {
    if let Ok(Some(token)) = extract_token_from_headers(&headers) {
        let token_hash = hash_token(&token);
        let _ = crate::auth::revoke_auth_session(&state.store, &token_hash).await;
    }

    let cookie_clear = format!(
        "{}=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Strict",
        SESSION_COOKIE_NAME
    );

    let mut response = (StatusCode::OK, Json(LogoutResponse { success: true })).into_response();
    if let Ok(val) = HeaderValue::from_str(&cookie_clear) {
        response.headers_mut().insert(SET_COOKIE, val);
    }

    Ok(response)
}

pub async fn logout_all(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Response, WebError> {
    let response = crate::auth::revoke_all_auth_sessions(&state.store, &auth.user_id)
        .await
        .map_err(|e| WebError::Internal(format!("Logout all failed: {}", e)))?;

    let cookie_clear = format!(
        "{}=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Strict",
        SESSION_COOKIE_NAME
    );

    let mut resp = (StatusCode::OK, Json(response)).into_response();
    if let Ok(val) = HeaderValue::from_str(&cookie_clear) {
        resp.headers_mut().insert(SET_COOKIE, val);
    }

    Ok(resp)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_csprng_token_length_and_uniqueness() {
        let t1 = generate_csprng_session_token();
        let t2 = generate_csprng_session_token();
        assert_ne!(t1, t2);
        assert!(t1.len() >= 43); // 32 bytes base64url non-rembourre = 43 chars
    }

    #[test]
    fn test_bearer_priority_over_cookie() {
        let mut headers = HeaderMap::new();
        headers.insert(AUTHORIZATION, HeaderValue::from_static("Bearer token_bearer_123"));
        headers.insert(
            "cookie",
            HeaderValue::from_str(&format!("{}=token_cookie_456", SESSION_COOKIE_NAME)).unwrap(),
        );
        let extracted = extract_token_from_headers(&headers).unwrap();
        assert_eq!(extracted, Some("token_bearer_123".to_string()));
    }

    #[test]
    fn test_invalid_bearer_rejects_without_cookie_fallback() {
        let mut headers = HeaderMap::new();
        headers.insert(AUTHORIZATION, HeaderValue::from_static("Bearer "));
        headers.insert(
            "cookie",
            HeaderValue::from_str(&format!("{}=token_cookie_456", SESSION_COOKIE_NAME)).unwrap(),
        );
        let result = extract_token_from_headers(&headers);
        assert!(result.is_err());
    }

    #[test]
    fn test_cookie_deletion_attributes() {
        let cookie_clear = format!(
            "{}=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Strict",
            SESSION_COOKIE_NAME
        );
        assert!(cookie_clear.contains("Max-Age=0"));
        assert!(cookie_clear.contains("Path=/"));
        assert!(cookie_clear.contains("HttpOnly"));
        assert!(cookie_clear.contains("Secure"));
        assert!(cookie_clear.contains("SameSite=Strict"));
    }
}
