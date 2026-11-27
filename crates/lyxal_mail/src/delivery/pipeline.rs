// SPDX-License-Identifier: AGPL-3.0-only

//! Chaîne de remise d'un message reçu (plan du lot 5, §12, décisions S9, S10, P15).
//!
//! L'ordre est **fixé par le type** : [`DeliveryPipeline::deliver`] appelle ses étapes, champs
//! nommés, toujours dans cet ordre (jamais une liste reconfigurable) :
//!
//! 1. **antivirus** : une analyse par message (pas par destinataire), sur le message en clair,
//!    avant tout dépôt ; infecté → refus définitif, aucun dépôt, aucune quarantaine ; antivirus
//!    configuré mais injoignable → refus temporaire ; sans antivirus : `not_scanned` ;
//! 2. **anti-spam** : étape posée, vide (verdict `none`, lot 11) ;
//! 3. **filtres** : choix du dossier, `junk` si la quarantaine DMARC est appliquée, sinon
//!    `inbox` (Sieve au lot 10) ;
//! 4. **index** : étape posée, vide (lot 9) ;
//! 5. **chiffrement** : niveau A, chaque copie écrite chiffrée par `lyxal_storage`
//!    ([`MailIngest::receive`]) ; niveau B (OpenPGP) au lot 12 bis.
//!
//! Puis le dépôt, un contenu par compte (décision M14) : un compte atteint par plusieurs
//! destinataires de la transaction (adresse et alias) ne reçoit qu'une copie. La réponse au
//! client est unique (décision S8) : tout inscrit (ou déjà inscrit) → accepté ; au moins un
//! échec → refus temporaire, l'expéditeur réessaie et l'empreinte d'idempotence reconnaît les
//! comptes déjà servis.

use bytes::Bytes;
use lyxal_storage::{ContentScanner, ScanVerdict};
use lyxal_surreal::ToSql;
use std::collections::BTreeMap;
use std::sync::Arc;

use crate::delivery::{delivery_key, DeliveryOutcome};
use crate::error::MailError;
use crate::ingest::{MailIngest, ReceivedDelivery};
use crate::models::{DeliveryRole, MailDatetime, MailRecordId, Reception};

/// Taille des morceaux transmis à l'antivirus.
const SCAN_CHUNK: usize = 64 * 1024;

/// Compte destinataire d'un message, avec l'adresse inscrite qui l'a désigné.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecipientTarget {
    /// Adresse inscrite (rendue par `fn::mail_recipient_resolve`) : entre dans l'empreinte
    /// d'idempotence.
    pub address: String,
    /// Organisation du domaine.
    pub tenant: MailRecordId,
    /// Comptes actifs de l'adresse (alias développé).
    pub accounts: Vec<MailRecordId>,
}

/// Message reçu à remettre : octets, enveloppe SMTP, résultats des contrôles, état TLS.
#[derive(Debug, Clone)]
pub struct ReceivedMessage {
    /// Octets reçus, avant l'ajout de nos en-têtes (empreinte d'idempotence, antivirus).
    pub received: Bytes,
    /// Message à ranger : nos en-têtes de réception puis les octets reçus (en-têtes
    /// `Authentication-Results` falsifiés retirés).
    pub stored: Bytes,
    /// Expéditeur de l'enveloppe (vide pour `MAIL FROM:<>`).
    pub sender: String,
    /// Destinataires acceptés.
    pub recipients: Vec<RecipientTarget>,
    /// Résultats d'authenticité : `spf`, `dkim`, `dmarc`, `iprev` (mots de la RFC 8601).
    pub authentication: [String; 4],
    /// Quarantaine DMARC appliquée : dossier « Junk ».
    pub quarantine: bool,
    /// Reçu sous TLS.
    pub tls: bool,
    /// Date interne.
    pub received_at: MailDatetime,
}

/// Décision de la chaîne avant le dépôt ([`DeliveryPipeline::screen`]).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Screening {
    /// Message admis : à remettre par [`DeliveryPipeline::deposit`].
    Passed(Screened),
    /// Refus définitif (antivirus : message infecté).
    Rejected {
        /// Motif.
        reason: RejectReason,
    },
    /// Refus temporaire (antivirus configuré mais injoignable) : l'expéditeur réessaie.
    Unavailable {
        /// Code de l'erreur de l'antivirus.
        code: String,
    },
}

/// Message admis par la chaîne : dossier choisi et résultat de l'antivirus.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Screened {
    /// Dossier de remise.
    pub role: DeliveryRole,
    /// Analysé par l'antivirus (sain) ; faux : aucun antivirus configuré.
    pub scanned: bool,
}

