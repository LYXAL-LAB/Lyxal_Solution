//! Droits par session : personnes et programmes (jetons de la méthode d'accès de test), modules
//! de l'hôte (`SecretsClient`, session système). Lectures refusées journalisées au nom de
//! l'appelant (R6).

use lyxal_crypto::SecretBytes;
use lyxal_secrets::models::{AuditItem, SecretCreateParams, Stage};
use lyxal_secrets::{ClientRead, ClientWrite, SecretsClient};

use crate::support::{bench, code, put, reveal, Bench, ALPHA};

/// Lectures refusées du journal d'une organisation.
async fn denied(bench: &Bench) -> Vec<AuditItem> {
    bench
        .journal(Some(ALPHA))
        .await
        .into_iter()
        .filter(|item| item.event["action"] == "secret.read" && item.event["outcome"] == "denied")
        .collect()
}

#[tokio::test]
async fn a_refused_read_is_journaled_on_behalf_of_the_caller() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/stripe").await;
    bench.put(&secret, b"valeur stripe").await;
    let reader = bench
        .person("lecteur", ALPHA, &["secrets.secret.list"])
        .await;
    let service = bench.service_for(&reader);

    assert_eq!(
        code(service.reveal(reveal(&secret)).await),
        "SECRETS_PERMISSION_DENIED"
    );
    // Écriture sans le droit d'écriture : refusée par la base
    assert_eq!(
        code(service.put(put(&secret, b"pirate")).await),
        "SECRETS_PERMISSION_DENIED"
    );
    let entries = denied(&bench).await;
    assert_eq!(entries.len(), 1, "{entries:?}");
    let event = &entries[0].event;
    assert_eq!(event["actor"], "auth_identity:lecteur");
    assert_eq!(event["session"], "auth_session:lecteur");
    assert_eq!(event["session_kind"], "interactive");
    assert_eq!(event["details"]["code"], "SECRETS_PERMISSION_DENIED");
    assert_eq!(event["secret"], secret.as_str());
    // La valeur n'a pas changé
    assert_eq!(bench.read(&secret).await, b"valeur stripe");
}

#[tokio::test]
async fn a_person_without_a_fresh_second_factor_is_refused() {
    let bench = bench().await;
    let secret = bench
        .secret_with(SecretCreateParams {
            visibility: Some("revealable".into()),
            ..SecretCreateParams::new(Some(ALPHA.into()), "api/revelable", "api_key")
        })
        .await;
    bench.put(&secret, b"valeur revelable").await;
    let human = bench
        .person(
            "humain",
            ALPHA,
            &["secrets.secret.list", "secrets.value.read"],
        )
        .await;
    // Second facteur activé, mais la session est restée au premier niveau
    bench
        .run("UPDATE auth_identity:humain SET available_aal = 2")
        .await;
    let error = bench
        .service_for(&human)
        .reveal(reveal(&secret))
        .await
        .expect_err("double facteur exigé");
    assert_eq!(error.code(), "AUTH_AAL_INSUFFICIENT");
    let entries = denied(&bench).await;
    assert_eq!(entries.len(), 1, "{entries:?}");
    assert_eq!(entries[0].event["details"]["code"], error.code().as_str());
    assert_eq!(entries[0].event["actor"], "auth_identity:humain");

    // Session au second facteur, récent : lecture permise
    bench
        .run("UPDATE auth_session:humain SET aal = 2, authenticated_at = time::now()")
        .await;
    let read = bench
        .service_for(&human)
        .reveal(reveal(&secret))
        .await
        .expect("second facteur récent");
    assert_eq!(read.value.expose_secret(), b"valeur revelable");

    // Secret non révélable : refusé à une personne quel que soit son droit
    let restricted = bench.secret(Some(ALPHA), "api/restreint").await;
    bench.put(&restricted, b"valeur restreinte").await;
    assert_eq!(
        code(bench.service_for(&human).reveal(reveal(&restricted)).await),
        "SECRETS_REVEAL_FORBIDDEN"
    );
}

