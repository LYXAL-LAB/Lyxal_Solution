// SPDX-License-Identifier: AGPL-3.0-only

//! Avis de non-remise produits par le worker d'envoi (plan du lot 6, §10.1, §10.2 ; décision
//! E22).
//!
//! `fn::mail_queue_complete`, `_fail` et `_prepare` rendent les avis dus (`dsn`), une fois par
//! destinataire (`fn::mail_queue_dsn_wanted` : `NOTIFY`, origine, avis déjà produit). Le
//! [`DsnComposer`] écrit l'avis (`lyxal_mail_proto::dsn::DsnBuilder` : texte lisible, partie
//! `delivery-status`, en-têtes du message ou message entier pour `RET=FULL`) et :
//!
//! * envoi d'un dépôt authentifié (`submission`) : le **dépose dans la boîte de réception du
//!   compte expéditeur** par la chaîne de remise du lot 5 (expéditeur
//!   `MAILER-DAEMON@<smtp.hostname>`), jamais sur Internet ; compte sans boîte (désactivé,
//!   supprimé) : aucun avis, compté ;
//! * envoi d'un module : aucun avis (les événements `mail.submission.*` suffisent) ;
//! * transfert (`forward`, sous-lot 6f) : avis renvoyé à l'expéditeur d'origine authentifié par
//!   la file ; produit par le transfert lui-même au sous-lot 6f.
//!
//! L'avis est déterministe (identifiant, date, frontière) : une remise reprise après un arrêt
//! est reconnue par l'empreinte d'idempotence du lot 5 et ne fait pas de doublon. Puis
//! `fn::mail_queue_dsn_done` le note : jamais produit deux fois.

use bytes::Bytes;
use lyxal_mail_proto::dsn::{
    DsnAction as ProtoAction, DsnAddress, DsnBuilder, DsnDiagnostic, DsnRecipient,
};
use lyxal_mail_proto::smtp::{DsnRet, EnhancedStatus, Mailbox};
use lyxal_storage::StorageService;
use lyxal_surreal::ToSql;
use time::OffsetDateTime;

use crate::auth::MessageHeaders;
use crate::delivery::{DeliveryPipeline, PipelineResult, ReceivedMessage, RecipientTarget};
use crate::error::{MailError, MailResult};
use crate::models::{
    DsnAction, DsnDoneParams, DsnDue, DsnReturn, MailDatetime, QueuedRecipient, SubmissionOrigin,
    SubmissionRefParams,
};
use crate::outbound::content;
use crate::store::MailStore;

/// En-têtes ou message joints au plus (`lyxal_mail_proto::dsn::MAX_RETURNED_BYTES`).
const MAX_ATTACHED: usize = lyxal_mail_proto::dsn::MAX_RETURNED_BYTES;

/// Issue d'un avis.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DsnOutcome {
    /// Avis déposé.
    Delivered,
    /// Aucun avis (module, compte sans boîte, expéditeur vide) ; noté comme produit.
    Suppressed,
    /// Avis d'un transfert : produit par le sous-lot 6f.
    Deferred,
}

/// Écriture et dépôt des avis de non-remise.
#[derive(Clone)]
pub struct DsnComposer {
    store: MailStore,
    storage: StorageService,
    pipeline: DeliveryPipeline,
    hostname: String,
}

fn offset(datetime: &MailDatetime) -> Option<OffsetDateTime> {
    OffsetDateTime::from_unix_timestamp(datetime.timestamp()).ok()
}

impl DsnComposer {
    /// Avis sur la session système (`store`, `storage`), déposés par la chaîne de remise
    /// `pipeline`, au nom de `hostname` (`smtp.hostname`).
    pub fn new(
        store: MailStore,
        storage: StorageService,
        pipeline: DeliveryPipeline,
        hostname: impl Into<String>,
    ) -> Self {
        Self {
            store,
            storage,
            pipeline,
            hostname: hostname.into(),
        }
    }

