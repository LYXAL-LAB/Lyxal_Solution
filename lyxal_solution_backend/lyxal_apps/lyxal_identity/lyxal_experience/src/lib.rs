//! Lyxal Experience - 1:1 Logto Experience Parity
//! Handles the User Experience (Login, Signup, Consent pages).

pub mod handlers;

use axum::{routing::get, Router};

pub fn router<S>() -> Router<S> 
where S: Clone + Send + Sync + 'static 
{
    Router::new()
        .route("/login", get(handlers::login_page))
        .route("/register", get(handlers::register_page))
}
