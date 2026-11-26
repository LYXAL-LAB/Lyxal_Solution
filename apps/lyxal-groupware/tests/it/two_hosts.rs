//! `lyxal-groupware` à côté du vrai `lyxal-server` sur la même base (décision G16), sur le moteur
//! embarqué et sur un serveur SurrealDB 3.3.4 réel (`ws://`, test ignoré par défaut, lancé par
//! `scripts/ci/test_all.sh`).
//!
//! Le socle est installé une fois (même empreinte pour les deux hôtes) ; `lyxal_mail` n'est
//! installé que par `lyxal-groupware` ; les deux nœuds sont dans `runtime_node` et dans la route
//! système de `lyxal-server` ; chaque hôte élit son chef des événements (baux distincts) ; la
//! réconciliation stricte de `lyxal-server` voit `lyxal_mail` comme module d'un autre hôte, sans
//! action ; l'arrêt de `lyxal-groupware` laisse `lyxal-server` sain ; son redémarrage ne rejoue
//! aucune installation.

use crate::support::{greeting, smtp_listener};
use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_host::config::{DatabaseConfig, SecretPassword};
use lyxal_host::database::{connect_database, Database};
use lyxal_host::{health::HealthRegistry, health::HealthState, metrics::Metrics};
use lyxal_mail::net::{refusal_line, MailProtocol, RefusalReason};
use lyxal_runtime::{DesiredRuntimeState, ForeignModule, ModuleId, RuntimeReconciler};
use lyxal_server::config::AppConfig;
use lyxal_server::context::AppContext;
use lyxal_server::http::build_router;
use lyxal_server::modules::auth;
use serde_json::Value;
use std::fs;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Modules déclarés par le nœud de `lyxal-groupware` (ordre alphabétique de `runtime_node`).
const GROUPWARE_MODULES: [&str; 8] = [
    "lyxal_auth",
    "lyxal_core",
    "lyxal_error",
    "lyxal_event",
    "lyxal_mail",
    "lyxal_scheduler",
    "lyxal_secrets",
    "lyxal_storage",
];

/// Configuration de `lyxal-server` (même forme que ses propres essais) sur la base
/// `namespace` / `database` (lue par son service d'authentification).
fn server_config(namespace: &str, database: &str, extra: &str) -> AppConfig {
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
namespace = "{namespace}"
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
    .expect("configuration");
    AppConfig::load_with_environment(directory.path(), Some(Default::default()))
        .expect("configuration de lyxal-server")
}

fn groupware_config() -> GroupwareConfig {
    crate::support::config(
        "two_hosts",
        &format!("[limits]\ndrain_seconds = 2\n{}", smtp_listener("smtp", "")),
    )
}

fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("groupware-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))))
}

async fn value(client: &Surreal<Any>, query: &str) -> Value {
    let mut response = client.query(query).await.expect("requête");
    let value: surrealdb::types::Value = response.take(0).expect("valeur");
    value.into_json_value()
}

async fn send(router: &axum::Router, uri: &str, token: Option<&str>) -> (StatusCode, Value) {
    let mut request = Request::builder().uri(uri);
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(Body::empty()).unwrap())
        .await
        .expect("réponse");
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .unwrap();
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

