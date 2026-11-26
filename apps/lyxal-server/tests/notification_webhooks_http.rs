//! Routes `/api/v1/notification/webhooks/{intégration}` et
//! `/api/v1/notification/integrations/{intégration}/test` de bout en bout sur l'hôte (base
//! embarquée, runtime démarré, coffre-fort à clé maîtresse éphémère, faux fournisseur local) :
//! retour Postmark (identifiants Basic) qui supprime l'adresse, identifiants faux, rejeu
//! dédoublonné, corps illisible ou trop grand, intégration inconnue ou sans secret des retours ;
//! retour Mailgun signé, horodatage trop ancien ; réponses sans détail ; essai d'une intégration
//! (droits, envoi accepté puis refusé par le fournisseur, issue notée, aucun secret rendu) ; relais
//! SMTP d'une organisation dont le nom se résout en adresse privée refusé sans connexion.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    sign_hmac_sha256_hex, CryptoEngine, EncryptionKey, HmacKey, KeyId, KeyRingBuilder, KeyUse,
    SecretBytes, StaticKeyResolver,
};
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_notification::models::{IntegrationSaveParams, IntegrationSettings};
use lyxal_notification::{
    EmailDispatcher, EmailProviders, NotificationStore, StaticResolver, SECRETS_CONSUMER,
};
use lyxal_secrets::models::{SecretCreateParams, Stage};
use lyxal_secrets::{ClientWrite, SecretsStore};
use lyxal_server::modules::notification::NotificationHost;
use lyxal_server::{
    config::AppConfig, context::AppContext, http::build_router, modules::auth, runtime,
};
use lyxal_surreal::ToSql;
use serde_json::{json, Value};
use std::fs;
use std::sync::{Arc, Mutex};
use surrealdb::engine::any::{connect, Any};
use surrealdb::Surreal;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpListener;

/// Clé éphémère : 32 octets aléatoires, Base64 canonique (jamais une vraie clé).
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
database = "notification_retours"
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

/// Faux Postmark local : enregistre les chemins et l'en-tête du jeton, répond selon le scénario.
#[derive(Clone, Default)]
struct FakePostmark {
    seen: Arc<Mutex<Vec<String>>>,
    replies: Arc<Mutex<Vec<(u16, String)>>>,
}

impl FakePostmark {
    async fn start(&self) -> String {
        let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
        let base = format!(
            "http://127.0.0.1:{}",
            listener.local_addr().expect("adresse").port()
        );
        let this = self.clone();
        tokio::spawn(async move {
            while let Ok((mut socket, _)) = listener.accept().await {
                let this = this.clone();
                tokio::spawn(async move {
                    let mut buffer = Vec::new();
                    let mut chunk = [0u8; 8192];
                    while let Ok(n) = socket.read(&mut chunk).await {
                        if n == 0 {
                            return;
                        }
                        buffer.extend_from_slice(&chunk[..n]);
                        let text = String::from_utf8_lossy(&buffer).to_string();
                        if let Some(end) = text.find("\r\n\r\n") {
                            let length: usize = text[..end]
                                .lines()
                                .find_map(|l| {
                                    l.to_ascii_lowercase()
                                        .strip_prefix("content-length:")
                                        .map(|v| v.trim().parse().unwrap_or(0))
                                })
                                .unwrap_or(0);
                            if buffer.len() >= end + 4 + length {
                                break;
                            }
                        }
                    }
                    let text = String::from_utf8_lossy(&buffer).to_string();
                    let token = text
                        .lines()
                        .find_map(|l| {
                            l.to_ascii_lowercase()
                                .starts_with("x-postmark-server-token:")
                                .then(|| l[24..].trim().to_string())
                        })
                        .unwrap_or_default();
                    this.seen.lock().expect("verrou").push(format!(
                        "{} {token}",
                        text.split(' ').nth(1).unwrap_or_default()
                    ));
                    let (status, body) = {
                        let mut replies = this.replies.lock().expect("verrou");
                        if replies.is_empty() {
                            (200, r#"{"MessageID":"pm-essai","ErrorCode":0}"#.to_string())
                        } else {
                            replies.remove(0)
                        }
                    };
                    let response = format!("HTTP/1.1 {status} X\r\ncontent-type: application/json\r\ncontent-length: {}\r\nconnection: close\r\n\r\n{body}", body.len());
                    let _ = socket.write_all(response.as_bytes()).await;
                    let _ = socket.shutdown().await;
                });
            }
        });
        base
    }
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
    body: Vec<u8>,
) -> Reply {
    let mut request = Request::builder()
        .method("POST")
        .uri(uri)
        .header("content-type", "application/json");
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
    assert_eq!(
        response
            .headers()
            .get("cache-control")
            .and_then(|v| v.to_str().ok()),
        Some("no-store"),
        "{uri}"
    );
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

#[tokio::test]
async fn provider_webhooks_and_integration_tests_go_through_the_host() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_retours")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    let host = auth::host(&client.clone().into(), &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let fake = FakePostmark::default();
    let base = fake.start().await;
    // Hôte réel, avec les API des fournisseurs servies par le faux Postmark local
    let vault = started.secrets.client(SECRETS_CONSUMER);
    let notification = NotificationHost {
        dispatcher: Some(EmailDispatcher::new(
            Arc::new(
                EmailProviders::for_local_tests(&base)
                    .expect("faux fournisseurs")
                    // Relais SMTP d'Alpha dont le nom se résout dans le réseau interne
                    .with_resolver(Arc::new(StaticResolver::new().with(
                        "smtp.interne.test",
                        "10.0.0.1:587".parse().expect("adresse"),
                    ))),
            ),
            vault.clone(),
        )),
        ..started.notification.clone()
    };
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
        .with_notification(notification),
    )
    .expect("routeur");

