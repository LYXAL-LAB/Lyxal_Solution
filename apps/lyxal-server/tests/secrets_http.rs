//! Routes `/api/v1/secrets/*` de bout en bout sur une base embarquée : fiche créée, valeur écrite
//! puis révélée (en-têtes `no-store`), liste sans valeur, réglages, partage d'un texte ouvert
//! sans jeton puis refusé, route protégée refusée sans jeton.
//!
//! Exécutable de tests séparé : il fournit la clé maîtresse du coffre-fort par
//! `LYXAL__SECRETS__MASTER_KEY` (variable d'environnement du processus), ce qui changerait la
//! configuration des autres tests de l'hôte s'ils tournaient dans le même processus.

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
database = "coffre_http"
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

    fn header(&self, name: &str) -> &str {
        self.headers
            .get(name)
            .and_then(|value| value.to_str().ok())
            .unwrap_or_default()
    }
}

async fn send(
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
    let body = body.map_or_else(Body::empty, |body| Body::from(body.to_string()));
    let response = tower::ServiceExt::oneshot(router.clone(), request.body(body).expect("requête"))
        .await
        .expect("réponse");
    let (status, headers) = (response.status(), response.headers().clone());
    let bytes = to_bytes(response.into_body(), 4 * 1024 * 1024)
        .await
        .expect("corps");
    Reply {
        status,
        headers,
        body: String::from_utf8_lossy(&bytes).to_string(),
    }
}

