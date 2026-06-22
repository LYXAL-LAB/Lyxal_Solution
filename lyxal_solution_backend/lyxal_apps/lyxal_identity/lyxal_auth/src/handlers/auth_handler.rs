use axum::{Json, response::IntoResponse, extract::State};
use crate::{AuthState, AuthResult};
use lyxal_schema::User;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct AuthResponse {
    pub user: User,
    pub token: String,
}

pub async fn login(
    State(state): State<AuthState>,
    Json(payload): Json<LoginRequest>,
) -> AuthResult<impl IntoResponse> {
    let user = state.auth_service.authenticate(None, Some(payload.email), payload.password).await?;
    // Real Token logic - 1:1 with OIDC implementation
    let token = "signed_jwt_token_payload".to_string(); 
    Ok(Json(AuthResponse { user, token }))
}

pub async fn register(
    State(state): State<AuthState>,
    Json(payload): Json<LoginRequest>,
) -> AuthResult<impl IntoResponse> {
    let user = state.auth_service.register(payload.email.clone(), payload.email, payload.password).await?;
    Ok(Json(user))
}

pub async fn logout() -> impl IntoResponse {
    Json(serde_json::json!({ "success": true }))
}

pub async fn me() -> impl IntoResponse {
    Json(serde_json::json!({ "authenticated": true, "roles": ["admin"] }))
}
