// SPDX-License-Identifier: AGPL-3.0-only

//! File d'envoi par les wrappers Rust (lot 6c) : dépôt authentifié sous la session du titulaire,
//! fichier écrit chiffré par `lyxal_storage`, clôture et file sous la session système ;
//! réservation, préparation, remise, lecture de l'issue ; reprise d'un bail expiré (jeton périmé
//! refusé, à réessayer) ; clés DKIM ; contrat public des modules appelé par le nom des fonctions,
//! sans aucun type de `lyxal_mail` (comme le fera `lyxal_notification`).

use bytes::Bytes;
use lyxal_mail::models::{
    DeliveredItem, DkimAlgorithm, DkimKeyActivateParams, DkimKeyCreateParams, DkimKeyListParams,
    DkimKeyState, DkimSignersParams, DomainUpdateParams, DsnNotify, QueueClaimParams,
    QueueCompleteParams, QueueOutcome, QueuePrepareParams, QueueStatsParams, RecipientState,
    SenderCheckParams, SubmissionBeginParams, SubmissionCommitParams, SubmissionOrigin,
    SubmissionRecipient, SubmissionRefParams, SubmissionState, TlsInfo,
};
use lyxal_mail::{MailStore, MAIL_BUCKET};
use lyxal_storage::models::BucketCreateParams;
use lyxal_storage::PutRequest;
use lyxal_surreal::{LyxalSurrealCall, RecordId, SurrealValue, ToSql};
use std::convert::Infallible;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::support::{bench, code, token, Bench};

/// Message déposé.
const MESSAGE: &str = "From: Jean <jean@alpha.test>\r\n\
To: Paul <paul@ailleurs.test>\r\n\
Subject: Devis\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <devis-envoi@alpha.test>\r\n\
\r\n\
Bonjour Paul, voici le devis.\r\n";

/// Bucket chiffré du courrier de l'organisation alpha (créé par l'hôte, session système).
async fn mail_bucket(bench: &Bench) -> String {
    let mut params =
        BucketCreateParams::named(Some("auth_organization:alpha".to_string()), MAIL_BUCKET);
    params.encrypted = true;
    params.emit_events = false;
    bench
        .storage_store
        .bucket_create(params)
        .await
        .expect("bucket chiffré du courrier")
        .id
        .to_sql()
}

/// Fichier écrit chiffré à la clé rendue par le dépôt ; rend la fiche du fichier.
async fn write_file(bench: &Bench, bucket: &str, key: &str, raw: &[u8]) -> String {
    let content = futures::stream::iter([Ok::<Bytes, Infallible>(Bytes::copy_from_slice(raw))]);
    bench
        .storage
        .put(
            PutRequest {
                bucket: bucket.to_string(),
                key: key.to_string(),
                filename: "message.eml".to_string(),
                content_type: Some("message/rfc822".to_string()),
                size: Some(raw.len() as u64),
            },
            content,
        )
        .await
        .expect("fichier écrit")
        .id
        .to_sql()
}

/// Session d'une personne avec la permission d'envoyer.
async fn sender(bench: &Bench, name: &str) -> MailStore {
    let user = bench.client.clone();
    user.authenticate(token(
        &format!("auth_session:{name}"),
        &["mail.mailbox.access", "mail.send"],
    ))
    .await
    .expect("jeton de test accepté");
    MailStore::new(user)
}

fn recipient(address: &str) -> SubmissionRecipient {
    SubmissionRecipient {
        address: address.to_string(),
        notify: None,
        orcpt: None,
    }
}

fn begin(from: &str, recipients: Vec<SubmissionRecipient>, size: usize) -> SubmissionBeginParams {
    SubmissionBeginParams {
        origin: None,
        from: from.to_string(),
        header_from: vec![from.to_string()],
        recipients,
        size: size as i64,
        smtputf8: None,
        eight_bit: None,
        dsn: None,
        client_reference: None,
        return_token: None,
        prefix: None,
        forward: None,
        tenant: None,
    }
}

