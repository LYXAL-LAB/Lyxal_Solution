// SPDX-License-Identifier: AGPL-3.0-only

//! Avis reçus sur une adresse de retour `rp=<jeton>@<domaine>` (plan du lot 6, §10.3 et §11 ;
//! décision E23).
//!
//! Un message arrivé pour une adresse de retour valide (port 25, ou route locale) passe la
//! réception du lot 5 (SPF, DKIM, DMARC) puis l'antivirus, une seule fois pour toute la
//! transaction (chemin de réception commun, [`crate::delivery::Reception`]) ; infecté ou antivirus
//! injoignable : rien n'est inscrit. Puis [`BounceProcessor::process`] :
//!
//! * rapport `delivery-status` (lu par `lyxal_mail_proto::dsn::parse_dsn`) : ses destinataires
//!   sont inscrits par `fn::mail_return_record`, qui passe à `bounced` chaque destinataire de
//!   l'envoi remis ou relayé dont l'avis dit l'échec (rejet après acceptation, événement
//!   `mail.submission.bounced`) et compte les autres ; inscription rejouable (un nouvel essai de
//!   l'expéditeur ne change rien) ;
//! * envoi d'un dépôt authentifié : le message (avis, ou réponse automatique qui vise le
//!   `Return-Path`, RFC 3834) est remis dans la boîte de réception du compte expéditeur par la
//!   chaîne de remise (idempotence du lot 5) ; compte désactivé ou supprimé : écarté ;
//! * envoi d'un module, d'un transfert ou d'un avis : accepté puis écarté (aucune boîte où
//!   aller), compté par l'appelant.
//!
//! Une adresse de retour n'est jamais réexpédiée vers l'extérieur (aucun relais).

use lyxal_mail_proto::dsn::{parse_dsn, DsnAction as ProtoAction, DsnParseError};
use lyxal_mail_proto::mime::ParsedMessage;
use lyxal_surreal::ToSql;

use crate::delivery::{
    DeliveryPipeline, PipelineResult, ReceivedMessage, RecipientTarget, Screened,
};
use crate::error::{MailError, MailResult};
use crate::models::{MailRecordId, ReturnAction, ReturnItem, ReturnRecordParams, SubmissionOrigin};
use crate::store::MailStore;

/// Longueur maximale d'une adresse transmise à `fn::mail_return_record`.
const MAX_ADDRESS: usize = 254;
/// Longueur maximale d'un `Diagnostic-Code` gardé (octets, coupé sur un caractère).
const MAX_DIAGNOSTIC: usize = 512;
/// Éléments d'un appel de `fn::mail_return_record`.
const RECORD_BATCH: usize = 100;

/// Adresse de retour acceptée à `RCPT TO` (rendue par `fn::mail_recipient_resolve`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReturnTarget {
    /// Adresse de retour (`rp=<jeton>@<domaine>`).
    pub address: String,
    /// Organisation de l'envoi.
    pub tenant: MailRecordId,
    /// Envoi auquel elle appartient.
    pub submission: MailRecordId,
    /// Origine de l'envoi.
    pub origin: SubmissionOrigin,
    /// Compte expéditeur d'un dépôt authentifié.
    pub account: Option<MailRecordId>,
}

/// Issue du traitement d'un message reçu sur une adresse de retour.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct ReturnOutcome {
    /// Le message est un rapport `delivery-status` (lisible ou non).
    pub report: bool,
    /// Destinataires de l'envoi passés à `bounced`.
    pub bounced: u64,
    /// Éléments de l'avis seulement comptés (retard, remise, échec d'un destinataire non remis).
    pub counted: u64,
    /// Message remis dans la boîte du compte expéditeur.
    pub delivered: bool,
}

/// Lecture des avis reçus et remise à l'expéditeur d'un dépôt authentifié.
#[derive(Clone)]
pub struct BounceProcessor {
    store: MailStore,
    pipeline: DeliveryPipeline,
}

/// Texte coupé à `max` octets, sur une limite de caractère.
fn cut(text: &str, max: usize) -> String {
    let mut end = text.len().min(max);
    while !text.is_char_boundary(end) {
        end -= 1;
    }
    text[..end].to_string()
}

fn action(action: ProtoAction) -> ReturnAction {
    match action {
        ProtoAction::Failed => ReturnAction::Failed,
        ProtoAction::Delayed => ReturnAction::Delayed,
        ProtoAction::Delivered => ReturnAction::Delivered,
        ProtoAction::Relayed => ReturnAction::Relayed,
        ProtoAction::Expanded => ReturnAction::Expanded,
    }
}

/// Vrai si le message contient un rapport `delivery-status`, lisible ou non (règle contre la
/// rétrodiffusion, §11).
pub(crate) fn is_delivery_report(raw: &[u8], parsed: &ParsedMessage) -> bool {
    !matches!(parse_dsn(raw, parsed), Err(DsnParseError::NotAReport))
}

impl BounceProcessor {
    /// Inscription sur la session système de l'hôte (`store`), remise par `pipeline`.
    pub fn new(store: MailStore, pipeline: DeliveryPipeline) -> Self {
        Self { store, pipeline }
    }