#[tokio::test]
async fn a_program_writes_and_reads_as_a_listed_consumer() {
    let bench = bench().await;
    let secret = bench
        .secret_with(SecretCreateParams {
            consumers: vec!["auth_application:robot".into()],
            ..SecretCreateParams::new(Some(ALPHA.into()), "api/robot", "token")
        })
        .await;
    let robot = bench
        .program(
            "robot",
            ALPHA,
            &[
                "secrets.secret.list",
                "secrets.secret.write",
                "secrets.value.read",
            ],
        )
        .await;
    let service = bench.service_for(&robot);
    let added = service
        .put(put(&secret, b"jeton du robot"))
        .await
        .expect("écriture par le programme");
    assert_eq!(
        added
            .version
            .created_by_application
            .as_ref()
            .map(lyxal_surreal::ToSql::to_sql)
            .as_deref(),
        Some("auth_application:robot")
    );
    let read = service.reveal(reveal(&secret)).await.expect("lecture");
    assert_eq!(read.value.expose_secret(), b"jeton du robot");

    // Programme absent de la liste des consommateurs : refusé et journalisé
    let other = bench
        .program(
            "intrus",
            ALPHA,
            &["secrets.secret.list", "secrets.value.read"],
        )
        .await;
    assert_eq!(
        code(bench.service_for(&other).reveal(reveal(&secret)).await),
        "SECRETS_CONSUMER_NOT_ALLOWED"
    );
    let entries = denied(&bench).await;
    assert_eq!(entries.len(), 1, "{entries:?}");
    assert_eq!(entries[0].event["application"], "auth_application:intrus");
    assert_eq!(entries[0].event["session_kind"], "service");
}

#[tokio::test]
async fn a_tenant_key_rotation_needs_the_settings_right() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/rotation").await;
    bench.put(&secret, b"avant rotation").await;
    let admin = bench
        .person(
            "admin",
            ALPHA,
            &["secrets.secret.list", "secrets.settings.manage"],
        )
        .await;
    let writer = bench
        .person(
            "redacteur",
            ALPHA,
            &["secrets.secret.list", "secrets.secret.write"],
        )
        .await;
    assert_eq!(
        code(
            bench
                .service_for(&writer)
                .rotate_tenant_key(Some(ALPHA.into()))
                .await
        ),
        "SECRETS_PERMISSION_DENIED"
    );
    let rotated = bench
        .service_for(&admin)
        .rotate_tenant_key(Some(ALPHA.into()))
        .await
        .expect("rotation");
    assert!(rotated.retired.is_some());
    let requested_by: Option<String> = bench
        .value(&format!(
            "SELECT VALUE requested_by FROM ONLY secrets_tenant_key WHERE key_id = '{}' LIMIT 1",
            rotated.key_id
        ))
        .await;
    assert_eq!(requested_by.as_deref(), Some("auth_identity:admin"));
    // Écriture par le rédacteur : scellée par la nouvelle clé
    let added = bench
        .service_for(&writer)
        .put(put(&secret, b"apres rotation"))
        .await
        .expect("écriture");
    assert_eq!(
        added.version.key_id.as_deref(),
        Some(rotated.key_id.as_str())
    );
    assert_eq!(bench.read(&secret).await, b"apres rotation");
}

#[tokio::test]
async fn a_host_module_reads_its_secrets_as_announced_consumer() {
    let bench = bench().await;
    bench
        .secret_with(SecretCreateParams {
            consumers: vec!["lyxal_notification".into()],
            ..SecretCreateParams::new(None, "notification/smtp/password", "password")
        })
        .await;
    let client = SecretsClient::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        "lyxal_notification",
    );
    let written = client
        .write(ClientWrite {
            tenant: None,
            path: "notification/smtp/password".into(),
            value: SecretBytes::new(b"mot de passe smtp".to_vec()).expect("valeur"),
            stage: Stage::Current,
        })
        .await
        .expect("écriture");
    assert_eq!(written.version.number, 1);
    let read = client
        .read(ClientRead {
            tenant: None,
            path: "notification/smtp/password".into(),
            label: None,
        })
        .await
        .expect("lecture");
    assert_eq!(read.value.expose_secret(), b"mot de passe smtp");
    assert!(!format!("{client:?}").contains("smtp"));

    // Un autre module n'est pas consommateur prévu
    let other = SecretsClient::new(bench.store.clone(), Some(bench.master.clone()), "lyxal_crm");
    let refused = other
        .read(ClientRead {
            tenant: None,
            path: "notification/smtp/password".into(),
            label: None,
        })
        .await;
    assert_eq!(code(refused), "SECRETS_CONSUMER_NOT_ALLOWED");
    let journal = bench.journal(None).await;
    let entry = journal
        .iter()
        .find(|item| item.event["outcome"] == "denied")
        .expect("refus journalisé");
    assert_eq!(entry.event["session_kind"], "system");
    assert_eq!(entry.event["details"]["consumer"], "lyxal_crm");
}
