use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{delete, get, post},
    Json, Router,
};

use crate::contracts::availability::{
    AvailabilityQuery, SaveAvailabilityOverrideRequest, SaveAvailabilityScheduleRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/slots", get(get_slots))
        .route(
            "/schedules",
            get(get_schedules).post(save_schedule),
        )
        .route(
            "/overrides",
            get(get_overrides).post(save_override),
        )
        .route("/overrides/{id}", delete(delete_override))
}

async fn get_slots(
    State(state): State<AppState>,
    Query(query): Query<AvailabilityQuery>,
) -> Result<impl IntoResponse, WebError> {
    let response = crate::services::availability::get_available_slots(&state.store, None, &query)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::OK, Json(response)))
}

async fn get_schedules(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<impl IntoResponse, WebError> {
    let schedules = crate::services::availability::get_availability_schedules(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(schedules)))
}

async fn save_schedule(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(payload): Json<SaveAvailabilityScheduleRequest>,
) -> Result<impl IntoResponse, WebError> {
    let schedule = crate::services::availability::save_availability_schedule(&state.store, &auth, &payload)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(schedule)))
}

async fn get_overrides(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<impl IntoResponse, WebError> {
    let overrides = crate::services::availability::get_availability_overrides(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(overrides)))
}

async fn save_override(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(payload): Json<SaveAvailabilityOverrideRequest>,
) -> Result<impl IntoResponse, WebError> {
    let override_res = crate::services::availability::save_availability_override(&state.store, &auth, &payload)
        .await
        .map_err(|e| WebError::BadRequest(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(override_res)))
}

async fn delete_override(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, WebError> {
    let res = crate::services::availability::delete_availability_override(&state.store, &auth, &id)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::OK, Json(res)))
}
