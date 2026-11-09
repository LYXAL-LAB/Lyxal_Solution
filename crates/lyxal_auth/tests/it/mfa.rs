//! Double facteur de bout en bout sur le moteur embarqué : premier administrateur obligé de
//! configurer un second facteur (politique installée), TOTP calculé comme une application
//! d'authentification, codes de secours à usage unique, échecs et parcours échoué, passkeys avec
//! l'authentificateur logiciel de `webauthn-rs` (second facteur et connexion sans mot de passe),
//! réauthentification pour les actions sensibles.

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_auth::models::ClientInfo;
use lyxal_auth::{
    AccessConfig, AccessService, AuthStore, IssuedTokens, LoginActions, LoginOutcome, LoginRequest,
    MfaProof, ReauthProof, SigningKeyService,
};
use lyxal_crypto::{
    totp_generate, SecretBytes, SecretString, StaticKeyResolver, TotpConfig, TotpSecret,
};
use lyxal_surreal::{SurrealValue, ToSql};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use webauthn_authenticator_rs::softpasskey::SoftPasskey;
use webauthn_authenticator_rs::WebauthnAuthenticator;
use webauthn_rs::prelude::{CreationChallengeResponse, RequestChallengeResponse, Url};

use crate::support::{crypto, installed_store};

const PASSWORD: &str = "Mot-de-passe-solide-2026";

fn secret(text: &str) -> SecretString {
    SecretString::new(text.to_string()).expect("secret")
}

fn copy(value: &SecretString) -> SecretString {
    secret(value.expose_secret())
}

fn origin() -> Url {
    Url::parse("https://lyxal.test").expect("origine")
}

async fn service(store: &AuthStore) -> AccessService<StaticKeyResolver> {
    let engine = crypto();
    let keys = Arc::new(SigningKeyService::new(store.clone(), engine.clone()));
    keys.ensure().await.expect("clés");
    AccessService::new(
        store.clone(),
        engine,
        keys,
        AccessConfig {
            namespace: "auth".into(),
            database: "test".into(),
            public_url: "https://lyxal.test".into(),
            issuer: "Lyxal Test".into(),
            passkey_rp_id: None,
        },
    )
    .expect("service")
}

/// Code TOTP calculé comme une application d'authentification, `offset` pas après maintenant.
fn totp_code(uri: &SecretString, offset: u64) -> SecretString {
    let encoded = uri
        .expose_secret()
        .split(['?', '&'])
        .find_map(|part| part.strip_prefix("secret="))
        .expect("secret dans l'URI")
        .to_string();
    let secret = TotpSecret::import(SecretBytes::new(base32_decode(&encoded)).expect("octets"))
        .expect("secret TOTP");
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("heure")
        .as_secs();
    totp_generate(&secret, &TotpConfig::default(), now + offset * 30).expect("code")
}

fn base32_decode(text: &str) -> Vec<u8> {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let mut bits = 0u64;
    let mut count = 0;
    let mut out = Vec::new();
    for c in text.bytes() {
        let value = ALPHABET.iter().position(|&a| a == c).expect("base32") as u64;
        bits = (bits << 5) | value;
        count += 5;
        if count >= 8 {
            count -= 8;
            out.push((bits >> count) as u8);
        }
    }
    out
}

async fn login(access: &AccessService<StaticKeyResolver>) -> LoginOutcome {
    access
        .login(LoginRequest {
            identifier: "admin@lyxal.test".into(),
            password: secret(PASSWORD),
            organization: None,
            client: ClientInfo::default(),
        })
        .await
        .expect("connexion")
}

async fn mfa_flow(access: &AccessService<StaticKeyResolver>) -> (String, Vec<String>) {
    match login(access).await {
        LoginOutcome::MfaRequired { flow, methods } => (flow, methods),
        other => panic!("second facteur attendu : {other:?}"),
    }
}

/// Premier administrateur : l'inscription s'arrête sur configure_mfa (platform_admin).
async fn register_admin(access: &AccessService<StaticKeyResolver>) -> String {
    let link = access.setup_link("admin@lyxal.test").await.expect("lien");
    let token = link
        .expose_secret()
        .rsplit("token=")
        .next()
        .expect("jeton")
        .to_string();
    let started = access
        .start_registration(&secret(&token), true)
        .await
        .expect("inscription");
    let outcome = access
        .complete_registration(
            &started.flow.to_sql(),
            serde_json::json!({ "name": { "first": "Ada" } }).into_value(),
            &secret(PASSWORD),
            ClientInfo::default(),
        )
        .await
        .expect("administrateur");
    let LoginOutcome::ActionRequired { flow, actions } = outcome else {
        panic!("configuration du double facteur attendue : {outcome:?}");
    };
    assert_eq!(actions, vec!["configure_mfa".to_string()]);
    flow
}

