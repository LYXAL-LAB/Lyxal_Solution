//! Intégrations de bout en bout sur la base embarquée, le coffre-fort `lyxal_secrets` et des
//! faux fournisseurs locaux : déclenchement → intégration de l'organisation → faux fournisseur →
//! retour « rejeté » vérifié → adresse supprimée ; bascule vers la seconde intégration après une
//! panne, retour à la principale au message suivant, refus définitif sans bascule ; retours
//! Mailgun et Resend (signature valide, fausse, horodatage trop ancien, rejeu dédoublonné) ;
//! identifiants lus du coffre-fort, jamais en base ni dans un `Debug`.

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    sign_external_hmac_sha256, sign_hmac_sha256, ExternalHmacKey, HmacKey, SecretBytes,
};
use lyxal_notification::models::{FailureClass, IntegrationSaveParams, IntegrationSettings};
use lyxal_notification::{
    JobOutcome, NotificationEmailWorker, NotificationStore, ProviderEventKind, SecretCodec,
    SendWorkerSettings, WebhookError, WebhookRequest,
};
use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::ToSql;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::fake_provider::{FakeProviders, Reply};
use crate::support::{
    claimed, crypto, dispatcher, installed_client, integration, put_secret, vault,
};

/// Heure du serveur en secondes Unix.
fn now() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .expect("horloge")
}

/// Organisation Alpha, parcours `devis` et son gabarit.
async fn alpha(client: &Surreal<Any>) {
    client
        .query(
            r#"
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", steps: [{ key: "email", type: "email" }] };
            CREATE notification_template:devis_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email", subject: "Devis {{ payload.n }}", html_body: "<p>Devis {{ payload.n }}</p>", text_body: "Devis {{ payload.n }}" };
            "#,
        )
        .await
        .expect("préparation")
        .check()
        .expect("préparation acceptée");
}

async fn trigger(client: &Surreal<Any>, key: &str, email: &str) {
    client
        .query("RETURN fn::notification_trigger({ tenant: 'auth_organization:alpha', workflow_key: 'devis', idempotency_key: $key, to: { subscriber_id: $email, email: $email }, payload: { n: $key } }).ok")
        .bind(("key", key.to_string()))
        .bind(("email", email.to_string()))
        .await
        .expect("déclenchement")
        .check()
        .expect("déclenchement accepté");
}

fn settings(from: &str) -> IntegrationSettings {
    IntegrationSettings {
        from_address: Some(from.into()),
        from_name: Some("Alpha BTP".into()),
        ..IntegrationSettings::default()
    }
}

fn org_integration(key: &str, provider: &str, priority: i64) -> IntegrationSaveParams {
    IntegrationSaveParams {
        tenant: Some("auth_organization:alpha".into()),
        key: key.into(),
        provider: Some(provider.into()),
        name: Some(key.into()),
        priority: Some(priority),
        settings: Some(settings("devis@alpha.test")),
        credentials_path: Some(format!("notification/{key}/api")),
        ..IntegrationSaveParams::default()
    }
}

async fn dump(client: &Surreal<Any>) -> String {
    let mut response = client
        .query("RETURN [(SELECT * FROM notification_integration), (SELECT * FROM notification_job), (SELECT * FROM notification_message), (SELECT * FROM notification_delivery_log), (SELECT * FROM notification_provider_event), (SELECT * FROM event_outbox)]")
        .await
        .expect("lecture");
    let all: Vec<serde_json::Value> = response.take(0).expect("valeur");
    serde_json::Value::Array(all).to_string()
}

/// Requête Svix d'un retour Resend.
fn svix<'a>(timestamp: &'a str, signature: &'a str, body: &'a str) -> WebhookRequest<'a> {
    WebhookRequest {
        svix_id: Some("msg_1"),
        svix_timestamp: Some(timestamp),
        svix_signature: Some(signature),
        body: body.as_bytes(),
        ..Default::default()
    }
}

