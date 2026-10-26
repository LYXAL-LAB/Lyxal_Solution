//! ============================================================================
//! TESTS D'INTÉGRATION HTTP DU SERVEUR HÔTE STAGING — apps/lyxal-server
//! ============================================================================
//!
//! Valide le raccordement de `IngestionServerModule` à l'hôte officiel `lyxal_server` :
//! 1. Endpoint liveness : `GET /live` -> 204 No Content
//! 2. Endpoint readiness : `GET /ready` -> 204 No Content
//! 3. Endpoint health : `GET /health` -> 200 OK avec diagnostic global
//! 4. Endpoint modules : `GET /api/v1/system/modules` -> liste contenant `lyxal-pipeline-ingestion`

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_server::{
    config::{AppConfig, ModulesConfig, RuntimeConfig},
    context::AppContext,
    health::{HealthRegistry, HealthState},
    http::build_router,
    metrics::Metrics,
    modules::{compiled_modules, ModuleContext},
    runtime::RuntimeHandle,
};
use std::sync::Arc;
use surrealdb::engine::any::connect;

#[tokio::test]
async fn test_http_server_endpoints_and_ingestion_module() {
    // 1. Initialisation de la base in-memory pour le test HTTP de l'hôte
    let db = connect("mem://")
        .await
        .expect("Connexion DB test");
    db.use_ns("lyxal_test").use_db("system_test").await.expect("Use NS/DB");

    let database = Arc::new(db);
    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    health.set("database", HealthState::Healthy, None).await;

    let metrics = Metrics::default();
    let module_context = ModuleContext {
        database: database.clone(),
        health: health.clone(),
        metrics: metrics.clone(),
    };

    let config = Arc::new(AppConfig {
        application: lyxal_server::config::ApplicationConfig {
            name: "Lyxal OS Staging".into(),
            environment: "staging".into(),
            instance_id: "host_staging_01".into(),
            version: "0.1.0".into(),
        },
        server: lyxal_server::config::ServerConfig {
            host: "127.0.0.1".parse().unwrap(),
            port: 8085,
            request_timeout_seconds: 10,
            graceful_shutdown_seconds: 5,
            max_concurrency: 128,
            body_limit_bytes: 1048576,
            trust_proxy_headers: false,
        },
        database: lyxal_server::config::DatabaseConfig {
            endpoint: "mem://".into(),
            namespace: "lyxal_test".into(),
            database: "system_test".into(),
            username: None,
            password: None,
            connect_timeout_seconds: 5,
            required: true,
        },
        runtime: RuntimeConfig {
            run_migrations: false,
            fail_fast: true,
            parallel_start: false,
            module_start_timeout_seconds: 10,
            module_stop_timeout_seconds: 5,
        },
        observability: lyxal_server::config::ObservabilityConfig {
            log_filter: "info".into(),
            json_logs: false,
            include_target: false,
            include_thread_ids: false,
        },
        cors: lyxal_server::config::CorsConfig {
            enabled: false,
            allow_credentials: false,
            allowed_origins: vec![],
            allowed_methods: vec![],
            allowed_headers: vec![],
        },
        modules: ModulesConfig::default(),
    });

    // 2. Compilation et démarrage du runtime hôte avec IngestionServerModule
    let modules = compiled_modules(&config);
    assert!(
        modules.iter().any(|m| m.descriptor().id.as_str() == "lyxal-pipeline-ingestion"),
        "Le module lyxal-pipeline-ingestion doit être présent dans les modules compilés"
    );

    let runtime = RuntimeHandle::build(modules, &config.modules, config.runtime.clone(), module_context)
        .expect("Construction du runtime");
    runtime.install_and_start().await.expect("Démarrage des modules hôtes");

    let context = AppContext::new(
        config.clone(),
        database,
        health,
        metrics,
        runtime.clone(),
    );

    let router = build_router(context).expect("Construction du routeur Axum");

    // 3. Test GET /live
    let req_live = Request::builder().uri("/live").body(Body::empty()).unwrap();
    let resp_live = tower::ServiceExt::oneshot(router.clone(), req_live).await.unwrap();
    assert_eq!(resp_live.status(), StatusCode::NO_CONTENT);

    // 4. Test GET /ready
    let req_ready = Request::builder().uri("/ready").body(Body::empty()).unwrap();
    let resp_ready = tower::ServiceExt::oneshot(router.clone(), req_ready).await.unwrap();
    assert_eq!(resp_ready.status(), StatusCode::NO_CONTENT);

    // 5. Test GET /health
    let req_health = Request::builder().uri("/health").body(Body::empty()).unwrap();
    let resp_health = tower::ServiceExt::oneshot(router.clone(), req_health).await.unwrap();
    assert_eq!(resp_health.status(), StatusCode::OK);

    // 6. Test GET /api/v1/system/modules
    let req_mods = Request::builder().uri("/api/v1/system/modules").body(Body::empty()).unwrap();
    let resp_mods = tower::ServiceExt::oneshot(router.clone(), req_mods).await.unwrap();
    assert_eq!(resp_mods.status(), StatusCode::OK);

    let body_bytes = to_bytes(resp_mods.into_body(), 1024 * 1024).await.unwrap();
    let mods_json: serde_json::Value = serde_json::from_slice(&body_bytes).unwrap();
    let arr = mods_json.as_array().expect("Array de modules");
    assert!(
        arr.iter().any(|m| m["descriptor"]["id"] == "lyxal-pipeline-ingestion"),
        "lyxal-pipeline-ingestion doit être listé dans les modules système actifs (reçu: {mods_json})"
    );

    // 7. Arrêt gracieux du runtime et des workers
    runtime.stop_all().await;

    println!("[OK] Cycle de vie complet (install, start, endpoints HTTP, stop des workers) validé sur lyxal_server.");
}