/// Administrateur avec un TOTP et des codes de secours, connecté en AAL2.
struct Admin {
    uri: SecretString,
    codes: Vec<SecretString>,
    tokens: IssuedTokens,
}

async fn admin_with_totp(access: &AccessService<StaticKeyResolver>) -> Admin {
    let flow = register_admin(access).await;
    let actor = access.login_actor(&flow).await.expect("acteur");
    let enrollment = access.mfa().totp_begin(&actor).await.expect("enrôlement");
    access
        .mfa()
        .totp_confirm(&actor, &totp_code(&enrollment.otpauth_uri, 0))
        .await
        .expect("confirmation");
    let codes = access.mfa().recovery_codes(&actor).await.expect("codes");
    let outcome = access
        .complete_login_actions(&flow, LoginActions::default(), ClientInfo::default())
        .await
        .expect("session");
    let LoginOutcome::Authenticated(tokens) = outcome else {
        panic!("session attendue");
    };
    Admin {
        uri: enrollment.otpauth_uri,
        codes,
        tokens: *tokens,
    }
}

#[tokio::test]
async fn first_admin_configures_totp_before_any_session() {
    let store = installed_store().await;
    let access = service(&store).await;
    let flow = register_admin(&access).await;
    // Sans second facteur : toujours bloqué
    let blocked = access
        .complete_login_actions(&flow, LoginActions::default(), ClientInfo::default())
        .await
        .expect("parcours");
    assert!(matches!(blocked, LoginOutcome::ActionRequired { .. }));

    let actor = access.login_actor(&flow).await.expect("acteur");
    let enrollment = access.mfa().totp_begin(&actor).await.expect("enrôlement");
    let uri = enrollment.otpauth_uri.expose_secret();
    assert!(
        uri.starts_with("otpauth://totp/Lyxal%20Test:admin%40lyxal.test?secret="),
        "{uri}"
    );
    assert!(!format!("{enrollment:?}").contains("secret="));
    let wrong = access
        .mfa()
        .totp_confirm(&actor, &secret("000000"))
        .await
        .expect_err("code faux");
    assert!(wrong.is("AUTH_MFA_INVALID"), "{}", wrong.code());
    access
        .mfa()
        .totp_confirm(&actor, &totp_code(&enrollment.otpauth_uri, 0))
        .await
        .expect("confirmation");
    let codes = access.mfa().recovery_codes(&actor).await.expect("codes");
    assert_eq!(codes.len(), 10);
    let outcome = access
        .complete_login_actions(&flow, LoginActions::default(), ClientInfo::default())
        .await
        .expect("session");
    let LoginOutcome::Authenticated(tokens) = outcome else {
        panic!("session attendue");
    };
    assert_eq!(tokens.session.aal, 2);

    // Connexion suivante : second facteur demandé, aucune session sur le seul mot de passe
    let (flow, methods) = mfa_flow(&access).await;
    assert_eq!(
        methods,
        vec!["totp".to_string(), "recovery_code".to_string()]
    );
    let code = totp_code(&enrollment.otpauth_uri, 1);
    let tokens = access
        .complete_login_mfa(&flow, MfaProof::Totp(copy(&code)), ClientInfo::default())
        .await
        .expect("second facteur");
    assert_eq!(tokens.session.aal, 2);
    // Même code rejoué sur une autre connexion : refusé (anti-rejeu par pas)
    let (flow, _) = mfa_flow(&access).await;
    let replay = access
        .complete_login_mfa(&flow, MfaProof::Totp(code), ClientInfo::default())
        .await
        .expect_err("rejeu");
    assert!(replay.is("AUTH_MFA_INVALID"), "{}", replay.code());

    // Code de secours : une seule fois
    let (flow, _) = mfa_flow(&access).await;
    access
        .complete_login_mfa(
            &flow,
            MfaProof::RecoveryCode(copy(&codes[0])),
            ClientInfo::default(),
        )
        .await
        .expect("code de secours");
    let (flow, _) = mfa_flow(&access).await;
    let reused = access
        .complete_login_mfa(
            &flow,
            MfaProof::RecoveryCode(copy(&codes[0])),
            ClientInfo::default(),
        )
        .await
        .expect_err("code utilisé");
    assert!(reused.is("AUTH_MFA_INVALID"), "{}", reused.code());
}

