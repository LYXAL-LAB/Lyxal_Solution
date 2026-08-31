use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, patch, post};
use axum::Json;
use axum::Router;

use crate::contracts::event_types::{
    CreateEventTypeParams, CreateEventTypeRequest, DeleteEventTypeParams,
    DeleteEventTypeResponse, EventTypeResponse, GetEventTypeParams, ListEventTypesParams,
    UpdateEventTypeParams, UpdateEventTypeRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

const RESERVED_SLUGS: &[&str] = &[
    "new", "edit", "admin", "api", "settings", "calendar", "oauth", "login", "logout", "dashboard",
];

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_event_types).post(create_event_type))
        .route(
            "/{slug}",
            get(get_event_type)
                .patch(update_event_type)
                .delete(delete_event_type),
        )
        .route("/{slug}/toggle", patch(toggle_event_type))
        .route(
            "/{slug}/resources",
            get(get_event_type_resources).put(update_event_type_resources),
        )
}

pub fn validate_title(title: &str) -> Result<(), WebError> {
    let clean = title.trim();
    if clean.is_empty() || clean.chars().count() > 150 {
        return Err(WebError::BadRequest(
            "INVALID_EVENT_TYPE_TITLE: Title must be between 1 and 150 characters".to_string(),
        ));
    }
    if clean.chars().any(char::is_control) {
        return Err(WebError::BadRequest(
            "INVALID_EVENT_TYPE_TITLE: Title contains invalid control characters".to_string(),
        ));
    }
    Ok(())
}

pub fn validate_slug(slug: &str) -> Result<(), WebError> {
    let clean = slug.trim();
    if clean.is_empty() || clean.len() > 100 {
        return Err(WebError::BadRequest(
            "INVALID_SLUG: Slug cannot be empty or exceed 100 characters".to_string(),
        ));
    }
    if clean.starts_with('-') || clean.ends_with('-') {
        return Err(WebError::BadRequest(
            "INVALID_SLUG: Slug cannot start or end with a hyphen".to_string(),
        ));
    }
    if clean.contains("--") {
        return Err(WebError::BadRequest(
            "INVALID_SLUG: Slug cannot contain consecutive hyphens".to_string(),
        ));
    }
    if !clean.chars().all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-') {
        return Err(WebError::BadRequest(
            "INVALID_SLUG: Slug can only contain lowercase alphanumeric characters and hyphens".to_string(),
        ));
    }
    if RESERVED_SLUGS.contains(&clean) {
        return Err(WebError::BadRequest(format!(
            "INVALID_SLUG: '{}' is a reserved word",
            clean
        )));
    }
    Ok(())
}

pub async fn list_event_types(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<Vec<EventTypeResponse>>, WebError> {
    let list = crate::services::event_types::list_event_types(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(list))
}

pub async fn create_event_type(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateEventTypeRequest>,
) -> Result<Response, WebError> {
    validate_title(&request.title)?;
    validate_slug(&request.slug)?;

    if request.duration_minutes == 0 || request.duration_minutes > 1440 {
        return Err(WebError::BadRequest(
            "INVALID_DURATION: Duration must be between 1 and 1440 minutes".to_string(),
        ));
    }

    let event_type = crate::services::event_types::create_event_type(&state.store, &auth, &request)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(event_type)).into_response())
}

pub async fn get_event_type(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
) -> Result<Json<EventTypeResponse>, WebError> {
    validate_slug(&slug)?;

    let record_id = surrealdb::RecordId::from(("booking_event_type", slug.as_str()));
    let event_type = crate::services::event_types::get_event_type(&state.store, &auth, &record_id)
        .await
        .map_err(|e| WebError::NotFound(e.to_string()))?;

    Ok(Json(event_type))
}

pub async fn update_event_type(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
    Json(request): Json<UpdateEventTypeRequest>,
) -> Result<Json<EventTypeResponse>, WebError> {
    validate_slug(&slug)?;

    if let Some(ref title) = request.title {
        validate_title(title)?;
    }
    if let Some(ref new_slug) = request.slug {
        validate_slug(new_slug)?;
    }
    if let Some(duration) = request.duration_minutes {
        if duration == 0 || duration > 1440 {
            return Err(WebError::BadRequest(
                "INVALID_DURATION: Duration must be between 1 and 1440 minutes".to_string(),
            ));
        }
    }

    let record_id = surrealdb::RecordId::from(("booking_event_type", slug.as_str()));
    let event_type = crate::services::event_types::update_event_type(&state.store, &auth, &record_id, &request)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok(Json(event_type))
}

pub async fn delete_event_type(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
) -> Result<Json<DeleteEventTypeResponse>, WebError> {
    validate_slug(&slug)?;

    let record_id = surrealdb::RecordId::from(("booking_event_type", slug.as_str()));
    let response = crate::services::event_types::delete_event_type(&state.store, &auth, &record_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    if !response.deleted {
        return Err(WebError::Conflict(
            "EVENT_TYPE_DELETE_FORBIDDEN: Event type cannot be deleted (active bookings exist)".to_string(),
        ));
    }

    Ok(Json(response))
}

pub async fn toggle_event_type(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
) -> Result<Json<crate::contracts::event_types::ToggleEventTypeResponse>, WebError> {
    validate_slug(&slug)?;
    let record_id = surrealdb::RecordId::from(("booking_event_type", slug.as_str()));
    let response = crate::services::event_types::toggle_event_type(&state.store, &auth, &record_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(response))
}

pub async fn get_event_type_resources(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
) -> Result<Json<Vec<String>>, WebError> {
    validate_slug(&slug)?;
    let record_id = surrealdb::RecordId::from(("booking_event_type", slug.as_str()));
    let resources = crate::services::event_types::get_event_type_resources(&state.store, &auth, &record_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(resources))
}

pub async fn update_event_type_resources(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(slug): Path<String>,
    Json(payload): Json<crate::contracts::event_types::EventTypeResourcesRequest>,
) -> Result<Json<crate::contracts::event_types::EventTypeResourcesResponse>, WebError> {
    validate_slug(&slug)?;
    let response = crate::services::event_types::update_event_type_resources(
        &state.store,
        &auth,
        &slug,
        &payload.resource_ids,
    )
    .await
    .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_slug_validation_advanced() {
        assert!(validate_slug("consultation-30min").is_ok());
        assert!(validate_slug("-consultation").is_err());
        assert!(validate_slug("consultation-").is_err());
        assert!(validate_slug("consultation--30min").is_err());
        assert!(validate_slug("Consultation").is_err());
        assert!(validate_slug("admin").is_err());
        assert!(validate_slug("new").is_err());
    }

    #[test]
    fn test_title_validation_advanced() {
        assert!(validate_title("Consultation Médicale").is_ok());
        assert!(validate_title("   ").is_err());
        assert!(validate_title(&"a".repeat(151)).is_err());
        assert!(validate_title("Title\nWith\x00Control").is_err());
    }
}
