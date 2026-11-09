//! Parcours de bout en bout : événement `auth.*` → déclenchement → worker → serveur SMTP de test.

use base64::Engine;
use lyxal_auth::models::OrganizationCreateParams;
use lyxal_auth::{AuthStore, InvitationRequest, InvitationService};
use lyxal_crypto::{CryptoEngine, SecretBytes, StaticKeyResolver};
use lyxal_notification::consumer::AuthMessagePayload;
use lyxal_notification::models::FailureClass;
use lyxal_notification::secret::event_context;
use lyxal_notification::{
    AuthMessageHandler, EmailWorkerSettings, InvitationCreated, JobOutcome,
    NotificationEmailWorker, NotificationStore, SecretCodec, SmtpSecurity, SmtpSettings,
    SmtpTransport, VerificationRequested,
};
use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::{SurrealValue, ToSql};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::smtp_server::TestSmtpServer;
use crate::support::{crypto, installed_client};

#[derive(Debug, PartialEq, SurrealValue)]
struct Suppressed {
    address: String,
    reason: String,
    source: Option<String>,
}

#[derive(Debug, SurrealValue)]
struct Published {
    event_id: String,
    payload: serde_json::Value,
}

fn worker(
    client: &Surreal<Any>,
    engine: &Arc<CryptoEngine<StaticKeyResolver>>,
    server: &TestSmtpServer,
) -> NotificationEmailWorker<StaticKeyResolver> {
    let transport = SmtpTransport::new(SmtpSettings {
        host: "127.0.0.1".to_string(),
        port: server.port,
        security: SmtpSecurity::LocalPlain,
        username: None,
        password: None,
        from_address: "noreply@lyxal.test".to_string(),
        from_name: Some("Lyxal".to_string()),
        timeout: Duration::from_secs(5),
    })
    .expect("transport");
    NotificationEmailWorker::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(engine.clone()),
        Arc::new(transport),
        EmailWorkerSettings::default(),
    )
    .expect("worker")
}

/// Corps décodé d'un message MIME simple (parties en quoted-printable ou Base64).
fn decoded(data: &str) -> String {
    let mut out = String::new();
    for part in data.split("\n--") {
        let Some((headers, body)) = part.split_once("\n\n") else {
            out.push_str(part);
            continue;
        };
        let lower = headers.to_ascii_lowercase();
        if lower.contains("content-transfer-encoding: base64") {
            let compact: String = body
                .split_whitespace()
                .take_while(|l| !l.starts_with("--"))
                .collect();
            if let Ok(bytes) = base64::engine::general_purpose::STANDARD.decode(compact) {
                out.push_str(&String::from_utf8_lossy(&bytes));
            }
        } else if lower.contains("content-transfer-encoding: quoted-printable") {
            let joined = body.replace("=\n", "");
            let mut bytes = Vec::new();
            let raw = joined.as_bytes();
            let mut i = 0;
            while i < raw.len() {
                if raw[i] == b'=' && i + 2 < raw.len() {
                    if let Ok(byte) = u8::from_str_radix(&joined[i + 1..i + 3], 16) {
                        bytes.push(byte);
                        i += 3;
                        continue;
                    }
                }
                bytes.push(raw[i]);
                i += 1;
            }
            out.push_str(&String::from_utf8_lossy(&bytes));
        } else {
            out.push_str(body);
        }
        out.push('\n');
    }
    out
}

async fn dump(client: &Surreal<Any>) -> String {
    let mut response = client
        .query("RETURN [(SELECT * FROM notification_run), (SELECT * FROM notification_job), (SELECT * FROM notification_message), (SELECT * FROM notification_delivery_log), (SELECT * FROM event_outbox)]")
        .await
        .expect("lecture");
    let all: Vec<serde_json::Value> = response.take(0).expect("valeur");
    serde_json::Value::Array(all).to_string()
}