#[tokio::test]
async fn the_vault_is_used_through_http_on_behalf_of_the_caller() {
    std::env::set_var("LYXAL__SECRETS__MASTER_KEY", ephemeral_key());
    let config = Arc::new(config());
    let client = connect("mem://").await.expect("connexion");
    client
        .use_ns("lyxal_test")
        .use_db("coffre_http")
        .await
        .expect("ns/db");
    let started = runtime::start(&config, &client).await.expect("démarrage");
    assert!(started.secrets.has_master_key());
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
        .with_secrets(started.secrets.clone()),
    )
    .expect("routeur");

    // Organisation, compte de service administrateur d'alpha qui lit aussi les valeurs, voisin de
    // beta
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
            CREATE auth_role:secrets_reader CONTENT { scope_key: "installation", key: "secrets_reader", name: "Lecteur des valeurs", scope: "organization", system: true };
            RELATE auth_role:secrets_reader->auth_role_grants->auth_permission:⟨secrets.value.read⟩;
            CREATE auth_application:coffre CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-coffre-alpha", name: "Coffre", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
            RELATE auth_application:coffre->auth_has_role->auth_role:organization_admin SET granted_at = time::now();
            RELATE auth_application:coffre->auth_has_role->auth_role:secrets_reader SET granted_at = time::now();
            CREATE auth_application:voisin CONTENT { tenant: auth_organization:beta, client_id: "lyxal-test-voisin-beta", name: "Voisin", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
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
    let admin = token("lyxal-test-coffre-alpha").await;
    let neighbour = token("lyxal-test-voisin-beta").await;
    const VALUE: &str = "sk_live_valeur_du_test";
    const SHARED: &str = "mot de passe du prestataire";

    // --- Sans jeton : refusé --------------------------------------------------------------
    let anonymous = send(
        &router,
        "GET",
        "/api/v1/secrets/secrets?tenant=auth_organization:alpha",
        None,
        None,
    )
    .await;
    assert!(!anonymous.status.is_success(), "{}", anonymous.body);
    assert_eq!(anonymous.json()["ok"], false);
    assert_eq!(
        anonymous.code(),
        "AUTH_SESSION_REQUIRED",
        "{}",
        anonymous.body
    );

    // --- Fiche, valeur, révélation --------------------------------------------------------
    let created = send(
        &router,
        "POST",
        "/api/v1/secrets/secrets",
        Some(&admin),
        Some(json!({
            "tenant": "auth_organization:alpha",
            "path": "api/stripe",
            "kind": "api_key",
            "consumers": ["auth_application:coffre"],
        })),
    )
    .await;
    assert_eq!(created.status, StatusCode::CREATED, "{}", created.body);
    let secret = created.json()["data"]["id"]
        .as_str()
        .expect("identifiant")
        .to_string();
    assert!(secret.starts_with("secrets_secret:"), "{secret}");

    let written = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/secrets/{secret}/versions"),
        Some(&admin),
        Some(json!({ "value": VALUE })),
    )
    .await;
    assert_eq!(written.status, StatusCode::CREATED, "{}", written.body);
    assert_eq!(written.json()["data"]["version"]["number"], 1);
    assert!(!written.body.contains(VALUE));

    let revealed = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/secrets/{secret}/reveal"),
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(revealed.status, StatusCode::OK, "{}", revealed.body);
    assert_eq!(revealed.json()["data"]["value"], VALUE);
    assert_eq!(revealed.json()["data"]["number"], 1);
    assert_eq!(revealed.header("cache-control"), "no-store");
    assert_eq!(revealed.header("pragma"), "no-cache");

    // Octets non UTF-8 : rendus en base64
    let binary = STANDARD.encode([0xff, 0x00, 0xfe]);
    let written = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/secrets/{secret}/versions"),
        Some(&admin),
        Some(json!({ "value_base64": binary })),
    )
    .await;
    assert_eq!(written.status, StatusCode::CREATED, "{}", written.body);
    let revealed = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/secrets/{secret}/reveal"),
        Some(&admin),
        Some(json!({ "number": 2 })),
    )
    .await;
    assert_eq!(revealed.json()["data"]["value_base64"], binary.as_str());
    assert!(revealed.json()["data"].get("value").is_none());

    // Autre organisation : la base refuse
    let refused = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/secrets/{secret}/reveal"),
        Some(&neighbour),
        None,
    )
    .await;
    assert!(!refused.status.is_success(), "{}", refused.body);
    assert!(refused.code().starts_with("SECRETS_"), "{}", refused.body);
    assert!(!refused.body.contains(VALUE));

    // --- Listes : jamais de valeur -------------------------------------------------------
    let listed = send(
        &router,
        "GET",
        "/api/v1/secrets/secrets?tenant=auth_organization:alpha&limit=10",
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(listed.status, StatusCode::OK, "{}", listed.body);
    assert_eq!(listed.json()["data"]["total"], 1);
    assert_eq!(listed.json()["data"]["items"][0]["path"], "api/stripe");
    let versions = send(
        &router,
        "GET",
        &format!("/api/v1/secrets/secrets/{secret}/versions"),
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(versions.status, StatusCode::OK, "{}", versions.body);
    assert_eq!(versions.json()["data"]["total"], 2);
    for reply in [&listed, &versions] {
        assert!(!reply.body.contains(VALUE) && !reply.body.contains(&binary));
        assert!(!reply.body.contains("enc:v2"));
    }

    // --- Réglages (durées) ----------------------------------------------------------------
    let settings = send(
        &router,
        "PUT",
        "/api/v1/secrets/settings",
        Some(&admin),
        Some(json!({ "tenant": "auth_organization:alpha", "share_max_ttl": "2d" })),
    )
    .await;
    assert_eq!(settings.status, StatusCode::OK, "{}", settings.body);
    let settings = send(
        &router,
        "GET",
        "/api/v1/secrets/settings?tenant=auth_organization:alpha",
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(settings.status, StatusCode::OK, "{}", settings.body);
    assert_eq!(settings.json()["data"]["effective"]["share_max_ttl"], "2d");

    // --- Partage d'un texte, ouvert sans jeton une fois ----------------------------------
    let shared = send(
        &router,
        "POST",
        "/api/v1/secrets/shares",
        Some(&admin),
        Some(json!({
            "tenant": "auth_organization:alpha",
            "value": SHARED,
            "ttl": "1h",
            "note": "prestataire",
        })),
    )
    .await;
    assert_eq!(shared.status, StatusCode::CREATED, "{}", shared.body);
    assert_eq!(shared.header("cache-control"), "no-store");
    assert_eq!(shared.header("pragma"), "no-cache");
    let share = shared.json()["data"]["share"]["id"]
        .as_str()
        .expect("partage")
        .to_string();
    let key = shared.json()["data"]["key"]
        .as_str()
        .expect("clé du lien")
        .to_string();
    assert!(!shared.body.contains(SHARED));

    let shares = send(
        &router,
        "GET",
        "/api/v1/secrets/shares?tenant=auth_organization:alpha",
        Some(&admin),
        None,
    )
    .await;
    assert_eq!(shares.status, StatusCode::OK, "{}", shares.body);
    assert_eq!(shares.json()["data"]["total"], 1);
    assert!(!shares.body.contains(SHARED) && !shares.body.contains(&key));

    let open = |key: String| json!({ "key": key });
    let opened = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/shares/{share}/open"),
        None,
        Some(open(key.clone())),
    )
    .await;
    assert_eq!(opened.status, StatusCode::OK, "{}", opened.body);
    assert_eq!(opened.json()["data"]["value"], SHARED);
    assert_eq!(opened.header("cache-control"), "no-store");

    let again = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/shares/{share}/open"),
        None,
        Some(open(key.clone())),
    )
    .await;
    assert_eq!(again.status, StatusCode::NOT_FOUND, "{}", again.body);
    assert_eq!(again.code(), "SECRETS_SHARE_UNAVAILABLE");
    assert!(!again.body.contains(SHARED) && !again.body.contains(&key));

    // Jeton présent mais invalide sur l'ouverture : contrôlé, donc refusé
    let forged = send(
        &router,
        "POST",
        &format!("/api/v1/secrets/shares/{share}/open"),
        Some("jeton.invalide.x"),
        Some(open(key)),
    )
    .await;
    assert!(!forged.status.is_success(), "{}", forged.body);
    assert!(forged.code().starts_with("AUTH_"), "{}", forged.body);

    started.runtime.stop_all().await.expect("arrêt");
}
