//! Connexion, jetons et parcours de bout en bout sur le moteur embarqué : jeton d'accès émis
//! par Lyxal et accepté par l'accès SurrealDB `lyxal_auth_<emplacement>`, refusé après
//! révocation ; échecs et verrouillage ; renouvellement et réutilisation ; récupération par le
//! code reçu dans l'événement (secret scellé) ; compte de service.

use lyxal_auth::models::{ClientInfo, IdentityCreateParams};
use lyxal_auth::{
    AccessConfig, AccessService, AuthStore, CodeProof, IssuedTokens, LoginOutcome, LoginRequest,
    SigningKeyService,
};
use lyxal_crypto::{
    CryptoEngine, EncryptedEnvelope, SecretContext, SecretString, StaticKeyResolver,
};
use lyxal_surreal::{SurrealValue, ToSql};
use std::sync::Arc;

use crate::support::{crypto, installed_store};

#[derive(Debug, SurrealValue)]
struct Context {
    system: bool,
    identity: Option<lyxal_surreal::RecordId>,
    kind: Option<String>,
    permissions: Vec<String>,
}

fn secret(text: &str) -> SecretString {
    SecretString::new(text.to_string()).expect("secret")
}

async fn service(
    store: &AuthStore,
) -> (
    AccessService<StaticKeyResolver>,
    Arc<CryptoEngine<StaticKeyResolver>>,
) {
    let engine = crypto();
    let keys = Arc::new(SigningKeyService::new(store.clone(), engine.clone()));
    keys.ensure().await.expect("clés");
    let access = AccessService::new(
        store.clone(),
        engine.clone(),
        keys,
        AccessConfig {
            namespace: "auth".into(),
            database: "test".into(),
            public_url: "https://lyxal.test".into(),
        },
    )
    .expect("service");
    (access, engine)
}

/// Premier administrateur par le lien d'installation.
async fn admin(access: &AccessService<StaticKeyResolver>) -> IssuedTokens {
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
    access
        .complete_registration(
            &started.flow.to_sql(),
            serde_json::json!({ "name": { "first": "Ada" } }).into_value(),
            &secret("Mot-de-passe-solide-2026"),
            ClientInfo::default(),
        )
        .await
        .expect("administrateur")
}

async fn context_as(store: &AuthStore, token: &SecretString) -> Result<Context, String> {
    store
        .client()
        .authenticate(token.expose_secret().to_string())
        .await
        .map_err(|e| e.to_string())?;
    let mut response = store
        .client()
        .query("RETURN fn::auth_context({}).data")
        .await
        .map_err(|e| e.to_string())?;
    let context: Option<Context> = response.take(0).map_err(|e| e.to_string())?;
    context.ok_or_else(|| "contexte absent".to_string())
}

#[tokio::test]
async fn token_issued_by_lyxal_is_accepted_by_surrealdb() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    admin(&access).await;

    let outcome = access
        .login(LoginRequest {
            identifier: "Admin@Lyxal.test".into(),
            password: secret("Mot-de-passe-solide-2026"),
            organization: None,
            client: ClientInfo {
                ip: Some("203.0.113.9".into()),
                user_agent: Some("test".into()),
            },
        })
        .await
        .expect("connexion");
    let LoginOutcome::Authenticated(tokens) = outcome else {
        panic!("session attendue");
    };
    assert!(tokens.refresh_token.is_some());
    assert_eq!(tokens.expires_in, 900);
    assert!(!format!("{tokens:?}").contains(tokens.access_token.expose_secret()));

    let context = context_as(&store, &tokens.access_token)
        .await
        .expect("jeton accepté");
    assert!(!context.system);
    assert_eq!(context.identity, tokens.session.identity);
    assert_eq!(context.kind.as_deref(), Some("interactive"));
    assert!(context
        .permissions
        .contains(&"auth.identity.manage".to_string()));
    assert!(context
        .permissions
        .contains(&"auth.self.manage".to_string()));
}

#[tokio::test]
async fn revoked_session_token_is_refused_by_surrealdb() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    let tokens = admin(&access).await;
    assert!(access
        .revoke(&tokens.session.session.to_sql(), "logout")
        .await
        .expect("révocation"));
    let refused = context_as(&store, &tokens.access_token)
        .await
        .expect_err("session révoquée");
    assert!(refused.contains("AUTH_SESSION_REVOKED"), "{refused}");
}

#[tokio::test]
async fn wrong_passwords_are_indistinct_and_lock_the_identifier() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    admin(&access).await;
    let attempt = |identifier: &str, password: &str| LoginRequest {
        identifier: identifier.into(),
        password: secret(password),
        organization: None,
        client: ClientInfo::default(),
    };
    let wrong = access
        .login(attempt("admin@lyxal.test", "mauvais-mot-de-passe"))
        .await
        .expect_err("refus");
    let unknown = access
        .login(attempt("inconnu@lyxal.test", "mauvais-mot-de-passe"))
        .await
        .expect_err("refus");
    assert_eq!(wrong.code(), "AUTH_CREDENTIALS_INVALID");
    assert_eq!(unknown.code(), "AUTH_CREDENTIALS_INVALID");
    for _ in 0..8 {
        let _ = access
            .login(attempt("admin@lyxal.test", "mauvais-mot-de-passe"))
            .await;
    }
    // Dixième échec : verrouillé, même avec le bon mot de passe
    let locked = access
        .login(attempt("admin@lyxal.test", "mauvais-mot-de-passe"))
        .await
        .expect_err("verrou");
    assert_eq!(locked.code(), "AUTH_TOO_MANY_ATTEMPTS");
    let still = access
        .login(attempt("admin@lyxal.test", "Mot-de-passe-solide-2026"))
        .await
        .expect_err("verrou");
    assert_eq!(still.code(), "AUTH_TOO_MANY_ATTEMPTS");
}

