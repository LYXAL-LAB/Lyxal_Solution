//! Mots de passe d'application de bout en bout sur le moteur embarqué : création (format du mot
//! de passe, une seule fois), vérification par l'hôte des protocoles (jeton accepté par l'accès
//! SurrealDB, droits du mot de passe seulement), mémoire courte, connexion non chiffrée et
//! saisie au mauvais format refusées, renouvellement après retrait d'un droit, révocation
//! effective sur la même connexion et mémoire oubliée.

use lyxal_auth::models::{ClientInfo, SessionCaller};
use lyxal_auth::{
    AccessConfig, AccessService, AppPasswordAttempt, AppPasswordTarget, AppProtocol, AuthStore,
    SigningKeyService,
};
use lyxal_crypto::{SecretString, StaticKeyResolver};
use lyxal_surreal::{RecordId, ToSql};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::support::{crypto, installed_store};

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

/// Organisation, permissions déclarées par un module du courrier, identité membre avec un rôle
/// qui les accorde, session interactive récente ; rend l'appelant.
async fn member(store: &AuthStore) -> SessionCaller {
    store
        .client()
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
            fn::auth_permission_register({ code: "mail.mailbox.access", module: "lyxal_mail", scope: "organization", app_password: true });
            fn::auth_permission_register({ code: "calendar.access", module: "lyxal_calendar", scope: "organization", app_password: true });
            fn::auth_permission_register({ code: "mail.admin", module: "lyxal_mail", scope: "organization" });
            CREATE auth_role:messagerie CONTENT { scope_key: "installation", key: "messagerie", name: "Messagerie", scope: "organization" };
            RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩;
            RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨calendar.access⟩;
            RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.admin⟩;
            fn::auth_identity_create({ traits: { email: "claire@exemple.fr" }, organization: "auth_organization:alpha" });
            LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
            LET $membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $claire LIMIT 1);
            RELATE $membership->auth_has_role->auth_role:messagerie;
            CREATE auth_session:claire CONTENT { identity: $claire, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
    let mut response = store
        .client()
        .query("SELECT VALUE identity FROM ONLY auth_session:claire")
        .await
        .expect("identité");
    let identity: Option<RecordId> = response.take(0).expect("identité");
    SessionCaller {
        session: RecordId::parse_simple("auth_session:claire").expect("session"),
        identity,
        application: None,
        organization: Some(
            RecordId::parse_simple("auth_organization:alpha").expect("organisation"),
        ),
        kind: "interactive".into(),
    }
}

fn attempt(password: &str, ip: &str, secure: bool) -> AppPasswordAttempt {
    AppPasswordAttempt {
        username: " Claire@Exemple.fr ".into(),
        password: SecretString::new(password.to_string()).expect("secret"),
        protocol: AppProtocol::Imap,
        client: ClientInfo {
            ip: Some(ip.into()),
            user_agent: None,
        },
        client_name: Some("Thunderbird".into()),
        secure,
    }
}

/// Connexion SurrealDB distincte, au nom de l'utilisateur, avec le jeton de l'hôte des protocoles.
async fn user_connection(store: &AuthStore, token: &SecretString) -> Surreal<Any> {
    let connection = store.client().clone();
    connection
        .authenticate(token.expose_secret().to_string())
        .await
        .expect("jeton accepté par l'accès SurrealDB");
    connection
}

async fn allowed(connection: &Surreal<Any>, permission: &str) -> bool {
    let mut response = connection
        .query("RETURN fn::auth_has_permission({ permission: $permission, tenant: auth_organization:alpha })")
        .bind(("permission", permission.to_string()))
        .await
        .expect("contrôle");
    let allowed: Option<bool> = response.take(0).expect("booléen");
    allowed.unwrap_or(false)
}

async fn count(store: &AuthStore, query: &str) -> i64 {
    let mut response = store.client().query(query).await.expect("comptage");
    let value: Option<i64> = response.take(0).expect("nombre");
    value.unwrap_or(0)
}

