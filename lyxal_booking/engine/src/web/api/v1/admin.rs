/**
 * 🏛️ LYXAL OS — Axum Handlers REST API v1 pour Tenant Admin
 */

use axum::extract::{Path, Query, State};
use axum::response::IntoResponse;
use axum::routing::{get, patch};
use axum::{Json, Router};
use serde::Deserialize;

use lyxal_surreal::LyxalSurrealCall;
use crate::contracts::admin::*;
use crate::services::admin;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::WebError;
use crate::web::state::AppState;

#[derive(Debug, Deserialize)]
pub struct ListQuery {
    pub limit: Option<u32>,
}

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/metrics", get(get_tenant_metrics))
        .route("/users", get(list_tenant_users))
        .route("/users/{user_id}/role", patch(update_tenant_user_role))
        .route("/audit-logs", get(get_tenant_audit_logs))
        .route("/settings", get(get_tenant_settings).patch(update_tenant_settings))
}

pub async fn get_tenant_metrics(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<TenantMetricsResponse>, WebError> {
    let tenant_id = auth.user_id.clone();
    let metrics = admin::get_tenant_metrics(&state.store, &tenant_id)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_TENANT_METRICS: {}", e)))?;

    Ok(Json(metrics))
}

pub async fn list_tenant_users(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Query(query): Query<ListQuery>,
) -> Result<Json<TenantUsersPage>, WebError> {
    let tenant_id = auth.user_id.clone();
    let page = admin::list_tenant_users(&state.store, &tenant_id, query.limit)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_LIST_TENANT_USERS: {}", e)))?;

    Ok(Json(page))
}

pub async fn update_tenant_user_role(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(target_user_id): Path<String>,
    Json(request): Json<UpdateTenantUserRoleRequest>,
) -> Result<impl IntoResponse, WebError> {
    let tenant_id = auth.user_id.clone();
    let result = admin::update_tenant_user_role(&state.store, &tenant_id, &auth.user_id, &target_user_id, &request)
        .await
        .map_err(|e| WebError::BadRequest(format!("FAILED_UPDATE_USER_ROLE: {}", e)))?;

    Ok(Json(result))
}

pub async fn get_tenant_audit_logs(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Query(query): Query<ListQuery>,
) -> Result<Json<TenantAuditLogsPage>, WebError> {
    let tenant_id = auth.user_id.clone();
    let page = admin::get_tenant_audit_logs(&state.store, &tenant_id, query.limit)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_TENANT_AUDIT_LOGS: {}", e)))?;

    Ok(Json(page))
}

pub async fn get_tenant_settings(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<TenantSettingsResponse>, WebError> {
    let tenant_id = auth.user_id.clone();
    let settings = admin::get_tenant_settings(&state.store, &tenant_id)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_TENANT_SETTINGS: {}", e)))?;

    Ok(Json(settings))
}

pub async fn update_tenant_settings(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<UpdateTenantSettingsRequest>,
) -> Result<Json<TenantSettingsResponse>, WebError> {
    let tenant_id = auth.user_id.clone();
    let settings = admin::update_tenant_settings(&state.store, &tenant_id, &request)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_UPDATE_TENANT_SETTINGS: {}", e)))?;

    Ok(Json(settings))
}