#[tokio::test]
async fn refresh_tokens_rotate_and_reuse_revokes_the_session() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    let first = admin(&access).await;
    let refresh = first.refresh_token.expect("jeton de renouvellement");
    let second = access.refresh(&refresh).await.expect("renouvellement");
    assert_eq!(second.session.session, first.session.session);
    let reused = access.refresh(&refresh).await.expect_err("réutilisation");
    assert_eq!(reused.code(), "AUTH_REFRESH_REUSED");
    let after = access
        .refresh(second.refresh_token.as_ref().expect("jeton"))
        .await
        .expect_err("session révoquée");
    assert_eq!(after.code(), "AUTH_REFRESH_INVALID");
}

#[tokio::test]
async fn recovery_code_from_the_sealed_event_resets_the_password() {
    let store = installed_store().await;
    let (access, engine) = service(&store).await;
    let first = admin(&access).await;

    let flow = access
        .start_recovery("admin@lyxal.test", ClientInfo::default())
        .await
        .expect("récupération");
    // Le code n'est lisible que dans le secret scellé de l'événement (consommé par lyxal_notification)
    let mut response = store
        .client()
        .query("SELECT VALUE <string> event_id FROM ONLY event_outbox WHERE event_type = 'auth.recovery.requested' LIMIT 1; SELECT VALUE payload.secret FROM ONLY event_outbox WHERE event_type = 'auth.recovery.requested' LIMIT 1")
        .await
        .expect("événement");
    let event_id: Option<String> = response.take(0).expect("identifiant");
    let sealed: Option<String> = response.take(1).expect("secret");
    let published = [
        event_id.expect("événement publié"),
        sealed.expect("secret publié"),
    ];
    let context = SecretContext::with_tenant(
        "lyxal_installation",
        "lyxal_auth",
        "auth_recovery_requested",
        &published[0],
        "secret",
    )
    .expect("contexte");
    let opened = engine
        .open(
            &EncryptedEnvelope::parse(&published[1]).expect("enveloppe"),
            &context,
        )
        .expect("ouverture");
    let message: serde_json::Value = serde_json::from_slice(opened.expose_secret()).expect("json");
    let code = message["code"].as_str().expect("code").to_string();
    assert!(message["action_url"]
        .as_str()
        .expect("lien")
        .starts_with("https://lyxal.test/recovery?token="));

    // Mot de passe trop faible : refusé, le code vérifié reste acquis pour réessayer
    let weak = access
        .complete_recovery(
            CodeProof::Code {
                flow: flow.clone(),
                code: secret(&code),
            },
            &secret("court"),
        )
        .await
        .expect_err("politique");
    assert_eq!(weak.code(), "AUTH_PASSWORD_POLICY_VIOLATION");
    access
        .complete_recovery(
            CodeProof::Code {
                flow,
                code: secret("000000"),
            },
            &secret("Nouveau-mot-de-passe-2026"),
        )
        .await
        .expect("nouveau mot de passe");

    // Toutes les sessions révoquées ; l'ancien mot de passe ne sert plus
    let refused = access
        .refresh(first.refresh_token.as_ref().expect("jeton"))
        .await
        .expect_err("révoquée");
    assert_eq!(refused.code(), "AUTH_REFRESH_INVALID");
    let old = access
        .login(LoginRequest {
            identifier: "admin@lyxal.test".into(),
            password: secret("Mot-de-passe-solide-2026"),
            organization: None,
            client: ClientInfo::default(),
        })
        .await
        .expect_err("ancien mot de passe");
    assert_eq!(old.code(), "AUTH_CREDENTIALS_INVALID");
    assert!(matches!(
        access
            .login(LoginRequest {
                identifier: "admin@lyxal.test".into(),
                password: secret("Nouveau-mot-de-passe-2026"),
                organization: None,
                client: ClientInfo::default()
            })
            .await
            .expect("nouveau mot de passe"),
        LoginOutcome::Authenticated(_)
    ));
    // Aucune trace du code en clair dans la base
    let mut response = store
        .client()
        .query("RETURN (SELECT * FROM auth_one_time_code)")
        .await
        .expect("codes");
    let codes: Vec<serde_json::Value> = response.take(0).expect("lecture");
    assert!(!serde_json::Value::Array(codes).to_string().contains(&code));
}

