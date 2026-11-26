// SPDX-License-Identifier: AGPL-3.0-only

//! Remise d'un message reçu dans un compte : empreinte d'idempotence, ordre des inscriptions par
//! compte dans le nœud et écriture groupée (plan du lot 5, §9.4 et §10.3, décisions S8 et S11).
//!
//! Le compteur de modifications d'un compte reste unique (décision M6) : deux inscriptions
//! simultanées dans un même compte se heurtent sur sa fiche. [`AccountQueue`] les ordonne dans
//! le nœud : les inscriptions d'un compte passent une à une, et celles qui attendent déjà leur
//! tour sont inscrites ensemble, jusqu'à [`MAX_BATCH`] par appel de `fn::mail_delivery_commit`
//! (une transaction, un seul passage sur la fiche du compte). Rien n'est retardé pour grossir un
//! lot : on groupe ce qui attend déjà. Entre deux nœuds, un conflit de transaction reste
//! possible : il est rejoué (trois fois au plus), et l'empreinte d'idempotence rend tout nouvel
//! essai sans effet.
//!
//! Aucune règle d'acceptation n'est écrite ici : compte, taille, quota, dossier, idempotence et
//! compteurs sont contrôlés par les fonctions SurrealQL.

use lyxal_crypto::Blake3Hasher;
use std::collections::hash_map::DefaultHasher;
use std::collections::{HashMap, VecDeque};
use std::hash::{Hash, Hasher};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Mutex, PoisonError};
use tokio::sync::oneshot;

use crate::error::{MailError, MailResult};
use crate::ingest::retry_conflicts_counted;
use crate::models::{
    DeliveryCommitParams, DeliveryCommitResult, DeliveryItem, DeliveryItemResult, MailRecordId,
};
use crate::store::MailStore;

/// Messages inscrits au plus par appel de `fn::mail_delivery_commit`.
pub const MAX_BATCH: usize = 32;
/// Compartiments de la table d'ordre par compte.
const COMPARTMENTS: usize = 1_024;

/// Empreinte d'idempotence d'une remise (décision S8) : BLAKE3, en hexadécimal, de l'adresse
/// inscrite du destinataire (`recipient`, rendue par `fn::mail_recipient_resolve`), de
/// l'expéditeur de l'enveloppe SMTP (`sender`, vide pour `MAIL FROM:<>`) et des octets reçus
/// avant l'ajout de nos en-têtes (`received`). Les deux adresses sont précédées de leur
/// longueur : deux remises différentes ne donnent jamais la même suite d'octets.
pub fn delivery_key(recipient: &str, sender: &str, received: &[u8]) -> String {
    let mut hasher = Blake3Hasher::new();
    for part in [recipient.as_bytes(), sender.as_bytes()] {
        hasher.update(&u64::try_from(part.len()).unwrap_or(u64::MAX).to_be_bytes());
        hasher.update(part);
    }
    hasher.update(received);
    hasher.finalize_hex()
}

/// Compartiment d'un compte dans une table de [`COMPARTMENTS`] entrées.
fn compartment_of(key: &str) -> usize {
    let mut hasher = DefaultHasher::new();
    key.hash(&mut hasher);
    usize::try_from(hasher.finish() % COMPARTMENTS as u64).unwrap_or(0)
}

/// Issue de la remise d'un message à un compte.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DeliveryOutcome {
    /// Message inscrit.
    Delivered {
        /// Fiche inscrite.
        message: MailRecordId,
        /// Dossier de remise.
        mailbox: MailRecordId,
        /// UID dans le dossier.
        uid: i64,
    },
    /// Message déjà remis à ce compte (nouvel essai de l'expéditeur) : rien n'a été inscrit.
    Duplicate {
        /// Fiche inscrite par la première remise.
        message: MailRecordId,
    },
}

/// Relevé de l'ordre des inscriptions d'un nœud (mesures ; aucune donnée de message).
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct QueueStats {
    /// Appels de `fn::mail_delivery_commit` aboutis.
    pub batches: u64,
    /// Messages présentés à l'inscription.
    pub items: u64,
    /// Plus grand lot inscrit.
    pub largest_batch: u64,
    /// Appels refusés pour conflit de transaction, puis rejoués.
    pub conflicts: u64,
    /// Lots en échec repris élément par élément.
    pub split_batches: u64,
}