#[tokio::test]
async fn wrong_second_factors_fail_the_flow() {
    let store = installed_store().await;
    let access = service(&store).await;
    admin_with_totp(&access).await;
    let (flow, _) = mfa_flow(&access).await;
    for _ in 0..4 {
        let error = access
            .complete_login_mfa(
                &flow,
                MfaProof::Totp(secret("123456")),
                ClientInfo::default(),
            )
            .await
            .expect_err("code faux");
        assert!(error.is("AUTH_MFA_INVALID"), "{}", error.code());
    }
    access
        .complete_login_mfa(
            &flow,
            MfaProof::Totp(secret("123456")),
            ClientInfo::default(),
        )
        .await
        .expect_err("cinquième essai");
    // Parcours échoué : plus aucun essai, même juste
    let closed = access
        .complete_login_mfa(
            &flow,
            MfaProof::RecoveryCode(secret("aaaaa-aaaaa")),
            ClientInfo::default(),
        )
        .await
        .expect_err("parcours échoué");
    assert!(closed.is("AUTH_FLOW_INVALID_STATE"), "{}", closed.code());
}

#[tokio::test]
async fn passkey_second_factor_and_passwordless_login() {
    let store = installed_store().await;
    let access = service(&store).await;
    let admin = admin_with_totp(&access).await;
    let caller = access
        .authenticate(&admin.tokens.access_token)
        .await
        .expect("appelant");
    let actor = AccessService::<StaticKeyResolver>::session_actor(&caller).expect("acteur");
    let mut authenticator = SoftPasskey::new(true);

    // Enregistrement
    let challenge = access
        .mfa()
        .passkey_registration_options(&actor)
        .await
        .expect("défi d'enregistrement");
    let options: CreationChallengeResponse =
        serde_json::from_value(challenge.options).expect("options");
    let registration = authenticator
        .do_registration(origin(), options)
        .expect("enregistrement");
    let saved = access
        .mfa()
        .passkey_register(
            &actor,
            &challenge.flow,
            serde_json::to_value(&registration).expect("json"),
            Some("Clé de test".into()),
        )
        .await
        .expect("passkey enregistrée");
    assert_eq!(saved.label.as_deref(), Some("Clé de test"));
    let factors = access.mfa().factors(&actor).await.expect("facteurs");
    assert_eq!(factors.passkeys.len(), 1);

    // Second facteur par passkey
    let (flow, methods) = mfa_flow(&access).await;
    assert!(methods.contains(&"passkey".to_string()));
    let options: RequestChallengeResponse =
        serde_json::from_value(access.login_passkey_options(&flow).await.expect("défi"))
            .expect("options");
    let response = authenticator
        .do_authentication(origin(), options)
        .expect("signature");
    let response = serde_json::to_value(&response).expect("json");
    let tokens = access
        .complete_login_mfa(
            &flow,
            MfaProof::Passkey {
                flow: flow.clone(),
                response: response.clone(),
            },
            ClientInfo::default(),
        )
        .await
        .expect("passkey acceptée");
    assert_eq!(tokens.session.aal, 2);

    // Réponse rejouée sur un nouveau défi : refusée
    let (flow, _) = mfa_flow(&access).await;
    access.login_passkey_options(&flow).await.expect("défi");
    let replay = access
        .complete_login_mfa(
            &flow,
            MfaProof::Passkey {
                flow: flow.clone(),
                response,
            },
            ClientInfo::default(),
        )
        .await
        .expect_err("rejeu");
    assert!(replay.is("AUTH_PASSKEY_INVALID"), "{}", replay.code());

    // Connexion sans mot de passe
    let identity = caller.identity.as_ref().expect("identité").to_sql();
    let user = uuid::Uuid::parse_str(identity.split_once(':').expect("clé").1).expect("uuid");
    let outcome = passwordless(
        &access,
        &mut authenticator,
        &registration.id,
        URL_SAFE_NO_PAD.encode(user.as_bytes()),
    )
    .await
    .expect("connexion sans mot de passe");
    let LoginOutcome::Authenticated(tokens) = outcome else {
        panic!("session attendue");
    };
    assert_eq!(tokens.session.aal, 2);
    let stranger = passwordless(
        &access,
        &mut authenticator,
        &registration.id,
        URL_SAFE_NO_PAD.encode(uuid::Uuid::now_v7().as_bytes()),
    )
    .await
    .expect_err("autre utilisateur");
    assert!(stranger.is("AUTH_PASSKEY_INVALID"), "{}", stranger.code());
}

/// Connexion sans mot de passe avec l'authentificateur logiciel : le défi lui désigne la clé
/// (il ne garde pas de clé découvrable) et l'identifiant d'utilisateur, non signé, qu'un appareil
/// réel renverrait est ajouté à sa réponse.
async fn passwordless(
    access: &AccessService<StaticKeyResolver>,
    authenticator: &mut SoftPasskey,
    credential_id: &str,
    user_handle: String,
) -> lyxal_auth::AuthResult<LoginOutcome> {
    let challenge = access.passkey_login_options().await.expect("défi");
    let mut options = challenge.options.clone();
    options["publicKey"]["allowCredentials"] =
        serde_json::json!([{ "type": "public-key", "id": credential_id }]);
    let options: RequestChallengeResponse = serde_json::from_value(options).expect("options");
    let mut response = serde_json::to_value(
        authenticator
            .do_authentication(origin(), options)
            .expect("signature"),
    )
    .expect("json");
    response["response"]["userHandle"] = serde_json::Value::String(user_handle);
    access
        .passkey_login(&challenge.flow, response, ClientInfo::default())
        .await
}

