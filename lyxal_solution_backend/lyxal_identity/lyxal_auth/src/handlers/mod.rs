use axum::{response::IntoResponse, Json, extract::State};
use crate::{AuthState, AuthResult};
use serde_json::json;

pub async fn login(State(_state): State<AuthState>) -> AuthResult<impl IntoResponse> {
    Ok(Json(json!({ "message": "Login successful" })))
}

pub async fn logout() -> impl IntoResponse {
    Json(json!({ "success": true }))
}

pub async fn register(State(_state): State<AuthState>) -> AuthResult<impl IntoResponse> {
    Ok(Json(json!({ "message": "Registration successful" })))
}

pub async fn me(State(_state): State<AuthState>) -> impl IntoResponse {
    Json(json!({ "authenticated": true }))
}