#[tokio::test]
async fn required_password_change_happens_before_any_session() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    admin(&access).await;
    store
        .client()
        .query("fn::auth_required_action_add({ identity: <string> (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1), action: 'update_password' })")
        .await
        .expect("action imposée");
    let outcome = access
        .login(LoginRequest {
            identifier: "admin@lyxal.test".into(),
            password: secret("Mot-de-passe-solide-2026"),
            organization: None,
            client: ClientInfo::default(),
        })
        .await
        .expect("connexion");
    let LoginOutcome::ActionRequired { flow, actions } = outcome else {
        panic!("action requise attendue");
    };
    assert_eq!(actions, vec!["update_password".to_string()]);
    let reused = access
        .complete_login_actions(
            &flow,
            lyxal_auth::LoginActions {
                new_password: Some(secret("Mot-de-passe-solide-2026")),
                accept_terms: false,
            },
            ClientInfo::default(),
        )
        .await
        .expect_err("historique");
    assert_eq!(reused.code(), "AUTH_PASSWORD_REUSED");
    let done = access
        .complete_login_actions(
            &flow,
            lyxal_auth::LoginActions {
                new_password: Some(secret("Autre-mot-de-passe-2026")),
                accept_terms: false,
            },
            ClientInfo::default(),
        )
        .await
        .expect("session");
    assert!(matches!(done, LoginOutcome::Authenticated(_)));
}

#[tokio::test]
async fn service_account_obtains_a_token_with_its_roles() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    // Application machine de l'installation avec un rôle de lecture des identités
    let mut response = store
        .client()
        .query(
            "RETURN fn::auth_application_create({ name: 'Synchronisation', type: 'machine' }).data",
        )
        .await
        .expect("application");
    let application: Option<serde_json::Value> = response.take(0).expect("lecture");
    let application = application.expect("application");
    let client_id = application["client_id"]
        .as_str()
        .expect("client_id")
        .to_string();
    let id = application["id"].as_str().expect("id").to_string();
    let client_secret = lyxal_auth::services::opaque_token("lyxs_").expect("secret");
    store
        .application_secret_add(lyxal_auth::models::ApplicationSecretAddParams {
            application: id.clone(),
            secret_hash: client_secret.hash.clone(),
            prefix: client_secret.prefix.clone(),
            expires_at: None,
        })
        .await
        .expect("secret");
    store
        .client()
        .query(format!(
            "CREATE auth_role:lecteur CONTENT {{ scope_key: 'installation', key: 'lecteur', name: 'Lecteur', scope: 'installation', kind: 'service' }};
             RELATE auth_role:lecteur->auth_role_grants->auth_permission:⟨auth.identity.read⟩;
             LET $app = type::record('{id}'); RELATE $app->auth_has_role->auth_role:lecteur;"
        ))
        .await
        .and_then(|r| r.check())
        .expect("rôle");

    let wrong = access
        .service_token(&client_id, &secret("lyxs_faux"), ClientInfo::default())
        .await
        .expect_err("secret faux");
    assert_eq!(wrong.code(), "AUTH_CLIENT_CREDENTIALS_INVALID");
    let tokens = access
        .service_token(&client_id, &client_secret.value, ClientInfo::default())
        .await
        .expect("jeton");
    assert!(tokens.refresh_token.is_none());
    let context = context_as(&store, &tokens.access_token)
        .await
        .expect("jeton accepté");
    assert_eq!(context.kind.as_deref(), Some("service"));
    assert_eq!(context.permissions, vec!["auth.identity.read".to_string()]);
    assert!(context.identity.is_none());
}

#[tokio::test]
async fn identity_created_by_an_admin_is_unaffected() {
    // Les identités du lot 2 (créées sans mot de passe) ne se connectent pas : réponse indistincte
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    store
        .identity_create(IdentityCreateParams {
            schema_key: None,
            traits: serde_json::json!({ "email": "sans-mdp@lyxal.test" }).into_value(),
            external_id: None,
            organization: None,
            roles: vec![],
        })
        .await
        .expect("identité");
    let refused = access
        .login(LoginRequest {
            identifier: "sans-mdp@lyxal.test".into(),
            password: secret("Peu-importe-2026"),
            organization: None,
            client: ClientInfo::default(),
        })
        .await
        .expect_err("sans mot de passe");
    assert_eq!(refused.code(), "AUTH_CREDENTIALS_INVALID");
}

#[tokio::test]
async fn host_authenticates_a_bearer_token_until_revocation() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    let tokens = admin(&access).await;
    let caller = access
        .authenticate(&tokens.access_token)
        .await
        .expect("appelant");
    assert_eq!(caller.session, tokens.session.session);
    assert_eq!(caller.kind, "interactive");
    // Jeton altéré : signature refusée
    let mut forged = tokens.access_token.expose_secret().to_string();
    forged.pop();
    forged.push(if forged.ends_with('A') { 'B' } else { 'A' });
    assert!(access.authenticate(&secret(&forged)).await.is_err());
    access
        .revoke(&tokens.session.session.to_sql(), "logout")
        .await
        .expect("révocation");
    let refused = access
        .authenticate(&tokens.access_token)
        .await
        .expect_err("révoquée");
    assert_eq!(refused.code(), "AUTH_SESSION_REVOKED");
}