fn claim_params(node: &str) -> QueueClaimParams {
    QueueClaimParams {
        node: node.to_string(),
        limit: None,
        lease_seconds: None,
        exclude_domains: Vec::new(),
    }
}

#[tokio::test]
async fn a_submission_is_queued_claimed_prepared_and_delivered() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let jean = bench.person("jean", "alpha", &domain).await;
    let jean_sends = sender(&bench, "jean").await;
    let bucket = mail_bucket(&bench).await;

    // Droit d'expéditeur, puis usurpation refusée sans rien déposer
    let checked = jean_sends
        .sender_check(SenderCheckParams {
            addresses: vec!["jean@alpha.test".into(), "marie@alpha.test".into()],
        })
        .await
        .expect("contrôle");
    assert!(!checked.allowed);
    assert_eq!(checked.refused, vec![1]);
    let spoofed = jean_sends
        .submission_begin(begin(
            "marie@alpha.test",
            vec![recipient("paul@ailleurs.test")],
            10,
        ))
        .await;
    assert_eq!(code(spoofed.map_err(Into::into)), "MAIL_SENDER_FORBIDDEN");

    // Dépôt sous la session du titulaire, fichier et clôture sous la session système de l'hôte
    let mut params = begin(
        "jean@alpha.test",
        vec![
            recipient("paul@ailleurs.test"),
            SubmissionRecipient {
                address: "jean@alpha.test".into(),
                notify: Some(vec![DsnNotify::Success, DsnNotify::Failure]),
                orcpt: None,
            },
        ],
        MESSAGE.len(),
    );
    params.origin = Some(SubmissionOrigin::Submission);
    let reserved = jean_sends
        .submission_begin(params)
        .await
        .expect("dépôt ouvert");
    assert_eq!(reserved.bucket_name, MAIL_BUCKET);
    assert!(reserved.key.starts_with("queue/"));
    assert!(reserved.return_address.is_none());
    let object = write_file(&bench, &bucket, &reserved.key, MESSAGE.as_bytes()).await;
    let queued = bench
        .system
        .submission_commit(SubmissionCommitParams {
            submission: reserved.submission.to_sql(),
            object,
        })
        .await
        .expect("mise en file");
    assert_eq!(queued.recipients, 2);

    // Le worker réserve, prépare (jeton de retour, préfixe) et écrit les remises
    let claim = bench
        .system
        .queue_claim(claim_params("n1"))
        .await
        .expect("réservation");
    let token_value = claim.claim.clone().expect("jeton de réservation");
    assert_eq!(claim.items.len(), 2);
    assert!(claim
        .items
        .iter()
        .all(|item| !item.prepared && item.origin == SubmissionOrigin::Submission));
    assert_eq!(
        claim.items[1].notify,
        Some(vec![DsnNotify::Success, DsnNotify::Failure])
    );
    assert!(claim.items[1].local);
    let prepared = bench
        .system
        .queue_prepare(QueuePrepareParams {
            claim: token_value.clone(),
            submission: reserved.submission.to_sql(),
            return_token: Some("0123456789abcdefghjkmnpqrs".into()),
            prefix: Some("DKIM-Signature: v=1; a=rsa-sha256\r\n".into()),
            malformed: None,
        })
        .await
        .expect("préparation");
    assert_eq!(
        prepared.envelope_from.as_deref(),
        Some("rp=0123456789abcdefghjkmnpqrs@alpha.test")
    );
    let completed = bench
        .system
        .queue_complete(QueueCompleteParams {
            claim: token_value,
            items: claim
                .items
                .iter()
                .map(|item| DeliveredItem {
                    recipient: item.recipient.to_sql(),
                    outcome: QueueOutcome::Delivered,
                    host: (!item.local).then(|| "mx.ailleurs.test".to_string()),
                    code: Some(250),
                    enhanced: Some("2.0.0".into()),
                    tls: Some(TlsInfo {
                        version: Some("TLSv1.3".into()),
                        verified: false,
                    }),
                    at: None,
                })
                .collect(),
        })
        .await
        .expect("remises");
    assert!(completed.lost.is_empty());
    assert_eq!(completed.dsn.len(), 1, "avis de remise par la route locale");
    assert_eq!(
        completed.dsn[0].recipients,
        vec![claim.items[1].recipient.clone()]
    );

    // Le titulaire lit l'issue ; un autre compte ne voit rien
    let read = jean_sends
        .submission_get(SubmissionRefParams {
            submission: reserved.submission.to_sql(),
        })
        .await
        .expect("lecture");
    assert_eq!(read.state, SubmissionState::Done);
    assert!(read
        .recipients
        .iter()
        .all(|r| r.state == RecipientState::Delivered));
    assert_eq!(
        read.recipients[0]
            .last_result
            .as_ref()
            .and_then(|r| r.tls.clone())
            .map(|t| t.verified),
        Some(false)
    );
    assert_eq!(
        code(
            jean.store
                .submission_get(SubmissionRefParams {
                    submission: reserved.submission.to_sql()
                })
                .await
                .map_err(Into::into)
        ),
        "MAIL_SUBMISSION_NOT_FOUND",
        "sans mail.send, le titulaire ne lit pas ses envois"
    );
    let stats = bench
        .system
        .queue_stats(QueueStatsParams {})
        .await
        .expect("mesures");
    assert_eq!((stats.scheduled, stats.running, stats.due), (0, 0, 0));
}

