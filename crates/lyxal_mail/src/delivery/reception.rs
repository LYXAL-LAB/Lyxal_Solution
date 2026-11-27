// SPDX-License-Identifier: AGPL-3.0-only

//! Chemin de réception commun du port 25 et de la route locale (plan du lot 6, §7, §10.3, §13 ;
//! décisions E23, E24, E25).
//!
//! [`Reception::receive`] fait, dans cet ordre et pour toute la transaction :
//!
//! 1. **une seule analyse** par la chaîne de remise ([`DeliveryPipeline::screen`]) : infecté →
//!    refus définitif ; antivirus configuré mais injoignable → refus temporaire (comme la
//!    réception du lot 5) ; dans les deux cas **rien n'est inscrit ni remis**, ni aux comptes, ni
//!    sur les adresses de retour, ni vers l'extérieur ;
//! 2. la remise aux comptes des destinataires ordinaires (idempotence du lot 5) ;
//! 3. les avis reçus sur les adresses de retour `rp=` ([`BounceProcessor`]) ;
//! 4. les transferts des alias à cibles extérieures (`forward_to`) : un envoi d'origine `forward`
//!    par alias, mis en file (contenu tel que rangé, sans `Return-Path`, adresse de retour à jeton
//!    tiré par `OsRng`, réception d'origine gardée pour l'avis, §10.2) ; limite des transferts de
//!    l'organisation atteinte : transfert non fait, compté et signalé par la sonde.
//!
//! **Identité d'un transfert** : la clé d'idempotence de l'envoi est l'empreinte de remise du
//! lot 5 ([`delivery_key`] : alias, expéditeur de l'enveloppe, octets reçus). Un nouvel essai de
//! l'expéditeur après un refus temporaire, ou une remise reprise par la route locale, retrouve
//! l'envoi déjà mis en file (`fn::mail_submission_begin`) : aucun second envoi, aucune limite
//! prise une seconde fois ; un dépôt resté `pending` (essai interrompu) est abandonné et refait.
//!
//! Toute panne d'une étape rend un refus temporaire : le port 25 répond `451`, la route locale
//! réessaie, et chaque étape est rejouable sans doublon.

use bytes::Bytes;
use lyxal_mail_proto::mime::{AddressEntry, ParsedMessage};

use crate::delivery::{
    delivery_key, AccountOutcome, DeliveryPipeline, PipelineResult, ReceivedMessage, RejectReason,
    Screening,
};
use crate::dkim::ReturnToken;
use crate::dsn::{BounceProcessor, ReturnOutcome, ReturnTarget};
use crate::models::{
    ForwardReception, SubmissionBeginParams, SubmissionOrigin, SubmissionRecipient,
};
use crate::store::MailStore;

/// Destinataire ordinaire qui transfère aussi le message vers l'extérieur.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ForwardTarget {
    /// Alias (adresse inscrite qui a servi).
    pub alias: String,
    /// Adresses extérieures (1 à 10).
    pub to: Vec<String>,
}

/// Issue d'un transfert vers l'extérieur.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ForwardResult {
    /// Mis en file (ou déjà mis en file par un essai précédent).
    Queued,
    /// Limite des transferts de l'organisation atteinte : non fait.
    Limited,
    /// Refusé par la file (alias désactivé entre-temps, adresses illisibles) : non fait.
    Refused,
}

/// Message reçu, avec tout ce que la transaction doit en faire.
pub struct InboundMessage<'a> {
    /// Message ; `recipients` : destinataires ordinaires (peut être vide).
    pub message: &'a ReceivedMessage,
    /// Lecture MIME du message reçu.
    pub parsed: &'a ParsedMessage,
    /// Adresses de retour de nos envois.
    pub returns: &'a [ReturnTarget],
    /// Alias qui transfèrent aussi le message vers l'extérieur.
    pub forwards: &'a [ForwardTarget],
    /// Réception d'origine, gardée sur chaque transfert pour l'avis à son expéditeur (§10.2).
    pub origin: ForwardReception,
    /// Le message exige `SMTPUTF8`.
    pub smtputf8: bool,
}

/// Issue de la réception d'une transaction.
#[derive(Debug)]
pub enum ReceptionResult {
    /// Tout est fait : comptes servis, avis inscrits, transferts traités.
    Accepted {
        /// Issue par compte.
        outcomes: Vec<AccountOutcome>,
        /// Issue par adresse de retour.
        returns: Vec<ReturnOutcome>,
        /// Issue par alias transféré.
        forwards: Vec<ForwardResult>,
    },
    /// Refus définitif avant tout dépôt ni inscription (antivirus).
    Rejected {
        /// Motif.
        reason: RejectReason,
    },
    /// Refus temporaire : l'expéditeur (ou la route locale) réessaie.
    TempFail {
        /// Code de la première erreur (`MAIL_*`, `STORAGE_*`), pour le journal.
        code: String,
        /// Comptes servis avant l'échec.
        served: usize,
    },
}

