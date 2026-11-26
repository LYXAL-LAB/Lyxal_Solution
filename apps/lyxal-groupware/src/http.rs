// SPDX-License-Identifier: AGPL-3.0-only

//! Port HTTP de l'hôte : `/live`, `/ready`, `/health` (ceux de `lyxal_host`, même contrat que
//! `lyxal-server`) et `/metrics` (écoutes de courrier et budget mémoire, sans adresse IP). Le
//! port se lie par défaut à `127.0.0.1` : les routes ne demandent aucun jeton. Au choix de
//! l'exploitant, le port se sert derrière un répartiteur qui envoie l'en-tête PROXY
//! (`http.proxy_networks`) et en TLS (`http.tls`), avec les certificats des écoutes.

use crate::config::{GroupwareConfig, TlsMinVersion};
use crate::error::GroupwareError;
use crate::net::certificates::Certificates;
use crate::net::proxy;
use crate::net::tls::ListenerTls;
use crate::net::{MailNet, MailSnapshot};
use axum::extract::State;
use axum::routing::get;
use axum::{Json, Router};
use lyxal_host::http::{health_routes, HostHealth, HttpStream, PrepareConnection};
use lyxal_host::net::{log_network, normalize_ip};
use proxy_header::io::ProxiedStream;
use serde::Serialize;
use std::net::SocketAddr;
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
pub fn router(health: HostHealth, mail: MailNet) -> Router {
    Router::new()
        .route("/metrics", get(metrics))
        .with_state(MetricsState {
            started_at: Instant::now(),
            mail,
        })
        .merge(health_routes::<(), GroupwareError>(health))
}

async fn metrics(State(state): State<MetricsState>) -> Json<MetricsResponse> {
    Json(MetricsResponse {
        uptime_seconds: state.started_at.elapsed().as_secs(),
        mail: state.mail.snapshot(),
    })
}

/// Préparation des connexions du port HTTP : en-tête PROXY depuis `http.proxy_networks` (exigé
/// depuis eux, jamais lu ailleurs), puis poignée de main TLS si `http.tls`. `None` : port servi
/// tel quel (`lyxal_host::http::serve`).
pub fn prepare(
    config: &GroupwareConfig,
    certificates: Option<&Arc<Certificates>>,
) -> Result<Option<PrepareConnection>, GroupwareError> {
    let http = &config.http;
    if !http.tls && http.proxy_networks.is_empty() {
        return Ok(None);
    }
    let tls = if http.tls {
        let store = certificates
            .ok_or_else(|| GroupwareError::Configuration {
                message: "http.tls = true : aucun certificat chargé".into(),
            })?
            .store();
        Some(ListenerTls::new(
            store,
            "http",
            &[b"h2", b"http/1.1"],
            TlsMinVersion::Tls12,
            config.handshake_timeout(),
        )?)
    } else {
        None
    };
    let networks = Arc::new(http.proxy_networks.clone());
    let timeout = config.proxy_header_timeout();
    Ok(Some(Arc::new(move |stream, peer: SocketAddr| {
        let networks = networks.clone();
        let tls = tls.clone();
        Box::pin(async move {
            let peer = SocketAddr::new(normalize_ip(peer.ip()), peer.port());
            let (stream, remote) = if networks.iter().any(|net| net.contains(peer.ip())) {
                match proxy::read_header(stream, timeout).await {
                    Ok((stream, Some(addresses))) => (stream, addresses.remote),
                    Ok((stream, None)) => (stream, peer),
                    Err(error) => {
                        tracing::info!(
                            network = %log_network(peer.ip()),
                            %error,
                            "port HTTP : en-tête PROXY refusé"
                        );
                        return None;
                    }
                }
            } else {
                (ProxiedStream::unproxied(stream), peer)
            };
            let Some(tls) = tls else {
                return Some((Box::new(stream) as Box<dyn HttpStream>, remote));
            };
            match tls.accept(stream).await {
                Ok((stream, _)) => Some((Box::new(stream) as Box<dyn HttpStream>, remote)),
                Err(error) => {
                    tracing::info!(
                        network = %log_network(remote.ip()),
                        %error,
                        "port HTTP : poignée de main TLS en échec"
                    );
                    None
                }
            }
        })
    })))
}
