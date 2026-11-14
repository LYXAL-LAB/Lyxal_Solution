//! Partages à usage unique : texte ouvert jusqu'au maximum puis refusé, copie d'un secret, clé ou
//! mot de passe faux et destruction au cinquième essai, lien réservé à l'organisation, retrait,
//! partage échu expiré par le worker, aucune valeur, clé ni mot de passe dans un `Debug` ou une
//! erreur.

use lyxal_crypto::{SecretBytes, SecretString};
use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::models::{SecretCreateParams, ShareListParams, ShareRefParams, ShareState};
use lyxal_secrets::{
    OpenerContext, RotatorRegistry, SecretsMaintenanceWorker, SecretsService, ShareCreated,
    ShareOpen, ShareRequest, ShareSource,
};
use lyxal_surreal::ToSql;
use std::time::Duration;

use crate::support::{bench, code, Bench, ALPHA, BETA};

const SHARER: &[&str] = &["secrets.secret.list", "secrets.share.create"];

fn text(tenant: &str, value: &[u8]) -> ShareRequest {
    ShareRequest {
        tenant: Some(tenant.to_string()),
        source: ShareSource::Text(SecretBytes::new(value.to_vec()).expect("valeur")),
        max_views: None,
        ttl: None,
        passphrase: None,
        members_only: false,
        note: Some("prestataire".to_string()),
    }
}

fn secret(value: &str) -> SecretString {
    SecretString::new(value.to_string()).expect("secret")
}

fn open(created: &ShareCreated, key: Option<&str>, passphrase: Option<&str>) -> ShareOpen {
    ShareOpen {
        share: created.share.id.to_sql(),
        key: secret(key.unwrap_or(created.key.expose_secret())),
        passphrase: passphrase.map(secret),
        opener: None,
    }
}

/// Service de l'auteur (personne d'alpha qui détient le droit de partage).
async fn sharer(bench: &Bench) -> SecretsService {
    let user = bench.person("partageur", ALPHA, SHARER).await;
    bench.service_for(&user)
}

