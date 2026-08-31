/**
 * 🏛️ LYXAL OS — Axum Handlers REST API v1 pour Platform SuperAdmin
 */

use axum::extract::{Query, State};
use axum::routing::{get, patch};
use axum::{Json, Router};
use serde::Deserialize;

use lyxal_surreal::LyxalSurrealCall;
use crate::contracts::platform_admin::*;
use crate::services::platform_admin;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::WebError;
use crate::web::state::AppState;

#[derive(Debug, Deserialize)]
pub struct ListQuery {
    pub limit: Option<u32>,
}

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/metrics", get(get_platform_metrics))
        .route("/tenants", get(list_platform_tenants))
        .route("/users", get(list_platform_users))
        .route("/audit-logs", get(get_platform_audit_logs))
        .route("/settings", get(get_platform_settings).patch(update_platform_settings))
}

pub async fn get_platform_metrics(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
) -> Result<Json<PlatformMetricsResponse>, WebError> {
    let metrics = platform_admin::get_platform_metrics(&state.store)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_PLATFORM_METRICS: {}", e)))?;

    Ok(Json(metrics))
}

pub async fn list_platform_tenants(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
    Query(query): Query<ListQuery>,
) -> Result<Json<PlatformTenantsPage>, WebError> {
    let page = platform_admin::list_platform_tenants(&state.store, query.limit)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_LIST_PLATFORM_TENANTS: {}", e)))?;

    Ok(Json(page))
}

pub async fn list_platform_users(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
    Query(query): Query<ListQuery>,
) -> Result<Json<PlatformUsersPage>, WebError> {
    let page = platform_admin::list_platform_users(&state.store, query.limit)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_LIST_PLATFORM_USERS: {}", e)))?;

    Ok(Json(page))
}

pub async fn get_platform_audit_logs(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
    Query(query): Query<ListQuery>,
) -> Result<Json<PlatformAuditLogsPage>, WebError> {
    let page = platform_admin::get_platform_audit_logs(&state.store, query.limit)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_PLATFORM_AUDIT_LOGS: {}", e)))?;

    Ok(Json(page))
}

pub async fn get_platform_settings(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
) -> Result<Json<PlatformSettingsResponse>, WebError> {
    let settings = platform_admin::get_platform_settings(&state.store)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_GET_PLATFORM_SETTINGS: {}", e)))?;

    Ok(Json(settings))
}

pub async fn update_platform_settings(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
    Json(request): Json<UpdatePlatformSettingsRequest>,
) -> Result<Json<PlatformSettingsResponse>, WebError> {
    let settings = platform_admin::update_platform_settings(&state.store, &request)
        .await
        .map_err(|e| WebError::Internal(format!("FAILED_UPDATE_PLATFORM_SETTINGS: {}", e)))?;

    Ok(Json(settings))
}