/// Routeur de `lyxal-server` avec son service d'authentification, et le jeton d'un
/// administrateur de la plateforme (droit `server.installation.manage`).
async fn server_router(
    database: &Database,
    base: (&str, &str),
    runtime: Arc<lyxal_runtime::LyxalRuntime>,
) -> (axum::Router, String) {
    let config = Arc::new(server_config(
        base.0,
        base.1,
        "[auth]\npublic_url = \"https://lyxal.test/\"\n",
    ));
    let host = auth::host(database, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let health = HealthRegistry::default();
    health.set("server", HealthState::Healthy, None).await;
    let router = build_router(AppContext::new(
        config,
        database.clone(),
        health,
        Metrics::default(),
        runtime,
        Some(host.clone()),
        Default::default(),
    ))
    .expect("routeur");
    database
        .fixed()
        .query(
            r#"CREATE auth_application:plateforme CONTENT { client_id: "lyxal-test-groupware-admin", name: "Plateforme", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
               RELATE auth_application:plateforme->auth_has_role->auth_role:platform_admin SET granted_at = time::now();"#,
        )
        .await
        .expect("requête")
        .check()
        .expect("compte de service");
    let token = host
        .access
        .internal_service_token("lyxal-test-groupware-admin")
        .await
        .expect("jeton")
        .access_token
        .expose_secret()
        .to_string();
    (router, token)
}

async fn lease_exists(client: &Surreal<Any>, host: &str) -> bool {
    value(
        client,
        &format!("RETURN record::exists(event_stream_lease:{host});"),
    )
    .await
        == Value::Bool(true)
}

async fn mail_installed_at(client: &Surreal<Any>) -> Value {
    value(
        client,
        "RETURN (SELECT VALUE installed_at FROM runtime_release WHERE module_id = 'lyxal_mail');",
    )
    .await
}

/// Scénario commun : `server_database` et `groupware_database`, sessions système des deux hôtes,
/// désignent la même base `base` (namespace, base).
async fn two_hosts(server_database: &Database, groupware_database: &Database, base: (&str, &str)) {
    // Requêtes de contrôle des essais : connexion fixe de la session système de lyxal-server
    let server_client = server_database.fixed();
    let server = lyxal_server::runtime::start(&server_config(base.0, base.1, ""), server_database)
        .await
        .expect("démarrage de lyxal-server");
    let config = groupware_config();
    let groupware = lyxal_groupware::runtime::start(
        &config,
        groupware_database,
        bind_listeners(&config).expect("liaison"),
        None,
    )
    .await
    .expect("démarrage de lyxal-groupware");

    // lyxal_mail : installé par lyxal-groupware seulement, inconnu du runtime de lyxal-server
    let installed_at = mail_installed_at(server_client).await;
    assert_eq!(
        installed_at.as_array().map(Vec::len),
        Some(1),
        "{installed_at}"
    );
    assert_eq!(
        server.runtime.module_state(&ModuleId::new("lyxal_mail")),
        None
    );

    // Deux nœuds de deux hôtes, même socle
    let nodes = value(
        server_client,
        "RETURN SELECT host, modules, foundation_checksum FROM runtime_node ORDER BY host;",
    )
    .await;
    let nodes = nodes.as_array().expect("nœuds").clone();
    assert_eq!(nodes.len(), 2, "{nodes:?}");
    assert_eq!(nodes[0]["host"], "lyxal_groupware");
    assert_eq!(nodes[1]["host"], "lyxal_server");
    assert_eq!(nodes[0]["modules"], serde_json::json!(GROUPWARE_MODULES));
    assert!(nodes[0]["foundation_checksum"].is_string());
    assert_eq!(
        nodes[0]["foundation_checksum"], nodes[1]["foundation_checksum"],
        "socle différent"
    );

    // Route système de lyxal-server : les nœuds vivants des deux hôtes
    let (router, admin) = server_router(server_database, base, server.runtime.clone()).await;
    let (status, reply) = send(&router, "/api/v1/system/modules", Some(&admin)).await;
    assert_eq!(status, StatusCode::OK, "{reply}");
    let system = &reply["data"];
    assert_eq!(system["host"], "lyxal_server", "{system}");
    let listed = system["nodes"].as_array().expect("nœuds");
    assert_eq!(listed.len(), 2, "{system}");
    let groupware_node = groupware.runtime.node_id().to_string();
    let node = listed
        .iter()
        .find(|n| n["node_id"] == groupware_node.as_str())
        .unwrap_or_else(|| panic!("nœud de lyxal-groupware absent : {system}"));
    assert_eq!(node["host"], "lyxal_groupware");
    assert_eq!(node["current"], false);
    assert_eq!(node["modules"], serde_json::json!(GROUPWARE_MODULES));

    // Un chef des événements par hôte
    let deadline = tokio::time::Instant::now() + Duration::from_secs(15);
    while !(lease_exists(server_client, "lyxal_server").await
        && lease_exists(server_client, "lyxal_groupware").await)
    {
        assert!(
            tokio::time::Instant::now() < deadline,
            "baux event_stream_lease des deux hôtes absents"
        );
        tokio::time::sleep(Duration::from_millis(100)).await;
    }

    // Réconciliation stricte de lyxal-server : lyxal_mail est le module d'un autre hôte
    let available = lyxal_server::modules::packages(server_client).expect("packages");
    let desired = available
        .iter()
        .fold(DesiredRuntimeState::new(), |desired, package| {
            desired.running(package.id().clone())
        })
        .with_strict(true);
    let plan = RuntimeReconciler::new(server.runtime.clone())
        .plan(&desired, &available)
        .await
        .expect("plan");
    assert!(plan.actions.is_empty(), "{:?}", plan.actions);
    assert_eq!(
        plan.foreign_modules,
        vec![ForeignModule {
            module_id: ModuleId::new("lyxal_mail"),
            hosts: vec!["lyxal_groupware".to_string()],
        }]
    );

    // Les ports de courrier répondent
    let address = groupware.mail.local_addrs("smtp")[0];
    let (_stream, reply) = greeting(address).await;
    assert_eq!(
        reply.as_bytes(),
        refusal_line(MailProtocol::Smtp, RefusalReason::Unavailable)
            .strip_suffix(b"\r\n")
            .unwrap()
    );

    // Arrêt de lyxal-groupware : nœud retiré, lyxal-server reste sain
    groupware
        .runtime
        .stop_all()
        .await
        .expect("arrêt de lyxal-groupware");
    let remaining = value(server_client, "RETURN SELECT VALUE host FROM runtime_node;").await;
    assert_eq!(remaining, serde_json::json!(["lyxal_server"]));
    let (status, health) = send(&router, "/health", None).await;
    assert_eq!(status, StatusCode::OK, "{health}");
    assert_ne!(health["modules"]["status"], "unhealthy", "{health}");

    // Redémarrage de lyxal-groupware (nouveau nœud) : aucune installation rejouée
    let config = groupware_config();
    let restarted = lyxal_groupware::runtime::start(
        &config,
        groupware_database,
        bind_listeners(&config).expect("liaison"),
        None,
    )
    .await
    .expect("redémarrage de lyxal-groupware");
    assert_eq!(mail_installed_at(server_client).await, installed_at);
    let hosts = value(
        server_client,
        "RETURN SELECT VALUE host FROM runtime_node ORDER BY host;",
    )
    .await;
    assert_eq!(
        hosts,
        serde_json::json!(["lyxal_groupware", "lyxal_server"])
    );

    restarted.runtime.stop_all().await.expect("arrêt");
    server
        .runtime
        .stop_all()
        .await
        .expect("arrêt de lyxal-server");
}

#[tokio::test]
async fn groupware_beside_lyxal_server_on_an_embedded_database() {
    let client = crate::support::database("two_hosts").await;
    two_hosts(
        &client.clone().into(),
        &client.into(),
        ("lyxal_test", "two_hosts"),
    )
    .await;
}

/// Serveur SurrealDB 3.3.4 réel (`ws://`) : chaque hôte ouvre sur la même base sa session système,
/// un pool de trois connexions (`connect_database`, comme au démarrage du binaire).
/// `LYXAL_SURREAL_WS_URL`, `LYXAL_SURREAL_USER`, `LYXAL_SURREAL_PASS` (`scripts/ci/test_all.sh`).
#[tokio::test]
#[ignore = "nécessite un serveur SurrealDB distant (LYXAL_SURREAL_WS_URL)"]
async fn groupware_beside_lyxal_server_on_a_remote_server() {
    let namespace = "lyxal_groupware_ws";
    let database = format!(
        "t{}",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_nanos()
    );
    let server_database = remote(namespace, &database).await;
    let groupware_database = remote(namespace, &database).await;
    assert_eq!(server_database.size(), 3);
    assert_eq!(groupware_database.size(), 3);

    two_hosts(
        &server_database,
        &groupware_database,
        (namespace, &database),
    )
    .await;

    server_database
        .fixed()
        .query(format!("REMOVE DATABASE {database}"))
        .await
        .unwrap()
        .check()
        .unwrap();
}

/// Session système d'un hôte sur le serveur d'essai : pool de trois connexions.
async fn remote(namespace: &str, database: &str) -> Database {
    let password = std::env::var("LYXAL_SURREAL_PASS").expect("LYXAL_SURREAL_PASS");
    connect_database(&DatabaseConfig {
        endpoint: std::env::var("LYXAL_SURREAL_WS_URL").expect("LYXAL_SURREAL_WS_URL"),
        namespace: namespace.to_string(),
        database: database.to_string(),
        username: Some(std::env::var("LYXAL_SURREAL_USER").expect("LYXAL_SURREAL_USER")),
        password: Some(SecretPassword::new(password).expect("mot de passe")),
        connect_timeout_seconds: 15,
        connections: std::num::NonZeroUsize::new(3).expect("connexions"),
    })
    .await
    .expect("connexions ws://")
}
