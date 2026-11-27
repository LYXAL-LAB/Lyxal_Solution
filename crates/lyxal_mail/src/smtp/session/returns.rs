// SPDX-License-Identifier: AGPL-3.0-only

//! Adresses de retour et transferts à la réception du port 25 (plan du lot 6, §10.3, §11, §13 ;
//! décisions E21, E23, E25).
//!
//! * `RCPT TO:<rp=<jeton>@<domaine>>` : adresse de retour d'un envoi, acceptée seulement si le
//!   jeton est connu et non échu (`fn::mail_recipient_resolve`, sinon `550 5.1.1`) ; le message
//!   est lu par [`BounceProcessor`] après la remise aux boîtes ordinaires de la transaction,
//!   jamais réexpédié vers l'extérieur ;
//! * alias à cibles extérieures (`forward_to`) : après la remise aux comptes de l'alias, un envoi
//!   d'origine `forward` est mis en file (contenu tel que rangé, sans `Return-Path`, adresse de
//!   retour à jeton tiré par `OsRng`, adresse d'enveloppe d'origine et résultats SPF et DKIM de
//!   la réception gardés pour l'avis, §10.2) ; limite des transferts de l'organisation atteinte :
//!   transfert non fait, compté et signalé par la sonde ;
//! * la réponse `250` n'est donnée qu'après la remise, l'inscription des avis et la mise en file
//!   des transferts ; une panne de l'une de ces étapes : `451`, l'expéditeur réessaie (remises et
//!   avis rejouables par l'idempotence).

use lyxal_mail_proto::mime::{AddressEntry, ParsedMessage};

use super::*;
use crate::auth::OrganizationalDomain;
use crate::dkim::ReturnToken;
use crate::dsn::{BounceProcessor, ReturnTarget};
use crate::models::{ForwardReception, SubmissionBeginParams, SubmissionOrigin};
use crate::smtp::metrics::ForwardResult;

/// Destinataire ordinaire qui transfère aussi le message vers l'extérieur.
#[derive(Debug, Clone)]
pub(super) struct ForwardTarget {
    /// Alias (adresse inscrite qui a servi).
    pub(super) alias: String,
    /// Adresses extérieures (1 à 10).
    pub(super) to: Vec<String>,
}

/// Contrôles de la réception utiles au transfert (avis à l'expéditeur d'origine, §10.2).
pub(super) struct Authenticity<'a> {
    pub(super) spf: &'a SpfOutput,
    pub(super) dkim: &'a [DkimOutput],
}

/// Vrai si une signature DKIM valide porte le domaine de l'adresse d'enveloppe `sender` ou son
/// domaine d'organisation (§10.2) : un `From` aligné ne prouve rien sur l'enveloppe.
pub(super) fn envelope_dkim(
    sender: &str,
    dkim: &[DkimOutput],
    organizational: &dyn OrganizationalDomain,
) -> bool {
    let Some(domain) = sender
        .rsplit_once('@')
        .and_then(|(_, domain)| to_ascii_domain(domain))
    else {
        return false;
    };
    let organization = organizational.organizational_domain(&domain);
    dkim.iter()
        .filter(|output| output.result == DkimResult::Pass && !output.testing)
        .filter_map(|output| output.domain.as_deref())
        .any(|signer| signer == domain || organization.as_deref() == Some(signer))
}

/// Adresses d'auteur du message (`From`), 10 au plus, pour la fiche du transfert.
fn author_addresses(parsed: &ParsedMessage) -> Vec<String> {
    parsed
        .envelope
        .from
        .iter()
        .flat_map(|entry| match entry {
            AddressEntry::Mailbox(address) => std::slice::from_ref(address).iter(),
            AddressEntry::Group { members, .. } => members.iter(),
        })
        .filter_map(|address| address.address.clone())
        .filter(|address| address.is_ascii() && address.contains('@') && address.len() <= 254)
        .take(10)
        .collect()
}

impl SmtpSession {
    /// `RCPT TO` d'une adresse de retour valide.
    pub(super) async fn accept_return(
        &mut self,
        resolved: ResolvedRecipient,
        declared: Option<u64>,
    ) -> Flow {
        let (Some(submission), Some(origin)) = (resolved.submission.clone(), resolved.origin)
        else {
            return self.refuse_recipient(RefusedReason::Unknown).await;
        };
        let max = u64::try_from(resolved.max_message_bytes).unwrap_or(0);
        if declared.is_some_and(|size| size > max) {
            self.io.reply(
                552,
                "5.3.4",
                "Message size exceeds the recipient's maximum message size",
            );
            self.shared.metrics.recipient_refused(RefusedReason::Size);
            return Flow::Continue;
        }
        let Some(transaction) = self.transaction.as_mut() else {
            return Flow::Continue;
        };
        if !transaction
            .returns
            .iter()
            .any(|known| known.address == resolved.address)
        {
            transaction.max_bytes = transaction.max_bytes.min(max);
            transaction.returns.push(ReturnTarget {
                address: resolved.address,
                tenant: resolved.tenant,
                submission,
                origin,
                account: resolved.account,
            });
        }
        transaction.accepted += 1;
        self.shared.metrics.recipient_accepted();
        self.io.reply(250, "2.1.5", "Recipient OK");
        Flow::Continue
    }

