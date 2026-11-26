//! Notifications push de `lyxal_notification` sur l'hôte (base embarquée, runtime démarré, coffre-fort à clé
//! maîtresse éphémère) : paire VAPID neuve rangée dans le coffre-fort (droit de gestion, clé privée
//! jamais montrée, clé publique notée sur l'intégration), clé publique VAPID donnée à la personne
//! de l'organisation, inscription des appareils par la personne connectée (jeton et clés scellés
//! par l'hôte sous l'empreinte du jeton, jamais relus ni renvoyés, inscription renvoyée mise à
//! jour), refus (service push inconnu, autre organisation, sans jeton d'accès) ; liste et retrait
//! de ses appareils et de ses adresses de messagerie par la personne (jamais ceux d'une autre).

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    CryptoEngine, EcdsaP256SigningKey, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, SecretBytes,
    StaticKeyResolver,
};
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_notification::{device_fingerprint, DeviceField, SecretCodec, SECRETS_CONSUMER};
use lyxal_secrets::models::SecretCreateParams;
use lyxal_secrets::{ClientRead, SecretsStore};
use lyxal_server::modules::notification::NotificationHost;
use lyxal_server::{
    config::AppConfig, context::AppContext, http::build_router, modules::auth, runtime,
};
use serde_json::{json, Value};
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;

const WEBPUSH_URL: &str =
    "https://updates.push.services.mozilla.com/wpush/v2/essai-abonnement-secret";
const P256DH: &str =
    "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4";
const AUTH: &str = "BTBZMqHH6r4Tts7J_aSIgg";
const FCM_TOKEN: &str = "jeton-fcm-essai-0000000000000000000000000001";
const APNS_TOKEN: &str = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

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
database = "notification_push"
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

