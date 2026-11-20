// SPDX-License-Identifier: AGPL-3.0-only

//! Port HTTP de l'hôte : `/live`, `/ready`, `/health` (ceux de `lyxal_host`, même contrat que
//! `lyxal-server`) et `/metrics` (écoutes de courrier et budget mémoire, sans adresse IP). Le
//! port se lie par défaut à `127.0.0.1` : les routes ne demandent aucun jeton.

use crate::error::GroupwareError;
use crate::modules::HOST_ID;
use crate::net::{MailNet, MailSnapshot};
use axum::extract::State;
use axum::routing::get;
use axum::{Json, Router};
use lyxal_host::health::HealthRegistry;
use lyxal_host::http::{health_routes, HostHealth};
use lyxal_runtime::LyxalRuntime;
use serde::Serialize;
use std::sync::Arc;
use std::time::Instant;

#[derive(Clone)]
struct MetricsState {
    started_at: Instant,
    mail: MailNet,
}

#[derive(Serialize)]
struct MetricsResponse {
    uptime_seconds: u64,
    mail: MailSnapshot,
}

/// Routeur du port HTTP de l'hôte.
pub fn router(health: HealthRegistry, runtime: Arc<LyxalRuntime>, mail: MailNet) -> Router {
    Router::new()
        .route("/metrics", get(metrics))
        .with_state(MetricsState {
            started_at: Instant::now(),
            mail,
        })
        .merge(health_routes::<(), GroupwareError>(HostHealth::new(
            health, runtime, HOST_ID,
        )))
}

async fn metrics(State(state): State<MetricsState>) -> Json<MetricsResponse> {
    Json(MetricsResponse {
        uptime_seconds: state.started_at.elapsed().as_secs(),
        mail: state.mail.snapshot(),
    })
}
