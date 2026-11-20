//! Routes `/api/v1/auth/*` de bout en bout sur une base embarquée : premier administrateur par le
//! lien d'installation, connexion (refus unique sur mot de passe faux), sessions de l'appelant
//! par son jeton d'accès, déconnexion (jeton refusé ensuite), service absent → 503.

use axum::body::{to_bytes, Body};
use axum::http::{Request, StatusCode};
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_host::{health::HealthRegistry, metrics::Metrics};
use lyxal_server::{context::AppContext, http::build_router, modules::auth, runtime};
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

pub(crate) fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
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
        Default::default(),
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
        Default::default(),
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

/// Jeton d'accès d'une session interactive ouverte directement par la session système (identité
/// préparée en base pour le test, sans mot de passe).
async fn session_token(
    host: &auth::AuthHost,
    config: &lyxal_server::config::AppConfig,
    identity: &str,
    organization: Option<&str>,
) -> String {
    let key = host.keys.signing_key().await.expect("clé");
    let issued = host
        .access
        .store()
        .session_create(lyxal_auth::models::SessionCreateParams {
            identity: identity.to_string(),
            organization: organization.map(str::to_string),
            amr: vec!["password".into()],
            client: lyxal_auth::models::ClientInfo::default(),
            access_slot: key.slot.clone(),
            refresh_token_hash: lyxal_crypto::hash::blake3_hex(identity.as_bytes()),
        })
        .await
        .expect("session");
    lyxal_auth::services::tokens::access_token(
        &key,
        &config.database.namespace,
        &config.database.database,
        &issued,
    )
    .expect("jeton")
    .expose_secret()
    .to_string()
}

async fn identity_of(
    client: &surrealdb::Surreal<surrealdb::engine::any::Any>,
    email: &str,
) -> String {
    let mut response = client
        .query("RETURN <string> (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = $email LIMIT 1)")
        .bind(("email", email.to_string()))
        .await
        .expect("identité");
    let identity: Option<String> = response.take(0).expect("identité");
    identity.expect("identité connue")
}

