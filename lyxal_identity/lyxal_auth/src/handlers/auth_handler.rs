use crate::services::auth_service::AuthService;
use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use lyxal_core::{CoreError, Result};
use lyxal_iam::UserService;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Request body for login
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}

/// Request body for user registration
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub email: Option<String>,
    pub username: Option<String>,
    pub password: String,
}

/// Response body for successful authentication
#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub user_id: Uuid,
    pub email: Option<String>,
    pub username: Option<String>,
}

/// Handler for user login via Email/Password
pub async fn login(
    State(state): State<crate::AuthState>,
    Json(payload): Json<LoginRequest>,
) -> Result<impl IntoResponse> {
    let user = state
        .auth_service
        .authenticate_with_password(&payload.email, &payload.password)
        .await?;

    // Note: The actual session creation happens via tower-sessions middleware
    // in the router configuration. Here we just return the user info.

    Ok((
        StatusCode::OK,
        Json(AuthResponse {
            user_id: user.id,
            email: user.primary_email,
            username: user.username,
        }),
    ))
}

/// Handler for user registration
pub async fn register(
    State(state): State<crate::AuthState>,
    Json(payload): Json<RegisterRequest>,
) -> Result<impl IntoResponse> {
    let user = state
        .user_service
        .create_user(payload.username, payload.email, Some(payload.password))
        .await?;

    Ok((
        StatusCode::CREATED,
        Json(AuthResponse {
            user_id: user.id,
            email: user.primary_email,
            username: user.username,
        }),
    ))
}

/// Handler for user logout
pub async fn logout() -> impl IntoResponse {
    // Session is typically cleared by the session middleware
    // when the session is deleted from the store.
    StatusCode::NO_CONTENT
}

/// Handler to get current user info (requires session)
pub async fn me(// In a real scenario, an extractor would fetch the user from the session
    // This is a placeholder for the logic
) -> Result<impl IntoResponse> {
    // Logic to return current user profile
    Ok(StatusCode::OK)
}
