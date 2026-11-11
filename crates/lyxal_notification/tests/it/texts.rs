//! E-mails du système : chaque gabarit et chaque variante de message, rendus en français et en
//! anglais avec les textes de `lyxal_i18n` lus à la réservation.

use lyxal_notification::models::JobClaimParams;
use lyxal_notification::{NotificationStore, Renderer};

use crate::support::installed_client;

/// Déclenche un parcours du système pour un destinataire dans chaque langue.
fn trigger(workflow: &str, key: &str, payload: &str) -> String {
    ["fr", "en"]
        .iter()
        .map(|locale| {
            format!(
                "fn::notification_trigger({{ workflow_key: '{workflow}', idempotency_key: '{key}-{locale}', \
                 recipient: {{ email: '{key}-{locale}@exemple.fr', locale: '{locale}', name: 'Inès' }}, \
                 payload: {payload}, secret: 'enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA', expires_at: time::now() + 1d }});"
            )
        })
        .collect()
}

#[tokio::test]
async fn system_emails_render_in_french_and_english() {
    let client = installed_client().await;
    // (clé, parcours, charge utile, phrase attendue en français, en anglais)
    let cases: [(&str, &str, &str, &str, &str); 12] = [
        (
            "verif",
            "auth_verification",
            "{}",
            "Pour confirmer votre adresse e-mail",
            "To confirm your email address",
        ),
        (
            "recup",
            "auth_recovery",
            "{}",
            "votre mot de passe reste inchangé",
            "your password is unchanged",
        ),
        (
            "invit",
            "auth_invitation",
            "{ invitation_id: 'i', organization_name: 'Alpha & Fils', inviter_name: 'Luc' }",
            "Luc vous invite à rejoindre l'organisation Alpha & Fils.",
            "Luc invites you to join the organization Alpha & Fils.",
        ),
        (
            "invit-anonyme",
            "auth_invitation",
            "{ invitation_id: 'i', organization_name: 'Alpha' }",
            "Vous êtes invité à rejoindre l'organisation Alpha.",
            "You are invited to join the organization Alpha.",
        ),
        (
            "totp",
            "auth_security_alert",
            "{ alert: 'mfa_enrolled', method: 'totp' }",
            "ajouté à votre compte : application d'authentification.",
            "added to your account: authenticator app.",
        ),
        (
            "passkey",
            "auth_security_alert",
            "{ alert: 'mfa_enrolled', method: 'passkey', label: 'Téléphone' }",
            "passkey « Téléphone ».",
            "passkey “Téléphone”.",
        ),
        (
            "retrait",
            "auth_security_alert",
            "{ alert: 'mfa_removed', method: 'passkey' }",
            "retiré de votre compte : passkey.",
            "removed from your account: passkey.",
        ),
        (
            "admin",
            "auth_security_alert",
            "{ alert: 'mfa_removed', reason: 'admin_reset' }",
            "Un administrateur a retiré tous les seconds facteurs",
            "An administrator removed all second factors",
        ),
        (
            "codes",
            "auth_security_alert",
            "{ alert: 'recovery_codes_generated' }",
            "les précédents ne fonctionnent plus.",
            "the previous ones no longer work.",
        ),
        (
            "code-utilise",
            "auth_security_alert",
            "{ alert: 'recovery_code_used', remaining: 1 }",
            "Il vous en reste 1.",
            "You have 1 left.",
        ),
        (
            "code-dernier",
            "auth_security_alert",
            "{ alert: 'recovery_code_used', remaining: 0 }",
            "Il ne vous en reste aucun.",
            "You have none left.",
        ),
        (
            "clone",
            "auth_security_alert",
            "{ alert: 'passkey_clone_detected', label: 'Clé' }",
            "(« Clé ») a été refusée",
            "(“Clé”) was refused",
        ),
    ];
    let script: String = cases
        .iter()
        .map(|(key, workflow, payload, _, _)| trigger(workflow, key, payload))
        .collect();
    client
        .query(script)
        .await
        .expect("déclenchements")
        .check()
        .expect("déclenchements acceptés");

    let jobs = NotificationStore::new(client)
        .job_claim(JobClaimParams {
            worker_id: "test".to_string(),
            limit: 100,
            lease_seconds: 60,
        })
        .await
        .expect("réservation");
    assert_eq!(jobs.len(), cases.len() * 2);
    let secret =
        serde_json::json!({ "code": "123456", "action_url": "https://lyxal.test/a?b=1&c=2" });
    let renderer = Renderer::default();
    for (key, _, _, french, english) in cases {
        for (locale, expected, greeting) in [
            ("fr", french, "Bonjour Inès,"),
            ("en", english, "Hello Inès,"),
        ] {
            let job = jobs
                .iter()
                .find(|job| job.idempotency_key == format!("{key}-{locale}"))
                .expect("étape réservée");
            assert_eq!(job.locale.as_deref(), Some(locale));
            let email = renderer
                .render(job, secret.as_object())
                .unwrap_or_else(|error| panic!("{key} {locale} : {error}"));
            assert!(
                email.text.starts_with(greeting),
                "{key} {locale} : {}",
                email.text
            );
            assert!(
                email.text.contains(expected),
                "{key} {locale} : {}",
                email.text
            );
            // Même phrase dans le HTML, échappée ; mise en page par défaut appliquée
            let escaped = expected.replace('&', "&amp;").replace('\'', "&#x27;");
            assert!(
                email.html.contains(&escaped),
                "{key} {locale} : {}",
                email.html
            );
            assert!(email.html.starts_with("<!DOCTYPE html>"));
            assert!(!email.subject.is_empty() && !email.subject.contains("{{"));
        }
    }
    // Objet de l'invitation : nom de l'organisation en argument, sans échappement HTML
    let invitation = jobs
        .iter()
        .find(|job| job.idempotency_key == "invit-en")
        .expect("invitation");
    let email = renderer
        .render(invitation, secret.as_object())
        .expect("invitation");
    assert_eq!(email.subject, "Invitation to join Alpha & Fils");
    assert!(
        email
            .html
            .contains("href=\"https:&#x2f;&#x2f;lyxal.test&#x2f;a?b=1&amp;c=2\""),
        "{}",
        email.html
    );
    assert!(email
        .text
        .contains("Accept the invitation\nhttps://lyxal.test/a?b=1&c=2"));
}
