//! Lyxal Console - 1:1 Logto Console Parity
//! Administration Management API and Interface logic.

pub mod handlers;

use axum::{routing::get, Router};

pub fn router<S>() -> Router<S> 
where S: Clone + Send + Sync + 'static 
{
    Router::new()
        .route("/stats", get(handlers::get_dashboard_stats))
}