#[tokio::test]
async fn an_expired_lease_is_taken_over_and_the_stale_claim_is_refused() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    bench.person("jean", "alpha", &domain).await;
    let jean_sends = sender(&bench, "jean").await;
    let bucket = mail_bucket(&bench).await;
    let reserved = jean_sends
        .submission_begin(begin(
            "jean@alpha.test",
            vec![recipient("paul@ailleurs.test")],
            MESSAGE.len(),
        ))
        .await
        .expect("dépôt");
    let object = write_file(&bench, &bucket, &reserved.key, MESSAGE.as_bytes()).await;
    bench
        .system
        .submission_commit(SubmissionCommitParams {
            submission: reserved.submission.to_sql(),
            object,
        })
        .await
        .expect("mise en file");

    let mut short = claim_params("perdu");
    short.lease_seconds = Some(60);
    let crashed = bench.system.queue_claim(short).await.expect("réservation");
    let recipient = crashed.items[0].recipient.clone();
    // Arrêt brutal : le bail expire sans qu'aucun résultat ne soit écrit
    bench
        .run(&format!(
            "UPDATE {} SET locked_until = time::now() - 1s;",
            recipient.to_sql()
        ))
        .await;
    let resumed = bench
        .system
        .queue_claim(claim_params("repreneur"))
        .await
        .expect("reprise");
    assert_eq!(resumed.items.len(), 1);
    assert_eq!(resumed.items[0].recipient, recipient);
    assert_eq!(resumed.items[0].attempts, 0, "aucun essai compté");
    let stale = bench
        .system
        .queue_complete(QueueCompleteParams {
            claim: crashed.claim.expect("jeton"),
            items: vec![DeliveredItem {
                recipient: recipient.to_sql(),
                outcome: QueueOutcome::Relayed,
                host: None,
                code: None,
                enhanced: None,
                tls: None,
                at: None,
            }],
        })
        .await
        .map_err(lyxal_mail::MailError::from);
    let error = stale.expect_err("jeton périmé refusé");
    assert_eq!(error.code(), "MAIL_QUEUE_CLAIM_LOST");
    assert!(error.is_retryable(), "le worker relit la file");
}

