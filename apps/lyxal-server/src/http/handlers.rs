use crate::{
    context::AppContext,
    health::HealthState,
};
use axum::{
    Json,
    extract::State,
    http::StatusCode,
    response::IntoResponse,
};
use serde::Serialize;

#[derive(Serialize)]
pub struct RootResponse {
    name: String,
    version: String,
    environment: String,
    instance_id: String,
}

pub async fn root(State(context): State<AppContext>) -> Json<RootResponse> {
    Json(RootResponse {
        name: context.config.application.name.clone(),
        version: context.config.application.version.clone(),
        environment: context.config.application.environment.clone(),
        instance_id: context.config.application.instance_id.clone(),
    })
}

pub async fn live() -> StatusCode {
    StatusCode::NO_CONTENT
}

pub async fn ready(State(context): State<AppContext>) -> impl IntoResponse {
    if context.health.ready().await {
        StatusCode::NO_CONTENT
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    }
}

pub async fn health(State(context): State<AppContext>) -> impl IntoResponse {
    let snapshot = context.health.snapshot().await;
    let status = match snapshot.state {
        HealthState::Healthy | HealthState::Degraded => StatusCode::OK,
        HealthState::Starting => StatusCode::SERVICE_UNAVAILABLE,
        HealthState::Unhealthy | HealthState::Stopping => StatusCode::SERVICE_UNAVAILABLE,
    };
    (status, Json(snapshot))
}

pub async fn metrics(State(context): State<AppContext>) -> Json<crate::metrics::MetricsSnapshot> {
    Json(context.metrics.snapshot())
}

pub async fn modules(State(context): State<AppContext>) -> Json<Vec<crate::runtime::ModuleStatus>> {
    Json(context.runtime.statuses().await)
}
