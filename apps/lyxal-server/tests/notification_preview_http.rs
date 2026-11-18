//! Route `POST /api/v1/notification/preview` de bout en bout sur l'hôte (base embarquée, runtime
//! démarré) : aperçu d'une étape rendu au nom de l'appelant (`notification.read`), sans écriture ;
//! droits (sans jeton, sans permission, autre organisation) ; corps refusé (champ inconnu comme un
//! secret, corps illisible, trop volumineux) ; `no-store` ; planification horaire de la purge
//! créée par l'installation du module.

use axum::body::{to_bytes, Body};
use axum::http::{HeaderMap, Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_server::{
    config::AppConfig, context::AppContext, health::HealthRegistry, http::build_router,
    metrics::Metrics, modules::auth, runtime,
};
use serde_json::{json, Value};
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::connect;

/// Clé éphémère : 32 octets aléatoires, Base64 canonique (jamais une vraie clé).
fn ephemeral_key() -> String {
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    STANDARD.encode(&bytes)
}

/// Trousseau applicatif éphémère du service de connexion.
fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("server-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))))
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
request_timeout_seconds = 30
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "notification_apercu"
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

[auth]
public_url = "https://lyxal.test/"

[secrets]
master_key_id = "vault-test"
"#,
    )
    .expect("écriture de la configuration");
    AppConfig::load_from(directory.path()).expect("configuration valide")
}

struct Reply {
    status: StatusCode,
    headers: HeaderMap,
    body: String,
}

impl Reply {
    fn json(&self) -> Value {
        serde_json::from_str(&self.body).unwrap_or(Value::Null)
    }

    fn code(&self) -> String {
        self.json()["error"]["code"]
            .as_str()
            .unwrap_or_default()
            .to_string()
    }
}

async fn preview(router: &axum::Router, token: Option<&str>, body: String) -> Reply {
    let mut request = Request::builder()
        .method("POST")
        .uri("/api/v1/notification/preview")
        .header("content-type", "application/json");
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let response = tower::ServiceExt::oneshot(
        router.clone(),
        request.body(Body::from(body)).expect("requête"),
    )
    .await
    .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    let reply = Reply {
        status,
        headers,
        body: String::from_utf8_lossy(&bytes).to_string(),
    };
    assert_eq!(
        reply
            .headers
            .get("cache-control")
            .and_then(|v| v.to_str().ok()),
        Some("no-store"),
        "{}",
        reply.body
    );
    reply
}

#[tokio::test]
async fn a_step_is_previewed_through_http_on_behalf_of_the_caller() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_apercu")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let router = build_router(
        AppContext::new(
            config.clone(),
            Arc::new(client.clone()),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            Some(host.clone()),
            Default::default(),
        )
        .with_notification(started.notification.clone()),
    )
    .expect("routeur");

    // La planification de la purge a été créée par l'installation du module (les autres
    // planifications de l'installation sont celles des tâches de fond de l'hôte)
    let schedules: Vec<Value> = client
        .query("SELECT VALUE [name, record::id(task)] FROM scheduler_schedule WHERE task.module = 'lyxal_notification'")
        .await
        .and_then(|mut r| r.take(0))
        .expect("planifications");
    assert_eq!(
        schedules,
        vec![json!(["notification-purge", "notification.purge"])]
    );

    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, scope_key: "alpha", key: "devis", name: "Devis", status: "draft", steps: [
                { key: "pause", type: "delay", amount: 1, unit: "days" }, { key: "email", type: "email" }
            ] };
            CREATE notification_template CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email",
                subject: "{{ t(\"notification.common.greeting\") }} {{ payload.numero }}",
                html_body: "<p>{{ payload.numero }} {{ secret.code }}{% if digest %} ({{ digest.count }}){% endif %}</p>",
                text_body: "Devis {{ payload.numero }}",
                keys: ["notification.common.greeting"] };
            CREATE auth_application:admin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-apercu-admin", name: "Admin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:admin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:membre CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-apercu-membre", name: "Membre", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "lyxal-test-apercu-voisin", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    let token = |client_id: &'static str| {
        let host = host.clone();
        async move {
            host.access
                .internal_service_token(client_id)
                .await
                .expect("jeton")
                .access_token
                .expose_secret()
                .to_string()
        }
    };
    let admin = token("lyxal-test-apercu-admin").await;
    let member = token("lyxal-test-apercu-membre").await;
    let neighbour = token("lyxal-test-apercu-voisin").await;
    let body = json!({
        "workflow": "notification_workflow:devis",
        "step_key": "email",
        "payload": { "numero": "<D-42>" },
        "locale": "en-GB",
        "digest": { "count": 3, "events": [] }
    })
    .to_string();

    // Aperçu rendu au nom de l'appelant, sans écriture ; secret absent affiché vide
    let reply = preview(&router, Some(&admin), body.clone()).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(
        reply.json()["data"],
        json!({ "subject": "Hello, <D-42>", "html": "<p>&lt;D-42&gt;  (3)</p>", "text": "Devis <D-42>" })
    );
    let runs: i64 = client
        .query("RETURN count(SELECT id FROM notification_run)")
        .await
        .and_then(|mut r| r.take::<Option<i64>>(0))
        .expect("déclenchements")
        .unwrap_or_default();
    assert_eq!(runs, 0, "aucune écriture");

    // Étape qui n'est pas un canal
    let step =
        json!({ "workflow": "notification_workflow:devis", "step_key": "pause" }).to_string();
    let reply = preview(&router, Some(&admin), step).await;
    assert_eq!(reply.status, StatusCode::NOT_FOUND, "{}", reply.body);
    assert_eq!(reply.code(), "NOTIFICATION_NOT_FOUND");

    // Droits : sans jeton, sans permission, autre organisation
    let reply = preview(&router, None, body.clone()).await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED, "{}", reply.body);
    // Parcours illisible sans la lecture de son organisation : introuvable, rien n'est rendu
    for caller in [&member, &neighbour] {
        let reply = preview(&router, Some(caller), body.clone()).await;
        assert!(
            [
                "NOTIFICATION_PERMISSION_DENIED",
                "NOTIFICATION_WORKFLOW_NOT_FOUND"
            ]
            .contains(&reply.code().as_str()),
            "{}",
            reply.body
        );
        assert!(reply.json()["data"].is_null());
    }

    // Corps refusé : champ inconnu (aucun secret accepté), corps illisible, trop volumineux
    let secret = json!({ "workflow": "notification_workflow:devis", "step_key": "email", "secret": { "code": "123456" } }).to_string();
    let reply = preview(&router, Some(&admin), secret).await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    assert!(!reply.body.contains("123456"));
    let reply = preview(&router, Some(&admin), "pas du json".to_string()).await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    let huge = json!({ "workflow": "notification_workflow:devis", "step_key": "email", "payload": { "texte": "x".repeat(70 * 1024) } }).to_string();
    let reply = preview(&router, Some(&admin), huge).await;
    assert_eq!(
        reply.status,
        StatusCode::PAYLOAD_TOO_LARGE,
        "{}",
        reply.body
    );

    started.runtime.stop_all().await.expect("arrêt");
}
