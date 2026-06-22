use crate::handlers::IamState;
use crate::models::{CreateUserRequest, UpdateUserRequest};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use lyxal_core::Result;
use lyxal_schema::User;
use std::sync::Arc;
use uuid::Uuid;

/// Creates the router for user administration.
pub fn router(state: Arc<IamState>) -> Router {
    Router::new()
        .route("/", post(create_user).get(list_users))
        .route("/:id", get(get_user).put(update_user).delete(delete_user))
        .with_state(state)
}

/// Create a new user.
#[utoipa::path(
    post,
    path = "/api/admin/iam/users",
    request_body = CreateUserRequest,
    responses(
        (status = 201, description = "User created successfully", body = User),
        (status = 400, description = "Invalid request")
    ),
    tag = "IAM - Users"
)]
pub async fn create_user(
    State(state): State<Arc<IamState>>,
    Json(payload): Json<CreateUserRequest>,
) -> Result<(StatusCode, Json<User>)> {
    let user = state
        .user_service
        .create_user(payload.username, payload.email, payload.password)
        .await?;
    Ok((StatusCode::CREATED, Json(user)))
}

/// Get a user by their unique ID.
#[utoipa::path(
    get,
    path = "/api/admin/iam/users/{id}",
    params(
        ("id" = Uuid, Path, description = "User ID")
    ),
    responses(
        (status = 200, description = "User found", body = User),
        (status = 404, description = "User not found")
    ),
    tag = "IAM - Users"
)]
pub async fn get_user(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<Json<User>> {
    let user = state.user_service.get_user_by_id(id).await?;
    Ok(Json(user))
}

/// List all users.
#[utoipa::path(
    get,
    path = "/api/admin/iam/users",
    responses(
        (status = 200, description = "List of users", body = [User])
    ),
    tag = "IAM - Users"
)]
pub async fn list_users(State(state): State<Arc<IamState>>) -> Result<Json<Vec<User>>> {
    // We use a default limit for administration list
    let users = state.user_service.list_users(100, 0).await?;
    Ok(Json(users))
}

/// Update a user's profile information.
#[utoipa::path(
    put,
    path = "/api/admin/iam/users/{id}",
    params(
        ("id" = Uuid, Path, description = "User ID")
    ),
    request_body = UpdateUserRequest,
    responses(
        (status = 200, description = "User updated successfully", body = User),
        (status = 404, description = "User not found")
    ),
    tag = "IAM - Users"
)]
pub async fn update_user(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
    Json(payload): Json<UpdateUserRequest>,
) -> Result<Json<User>> {
    let user = state
        .user_service
        .update_user_profile(id, payload.name, payload.avatar)
        .await?;
    Ok(Json(user))
}

/// Delete a user account.
#[utoipa::path(
    delete,
    path = "/api/admin/iam/users/{id}",
    params(
        ("id" = Uuid, Path, description = "User ID")
    ),
    responses(
        (status = 204, description = "User deleted successfully"),
        (status = 404, description = "User not found")
    ),
    tag = "IAM - Users"
)]
pub async fn delete_user(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<StatusCode> {
    state.user_service.delete_user(id).await?;
    Ok(StatusCode::NO_CONTENT)
}
