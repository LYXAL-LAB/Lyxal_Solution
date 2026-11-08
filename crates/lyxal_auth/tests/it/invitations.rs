//! Service d'invitation : seule l'empreinte du jeton est enregistrée ; le lien scellé est publié
//! dans `auth.invitation.created` avec l'identifiant d'événement de son contexte, et ne s'ouvre
//! qu'avec ce contexte.

use lyxal_auth::models::OrganizationCreateParams;
use lyxal_auth::{invitation_seal_context, InvitationRequest, InvitationService};
use lyxal_crypto::{blake3_hex, EncryptedEnvelope, SecretString};
use lyxal_surreal::{SurrealValue, ToSql};

use crate::support::{crypto, installed_store};

#[derive(Debug, SurrealValue)]
struct PublishedInvitation {
    event_id: String,
    secret: String,
    tenant: String,
}

#[tokio::test]
async fn invitation_link_is_sealed_published_and_never_stored() {
    let store = installed_store().await;
    let organization = store
        .organization_create(OrganizationCreateParams {
            slug: "alpha".into(),
            name: "Alpha".into(),
            description: None,
            mfa_required: None,
            owner: None,
        })
        .await
        .expect("organisation");
    let organization_id = organization.id.to_sql();
    let engine = crypto();
    let service = InvitationService::new(
        store.clone(),
        engine.clone(),
        "https://lyxal.test/invitations/accept",
    )
    .expect("service");

    let invitation = service
        .invite(InvitationRequest {
            organization: organization_id,
            email: "Claire@Exemple.fr".into(),
            roles: vec![],
            expires_at: None,
        })
        .await
        .expect("invitation");
    assert_eq!(invitation.email, "claire@exemple.fr");

    // L'événement porte le lien scellé ; il s'ouvre avec le contexte de son event_id
    let mut response = store
        .client()
        .query("SELECT event_id, payload.secret AS secret, payload.tenant AS tenant FROM ONLY event_outbox WHERE event_type = 'auth.invitation.created' LIMIT 1")
        .await
        .expect("outbox");
    let published: Option<PublishedInvitation> = response.take(0).expect("événement");
    let published = published.expect("événement publié");
    let envelope = EncryptedEnvelope::parse(&published.secret).expect("enveloppe");
    let opened = engine
        .open(
            &envelope,
            &invitation_seal_context(&published.tenant, &published.event_id).expect("contexte"),
        )
        .expect("ouverture");
    let link: serde_json::Value = serde_json::from_slice(opened.expose_secret()).expect("JSON");
    let url = link["action_url"].as_str().expect("action_url");
    let token = url
        .strip_prefix("https://lyxal.test/invitations/accept?token=")
        .expect("préfixe")
        .to_string();
    assert_eq!(token.len(), 43, "32 octets en Base64 URL sans remplissage");

    // Un autre identifiant d'événement ne l'ouvre pas
    let other = invitation_seal_context(&published.tenant, "01a1bca0-0000-7000-8000-000000000000")
        .expect("contexte");
    assert!(engine.open(&envelope, &other).is_err());

    // La base ne connaît que l'empreinte ; ni le jeton ni le lien ne sont enregistrés
    let mut stored = store
        .client()
        .query("SELECT VALUE token_hash FROM ONLY auth_organization_invitation LIMIT 1; SELECT VALUE delivery FROM ONLY auth_organization_invitation LIMIT 1;")
        .await
        .expect("invitation");
    let hash: Option<String> = stored.take(0).expect("empreinte");
    assert_eq!(hash.as_deref(), Some(blake3_hex(token.as_bytes()).as_str()));
    let delivery: Option<serde_json::Value> = stored.take(1).expect("champ transitoire");
    assert!(delivery.is_none() || delivery == Some(serde_json::Value::Null));

    // La session système n'accepte pas d'invitation (identité requise)
    let refused = service
        .accept(&SecretString::new(token).expect("jeton"))
        .await;
    assert_eq!(
        refused.expect_err("identité requise").code(),
        "AUTH_SESSION_REQUIRED"
    );
}

#[tokio::test]
async fn accept_url_is_validated() {
    let store = installed_store().await;
    for url in [
        "ftp://x",
        "https://x?y=1",
        "https://x/#a",
        "https://x y",
        "https://x\"y",
    ] {
        assert!(
            InvitationService::new(store.clone(), crypto(), url).is_err(),
            "{url}"
        );
    }
}

#[tokio::test]
async fn invalid_organization_is_refused_before_sealing() {
    let store = installed_store().await;
    let service =
        InvitationService::new(store, crypto(), "https://lyxal.test/accept").expect("service");
    let error = service
        .invite(InvitationRequest {
            organization: "autre_table:x".into(),
            email: "a@b.fr".into(),
            roles: vec![],
            expires_at: None,
        })
        .await
        .expect_err("organisation invalide");
    assert_eq!(error.code(), "AUTH_INVALID_PARAMETERS");
}
