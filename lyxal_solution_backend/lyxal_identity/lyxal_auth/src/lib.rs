//! Lyxal Auth Module - 1:1 Logto Mapping
//! Handles primary authentication flows and interaction states.

pub mod handlers;
pub mod providers;
pub mod services;

use axum::{routing::{get, post}, Router};
use lyxal_core::LyxalConfig;
use lyxal_iam::UserService;
use std::sync::Arc;

pub use handlers::auth_handler::*;
pub use services::auth_service::AuthService;

/// 1:1 Logto Authentication Methods
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum AuthMethod {
    Password,
    Social,
    Sms,
    Email,
    Sso,
    Mfa,
}

#[derive(Clone)]
pub struct AuthState {
    pub auth_service: AuthService,
    pub user_service: UserService,
    pub config: Arc<LyxalConfig>,
}

pub fn router(state: AuthState) -> Router {
    Router::new()
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/register", post(register))
        .route("/me", get(me))
        .with_state(state)
}