#[tokio::test]
async fn invitation_from_auth_is_delivered_once_and_leaves_no_secret() {
    let client = installed_client().await;
    let engine = crypto();
    let auth = AuthStore::new(client.clone());
    let organization = auth
        .organization_create(OrganizationCreateParams {
            locale: None,
            branding: None,
            custom_data: None,
            slug: "alpha".into(),
            name: "Alpha BTP".into(),
            description: None,
            mfa_required: None,
            owner: None,
        })
        .await
        .expect("organisation");
    InvitationService::new(
        auth,
        engine.clone(),
        "https://lyxal.test/invitations/accept",
    )
    .expect("service")
    .invite(InvitationRequest {
        organization: organization.id.to_sql(),
        email: "claire@exemple.fr".into(),
        roles: vec![],
        expires_at: None,
    })
    .await
    .expect("invitation");

    // Événement tel que publié par lyxal_auth (charge utile JSON, comme la livre lyxal_event)
    let mut response = client
        .query("SELECT <string> event_id AS event_id, payload FROM ONLY event_outbox WHERE event_type = 'auth.invitation.created' LIMIT 1")
        .await
        .expect("outbox");
    let published: Option<Published> = response.take(0).expect("événement");
    let published = published.expect("événement publié");
    let event: InvitationCreated =
        serde_json::from_value(published.payload.clone()).expect("contrat auth.invitation.created");
    assert_eq!(event.organization_name, "Alpha BTP");

    let handler = AuthMessageHandler::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(engine.clone()),
    );
    handler
        .deliver(&event, &published.event_id)
        .await
        .expect("déclenchement");
    // Livraison au moins une fois : le rejeu ne crée rien de plus
    handler
        .deliver(&event, &published.event_id)
        .await
        .expect("rejeu");
    let mut response = client
        .query("SELECT VALUE secret FROM notification_run")
        .await
        .expect("déclenchements");
    let secrets: Vec<Option<String>> = response.take(0).expect("secrets");
    assert_eq!(secrets.len(), 1, "un seul déclenchement");
    let queued = secrets[0].clone().expect("secret en file");
    assert!(queued.starts_with("enc:v2:"));
    assert_ne!(
        Some(queued.as_str()),
        published.payload["secret"].as_str(),
        "secret rescellé pour la file"
    );

    let server = TestSmtpServer::start().await;
    let outcomes = worker(&client, &engine, &server)
        .run_once(&CancellationToken::new())
        .await
        .expect("envoi");
    assert_eq!(outcomes, vec![JobOutcome::Sent]);

    let received = server.received();
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].rcpt, "claire@exemple.fr");
    let body = decoded(&received[0].data);
    let start = body
        .find("https://lyxal.test/invitations/accept#token=")
        .expect("lien d'acceptation");
    let link: String = body[start..]
        .chars()
        .take_while(|c| !c.is_whitespace() && *c != '"' && *c != '<')
        .collect();
    let token = link.rsplit('=').next().expect("jeton").to_string();
    assert_eq!(token.len(), 43, "jeton complet");
    assert!(body.contains("Alpha BTP"));

    // Aucune trace du jeton ni du lien en clair dans la base ; secret effacé après l'envoi
    let stored = dump(&client).await;
    assert!(!stored.contains(&token), "jeton absent de la base");
    let mut response = client
        .query("SELECT VALUE status FROM ONLY notification_run LIMIT 1; SELECT VALUE secret FROM ONLY notification_run LIMIT 1")
        .await
        .expect("déclenchement");
    let status: Option<String> = response.take(0).expect("état");
    let secret: Option<String> = response.take(1).expect("secret");
    assert_eq!((status.as_deref(), secret), (Some("completed"), None));
    // Parcours sensible : aucun objet conservé
    let mut response = client
        .query("SELECT VALUE subject FROM ONLY notification_message LIMIT 1")
        .await
        .expect("message");
    let subject: Option<String> = response.take(0).expect("objet");
    assert_eq!(subject, None);
}

fn verification(
    engine: &CryptoEngine<StaticKeyResolver>,
    email: &str,
    event_id: &str,
    signed_for: &str,
) -> VerificationRequested {
    let context = event_context(
        None,
        "lyxal_auth",
        "auth.verification.requested",
        signed_for,
    )
    .expect("contexte");
    let secret = engine
        .seal(
            &SecretBytes::new(
                br#"{"action_url":"https://lyxal.test/verify?t=abc","code":"482913"}"#.to_vec(),
            )
            .expect("secret"),
            &context,
        )
        .expect("scellement")
        .encode();
    let _ = event_id;
    VerificationRequested {
        message: AuthMessagePayload {
            tenant: None,
            identity_id: Some("auth_identity:x".to_string()),
            recipient_email: email.to_string(),
            recipient_locale: Some("en".to_string()),
            recipient_name: None,
            expires_at: "2099-01-01T00:00:00Z".to_string(),
            secret,
        },
    }
}

#[tokio::test]
async fn envelope_sealed_for_another_event_is_refused() {
    let client = installed_client().await;
    let engine = crypto();
    let handler = AuthMessageHandler::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(engine.clone()),
    );
    let event_id = uuid::Uuid::now_v7().to_string();
    let other = uuid::Uuid::now_v7().to_string();
    let event = verification(&engine, "a@exemple.fr", &event_id, &other);
    let error = handler
        .deliver(&event, &event_id)
        .await
        .expect_err("enveloppe d'un autre événement");
    assert_eq!(error.code(), "NOTIFICATION_SECRET_UNAVAILABLE");
    assert!(!error.is_retryable(), "lettre morte");
    let mut response = client
        .query("RETURN array::len(SELECT * FROM notification_run)")
        .await
        .expect("lecture");
    let runs: Option<i64> = response.take(0).expect("nombre");
    assert_eq!(runs, Some(0));
}

