//! Routes `/api/v1/auth/*` de bout en bout sur une base embarquée : premier administrateur par le
//! lien d'installation, connexion (refus unique sur mot de passe faux), sessions de l'appelant
//! par son jeton d'accès, déconnexion (jeton refusé ensuite), service absent → 503.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_server::{
    context::AppContext, health::HealthRegistry, http::build_router, metrics::Metrics,
    modules::auth, runtime,
};
use serde_json::{json, Value};
use std::sync::Arc;

use crate::startup::{config_with, database};

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

async fn call(
    router: &axum::Router,
    method: &str,
    uri: &str,
    bearer: Option<&str>,
    body: Option<Value>,
) -> (StatusCode, Value) {
    let mut request = Request::builder()
        .method(method)
        .uri(uri)
        .header("content-type", "application/json");
    if let Some(token) = bearer {
        request = request.header("authorization", format!("Bearer {token}"));
    }
    let request = request
        .body(body.map_or_else(Body::empty, |b| Body::from(b.to_string())))
        .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    let status = response.status();
    let bytes = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps");
    (
        status,
        serde_json::from_slice(&bytes).unwrap_or(Value::Null),
    )
}

#[tokio::test]
async fn login_sessions_and_logout_through_http() {
    let config = Arc::new(config_with(
        "auth_routes",
        "[auth]\npublic_url = \"https://lyxal.test/\"\n",
    ));
    let client = database("auth_routes").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
    // Sans clé applicative dans l'environnement, l'hôte n'a pas de service de connexion
    assert!(started.auth.is_none());

    let disabled = build_router(AppContext::new(
        config.clone(),
        Arc::new(client.clone()),
        HealthRegistry::default(),
        Metrics::default(),
        started.runtime.clone(),
        None,
    ))
    .expect("routeur");
    let (status, body) = call(
        &disabled,
        "POST",
        "/api/v1/auth/login",
        None,
        Some(json!({ "identifier": "a@lyxal.test", "password": "x" })),
    )
    .await;
    assert_eq!(status, StatusCode::SERVICE_UNAVAILABLE, "{body}");
    assert_eq!(body["error"]["code"], "SERVER_AUTH_DISABLED");

    let host = auth::host(&client, &config, Some(crypto()))
        .expect("service")
        .expect("service configuré");
    auth::complete_services(Some(&host)).await.expect("clés");
    let router = build_router(AppContext::new(
        config.clone(),
        Arc::new(client.clone()),
        HealthRegistry::default(),
        Metrics::default(),
        started.runtime.clone(),
        Some(host.clone()),
    ))
    .expect("routeur");

    // Premier administrateur
    let link = host
        .access
        .setup_link("admin@lyxal.test")
        .await
        .expect("lien");
    let token = link
        .expose_secret()
        .rsplit("token=")
        .next()
        .expect("jeton")
        .to_string();
    assert!(link
        .expose_secret()
        .starts_with("https://lyxal.test/setup?token="));
    let (status, started_registration) = call(
        &router,
        "POST",
        "/api/v1/auth/registration/start",
        None,
        Some(json!({ "token": token, "setup": true })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{started_registration}");
    assert_eq!(started_registration["data"]["email"], "admin@lyxal.test");
    let (status, registered) = call(
        &router,
        "POST",
        "/api/v1/auth/registration/complete",
        None,
        Some(json!({
            "flow": started_registration["data"]["flow"],
            "password": "Mot-de-passe-solide-2026",
            "traits": { "name": { "first": "Ada" } }
        })),
    )
    .await;
    assert_eq!(status, StatusCode::CREATED, "{registered}");

    // Mot de passe faux : refus unique, sans détail
    let (status, refused) = call(
        &router,
        "POST",
        "/api/v1/auth/login",
        None,
        Some(json!({ "identifier": "admin@lyxal.test", "password": "faux-mot-de-passe" })),
    )
    .await;
    assert!(status.is_client_error(), "{refused}");
    assert_eq!(refused["ok"], false);
    assert_eq!(refused["error"]["code"], "AUTH_CREDENTIALS_INVALID");

    let (status, logged) = call(
        &router,
        "POST",
        "/api/v1/auth/login",
        None,
        Some(json!({ "identifier": "admin@lyxal.test", "password": "Mot-de-passe-solide-2026" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{logged}");
    assert_eq!(logged["data"]["status"], "authenticated");
    let access = logged["data"]["access_token"]
        .as_str()
        .expect("jeton d'accès")
        .to_string();
    assert!(logged["data"]["refresh_token"].is_string());

    // Sessions de l'appelant : celle d'inscription et la courante
    let (status, sessions) =
        call(&router, "GET", "/api/v1/auth/sessions", Some(&access), None).await;
    assert_eq!(status, StatusCode::OK, "{sessions}");
    let list = sessions["data"].as_array().expect("liste");
    assert_eq!(list.len(), 2, "{sessions}");
    assert_eq!(list.iter().filter(|s| s["current"] == true).count(), 1);

    // Sans jeton : refusé
    let (status, _) = call(&router, "GET", "/api/v1/auth/sessions", None, None).await;
    assert!(status.is_client_error());

    // Déconnexion : le jeton n'est plus accepté
    let (status, out) = call(&router, "POST", "/api/v1/auth/logout", Some(&access), None).await;
    assert_eq!(status, StatusCode::OK, "{out}");
    let (status, after) = call(&router, "GET", "/api/v1/auth/sessions", Some(&access), None).await;
    assert!(status.is_client_error(), "{after}");
    assert_eq!(after["ok"], false);

    started.runtime.stop_all().await.expect("arrêt");
}