    /// Traite `message` (reçu, `parsed` : sa lecture MIME), déjà admis par la chaîne
    /// (`screened` : antivirus passé), pour l'adresse de retour `target`. Une erreur est
    /// temporaire : la session répond `451` et l'expéditeur réessaie (inscription et remise
    /// rejouables).
    pub async fn process(
        &self,
        target: &ReturnTarget,
        message: &ReceivedMessage,
        parsed: &ParsedMessage,
        screened: &Screened,
    ) -> MailResult<ReturnOutcome> {
        let mut outcome = ReturnOutcome::default();
        match parse_dsn(&message.received, parsed) {
            Ok(report) => {
                outcome.report = true;
                let items: Vec<ReturnItem> = report
                    .recipients
                    .iter()
                    .filter(|recipient| {
                        !recipient.final_recipient.address.is_empty()
                            && recipient.final_recipient.address.len() <= MAX_ADDRESS
                    })
                    .map(|recipient| ReturnItem {
                        final_recipient: recipient.final_recipient.address.clone(),
                        original_recipient: recipient
                            .original_recipient
                            .as_ref()
                            .map(|original| original.address.clone())
                            .filter(|address| !address.is_empty() && address.len() <= MAX_ADDRESS),
                        action: action(recipient.action),
                        status: Some(recipient.status.to_string()),
                        diagnostic: recipient
                            .diagnostic
                            .as_ref()
                            .map(|diagnostic| {
                                cut(
                                    &format!("{}; {}", diagnostic.diagnostic_type, diagnostic.text),
                                    MAX_DIAGNOSTIC,
                                )
                            })
                            .filter(|text| !text.is_empty()),
                    })
                    .collect();
                let unread = report.recipients.len() - items.len() + report.ignored_recipients;
                outcome.counted = u64::try_from(unread).unwrap_or(0);
                for batch in items.chunks(RECORD_BATCH) {
                    let recorded = self
                        .store
                        .return_record(ReturnRecordParams {
                            submission: target.submission.to_sql(),
                            items: batch.to_vec(),
                        })
                        .await?;
                    outcome.bounced += u64::try_from(recorded.bounced).unwrap_or(0);
                    outcome.counted += u64::try_from(recorded.ignored).unwrap_or(0);
                }
            }
            Err(DsnParseError::NotAReport) => {}
            // Rapport illisible : rien n'est inscrit ; il reste remis à l'expéditeur
            Err(error) => {
                outcome.report = true;
                tracing::info!(%error, "avis reçu illisible : aucun destinataire inscrit");
            }
        }
        let (SubmissionOrigin::Submission, Some(account)) = (target.origin, &target.account) else {
            return Ok(outcome);
        };
        let deposit = ReceivedMessage {
            recipients: vec![RecipientTarget {
                address: target.address.clone(),
                tenant: target.tenant.clone(),
                accounts: vec![account.clone()],
            }],
            ..message.clone()
        };
        match self.pipeline.deposit(&deposit, screened).await {
            PipelineResult::Delivered { .. } => outcome.delivered = true,
            // Jamais rendu par un dépôt après la chaîne
            PipelineResult::Rejected { .. } => {}
            // Compte expéditeur désactivé ou supprimé, message trop grand pour son organisation :
            // rien à remettre, le message est écarté
            PipelineResult::TempFail { code, .. }
                if code.starts_with("MAIL_ACCOUNT")
                    || code == "MAIL_RECIPIENT_DISABLED"
                    || code == "MAIL_MESSAGE_TOO_LARGE" => {}
            PipelineResult::TempFail { code, .. } => {
                return Err(MailError::Refused {
                    code,
                    retryable: true,
                })
            }
        }
        Ok(outcome)
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use lyxal_mail_proto::mime::{parse, MimeLimits};

    #[test]
    fn a_delivery_report_is_recognised_even_when_unreadable() {
        let report = b"From: MAILER-DAEMON@ailleurs.test\r\nTo: <rp=x@alpha.test>\r\nSubject: Undelivered\r\nMIME-Version: 1.0\r\nContent-Type: multipart/report; report-type=delivery-status; boundary=\"b\"\r\n\r\n--b\r\nContent-Type: text/plain\r\n\r\nEchec\r\n--b\r\nContent-Type: message/delivery-status\r\n\r\nReporting-MTA: dns; mx.ailleurs.test\r\n\r\n--b--\r\n";
        let parsed = parse(report, &MimeLimits::default()).unwrap();
        assert!(is_delivery_report(report, &parsed));
        let plain = b"From: a@ailleurs.test\r\nSubject: Absent\r\n\r\nJe suis absent.\r\n";
        let parsed = parse(plain, &MimeLimits::default()).unwrap();
        assert!(!is_delivery_report(plain, &parsed));
    }

    #[test]
    fn texts_are_cut_on_a_character_boundary() {
        assert_eq!(cut("abc", 2), "ab");
        assert_eq!(cut("éé", 3), "é");
        assert_eq!(cut("abc", 10), "abc");
    }
}