#[tokio::test]
async fn a_text_share_opens_up_to_its_maximum_then_is_refused() {
    let bench = bench().await;
    let service = sharer(&bench).await;
    let created = service
        .share_create(ShareRequest {
            max_views: Some(2),
            ..text(ALPHA, b"mot de passe du prestataire")
        })
        .await
        .expect("partage");
    assert_eq!(created.share.state, ShareState::Active);
    assert_eq!(created.share.max_views, 2);
    assert!(!created.share.protected);
    assert_eq!(
        created.share.created_identity.as_ref().map(ToSql::to_sql),
        Some("auth_identity:partageur".to_string())
    );
    // Clé de 32 octets en base64url sans remplissage
    assert_eq!(created.key.len(), 43);

    // N'importe qui avec le lien : session système de l'hôte, sans appelant
    let anyone = &bench.service;
    for _ in 0..2 {
        let value = anyone
            .share_open(open(&created, None, None))
            .await
            .expect("ouverture");
        assert_eq!(value.expose_secret(), b"mot de passe du prestataire");
    }
    assert_eq!(
        code(anyone.share_open(open(&created, None, None)).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );

    // Épuisé : copie, empreinte et hachage effacés ; la base n'a jamais vu la clé
    let row: serde_json::Value = bench
        .value(&format!(
            "SELECT state, envelope, key_fingerprint, views FROM ONLY {}",
            created.share.id.to_sql()
        ))
        .await;
    assert_eq!(row["state"], "consumed");
    assert_eq!(row["views"], 2);
    assert!(row["envelope"].is_null() && row["key_fingerprint"].is_null());
    let dump: Vec<serde_json::Value> = bench.values("SELECT * FROM secrets_share").await;
    assert!(!serde_json::Value::from(dump)
        .to_string()
        .contains(created.key.expose_secret()));
}

#[tokio::test]
async fn a_secret_is_shared_as_a_copy_of_the_revealed_version() {
    let bench = bench().await;
    let source = bench
        .secret_with(SecretCreateParams {
            consumers: vec!["auth_application:robot".into()],
            ..SecretCreateParams::new(Some(ALPHA.into()), "api/stripe", "api_key")
        })
        .await;
    bench.put(&source, b"sk_live_1").await;
    bench.put(&source, b"sk_live_2").await;
    let robot = bench
        .program(
            "robot",
            ALPHA,
            &[
                "secrets.secret.list",
                "secrets.value.read",
                "secrets.share.create",
            ],
        )
        .await;
    let created = bench
        .service_for(&robot)
        .share_create(ShareRequest {
            tenant: Some(ALPHA.to_string()),
            source: ShareSource::Secret {
                secret: source.clone(),
                label: None,
                number: None,
            },
            max_views: None,
            ttl: None,
            passphrase: None,
            members_only: false,
            note: None,
        })
        .await
        .expect("partage du secret");
    assert_eq!(
        created.share.secret.as_ref().map(ToSql::to_sql),
        Some(source.clone())
    );
    assert_eq!(created.share.number, Some(2));
    assert_eq!(
        created
            .share
            .created_application
            .as_ref()
            .map(ToSql::to_sql),
        Some("auth_application:robot".to_string())
    );

    // Une version écrite ensuite ne change pas la copie
    bench.put(&source, b"sk_live_3").await;
    let value = bench
        .service
        .share_open(open(&created, None, None))
        .await
        .expect("ouverture");
    assert_eq!(value.expose_secret(), b"sk_live_2");

    // Sans le droit de partage : refusé, aucune fiche
    let member = bench
        .person("membre", ALPHA, &["secrets.secret.list"])
        .await;
    assert_eq!(
        code(
            bench
                .service_for(&member)
                .share_create(text(ALPHA, b"x"))
                .await
        ),
        "SECRETS_PERMISSION_DENIED"
    );
}

#[tokio::test]
async fn a_wrong_key_or_passphrase_counts_and_the_fifth_destroys_the_share() {
    let bench = bench().await;
    let service = sharer(&bench).await;
    let created = service
        .share_create(ShareRequest {
            passphrase: Some(secret("correct horse battery staple")),
            ..text(ALPHA, b"valeur protegee")
        })
        .await
        .expect("partage protégé");
    assert!(created.share.protected);
    let anyone = &bench.service;
    let wrong_key = "A".repeat(43);

    // Clé fausse, clé illisible, mot de passe faux, mot de passe absent : même refus
    let attempts = [
        open(
            &created,
            Some(&wrong_key),
            Some("correct horse battery staple"),
        ),
        open(&created, Some("pas une clé !"), None),
        open(&created, None, Some("mauvais mot de passe")),
        open(&created, None, None),
    ];
    for attempt in attempts {
        assert_eq!(
            code(anyone.share_open(attempt).await),
            "SECRETS_SHARE_UNAVAILABLE"
        );
    }
    let failed: i64 = bench
        .value(&format!(
            "SELECT VALUE failed_attempts FROM ONLY {}",
            created.share.id.to_sql()
        ))
        .await;
    assert_eq!(failed, 4);

    // Cinquième essai faux : détruit ; la bonne clé ne sert plus
    assert_eq!(
        code(
            anyone
                .share_open(open(&created, Some(&wrong_key), None))
                .await
        ),
        "SECRETS_SHARE_UNAVAILABLE"
    );
    let state: String = bench
        .value(&format!(
            "SELECT VALUE state FROM ONLY {}",
            created.share.id.to_sql()
        ))
        .await;
    assert_eq!(state, "destroyed");
    assert_eq!(
        code(
            anyone
                .share_open(open(&created, None, Some("correct horse battery staple")))
                .await
        ),
        "SECRETS_SHARE_UNAVAILABLE"
    );

    // Partage inconnu ou identifiant invalide : le même refus
    let mut unknown = open(&created, None, None);
    unknown.share = "secrets_share:inconnu".to_string();
    assert_eq!(
        code(anyone.share_open(unknown).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );
    let mut invalid = open(&created, None, None);
    invalid.share = "pas un identifiant".to_string();
    assert_eq!(
        code(anyone.share_open(invalid).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );
}

#[tokio::test]
async fn a_members_only_share_needs_a_member_of_the_organization() {
    let bench = bench().await;
    let service = sharer(&bench).await;
    let created = service
        .share_create(ShareRequest {
            members_only: true,
            ..text(ALPHA, b"interne")
        })
        .await
        .expect("partage réservé");
    let anyone = &bench.service;
    let with = |opener: Option<OpenerContext>| ShareOpen {
        opener,
        ..open(&created, None, None)
    };
    // Sans session, ou membre d'une autre organisation : refusé, sans compter d'essai
    assert_eq!(
        code(anyone.share_open(with(None)).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );
    assert_eq!(
        code(
            anyone
                .share_open(with(Some(OpenerContext {
                    identity: Some("auth_identity:autre".into()),
                    organization: Some(BETA.into()),
                })))
                .await
        ),
        "SECRETS_SHARE_UNAVAILABLE"
    );
    let failed: i64 = bench
        .value(&format!(
            "SELECT VALUE failed_attempts FROM ONLY {}",
            created.share.id.to_sql()
        ))
        .await;
    assert_eq!(failed, 0);

    // Membre connecté d'alpha : ouvert, ouvreur journalisé
    let value = anyone
        .share_open(with(Some(OpenerContext {
            identity: Some("auth_identity:partageur".into()),
            organization: Some(ALPHA.into()),
        })))
        .await
        .expect("ouverture par un membre");
    assert_eq!(value.expose_secret(), b"interne");
    let journal = bench.journal(Some(ALPHA)).await;
    assert!(
        journal
            .iter()
            .any(|entry| entry.event["action"] == "share.opener"),
        "{journal:?}"
    );
}

#[tokio::test]
async fn a_revoked_share_no_longer_opens_and_the_worker_expires_due_shares() {
    let bench = bench().await;
    let service = sharer(&bench).await;
    let revoked = service
        .share_create(text(ALPHA, b"a retirer"))
        .await
        .expect("partage");
    let kept = service
        .share_create(text(ALPHA, b"a garder"))
        .await
        .expect("partage");
    let listed = service
        .store()
        .share_list(ShareListParams {
            tenant: Some(ALPHA.to_string()),
            ..ShareListParams::default()
        })
        .await
        .expect("liste");
    assert_eq!(listed.total, 2);

    let done = service
        .store()
        .share_revoke(ShareRefParams {
            share: revoked.share.id.to_sql(),
        })
        .await
        .expect("retrait");
    assert_eq!(done.state, ShareState::Revoked);
    assert_eq!(
        code(bench.service.share_open(open(&revoked, None, None)).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );

    // Échéance passée (champ rendu modifiable pour le test seulement), puis passage du worker
    bench
        .run(&format!(
            "DEFINE FIELD OVERWRITE expires_at ON TABLE secrets_share TYPE datetime;
             UPDATE {} SET expires_at = time::now() - 1s;",
            kept.share.id.to_sql()
        ))
        .await;
    assert_eq!(
        code(bench.service.share_open(open(&kept, None, None)).await),
        "SECRETS_SHARE_UNAVAILABLE"
    );
    let report = SecretsMaintenanceWorker::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        RotatorRegistry::new(),
        Duration::from_secs(3600),
        10,
    )
    .expect("worker")
    .run_once(&CancellationToken::new())
    .await
    .expect("passage");
    assert_eq!(report.shares_expired, 1);
    assert_eq!(report.shares_removed, 0);
    assert_eq!(report.failed, 0);
}

#[tokio::test]
async fn no_value_key_or_passphrase_appears_in_a_debug_or_an_error() {
    let bench = bench().await;
    let service = sharer(&bench).await;
    let request = ShareRequest {
        passphrase: Some(secret("phrase-de-passe-secrete")),
        ..text(ALPHA, b"valeur-tres-secrete")
    };
    let shown = format!("{request:?}");
    assert!(!shown.contains("valeur-tres-secrete") && !shown.contains("phrase-de-passe-secrete"));
    let created = service.share_create(request).await.expect("partage");
    let key = created.key.expose_secret().to_string();
    assert!(!format!("{created:?}").contains(&key));
    let attempt = open(&created, None, Some("phrase-de-passe-secrete"));
    let shown = format!("{attempt:?}");
    assert!(!shown.contains(&key) && !shown.contains("phrase-de-passe-secrete"));

    let refused = bench
        .service
        .share_open(open(&created, None, Some("faux-mot-de-passe")))
        .await
        .expect_err("refus");
    for text in [format!("{refused:?}"), refused.to_string()] {
        assert!(
            !text.contains(&key)
                && !text.contains("faux-mot-de-passe")
                && !text.contains("valeur-tres-secrete"),
            "{text}"
        );
    }
    let value = bench.service.share_open(attempt).await.expect("ouverture");
    assert!(!format!("{value:?}").contains("valeur-tres-secrete"));
}
