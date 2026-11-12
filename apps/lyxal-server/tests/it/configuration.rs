use lyxal_server::config::AppConfig;
use std::fs;

#[test]
fn loads_and_validates_configuration() {
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
request_timeout_seconds = 5
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1024
trusted_proxies = ["10.0.0.0/8", "192.0.2.10"]

[database]
endpoint = "ws://127.0.0.1:8000"
namespace = "test"
database = "test"
username = "root"
password = "mot-de-passe-de-test"
connect_timeout_seconds = 1

[runtime]
module_install_timeout_seconds = 5
module_start_timeout_seconds = 5
module_stop_timeout_seconds = 5

[observability]
log_filter = "info"
json_logs = false
include_target = true
include_thread_ids = false

[cors]
enabled = false
allow_credentials = false
allowed_origins = []
allowed_methods = ["GET"]
allowed_headers = []

"#,
    )
    .expect("write config");

    let config = AppConfig::load_from(directory.path()).expect("valid config");
    assert_eq!(config.application.name, "Lyxal Test");
    assert_eq!(config.server.port, 0);
    assert_eq!(
        format!("{:?}", config.server.trusted_proxies),
        "[10.0.0.0/8, 192.0.2.10/32]"
    );

    // Le mot de passe n'apparaît jamais dans l'affichage de débogage de la configuration
    let debug = format!("{config:?}");
    assert!(!debug.contains("mot-de-passe-de-test"));
    assert!(debug.contains("[REDACTED]"));
}

#[test]
fn invalid_trusted_proxy_is_refused() {
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
request_timeout_seconds = 5
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1024
trusted_proxies = ["proxy.local"]

[database]
endpoint = "mem://"
namespace = "test"
database = "test"
connect_timeout_seconds = 1

[runtime]
module_install_timeout_seconds = 5
module_start_timeout_seconds = 5
module_stop_timeout_seconds = 5

[observability]
log_filter = "info"
json_logs = false
include_target = true
include_thread_ids = false

[cors]
enabled = false
allow_credentials = false
allowed_origins = []
allowed_methods = []
allowed_headers = []
"#,
    )
    .expect("write config");
    let error = AppConfig::load_from(directory.path()).expect_err("réseau invalide refusé");
    assert!(error.to_string().contains("proxy.local"), "{error}");
}

