//! Coffre-fort des secrets avec sa clé maîtresse.
//!
//! Exécutable de tests séparé : il fournit la clé maîtresse du coffre-fort par
//! `LYXAL__SECRETS__MASTER_KEY` (variable d'environnement du processus, lue par
//! `EnvironmentKeyProvider`), ce qui changerait la configuration des autres tests de l'hôte
//! s'ils tournaient dans le même processus.

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::SecretBytes;
use lyxal_secrets::models::{SecretCreateParams, Stage};
use lyxal_secrets::{ClientRead, ClientWrite, SecretsStore};
use lyxal_server::{config::AppConfig, runtime};
use std::fs;
use surrealdb::engine::any::connect;

/// Clé éphémère : 32 octets aléatoires, Base64 canonique (jamais une vraie clé).
fn ephemeral_key() -> String {
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    STANDARD.encode(&bytes)
}

fn config() -> AppConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    fs::write(
        directory.path().join("default.toml"),
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
database = "coffre"
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

[secrets]
master_key_id = "vault-test"
"#,
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

/// Avec sa clé maîtresse, le coffre-fort est sain et un module hébergé écrit puis relit la
/// valeur d'un secret dont il est consommateur ; la clé applicative partagée n'est pas requise.
#[tokio::test]
async fn the_vault_with_its_master_key_writes_and_reads_values() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = config();
    assert!(config.crypto.application_key.is_none());

    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("coffre")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client).await.expect("démarrage");
    assert!(started.secrets.has_master_key());
    let probe = started
        .runtime
        .health_registry()
        .get_check(&lyxal_runtime::ModuleId::new("lyxal_secrets"))
        .expect("sonde")
        .check(&lyxal_runtime::ModuleContext::new("lyxal_secrets"))
        .await
        .expect("sonde");
    assert_eq!(
        probe.status,
        lyxal_runtime::health::HealthStatus::Healthy,
        "{probe:?}"
    );

    SecretsStore::new(client.clone())
        .secret_create(SecretCreateParams {
            consumers: vec!["lyxal_notification".into()],
            ..SecretCreateParams::new(None, "notification/smtp/password", "password")
        })
        .await
        .expect("fiche");
    let module = started.secrets.client("lyxal_notification");
    module
        .write(ClientWrite {
            tenant: None,
            path: "notification/smtp/password".into(),
            value: SecretBytes::new(b"mot de passe du relais".to_vec()).expect("valeur"),
            stage: Stage::Current,
        })
        .await
        .expect("écriture");
    let read = module
        .read(ClientRead {
            tenant: None,
            path: "notification/smtp/password".into(),
            label: None,
        })
        .await
        .expect("lecture");
    assert_eq!(read.value.expose_secret(), b"mot de passe du relais");
    let wrapped: Option<String> = client
        .query("RETURN (SELECT VALUE wrapped FROM ONLY secrets_tenant_key LIMIT 1)")
        .await
        .expect("requête")
        .take(0)
        .expect("clé d'organisation");
    assert!(wrapped.is_some_and(|w| w.starts_with("enc:v2:vault-test:")));

    started.runtime.stop_all().await.expect("arrêt");
}