    /// Après la remise aux boîtes ordinaires : avis reçus sur les adresses de retour, puis
    /// transferts. `Some(flow)` quand le message est refusé (réponse écrite).
    pub(super) async fn after_delivery(
        &mut self,
        transaction: &Transaction,
        message: &ReceivedMessage,
        parsed: &ParsedMessage,
        checks: Authenticity<'_>,
        log: &TransactionLog,
    ) -> Option<Flow> {
        let inbound = self.inbound()?;
        let (pipeline, organizational) = (inbound.pipeline.clone(), inbound.organizational.clone());
        let bounces = BounceProcessor::new(self.shared.store.clone(), pipeline.clone());
        for target in &transaction.returns {
            match bounces.process(target, message, parsed).await {
                Ok(outcome) if outcome.infected => {
                    self.io
                        .reply(554, "5.7.1", "Message rejected: virus detected");
                    self.shared.metrics.refused(RefusedReason::Antivirus);
                    log.emit("infected", 554);
                    return Some(Flow::Continue);
                }
                Ok(outcome) => self.shared.metrics.returned(&outcome),
                Err(error) => {
                    tracing::warn!(code = %error.code(), "avis reçu non inscrit : refus temporaire");
                    return Some(self.temporary(log));
                }
            }
        }
        if transaction.forwards.is_empty() {
            return None;
        }
        // Contenu tel que rangé, sans notre `Return-Path` (posé par la remise finale)
        let content = match message.stored.iter().position(|byte| *byte == b'\n') {
            Some(end) if message.stored.starts_with(b"Return-Path:") => {
                message.stored.slice(end + 1..)
            }
            _ => message.stored.clone(),
        };
        let reception = ForwardReception {
            envelope_from: (!transaction.sender.is_empty()).then(|| transaction.sender.clone()),
            spf: if checks.spf.identity == SpfIdentity::MailFrom {
                checks.spf.result.as_str()
            } else {
                "none"
            }
            .to_string(),
            envelope_dkim: envelope_dkim(&transaction.sender, checks.dkim, organizational.as_ref()),
        };
        let authors = author_addresses(parsed);
        let eight_bit = content.iter().any(|byte| *byte >= 0x80);
        let ingest = pipeline.ingest();
        for forward in &transaction.forwards {
            let token = match ReturnToken::generate() {
                Ok(token) => token,
                Err(error) => {
                    tracing::warn!(code = %error.code(), "jeton de retour d'un transfert non tiré : refus temporaire");
                    return Some(self.temporary(log));
                }
            };
            let params = SubmissionBeginParams {
                origin: Some(SubmissionOrigin::Forward),
                from: forward.alias.clone(),
                header_from: if authors.is_empty() {
                    vec![forward.alias.clone()]
                } else {
                    authors.clone()
                },
                recipients: forward
                    .to
                    .iter()
                    .map(|address| SubmissionRecipient {
                        address: address.clone(),
                        notify: None,
                        orcpt: None,
                    })
                    .collect(),
                size: i64::try_from(content.len()).unwrap_or(i64::MAX),
                smtputf8: Some(transaction.smtputf8),
                eight_bit: Some(eight_bit),
                dsn: None,
                client_reference: None,
                return_token: Some(token.as_str().to_string()),
                prefix: None,
                forward: Some(reception.clone()),
                tenant: None,
            };
            match ingest
                .queue_submission(&self.shared.store, params, content.clone())
                .await
            {
                Ok(_) => self.shared.metrics.forwarded(ForwardResult::Queued),
                Err(error) if error.is_business() && error.code() == "MAIL_SEND_LIMIT_EXCEEDED" => {
                    self.shared.metrics.forwarded(ForwardResult::Limited);
                    tracing::warn!(session = %self.session_label(), "limite des transferts de l'organisation atteinte : message remis aux comptes de l'alias seulement");
                }
                Err(error) if error.is_business() => {
                    self.shared.metrics.forwarded(ForwardResult::Refused);
                    tracing::warn!(session = %self.session_label(), code = %error.code(), "transfert refusé par la file : message remis aux comptes de l'alias seulement");
                }
                Err(error) => {
                    tracing::warn!(code = %error.code(), "transfert non mis en file : refus temporaire");
                    return Some(self.temporary(log));
                }
            }
        }
        None
    }

    fn temporary(&mut self, log: &TransactionLog) -> Flow {
        self.io
            .reply(451, "4.3.0", "Temporary failure, try again later");
        self.shared.metrics.refused(RefusedReason::Temporary);
        log.emit("temporary", 451);
        Flow::Continue
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::auth::EmbeddedSuffixList;

    fn signature(result: DkimResult, domain: &str) -> DkimOutput {
        DkimOutput {
            result,
            domain: Some(domain.to_string()),
            selector: None,
            signature_prefix: None,
            testing: false,
        }
    }

    #[test]
    fn only_a_valid_signature_of_the_envelope_domain_counts() {
        let psl = EmbeddedSuffixList;
        let sender = "bounce@mail.ailleurs.com";
        assert!(envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "mail.ailleurs.com")],
            &psl
        ));
        assert!(envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "ailleurs.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            sender,
            &[signature(DkimResult::Fail, "ailleurs.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            sender,
            &[signature(DkimResult::Pass, "autre.com")],
            &psl
        ));
        assert!(!envelope_dkim(
            "",
            &[signature(DkimResult::Pass, "ailleurs.com")],
            &psl
        ));
        let mut testing = signature(DkimResult::Pass, "ailleurs.com");
        testing.testing = true;
        assert!(!envelope_dkim(sender, &[testing], &psl));
    }
}