async fn rows(client: &Surreal<Any>, query: &str) -> Vec<serde_json::Value> {
    let mut response = client.query(query).await.expect("requête");
    response.take(0).expect("lignes")
}

#[tokio::test]
async fn organization_integration_then_bounce_webhook_suppresses_the_address() {
    let client = installed_client().await;
    let vault = vault(&client);
    let fake = FakeProviders::start().await;
    alpha(&client).await;
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/postmark/api",
        r#"{"api_key":"pm-token-tres-secret"}"#,
    )
    .await;
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/postmark/webhook",
        r#"{"username":"lyxal","password":"retour-tres-secret"}"#,
    )
    .await;
    let created = integration(
        &client,
        IntegrationSaveParams {
            primary: Some(true),
            webhook_path: Some("notification/postmark/webhook".into()),
            ..org_integration("postmark", "postmark", 100)
        },
    )
    .await;
    trigger(&client, "d-1", "client@exemple.fr").await;

    let dispatcher = dispatcher(&vault, Some(&fake.base));
    let worker = NotificationEmailWorker::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(crypto()),
        dispatcher.clone(),
        SendWorkerSettings::default(),
    )
    .expect("worker");
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("envoi"),
        vec![JobOutcome::Sent]
    );
    let sent = &fake.requests_to("postmark")[0];
    assert_eq!(
        sent.header("x-postmark-server-token"),
        Some("pm-token-tres-secret")
    );
    assert_eq!(sent.json()["To"], "client@exemple.fr");
    assert_eq!(sent.json()["Subject"], "Devis d-1");
    let messages = rows(&client, "SELECT VALUE [provider, provider_message_id, status, <string> integration] FROM notification_message").await;
    assert_eq!(
        messages,
        vec![serde_json::json!([
            "postmark",
            "pm-1",
            "sent",
            created.id.to_sql()
        ])]
    );

    // Retour « rejet définitif » de Postmark, identifiants Basic du webhook lus dans le coffre-fort
    let body = serde_json::json!({ "RecordType": "Bounce", "Type": "HardBounce", "ID": 4242, "MessageID": "pm-1", "Email": "client@exemple.fr", "BouncedAt": "2026-11-16T10:00:00Z" }).to_string();
    let good = format!("Basic {}", STANDARD.encode("lyxal:retour-tres-secret"));
    let bad = format!("Basic {}", STANDARD.encode("lyxal:retour-faux"));
    let target = claimed(&client, "postmark").await;
    let store = NotificationStore::new(client.clone());
    let refused = dispatcher
        .verify_webhook(
            &target,
            &WebhookRequest {
                authorization: Some(&bad),
                body: body.as_bytes(),
                ..Default::default()
            },
            now(),
        )
        .await;
    assert_eq!(refused, Err(WebhookError::Unauthorized));
    for expected in ["recorded", "duplicate"] {
        // Le fournisseur rejoue le même retour : dédoublonné
        let events = dispatcher
            .verify_webhook(
                &target,
                &WebhookRequest {
                    authorization: Some(&good),
                    body: body.as_bytes(),
                    ..Default::default()
                },
                now(),
            )
            .await
            .expect("retour vérifié");
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ProviderEventKind::Bounced);
        let recorded = store
            .provider_event_record(events[0].record_params(target.id.to_sql()))
            .await
            .expect("retour enregistré");
        assert_eq!(recorded.status, expected);
    }
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE [address, reason, scope_key] FROM notification_suppression"
        )
        .await,
        vec![serde_json::json!([
            "client@exemple.fr",
            "hard_bounce",
            "alpha"
        ])]
    );
    assert_eq!(
        rows(&client, "SELECT VALUE status FROM notification_message").await,
        vec![serde_json::json!("bounced")]
    );
    // L'adresse supprimée n'est plus contactée
    trigger(&client, "d-2", "client@exemple.fr").await;
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE skip_reason FROM notification_run WHERE idempotency_key = 'd-2'"
        )
        .await,
        vec![serde_json::json!("suppressed:hard_bounce")]
    );

    // Aucun identifiant en base ni dans un Debug
    let stored = dump(&client).await;
    for secret in ["pm-token-tres-secret", "retour-tres-secret"] {
        assert!(!stored.contains(secret), "{secret} en base");
        assert!(!format!("{dispatcher:?}{target:?}").contains(secret));
    }
}

