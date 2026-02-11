//! Webhook Handler
//!
//! HTTP handler for incoming webhook requests.

use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{HeaderMap, Method, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use std::collections::HashMap;
use surrealdb_core::webhook::{WebhookDispatcher, DispatchResult};

use super::router::WebhookState;

/// Handle incoming webhook request
pub async fn handle_webhook(
    State(state): State<WebhookState>,
    method: Method,
    Path((ns, db, path)): Path<(String, String, String)>,
    headers: HeaderMap,
    body: Bytes,
) -> Response {
    // Convert headers to HashMap
    let headers_map: HashMap<String, String> = headers
        .iter()
        .filter_map(|(k, v)| {
            v.to_str()
                .ok()
                .map(|val| (k.as_str().to_lowercase(), val.to_string()))
        })
        .collect();

    // Build the full path
    let full_path = if path.is_empty() {
        "/".to_string()
    } else {
        format!("/{}", path)
    };

    tracing::debug!(
        event = "webhook:http_received",
        ns = %ns,
        db = %db,
        method = %method,
        path = %full_path,
        "Webhook HTTP request received"
    );

    // Create dispatcher with the registry
    let dispatcher = WebhookDispatcher::new(state.registry.clone());

    // Dispatch the webhook
    let result = dispatcher
        .dispatch(&ns, &db, method.as_str(), &full_path, &body, headers_map)
        .await;

    // Convert dispatch result to HTTP response
    match result {
        DispatchResult::Success { result } => {
            let response_body = result.unwrap_or(json!({"status": "ok"}));
            (StatusCode::OK, Json(response_body)).into_response()
        }
        DispatchResult::Rejected { reason, status_code } => {
            let status = StatusCode::from_u16(status_code).unwrap_or(StatusCode::BAD_REQUEST);
            let body = json!({
                "error": reason,
                "status": status_code
            });
            (status, Json(body)).into_response()
        }
        DispatchResult::Failed { error } => {
            tracing::error!(
                event = "webhook:handler_error",
                error = %error,
                "Webhook handler failed"
            );
            let body = json!({
                "error": "Internal server error",
                "details": error
            });
            (StatusCode::INTERNAL_SERVER_ERROR, Json(body)).into_response()
        }
    }
}
