use crate::handlers::IamState;
use crate::models::{CreateTenantRequest, UpdateTenantRequest};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    routing::{delete, get, post, put},
    Json, Router,
};
use lyxal_core::Result;
use lyxal_schema::Tenant;
use std::sync::Arc;
use uuid::Uuid;

/// Creates the router for tenant administration.
pub fn router(state: Arc<IamState>) -> Router {
    Router::new()
        .route("/", post(create_tenant).get(list_tenants))
        .route(
            "/:id",
            get(get_tenant).put(update_tenant).delete(delete_tenant),
        )
        .with_state(state)
}

/// Create a new tenant.
#[utoipa::path(
    post,
    path = "/api/admin/iam/tenants",
    request_body = CreateTenantRequest,
    responses(
        (status = 201, description = "Tenant created successfully", body = Tenant),
        (status = 400, description = "Invalid request"),
        (status = 409, description = "Slug already in use")
    ),
    tag = "IAM - Tenants"
)]
pub async fn create_tenant(
    State(state): State<Arc<IamState>>,
    Json(payload): Json<CreateTenantRequest>,
) -> Result<(StatusCode, Json<Tenant>)> {
    let tenant = state
        .tenant_service
        .create_tenant(payload.name, payload.slug)
        .await?;
    Ok((StatusCode::CREATED, Json(tenant)))
}

/// Get a tenant by its unique ID.
#[utoipa::path(
    get,
    path = "/api/admin/iam/tenants/{id}",
    params(
        ("id" = Uuid, Path, description = "Tenant ID")
    ),
    responses(
        (status = 200, description = "Tenant found", body = Tenant),
        (status = 404, description = "Tenant not found")
    ),
    tag = "IAM - Tenants"
)]
pub async fn get_tenant(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<Json<Tenant>> {
    let tenant = state.tenant_service.get_tenant_by_id(id).await?;
    Ok(Json(tenant))
}

/// List all tenants in the system.
#[utoipa::path(
    get,
    path = "/api/admin/iam/tenants",
    responses(
        (status = 200, description = "List of tenants", body = [Tenant])
    ),
    tag = "IAM - Tenants"
)]
pub async fn list_tenants(State(state): State<Arc<IamState>>) -> Result<Json<Vec<Tenant>>> {
    let tenants = state.tenant_service.list_tenants(100, 0).await?;
    Ok(Json(tenants))
}

/// Update a tenant's information.
#[utoipa::path(
    put,
    path = "/api/admin/iam/tenants/{id}",
    params(
        ("id" = Uuid, Path, description = "Tenant ID")
    ),
    request_body = UpdateTenantRequest,
    responses(
        (status = 200, description = "Tenant updated successfully", body = Tenant),
        (status = 404, description = "Tenant not found")
    ),
    tag = "IAM - Tenants"
)]
pub async fn update_tenant(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
    Json(payload): Json<UpdateTenantRequest>,
) -> Result<Json<Tenant>> {
    let tenant = state
        .tenant_service
        .update_tenant(id, payload.name, payload.logo)
        .await?;
    Ok(Json(tenant))
}

/// Delete a tenant.
#[utoipa::path(
    delete,
    path = "/api/admin/iam/tenants/{id}",
    params(
        ("id" = Uuid, Path, description = "Tenant ID")
    ),
    responses(
        (status = 204, description = "Tenant deleted successfully"),
        (status = 404, description = "Tenant not found")
    ),
    tag = "IAM - Tenants"
)]
pub async fn delete_tenant(
    State(state): State<Arc<IamState>>,
    Path(id): Path<Uuid>,
) -> Result<StatusCode> {
    state.tenant_service.delete_tenant(id).await?;
    Ok(StatusCode::NO_CONTENT)
}