async fn call(
    router: &axum::Router,
    method: &str,
    uri: &str,
    token: Option<&str>,
    body: Option<Value>,
) -> Reply {
    let mut request = Request::builder()
        .method(method)
        .uri(uri)
        .header("content-type", "application/json");
    if let Some(token) = token {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let body = body.map_or_else(Body::empty, |value| Body::from(value.to_string()));
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(body).expect("requête"))
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

/// Jeton d'accès d'une personne, par l'échange d'une clé d'API.
async fn person(router: &axum::Router, api_key: &str) -> String {
    let reply = call(
        router,
        "POST",
        "/api/v1/auth/api-keys/exchange",
        None,
        Some(json!({ "api_key": api_key })),
    )
    .await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    reply.json()["data"]["access_token"]
        .as_str()
        .expect("jeton")
        .to_string()
}

#[tokio::test]
async fn devices_are_sealed_by_the_host_and_vapid_keys_are_kept_in_the_vault() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_push")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    let host = auth::host(&client.clone().into(), &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let codec = SecretCodec::new(crypto());
    let router = build_router(
        AppContext::new(
            config.clone(),
            client.clone().into(),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            Some(host.clone()),
            Default::default(),
        )
        .with_secrets(started.secrets.clone())
        .with_notification(NotificationHost {
            codec: Some(codec.clone()),
            ..started.notification.clone()
        }),
    )
    .expect("routeur");
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_role:secrets_reader CONTENT { scope_key: "installation", key: "secrets_reader", name: "Lecteur des valeurs", scope: "organization", system: true };
            RELATE auth_role:secrets_reader->auth_role_grants->auth_permission:⟨secrets.value.read⟩;
            CREATE auth_application:admin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-push-admin", name: "Admin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:admin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            RELATE auth_application:admin->auth_has_role->auth_role:secrets_reader SET granted_at = time::now();
            CREATE auth_application:gestion CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-push-gestion", name: "Gestion", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:gestion->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_identity:personne CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "personne@lyxal.test", locale: "fr" } };
            RELATE auth_identity:personne->auth_member_of->auth_organization:alpha;
            RELATE auth_identity:personne->auth_member_of->auth_organization:beta;
            CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test", locale: "fr" } };
            RELATE auth_identity:autre->auth_member_of->auth_organization:alpha;
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    for (name, organization) in [("alpha", "alpha"), ("beta", "beta")] {
        client
            .query("CREATE auth_api_key CONTENT { identity: auth_identity:personne, organization: type::record('auth_organization', $organization), name: $name, key_hash: $hash, prefix: 'lyxk_pus', permissions: [] }")
            .bind(("organization", organization.to_string()))
            .bind(("name", name.to_string()))
            .bind(("hash", lyxal_crypto::hash::blake3_hex(format!("lyxk_push-essai-{name}").as_bytes())))
            .await
            .expect("clé d'API")
            .check()
            .expect("clé d'API créée");
    }
    SecretsStore::new(client.clone())
        .secret_create(SecretCreateParams::new(
            Some("auth_organization:alpha".to_string()),
            "notification/push/vapid",
            "api_key",
        ))
        .await
        .expect("fiche du secret");
    client
        .query(r#"CREATE notification_integration:webpush_alpha CONTENT { tenant: auth_organization:alpha, key: "webpush", channel: "push", provider: "webpush", name: "Web Push", settings: { vapid_subject: "mailto:contact@alpha.test" }, credentials_path: "notification/push/vapid" }"#)
        .await
        .expect("intégration")
        .check()
        .expect("intégration acceptée");
    let admin = host
        .access
        .internal_service_token("lyxal-test-push-admin")
        .await
        .expect("jeton")
        .access_token
        .expose_secret()
        .to_string();
    let personne = person(&router, "lyxk_push-essai-alpha").await;
    let personne_beta = person(&router, "lyxk_push-essai-beta").await;
    client
        .query("CREATE auth_api_key CONTENT { identity: auth_identity:autre, organization: auth_organization:alpha, name: 'autre', key_hash: $hash, prefix: 'lyxk_pus', permissions: [] }")
        .bind(("hash", lyxal_crypto::hash::blake3_hex(b"lyxk_push-essai-autre")))
        .await
        .expect("clé d'API")
        .check()
        .expect("clé d'API créée");
    let autre = person(&router, "lyxk_push-essai-autre").await;
    let vapid_key = "/api/v1/notification/push/vapid-key?tenant=auth_organization:alpha";

    // Pas encore de clé VAPID : aucune clé à donner
    let reply = call(&router, "GET", vapid_key, Some(&personne), None).await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_INTEGRATION_UNAVAILABLE",
        "{}",
        reply.body
    );

    // Paire VAPID neuve : clé privée rangée dans le coffre-fort, jamais montrée
    let generate = "/api/v1/notification/integrations/webpush_alpha/vapid";
    let reply = call(&router, "POST", generate, Some(&personne), None).await;
    assert_ne!(reply.status, StatusCode::OK, "{}", reply.body);
    let reply = call(&router, "POST", generate, Some(&admin), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert!(!reply.body.contains("PRIVATE KEY"));
    let public_key = reply.json()["data"]["public_key"]
        .as_str()
        .expect("clé publique")
        .to_string();
    assert_eq!(public_key.len(), 87);
    let stored = started
        .secrets
        .client(SECRETS_CONSUMER)
        .read(ClientRead {
            tenant: Some("auth_organization:alpha".to_string()),
            path: "notification/push/vapid".to_string(),
            label: None,
        })
        .await
        .expect("valeur du coffre-fort")
        .value;
    let stored: Value = serde_json::from_slice(stored.expose_secret()).expect("json");
    let private = stored["private_key"].as_str().expect("clé privée");
    assert!(private.starts_with("-----BEGIN PRIVATE KEY-----"));
    let imported = EcdsaP256SigningKey::import_pkcs8(
        SecretBytes::new(private.as_bytes().to_vec()).expect("valeur"),
    )
    .expect("clé VAPID");
    assert_eq!(
        base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(imported.public_key_uncompressed()),
        public_key
    );
    let settings = rows(
        &client,
        "SELECT VALUE settings FROM notification_integration:webpush_alpha",
    )
    .await;
    assert_eq!(settings[0]["vapid_public_key"], json!(public_key));
    assert_eq!(
        settings[0]["vapid_subject"],
        json!("mailto:contact@alpha.test")
    );

    // Écriture du coffre-fort sans droit de lire le secret : refus avant tout changement, la
    // paire en place reste accordée (clé privée inchangée, même clé publique)
    let gestion = host
        .access
        .internal_service_token("lyxal-test-push-gestion")
        .await
        .expect("jeton")
        .access_token
        .expose_secret()
        .to_string();
    let reply = call(&router, "POST", generate, Some(&gestion), None).await;
    assert_ne!(reply.status, StatusCode::OK, "{}", reply.body);
    let after = started
        .secrets
        .client(SECRETS_CONSUMER)
        .read(ClientRead {
            tenant: Some("auth_organization:alpha".to_string()),
            path: "notification/push/vapid".to_string(),
            label: None,
        })
        .await
        .expect("valeur du coffre-fort")
        .value;
    let after: Value = serde_json::from_slice(after.expose_secret()).expect("json");
    assert_eq!(after["private_key"].as_str(), Some(private));
    let settings = rows(
        &client,
        "SELECT VALUE settings FROM notification_integration:webpush_alpha",
    )
    .await;
    assert_eq!(settings[0]["vapid_public_key"], json!(public_key));

    // Clé publique donnée à la personne de l'organisation ; pas pour une autre organisation
    let reply = call(&router, "GET", vapid_key, Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(reply.json()["data"]["public_key"], json!(public_key));
    let reply = call(&router, "GET", vapid_key, Some(&personne_beta), None).await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_PERMISSION_DENIED",
        "{}",
        reply.body
    );
    let reply = call(&router, "GET", vapid_key, None, None).await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);

    // Inscription d'un navigateur : abonnement tel que le donne PushSubscription.toJSON()
    let devices = "/api/v1/notification/my/devices";
    let browser = json!({ "tenant": "auth_organization:alpha", "provider": "webpush", "name": "Firefox",
        "subscription": { "endpoint": WEBPUSH_URL, "expirationTime": null, "keys": { "p256dh": format!("{P256DH}="), "auth": format!("{AUTH}==") } } });
    let reply = call(
        &router,
        "POST",
        devices,
        Some(&personne),
        Some(browser.clone()),
    )
    .await;
    assert_eq!(reply.status, StatusCode::CREATED, "{}", reply.body);
    assert!(!reply.body.contains("essai-abonnement-secret"));
    assert_eq!(reply.json()["data"]["created"], json!(true));
    let device = reply.json()["data"]["device"].clone();
    assert_eq!(
        (
            device["provider"].as_str(),
            device["platform"].as_str(),
            device["host"].as_str()
        ),
        (
            Some("webpush"),
            Some("web"),
            Some("updates.push.services.mozilla.com")
        )
    );
    let id = device["id"].as_str().expect("appareil").to_string();
    // En base : valeurs scellées sous l'empreinte du jeton, jamais en clair
    let stored = rows(
        &client,
        &format!("SELECT token, p256dh, auth, fingerprint FROM {id}"),
    )
    .await;
    let fingerprint = device_fingerprint(WEBPUSH_URL);
    assert_eq!(stored[0]["fingerprint"], json!(fingerprint));
    let open = |field: &str, kind| {
        let envelope = stored[0][field].as_str().expect("valeur scellée");
        assert!(envelope.starts_with("enc:v2:"));
        String::from_utf8(
            codec
                .open_device_value(envelope, Some("alpha"), &fingerprint, kind)
                .expect("ouverture")
                .expose_secret()
                .to_vec(),
        )
        .expect("texte")
    };
    assert_eq!(open("token", DeviceField::Token), WEBPUSH_URL);
    assert_eq!(open("p256dh", DeviceField::P256dh), P256DH);
    assert_eq!(open("auth", DeviceField::Auth), AUTH);
    assert!(codec
        .open_device_value(
            stored[0]["token"].as_str().expect("jeton"),
            Some("alpha"),
            &"0".repeat(64),
            DeviceField::Token
        )
        .is_err());
    let dump = rows(&client, "SELECT * FROM notification_endpoint").await;
    assert!(!format!("{dump:?}").contains("essai-abonnement-secret"));

    // Inscription renvoyée : le même appareil est mis à jour
    let reply = call(&router, "POST", devices, Some(&personne), Some(browser)).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(reply.json()["data"]["created"], json!(false));
    assert_eq!(reply.json()["data"]["device"]["id"], json!(id));

    // Android (FCM) et iPhone (APNs) : jeton seul
    for (provider, token, platform) in [("fcm", FCM_TOKEN, "android"), ("apns", APNS_TOKEN, "ios")]
    {
        let reply = call(&router, "POST", devices, Some(&personne),
            Some(json!({ "tenant": "auth_organization:alpha", "provider": provider, "token": token }))).await;
        assert_eq!(reply.status, StatusCode::CREATED, "{}", reply.body);
        assert_eq!(reply.json()["data"]["device"]["platform"], json!(platform));
        assert!(!reply.body.contains(token));
    }
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE count() FROM notification_endpoint WHERE channel = 'push' GROUP ALL"
        )
        .await,
        vec![json!(3)]
    );

    // Refus : service push inconnu, autre organisation, corps mal formé, sans jeton d'accès
    let reply = call(&router, "POST", devices, Some(&personne), Some(json!({ "tenant": "auth_organization:alpha", "provider": "webpush",
        "subscription": { "endpoint": "https://push.pirate.test/abonnement", "keys": { "p256dh": P256DH, "auth": AUTH } } }))).await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    assert_eq!(reply.json()["error"]["code"], "NOTIFICATION_DEVICE_INVALID");
    let reply = call(
        &router,
        "POST",
        devices,
        Some(&personne_beta),
        Some(json!({ "tenant": "auth_organization:alpha", "provider": "fcm", "token": FCM_TOKEN })),
    )
    .await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_PERMISSION_DENIED",
        "{}",
        reply.body
    );
    let reply = call(
        &router,
        "POST",
        devices,
        Some(&personne),
        Some(json!({ "tenant": "auth_organization:alpha", "provider": "fcm" })),
    )
    .await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    let reply = call(
        &router,
        "POST",
        devices,
        None,
        Some(json!({ "tenant": "auth_organization:alpha", "provider": "fcm", "token": FCM_TOKEN })),
    )
    .await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);

    // Liste et retrait de ses appareils par la personne ; jamais ceux d'une autre personne
    let mine = format!("{devices}?tenant=auth_organization:alpha");
    let reply = call(&router, "GET", &mine, Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    let listed = reply.json()["data"]["devices"].clone();
    assert_eq!(listed.as_array().map(Vec::len), Some(3), "{}", reply.body);
    assert!(!reply.body.contains(FCM_TOKEN) && !reply.body.contains(&fingerprint));
    let fcm = listed
        .as_array()
        .and_then(|list| list.iter().find(|d| d["provider"] == "fcm"))
        .and_then(|d| d["id"].as_str())
        .expect("appareil FCM")
        .to_string();
    let path = |id: &str| {
        format!(
            "{devices}/{}?tenant=auth_organization:alpha",
            id.trim_start_matches("notification_endpoint:")
        )
    };
    let reply = call(
        &router,
        "POST",
        devices,
        Some(&autre),
        Some(json!({ "tenant": "auth_organization:alpha", "provider": "apns", "token": APNS_TOKEN.replace('0', "f") })),
    )
    .await;
    assert_eq!(reply.status, StatusCode::CREATED, "{}", reply.body);
    let reply = call(&router, "GET", &mine, Some(&autre), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(
        reply.json()["data"]["devices"].as_array().map(Vec::len),
        Some(1)
    );
    let reply = call(&router, "DELETE", &path(&fcm), Some(&autre), None).await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_DEVICE_NOT_FOUND",
        "{}",
        reply.body
    );
    let reply = call(&router, "DELETE", &path(&fcm), Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(reply.json()["data"]["deleted"], json!(fcm));
    let reply = call(&router, "GET", &mine, Some(&personne), None).await;
    assert_eq!(
        reply.json()["data"]["devices"].as_array().map(Vec::len),
        Some(2)
    );
    let reply = call(&router, "DELETE", &path("a:b"), Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::BAD_REQUEST, "{}", reply.body);
    let reply = call(&router, "GET", &mine, None, None).await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);
    // Adresses de messagerie et web : liste et retrait par la personne, jamais par une autre
    let endpoints = "/api/v1/notification/my/endpoints";
    let reply = call(&router, "POST", endpoints, Some(&personne),
        Some(json!({ "tenant": "auth_organization:alpha", "channel": "chat", "provider": "slack", "name": "Équipe", "url": "https://hooks.slack.com/services/essai-salon-secret" }))).await;
    assert_eq!(reply.status, StatusCode::CREATED, "{}", reply.body);
    let created = reply.json()["data"]["endpoint"]["id"]
        .as_str()
        .expect("adresse")
        .to_string();
    let mine = format!("{endpoints}?tenant=auth_organization:alpha&channel=chat");
    let reply = call(&router, "GET", &mine, Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    let listed = reply.json()["data"]["endpoints"].clone();
    assert_eq!(listed.as_array().map(Vec::len), Some(1), "{}", reply.body);
    assert_eq!(
        (listed[0]["id"].as_str(), listed[0]["host"].as_str()),
        (Some(created.as_str()), Some("hooks.slack.com"))
    );
    assert!(!reply.body.contains("essai-salon-secret"));
    let reply = call(&router, "GET", &mine, Some(&autre), None).await;
    assert_eq!(
        reply.json()["data"]["endpoints"],
        json!([]),
        "{}",
        reply.body
    );
    let path = |id: &str| {
        format!(
            "{endpoints}/{}?tenant=auth_organization:alpha",
            id.trim_start_matches("notification_endpoint:")
        )
    };
    let reply = call(&router, "DELETE", &path(&created), Some(&autre), None).await;
    assert_eq!(
        reply.json()["error"]["code"],
        "NOTIFICATION_ENDPOINT_NOT_FOUND",
        "{}",
        reply.body
    );
    let reply = call(&router, "DELETE", &path(&created), Some(&personne), None).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(reply.json()["data"]["deleted"], json!(created));
    let reply = call(&router, "GET", &mine, Some(&personne), None).await;
    assert_eq!(
        reply.json()["data"]["endpoints"],
        json!([]),
        "{}",
        reply.body
    );
    let reply = call(&router, "DELETE", &path(&created), None, None).await;
    assert_eq!(reply.status, StatusCode::UNAUTHORIZED);
}