/// Inscription en attente de son tour.
struct Waiting {
    ticket: u64,
    item: DeliveryItem,
    reply: oneshot::Sender<MailResult<DeliveryOutcome>>,
}

/// Un compartiment : inscriptions en attente par compte, et le tour d'écriture.
#[derive(Default)]
struct Compartment {
    waiting: Mutex<HashMap<String, VecDeque<Waiting>>>,
    turn: tokio::sync::Mutex<()>,
    tickets: AtomicU64,
}

/// Place d'une inscription dans la file de son compte. Lâchée avant que l'inscription soit
/// prise dans un lot (remise abandonnée par son appelant : délai dépassé, connexion fermée),
/// elle retire l'inscription de la file : rien n'y reste sans appelant.
struct Ticket<'a> {
    compartment: &'a Compartment,
    account: &'a str,
    ticket: u64,
}

impl Drop for Ticket<'_> {
    fn drop(&mut self) {
        let mut waiting = self
            .compartment
            .waiting
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if let Some(queue) = waiting.get_mut(self.account) {
            queue.retain(|entry| entry.ticket != self.ticket);
            if queue.is_empty() {
                waiting.remove(self.account);
            }
        }
    }
}

impl Compartment {
    /// Met l'inscription en file ; rend sa place et le canal de sa réponse.
    fn enqueue<'a>(
        &'a self,
        account: &'a str,
        item: DeliveryItem,
    ) -> (Ticket<'a>, oneshot::Receiver<MailResult<DeliveryOutcome>>) {
        let (reply, answer) = oneshot::channel();
        let ticket = self.tickets.fetch_add(1, Ordering::Relaxed);
        self.waiting
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .entry(account.to_string())
            .or_default()
            .push_back(Waiting {
                ticket,
                item,
                reply,
            });
        (
            Ticket {
                compartment: self,
                account,
                ticket,
            },
            answer,
        )
    }

    /// Les plus anciennes inscriptions en attente du compte, [`MAX_BATCH`] au plus.
    fn take(&self, account: &str) -> Vec<Waiting> {
        let mut waiting = self.waiting.lock().unwrap_or_else(PoisonError::into_inner);
        let Some(queue) = waiting.get_mut(account) else {
            return Vec::new();
        };
        let count = queue.len().min(MAX_BATCH);
        let batch: Vec<Waiting> = queue.drain(..count).collect();
        if queue.is_empty() {
            waiting.remove(account);
        }
        batch
    }
}

/// Ordre des inscriptions par compte dans le nœud et écriture groupée (décision S11) : table de
/// 1 024 compartiments, chacun avec son tour d'écriture.
pub struct AccountQueue {
    store: MailStore,
    compartments: Box<[Compartment]>,
    batches: AtomicU64,
    items: AtomicU64,
    largest_batch: AtomicU64,
    conflicts: AtomicU64,
    split_batches: AtomicU64,
}

impl AccountQueue {
    /// Ordre des inscriptions faites sous la session de `store` (session système de l'hôte, ou
    /// compte de service).
    pub fn new(store: MailStore) -> Self {
        Self {
            store,
            compartments: (0..COMPARTMENTS).map(|_| Compartment::default()).collect(),
            batches: AtomicU64::new(0),
            items: AtomicU64::new(0),
            largest_batch: AtomicU64::new(0),
            conflicts: AtomicU64::new(0),
            split_batches: AtomicU64::new(0),
        }
    }

    /// Relevé depuis la création.
    pub fn stats(&self) -> QueueStats {
        QueueStats {
            batches: self.batches.load(Ordering::Relaxed),
            items: self.items.load(Ordering::Relaxed),
            largest_batch: self.largest_batch.load(Ordering::Relaxed),
            conflicts: self.conflicts.load(Ordering::Relaxed),
            split_batches: self.split_batches.load(Ordering::Relaxed),
        }
    }

    fn compartment(&self, account: &str) -> Option<&Compartment> {
        self.compartments.get(compartment_of(account))
    }