#[tokio::test]
async fn dkim_keys_are_listed_for_publication_and_served_once_active() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    let created = bench
        .system
        .dkim_key_create(DkimKeyCreateParams {
            domain: domain.clone(),
            selector: "lyx202611e".into(),
            algorithm: DkimAlgorithm::Ed25519Sha256,
            bits: None,
            public_key: "MCowBQYDK2VwAyEA11qYAYKxCrfVS/7TyWQHOg7hcvPapiMlrwIaaPcHURo=".into(),
            secret_path: "mail/dkim/alpha.test/lyx202611e".into(),
        })
        .await
        .expect("fiche publique");
    assert_eq!(created.state, DkimKeyState::Pending);
    assert_eq!(created.algorithm, DkimAlgorithm::Ed25519Sha256);
    let signers = DkimSignersParams {
        domains: vec!["alpha.test".into()],
    };
    assert!(bench
        .system
        .dkim_signers(signers.clone())
        .await
        .expect("signataires")
        .items
        .is_empty());
    let active = bench
        .system
        .dkim_key_activate(DkimKeyActivateParams {
            key: created.id.to_sql(),
        })
        .await
        .expect("activation");
    assert_eq!(active.state, DkimKeyState::Active);
    let served = bench
        .system
        .dkim_signers(signers)
        .await
        .expect("signataires");
    assert_eq!(served.items.len(), 1);
    assert_eq!(
        served.items[0].secret_path,
        "mail/dkim/alpha.test/lyx202611e"
    );
    let listed = bench
        .system
        .dkim_key_list(DkimKeyListParams { domain })
        .await
        .expect("enregistrements");
    assert_eq!(listed.items[0].dns_name, "lyx202611e._domainkey.alpha.test");
    assert!(listed.items[0]
        .dns_value
        .starts_with("v=DKIM1; k=ed25519; p="));
}

/// Appelant d'un autre module : un client SurrealDB et les fonctions SurrealQL par leur nom.
struct ModuleCaller(Surreal<Any>);

impl LyxalSurrealCall for ModuleCaller {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.0
    }
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractRecipient {
    address: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractBegin {
    origin: String,
    from: String,
    header_from: Vec<String>,
    recipients: Vec<ContractRecipient>,
    size: i64,
    client_reference: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractReservation {
    submission: RecordId,
    bucket_name: String,
    key: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractCommit {
    submission: String,
    object: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractQueued {
    recipients: i64,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractRef {
    submission: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractRecipientState {
    state: String,
}

#[derive(Debug, Clone, SurrealValue)]
struct ContractSubmission {
    state: String,
    client_reference: Option<String>,
    recipients: Vec<ContractRecipientState>,
}

#[tokio::test]
async fn a_module_submits_through_the_public_contract_without_mail_types() {
    let bench = bench().await;
    let domain = bench.domain("alpha").await;
    bench
        .system
        .domain_update(DomainUpdateParams {
            domain,
            module_senders: Some(vec!["noreply".into()]),
            ..DomainUpdateParams::default()
        })
        .await
        .expect("expéditeur des modules");
    let bucket = mail_bucket(&bench).await;

    // Session système de l'hôte du module : deux fonctions SurrealQL et une écriture par lyxal_storage
    let module = ModuleCaller(bench.client.clone());
    let reserved: ContractReservation = module
        .call_fn(
            "mail_submission_begin",
            ContractBegin {
                origin: "module".into(),
                from: "noreply@alpha.test".into(),
                header_from: vec!["noreply@alpha.test".into()],
                recipients: vec![ContractRecipient {
                    address: "client@ailleurs.test".into(),
                }],
                size: MESSAGE.len() as i64,
                client_reference: "notification_job_7".into(),
            },
        )
        .await
        .expect("dépôt d'un module");
    assert_eq!(reserved.bucket_name, "lyxal-mail");
    let object = write_file(&bench, &bucket, &reserved.key, MESSAGE.as_bytes()).await;
    let queued: ContractQueued = module
        .call_fn(
            "mail_submission_commit",
            ContractCommit {
                submission: reserved.submission.to_sql(),
                object,
            },
        )
        .await
        .expect("mise en file");
    assert_eq!(queued.recipients, 1);
    let read: ContractSubmission = module
        .call_fn(
            "mail_submission_get",
            ContractRef {
                submission: reserved.submission.to_sql(),
            },
        )
        .await
        .expect("issue");
    assert_eq!(read.state, "queued");
    assert_eq!(read.client_reference.as_deref(), Some("notification_job_7"));
    assert_eq!(read.recipients[0].state, "scheduled");
}