/// Motif d'un refus définitif de la chaîne.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RejectReason {
    /// Message infecté (`MAIL_MESSAGE_INFECTED`).
    Infected,
}

/// Issue de la remise à un compte.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AccountOutcome {
    /// Compte destinataire.
    pub account: MailRecordId,
    /// Message inscrit, ou déjà inscrit.
    pub outcome: DeliveryOutcome,
}

/// Issue de la remise d'un message à tous ses comptes.
#[derive(Debug)]
pub enum PipelineResult {
    /// Tous les comptes servis (inscrits, ou déjà inscrits).
    Delivered {
        /// Issue par compte.
        outcomes: Vec<AccountOutcome>,
    },
    /// Refus avant tout dépôt (antivirus).
    Rejected {
        /// Motif.
        reason: RejectReason,
    },
    /// Refus temporaire : antivirus injoignable, ou au moins un compte non servi.
    TempFail {
        /// Code de la première erreur (`MAIL_*`, `STORAGE_*`), pour le journal.
        code: String,
        /// Comptes servis avant l'échec (reconnus au nouvel essai par l'idempotence).
        served: usize,
    },
}

/// Étape 1 : antivirus de `lyxal_storage`, s'il est configuré.
#[derive(Clone, Default)]
pub struct AntivirusStage {
    scanner: Option<Arc<dyn ContentScanner>>,
}

/// Résultat de l'antivirus.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum ScanOutcome {
    Clean,
    NotScanned,
    Infected,
    Unavailable(String),
}

impl AntivirusStage {
    /// Étape sur l'antivirus de `lyxal_storage`, s'il est configuré (aussi pour le dépôt
    /// authentifié, plan du lot 6, §8.5).
    pub(crate) fn new(scanner: Option<Arc<dyn ContentScanner>>) -> Self {
        Self { scanner }
    }

    /// Une analyse du message entier, en morceaux de 64 Kio.
    pub(crate) async fn scan(&self, message: &Bytes) -> ScanOutcome {
        let Some(scanner) = &self.scanner else {
            return ScanOutcome::NotScanned;
        };
        let mut session = match scanner.begin().await {
            Ok(session) => session,
            Err(error) => return ScanOutcome::Unavailable(error.code()),
        };
        let mut start = 0;
        while start < message.len() {
            let end = (start + SCAN_CHUNK).min(message.len());
            if let Err(error) = session.feed(&message.slice(start..end)).await {
                return ScanOutcome::Unavailable(error.code());
            }
            start = end;
        }
        match session.finish().await {
            Ok(ScanVerdict::Clean) => ScanOutcome::Clean,
            Ok(ScanVerdict::Infected(_)) => ScanOutcome::Infected,
            Err(error) => ScanOutcome::Unavailable(error.code()),
        }
    }
}

/// Étape 2 : anti-spam (vide au lot 5, verdict `none`).
#[derive(Clone, Copy, Default)]
pub struct SpamStage;

impl SpamStage {
    fn verdict(&self) -> &'static str {
        "none"
    }
}

/// Étape 3 : filtres (choix du dossier ; aucune règle d'utilisateur au lot 5).
#[derive(Clone, Copy, Default)]
pub struct FilterStage;

impl FilterStage {
    fn mailbox(&self, message: &ReceivedMessage) -> DeliveryRole {
        if message.quarantine {
            DeliveryRole::Junk
        } else {
            DeliveryRole::Inbox
        }
    }
}

/// Étape 4 : index (vide au lot 5).
#[derive(Clone, Copy, Default)]
pub struct IndexStage;

impl IndexStage {
    fn index(&self, _message: &ReceivedMessage) {}
}

/// Étape 5 : chiffrement de niveau A et dépôt par compte ([`MailIngest::receive`]).
#[derive(Clone)]
pub struct EncryptionStage {
    ingest: MailIngest,
}

/// Chaîne de remise : étapes nommées, appelées dans l'ordre du type.
#[derive(Clone)]
pub struct DeliveryPipeline {
    antivirus: AntivirusStage,
    spam: SpamStage,
    filters: FilterStage,
    index: IndexStage,
    encryption: EncryptionStage,
}

impl DeliveryPipeline {
    /// Chaîne sans antivirus, qui dépose par `ingest` (session système de l'hôte ; son stockage
    /// n'analyse plus les copies, décision S9).
    pub fn new(ingest: MailIngest) -> Self {
        Self {
            antivirus: AntivirusStage::default(),
            spam: SpamStage,
            filters: FilterStage,
            index: IndexStage,
            encryption: EncryptionStage { ingest },
        }
    }