/// Chemin de réception commun (session SMTP du port 25, route locale du worker d'envoi).
#[derive(Clone)]
pub struct Reception {
    store: MailStore,
    pipeline: DeliveryPipeline,
    bounces: BounceProcessor,
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

/// Contenu tel que rangé, sans notre `Return-Path` (posé par la remise finale).
fn forwarded_content(stored: &Bytes) -> Bytes {
    match stored.iter().position(|byte| *byte == b'\n') {
        Some(end) if stored.starts_with(b"Return-Path:") => stored.slice(end + 1..),
        _ => stored.clone(),
    }
}

impl Reception {
    /// Chemin sur la session système de l'hôte (`store`) et la chaîne de remise du nœud.
    pub fn new(store: MailStore, pipeline: DeliveryPipeline) -> Self {
        Self {
            bounces: BounceProcessor::new(store.clone(), pipeline.clone()),
            store,
            pipeline,
        }
    }

    /// Analyse, remet, inscrit les avis et met en file les transferts de `inbound`.
    pub async fn receive(&self, inbound: InboundMessage<'_>) -> ReceptionResult {
        let message = inbound.message;
        let screened = match self.pipeline.screen(message).await {
            Screening::Passed(screened) => screened,
            Screening::Rejected { reason } => return ReceptionResult::Rejected { reason },
            Screening::Unavailable { code } => {
                return ReceptionResult::TempFail { code, served: 0 }
            }
        };
        let outcomes = if message.recipients.is_empty() {
            Vec::new()
        } else {
            match self.pipeline.deposit(message, &screened).await {
                PipelineResult::Delivered { outcomes } => outcomes,
                PipelineResult::Rejected { reason } => return ReceptionResult::Rejected { reason },
                PipelineResult::TempFail { code, served } => {
                    return ReceptionResult::TempFail { code, served }
                }
            }
        };
        let served = outcomes.len();
        let mut returns = Vec::with_capacity(inbound.returns.len());
        for target in inbound.returns {
            match self
                .bounces
                .process(target, message, inbound.parsed, &screened)
                .await
            {
                Ok(outcome) => returns.push(outcome),
                Err(error) => {
                    tracing::warn!(code = %error.code(), "avis reçu non inscrit : refus temporaire");
                    return ReceptionResult::TempFail {
                        code: error.code(),
                        served,
                    };
                }
            }
        }
        let mut forwards = Vec::with_capacity(inbound.forwards.len());
        if !inbound.forwards.is_empty() {
            let content = forwarded_content(&message.stored);
            let authors = author_addresses(inbound.parsed);
            let eight_bit = content.iter().any(|byte| *byte >= 0x80);
            for forward in inbound.forwards {
                match self
                    .forward(&inbound, forward, &content, &authors, eight_bit)
                    .await
                {
                    Ok(result) => forwards.push(result),
                    Err(code) => return ReceptionResult::TempFail { code, served },
                }
            }
        }
        ReceptionResult::Accepted {
            outcomes,
            returns,
            forwards,
        }
    }

    /// Met en file le transfert de `forward` ; `Err(code)` : panne, refus temporaire.
    async fn forward(
        &self,
        inbound: &InboundMessage<'_>,
        forward: &ForwardTarget,
        content: &Bytes,
        authors: &[String],
        eight_bit: bool,
    ) -> Result<ForwardResult, String> {
        let token = ReturnToken::generate().map_err(|error| {
            tracing::warn!(code = %error.code(), "jeton de retour d'un transfert non tiré : refus temporaire");
            error.code()
        })?;
        let message = inbound.message;
        let params = SubmissionBeginParams {
            origin: Some(SubmissionOrigin::Forward),
            from: forward.alias.clone(),
            header_from: if authors.is_empty() {
                vec![forward.alias.clone()]
            } else {
                authors.to_vec()
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
            smtputf8: Some(inbound.smtputf8),
            eight_bit: Some(eight_bit),
            dsn: None,
            client_reference: None,
            return_token: Some(token.as_str().to_string()),
            prefix: None,
            forward: Some(inbound.origin.clone()),
            tenant: None,
            idempotency_key: Some(delivery_key(
                &forward.alias,
                &message.sender,
                &message.received,
            )),
        };
        match self
            .pipeline
            .ingest()
            .queue_submission(&self.store, params, content.clone())
            .await
        {
            Ok(_) => Ok(ForwardResult::Queued),
            Err(error) if error.is_business() && error.code() == "MAIL_SEND_LIMIT_EXCEEDED" => {
                tracing::warn!("limite des transferts de l'organisation atteinte : message remis aux comptes de l'alias seulement");
                Ok(ForwardResult::Limited)
            }
            Err(error) if error.is_business() => {
                tracing::warn!(code = %error.code(), "transfert refusé par la file : message remis aux comptes de l'alias seulement");
                Ok(ForwardResult::Refused)
            }
            Err(error) => {
                tracing::warn!(code = %error.code(), "transfert non mis en file : refus temporaire");
                Err(error.code())
            }
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;

    #[test]
    fn our_return_path_is_removed_from_a_forwarded_copy() {
        let stored =
            Bytes::from_static(b"Return-Path: <x@a.test>\r\nReceived: by mx\r\n\r\nCorps\r\n");
        assert_eq!(
            forwarded_content(&stored),
            Bytes::from_static(b"Received: by mx\r\n\r\nCorps\r\n")
        );
        let plain = Bytes::from_static(b"Received: by mx\r\n\r\nCorps\r\n");
        assert_eq!(forwarded_content(&plain), plain);
    }
}
