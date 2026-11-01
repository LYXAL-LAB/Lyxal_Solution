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
trust_proxy_headers = false

[database]
endpoint = "ws://127.0.0.1:8000"
namespace = "test"
database = "test"
connect_timeout_seconds = 1
required = true

[runtime]
run_migrations = false
fail_fast = true
parallel_start = false
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

[modules]
enabled = []
disabled = []
"#,
    )
    .expect("write config");

    let config = AppConfig::load_from(directory.path()).expect("valid config");
    assert_eq!(config.application.name, "Lyxal Test");
    assert_eq!(config.server.port, 0);
}
