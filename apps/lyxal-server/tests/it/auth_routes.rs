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

/// Segment d'URL encodé (les identifiants `table:⟨clé⟩` contiennent des caractères réservés).
fn encode(segment: &str) -> String {
    segment
        .bytes()
        .map(|b| {
            if b.is_ascii_alphanumeric() || b"-_.~".contains(&b) {
                char::from(b).to_string()
            } else {
                format!("%{b:02X}")
            }
        })
        .collect()
}

/// Code TOTP calculé comme une application d'authentification depuis l'URI `otpauth://`.
fn totp_code(uri: &str) -> String {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let encoded = uri
        .split(['?', '&'])
        .find_map(|part| part.strip_prefix("secret="))
        .expect("secret");
    let (mut bits, mut count, mut bytes) = (0u64, 0, Vec::new());
    for c in encoded.bytes() {
        bits = (bits << 5) | ALPHABET.iter().position(|&a| a == c).expect("base32") as u64;
        count += 5;
        if count >= 8 {
            count -= 8;
            bytes.push((bits >> count) as u8);
        }
    }
    let secret =
        lyxal_crypto::TotpSecret::import(lyxal_crypto::SecretBytes::new(bytes).expect("octets"))
            .expect("secret");
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .expect("heure")
        .as_secs();
    lyxal_crypto::totp_generate(&secret, &lyxal_crypto::TotpConfig::default(), now)
        .expect("code")
        .expose_secret()
        .to_string()
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

/// Code et libellé de l'erreur métier renvoyée par un changement vers une organisation inconnue.
async fn error_label(router: &axum::Router, token: &str, accept: Option<&str>) -> (String, String) {
    let mut request = Request::builder()
        .method("POST")
        .uri("/api/v1/auth/session/organization")
        .header("content-type", "application/json")
        .header("authorization", format!("Bearer {token}"));
    if let Some(accept) = accept {
        request = request.header("accept-language", accept);
    }
    let request = request
        .body(Body::from(
            json!({ "organization": "auth_organization:inconnue" }).to_string(),
        ))
        .expect("requête");
    let response = tower::ServiceExt::oneshot(router.clone(), request)
        .await
        .expect("réponse");
    assert!(response.status().is_client_error());
    let bytes = to_bytes(response.into_body(), 1024 * 1024)
        .await
        .expect("corps");
    let body: Value = serde_json::from_slice(&bytes).expect("json");
    (
        body["error"]["code"]
            .as_str()
            .unwrap_or_default()
            .to_string(),
        body["error"]["label"]
            .as_str()
            .unwrap_or_default()
            .to_string(),
    )
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
    // Réponses des routes d'authentification jamais mises en cache
    let response = tower::ServiceExt::oneshot(
        disabled.clone(),
        Request::builder()
            .method("POST")
            .uri("/api/v1/auth/logout")
            .body(Body::empty())
            .expect("requête"),
    )
    .await
    .expect("réponse");
    assert_eq!(response.headers()["cache-control"], "no-store");
    assert_eq!(response.headers()["pragma"], "no-cache");

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
        .starts_with("https://lyxal.test/setup#token="));
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
    // Administrateur de la plateforme : double facteur à configurer avant toute session
    assert_eq!(
        registered["data"]["status"], "action_required",
        "{registered}"
    );
    assert_eq!(registered["data"]["actions"], json!(["configure_mfa"]));
    let login_flow = registered["data"]["flow"]
        .as_str()
        .expect("parcours")
        .to_string();
    let (status, enrollment) = call(
        &router,
        "POST",
        "/api/v1/auth/mfa/totp",
        None,
        Some(json!({ "login_flow": login_flow })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{enrollment}");
    let uri = enrollment["data"]["otpauth_uri"]
        .as_str()
        .expect("URI")
        .to_string();
    let (status, confirmed) = call(
        &router,
        "POST",
        "/api/v1/auth/mfa/totp/confirm",
        None,
        Some(json!({ "login_flow": login_flow, "code": totp_code(&uri) })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{confirmed}");
    let (status, codes) = call(
        &router,
        "POST",
        "/api/v1/auth/mfa/recovery-codes",
        None,
        Some(json!({ "login_flow": login_flow })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{codes}");
    let codes: Vec<String> = codes["data"]["codes"]
        .as_array()
        .expect("codes")
        .iter()
        .map(|c| c.as_str().expect("code").to_string())
        .collect();
    assert_eq!(codes.len(), 10);
    let (status, first) = call(
        &router,
        "POST",
        &format!("/api/v1/auth/flows/{}/actions", encode(&login_flow)),
        None,
        Some(json!({})),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{first}");
    assert_eq!(first["data"]["status"], "authenticated");

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
    // Second facteur demandé : code de secours
    assert_eq!(logged["data"]["status"], "mfa_required", "{logged}");
    assert_eq!(logged["data"]["methods"], json!(["totp", "recovery_code"]));
    let mfa_flow = logged["data"]["flow"]
        .as_str()
        .expect("parcours")
        .to_string();
    let (status, logged) = call(
        &router,
        "POST",
        &format!("/api/v1/auth/flows/{}/mfa", encode(&mfa_flow)),
        None,
        Some(json!({ "method": "recovery_code", "code": codes[0] })),
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
    // Révocation d'une autre de ses sessions (route paramétrée)
    let other = list
        .iter()
        .find(|s| s["current"] != true)
        .and_then(|s| s["session"].as_str())
        .expect("autre session")
        .to_string();
    let (status, revoked) = call(
        &router,
        "DELETE",
        &format!("/api/v1/auth/sessions/{}", encode(&other)),
        Some(&access),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{revoked}");
    assert_eq!(revoked["data"]["revoked"], true);

    // Facteurs de l'identité ; réauthentification par le seul mot de passe refusée
    let (status, factors) = call(&router, "GET", "/api/v1/auth/mfa", Some(&access), None).await;
    assert_eq!(status, StatusCode::OK, "{factors}");
    assert_eq!(factors["data"]["totp"]["state"], "active");
    assert_eq!(factors["data"]["recovery_codes"]["remaining"], 9);
    assert_eq!(factors["data"]["available_aal"], 2);
    let (status, refused) = call(
        &router,
        "POST",
        "/api/v1/auth/session/reauthenticate",
        Some(&access),
        Some(json!({ "method": "password", "code": "Mot-de-passe-solide-2026" })),
    )
    .await;
    assert!(status.is_client_error(), "{refused}");
    assert_eq!(refused["error"]["code"], "AUTH_MFA_REQUIRED");
    let (status, reauthenticated) = call(
        &router,
        "POST",
        "/api/v1/auth/session/reauthenticate",
        Some(&access),
        Some(json!({ "method": "recovery_code", "code": codes[1] })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{reauthenticated}");
    assert!(reauthenticated["data"]["refresh_token"].is_null());

    // Jeton d'une clé d'API limitée : aucun accès à la gestion du compte de son propriétaire
    let api_key = "lyxk_cle-de-test-du-serveur-0123456789";
    client
        .query("CREATE auth_api_key CONTENT { identity: (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1), name: 'lecture', key_hash: $hash, prefix: 'lyxk_cle', permissions: ['auth.member.read'] }")
        .bind(("hash", lyxal_crypto::hash::blake3_hex(api_key.as_bytes())))
        .await
        .expect("clé d'API")
        .check()
        .expect("clé d'API créée");
    let (status, exchanged) = call(
        &router,
        "POST",
        "/api/v1/auth/api-keys/exchange",
        None,
        Some(json!({ "api_key": api_key })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{exchanged}");
    let key_token = exchanged["data"]["access_token"]
        .as_str()
        .expect("jeton de la clé")
        .to_string();
    for (method, uri) in [
        ("GET", "/api/v1/auth/sessions"),
        ("POST", "/api/v1/auth/verification"),
    ] {
        let (status, denied) = call(&router, method, uri, Some(&key_token), None).await;
        assert!(status.is_client_error(), "{uri} : {denied}");
        assert_eq!(denied["error"]["code"], "AUTH_PERMISSION_DENIED", "{uri}");
    }

    // Erreur métier renvoyée par SurrealQL : rendue dans la langue choisie par lyxal_i18n
    let fr = error_label(&router, &access, Some("fr-XX,fr;q=0.9")).await;
    let en = error_label(&router, &access, Some("en-XX,en;q=0.9")).await;
    assert!(fr.0.starts_with("AUTH_"), "{fr:?}");
    assert_eq!(fr.0, en.0);
    assert_ne!(fr.1, en.1, "libellé traduit : {fr:?} {en:?}");
    // Poids de Accept-Language : de (inactif) écarté, en préféré à fr
    assert_eq!(
        error_label(&router, &access, Some("de;q=0.5, fr;q=0.1, en;q=0.8")).await,
        en
    );
    // Sans langue : langue par défaut de l'installation
    assert_eq!(error_label(&router, &access, None).await, fr);
    // La langue de l'identité passe avant Accept-Language
    client
        .query("UPDATE auth_identity SET traits.locale = 'fr-CA' WHERE id = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1)")
        .await
        .expect("langue de l'identité")
        .check()
        .expect("langue de l'identité modifiée");
    assert_eq!(error_label(&router, &access, Some("en")).await, fr);
    client
        .query("UPDATE auth_identity UNSET traits.locale")
        .await
        .expect("langue retirée")
        .check()
        .expect("langue de l'identité retirée");
    // Langue de l'organisation active, avant Accept-Language
    client
        .query("CREATE auth_organization:langue CONTENT { slug: 'langue', name: 'Langue', locale: 'en' };
                RETURN fn::auth_organization_member_add({ organization: 'auth_organization:langue', identity: <string> (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1), roles: [] }).ok;")
        .await
        .expect("organisation")
        .check()
        .expect("organisation créée");
    let (status, switched) = call(
        &router,
        "POST",
        "/api/v1/auth/session/organization",
        Some(&access),
        Some(json!({ "organization": "auth_organization:langue" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{switched}");
    let in_organization = switched["data"]["access_token"]
        .as_str()
        .expect("jeton de l'organisation")
        .to_string();
    assert_eq!(error_label(&router, &in_organization, Some("fr")).await, en);
    // Le changement d'organisation remplace la session : la suite utilise le nouveau jeton
    let access = in_organization;

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
