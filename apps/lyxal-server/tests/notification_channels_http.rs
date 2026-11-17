//! Canaux de texte de `lyxal_notification` sur l'hôte (base embarquée, runtime démarré, coffre-fort à clé
//! maîtresse éphémère) : routes des adresses de messagerie et web (`/api/v1/notification/
//! endpoints`) — adresse scellée par l'hôte avant d'entrer en base, jamais relue ni renvoyée,
//! clé de signature montrée une seule fois puis renouvelée, droits (gestion, sans droit, autre
//! organisation, personne connectée), hôte refusé ; retour Twilio signé
//! (`X-Twilio-Signature` sur l'adresse publique de l'hôte) accepté, signature fausse refusée.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, SecretBytes, StaticKeyResolver,
};
use lyxal_notification::{
    ChannelDispatcher, ChatSender, EndpointField, OutboundClient, SecretCodec, SmsApi,
    SECRETS_CONSUMER,
};
use lyxal_secrets::models::{SecretCreateParams, Stage};
use lyxal_secrets::{ClientWrite, SecretsStore};
use lyxal_server::modules::notification::NotificationHost;
use lyxal_server::{
    config::AppConfig, context::AppContext, health::HealthRegistry, http::build_router,
    metrics::Metrics, modules::auth, runtime,
};
use serde_json::{json, Value};
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

fn ephemeral_key() -> String {
    let mut bytes = uuid::Uuid::new_v4().as_bytes().to_vec();
    bytes.extend_from_slice(uuid::Uuid::new_v4().as_bytes());
    STANDARD.encode(&bytes)
}

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
database = "notification_canaux"
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
    body: String,
}

impl Reply {
    fn json(&self) -> Value {
        serde_json::from_str(&self.body).unwrap_or(Value::Null)
    }
}

async fn post(
    router: &axum::Router,
    uri: &str,
    headers: &[(&str, String)],
    content_type: &str,
    body: Vec<u8>,
) -> Reply {
    let mut request = Request::builder()
        .method("POST")
        .uri(uri)
        .header("content-type", content_type);
    for (name, value) in headers {
        request = request.header(*name, value);
    }
    let response = tower::ServiceExt::oneshot(
        router.clone(),
        request.body(Body::from(body)).expect("requête"),
    )
    .await
    .expect("réponse");
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    Reply {
        status,
        body: String::from_utf8_lossy(&bytes).to_string(),
    }
}

async fn rows(client: &Surreal<Any>, query: &str) -> Vec<Value> {
    let mut response = client.query(query).await.expect("requête");
    response.take(0).expect("lignes")
}

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