#[tokio::test]
async fn a_failing_provider_fails_over_to_the_next_integration() {
    let client = installed_client().await;
    let vault = vault(&client);
    let fake = FakeProviders::start().await;
    alpha(&client).await;
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/brevo/api",
        r#"{"api_key":"xkeysib-1"}"#,
    )
    .await;
    put_secret(
        &client,
        &vault,
        Some("auth_organization:alpha"),
        "notification/resend/api",
        r#"{"api_key":"re_1"}"#,
    )
    .await;
    integration(
        &client,
        IntegrationSaveParams {
            primary: Some(true),
            ..org_integration("brevo", "brevo", 100)
        },
    )
    .await;
    integration(&client, org_integration("resend", "resend", 10)).await;
    let worker = NotificationEmailWorker::new(
        NotificationStore::new(client.clone()),
        SecretCodec::new(crypto()),
        dispatcher(&vault, Some(&fake.base)),
        SendWorkerSettings::default(),
    )
    .expect("worker");
    let due_now = || async {
        client
            .query(
                "UPDATE notification_job SET next_retry_at = time::now() WHERE status = 'queued'",
            )
            .await
            .expect("échéance")
            .check()
            .expect("échéance acceptée");
    };

    // Panne de la principale (503) : échec temporaire, la tentative suivante passe à Resend
    fake.script("brevo", vec![Reply::status(503)]);
    trigger(&client, "panne", "a@exemple.fr").await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("premier tour"),
        vec![JobOutcome::Failed(FailureClass::Transient)]
    );
    due_now().await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("second tour"),
        vec![JobOutcome::Sent]
    );
    assert_eq!(
        (
            fake.requests_to("brevo").len(),
            fake.requests_to("resend").len()
        ),
        (1, 1)
    );
    assert_eq!(
        rows(
            &client,
            "SELECT VALUE [integration.key, provider_message_id] FROM notification_message"
        )
        .await,
        vec![serde_json::json!(["resend", "re-1"])]
    );

    // Message suivant : de nouveau la principale
    trigger(&client, "suivant", "b@exemple.fr").await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("message suivant"),
        vec![JobOutcome::Sent]
    );
    assert_eq!(
        (
            fake.requests_to("brevo").len(),
            fake.requests_to("resend").len()
        ),
        (2, 1)
    );

    // Refus définitif (422) : aucune bascule, étape en échec
    fake.script(
        "brevo",
        vec![Reply::json(
            422,
            serde_json::json!({ "code": "invalid_parameter" }),
        )],
    );
    trigger(&client, "refus", "c@exemple.fr").await;
    assert_eq!(
        worker
            .run_once(&CancellationToken::new())
            .await
            .expect("refus"),
        vec![JobOutcome::Failed(FailureClass::Permanent)]
    );
    due_now().await;
    assert!(worker
        .run_once(&CancellationToken::new())
        .await
        .expect("rien")
        .is_empty());
    assert_eq!(fake.requests_to("resend").len(), 1);
    assert_eq!(
        rows(&client, "SELECT VALUE [status, last_error.code, integration.key] FROM notification_job WHERE run.idempotency_key = 'refus'").await,
        vec![serde_json::json!(["failed", "NOTIFICATION_PROVIDER_REJECTED", "brevo"])]
    );
}

