//! Démarrage réel du serveur sur une base embarquée : installation du noyau et des modules
//! hébergés depuis leurs manifestes embarqués, démarrage par `LyxalRuntime`, routes système.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_host::health::{HealthRegistry, HealthState};
use lyxal_server::{config::AppConfig, runtime};
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

use crate::configuration::{remote_config, surreal_server};
use crate::system_routes::{platform_admin, router_on, router_with_auth, send, AUTH, MODULES};

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

/// Serveur SurrealDB réel, session système en pool de trois connexions : le serveur s'installe
/// et démarre, une route d'administration répond à une session d'utilisateur (clonée de la
/// connexion fixe), les stores de la session système passent par le pool ; `/ready` suit la
/// base : `204` tant qu'une connexion répond, `503` une fois la base arrêtée.
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn server_starts_on_a_pool_of_connections_and_ready_follows_the_database() {
    let (server, endpoint) = surreal_server(false).await;
    let mut config = config_with("pool", AUTH);
    config.database = remote_config(endpoint);
    config.database.connections = std::num::NonZeroUsize::new(3).expect("connexions");
    config.database.connect_timeout_seconds = 3;
    let config = Arc::new(config);

    let database = lyxal_host::database::connect_database(&config.database)
        .await
        .expect("pool de connexions");
    assert_eq!(database.size(), 3);
    let runtime = runtime::start(&config, &database)
        .await
        .expect("démarrage sur un pool")
        .runtime;

    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    health.set("database", HealthState::Healthy, None).await;
    let (router, host) = router_on(config, database.clone(), runtime.clone(), health).await;
    assert_eq!(get(&router, "/ready").await.0, StatusCode::NO_CONTENT);
    let (status, reply) = get(&router, "/health").await;
    assert_eq!(status, StatusCode::OK, "{reply}");

    // Session d'un compte de service, sur une copie de la connexion fixe ; plusieurs requêtes :
    // les appels de la session système (contrôle du jeton, langue) tournent sur le pool
    let admin = platform_admin(database.fixed(), &host).await;
    for _ in 0..6 {
        let (status, reply) = send(&router, "GET", MODULES, Some(&admin), None).await;
        assert_eq!(status, StatusCode::OK, "{reply}");
        assert_eq!(reply["data"]["host"], "lyxal_server", "{reply}");
    }
    // Chaque connexion du pool est restée dans la session système (aucune n'a pris le jeton)
    for client in database.clients() {
        let mut response = client
            .query("RETURN [$auth, session::db()];")
            .await
            .expect("session");
        let state: Vec<serde_json::Value> = response
            .take::<surrealdb::types::Value>(0)
            .expect("lecture")
            .into_json_value()
            .as_array()
            .expect("liste")
            .clone();
        assert_eq!(
            state[0],
            serde_json::Value::Null,
            "session système attendue"
        );
        assert_eq!(state[1], "test");
    }

    // Base arrêtée : plus aucune connexion ne répond
    drop(server);
    assert_eq!(
        get(&router, "/ready").await.0,
        StatusCode::SERVICE_UNAVAILABLE
    );
}

