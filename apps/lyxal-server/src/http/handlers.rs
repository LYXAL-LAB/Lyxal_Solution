//! Routes de description du serveur et de ses mesures. `/live`, `/ready` et `/health` sont
//! celles de `lyxal_host::http::health_routes`.

use crate::context::AppContext;
use axum::{extract::State, Json};
use lyxal_host::metrics::MetricsSnapshot;
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

pub async fn metrics(State(context): State<AppContext>) -> Json<MetricsSnapshot> {
    Json(context.metrics.snapshot())
}