    /// Inscrit un message remis au compte (`mail_account:<clé>`), à son tour : avec les
    /// inscriptions du même compte qui attendent déjà, dans l'ordre d'arrivée. L'erreur d'un
    /// élément ne touche pas les autres.
    pub async fn commit(&self, account: &str, item: DeliveryItem) -> MailResult<DeliveryOutcome> {
        let Some(compartment) = self.compartment(account) else {
            return Err(interrupted());
        };
        let (_ticket, mut answer) = compartment.enqueue(account, item);
        self.items.fetch_add(1, Ordering::Relaxed);
        loop {
            tokio::select! {
                biased;
                // Déjà inscrit dans le lot d'une remise arrivée avant
                answered = &mut answer => return answered.unwrap_or_else(|_| Err(interrupted())),
                turn = compartment.turn.lock() => {
                    let batch = compartment.take(account);
                    if !batch.is_empty() {
                        self.write(account, batch).await;
                    }
                    drop(turn);
                }
            }
        }
    }

    /// Inscrit un lot et répond à chaque remise. Un lot refusé en entier (hors conflit rejoué)
    /// est repris élément par élément : l'élément en cause échoue seul, et un lot dont on ne
    /// sait pas s'il a été inscrit (panne) est reconnu par son empreinte d'idempotence.
    async fn write(&self, account: &str, batch: Vec<Waiting>) {
        let (items, replies): (Vec<DeliveryItem>, Vec<_>) = batch
            .into_iter()
            .map(|waiting| (waiting.item, waiting.reply))
            .unzip();
        let count = u64::try_from(items.len()).unwrap_or(u64::MAX);
        let params = DeliveryCommitParams {
            account: account.to_string(),
            items,
        };
        match self.call(&params).await {
            Ok(done) if done.items.len() == replies.len() => {
                self.largest_batch.fetch_max(count, Ordering::Relaxed);
                for (reply, result) in replies.into_iter().zip(done.items) {
                    // Remise abandonnée par son appelant : rien à répondre
                    let _ = reply.send(outcome(result));
                }
            }
            Ok(_) => {
                for reply in replies {
                    let _ = reply.send(Err(incomplete()));
                }
            }
            Err(error) if replies.len() == 1 => {
                if let Some(reply) = replies.into_iter().next() {
                    let _ = reply.send(Err(error.into()));
                }
            }
            Err(error) => {
                self.split_batches.fetch_add(1, Ordering::Relaxed);
                tracing::warn!(code = %MailError::from(error).code(), items = count, "lot de remise refusé : repris élément par élément");
                for (item, reply) in params.items.into_iter().zip(replies) {
                    let single = DeliveryCommitParams {
                        account: account.to_string(),
                        items: vec![item],
                    };
                    let result = match self.call(&single).await {
                        Ok(done) => single_outcome(done),
                        Err(error) => Err(error.into()),
                    };
                    let _ = reply.send(result);
                }
            }
        }
    }

    async fn call(
        &self,
        params: &DeliveryCommitParams,
    ) -> Result<DeliveryCommitResult, lyxal_surreal::LyxalSurrealError> {
        let done = retry_conflicts_counted(&self.conflicts, || {
            self.store.delivery_commit(params.clone())
        })
        .await?;
        self.batches.fetch_add(1, Ordering::Relaxed);
        Ok(done)
    }
}

/// Issue d'un élément rendu par `fn::mail_delivery_commit`.
fn outcome(result: DeliveryItemResult) -> MailResult<DeliveryOutcome> {
    if let Some(error) = result.error {
        return Err(MailError::Refused {
            code: error.code,
            retryable: error.retryable,
        });
    }
    match (result.message, result.mailbox, result.uid, result.duplicate) {
        (Some(message), _, _, true) => Ok(DeliveryOutcome::Duplicate { message }),
        (Some(message), Some(mailbox), Some(uid), false) => Ok(DeliveryOutcome::Delivered {
            message,
            mailbox,
            uid,
        }),
        _ => Err(incomplete()),
    }
}

fn single_outcome(mut done: DeliveryCommitResult) -> MailResult<DeliveryOutcome> {
    match (done.items.pop(), done.items.is_empty()) {
        (Some(result), true) => outcome(result),
        _ => Err(incomplete()),
    }
}

/// Réponse d'inscription qui ne correspond pas au lot envoyé (à réessayer : l'empreinte
/// d'idempotence reconnaît ce qui a été inscrit).
fn incomplete() -> MailError {
    MailError::Unavailable("réponse d'inscription incomplète".to_string())
}