#[tokio::test]
async fn mailgun_and_resend_webhooks_are_verified() {
    let client = installed_client().await;
    let vault = vault(&client);
    let fake = FakeProviders::start().await;
    let dispatcher = dispatcher(&vault, Some(&fake.base));
    // Clés de 32 octets : signatures calculées ici sans aucune transformation de la clé
    // Clé de 36 octets (de 33 à 64 octets) : elle passe par ExternalHmacKey
    let mailgun_key = "essai_signature_retours_36_octets_xy";
    let svix_raw: Vec<u8> = (0u8..32).collect();
    put_secret(
        &client,
        &vault,
        None,
        "notification/mailgun/api",
        r#"{"api_key":"key-1"}"#,
    )
    .await;
    put_secret(
        &client,
        &vault,
        None,
        "notification/mailgun/webhook",
        &format!(r#"{{"signing_key":"{mailgun_key}"}}"#),
    )
    .await;
    put_secret(
        &client,
        &vault,
        None,
        "notification/resend/api",
        r#"{"api_key":"re_1"}"#,
    )
    .await;
    put_secret(
        &client,
        &vault,
        None,
        "notification/resend/webhook",
        &format!(
            r#"{{"signing_secret":"whsec_{}"}}"#,
            STANDARD.encode(&svix_raw)
        ),
    )
    .await;
    for (key, provider, domain) in [
        ("mailgun", "mailgun", Some("mg.lyxal.test")),
        ("resend", "resend", None),
    ] {
        integration(
            &client,
            IntegrationSaveParams {
                key: key.into(),
                provider: Some(provider.into()),
                name: Some(key.into()),
                settings: Some(IntegrationSettings {
                    domain: domain.map(str::to_string),
                    ..settings("noreply@lyxal.test")
                }),
                credentials_path: Some(format!("notification/{key}/api")),
                webhook_path: Some(format!("notification/{key}/webhook")),
                ..IntegrationSaveParams::default()
            },
        )
        .await;
    }
    let store = NotificationStore::new(client.clone());

    // Mailgun : HMAC-SHA256(clé, horodatage + jeton) en hexadécimal
    let mailgun = claimed(&client, "mailgun").await;
    let key =
        ExternalHmacKey::import(SecretBytes::new(mailgun_key.as_bytes().to_vec()).expect("clé"))
            .expect("clé");
    let mailgun_body = |timestamp: i64, signature: Option<&str>| {
        let token = "jeton-aleatoire-50";
        let signed: String =
            sign_external_hmac_sha256(&key, format!("{timestamp}{token}").as_bytes())
                .expect("signature")
                .iter()
                .map(|b| format!("{b:02x}"))
                .collect();
        serde_json::json!({
            "signature": { "timestamp": timestamp.to_string(), "token": token, "signature": signature.unwrap_or(&signed) },
            "event-data": { "event": "failed", "severity": "permanent", "id": "mg-event-1", "timestamp": timestamp as f64, "message": { "headers": { "message-id": "mg-1@mg.lyxal.test" } } }
        })
        .to_string()
    };
    let valid = mailgun_body(now(), None);
    let events = dispatcher
        .verify_webhook(
            &mailgun,
            &WebhookRequest {
                body: valid.as_bytes(),
                ..Default::default()
            },
            now(),
        )
        .await
        .expect("signature valide");
    assert_eq!(
        (
            events[0].event_id.as_str(),
            events[0].kind,
            events[0].provider_message_id.as_deref()
        ),
        (
            "mg-event-1",
            ProviderEventKind::Bounced,
            Some("mg-1@mg.lyxal.test")
        )
    );
    let forged = mailgun_body(now(), Some(&"0".repeat(64)));
    let stale = mailgun_body(now() - 400, None);
    for body in [&forged, &stale] {
        assert_eq!(
            dispatcher
                .verify_webhook(
                    &mailgun,
                    &WebhookRequest {
                        body: body.as_bytes(),
                        ..Default::default()
                    },
                    now()
                )
                .await,
            Err(WebhookError::Unauthorized)
        );
    }
    // Rejeu d'un retour valide : vérifié de nouveau, dédoublonné en base (message inconnu ici)
    for expected in ["unmatched", "duplicate"] {
        let events = dispatcher
            .verify_webhook(
                &mailgun,
                &WebhookRequest {
                    body: valid.as_bytes(),
                    ..Default::default()
                },
                now(),
            )
            .await
            .expect("rejeu");
        assert_eq!(
            store
                .provider_event_record(events[0].record_params(mailgun.id.to_sql()))
                .await
                .expect("enregistré")
                .status,
            expected
        );
    }

    // Resend (Svix) : HMAC-SHA256 de « id.horodatage.corps », signature v1 en Base64
    let resend = claimed(&client, "resend").await;
    let svix_key = HmacKey::import(SecretBytes::new(svix_raw.clone()).expect("clé")).expect("clé");
    let body = serde_json::json!({ "type": "email.complained", "created_at": "2026-11-16T10:00:00.000Z", "data": { "email_id": "re-1" } }).to_string();
    let sign = |timestamp: &str| {
        let tag = sign_hmac_sha256(&svix_key, format!("msg_1.{timestamp}.{body}").as_bytes())
            .expect("signature");
        format!("v1,{}", STANDARD.encode(tag))
    };
    let fresh = now().to_string();
    let signature = format!("v1,{} {}", STANDARD.encode([0u8; 32]), sign(&fresh));
    let events = dispatcher
        .verify_webhook(&resend, &svix(&fresh, &signature, &body), now())
        .await
        .expect("une des signatures est valide");
    assert_eq!(
        (
            events[0].event_id.as_str(),
            events[0].kind,
            events[0].provider_message_id.as_deref()
        ),
        ("msg_1", ProviderEventKind::Complained, Some("re-1"))
    );
    let old = (now() - 400).to_string();
    let forged_signature = format!("v1,{}", STANDARD.encode([7u8; 32]));
    for (timestamp, signature) in [
        (fresh.clone(), forged_signature),
        (old.clone(), sign(&old)),
        (fresh.clone(), String::new()),
    ] {
        assert_eq!(
            dispatcher
                .verify_webhook(&resend, &svix(&timestamp, &signature, &body), now())
                .await,
            Err(WebhookError::Unauthorized),
            "{timestamp} {signature}"
        );
    }
    // Corps modifié après signature : refusé
    let tampered = body.replace("re-1", "re-2");
    assert_eq!(
        dispatcher
            .verify_webhook(&resend, &svix(&fresh, &sign(&fresh), &tampered), now())
            .await,
        Err(WebhookError::Unauthorized)
    );
}

#[tokio::test]
async fn a_condition_and_a_webhook_secret_are_cleared_through_the_typed_update() {
    let client = installed_client().await;
    let vault = vault(&client);
    alpha(&client).await;
    for path in ["notification/postmark/api", "notification/postmark/webhook"] {
        put_secret(
            &client,
            &vault,
            Some("auth_organization:alpha"),
            path,
            r#"{"api_key":"x"}"#,
        )
        .await;
    }
    let created = integration(
        &client,
        IntegrationSaveParams {
            condition: Some(serde_json::json!({ "field": "payload.n", "op": "exists" })),
            webhook_path: Some("notification/postmark/webhook".into()),
            ..org_integration("postmark", "postmark", 100)
        },
    )
    .await;
    assert!(created.condition.is_some() && created.webhook_path.is_some());
    let updated = NotificationStore::new(client.clone())
        .integration_update(IntegrationSaveParams {
            tenant: Some("auth_organization:alpha".into()),
            key: "postmark".into(),
            clear_condition: Some(true),
            clear_webhook: Some(true),
            ..IntegrationSaveParams::default()
        })
        .await
        .expect("modification");
    assert_eq!(updated.condition, None);
    assert_eq!(updated.webhook_path, None);
}
