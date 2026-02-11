//! Lyxal Auth Module
//!
//! This module handles the core authentication logic, including:
//! - Password-based authentication
//! - Social login integration
//! - Magic links and verification codes
//! - Account recovery flows

pub mod handlers;
pub mod providers;
pub mod services;

use axum::{
    routing::{get, post},
    Router,
};
use lyxal_core::LyxalConfig;
use lyxal_iam::UserService;
use std::sync::Arc;

pub use handlers::auth_handler::*;
pub use services::auth_service::AuthService;

/// Result type for Lyxal Auth operations
pub type AuthResult<T> = Result<T, lyxal_core::CoreError>;

/// Enum representing the different authentication methods supported
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum AuthMethod {
    Password,
    Social,
    MagicLink,
    Mfa,
}

/// Shared application state for authentication handlers
#[derive(Clone)]
pub struct AuthState {
    pub auth_service: AuthService,
    pub user_service: UserService,
    pub config: Arc<LyxalConfig>,
}

/// Creates the authentication router with all auth-related routes
pub fn router(state: AuthState) -> Router {
    Router::new()
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/register", post(register))
        .route("/me", get(me))
        .with_state(state)
}
