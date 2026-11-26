//! HTTP de l'hôte : liaison du port, service des connexions avec délai d'écriture, routes de
//! santé (`/live`, `/ready`, `/health`).
//!
//! Un client qui cesse de lire une réponse (téléchargement d'un fichier, par exemple) remplit le
//! tampon d'envoi : plus rien n'est demandé au corps de la réponse, et aucun délai posé dans une
//! route ne peut expirer. Le délai est donc porté par la connexion elle-même : une écriture qui
//! n'avance plus pendant `write_idle` ferme la connexion, ce qui libère le fichier ouvert et la
//! place prise dans la limite de requêtes simultanées.

use crate::database::Database;
use crate::health::{HealthRegistry, HealthSnapshot, HealthState};
use crate::HostError;
use axum::extract::{ConnectInfo, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::{Json, Router};
use hyper::body::Incoming;
use hyper::Request;
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder;
use hyper_util::server::graceful::{GracefulShutdown, Watcher};
use lyxal_runtime::health::{GlobalHealthStatus, HealthConfig, HealthStatus};
use lyxal_runtime::reconciler::observer::RuntimeObserver;
use lyxal_runtime::{LyxalRuntime, ModuleContext, RuntimeError};
use serde::Serialize;
use std::collections::BTreeMap;
use std::future::Future;
use std::net::SocketAddr;
use std::pin::Pin;
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncRead, AsyncWrite};
use tokio::net::{TcpListener, TcpStream};
use tokio_io_timeout::TimeoutStream;
use tower::Service;

/// Lie le port HTTP de l'hôte (`adresse:port`).
pub async fn bind(address: &str) -> Result<TcpListener, HostError> {
    TcpListener::bind(address)
        .await
        .map_err(|error| HostError::Bind {
            address: address.to_string(),
            message: error.to_string(),
        })
}

/// Flux d'une connexion HTTP préparée par l'hôte (en-tête PROXY lu, poignée de main TLS faite).
pub trait HttpStream: AsyncRead + AsyncWrite + Send + Unpin + 'static {}

impl<T: AsyncRead + AsyncWrite + Send + Unpin + 'static> HttpStream for T {}

/// Préparation d'une connexion acceptée avant le service HTTP : rend le flux à servir et
/// l'adresse du client, ou `None` pour fermer la connexion (l'hôte compte et journalise le refus).
pub type PrepareConnection = Arc<
    dyn Fn(
            TcpStream,
            SocketAddr,
        )
            -> Pin<Box<dyn Future<Output = Option<(Box<dyn HttpStream>, SocketAddr)>> + Send>>
        + Send
        + Sync,
>;

/// Sert `router` sur `listener` jusqu'à la fin de `shutdown`, puis laisse `drain` aux requêtes en
/// cours pour se terminer. L'adresse du client est transmise aux routes (`ConnectInfo`).
pub async fn serve(
    listener: TcpListener,
    router: Router,
    write_idle: Duration,
    drain: Duration,
    shutdown: impl Future<Output = ()>,
) {
    serve_prepared(listener, router, write_idle, drain, shutdown, None).await;
}

/// `serve`, chaque connexion passant d'abord par `prepare` (PROXY, TLS : `lyxal-groupware`).
/// La préparation tourne dans la tâche de la connexion : un client lent ne bloque pas les
/// autres.
pub async fn serve_prepared(
    listener: TcpListener,
    router: Router,
    write_idle: Duration,
    drain: Duration,
    shutdown: impl Future<Output = ()>,
    prepare: Option<PrepareConnection>,
) {
    let graceful = GracefulShutdown::new();
    let mut shutdown = std::pin::pin!(shutdown);
    loop {
        tokio::select! {
            accepted = listener.accept() => {
                let (stream, remote) = match accepted {
                    Ok(accepted) => accepted,
                    Err(error) => {
                        // Erreur passagère d'acceptation (descripteurs épuisés, connexion
                        // réinitialisée) : le serveur continue
                        tracing::warn!(%error, "connexion entrante refusée");
                        tokio::time::sleep(Duration::from_millis(50)).await;
                        continue;
                    }
                };
                let watcher = graceful.watcher();
                match &prepare {
                    None => {
                        tokio::spawn(serve_connection(
                            stream,
                            remote,
                            router.clone(),
                            write_idle,
                            watcher,
                        ));
                    }
                    Some(prepare) => {
                        let prepared = prepare(stream, remote);
                        let router = router.clone();
                        tokio::spawn(async move {
                            if let Some((stream, remote)) = prepared.await {
                                serve_connection(stream, remote, router, write_idle, watcher)
                                    .await;
                            }
                        });
                    }
                }
            }
            () = &mut shutdown => break,
        }
    }
    drop(listener);
    if tokio::time::timeout(drain, graceful.shutdown())
        .await
        .is_err()
    {
        tracing::warn!(
            drain_seconds = drain.as_secs(),
            "arrêt : des requêtes en cours ont été interrompues"
        );
    }
}