/// Mots de passe d'application par HTTP : permissions proposées, création refusée sans
/// authentification récente puis acceptée après réauthentification, mot de passe rendu une
/// seule fois (`Cache-Control: no-store`), liste sans secret, journal, révocations par le
/// titulaire et par les administrateurs (installation, organisation ; autre organisation et
/// simple membre refusés), jeton de clé d'API refusé.
#[tokio::test]
async fn app_passwords_through_http() {
    let config = Arc::new(config_with(
        "app_password_routes",
        "[auth]\npublic_url = \"https://lyxal.test/\"\n",
    ));
    let client = database("app_password_routes").await;
    let started = runtime::start(&config, &client).await.expect("démarrage");
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
        Default::default(),
    ))
    .expect("routeur");

    // Administrateur de la plateforme par le lien d'installation (double facteur non exigé ici)
    client
        .query("fn::auth_policy_save({ mfa: { required_roles: [] } })")
        .await
        .expect("politique")
        .check()
        .expect("politique enregistrée");
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
    let (_, started_registration) = call(
        &router,
        "POST",
        "/api/v1/auth/registration/start",
        None,
        Some(json!({ "token": token, "setup": true })),
    )
    .await;
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
    let admin_token = registered["data"]["access_token"]
        .as_str()
        .expect("jeton")
        .to_string();

    // Organisations, permissions déclarées par un module du courrier, membres
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
            CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
            fn::auth_permission_register({ code: "mail.mailbox.access", module: "lyxal_mail", scope: "organization", app_password: true });
            fn::auth_permission_register({ code: "mail.admin", module: "lyxal_mail", scope: "organization" });
            CREATE auth_role:messagerie CONTENT { scope_key: "installation", key: "messagerie", name: "Messagerie", scope: "organization" };
            RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩;
            RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.admin⟩;
            fn::auth_identity_create({ traits: { email: "claire@alpha.test" }, organization: "auth_organization:alpha" });
            fn::auth_identity_create({ traits: { email: "marc@alpha.test" }, organization: "auth_organization:alpha" });
            fn::auth_identity_create({ traits: { email: "admin@alpha.test" }, organization: "auth_organization:alpha" });
            fn::auth_identity_create({ traits: { email: "admin@beta.test" }, organization: "auth_organization:beta" });
            LET $member = |$email| (SELECT VALUE id FROM ONLY auth_member_of WHERE in = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = $email LIMIT 1) LIMIT 1);
            LET $admin = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "admin@lyxal.test" LIMIT 1);
            fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: <string> $admin, roles: [] });
            RELATE ($member("claire@alpha.test"))->auth_has_role->auth_role:messagerie;
            RELATE ($member("admin@lyxal.test"))->auth_has_role->auth_role:messagerie;
            RELATE ($member("admin@alpha.test"))->auth_has_role->auth_role:organization_admin;
            RELATE ($member("admin@beta.test"))->auth_has_role->auth_role:organization_admin;
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
    let claire = identity_of(&client, "claire@alpha.test").await;
    let claire_token =
        session_token(&host, &config, &claire, Some("auth_organization:alpha")).await;
    let marc_token = session_token(
        &host,
        &config,
        &identity_of(&client, "marc@alpha.test").await,
        Some("auth_organization:alpha"),
    )
    .await;
    let alpha_admin_token = session_token(
        &host,
        &config,
        &identity_of(&client, "admin@alpha.test").await,
        Some("auth_organization:alpha"),
    )
    .await;
    let beta_admin_token = session_token(
        &host,
        &config,
        &identity_of(&client, "admin@beta.test").await,
        Some("auth_organization:beta"),
    )
    .await;

    // Permissions proposées : celles du courrier utilisables, jamais mail.admin ni auth.*
    let (status, eligible) = call(
        &router,
        "GET",
        "/api/v1/auth/app-passwords/permissions",
        Some(&claire_token),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{eligible}");
    assert_eq!(eligible["data"][0]["code"], "mail.mailbox.access");
    assert_eq!(eligible["data"].as_array().map(Vec::len), Some(1));

    // L'administrateur passe dans alpha ; son authentification vieillit : création refusée
    let (status, switched) = call(
        &router,
        "POST",
        "/api/v1/auth/session/organization",
        Some(&admin_token),
        Some(json!({ "organization": "auth_organization:alpha" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{switched}");
    let admin_token = switched["data"]["access_token"]
        .as_str()
        .expect("jeton")
        .to_string();
    client
        .query("UPDATE auth_session SET authenticated_at = time::now() - 1h WHERE identity = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1)")
        .await
        .expect("authentification ancienne")
        .check()
        .expect("authentification vieillie");
    let create = json!({ "name": "iPhone", "permissions": ["mail.mailbox.access"] });
    let (status, refused) = call(
        &router,
        "POST",
        "/api/v1/auth/app-passwords",
        Some(&admin_token),
        Some(create.clone()),
    )
    .await;
    assert!(status.is_client_error(), "{refused}");
    assert_eq!(refused["error"]["code"], "AUTH_REAUTHENTICATION_REQUIRED");
    let (status, reauthenticated) = call(
        &router,
        "POST",
        "/api/v1/auth/session/reauthenticate",
        Some(&admin_token),
        Some(json!({ "method": "password", "code": "Mot-de-passe-solide-2026" })),
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{reauthenticated}");
    let admin_token = reauthenticated["data"]["access_token"]
        .as_str()
        .expect("jeton")
        .to_string();
    // Création : mot de passe rendu une seule fois, réponse jamais mise en cache
    let response = tower::ServiceExt::oneshot(
        router.clone(),
        Request::builder()
            .method("POST")
            .uri("/api/v1/auth/app-passwords")
            .header("content-type", "application/json")
            .header("authorization", format!("Bearer {admin_token}"))
            .body(Body::from(create.to_string()))
            .expect("requête"),
    )
    .await
    .expect("réponse");
    assert_eq!(response.status(), StatusCode::CREATED);
    assert_eq!(response.headers()["cache-control"], "no-store");
    let created: Value = serde_json::from_slice(
        &to_bytes(response.into_body(), 1024 * 1024)
            .await
            .expect("corps"),
    )
    .expect("json");
    let password = created["data"]["password"].as_str().expect("mot de passe");
    assert_eq!(password.len(), 23);
    assert_eq!(created["data"]["username"], "admin@lyxal.test");
    let admin_app = created["data"]["app_password"]["id"]
        .as_str()
        .expect("identifiant")
        .to_string();
    let (status, own) = call(
        &router,
        "GET",
        "/api/v1/auth/app-passwords",
        Some(&admin_token),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{own}");
    assert_eq!(own["data"][0]["id"], admin_app.as_str());
    assert_eq!(own["data"][0]["state"], "active");
    assert!(!own.to_string().contains(password));
    assert!(own["data"][0].get("password").is_none());

    // Claire crée deux mots de passe ; un logiciel se connecte avec le premier
    let mut claire_apps = Vec::new();
    for name in ["Téléphone", "Portable"] {
        let (status, created) = call(
            &router,
            "POST",
            "/api/v1/auth/app-passwords",
            Some(&claire_token),
            Some(json!({ "name": name, "permissions": ["mail.mailbox.access"], "expires_at": "2099-01-01T00:00:00Z" })),
        )
        .await;
        assert_eq!(status, StatusCode::CREATED, "{created}");
        claire_apps.push((
            created["data"]["app_password"]["id"]
                .as_str()
                .expect("identifiant")
                .to_string(),
            created["data"]["password"]
                .as_str()
                .expect("mot de passe")
                .to_string(),
        ));
    }
    host.access
        .app_passwords()
        .authenticate(lyxal_auth::AppPasswordAttempt {
            username: "claire@alpha.test".into(),
            password: lyxal_crypto::SecretString::new(claire_apps[0].1.clone()).expect("secret"),
            protocol: lyxal_auth::AppProtocol::Dav,
            client: lyxal_auth::models::ClientInfo {
                ip: Some("203.0.113.5".into()),
                user_agent: Some("DAVx5".into()),
            },
            client_name: Some("DAVx5".into()),
            secure: true,
        })
        .await
        .expect("connexion d'un logiciel");
    let (status, uses) = call(
        &router,
        "GET",
        &format!(
            "/api/v1/auth/app-passwords/{}/uses",
            encode(&claire_apps[0].0)
        ),
        Some(&claire_token),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{uses}");
    assert_eq!(uses["data"][0]["protocol"], "dav");
    assert_eq!(uses["data"][0]["count"], 1);

    // Administrateurs : celui d'alpha voit et révoque ; celui de beta et un simple membre non
    let claire_path = format!("/api/v1/auth/identities/{}/app-passwords", encode(&claire));
    let (status, listed) = call(&router, "GET", &claire_path, Some(&alpha_admin_token), None).await;
    assert_eq!(status, StatusCode::OK, "{listed}");
    assert_eq!(listed["data"].as_array().map(Vec::len), Some(2));
    let (status, other_org) =
        call(&router, "GET", &claire_path, Some(&beta_admin_token), None).await;
    assert_eq!(status, StatusCode::OK, "{other_org}");
    assert_eq!(other_org["data"], json!([]));
    let (status, denied) = call(&router, "GET", &claire_path, Some(&marc_token), None).await;
    assert!(status.is_client_error(), "{denied}");
    assert_eq!(denied["error"]["code"], "AUTH_PERMISSION_DENIED");
    let one = format!("{claire_path}/{}", encode(&claire_apps[0].0));
    let (status, not_found) = call(&router, "DELETE", &one, Some(&beta_admin_token), None).await;
    assert!(status.is_client_error(), "{not_found}");
    assert_eq!(not_found["error"]["code"], "AUTH_APP_PASSWORD_NOT_FOUND");
    let (status, revoked) = call(&router, "DELETE", &one, Some(&alpha_admin_token), None).await;
    assert_eq!(status, StatusCode::OK, "{revoked}");
    assert_eq!(revoked["data"]["revoked"], 1);

    // Titulaire : révocation d'un mot de passe, puis de tous ceux de l'organisation active
    let (status, revoked) = call(
        &router,
        "DELETE",
        &format!("/api/v1/auth/app-passwords/{}", encode(&claire_apps[1].0)),
        Some(&claire_token),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{revoked}");
    assert_eq!(revoked["data"]["revoked"], 1);
    let (status, revoked) = call(
        &router,
        "DELETE",
        "/api/v1/auth/app-passwords",
        Some(&admin_token),
        None,
    )
    .await;
    assert_eq!(status, StatusCode::OK, "{revoked}");
    assert_eq!(revoked["data"]["revoked"], 1);
    // Administrateur de l'installation : tous ceux d'une identité (aucun actif restant)
    let (status, revoked) = call(&router, "DELETE", &claire_path, Some(&admin_token), None).await;
    assert_eq!(status, StatusCode::OK, "{revoked}");
    assert_eq!(revoked["data"]["revoked"], 0);
    let (status, states) = call(&router, "GET", &claire_path, Some(&admin_token), None).await;
    assert_eq!(status, StatusCode::OK, "{states}");
    assert!(states["data"]
        .as_array()
        .expect("liste")
        .iter()
        .all(|a| a["state"] == "revoked"));

    // Jeton d'une clé d'API : aucun accès aux mots de passe d'application
    let api_key = "lyxk_cle-de-test-des-mots-de-passe";
    client
        .query("CREATE auth_api_key CONTENT { identity: <record> $claire, name: 'lecture', key_hash: $hash, prefix: 'lyxk_cle', permissions: ['mail.mailbox.access'], organization: auth_organization:alpha }")
        .bind(("claire", claire.clone()))
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
    for (method, uri, body) in [
        ("GET", "/api/v1/auth/app-passwords", None),
        ("GET", "/api/v1/auth/app-passwords/permissions", None),
        ("POST", "/api/v1/auth/app-passwords", Some(create.clone())),
        ("DELETE", "/api/v1/auth/app-passwords", None),
    ] {
        let (status, denied) = call(&router, method, uri, Some(&key_token), body).await;
        assert!(status.is_client_error(), "{uri} : {denied}");
        assert_eq!(denied["error"]["code"], "AUTH_PERMISSION_DENIED", "{uri}");
    }
    // Sans jeton : refusé
    let (status, _) = call(&router, "GET", "/api/v1/auth/app-passwords", None, None).await;
    assert!(status.is_client_error());

    started.runtime.stop_all().await.expect("arrêt");
}