#[tokio::test]
async fn endpoints_are_sealed_by_the_host_and_sms_callbacks_are_verified() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_canaux")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client).await.expect("démarrage");
    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let vault = started.secrets.client(SECRETS_CONSUMER);
    let codec = SecretCodec::new(crypto());
    let notification = NotificationHost {
        channels: Some(ChannelDispatcher::new(
            Arc::new(SmsApi::for_local_tests("http://127.0.0.1:9").expect("faux fournisseurs")),
            Arc::new(ChatSender::new(OutboundClient::new()).expect("client")),
            vault.clone(),
            Some("https://lyxal.exemple.fr"),
        )),
        codec: Some(codec.clone()),
        public_url: Some("https://lyxal.exemple.fr".to_string()),
        ..started.notification.clone()
    };
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
        .with_notification(notification),
    )
    .expect("routeur");
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_application:admin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-canaux-admin", name: "Admin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:admin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:membre CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-canaux-membre", name: "Membre", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "lyxal-test-canaux-voisin", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s1", phone: "+33612345678" }, must_exist: false });
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
    let admin = token("lyxal-test-canaux-admin").await;
    let member = token("lyxal-test-canaux-membre").await;
    let neighbour = token("lyxal-test-canaux-voisin").await;
    let bearer = |token: &str| ("authorization", format!("Bearer {token}"));
    let json_body = |value: Value| value.to_string().into_bytes();
    let endpoint = || {
        json!({ "tenant": "auth_organization:alpha", "subscriber_id": "s1", "channel": "webhook", "provider": "webhook",
            "name": "CRM", "url": "https://crm.exemple.fr/hook?jeton=essai-valeur-secrete" })
    };

    // Adresse web : scellée par l'hôte, clé de signature montrée une fois, adresse jamais renvoyée
    let reply = post(
        &router,
        "/api/v1/notification/endpoints",
        &[bearer(&admin)],
        "application/json",
        json_body(endpoint()),
    )
    .await;
    assert_eq!(reply.status, StatusCode::CREATED, "{}", reply.body);
    assert!(!reply.body.contains("essai-valeur-secrete"));
    let data = reply.json()["data"].clone();
    assert_eq!(
        (
            data["endpoint"]["host"].as_str(),
            data["endpoint"]["signed"].as_bool()
        ),
        (Some("crm.exemple.fr"), Some(true))
    );
    let shown = data["signing_secret"]
        .as_str()
        .expect("clé montrée")
        .to_string();
    assert_eq!(shown.len(), 64);
    let id = data["endpoint"]["id"]
        .as_str()
        .expect("adresse")
        .to_string();
    let key = id.trim_start_matches("notification_endpoint:").to_string();
    // En base : valeurs scellées seulement, ouvertes par le contexte de l'adresse
    let stored = rows(&client, &format!("SELECT url, signing_secret FROM {id}")).await;
    let url = stored[0]["url"].as_str().expect("adresse scellée");
    let sealed_key = stored[0]["signing_secret"].as_str().expect("clé scellée");
    assert!(url.starts_with("enc:v2:") && sealed_key.starts_with("enc:v2:"));
    let dump = rows(&client, "SELECT * FROM notification_endpoint").await;
    assert!(!format!("{dump:?}").contains("essai-valeur-secrete"));
    let opened = codec
        .open_endpoint_value(url, Some("alpha"), &key, EndpointField::Url)
        .expect("ouverture");
    assert_eq!(
        opened.expose_secret(),
        b"https://crm.exemple.fr/hook?jeton=essai-valeur-secrete"
    );
    let opened = codec
        .open_endpoint_value(
            sealed_key,
            Some("alpha"),
            &key,
            EndpointField::SigningSecret,
        )
        .expect("ouverture");
    assert_eq!(hex(opened.expose_secret()), shown);
    // Une adresse scellée pour une autre adresse ou un autre champ ne s'ouvre pas
    assert!(codec
        .open_endpoint_value(url, Some("alpha"), "autre", EndpointField::Url)
        .is_err());
    assert!(codec
        .open_endpoint_value(url, Some("alpha"), &key, EndpointField::SigningSecret)
        .is_err());

    // Nouvelle clé de signature : différente, montrée une fois
    let reply = post(
        &router,
        &format!("/api/v1/notification/endpoints/{key}/rotate"),
        &[bearer(&admin)],
        "application/json",
        json_body(json!({ "tenant": "auth_organization:alpha" })),
    )
    .await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    let rotated = reply.json()["data"]["signing_secret"]
        .as_str()
        .expect("nouvelle clé")
        .to_string();
    assert_ne!(rotated, shown);
    let stored = rows(&client, &format!("SELECT VALUE signing_secret FROM {id}")).await;
    let opened = codec
        .open_endpoint_value(
            stored[0].as_str().expect("clé"),
            Some("alpha"),
            &key,
            EndpointField::SigningSecret,
        )
        .expect("ouverture");
    assert_eq!(hex(opened.expose_secret()), rotated);

    // Droits : sans droit de gestion, autre organisation ; personne connectée exigée pour /my
    for (token, uri) in [
        (&member, "/api/v1/notification/endpoints"),
        (&neighbour, "/api/v1/notification/endpoints"),
    ] {
        let reply = post(
            &router,
            uri,
            &[bearer(token)],
            "application/json",
            json_body(endpoint()),
        )
        .await;
        assert_eq!(reply.status, StatusCode::FORBIDDEN, "{}", reply.body);
        assert_eq!(
            reply.json()["error"]["code"],
            "NOTIFICATION_PERMISSION_DENIED"
        );
    }
    let mine = json!({ "tenant": "auth_organization:alpha", "channel": "chat", "provider": "slack", "name": "S", "url": "https://hooks.slack.com/services/essai" });
    let reply = post(
        &router,
        "/api/v1/notification/my/endpoints",
        &[bearer(&member)],
        "application/json",
        json_body(mine.clone()),
    )
    .await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_PERMISSION_DENIED",
        "{}",
        reply.body
    );
    // subscriber_id interdit pour sa propre adresse, requis pour une adresse gérée
    let reply = post(
        &router,
        "/api/v1/notification/my/endpoints",
        &[bearer(&member)],
        "application/json",
        json_body(endpoint()),
    )
    .await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST);
    let reply = post(
        &router,
        "/api/v1/notification/endpoints",
        &[bearer(&admin)],
        "application/json",
        json_body(mine),
    )
    .await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST);
    // Sans jeton : refus
    let reply = post(
        &router,
        "/api/v1/notification/endpoints",
        &[],
        "application/json",
        json_body(endpoint()),
    )
    .await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);
    // Hôte non officiel pour Slack : refusé, rien en base
    let slack = json!({ "tenant": "auth_organization:alpha", "subscriber_id": "s1", "channel": "chat", "provider": "slack", "name": "S", "url": "https://hooks.slack.com.pirate.test/x" });
    let reply = post(
        &router,
        "/api/v1/notification/endpoints",
        &[bearer(&admin)],
        "application/json",
        json_body(slack),
    )
    .await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_ENDPOINT_INVALID"
    );
    assert_eq!(
        rows(&client, "SELECT VALUE id FROM notification_endpoint")
            .await
            .len(),
        1
    );

    // Retour Twilio signé sur l'adresse publique de l'hôte
    let secrets = SecretsStore::new(client.clone());
    for (path, value) in [
        (
            "notification/twilio/api",
            r#"{"account_sid":"essai_compte","auth_token":"essai_jeton_twilio"}"#,
        ),
        (
            "notification/twilio/webhook",
            r#"{"auth_token":"essai_jeton_twilio"}"#,
        ),
    ] {
        secrets
            .secret_create(SecretCreateParams::new(
                Some("auth_organization:alpha".into()),
                path,
                "api_key",
            ))
            .await
            .expect("fiche");
        vault
            .write(ClientWrite {
                tenant: Some("auth_organization:alpha".into()),
                path: path.to_string(),
                value: SecretBytes::new(value.as_bytes().to_vec()).expect("valeur"),
                stage: Stage::Current,
            })
            .await
            .expect("valeur");
    }
    client
        .query(r#"CREATE notification_integration:twilio_essai CONTENT { tenant: auth_organization:alpha, key: "twilio", channel: "sms", provider: "twilio", name: "Twilio", settings: { sender: "+33700000000" }, credentials_path: "notification/twilio/api", webhook_path: "notification/twilio/webhook" }"#)
        .await
        .expect("intégration")
        .check()
        .expect("intégration acceptée");
    // Vecteur calculé indépendamment (module hmac de Python) sur l'adresse publique appelée
    let body = b"MessageSid=SMessai0001&MessageStatus=undelivered&ErrorCode=30005&AccountSid=essai_compte&To=%2B33612345678&From=%2B33700000000".to_vec();
    let uri = "/api/v1/notification/webhooks/twilio_essai";
    let form = "application/x-www-form-urlencoded";
    let reply = post(
        &router,
        uri,
        &[(
            "x-twilio-signature",
            "J8mBN8PSNl9BeI5t7qfuh2EB7xg=".to_string(),
        )],
        form,
        body.clone(),
    )
    .await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);
    assert_eq!(reply.body, "");
    let reply = post(
        &router,
        uri,
        &[(
            "x-twilio-signature",
            "I8mBN8PSNl9BeI5t7qfuh2EB7xg=".to_string(),
        )],
        form,
        body.clone(),
    )
    .await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    // Rejeu dédoublonné ; retour gardé jusqu'à l'enregistrement de son message
    let reply = post(
        &router,
        uri,
        &[(
            "x-twilio-signature",
            "I8mBN8PSNl9BeI5t7qfuh2EB7xg=".to_string(),
        )],
        form,
        body,
    )
    .await;
    assert_eq!(reply.status, StatusCode::OK);
    assert_eq!(
        rows(&client, "SELECT VALUE [provider_event_id, type, provider_message_id] FROM notification_provider_event").await,
        vec![json!(["SMessai0001:undelivered", "bounced", "SMessai0001"])]
    );
}