/// Sert `router` sur une connexion déjà acceptée (`remote` : adresse du client), avec le délai
/// d'écriture `write_idle`, sous la surveillance de `watcher` (arrêt gracieux). Le futur rendu
/// se termine à la fermeture de la connexion ; l'appelant le confie à une tâche.
pub fn serve_connection<S>(
    stream: S,
    remote: SocketAddr,
    router: Router,
    write_idle: Duration,
    watcher: Watcher,
) -> impl Future<Output = ()> + Send + 'static
where
    S: AsyncRead + AsyncWrite + Send + Unpin + 'static,
{
    let mut stream = TimeoutStream::new(stream);
    stream.set_write_timeout(Some(write_idle));
    let service = hyper::service::service_fn(move |mut request: Request<Incoming>| {
        request.extensions_mut().insert(ConnectInfo(remote));
        router.clone().call(request)
    });
    let connection = watcher.watch(
        Builder::new(TokioExecutor::new())
            .serve_connection_with_upgrades(TokioIo::new(Box::pin(stream)), service)
            .into_owned(),
    );
    async move {
        if let Err(error) = connection.await {
            tracing::debug!(%remote, %error, "connexion fermée sur erreur");
        }
    }
}

/// Ce que les routes de santé lisent : les composants de l'hôte, son runtime, son nom et les
/// connexions de sa session système.
#[derive(Clone)]
pub struct HostHealth {
    registry: HealthRegistry,
    runtime: Arc<LyxalRuntime>,
    host: &'static str,
    database: Database,
    probe_timeout: Duration,
}

impl HostHealth {
    /// Santé de l'hôte `host` (nom fixe de l'hôte, ex. `lyxal_server`). `/ready` sonde les
    /// connexions de `database`, chacune devant répondre en moins de `probe_timeout`.
    pub fn new(
        registry: HealthRegistry,
        runtime: Arc<LyxalRuntime>,
        host: &'static str,
        database: Database,
        probe_timeout: Duration,
    ) -> Self {
        Self {
            registry,
            runtime,
            host,
            database,
            probe_timeout,
        }
    }
}

/// Routes `/live`, `/ready` et `/health` de l'hôte. Une erreur du runtime pendant `/health` est
/// rendue par le type d'erreur `E` de l'hôte (contrat `LyxalResult`, code `RUNTIME_*`).
pub fn health_routes<S, E>(state: HostHealth) -> Router<S>
where
    S: Clone + Send + Sync + 'static,
    E: From<RuntimeError> + IntoResponse + Send + 'static,
{
    Router::new()
        .route("/live", get(live))
        .route("/ready", get(ready))
        .route("/health", get(health::<E>))
        .with_state(state)
}

async fn live() -> StatusCode {
    StatusCode::NO_CONTENT
}

/// Prêt si les composants de l'hôte le sont et si une connexion au moins de la session système
/// répond : une connexion muette parmi plusieurs est journalisée, elle ne retire pas le nœud.
async fn ready(State(state): State<HostHealth>) -> StatusCode {
    if !state.registry.ready().await {
        return StatusCode::SERVICE_UNAVAILABLE;
    }
    let probe = state.database.probe(state.probe_timeout).await;
    if !probe.complete() {
        tracing::warn!(
            responding = probe.responding,
            connections = probe.clients,
            error = probe.error.as_deref().unwrap_or_default(),
            "connexions SurrealDB muettes"
        );
    }
    if probe.reachable() {
        StatusCode::NO_CONTENT
    } else {
        StatusCode::SERVICE_UNAVAILABLE
    }
}

#[derive(Serialize)]
struct HealthResponse {
    /// Composants de l'hôte (processus, base de données, port HTTP…).
    host: HealthSnapshot,
    /// Santé des modules, évaluée par le runtime (`ModuleHealthCheck`), sans le message des
    /// sondes (détail interne).
    modules: ModulesHealth,
}

#[derive(Serialize)]
struct ModulesHealth {
    status: GlobalHealthStatus,
    modules: BTreeMap<String, HealthStatus>,
}

async fn health<E>(State(state): State<HostHealth>) -> Result<Response, E>
where
    E: From<RuntimeError> + IntoResponse,
{
    let host = state.registry.snapshot().await;
    let observer = RuntimeObserver::new(
        state.runtime.store(),
        state.runtime.registry(),
        state.runtime.lifecycle(),
    );
    let actual = observer.observe().await?;
    let modules = state
        .runtime
        .health_engine(HealthConfig::default())
        .check_all(&actual, &ModuleContext::new(state.host))
        .await;
    let serving = matches!(host.state, HealthState::Healthy | HealthState::Degraded)
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
    Ok((status, Json(HealthResponse { host, modules })).into_response())
}