#[tokio::test]
async fn app_password_opens_a_limited_session_until_revocation() {
    let store = installed_store().await;
    let access = service(&store).await;
    let caller = member(&store).await;

    let issued = access
        .app_passwords()
        .create(
            &caller,
            "iPhone de Claire",
            vec!["mail.mailbox.access".into()],
            None,
        )
        .await
        .expect("création");
    let password = issued.password.expose_secret().to_string();
    assert_eq!(password.len(), 23);
    assert_eq!(password.split('-').count(), 4);
    assert_eq!(issued.username, "claire@exemple.fr");
    assert_eq!(issued.summary.state, "active");
    assert!(!format!("{issued:?}").contains(&password));
    // Seule l'empreinte est conservée
    assert_eq!(
        count(
            &store,
            "RETURN count(SELECT id FROM auth_app_password WHERE string::len(password_hash) = 64)"
        )
        .await,
        1
    );

    // Saisie d'un téléphone : majuscules et espaces à la place des tirets
    let typed = password.to_uppercase().replace('-', " ");
    let login = access
        .app_passwords()
        .authenticate(attempt(&typed, "203.0.113.5", true))
        .await
        .expect("connexion");
    assert_eq!(login.session.kind, "app_password");
    assert_eq!(login.session.aal, 1);
    assert_eq!(login.session.permissions, vec!["mail.mailbox.access"]);
    assert_eq!(login.app_password, issued.summary.id);
    assert_eq!(login.expires_in, 900);
    assert!(!format!("{login:?}").contains(login.access_token.expose_secret()));

    // Le jeton ouvre une connexion SurrealDB au nom de l'utilisateur, limitée au mot de passe
    let connection = user_connection(&store, &login.access_token).await;
    assert!(allowed(&connection, "mail.mailbox.access").await);
    assert!(!allowed(&connection, "mail.admin").await);
    assert!(!allowed(&connection, "auth.self.manage").await);

    // Mémoire courte : seconde vérification sans passage par la base (journal inchangé)
    let again = access
        .app_passwords()
        .authenticate(attempt(&password, "203.0.113.5", true))
        .await
        .expect("connexion gardée en mémoire");
    assert_eq!(again.session.session, login.session.session);
    assert_eq!(access.app_passwords().cached_logins().await, 1);
    assert_eq!(
        count(
            &store,
            "RETURN (SELECT VALUE count FROM ONLY auth_app_password_use LIMIT 1)"
        )
        .await,
        1
    );
    // Autre adresse : vérification réelle, même session partagée, nouvelle ligne du journal
    let elsewhere = access
        .app_passwords()
        .authenticate(attempt(&password, "198.51.100.7", true))
        .await
        .expect("connexion");
    assert_eq!(elsewhere.session.session, login.session.session);
    assert_eq!(
        count(&store, "RETURN count(SELECT id FROM auth_app_password_use)").await,
        2
    );

    // Révocation par le titulaire : mémoire oubliée, la même connexion perd ses droits
    let revoked = access
        .app_passwords()
        .revoke(&caller, AppPasswordTarget::One(issued.summary.id.to_sql()))
        .await
        .expect("révocation");
    assert_eq!(revoked, 1);
    assert_eq!(access.app_passwords().cached_logins().await, 0);
    assert!(!allowed(&connection, "mail.mailbox.access").await);
    let mut response = connection
        .query("RETURN fn::auth_context({}).error.code")
        .await
        .expect("contexte");
    let code: Option<String> = response.take(0).expect("code");
    assert_eq!(code.as_deref(), Some("AUTH_SESSION_REVOKED"));
    let refused = access
        .app_passwords()
        .authenticate(attempt(&password, "203.0.113.5", true))
        .await
        .expect_err("révoqué");
    assert_eq!(refused.code(), "AUTH_APP_PASSWORD_INVALID");
    let refused = access
        .app_passwords()
        .renew(&login)
        .await
        .expect_err("révoqué");
    assert_eq!(refused.code(), "AUTH_APP_PASSWORD_INVALID");
}

