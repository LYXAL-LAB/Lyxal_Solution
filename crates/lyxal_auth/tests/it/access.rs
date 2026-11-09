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
    service_on(store, "auth", "test").await
}

async fn service_on(
    store: &AuthStore,
    namespace: &str,
    database: &str,
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
            namespace: namespace.into(),
            database: database.into(),
            public_url: "https://lyxal.test".into(),
            issuer: "Lyxal Test".into(),
            passkey_rp_id: None,
        },
    )
    .expect("service");
    (access, engine)
}

/// Premier administrateur par le lien d'installation.
async fn admin(access: &AccessService<StaticKeyResolver>) -> IssuedTokens {
    // Ces tests portent sur le lot 3 : le double facteur exigé de platform_admin (politique
    // installée) est levé ; il est testé dans `mfa.rs`.
    access
        .store()
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
    let outcome = access
        .complete_registration(
            &started.flow.to_sql(),
            serde_json::json!({ "name": { "first": "Ada" } }).into_value(),
            &secret("Mot-de-passe-solide-2026"),
            ClientInfo::default(),
        )
        .await
        .expect("administrateur");
    let LoginOutcome::Authenticated(tokens) = outcome else {
        panic!("session attendue");
    };
    *tokens
}

async fn sealed_message(
    store: &AuthStore,
    engine: &CryptoEngine<StaticKeyResolver>,
    event_type: &str,
) -> serde_json::Value {
    let mut response = store
        .client()
        .query("SELECT VALUE [<string> event_id, payload.secret] FROM event_outbox WHERE event_type = $type ORDER BY created_at DESC LIMIT 1")
        .bind(("type", event_type.to_string()))
        .await
        .expect("événement");
    let rows: Vec<Vec<String>> = response.take(0).expect("événement publié");
    let row = rows.first().expect("événement publié");
    let context = SecretContext::with_tenant(
        "lyxal_installation",
        "lyxal_auth",
        &event_type.replace('.', "_"),
        &row[0],
        "secret",
    )
    .expect("contexte");
    let opened = engine
        .open(
            &EncryptedEnvelope::parse(&row[1]).expect("enveloppe"),
            &context,
        )
        .expect("ouverture");
    serde_json::from_slice(opened.expose_secret()).expect("json")
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
async fn recovery_does_not_reveal_whether_the_account_exists() {
    let store = installed_store().await;
    let (access, _) = service(&store).await;
    admin(&access).await;
    // Adresse connue et adresse inconnue : même réponse, un code enregistré dans les deux cas,
    // un message publié seulement pour le compte réel
    let known = access
        .start_recovery("admin@lyxal.test", ClientInfo::default())
        .await
        .expect("récupération");
    let unknown = access
        .start_recovery("inconnu@lyxal.test", ClientInfo::default())
        .await
        .expect("récupération factice");
    assert!(known.starts_with("auth_flow:") && unknown.starts_with("auth_flow:"));
    let mut counts = store
        .client()
        .query(
            "RETURN count(SELECT id FROM auth_one_time_code WHERE address = 'inconnu@lyxal.test');
             RETURN count(SELECT id FROM event_outbox WHERE event_type = 'auth.recovery.requested');",
        )
        .await
        .expect("comptes");
    let decoys: Option<i64> = counts.take(0).expect("codes");
    let messages: Option<i64> = counts.take(1).expect("messages");
    assert_eq!((decoys, messages), (Some(1), Some(1)));
    // Deuxième demande dans la minute : même refus, que le compte existe ou non
    for email in ["admin@lyxal.test", "inconnu@lyxal.test"] {
        let again = access
            .start_recovery(email, ClientInfo::default())
            .await
            .expect_err("plafond d'envoi");
        assert_eq!(again.code(), "AUTH_TOO_MANY_ATTEMPTS", "{email}");
    }
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
    let message = sealed_message(&store, &engine, "auth.recovery.requested").await;
    let code = message["code"].as_str().expect("code").to_string();
    assert!(message["action_url"]
        .as_str()
        .expect("lien")
        .starts_with("https://lyxal.test/recovery?token="));

    // Mot de passe trop faible : refusé avant de consommer le code, qui reste utilisable
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
    // L'identifiant du parcours ne remplace pas le code
    let guessed = access
        .complete_recovery(
            CodeProof::Code {
                flow: flow.clone(),
                code: secret("000000"),
            },
            &secret("Nouveau-mot-de-passe-2026"),
        )
        .await
        .expect_err("code faux");
    assert_eq!(guessed.code(), "AUTH_CODE_INVALID");
    access
        .complete_recovery(
            CodeProof::Code {
                flow: flow.clone(),
                code: secret(&code),
            },
            &secret("Nouveau-mot-de-passe-2026"),
        )
        .await
        .expect("nouveau mot de passe");
    // Code consommé : aucune reprise, même avec le bon code
    let replay = access
        .complete_recovery(
            CodeProof::Code {
                flow,
                code: secret(&code),
            },
            &secret("Encore-un-mot-de-passe-2026"),
        )
        .await
        .expect_err("usage unique");
    assert!(
        replay.is("AUTH_CODE_INVALID") || replay.is("AUTH_FLOW_INVALID_STATE"),
        "{}",
        replay.code()
    );

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

/// Adresse à vérifier : le code s'obtient depuis le parcours de connexion (aucune session), puis
/// la connexion reprend ; les actions sont relues en base, pas figées au début du parcours.
#[tokio::test]
async fn email_verification_is_reachable_from_the_login_flow() {
    let store = installed_store().await;
    let (access, engine) = service(&store).await;
    admin(&access).await;
    store
        .client()
        .query("fn::auth_required_action_add({ identity: <string> (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = 'admin@lyxal.test' LIMIT 1), action: 'verify_email' })")
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
    assert_eq!(actions, vec!["verify_email".to_string()]);
    // Sans vérification : toujours bloqué
    let blocked = access
        .complete_login_actions(
            &flow,
            lyxal_auth::LoginActions::default(),
            ClientInfo::default(),
        )
        .await
        .expect("parcours");
    assert!(matches!(blocked, LoginOutcome::ActionRequired { .. }));

    let verification = access
        .start_login_verification(&flow, ClientInfo::default())
        .await
        .expect("code envoyé");
    let message = sealed_message(&store, &engine, "auth.verification.requested").await;
    access
        .complete_verification(CodeProof::Code {
            flow: verification,
            code: secret(message["code"].as_str().expect("code")),
        })
        .await
        .expect("adresse vérifiée");
    // Plus rien à vérifier : un nouvel envoi est refusé, la connexion reprend
    let again = access
        .start_login_verification(&flow, ClientInfo::default())
        .await
        .expect_err("déjà vérifiée");
    assert_eq!(again.code(), "AUTH_FLOW_INVALID_STATE");
    let done = access
        .complete_login_actions(
            &flow,
            lyxal_auth::LoginActions::default(),
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
    // Jeton altéré : signature refusée (premier caractère de la signature, dont les 6 bits
    // comptent toujours ; le dernier peut ne porter que des bits de remplissage)
    let token = tokens.access_token.expose_secret();
    let start = token.rfind('.').expect("signature") + 1;
    let replacement = if token[start..].starts_with('A') {
        "B"
    } else {
        "A"
    };
    let forged = format!("{}{}{}", &token[..start], replacement, &token[start + 1..]);
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

/// Serveur SurrealDB 3.3.4 réel : le jeton émis par Lyxal ouvre une connexion WebSocket ; après
/// révocation de la session, **la même connexion restée ouverte** n'a plus aucun droit.
/// `LYXAL_SURREAL_WS_URL`, `LYXAL_SURREAL_USER`, `LYXAL_SURREAL_PASS` (`scripts/ci/test_all.sh`).
#[tokio::test]
#[ignore = "nécessite un serveur SurrealDB distant (LYXAL_SURREAL_WS_URL)"]
async fn real_server_refuses_a_revoked_token_on_an_open_connection() {
    let url = std::env::var("LYXAL_SURREAL_WS_URL").expect("LYXAL_SURREAL_WS_URL");
    let user = std::env::var("LYXAL_SURREAL_USER").expect("LYXAL_SURREAL_USER");
    let pass = std::env::var("LYXAL_SURREAL_PASS").expect("LYXAL_SURREAL_PASS");
    let namespace = "auth_ws";
    let database = format!("t{}", uuid::Uuid::now_v7().simple());

    let root = surrealdb::engine::any::connect(url.as_str())
        .await
        .expect("connexion root");
    root.signin(surrealdb::opt::auth::Root {
        username: user,
        password: pass,
    })
    .await
    .expect("root");
    root.use_ns(namespace)
        .use_db(&database)
        .await
        .expect("ns/db");
    crate::support::install(&root).await;
    let store = AuthStore::new(root.clone());
    let (access, _) = service_on(&store, namespace, &database).await;
    let tokens = admin(&access).await;

    let client = surrealdb::engine::any::connect(url.as_str())
        .await
        .expect("connexion");
    client
        .use_ns(namespace)
        .use_db(&database)
        .await
        .expect("ns/db");
    client
        .authenticate(tokens.access_token.expose_secret().to_string())
        .await
        .expect("jeton accepté par le serveur");
    let mut response = client
        .query("RETURN fn::auth_context({}).data.identity")
        .await
        .expect("contexte");
    let identity: Option<lyxal_surreal::RecordId> = response.take(0).expect("identité");
    assert_eq!(identity, tokens.session.identity);

    assert!(access
        .revoke(&tokens.session.session.to_sql(), "logout")
        .await
        .expect("révocation"));
    let mut response = client
        .query("RETURN fn::auth_context({}).error.code; RETURN fn::auth_has_permission({ permission: 'auth.identity.manage' });")
        .await
        .expect("contexte après révocation");
    let code: Option<String> = response.take(0).expect("code");
    let allowed: Option<bool> = response.take(1).expect("droit");
    assert_eq!(code.as_deref(), Some("AUTH_SESSION_REVOKED"));
    assert_eq!(allowed, Some(false));

    root.query(format!("REMOVE DATABASE {database}"))
        .await
        .expect("nettoyage");
}