    /// Produit l'avis `due` d'un envoi dont le fichier est `object`, puis le note.
    pub async fn produce(&self, due: &DsnDue, object: Option<&str>) -> MailResult<DsnOutcome> {
        let submission = self
            .store
            .submission_get(SubmissionRefParams {
                submission: due.submission.to_sql(),
            })
            .await?;
        let outcome = match (submission.origin, &submission.account, &submission.sender) {
            (SubmissionOrigin::Forward, _, _) => return Ok(DsnOutcome::Deferred),
            (SubmissionOrigin::Submission, Some(account), Some(sender)) => {
                let recipients: Vec<&QueuedRecipient> = submission
                    .recipients
                    .iter()
                    .filter(|recipient| due.recipients.contains(&recipient.recipient))
                    .collect();
                let bytes = self
                    .compose(due, &submission, &recipients, sender, object)
                    .await?;
                let target = RecipientTarget {
                    address: sender.clone(),
                    tenant: submission.tenant.clone(),
                    accounts: vec![account.clone()],
                };
                match self.deposit(bytes, target).await? {
                    true => DsnOutcome::Delivered,
                    false => DsnOutcome::Suppressed,
                }
            }
            _ => DsnOutcome::Suppressed,
        };
        let marked: Vec<String> = due.recipients.iter().map(|r| r.to_sql()).collect();
        for batch in marked.chunks(1_000) {
            self.store
                .queue_dsn_done(DsnDoneParams {
                    submission: due.submission.to_sql(),
                    action: due.action,
                    recipients: batch.to_vec(),
                })
                .await?;
        }
        Ok(outcome)
    }