#[tokio::test]
async fn server_installs_and_starts_hosted_modules() {
    let config = Arc::new(config_with("startup", AUTH));
    let client = database("startup").await;
    let runtime = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage")
        .runtime;

    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    health.set("database", HealthState::Healthy, None).await;
    let (router, host) = router_with_auth(config, &client, runtime.clone(), health).await;

    assert_eq!(get(&router, "/live").await.0, StatusCode::NO_CONTENT);
    assert_eq!(get(&router, "/ready").await.0, StatusCode::NO_CONTENT);

    // Route d'administration de l'installation : jeton d'un administrateur de la plateforme
    let admin = platform_admin(&client, &host).await;
    let (status, reply) = send(&router, "GET", MODULES, Some(&admin), None).await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    let system = &reply["data"];
    // Hôte et nœud de ce processus ; seul nœud vivant de la base, avec ses modules démarrés
    assert_eq!(system["host"], "lyxal_server", "{system}");
    let node = runtime.node_id().to_string();
    assert_eq!(system["node_id"], node.as_str(), "{system}");
    let nodes = system["nodes"].as_array().expect("nœuds");
    assert_eq!(nodes.len(), 1, "{system}");
    assert_eq!(nodes[0]["node_id"], node.as_str());
    assert_eq!(nodes[0]["host"], "lyxal_server");
    assert_eq!(nodes[0]["current"], true);
    assert!(nodes[0]["seen_at"].is_string(), "{system}");
    let modules = &system["modules"];
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
        "lyxal_i18n",
        "lyxal_notification",
    ];
    if cfg!(feature = "module-ingestion") {
        expected.push("lyxal_pipeline_ingestion");
    }
    expected.push("lyxal_scheduler");
    expected.push("lyxal_secrets");
    expected.push("lyxal_storage");
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

    // Sonde de lyxal_i18n : langue par défaut rendue, versions des données, fuseaux horaires
    let probe = runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_i18n"))
        .expect("sonde de lyxal_i18n");
    let result = probe
        .check(&lyxal_runtime::ModuleContext::new("lyxal_i18n"))
        .await
        .expect("sonde");
    assert_eq!(
        result.status,
        lyxal_runtime::health::HealthStatus::Healthy,
        "{result:?}"
    );
    let message = result.message.unwrap_or_default();
    assert!(
        message.contains("langue par défaut fr") && message.contains("fuseaux horaires"),
        "{message}"
    );

    // Aucun réglage d'envoi dans l'hôte (le relais SMTP est une intégration de
    // lyxal_notification) : le module démarre, sa sonde est dégradée, rien n'est envoyé
    let probe = runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_notification"))
        .expect("sonde de lyxal_notification");
    let result = probe
        .check(&lyxal_runtime::ModuleContext::new("lyxal_notification"))
        .await
        .expect("sonde");
    assert_eq!(
        result.status,
        lyxal_runtime::health::HealthStatus::Degraded,
        "{result:?}"
    );
    assert!(
        result
            .message
            .unwrap_or_default()
            .starts_with("NOTIFICATION_"),
        "code de la cause"
    );

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

    let first = runtime::start(&config, &client.clone().into())
        .await
        .expect("premier démarrage")
        .runtime;
    first.stop_all().await.expect("arrêt");
    drop(first);

    let second = runtime::start(&config, &client.clone().into())
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
        12
    } else {
        11
    };
    assert_eq!(migrations, Some(0));
    assert_eq!(releases, Some(hosted));
}

/// Release du module en cours d'installation, comme l'enregistre le runtime avant d'installer ses
/// ressources : le seed d'un module qui déclare des tâches du planificateur l'exige (garde de
/// `scheduler_task`).
async fn installing_release(
    client: &surrealdb::Surreal<surrealdb::engine::any::Any>,
    module: &str,
) {
    client
        .query("fn::runtime_module_upsert({ module_id: $id, name: $id }); fn::runtime_release_register({ module_id: $id, version: '0.1.0', manifest_version: 1, status: 'Installing' });")
        .bind(("id", module.to_string()))
        .await
        .and_then(|r| r.check())
        .unwrap_or_else(|e| panic!("release de {module} : {e}"));
}