#[tokio::test]
async fn transient_failure_is_retried_and_rejected_recipient_is_suppressed() {
    let client = installed_client().await;
    let engine = crypto();
    let handler = AuthMessageHandler::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(engine.clone()),
    );
    for email in ["lent@exemple.fr", "absent@exemple.fr"] {
        let event_id = uuid::Uuid::now_v7().to_string();
        handler
            .deliver(
                &verification(&engine, email, &event_id, &event_id),
                &event_id,
            )
            .await
            .expect("déclenchement");
    }
    let server = TestSmtpServer::start().await;
    server.script("lent@exemple.fr", vec!["451 4.3.0 réessayez plus tard"]);
    server.script("absent@exemple.fr", vec!["550 5.1.1 utilisateur inconnu"]);
    let worker = worker(&client, &engine, &server);

    let mut outcomes = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("premier tour");
    outcomes.sort_by_key(|o| format!("{o:?}"));
    assert_eq!(
        outcomes,
        vec![
            JobOutcome::Failed(FailureClass::RecipientRejected),
            JobOutcome::Failed(FailureClass::Transient)
        ]
    );
    assert!(server.received().is_empty());

    // Nouvelle tentative avancée à maintenant : envoyée
    client
        .query("UPDATE notification_job SET next_retry_at = time::now() WHERE status = 'queued'")
        .await
        .expect("avance");
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("second tour"),
        vec![JobOutcome::Sent]
    );
    let received = server.received();
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].rcpt, "lent@exemple.fr");
    assert!(
        decoded(&received[0].data).contains("482913"),
        "code de vérification envoyé"
    );

    let mut response = client
        .query("SELECT address, reason, source FROM notification_suppression")
        .await
        .expect("suppressions");
    let suppressed: Vec<Suppressed> = response.take(0).expect("liste");
    assert_eq!(
        suppressed,
        vec![Suppressed {
            address: "absent@exemple.fr".into(),
            reason: "hard_bounce".into(),
            source: Some("550".into())
        }]
    );
}

#[tokio::test]
async fn shutdown_releases_reserved_jobs_without_sending() {
    let client = installed_client().await;
    let engine = crypto();
    let handler = AuthMessageHandler::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(engine.clone()),
    );
    let event_id = uuid::Uuid::now_v7().to_string();
    handler
        .deliver(
            &verification(&engine, "arret@exemple.fr", &event_id, &event_id),
            &event_id,
        )
        .await
        .expect("déclenchement");
    let server = TestSmtpServer::start().await;
    let worker = worker(&client, &engine, &server);

    let cancelled = CancellationToken::new();
    cancelled.cancel();
    assert_eq!(
        worker.run_once(&cancelled).await.expect("tour annulé"),
        vec![JobOutcome::Released]
    );
    assert!(
        server.received().is_empty(),
        "aucun envoi après l'annulation"
    );
    let mut response = client
        .query("SELECT VALUE attempts FROM ONLY notification_job LIMIT 1")
        .await
        .expect("étape");
    let attempts: Option<i64> = response.take(0).expect("tentatives");
    assert_eq!(attempts, Some(0), "aucune tentative comptée");

    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("reprise"),
        vec![JobOutcome::Sent]
    );
}

/// Alerte de sécurité de bout en bout : événement publié par `lyxal_auth` (contrat de la charge
/// utile), déclenchement idempotent, e-mail envoyé ; aucune alerte pour le premier mot de passe.
#[tokio::test]
async fn security_alert_from_auth_is_delivered_once() {
    use lyxal_notification::{MfaEnrolled, PasswordChanged, SecurityAlertHandler};

    let client = installed_client().await;
    let engine = crypto();
    client
        .query("CREATE auth_identity:alerte CONTENT { schema: auth_identity_schema:default_v1, traits: { email: 'alerte@exemple.fr', name: { first: 'Inès' } } }; RETURN fn::auth_mfa_publish({ event_type: 'auth.mfa.enrolled', identity: auth_identity:alerte, data: { method: 'passkey', label: 'Téléphone' } });")
        .await
        .expect("événement publié")
        .check()
        .expect("publication");
    let mut response = client
        .query("SELECT <string> event_id AS event_id, payload FROM ONLY event_outbox WHERE event_type = 'auth.mfa.enrolled' LIMIT 1")
        .await
        .expect("événement");
    let published: Option<Published> = response.take(0).expect("lecture");
    let published = published.expect("événement présent");
    let event: MfaEnrolled =
        serde_json::from_value(published.payload).expect("contrat de la charge utile");
    let handler = SecurityAlertHandler::new(NotificationStore::new(client.clone()));
    handler
        .deliver(&event, &published.event_id)
        .await
        .expect("déclenchement");
    // Livraison au moins une fois : un second passage ne crée rien
    handler
        .deliver(&event, &published.event_id)
        .await
        .expect("rejeu");
    // Premier mot de passe (création du compte) : aucune alerte
    let first: PasswordChanged = serde_json::from_value(serde_json::json!({
        "identity_id": "auth_identity:alerte", "recipient_email": "alerte@exemple.fr", "first": true
    }))
    .expect("événement");
    handler
        .deliver(&first, &uuid::Uuid::now_v7().to_string())
        .await
        .expect("ignoré");

    let server = TestSmtpServer::start().await;
    let worker = worker(&client, &engine, &server);
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("envoi"),
        vec![JobOutcome::Sent]
    );
    let received = server.received();
    assert_eq!(received.len(), 1);
    assert_eq!(received[0].rcpt, "alerte@exemple.fr");
    let body = decoded(&received[0].data);
    assert!(body.contains("Inès"), "{body}");
    assert!(body.contains("passkey « Téléphone »"), "{body}");
}