    async fn compose(
        &self,
        due: &DsnDue,
        submission: &crate::models::Submission,
        recipients: &[&QueuedRecipient],
        sender: &str,
        object: Option<&str>,
    ) -> MailResult<Vec<u8>> {
        let invalid = || MailError::Unavailable("avis de non-remise impossible à écrire".into());
        let action = match due.action {
            DsnAction::Failed => ProtoAction::Failed,
            DsnAction::Delayed => ProtoAction::Delayed,
            DsnAction::Delivered => ProtoAction::Delivered,
            DsnAction::Relayed => ProtoAction::Relayed,
        };
        let fields: Vec<DsnRecipient> = recipients
            .iter()
            .filter_map(|recipient| {
                let result = recipient.last_result.as_ref();
                let status = result
                    .and_then(|r| r.enhanced.as_deref())
                    .and_then(EnhancedStatus::parse)
                    .or(match action {
                        ProtoAction::Failed => EnhancedStatus::new(5, 0, 0),
                        ProtoAction::Delayed => EnhancedStatus::new(4, 0, 0),
                        _ => EnhancedStatus::new(2, 0, 0),
                    })?;
                let diagnostic = result.and_then(|r| {
                    r.code.map(|code| {
                        let mut text = code.to_string();
                        if let Some(enhanced) = &r.enhanced {
                            text.push(' ');
                            text.push_str(enhanced);
                        }
                        if let Some(remote) = &r.text {
                            text.push(' ');
                            text.push_str(remote);
                        }
                        DsnDiagnostic::smtp(text)
                    })
                });
                Some(DsnRecipient {
                    original_recipient: None,
                    final_recipient: DsnAddress {
                        address_type: if recipient.address.is_ascii() {
                            "rfc822"
                        } else {
                            "utf-8"
                        }
                        .to_string(),
                        address: recipient.address.clone(),
                    },
                    action,
                    status,
                    remote_mta: result.and_then(|r| r.host.clone()),
                    diagnostic,
                    last_attempt_date: result.and_then(|r| r.at.as_ref()).and_then(offset),
                    will_retry_until: (action == ProtoAction::Delayed)
                        .then(|| offset(&submission.expires_at))
                        .flatten(),
                })
            })
            .collect();
        // Message joint : en-têtes (RET=HDRS), ou message entier jusqu'à 256 Kio (RET=FULL)
        let ret = match submission.dsn.ret {
            DsnReturn::Full => DsnRet::Full,
            DsnReturn::Hdrs => DsnRet::Headers,
        };
        let original = match object {
            Some(object) => {
                let mut stream = content::open(&self.storage, object).await?;
                let head = content::read_head(&mut stream, MAX_ATTACHED).await?;
                let mut bytes = head.header;
                if ret == DsnRet::Full && head.complete {
                    bytes.extend_from_slice(&head.body_start);
                    while bytes.len() <= MAX_ATTACHED {
                        match futures::StreamExt::next(&mut stream).await {
                            Some(chunk) => bytes.extend_from_slice(&chunk?),
                            None => break,
                        }
                    }
                }
                bytes
            }
            None => Vec::new(),
        };
        let original_id = MessageHeaders::parse(&original).ok().and_then(|headers| {
            headers
                .fields
                .iter()
                .find(|field| field.is("Message-ID"))
                .map(|field| {
                    String::from_utf8_lossy(field.value)
                        .trim()
                        .trim_start_matches('<')
                        .trim_end_matches('>')
                        .to_string()
                })
        });
        // Avis déterministe : même identifiant, même date, mêmes octets à chaque reprise
        let mut seed = format!("{}|{}", due.submission.to_sql(), action.name());
        for recipient in &due.recipients {
            seed.push('|');
            seed.push_str(&recipient.to_sql());
        }
        let message_id = format!(
            "dsn.{}@{}",
            &lyxal_crypto::blake3_hex(seed.as_bytes())[..32],
            self.hostname
        );
        let date = recipients
            .iter()
            .filter_map(|r| {
                r.final_at
                    .as_ref()
                    .or(r.delayed_at.as_ref())
                    .or(r.last_result.as_ref().and_then(|l| l.at.as_ref()))
            })
            .filter_map(offset)
            .max()
            .or_else(|| offset(&submission.created_at))
            .ok_or_else(invalid)?;
        let from =
            Mailbox::parse(&format!("MAILER-DAEMON@{}", self.hostname)).ok_or_else(invalid)?;
        let to = Mailbox::parse(sender).ok_or_else(invalid)?;
        let builder = DsnBuilder {
            reporting_mta: &self.hostname,
            from: &from,
            to: &to,
            message_id: &message_id,
            date,
            original_message_id: original_id.as_deref().filter(|id| !id.is_empty()),
            international: submission.smtputf8,
            original_envelope_id: submission.dsn.envid.as_deref(),
            arrival_date: offset(&submission.created_at).ok_or_else(invalid)?,
            recipients: &fields,
            ret,
            original: &original,
        };
        builder.build().map_err(|error| {
            tracing::warn!(%error, "avis de non-remise impossible à écrire");
            invalid()
        })
    }

    /// Dépôt dans la boîte du compte expéditeur ; faux si le compte n'a plus de boîte (aucun
    /// avis, compté).
    async fn deposit(&self, bytes: Vec<u8>, target: RecipientTarget) -> MailResult<bool> {
        let bytes = Bytes::from(bytes);
        let message = ReceivedMessage {
            received: bytes.clone(),
            stored: bytes,
            sender: String::new(),
            recipients: vec![target],
            authentication: ["none".into(), "none".into(), "none".into(), "none".into()],
            quarantine: false,
            tls: true,
            received_at: MailDatetime::now(),
        };
        match self.pipeline.deliver(&message).await {
            PipelineResult::Delivered { .. } => Ok(true),
            PipelineResult::Rejected { .. } => Ok(false),
            PipelineResult::TempFail { code, .. }
                if code.starts_with("MAIL_ACCOUNT") || code == "MAIL_RECIPIENT_DISABLED" =>
            {
                Ok(false)
            }
            PipelineResult::TempFail { code, .. } => Err(MailError::Refused {
                code,
                retryable: true,
            }),
        }
    }
}