/// Configuration minimale de test, complétée par `extra` (sections TOML supplémentaires).
fn write_config(directory: &std::path::Path, extra: &str) {
    fs::write(
        directory.join("default.toml"),
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
request_timeout_seconds = 5
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1024

[database]
endpoint = "mem://"
namespace = "test"
database = "test"
connect_timeout_seconds = 1

[runtime]
module_install_timeout_seconds = 5
module_start_timeout_seconds = 5
module_stop_timeout_seconds = 5

[observability]
log_filter = "info"
json_logs = false
include_target = true
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
    .expect("write config");
}

fn variables(pairs: &[(&str, &str)]) -> Option<config::Map<String, String>> {
    Some(
        pairs
            .iter()
            .map(|(name, value)| (name.to_string(), value.to_string()))
            .collect(),
    )
}

#[test]
fn s3_storage_backends_are_read_from_the_environment() {
    let directory = tempfile::tempdir().expect("tempdir");
    write_config(directory.path(), "");
    let config = AppConfig::load_with_environment(
        directory.path(),
        variables(&[
            ("LYXAL__STORAGE__S3__BUNNY__ENDPOINT", "https://de-s3.storage.bunnycdn.com"),
            ("LYXAL__STORAGE__S3__BUNNY__REGION", "de"),
            ("LYXAL__STORAGE__S3__BUNNY__BUCKET", "zone-de-test"),
            ("LYXAL__STORAGE__S3__BUNNY__ACCESS_KEY_ID", "zone-de-test"),
            ("LYXAL__STORAGE__S3__BUNNY__SECRET_ACCESS_KEY", "mot-de-passe-de-zone"),
            ("LYXAL__STORAGE__IDLE_TIMEOUT_SECONDS", "30"),
        ]),
    )
    .expect("configuration valide");
    let bunny = config.storage.s3.get("bunny").expect("support bunny");
    assert_eq!(bunny.endpoint, "https://de-s3.storage.bunnycdn.com");
    assert_eq!(bunny.bucket, "zone-de-test");
    assert!(bunny.path_style && !bunny.allow_http);
    assert_eq!(config.storage.idle_timeout_seconds, 30);
    // La clé secrète n'apparaît jamais dans l'affichage de débogage
    let debug = format!("{config:?}");
    assert!(!debug.contains("mot-de-passe-de-zone"), "{debug}");

    // Champ manquant, champ inconnu, délai hors bornes : refus
    for (pairs, expected) in [
        (
            vec![("LYXAL__STORAGE__S3__BUNNY__ENDPOINT", "https://x.test")],
            "region",
        ),
        (
            vec![
                ("LYXAL__STORAGE__S3__BUNNY__ENDPOINT", "https://x.test"),
                ("LYXAL__STORAGE__S3__BUNNY__REGION", "de"),
                ("LYXAL__STORAGE__S3__BUNNY__BUCKET", "z"),
                ("LYXAL__STORAGE__S3__BUNNY__ACCESS_KEY_ID", "z"),
                ("LYXAL__STORAGE__S3__BUNNY__SECRET_ACCESS_KEY", "s"),
                ("LYXAL__STORAGE__S3__BUNNY__INCONNU", "1"),
            ],
            "inconnu",
        ),
        (
            vec![("LYXAL__STORAGE__IDLE_TIMEOUT_SECONDS", "2")],
            "idle_timeout_seconds",
        ),
    ] {
        let error = AppConfig::load_with_environment(directory.path(), variables(&pairs))
            .expect_err("configuration refusée");
        assert!(error.to_string().contains(expected), "{error}");
    }
}

#[test]
fn an_s3_secret_in_a_configuration_file_is_refused() {
    let directory = tempfile::tempdir().expect("tempdir");
    write_config(
        directory.path(),
        r#"
[storage.s3.bunny]
endpoint = "https://de-s3.storage.bunnycdn.com"
region = "de"
bucket = "zone-de-test"
access_key_id = "zone-de-test"
secret_access_key = "mot-de-passe-de-zone"
"#,
    );
    let error = AppConfig::load_with_environment(directory.path(), variables(&[]))
        .expect_err("clé secrète dans un fichier refusée");
    let message = error.to_string();
    assert!(
        message.contains("LYXAL__STORAGE__S3__BUNNY__SECRET_ACCESS_KEY"),
        "{message}"
    );
    assert!(!message.contains("mot-de-passe-de-zone"), "{message}");

    // Le reste du support peut être dans le fichier ; la clé secrète vient de l'environnement
    write_config(
        directory.path(),
        r#"
[storage.s3.bunny]
endpoint = "https://de-s3.storage.bunnycdn.com"
region = "de"
bucket = "zone-de-test"
access_key_id = "zone-de-test"
"#,
    );
    let config = AppConfig::load_with_environment(
        directory.path(),
        variables(&[("LYXAL__STORAGE__S3__BUNNY__SECRET_ACCESS_KEY", "mot-de-passe-de-zone")]),
    )
    .expect("configuration valide");
    assert!(config.storage.s3.contains_key("bunny"));
}

/// Serveur SurrealDB réel (`LYXAL_SURREAL_BIN`, à défaut `surreal` dans le `PATH`), arrêté à la
/// fin du test.
struct SurrealServer(std::process::Child);

impl Drop for SurrealServer {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

async fn surreal_server(allow_guests: bool) -> (SurrealServer, String) {
    let port = std::net::TcpListener::bind("127.0.0.1:0")
        .and_then(|l| l.local_addr())
        .expect("port libre")
        .port();
    let mut args = vec![
        "start".to_string(),
        "--bind".into(),
        format!("127.0.0.1:{port}"),
        "--user".into(),
        "root".into(),
        "--pass".into(),
        "root-de-test".into(),
    ];
    if allow_guests {
        args.push("--allow-guests".into());
    }
    args.push("memory".into());
    let child = std::process::Command::new(
        std::env::var("LYXAL_SURREAL_BIN").unwrap_or_else(|_| "surreal".into()),
    )
    .args(&args)
    .stdout(std::process::Stdio::null())
    .stderr(std::process::Stdio::null())
    .spawn()
    .expect("lancer `surreal` (LYXAL_SURREAL_BIN ou PATH)");
    let server = SurrealServer(child);
    let address = format!("127.0.0.1:{port}");
    let started = std::time::Instant::now();
    while tokio::net::TcpStream::connect(&address).await.is_err() {
        assert!(
            started.elapsed() < std::time::Duration::from_secs(30),
            "SurrealDB injoignable"
        );
        tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    }
    (server, format!("ws://{address}"))
}

fn remote_config(endpoint: String) -> lyxal_server::config::DatabaseConfig {
    lyxal_server::config::DatabaseConfig {
        endpoint,
        namespace: "test".into(),
        database: "test".into(),
        username: Some("root".into()),
        password: Some(
            lyxal_server::config::SecretPassword::new("root-de-test".into()).expect("secret"),
        ),
        connect_timeout_seconds: 5,
    }
}

/// Une base qui accepte les invités est refusée : un invité y serait traité comme la session
/// système par `lyxal_auth`.
#[tokio::test]
async fn database_accepting_guests_is_refused() {
    let (_open, endpoint) = surreal_server(true).await;
    let error = lyxal_server::database::connect_database(&remote_config(endpoint))
        .await
        .expect_err("invités acceptés : refus");
    assert!(error.to_string().contains("--allow-guests"), "{error}");

    let (_closed, endpoint) = surreal_server(false).await;
    lyxal_server::database::connect_database(&remote_config(endpoint))
        .await
        .expect("invités refusés : connexion acceptée");
}

#[tokio::test]
async fn remote_database_without_credentials_is_refused() {
    let config = lyxal_server::config::DatabaseConfig {
        endpoint: "ws://127.0.0.1:9".into(),
        namespace: "test".into(),
        database: "test".into(),
        username: None,
        password: None,
        connect_timeout_seconds: 1,
    };
    let error = lyxal_server::database::connect_database(&config)
        .await
        .expect_err("ws:// sans identifiants refusé");
    assert!(
        error.to_string().contains("Missing Root credentials"),
        "{error}"
    );
}