/// Une installation interrompue est reprise en rejouant les ressources des modules : chaque
/// module embarqué doit pouvoir être installé deux fois sans erreur ni doublon.
#[tokio::test]
async fn module_resources_are_replayable() {
    use lyxal_runtime::manifest::ManifestParser;
    use lyxal_runtime::resource::EmbeddedResourceProvider;
    use lyxal_server::modules::{install_foundation, EMBEDDED_MODULES};

    let client = database("replay").await;
    install_foundation(&client, &lyxal_runtime::NodeId::generate())
        .await
        .expect("noyau");
    for module in EMBEDDED_MODULES {
        installing_release(&client, module.id).await;
    }
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
    lyxal_server::modules::install_foundation(&client, &lyxal_runtime::NodeId::generate())
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
    install_foundation(&client, &lyxal_runtime::NodeId::generate())
        .await
        .expect("noyau");
    let mut emitted = std::collections::BTreeSet::new();
    for module in EMBEDDED_MODULES {
        let manifest = ManifestParser::parse_str(module.manifest).expect("manifeste");
        installing_release(&client, module.id).await;
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

/// Sans service de connexion `lyxal_auth`, la publication est désactivée ; sans dossier de
/// stockage, aucun lot n'est traité : la sonde du module signale les deux.
#[cfg(feature = "module-ingestion")]
#[tokio::test]
async fn publication_without_auth_service_degrades_the_ingestion_probe() {
    let config = config("sans_cle");
    let client = database("sans_cle").await;
    let runtime = runtime::start(&config, &client.clone().into())
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
    // Sans dossier de stockage, les fichiers sources des lots ne sont pas lisibles : les deux
    // causes sont rendues
    assert!(
        ingestion.contains("stockage des fichiers sources non configuré"),
        "{ingestion}"
    );
    runtime.stop_all().await.expect("arrêt");
}

/// Sonde de `lyxal_storage` : dégradée sans dossier de stockage (le serveur démarre), saine
/// avec un dossier, où un fichier témoin est écrit, relu puis retiré.
#[tokio::test]
async fn storage_probe_follows_the_configured_folder() {
    async fn probe(config: &AppConfig, name: &str) -> lyxal_runtime::health::HealthCheckResult {
        let client = database(name).await;
        let runtime = runtime::start(config, &client.clone().into())
            .await
            .expect("démarrage")
            .runtime;
        let result = runtime
            .health_registry()
            .get_check(&lyxal_runtime::ModuleId::new("lyxal_storage"))
            .expect("sonde de lyxal_storage")
            .check(&lyxal_runtime::ModuleContext::new("lyxal_storage"))
            .await
            .expect("sonde");
        runtime.stop_all().await.expect("arrêt");
        result
    }

    let without = probe(&config("stockage_sans"), "stockage_sans").await;
    assert_eq!(
        without.status,
        lyxal_runtime::health::HealthStatus::Degraded,
        "{without:?}"
    );
    assert!(
        without
            .message
            .as_deref()
            .is_some_and(|m| m.contains("STORAGE_BACKEND_UNKNOWN")),
        "{without:?}"
    );

    let folder = tempfile::tempdir().expect("dossier");
    let root = folder.path().join("fichiers");
    let extra = format!(
        "\n[storage.disk]\nroot = {:?}\n",
        root.display().to_string()
    );
    let with = probe(&config_with("stockage_avec", &extra), "stockage_avec").await;
    assert_eq!(
        with.status,
        lyxal_runtime::health::HealthStatus::Healthy,
        "{with:?}"
    );
    assert!(root.is_dir(), "dossier créé");
    let left: Vec<_> = walk(&root);
    assert!(left.is_empty(), "fichier témoin retiré : {left:?}");
}

/// Sans clé maîtresse du coffre-fort, le serveur démarre : le module est dégradé et aucune
/// valeur n'est écrite ni lue (R5) ; la clé applicative partagée n'y change rien.
#[tokio::test]
async fn the_vault_without_master_key_is_degraded() {
    let config = config("coffre_sans_cle");
    let client = database("coffre_sans_cle").await;
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    assert!(!started.secrets.has_master_key());
    let result = started
        .runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_secrets"))
        .expect("sonde de lyxal_secrets")
        .check(&lyxal_runtime::ModuleContext::new("lyxal_secrets"))
        .await
        .expect("sonde");
    assert_eq!(
        result.status,
        lyxal_runtime::health::HealthStatus::Degraded,
        "{result:?}"
    );
    assert!(
        result
            .message
            .as_deref()
            .is_some_and(|m| m.contains("SECRETS_CRYPTO_UNAVAILABLE")),
        "{result:?}"
    );
    // Fiches consultables, valeurs refusées
    lyxal_secrets::SecretsStore::new(client.clone())
        .secret_create(lyxal_secrets::models::SecretCreateParams::new(
            None, "test/cle", "api_key",
        ))
        .await
        .expect("fiche");
    let error = started
        .secrets
        .client("lyxal_test")
        .read(lyxal_secrets::ClientRead {
            tenant: None,
            path: "test/cle".into(),
            label: None,
        })
        .await
        .expect_err("aucune lecture");
    assert_eq!(error.code(), "SECRETS_CRYPTO_UNAVAILABLE");
    started.runtime.stop_all().await.expect("arrêt");
}

/// Le planificateur démarre avec le module : planificateur élu, un exécuteur par file, sonde
/// sain, registre des handlers ouvert où l'hôte a inscrit ceux de ses tâches de fond ; une
/// publication différée s'exécute.
#[tokio::test]
async fn the_scheduler_runs_with_its_workers_and_probe() {
    let config = config("planificateur");
    let client = database("planificateur").await;
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    assert_eq!(
        started.scheduler.handlers().tasks(),
        vec!["auth.purge", "secrets.maintenance", "storage.cleanup"]
    );
    let mut served = started.scheduler.served_queues();
    for _ in 0..100 {
        if served.len() == 2 {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(50)).await;
        served = started.scheduler.served_queues();
    }
    assert_eq!(
        served,
        vec!["default".to_string(), "maintenance".to_string()]
    );
    let result = started
        .runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_scheduler"))
        .expect("sonde de lyxal_scheduler")
        .check(&lyxal_runtime::ModuleContext::new("lyxal_scheduler"))
        .await
        .expect("sonde");
    assert_eq!(
        result.status,
        lyxal_runtime::health::HealthStatus::Healthy,
        "{result:?}"
    );

    // Une tâche d'essai de publication différée (module fictif lyxal_essai, installé : release
    // du runtime), exécutée par le moteur hébergé
    client
        .query(
            r#"fn::runtime_module_upsert({ module_id: "lyxal_essai", name: "Essai" });
            fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.1.0", manifest_version: 1, status: "Installed" });
            CREATE scheduler_task:⟨essai.rappel⟩ CONTENT {
                module: "lyxal_essai", executor: "event", target: "essai.rappel.envoi", scope: "installation",
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };"#,
        )
        .await
        .and_then(|r| r.check())
        .expect("tâche d'essai");
    let run = started
        .scheduler
        .client(lyxal_scheduler::SchedulerStore::new(client.clone()))
        .enqueue(lyxal_scheduler::models::RunEnqueueParams::new(
            "essai.rappel",
        ))
        .await
        .expect("différée");
    let mut state = String::new();
    for _ in 0..200 {
        state = client
            .query("RETURN (SELECT VALUE state FROM ONLY $run);")
            .bind(("run", run.id.clone()))
            .await
            .and_then(|mut r| r.take::<Option<String>>(0))
            .expect("état")
            .unwrap_or_default();
        if state == "completed" {
            break;
        }
        tokio::time::sleep(std::time::Duration::from_millis(50)).await;
    }
    assert_eq!(state, "completed");
    let leader = lyxal_runtime::lock::SurrealLeaderLeaseManager::new(client.clone())
        .inspect(lyxal_scheduler::LEADER_KEY)
        .await
        .expect("bail");
    assert_eq!(
        leader.map(|l| l.owner),
        Some(started.runtime.node_id().clone())
    );
    started.runtime.stop_all().await.expect("arrêt");
}

/// Fichiers présents sous un dossier.
fn walk(directory: &std::path::Path) -> Vec<std::path::PathBuf> {
    let mut files = Vec::new();
    for entry in fs::read_dir(directory).expect("dossier").flatten() {
        let path = entry.path();
        if path.is_dir() {
            files.extend(walk(&path));
        } else {
            files.push(path);
        }
    }
    files
}
