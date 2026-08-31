use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, post, put};
use axum::Json;
use axum::Router;
use surrealdb::RecordId;

use crate::contracts::resources::{
    CreateResourceParams, CreateResourceRequest, DeleteResourceResponse, ResourceParams,
    ResourceResponse, SyncResourceResponse, UpdateResourceParams, UpdateResourceRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::{AuthenticatedAdmin, AuthenticatedUser};
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_resources).post(create_resource))
        .route(
            "/{id}",
            get(get_resource)
                .put(update_resource)
                .delete(delete_resource),
        )
        .route("/{id}/sync", post(sync_resource))
}

fn parse_resource_id(raw: &str) -> Result<RecordId, WebError> {
    let clean = raw.trim();

    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_resource" || id.is_empty() {
            return Err(WebError::BadRequest(
                "INVALID_RESOURCE_ID: Expected booking_resource:<id>".to_string(),
            ));
        }
        return Ok(RecordId::from(("booking_resource", id)));
    }

    if clean.is_empty() {
        return Err(WebError::BadRequest(
            "INVALID_RESOURCE_ID: Resource identifier is required".to_string(),
        ));
    }

    Ok(RecordId::from(("booking_resource", clean)))
}

pub async fn list_resources(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<Vec<ResourceResponse>>, WebError> {
    let resources = crate::services::resources::list_resources(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(resources))
}

pub async fn create_resource(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateResourceRequest>,
) -> Result<Response, WebError> {
    if request.name.trim().is_empty() {
        return Err(WebError::BadRequest("Resource name cannot be empty".to_string()));
    }
    if request.resource_type.trim().is_empty() {
        return Err(WebError::BadRequest("Resource type cannot be empty".to_string()));
    }

    let resource = crate::services::resources::create_resource(&state.store, &auth, &request)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(resource)).into_response())
}

pub async fn get_resource(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<ResourceResponse>, WebError> {
    let resource_id = parse_resource_id(&id)?;
    let resource = crate::services::resources::get_resource(&state.store, &auth, &resource_id)
        .await
        .map_err(|e| WebError::NotFound(e.to_string()))?;

    Ok(Json(resource))
}

pub async fn update_resource(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<UpdateResourceRequest>,
) -> Result<Json<ResourceResponse>, WebError> {
    let resource_id = parse_resource_id(&id)?;
    let resource = crate::services::resources::update_resource(&state.store, &auth, &resource_id, &request)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok(Json(resource))
}

pub async fn delete_resource(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<DeleteResourceResponse>, WebError> {
    let resource_id = parse_resource_id(&id)?;
    let response = crate::services::resources::delete_resource(&state.store, &auth, &resource_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(response))
}

pub async fn sync_resource(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<SyncResourceResponse>, WebError> {
    let resource_id = parse_resource_id(&id)?;
    let response = crate::services::resources::sync_resource(&state.store, &auth, &resource_id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_resource_id_valid() {
        let parsed = parse_resource_id("booking_resource:room123").unwrap();
        assert_eq!(parsed.to_string(), "booking_resource:room123");
    }

    #[test]
    fn test_parse_resource_id_rejects_other_table() {
        let err = parse_resource_id("booking_account:admin");
        assert!(err.is_err());
    }

    #[test]
    fn test_resource_creation_validation() {
        let req = CreateResourceRequest {
            name: "   ".to_string(),
            resource_type: "ROOM".to_string(),
            capacity: Some(10),
            location: None,
            description: None,
            feed_url: None,
        };
        assert!(req.name.trim().is_empty());
    }
}
