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
    config_with(database, "")
}

/// Configuration de test complétée par `extra` (sections TOML supplémentaires).
pub(crate) fn config_with(database: &str, extra: &str) -> AppConfig {
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
{extra}
"#
        ),
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

pub(crate) async fn database(name: &str) -> Surreal<Any> {
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
    let runtime = runtime::start(&config, &client)
        .await
        .expect("démarrage")
        .runtime;

    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    health.set("database", HealthState::Healthy, None).await;
    let context = AppContext::new(
        config.clone(),
        Arc::new(client.clone()),
        health,
        Metrics::default(),
        runtime.clone(),
        None,
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
    let mut expected = vec![
        "lyxal_auth",
        "lyxal_base",
        "lyxal_catalogue",
        "lyxal_core",
        "lyxal_error",
        "lyxal_event",
        "lyxal_notification",
    ];
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
        .expect("premier démarrage")
        .runtime;
    first.stop_all().await.expect("arrêt");
    drop(first);

    let second = runtime::start(&config, &client)
        .await
        .expect("redémarrage")
        .runtime;
    second.stop_all().await.expect("arrêt");

    // Chaque module n'a qu'une release. Aucun module hébergé ne déclare de migration (schémas
    // installés par la phase `schemas`) ; l'application unique d'une migration est prouvée par
    // les tests de lyxal_runtime (lease_fencing_tests, multi_node_locking_tests).
    let mut res = client
        .query("RETURN count(SELECT * FROM runtime_migration); RETURN count(SELECT * FROM runtime_release);")
        .await
        .expect("requête");
    let migrations: Option<i64> = res.take(0).expect("migrations");
    let releases: Option<i64> = res.take(1).expect("releases");
    let hosted = if cfg!(feature = "module-ingestion") {
        8
    } else {
        7
    };
    assert_eq!(migrations, Some(0));
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
    assert_eq!(types, Some(11));
    assert_eq!(definitions, Some(1));
}

/// Les définitions `SERVER_*` sont installées au démarrage, une par entrée du catalogue.
#[tokio::test]
async fn server_error_definitions_are_installed() {
    let client = database("server_errors").await;
    lyxal_server::modules::install_foundation(&client)
        .await
        .expect("noyau");
    let mut res = client
        .query("SELECT VALUE code FROM error_definition WHERE module = 'server' ORDER BY code;")
        .await
        .expect("requête");
    let codes: Vec<String> = res.take(0).expect("codes");
    let mut expected: Vec<String> = lyxal_server::error::SERVER_ERROR_CATALOG
        .iter()
        .map(|info| info.code.to_string())
        .collect();
    expected.sort();
    assert_eq!(codes, expected);
}

/// Chaque code passé à `fn::error_result` par les fonctions d'un module embarqué a sa
/// définition installée (`error_definition`).
#[tokio::test]
async fn every_emitted_error_code_is_defined() {
    use lyxal_runtime::manifest::ManifestParser;
    use lyxal_runtime::resource::EmbeddedResourceProvider;
    use lyxal_server::modules::{install_foundation, EMBEDDED_MODULES};

    let client = database("error_codes").await;
    install_foundation(&client).await.expect("noyau");
    let mut emitted = std::collections::BTreeSet::new();
    for module in EMBEDDED_MODULES {
        let manifest = ManifestParser::parse_str(module.manifest).expect("manifeste");
        lyxal_runtime::schema::install_resources(
            &client,
            &manifest,
            &EmbeddedResourceProvider::new(module.files),
        )
        .await
        .unwrap_or_else(|e| panic!("{} : {e}", module.id));
        for (path, content) in module.files {
            // Codes renvoyés par les fonctions et codes levés par les gardes (`THROW "CODE: …"`).
            let markers: &[&str] = if path.starts_with("functions/") {
                &["fn::error_result(\"", "THROW \""]
            } else if path.starts_with("schema/") || path.starts_with("events/") {
                &["THROW \""]
            } else {
                &[]
            };
            for chunk in markers.iter().flat_map(|m| content.split(m).skip(1)) {
                let code = chunk.split(['"', ':']).next().unwrap_or_default();
                if !code.is_empty()
                    && code
                        .chars()
                        .all(|c| c.is_ascii_uppercase() || c.is_ascii_digit() || c == '_')
                {
                    emitted.insert((module.id, code.to_string()));
                }
            }
        }
    }
    let mut res = client
        .query("SELECT VALUE code FROM error_definition;")
        .await
        .expect("requête");
    let defined: std::collections::BTreeSet<String> = res
        .take::<Vec<String>>(0)
        .expect("codes")
        .into_iter()
        .collect();
    let missing: Vec<_> = emitted
        .iter()
        .filter(|(_, code)| !defined.contains(code))
        .collect();
    assert!(
        missing.is_empty(),
        "codes émis sans définition : {missing:?}"
    );
}

/// Sans service de connexion `lyxal_auth`, la publication est désactivée et la sonde du module
/// le signale.
#[cfg(feature = "module-ingestion")]
#[tokio::test]
async fn publication_without_auth_service_degrades_the_ingestion_probe() {
    let config = config("sans_cle");
    let client = database("sans_cle").await;
    let runtime = runtime::start(&config, &client)
        .await
        .expect("démarrage")
        .runtime;
    let probe = runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_pipeline_ingestion"))
        .expect("sonde du module");
    let result = probe
        .check(&lyxal_runtime::ModuleContext::new(
            "lyxal_pipeline_ingestion",
        ))
        .await
        .expect("sonde");
    let ingestion = format!("{result:?}");
    assert!(
        ingestion.contains("Publication vers le catalogue désactivée"),
        "{ingestion}"
    );
    runtime.stop_all().await.expect("arrêt");
}
