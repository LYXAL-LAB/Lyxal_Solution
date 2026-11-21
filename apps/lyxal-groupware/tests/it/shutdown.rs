//! Cycle de vie complet sur une base embarquée : démarrage par le runtime (écoutes supervisées,
//! module `lyxal_mail`), santé et mesures du port HTTP, arrêt avec drainage, session qui ignore
//! l'arrêt abandonnée au délai, port déjà pris au démarrage.

use crate::support::{
    config, database, first_line, greeting, smtp_listener, HoldHandler, StubbornHandler,
};
use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_groupware::{http, runtime};
use lyxal_host::health::{HealthRegistry, HealthState};
use lyxal_mail::net::{MailProtocol, SessionHandler};
use lyxal_runtime::worker::WorkerState;
use lyxal_runtime::{ModuleId, ModuleState};
use serde_json::Value;
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::net::TcpStream;

async fn get(router: &axum::Router, uri: &str) -> (StatusCode, Value) {
    let request = Request::builder().uri(uri).body(Body::empty()).unwrap();
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .unwrap();
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 1024 * 1024).await.unwrap();
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

async fn count(client: &surrealdb::Surreal<surrealdb::engine::any::Any>, query: &str) -> i64 {
    let mut response = client.query(query).await.unwrap();
    let total: Option<i64> = response.take(0).unwrap();
    total.unwrap()
}

#[tokio::test]
async fn host_starts_serves_health_and_drains_on_shutdown() {
    let config = config(
        "lifecycle",
        &format!("[limits]\ndrain_seconds = 2\n{}", smtp_listener("smtp", "")),
    );
    let client = database("lifecycle").await;
    let listeners = bind_listeners(&config).unwrap();
    let handler: Arc<dyn SessionHandler> = Arc::new(HoldHandler(MailProtocol::Smtp));
    let started = runtime::start_with(&config, &client, listeners, None, &move |_| handler.clone())
        .await
        .expect("démarrage");
    let runtime = started.runtime.clone();
    for module in [
        "lyxal_core",
        "lyxal_error",
        "lyxal_event",
        "lyxal_auth",
        "lyxal_secrets",
        "lyxal_storage",
        "lyxal_mail",
    ] {
        assert_eq!(
            runtime.module_state(&ModuleId::new(module)),
            Some(ModuleState::Running),
            "{module}"
        );
    }
    // Définitions GROUPWARE_* installées avec le socle
    assert_eq!(
        count(
            &client,
            "RETURN count(SELECT * FROM error_definition WHERE string::starts_with(code, 'GROUPWARE_'));"
        )
        .await,
        7
    );

    // Santé et mesures
    let health = HealthRegistry::default();
    for component in ["groupware", "database", "http"] {
        health.set(component, HealthState::Healthy, None).await;
    }
    let router = http::router(health.clone(), runtime.clone(), started.mail.clone());
    assert_eq!(get(&router, "/live").await.0, StatusCode::NO_CONTENT);
    assert_eq!(get(&router, "/ready").await.0, StatusCode::NO_CONTENT);
    let (status, body) = get(&router, "/health").await;
    assert_eq!(status, StatusCode::OK, "{body}");
    assert_eq!(body["host"]["state"], "healthy", "{body}");
    assert_eq!(body["host"]["components"]["groupware"]["state"], "healthy");
    assert_eq!(
        body["modules"]["modules"]["lyxal_mail"], "healthy",
        "{body}"
    );

    let address = started.mail.local_addrs("smtp")[0];
    let (mut session, reply) = greeting(address).await;
    assert_eq!(reply, "220 hold");
    let (status, metrics) = get(&router, "/metrics").await;
    assert_eq!(status, StatusCode::OK);
    let smtp = &metrics["mail"]["listeners"]["smtp"];
    assert_eq!(smtp["accepted"], 1, "{metrics}");
    assert_eq!(smtp["active"], 1, "{metrics}");
    assert_eq!(
        metrics["mail"]["memory"]["used_bytes"],
        64 * 1024,
        "{metrics}"
    );
    assert!(!metrics.to_string().contains("127.0.0.1"), "{metrics}");

    // Arrêt : « stopping » (/ready 503), session prévenue, plus aucune acceptation, nœud retiré
    health.set("groupware", HealthState::Stopping, None).await;
    assert_eq!(
        get(&router, "/ready").await.0,
        StatusCode::SERVICE_UNAVAILABLE
    );
    let stopping = Instant::now();
    let stop = tokio::spawn({
        let runtime = runtime.clone();
        async move { runtime.stop_all().await }
    });
    assert_eq!(first_line(&mut session).await, "421 bye");
    stop.await.unwrap().expect("arrêt");
    // Comme l'hôte (`bootstrap`) : les écoutes arrêtées gardent leurs ports, l'arrêt définitif
    // les referme
    started.mail.close();
    assert!(
        stopping.elapsed() < Duration::from_secs(10),
        "arrêt trop long"
    );
    assert!(
        TcpStream::connect(address).await.is_err(),
        "écoute encore ouverte"
    );
    assert_eq!(
        count(&client, "RETURN count(SELECT * FROM runtime_node);").await,
        0
    );
}

#[tokio::test]
async fn session_ignoring_shutdown_is_abandoned_at_the_drain_deadline() {
    let config = config(
        "stubborn",
        &format!("[limits]\ndrain_seconds = 1\n{}", smtp_listener("smtp", "")),
    );
    let client = database("stubborn").await;
    let listeners = bind_listeners(&config).unwrap();
    let started = runtime::start_with(&config, &client, listeners, None, &|_| {
        Arc::new(StubbornHandler) as Arc<dyn SessionHandler>
    })
    .await
    .expect("démarrage");
    let address = started.mail.local_addrs("smtp")[0];
    let (mut session, reply) = greeting(address).await;
    assert_eq!(reply, "220 stubborn");

    let stopping = Instant::now();
    started.runtime.stop_all().await.expect("arrêt");
    let elapsed = stopping.elapsed();
    assert!(elapsed >= Duration::from_secs(1), "{elapsed:?}");
    assert!(elapsed < Duration::from_secs(5), "{elapsed:?}");
    // Session abandonnée : connexion fermée
    assert_eq!(first_line(&mut session).await, "");
    let workers = started.runtime.worker_supervisor().all_health();
    assert!(
        workers
            .values()
            .all(|worker| worker.state != WorkerState::Failed),
        "{workers:?}"
    );
}

#[tokio::test]
async fn a_port_already_taken_stops_the_startup() {
    let taken = std::net::TcpListener::bind("127.0.0.1:0").unwrap();
    let port = taken.local_addr().unwrap().port();
    let config = config(
        "bind",
        &format!(
            "\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:{port}\"]\ntls = \"none\"\n"
        ),
    );
    let error = match bind_listeners(&config) {
        Ok(_) => panic!("port déjà pris accepté"),
        Err(error) => error,
    };
    assert_eq!(error.code(), "GROUPWARE_BIND_FAILED");
    assert!(
        error.to_string().contains(&format!("127.0.0.1:{port}")),
        "{error}"
    );
}