/// Inscription interrompue avant sa réponse (remise en tête de lot abandonnée, arrêt).
fn interrupted() -> MailError {
    MailError::Unavailable("inscription interrompue".to_string())
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn the_delivery_key_separates_recipient_sender_and_bytes() {
        let key = delivery_key("jean@alpha.test", "paul@ailleurs.test", b"message");
        assert_eq!(key.len(), 64);
        assert!(key
            .bytes()
            .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b)));
        assert_eq!(
            key,
            delivery_key("jean@alpha.test", "paul@ailleurs.test", b"message")
        );
        // Mêmes octets concaténés, découpés autrement : empreintes différentes
        assert_ne!(
            key,
            delivery_key("jean@alpha.testp", "aul@ailleurs.test", b"message")
        );
        assert_ne!(
            key,
            delivery_key("jean@alpha.test", "paul@ailleurs.tes", b"tmessage")
        );
        assert_ne!(key, delivery_key("jean@alpha.test", "", b"message"));
        assert_ne!(
            key,
            delivery_key("marie@alpha.test", "paul@ailleurs.test", b"message")
        );
    }

    fn item(key: &str) -> DeliveryItem {
        let raw = b"From: a@alpha.test\r\nSubject: essai\r\n\r\ncorps\r\n";
        let parsed = lyxal_mail_proto::mime::parse(raw, &Default::default()).expect("message");
        crate::mime::delivery_item(
            &parsed,
            crate::models::MailDatetime::now(),
            crate::models::DeliveryRole::Inbox,
            key.to_string(),
            crate::models::Reception {
                spf: "none".to_string(),
                dkim: "none".to_string(),
                dmarc: "none".to_string(),
                iprev: "pass".to_string(),
                antivirus: "not_scanned".to_string(),
                spam: "none".to_string(),
                tls: false,
            },
        )
    }

    #[test]
    fn an_abandoned_commit_leaves_nothing_in_the_queue() {
        let compartment = Compartment::default();
        let (first, _first_answer) = compartment.enqueue("mail_account:a", item("1"));
        let (second, _second_answer) = compartment.enqueue("mail_account:a", item("2"));
        // Remise abandonnée avant son tour : retirée, l'autre garde sa place
        drop(first);
        let left = compartment.take("mail_account:a");
        assert_eq!(left.len(), 1);
        assert_eq!(left[0].item.delivery_key, "2");
        // Déjà prise dans un lot : lâcher sa place ne retire rien d'autre
        let (third, _third_answer) = compartment.enqueue("mail_account:a", item("3"));
        drop(second);
        assert_eq!(compartment.take("mail_account:a").len(), 1);
        drop(third);
        let (last, _last_answer) = compartment.enqueue("mail_account:b", item("4"));
        drop(last);
        assert!(compartment
            .waiting
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .is_empty());
    }

    #[test]
    fn an_item_result_becomes_an_outcome_or_its_own_error() {
        let message = MailRecordId::new("mail_message", "m");
        let mailbox = MailRecordId::new("mail_mailbox", "b");
        let delivered = outcome(DeliveryItemResult {
            message: Some(message.clone()),
            uid: Some(7),
            mailbox: Some(mailbox.clone()),
            duplicate: false,
            error: None,
        });
        assert!(matches!(
            delivered,
            Ok(DeliveryOutcome::Delivered { uid: 7, .. })
        ));
        let duplicate = outcome(DeliveryItemResult {
            message: Some(message.clone()),
            uid: None,
            mailbox: None,
            duplicate: true,
            error: None,
        });
        assert!(matches!(duplicate, Ok(DeliveryOutcome::Duplicate { .. })));
        let refused = outcome(DeliveryItemResult {
            message: None,
            uid: None,
            mailbox: None,
            duplicate: false,
            error: Some(crate::models::DeliveryItemError {
                code: "MAIL_QUOTA_EXCEEDED".to_string(),
                retryable: false,
            }),
        });
        assert!(
            matches!(refused, Err(error) if error.code() == "MAIL_QUOTA_EXCEEDED" && error.is_business() && !error.is_retryable())
        );
        let empty = outcome(DeliveryItemResult {
            message: None,
            uid: None,
            mailbox: None,
            duplicate: false,
            error: None,
        });
        assert!(matches!(empty, Err(error) if error.is_retryable()));
    }
}
