//! Routes `/api/v1/notification/unsubscribe` de bout en bout sur l'hôte (base embarquée, runtime
//! démarré, liens activés par la clé applicative et `notification.public_url`) : page de
//! confirmation sans effet, désabonnement en un clic (RFC 8058) rejouable, page pour un
//! navigateur, jeton modifié ou absent refusé (400), abonné supprimé (400), liens non configurés
//! (404) ; aucune réponse mise en cache.

use axum::body::{to_bytes, Body};
use axum::http::{HeaderMap, Request, StatusCode};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_notification::models::UnsubscribeTarget;
use lyxal_server::{config::AppConfig, context::AppContext, http::build_router, runtime};
use lyxal_surreal::RecordId;
use std::fs;
use std::sync::Arc;
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
request_timeout_seconds = 30
graceful_shutdown_seconds = 5
max_concurrency = 32
body_limit_bytes = 1048576

[database]
endpoint = "mem://"
namespace = "lyxal_test"
database = "notification_http"
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

[crypto]
application_key_id = "app-test"

[notification]
public_url = "https://lyxal.test/"
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
    fn header(&self, name: &str) -> &str {
        self.headers
            .get(name)
            .and_then(|value| value.to_str().ok())
            .unwrap_or_default()
    }
}

async fn send(router: &axum::Router, method: &str, uri: &str, browser: bool) -> Reply {
    let mut request = Request::builder().method(method).uri(uri);
    if method == "POST" {
        request = request.header("content-type", "application/x-www-form-urlencoded");
    }
    if browser {
        request = request.header("accept", "text/html,application/xhtml+xml");
    }
    let body = if method == "POST" {
        Body::from("List-Unsubscribe=One-Click")
    } else {
        Body::empty()
    };
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(body).expect("requête"))
        .await
        .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let bytes = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps");
    let reply = Reply {
        status,
        headers,
        body: String::from_utf8_lossy(&bytes).to_string(),
    };
    if reply.status != StatusCode::NOT_FOUND {
        assert_eq!(reply.header("cache-control"), "no-store", "{method} {uri}");
    }
    reply
}

#[tokio::test]
async fn the_one_click_unsubscribe_routes_verify_the_signed_link() {
    std::env::set_var("LYXAL__CRYPTO__APPLICATION_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("notification_http")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client.clone().into())
        .await
        .expect("démarrage");
    let links = started
        .notification
        .links
        .clone()
        .expect("liens configurés");
    let context = || {
        AppContext::new(
            config.clone(),
            client.clone().into(),
            HealthRegistry::default(),
            Metrics::default(),
            started.runtime.clone(),
            None,
            Default::default(),
        )
    };
    let router =
        build_router(context().with_notification(started.notification.clone())).expect("routeur");

    // Abonné d'Alpha et catégorie de son parcours
    let mut response = client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_category:actualites CONTENT { tenant: auth_organization:alpha, key: "actualites", name: "Actualités" };
            RETURN fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "client-1", email: "claire@exemple.fr" }, must_exist: false }).subscriber.id;
            "#,
        )
        .await
        .expect("préparation");
    let subscriber: Option<RecordId> = response.take(2).expect("abonné");
    let subscriber = subscriber.expect("abonné créé");
    let token = links
        .token(&UnsubscribeTarget {
            scope: "alpha".into(),
            subscriber: subscriber.clone(),
            category: Some(RecordId::new("notification_category", "actualites")),
            workflow: None,
            channel: "email".into(),
        })
        .expect("jeton");
    let uri = format!("/api/v1/notification/unsubscribe?t={token}");
    let preferences = || async {
        let mut response = client
            .query("SELECT VALUE channels FROM notification_preference WHERE level = 'subscriber_category'")
            .await
            .expect("préférences");
        let channels: Vec<serde_json::Value> = response.take(0).expect("canaux");
        channels
    };

    // Page de confirmation : sans effet, formulaire qui fait le POST, sans script ni référent
    let page = send(&router, "GET", &uri, true).await;
    assert_eq!(page.status, StatusCode::OK, "{}", page.body);
    assert!(page.header("content-type").starts_with("text/html"));
    assert!(page.body.contains(&format!("action=\"?t={token}\"")));
    assert!(page
        .header("content-security-policy")
        .contains("default-src 'none'"));
    assert_eq!(page.header("referrer-policy"), "no-referrer");
    assert!(preferences().await.is_empty(), "la page ne désabonne pas");

    // Jeton modifié ou absent : refusé
    let mut tampered = token.clone();
    tampered.insert(3, 'x');
    for bad in [
        format!("/api/v1/notification/unsubscribe?t={tampered}"),
        "/api/v1/notification/unsubscribe".to_string(),
        "/api/v1/notification/unsubscribe?t=%3Cscript%3E".to_string(),
    ] {
        assert_eq!(
            send(&router, "GET", &bad, true).await.status,
            StatusCode::BAD_REQUEST
        );
        let refused = send(&router, "POST", &bad, false).await;
        assert_eq!(refused.status, StatusCode::BAD_REQUEST);
        assert!(refused.body.is_empty());
    }
    assert!(preferences().await.is_empty());

    // Un clic (client de messagerie) : 200 sans contenu ; rejouable
    let done = send(&router, "POST", &uri, false).await;
    assert_eq!((done.status, done.body.as_str()), (StatusCode::OK, ""));
    assert_eq!(
        send(&router, "POST", &uri, false).await.status,
        StatusCode::OK
    );
    assert_eq!(
        preferences().await,
        vec![serde_json::json!({ "email": false })]
    );
    // Depuis la page (navigateur) : page de confirmation
    let browser = send(&router, "POST", &uri, true).await;
    assert_eq!(browser.status, StatusCode::OK);
    assert!(browser.body.contains("Désabonnement enregistré"));

    // Abonné supprimé depuis l'envoi : lien sans effet
    client
        .query("DELETE notification_subscriber")
        .await
        .expect("suppression")
        .check()
        .expect("suppression acceptée");
    assert_eq!(
        send(&router, "POST", &uri, false).await.status,
        StatusCode::BAD_REQUEST
    );

    // Liens non configurés : routes absentes
    let bare = build_router(context()).expect("routeur");
    assert_eq!(
        send(&bare, "GET", &uri, false).await.status,
        StatusCode::NOT_FOUND
    );
    assert_eq!(
        send(&bare, "POST", &uri, false).await.status,
        StatusCode::NOT_FOUND
    );
}
