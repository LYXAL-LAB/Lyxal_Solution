use crate::{
    context::AppContext,
    error::ServerError,
    health::{HealthSnapshot, HealthState},
};
use axum::{extract::State, http::StatusCode, response::IntoResponse, Json};
use lyxal_runtime::health::{GlobalHealthStatus, HealthConfig, HealthStatus};
use lyxal_runtime::reconciler::observer::RuntimeObserver;
use lyxal_runtime::{ModuleContext, ModuleState};
use lyxal_surreal::SurrealValue;
use serde::Serialize;
use serde_json::Value;

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

#[derive(Serialize)]
pub struct HealthResponse {
    /// Composants du serveur (processus, base de données).
    server: HealthSnapshot,
    /// Santé des modules, évaluée par le runtime (`ModuleHealthCheck`), sans le message des
    /// sondes (détail interne).
    modules: ModulesHealth,
}

#[derive(Serialize)]
pub struct ModulesHealth {
    status: GlobalHealthStatus,
    modules: std::collections::BTreeMap<String, HealthStatus>,
}

pub async fn health(State(context): State<AppContext>) -> Result<impl IntoResponse, ServerError> {
    let server = context.health.snapshot().await;
    let observer = RuntimeObserver::new(
        context.runtime.store(),
        context.runtime.registry(),
        context.runtime.lifecycle(),
    );
    let actual = observer.observe().await?;
    let modules = context
        .runtime
        .health_engine(HealthConfig::default())
        .check_all(&actual, &ModuleContext::new("lyxal_server"))
        .await;
    let serving = matches!(server.state, HealthState::Healthy | HealthState::Degraded)
        && modules.global_status != GlobalHealthStatus::Unhealthy;
    let status = if serving {
        StatusCode::OK
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    };
    let modules = ModulesHealth {
        status: modules.global_status,
        modules: modules
            .modules
            .into_iter()
            .map(|(id, result)| (id.to_string(), result.status))
            .collect(),
    };
    Ok((status, Json(HealthResponse { server, modules })))
}

pub async fn metrics(State(context): State<AppContext>) -> Json<crate::metrics::MetricsSnapshot> {
    Json(context.metrics.snapshot())
}

#[derive(Serialize)]
pub struct ModuleStatus {
    id: String,
    name: String,
    version: String,
    state: Option<ModuleState>,
}

/// Nœud vivant de la base (`runtime_node`, battement récent), quel que soit son hôte.
#[derive(Serialize)]
pub struct NodeStatus {
    node_id: String,
    host: String,
    /// Modules démarrés par le nœud.
    modules: Vec<String>,
    started_at: Value,
    seen_at: Value,
    /// Le nœud est ce processus.
    current: bool,
}

#[derive(Serialize)]
pub struct ModulesResponse {
    /// Hôte de ce binaire (`lyxal_server`).
    host: String,
    /// Nœud de ce processus.
    node_id: String,
    /// Modules hébergés par ce processus et leur état.
    modules: Vec<ModuleStatus>,
    /// Nœuds vivants de la base, de tous les hôtes, du battement le plus récent au plus ancien.
    nodes: Vec<NodeStatus>,
}

fn date(value: lyxal_surreal::Datetime) -> Value {
    value.into_value().into_json_value()
}

pub async fn modules(
    State(context): State<AppContext>,
) -> Result<Json<ModulesResponse>, ServerError> {
    let runtime = &context.runtime;
    let mut modules: Vec<ModuleStatus> = runtime
        .modules()
        .iter()
        .map(|module| {
            let descriptor = module.descriptor();
            ModuleStatus {
                id: descriptor.id.to_string(),
                name: descriptor.name.clone(),
                version: descriptor.version.to_string(),
                state: runtime.module_state(&descriptor.id),
            }
        })
        .collect();
    modules.sort_by(|a, b| a.id.cmp(&b.id));
    let current = runtime.node_id().to_string();
    let nodes = runtime
        .nodes()
        .await?
        .into_iter()
        .filter(|node| node.alive == Some(true))
        .map(|node| NodeStatus {
            current: node.node_id == current,
            node_id: node.node_id,
            host: node.host,
            modules: node.modules,
            started_at: date(node.started_at),
            seen_at: date(node.seen_at),
        })
        .collect();
    Ok(Json(ModulesResponse {
        host: runtime.host_id().to_string(),
        node_id: current,
        modules,
        nodes,
    }))
}
