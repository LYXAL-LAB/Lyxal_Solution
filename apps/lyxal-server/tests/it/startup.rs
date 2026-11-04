//! Démarrage réel du serveur sur une base embarquée : installation du noyau et des modules
//! hébergés depuis leurs manifestes embarqués, démarrage par `LyxalRuntime`, routes système.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_server::{
    config::AppConfig,
    context::AppContext,
    health::{HealthRegistry, HealthState},
    http::build_router,
    metrics::Metrics,
    runtime,
};
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

fn config(database: &str) -> AppConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    fs::write(
        directory.path().join("default.toml"),
        format!(
            r#"
[application]
name = "Lyxal Test"
environment = "test"
instance_id = "test"
version = "0.1.0"

[server]
host = "127.0.0.1"
port = 0
request_timeout_seconds = 10
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "{database}"
connect_timeout_seconds = 5

[runtime]
module_install_timeout_seconds = 60
module_start_timeout_seconds = 10
module_stop_timeout_seconds = 10

[observability]
log_filter = "info"
json_logs = false
include_target = false
include_thread_ids = false

[cors]
enabled = false
allow_credentials = false
allowed_origins = []
allowed_methods = []
allowed_headers = []
"#
        ),
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

async fn database(name: &str) -> Surreal<Any> {
    let db = connect("mem://").await.expect("connexion");
    db.use_ns("lyxal_test").use_db(name).await.expect("ns/db");
    db
}

async fn get(router: &axum::Router, uri: &str) -> (StatusCode, serde_json::Value) {
    let request = Request::builder()
        .uri(uri)
        .body(Body::empty())
        .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps");
    let json = serde_json::from_slice(&bytes).unwrap_or(serde_json::Value::Null);
    (status, json)
}

#[tokio::test]
async fn server_installs_and_starts_hosted_modules() {
    let config = Arc::new(config("startup"));
    let client = database("startup").await;
    let runtime = runtime::start(&config, &client).await.expect("démarrage");

    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    health.set("database", HealthState::Healthy, None).await;
    let context = AppContext::new(
        config.clone(),
        Arc::new(client.clone()),
        health,
        Metrics::default(),
        runtime.clone(),
    );
    let router = build_router(context).expect("routeur");

    assert_eq!(get(&router, "/live").await.0, StatusCode::NO_CONTENT);
    assert_eq!(get(&router, "/ready").await.0, StatusCode::NO_CONTENT);

    let (status, modules) = get(&router, "/api/v1/system/modules").await;
    assert_eq!(status, StatusCode::OK);
    let ids: Vec<&str> = modules
        .as_array()
        .expect("liste")
        .iter()
        .filter_map(|m| m["id"].as_str())
        .collect();
    let mut expected = vec!["lyxal_base", "lyxal_core", "lyxal_error", "lyxal_event"];
    if cfg!(feature = "module-ingestion") {
        expected.push("lyxal_pipeline_ingestion");
    }
    assert_eq!(ids, expected);
    assert!(
        modules
            .as_array()
            .expect("liste")
            .iter()
            .all(|m| m["state"] == "Running"),
        "{modules}"
    );

    let (status, health) = get(&router, "/health").await;
    assert_eq!(status, StatusCode::OK, "{health}");

    // La fonction d'échec officielle de lyxal_error est intacte après installation.
    let mut res = client
        .query("RETURN fn::error_result('BASE_UNITE_TYPE_NOT_FOUND', 'fr', NONE).error.category;")
        .await
        .expect("requête");
    let category: Option<String> = res.take(0).expect("catégorie");
    assert_eq!(category.as_deref(), Some("not_found"));

    runtime.stop_all().await.expect("arrêt");
}

#[tokio::test]
async fn restart_on_installed_database_is_idempotent() {
    let config = config("restart");
    let client = database("restart").await;

    let first = runtime::start(&config, &client)
        .await
        .expect("premier démarrage");
    first.stop_all().await.expect("arrêt");
    drop(first);

    let second = runtime::start(&config, &client).await.expect("redémarrage");
    second.stop_all().await.expect("arrêt");

    // Chaque module n'a qu'une release, et chaque migration n'a été appliquée qu'une fois.
    let mut res = client
        .query("RETURN count(SELECT * FROM runtime_migration); RETURN count(SELECT * FROM runtime_release);")
        .await
        .expect("requête");
    let migrations: Option<i64> = res.take(0).expect("migrations");
    let releases: Option<i64> = res.take(1).expect("releases");
    let hosted = if cfg!(feature = "module-ingestion") {
        5
    } else {
        4
    };
    assert_eq!(
        migrations,
        Some(if cfg!(feature = "module-ingestion") {
            1
        } else {
            0
        })
    );
    assert_eq!(releases, Some(hosted));
}

/// Une installation interrompue est reprise en rejouant les ressources des modules : chaque
/// module embarqué doit pouvoir être installé deux fois sans erreur ni doublon.
#[tokio::test]
async fn module_resources_are_replayable() {
    use lyxal_runtime::manifest::ManifestParser;
    use lyxal_runtime::resource::EmbeddedResourceProvider;
    use lyxal_server::modules::{install_foundation, EMBEDDED_MODULES};

    let client = database("replay").await;
    install_foundation(&client).await.expect("noyau");
    for _ in 0..2 {
        for module in EMBEDDED_MODULES {
            let manifest = ManifestParser::parse_str(module.manifest).expect("manifeste");
            let provider = EmbeddedResourceProvider::new(module.files);
            lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
                .await
                .unwrap_or_else(|e| panic!("{} : {e}", module.id));
        }
    }
    let mut res = client
        .query("RETURN count(SELECT * FROM base_unite_type); RETURN count(SELECT * FROM error_definition WHERE code = 'BASE_UNITE_TYPE_NOT_FOUND');")
        .await
        .expect("requête");
    let types: Option<i64> = res.take(0).expect("types");
    let definitions: Option<i64> = res.take(1).expect("définitions");
    assert_eq!(types, Some(6));
    assert_eq!(definitions, Some(1));
}