    /// Antivirus de la première étape.
    pub fn with_scanner(mut self, scanner: Arc<dyn ContentScanner>) -> Self {
        self.antivirus.scanner = Some(scanner);
        self
    }

    /// Service de dépôt (relevés de l'ordre des inscriptions).
    pub fn ingest(&self) -> &MailIngest {
        &self.encryption.ingest
    }

    /// Antivirus configuré, s'il y en a un (sonde de santé).
    pub fn scanner(&self) -> Option<&Arc<dyn ContentScanner>> {
        self.antivirus.scanner.as_ref()
    }

    /// Décision de la chaîne (étapes 1 à 4), avant tout dépôt : une seule analyse antivirus du
    /// message, quel que soit le nombre de comptes, d'adresses de retour et de transferts qui
    /// suivent (chemin de réception commun, [`crate::delivery::Reception`]).
    pub async fn screen(&self, message: &ReceivedMessage) -> Screening {
        let scanned = match self.antivirus.scan(&message.received).await {
            ScanOutcome::Infected => {
                return Screening::Rejected {
                    reason: RejectReason::Infected,
                }
            }
            ScanOutcome::Unavailable(code) => return Screening::Unavailable { code },
            ScanOutcome::Clean => true,
            ScanOutcome::NotScanned => false,
        };
        let role = self.filters.mailbox(message);
        self.index.index(message);
        Screening::Passed(Screened { role, scanned })
    }

    /// Passe le message dans la chaîne puis le remet à chaque compte (en parallèle).
    pub async fn deliver(&self, message: &ReceivedMessage) -> PipelineResult {
        match self.screen(message).await {
            Screening::Passed(screened) => self.deposit(message, &screened).await,
            Screening::Rejected { reason } => PipelineResult::Rejected { reason },
            Screening::Unavailable { code } => PipelineResult::TempFail { code, served: 0 },
        }
    }

    /// Remet à chaque compte (en parallèle) un message déjà passé par [`Self::screen`] : aucune
    /// seconde analyse.
    pub async fn deposit(&self, message: &ReceivedMessage, screened: &Screened) -> PipelineResult {
        let (role, scanned) = (screened.role, screened.scanned);
        let [spf, dkim, dmarc, iprev] = &message.authentication;
        let reception = Reception {
            spf: spf.clone(),
            dkim: dkim.clone(),
            dmarc: dmarc.clone(),
            iprev: iprev.clone(),
            antivirus: if scanned { "clean" } else { "not_scanned" }.to_string(),
            spam: self.spam.verdict().to_string(),
            tls: message.tls,
        };
        // Un contenu par compte : un compte désigné par plusieurs destinataires (adresse et
        // alias) n'est servi qu'une fois, sous la plus petite des adresses qui le désignent ;
        // l'empreinte d'idempotence ne dépend donc pas de l'ordre des `RCPT TO`
        let mut chosen: BTreeMap<String, (&RecipientTarget, &MailRecordId)> = BTreeMap::new();
        for recipient in &message.recipients {
            for account in &recipient.accounts {
                chosen
                    .entry(account.to_sql())
                    .and_modify(|current| {
                        if recipient.address < current.0.address {
                            *current = (recipient, account);
                        }
                    })
                    .or_insert((recipient, account));
            }
        }
        let deliveries: Vec<_> = chosen
            .into_iter()
            .map(|(account_key, (recipient, account))| {
                (
                    account.clone(),
                    ReceivedDelivery {
                        account: account_key,
                        tenant: recipient.tenant.clone(),
                        role,
                        raw: message.stored.clone(),
                        received_at: Some(message.received_at),
                        delivery_key: delivery_key(
                            &recipient.address,
                            &message.sender,
                            &message.received,
                        ),
                        reception: reception.clone(),
                    },
                )
            })
            .collect();
        let ingest = &self.encryption.ingest;
        let results =
            futures::future::join_all(deliveries.into_iter().map(
                |(account, delivery)| async move { (account, ingest.receive(delivery).await) },
            ))
            .await;
        let mut outcomes = Vec::with_capacity(results.len());
        let mut failure: Option<MailError> = None;
        for (account, result) in results {
            match result {
                Ok(outcome) => outcomes.push(AccountOutcome { account, outcome }),
                Err(error) => {
                    tracing::warn!(code = %error.code(), "remise à un compte en échec : refus temporaire de la transaction");
                    failure.get_or_insert(error);
                }
            }
        }
        match failure {
            None => PipelineResult::Delivered { outcomes },
            Some(error) => PipelineResult::TempFail {
                code: error.code(),
                served: outcomes.len(),
            },
        }
    }
}
