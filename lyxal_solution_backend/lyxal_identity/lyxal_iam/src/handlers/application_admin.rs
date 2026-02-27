use crate::handlers::IamState;
use crate::models::{CreateApplicationRequest, UpdateApplicationRequest};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    routing::{delete, get, post, put},
    Json, Router,
};
use lyxal_core::Result;
use lyxal_schema::Application;
use std::sync::Arc;
use uuid::Uuid;

/// Creates the router for application (OAuth2 Client) administration.
pub fn router(state: Arc<IamState>) -> Router {
    Router::new()
        .route("/", post(create_application).get(list_applications))
        .route(
            "/:id",
            get(get_application)
                .put(update_application)
                .delete(delete_application),
        )
        .route("/:id/secret-rotation", post(rotate_secret))
        .with_state(state)
}

/// Create a new application (OAuth2 Client).
#[utoipa::path(
    post,
    path = "/api/admin/iam/applications",
    request_body = CreateApplicationRequest,
    responses(
        (status = 201, description = "Application created successfully", body = Application),
        (status = 400, description = "Invalid request")
    ),
    tag = "IAM - Applications"
)]
pub async fn create_application(
    State(state): State<Arc<IamState>>,
    Json(payload): Json<CreateApplicationRequest>,
) -> Result<(StatusCode, Json<Application>)> {
    let app = state
        .application_service
        .create_application(
            payload.name,
            payload.application_type,
            payload.redirect_uris,
        )
        .await?;
    Ok((StatusCode::CREATED, Json(app)))
}

/// Get application details by its unique ID.
#[utoipa::path(
    get,
    path = "/api/admin/iam/applications/{id}",
    params(
        ("id" = Uuid, Path, description = "Application ID")
    ),
    responses(
        (status = 200, description = "Application found", body = Application),
        (status = 404, description = "Application not found")
    ),
    tag = "IAM - Applications"
)]
pub async fn get_application(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<Json<Application>> {
    let app = state.application_service.get_application_by_id(id).await?;
    Ok(Json(app))
}

/// List all applications registered in the system.
#[utoipa::path(
    get,
    path = "/api/admin/iam/applications",
    responses(
        (status = 200, description = "List of applications", body = [Application])
    ),
    tag = "IAM - Applications"
)]
pub async fn list_applications(
    State(state): State<Arc<IamState>>,
) -> Result<Json<Vec<Application>>> {
    let apps = state.application_service.list_applications().await?;
    Ok(Json(apps))
}

/// Update an application's configuration.
#[utoipa::path(
    put,
    path = "/api/admin/iam/applications/{id}",
    params(
        ("id" = Uuid, Path, description = "Application ID")
    ),
    request_body = UpdateApplicationRequest,
    responses(
        (status = 200, description = "Application updated successfully", body = Application),
        (status = 404, description = "Application not found")
    ),
    tag = "IAM - Applications"
)]
pub async fn update_application(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
    Json(payload): Json<UpdateApplicationRequest>,
) -> Result<Json<Application>> {
    let app = state
        .application_service
        .update_application_config(
            id,
            payload.name,
            payload.description,
            payload.redirect_uris,
            payload.post_logout_redirect_uris,
            payload.allowed_cors_origins,
        )
        .await?;
    Ok(Json(app))
}

/// Rotate the client secret for a given application.
#[utoipa::path(
    post,
    path = "/api/admin/iam/applications/{id}/secret-rotation",
    params(
        ("id" = Uuid, Path, description = "Application ID")
    ),
    responses(
        (status = 200, description = "Secret rotated successfully", body = Application),
        (status = 404, description = "Application not found")
    ),
    tag = "IAM - Applications"
)]
pub async fn rotate_secret(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<Json<Application>> {
    let app = state.application_service.rotate_client_secret(id).await?;
    Ok(Json(app))
}

/// Delete an application.
#[utoipa::path(
    delete,
    path = "/api/admin/iam/applications/{id}",
    params(
        ("id" = Uuid, Path, description = "Application ID")
    ),
    responses(
        (status = 204, description = "Application deleted successfully"),
        (status = 404, description = "Application not found")
    ),
    tag = "IAM - Applications"
)]
pub async fn delete_application(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<StatusCode> {
    state.application_service.delete_application(id).await?;
    Ok(StatusCode::NO_CONTENT)
}