#[tokio::test]
async fn reauthentication_unlocks_sensitive_actions() {
    let store = installed_store().await;
    let access = service(&store).await;
    let admin = admin_with_totp(&access).await;
    let session = admin.tokens.session.session.to_sql();
    access
        .require_fresh(&session)
        .await
        .expect("authentification récente");
    store
        .client()
        .query(format!(
            "UPDATE {session} SET authenticated_at = time::now() - 2h"
        ))
        .await
        .expect("vieillissement");
    let stale = access.require_fresh(&session).await.expect_err("ancienne");
    assert!(
        stale.is("AUTH_REAUTHENTICATION_REQUIRED"),
        "{}",
        stale.code()
    );
    let caller = access
        .authenticate(&admin.tokens.access_token)
        .await
        .expect("appelant");
    // Identité avec un second facteur : le mot de passe seul ne suffit pas
    let refused = access
        .reauthenticate(&caller, ReauthProof::Password(secret(PASSWORD)))
        .await
        .expect_err("mot de passe seul");
    assert!(refused.is("AUTH_MFA_REQUIRED"), "{}", refused.code());
    let tokens = access
        .reauthenticate(
            &caller,
            ReauthProof::Mfa(MfaProof::RecoveryCode(copy(&admin.codes[1]))),
        )
        .await
        .expect("réauthentification");
    assert_eq!(tokens.session.aal, 2);
    assert!(tokens.refresh_token.is_none());
    access
        .require_fresh(&session)
        .await
        .expect("de nouveau récente");
    // Le nouveau jeton est accepté par l'hôte
    access
        .authenticate(&tokens.access_token)
        .await
        .expect("nouveau jeton");
    let _ = admin.uri;
}

#[tokio::test]
async fn password_only_identity_reauthenticates_then_enrolls() {
    let store = installed_store().await;
    let access = service(&store).await;
    store
        .client()
        .query("fn::auth_policy_save({ mfa: { required_roles: [] } })")
        .await
        .expect("politique");
    let link = access.setup_link("admin@lyxal.test").await.expect("lien");
    let token = link
        .expose_secret()
        .rsplit("token=")
        .next()
        .expect("jeton")
        .to_string();
    let started = access
        .start_registration(&secret(&token), true)
        .await
        .expect("inscription");
    let LoginOutcome::Authenticated(tokens) = access
        .complete_registration(
            &started.flow.to_sql(),
            serde_json::json!({}).into_value(),
            &secret(PASSWORD),
            ClientInfo::default(),
        )
        .await
        .expect("administrateur")
    else {
        panic!("session attendue");
    };
    assert_eq!(tokens.session.aal, 1);
    let session = tokens.session.session.to_sql();
    store
        .client()
        .query(format!(
            "UPDATE {session} SET authenticated_at = time::now() - 2h"
        ))
        .await
        .expect("vieillissement");
    let caller = access
        .authenticate(&tokens.access_token)
        .await
        .expect("appelant");
    let actor = AccessService::<StaticKeyResolver>::session_actor(&caller).expect("acteur");
    // Action sensible sur une session ancienne : refusée
    let stale = access.mfa().totp_begin(&actor).await.expect_err("ancienne");
    assert!(
        stale.is("AUTH_REAUTHENTICATION_REQUIRED"),
        "{}",
        stale.code()
    );
    let wrong = access
        .reauthenticate(
            &caller,
            ReauthProof::Password(secret("mauvais-mot-de-passe")),
        )
        .await
        .expect_err("mot de passe faux");
    assert!(wrong.is("AUTH_CREDENTIALS_INVALID"), "{}", wrong.code());
    let tokens = access
        .reauthenticate(&caller, ReauthProof::Password(secret(PASSWORD)))
        .await
        .expect("réauthentification");
    assert_eq!(tokens.session.aal, 1);
    // Enrôlement dans la session : la session monte en AAL2 (possession prouvée)
    let enrollment = access.mfa().totp_begin(&actor).await.expect("enrôlement");
    access
        .mfa()
        .totp_confirm(&actor, &totp_code(&enrollment.otpauth_uri, 0))
        .await
        .expect("confirmation");
    #[derive(Debug, SurrealValue)]
    struct Aal {
        aal: i64,
    }
    let mut response = store
        .client()
        .query(format!("SELECT aal FROM ONLY {session}"))
        .await
        .expect("session");
    let aal: Option<Aal> = response.take(0).expect("aal");
    assert_eq!(aal.map(|a| a.aal), Some(2));
}
