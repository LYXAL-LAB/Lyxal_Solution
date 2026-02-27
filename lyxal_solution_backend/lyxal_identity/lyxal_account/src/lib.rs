//! Lyxal Account - 1:1 Logto Account Parity
//! End-user profile and security management (Account Center).

pub mod handlers;
pub mod services;

use axum::{routing::{get, patch, post}, Router};

pub fn router<S>() -> Router<S> 
where S: Clone + Send + Sync + 'static 
{
    Router::new()
        .route("/me", get(handlers::get_profile))
        .route("/me", patch(handlers::update_profile))
        .route("/me/password", post(handlers::change_password))
        .route("/me/mfa", get(handlers::list_mfa))
}
