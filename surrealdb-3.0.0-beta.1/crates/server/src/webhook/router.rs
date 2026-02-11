//! Webhook Router
//!
//! Axum router configuration for webhook endpoints.

use axum::{
    Router,
    routing::any,
};
use std::sync::Arc;
use surrealdb_core::webhook::WebhookRegistry;

use super::handler::handle_webhook;

/// Shared state for webhook router
#[derive(Clone)]
pub struct WebhookState {
    pub registry: Arc<WebhookRegistry>,
}

/// Create the webhook router
pub fn webhook_router(registry: Arc<WebhookRegistry>) -> Router {
    let state = WebhookState { registry };

    Router::new()
        // Catch-all route for webhooks
        // Format: /webhook/{namespace}/{database}/{path...}
        .route("/webhook/{ns}/{db}/*path", any(handle_webhook))
        .route("/webhook/{ns}/{db}/", any(handle_webhook))
        .with_state(state)
}