#[tokio::test]
async fn insecure_or_malformed_input_is_refused_before_any_lookup() {
    let store = installed_store().await;
    let access = service(&store).await;
    let caller = member(&store).await;
    let issued = access
        .app_passwords()
        .create(&caller, "Portable", vec!["calendar.access".into()], None)
        .await
        .expect("création");
    let password = issued.password.expose_secret().to_string();

    // Connexion non chiffrée : refusée avant tout calcul, rien n'est compté
    let insecure = access
        .app_passwords()
        .authenticate(attempt(&password, "192.0.2.1", false))
        .await
        .expect_err("non chiffrée");
    assert_eq!(insecure.code(), "AUTH_APP_PASSWORD_INSECURE_TRANSPORT");
    assert_eq!(
        count(&store, "RETURN count(SELECT id FROM auth_login_failure)").await,
        0
    );

    // Saisie au mauvais format : refus sans vérification en base (aucune session, aucun
    // journal), mais l'échec est compté pour l'adresse IP et l'identifiant
    for malformed in ["court", "0000000000000000000l", &format!("{password}x")] {
        let refused = access
            .app_passwords()
            .authenticate(attempt(malformed, "192.0.2.1", true))
            .await
            .expect_err("mauvais format");
        assert_eq!(refused.code(), "AUTH_APP_PASSWORD_INVALID");
    }
    assert_eq!(
        count(
            &store,
            "RETURN (SELECT VALUE failures FROM ONLY auth_login_failure WHERE kind = 'app_password_ip' LIMIT 1)"
        )
        .await,
        3
    );
    assert_eq!(
        count(
            &store,
            "RETURN count(SELECT id FROM auth_session WHERE kind = 'app_password')"
        )
        .await,
        0
    );
    assert_eq!(
        count(&store, "RETURN count(SELECT id FROM auth_app_password_use)").await,
        0
    );
    // Adresse IP absente : paramètre refusé
    let mut without_ip = attempt(&password, "192.0.2.1", true);
    without_ip.client.ip = None;
    let refused = access
        .app_passwords()
        .authenticate(without_ip)
        .await
        .expect_err("adresse exigée");
    assert_eq!(refused.code(), "AUTH_INVALID_PARAMETERS");
    // Une session de clé d'API ne crée pas de mot de passe d'application
    let api_key = SessionCaller {
        kind: "api_key".into(),
        ..caller.clone()
    };
    let refused = access
        .app_passwords()
        .create(&api_key, "X", vec!["calendar.access".into()], None)
        .await
        .expect_err("non interactive");
    assert_eq!(refused.code(), "AUTH_PERMISSION_DENIED");
}

#[tokio::test]
async fn renewal_reflects_a_withdrawn_right_without_the_password() {
    let store = installed_store().await;
    let access = service(&store).await;
    let caller = member(&store).await;
    let issued = access
        .app_passwords()
        .create(
            &caller,
            "Agenda",
            vec!["calendar.access".into(), "mail.mailbox.access".into()],
            None,
        )
        .await
        .expect("création");
    let login = access
        .app_passwords()
        .authenticate(attempt(
            issued.password.expose_secret(),
            "203.0.113.5",
            true,
        ))
        .await
        .expect("connexion");
    assert_eq!(
        login.session.permissions,
        vec!["calendar.access", "mail.mailbox.access"]
    );
    // Droit retiré pendant la connexion : l'ancien jeton est obsolète, le renouvellement
    // réémet un jeton aux droits réduits pour la même session
    store
        .client()
        .query("DELETE auth_role_grants WHERE in = auth_role:messagerie AND out = auth_permission:⟨calendar.access⟩")
        .await
        .expect("retrait")
        .check()
        .expect("retrait accepté");
    let stale = store
        .client()
        .clone()
        .authenticate(login.access_token.expose_secret().to_string())
        .await;
    assert!(stale.is_err(), "jeton aux droits dépassés refusé");
    let renewed = access
        .app_passwords()
        .renew(&login)
        .await
        .expect("renouvellement");
    assert_eq!(renewed.session.session, login.session.session);
    assert_eq!(renewed.session.permissions, vec!["mail.mailbox.access"]);
    let connection = user_connection(&store, &renewed.access_token).await;
    assert!(allowed(&connection, "mail.mailbox.access").await);
    assert!(!allowed(&connection, "calendar.access").await);
    // Tous les mots de passe de l'identité révoqués d'un coup par le titulaire
    let identity = caller.identity.as_ref().expect("identité").to_sql();
    let revoked = access
        .app_passwords()
        .revoke(
            &caller,
            AppPasswordTarget::Identity {
                identity,
                organization: None,
            },
        )
        .await
        .expect("révocation");
    assert_eq!(revoked, 1);
    assert_eq!(access.app_passwords().cached_logins().await, 0);
}