    // Organisation, comptes, secrets, intégrations (Postmark d'Alpha, Mailgun de l'installation)
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_application:admin CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-retours-admin", name: "Admin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:admin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE auth_application:membre CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-retours-membre", name: "Membre", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "lyxal-test-retours-voisin", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:voisin->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", steps: [{ key: "email", type: "email" }] };
            CREATE notification_template:devis_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email", subject: "Devis", html_body: "<p>Devis</p>", text_body: "Devis" };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation refusée");
    let secrets = SecretsStore::new(client.clone());
    let mailgun_key = "0123456789abcdef0123456789abcdef";
    for (tenant, path, value) in [
        (
            Some("auth_organization:alpha"),
            "notification/postmark/api",
            r#"{"api_key":"pm-token-secret"}"#.to_string(),
        ),
        (
            Some("auth_organization:alpha"),
            "notification/postmark/webhook",
            r#"{"username":"lyxal","password":"retour-secret"}"#.to_string(),
        ),
        (
            None,
            "notification/mailgun/api",
            r#"{"api_key":"key-1"}"#.to_string(),
        ),
        (
            None,
            "notification/mailgun/webhook",
            format!(r#"{{"signing_key":"{mailgun_key}"}}"#),
        ),
    ] {
        secrets
            .secret_create(SecretCreateParams::new(
                tenant.map(str::to_string),
                path,
                "api_key",
            ))
            .await
            .expect("fiche");
        vault
            .write(ClientWrite {
                tenant: tenant.map(str::to_string),
                path: path.to_string(),
                value: SecretBytes::new(value.into_bytes()).expect("valeur"),
                stage: Stage::Current,
            })
            .await
            .expect("valeur");
    }
    let store = NotificationStore::new(client.clone());
    let settings = |domain: Option<&str>| IntegrationSettings {
        from_address: Some("noreply@lyxal.test".into()),
        domain: domain.map(str::to_string),
        ..IntegrationSettings::default()
    };
    let postmark = store
        .integration_create(IntegrationSaveParams {
            tenant: Some("auth_organization:alpha".into()),
            key: "postmark".into(),
            provider: Some("postmark".into()),
            name: Some("Postmark".into()),
            settings: Some(settings(None)),
            credentials_path: Some("notification/postmark/api".into()),
            webhook_path: Some("notification/postmark/webhook".into()),
            ..IntegrationSaveParams::default()
        })
        .await
        .expect("intégration Postmark");
    let mailgun = store
        .integration_create(IntegrationSaveParams {
            key: "mailgun".into(),
            provider: Some("mailgun".into()),
            name: Some("Mailgun".into()),
            settings: Some(settings(Some("mg.lyxal.test"))),
            credentials_path: Some("notification/mailgun/api".into()),
            webhook_path: Some("notification/mailgun/webhook".into()),
            ..IntegrationSaveParams::default()
        })
        .await
        .expect("intégration Mailgun");
    let without_webhook = store
        .integration_create(IntegrationSaveParams {
            key: "sans_retours".into(),
            provider: Some("mailgun".into()),
            name: Some("Sans retours".into()),
            settings: Some(settings(Some("mg.lyxal.test"))),
            credentials_path: Some("notification/mailgun/api".into()),
            ..IntegrationSaveParams::default()
        })
        .await
        .expect("intégration sans retours");
    let path = |id: &lyxal_surreal::RecordId| {
        let text = id.to_sql();
        let key = text
            .split_once(':')
            .map(|(_, key)| key.to_string())
            .unwrap_or_default();
        format!("/api/v1/notification/webhooks/{key}")
    };
    let postmark_uri = path(&postmark.id);

    // Un message envoyé par Postmark (identifiant pm-1 chez le fournisseur)
    client
        .query(
            r#"
            fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "d-1", to: { subscriber_id: "c1", email: "client@exemple.fr" } });
            LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w" }).data[0];
            fn::notification_job_complete({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: <string> $job.integration.id, provider_message_id: "pm-1", response_code: 200 });
            "#,
        )
        .await
        .expect("envoi")
        .check()
        .expect("envoi enregistré");

    // Retour Postmark : identifiants faux, absents, puis bons ; rejeu dédoublonné
    let bounce = json!({ "RecordType": "Bounce", "Type": "HardBounce", "ID": 77, "MessageID": "pm-1", "Email": "client@exemple.fr" }).to_string();
    let basic = |user: &str, pass: &str| {
        (
            "authorization",
            format!("Basic {}", STANDARD.encode(format!("{user}:{pass}"))),
        )
    };
    let refused = post(
        &router,
        &postmark_uri,
        &[basic("lyxal", "faux")],
        bounce.clone().into_bytes(),
    )
    .await;
    assert_eq!(
        (refused.status, refused.body.as_str()),
        (StatusCode::UNAUTHORIZED, "")
    );
    assert_eq!(
        post(&router, &postmark_uri, &[], bounce.clone().into_bytes())
            .await
            .status,
        StatusCode::UNAUTHORIZED
    );
    assert!(rows(&client, "SELECT * FROM notification_suppression")
        .await
        .is_empty());
    for _ in 0..2 {
        let accepted = post(
            &router,
            &postmark_uri,
            &[basic("lyxal", "retour-secret")],
            bounce.clone().into_bytes(),
        )
        .await;
        assert_eq!(
            (accepted.status, accepted.body.as_str()),
            (StatusCode::OK, "")
        );
    }
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE provider_event_id FROM notification_provider_event"
        )
        .await,
        vec![json!("Bounce:77")]
    );
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE [address, reason] FROM notification_suppression"
        )
        .await,
        vec![json!(["client@exemple.fr", "hard_bounce"])]
    );
    assert_eq!(
        rows(&client, "SELECT VALUE status FROM notification_message").await,
        vec![json!("bounced")]
    );

    // Corps illisible, trop grand ; intégration inconnue, mal écrite ou sans secret des retours
    let unreadable = post(
        &router,
        &postmark_uri,
        &[basic("lyxal", "retour-secret")],
        b"pas du json".to_vec(),
    )
    .await;
    assert_eq!(
        (unreadable.status, unreadable.body.as_str()),
        (StatusCode::BAD_REQUEST, "")
    );
    let huge = vec![b' '; 256 * 1024 + 1];
    assert_eq!(
        post(
            &router,
            &postmark_uri,
            &[basic("lyxal", "retour-secret")],
            huge
        )
        .await
        .status,
        StatusCode::PAYLOAD_TOO_LARGE
    );
    for uri in [
        "/api/v1/notification/webhooks/inconnue".to_string(),
        "/api/v1/notification/webhooks/a:b".to_string(),
        path(&without_webhook.id),
    ] {
        let reply = post(&router, &uri, &[], bounce.clone().into_bytes()).await;
        assert_eq!(
            (reply.status, reply.body.as_str()),
            (StatusCode::NOT_FOUND, ""),
            "{uri}"
        );
    }

    // Retour Mailgun signé ; horodatage trop ancien refusé
    let key = HmacKey::import(SecretBytes::new(mailgun_key.as_bytes().to_vec()).expect("clé"))
        .expect("clé");
    let signed = |timestamp: i64| {
        let signature =
            sign_hmac_sha256_hex(&key, format!("{timestamp}jeton").as_bytes()).expect("signature");
        json!({
            "signature": { "timestamp": timestamp.to_string(), "token": "jeton", "signature": signature },
            "event-data": { "event": "delivered", "id": format!("mg-{timestamp}"), "message": { "headers": { "message-id": "inconnu@mg.lyxal.test" } } }
        })
        .to_string()
        .into_bytes()
    };
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .expect("horloge")
        .as_secs() as i64;
    let mailgun_uri = path(&mailgun.id);
    assert_eq!(
        post(&router, &mailgun_uri, &[], signed(now)).await.status,
        StatusCode::OK
    );
    assert_eq!(
        post(&router, &mailgun_uri, &[], signed(now - 400))
            .await
            .status,
        StatusCode::UNAUTHORIZED
    );
    assert_eq!(
        rows(&client, "SELECT VALUE provider_event_id FROM notification_provider_event WHERE integration.key = 'mailgun'").await,
        vec![json!(format!("mg-{now}"))]
    );

    // Essai d'une intégration : droits, envoi accepté, puis refusé par le fournisseur
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
    let admin = token("lyxal-test-retours-admin").await;
    let member = token("lyxal-test-retours-membre").await;
    let neighbour = token("lyxal-test-retours-voisin").await;
    let test_uri = format!(
        "{}/test",
        postmark_uri.replace("/webhooks/", "/integrations/")
    );
    let body = || json!({ "to": "Essai@Alpha.test" }).to_string().into_bytes();
    let bearer = |token: &str| ("authorization", format!("Bearer {token}"));
    let reply = post(&router, &test_uri, &[bearer(&admin)], body()).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(
        reply.json()["data"],
        json!({ "accepted": true, "code": null })
    );
    assert_eq!(
        fake.seen.lock().expect("verrou").clone(),
        vec!["/postmark/email pm-token-secret".to_string()]
    );
    fake.replies.lock().expect("verrou").push((
        401,
        r#"{"ErrorCode":10,"Message":"Bad or missing API token pm-token-secret"}"#.to_string(),
    ));
    let reply = post(&router, &test_uri, &[bearer(&admin)], body()).await;
    assert_eq!(
        reply.json()["data"],
        json!({ "accepted": false, "code": "NOTIFICATION_PROVIDER_REJECTED" })
    );
    assert!(!reply.body.contains("pm-token-secret"));
    assert_eq!(
        rows(&client, "SELECT VALUE [last_test.ok, last_test.code] FROM notification_integration WHERE key = 'postmark'").await,
        vec![json!([false, "NOTIFICATION_PROVIDER_REJECTED"])]
    );
    for caller in [&member, &neighbour] {
        let reply = post(&router, &test_uri, &[bearer(caller)], body()).await;
        assert!(
            [
                "NOTIFICATION_PERMISSION_DENIED",
                "NOTIFICATION_INTEGRATION_NOT_FOUND"
            ]
            .contains(&reply.json()["error"]["code"].as_str().unwrap_or_default()),
            "{}",
            reply.body
        );
    }
    assert_eq!(
        post(&router, &test_uri, &[], body()).await.status,
        StatusCode::UNAUTHORIZED
    );
    let bad = post(
        &router,
        &test_uri,
        &[bearer(&admin)],
        br#"{"to":"a@b.test","api_key":"x"}"#.to_vec(),
    )
    .await;
    assert_eq!(bad.status, StatusCode::BAD_REQUEST, "{}", bad.body);
    assert_eq!(
        fake.seen.lock().expect("verrou").len(),
        2,
        "aucun envoi refusé par les droits"
    );

    // Relais SMTP d'Alpha dont le nom se résout en adresse privée : refusé avant toute connexion,
    // l'essai ne sonde pas le réseau interne
    secrets
        .secret_create(SecretCreateParams::new(
            Some("auth_organization:alpha".to_string()),
            "notification/smtp/interne",
            "password",
        ))
        .await
        .expect("fiche");
    vault
        .write(ClientWrite {
            tenant: Some("auth_organization:alpha".to_string()),
            path: "notification/smtp/interne".to_string(),
            value: SecretBytes::new(br#"{"username":"lyxal","password":"relais-secret"}"#.to_vec())
                .expect("valeur"),
            stage: Stage::Current,
        })
        .await
        .expect("valeur");
    let relay = store
        .integration_create(IntegrationSaveParams {
            tenant: Some("auth_organization:alpha".into()),
            key: "relais_interne".into(),
            provider: Some("smtp".into()),
            name: Some("Relais interne".into()),
            settings: Some(IntegrationSettings {
                host: Some("smtp.interne.test".into()),
                port: Some(587),
                security: Some("starttls".into()),
                ..settings(None)
            }),
            credentials_path: Some("notification/smtp/interne".into()),
            ..IntegrationSaveParams::default()
        })
        .await
        .expect("intégration SMTP d'Alpha");
    let relay_uri = format!(
        "{}/test",
        path(&relay.id).replace("/webhooks/", "/integrations/")
    );
    let reply = post(&router, &relay_uri, &[bearer(&admin)], body()).await;
    assert_eq!(reply.status, StatusCode::OK, "{}", reply.body);
    assert_eq!(
        reply.json()["data"],
        json!({ "accepted": false, "code": "NOTIFICATION_DESTINATION_FORBIDDEN" })
    );
    assert!(!reply.body.contains("10.0.0.1") && !reply.body.contains("relais-secret"));
    assert_eq!(
        rows(&client, "SELECT VALUE [last_test.ok, last_test.code] FROM notification_integration WHERE key = 'relais_interne'").await,
        vec![json!([false, "NOTIFICATION_DESTINATION_FORBIDDEN"])]
    );

    started.runtime.stop_all().await.expect("arrêt");
}
