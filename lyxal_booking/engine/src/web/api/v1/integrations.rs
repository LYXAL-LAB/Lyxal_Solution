use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, post};
use axum::Json;
use axum::Router;
use surrealdb::RecordId;

use crate::contracts::integrations::{
    CreateWebhookRequest, DeleteWebhookParams, DeleteWebhookResponse, GetWebhookParams,
    ListWebhooksParams, WebhookResponse, TestWebhookResponse,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

const ALLOWED_TOPICS: &[&str] = &[
    "booking.created",
    "booking.confirmed",
    "booking.rescheduled",
    "booking.cancelled",
    "calendar.sync_failed",
];

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/webhooks", get(list_webhooks).post(create_webhook))
        .route("/webhooks/{id}", get(get_webhook).delete(delete_webhook))
        .route("/webhooks/{id}/test", post(test_webhook))
}

pub fn parse_webhook_id(raw: &str) -> Result<RecordId, WebError> {
    let clean = raw.trim();

    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_webhook" || id.is_empty() {
            return Err(WebError::BadRequest(
                "INVALID_WEBHOOK_ID: Expected booking_webhook:<id>".to_string(),
            ));
        }
        return Ok(RecordId::from(("booking_webhook", id)));
    }

    if clean.is_empty() {
        return Err(WebError::BadRequest(
            "INVALID_WEBHOOK_ID: Identifier is required".to_string(),
        ));
    }

    Ok(RecordId::from(("booking_webhook", clean)))
}

pub fn validate_webhook_url(url: &str) -> Result<(), WebError> {
    let clean = url.trim().to_lowercase();
    if !clean.starts_with("http://") && !clean.starts_with("https://") {
        return Err(WebError::BadRequest(
            "INVALID_WEBHOOK_URL: URL must start with http:// or https://".to_string(),
        ));
    }
    Ok(())
}

pub fn validate_topics(events: &[String]) -> Result<(), WebError> {
    if events.is_empty() {
        return Err(WebError::BadRequest("INVALID_TOPICS: At least one event topic must be selected".to_string()));
    }

    for topic in events {
        if !ALLOWED_TOPICS.contains(&topic.as_str()) {
            return Err(WebError::BadRequest(format!(
                "INVALID_TOPICS: Topic '{}' is not recognized",
                topic
            )));
        }
    }

    Ok(())
}

pub async fn list_webhooks(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<Vec<WebhookResponse>>, WebError> {
    let webhooks = crate::services::integrations::list_webhooks(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to list webhooks: {}", e)))?;

    Ok(Json(webhooks))
}

pub async fn create_webhook(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateWebhookRequest>,
) -> Result<Response, WebError> {
    if request.name.trim().is_empty() {
        return Err(WebError::BadRequest("Webhook name cannot be empty".to_string()));
    }
    validate_webhook_url(&request.target_url)?;
    validate_topics(&request.events)?;

    let response = crate::services::integrations::create_webhook(
        &state.store,
        &state.crypto,
        &auth,
        &request,
    )
    .await
    .map_err(|e| WebError::Internal(format!("Failed to create webhook: {}", e)))?;

    Ok((StatusCode::CREATED, Json(response)).into_response())
}

pub async fn get_webhook(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<WebhookResponse>, WebError> {
    let webhook_rec = parse_webhook_id(&id)?;

    let webhook = crate::services::integrations::get_webhook(&state.store, &auth, &webhook_rec)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to fetch webhook: {}", e)))?;

    Ok(Json(webhook))
}

pub async fn delete_webhook(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<DeleteWebhookResponse>, WebError> {
    let webhook_rec = parse_webhook_id(&id)?;

    let response = crate::services::integrations::delete_webhook(&state.store, &auth, &webhook_rec)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to delete webhook: {}", e)))?;

    if !response.deleted {
        return Err(WebError::NotFound("Webhook not found or cannot be deleted".to_string()));
    }

    Ok(Json(response))
}

pub async fn test_webhook(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<TestWebhookResponse>, WebError> {
    let webhook_rec = parse_webhook_id(&id)?;

    let response = crate::services::integrations::test_webhook(&state.store, &auth, &webhook_rec)
        .await
        .map_err(|e| WebError::Internal(format!("Webhook test failed: {}", e)))?;

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_webhook_id_valid() {
        let parsed = parse_webhook_id("booking_webhook:wh123").unwrap();
        assert_eq!(parsed.to_string(), "booking_webhook:wh123");
    }

    #[test]
    fn test_validate_topics_allowlist() {
        assert!(validate_topics(&["booking.created".to_string()]).is_ok());
        assert!(validate_topics(&["invalid.topic".to_string()]).is_err());
        assert!(validate_topics(&[]).is_err());
    }
}
