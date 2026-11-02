// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

//! Superviseur d'alimentation et de réconciliation de l'outbox (`OutboxFeeder`).
//!
//! Ce composant réconcilie les événements stockés dans `event_outbox`, orchestre la création
//! transactionnelle des livraisons via `fn::event_delivery_assign_seq` (Lot 3B.1),
//! et alimente le [`ReliableDispatcher`] de distribution in-process sous contrôle strict de backpressure.
//!
//! # Invariants de Sûreté
//! - Le feeder vérifie impérativement la validité du bail et de la génération active avant toute opération.
//! - La distribution s'interrompt immédiatement en cas de perte de leadership ou de saturation
//!   de la fenêtre de dispatching (`!dispatcher.has_capacity()`).
//! - Aucun message n'est considéré comme définitivement traité avant sa confirmation durable
//!   dans SurrealDB par le [`SubscriptionProgressTracker`].

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, RecordId, ToSql};
use std::collections::HashMap;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use thiserror::Error;
use tokio::sync::Mutex;
use tokio_util::sync::CancellationToken;
use tracing::{debug, info};

use super::dispatcher::{AckReport, DispatcherError, ReliableDispatcher};
use super::dto::{DeliveryAssignSeqParams, DeliveryFailureParams};
use super::lease::OutboxLeaseManager;
use super::progress::{ProgressError, SubscriptionProgressTracker};
use crate::models::EventDelivery;

/// Erreurs associées à l'alimentation de l'outbox.
#[derive(Debug, Error)]
pub enum FeederError {
    /// Erreur SurrealDB.
    #[error("Erreur SurrealDB lors de l'alimentation: {0}")]
    Surreal(Box<LyxalSurrealError>),

    /// Erreur du dispatcher LYXAL Event Engine.
    #[error("Erreur du dispatcher d'événements: {0}")]
    Dispatcher(#[from] DispatcherError),

    /// Erreur interne du feeder.
    #[error("Erreur interne du feeder: {0}")]
    Internal(String),

    /// Erreur de progression ou de flush.
    #[error("Erreur de progression: {0}")]
    Progress(#[from] ProgressError),

    /// Ce nœud n'est pas le leader actif.
    #[error("Opération refusée : le nœud n'est pas le leader actif")]
    NotLeader,

    /// Le leadership a été révoqué par le Fencing.
    #[error("Leadership révoqué par le Fencing transactionnel")]
    Fenced,

    /// Backpressure active : la capacité maximale de messages en vol est atteinte.
    #[error("Backpressure active : la fenêtre du dispatcher est saturée")]
    Backpressure,

    /// La livraison créée ne comportait pas de numéro de séquence contigu.
    #[error("Livraison invalide : numéro de séquence absent")]
    MissingSequence,
}

impl From<LyxalSurrealError> for FeederError {
    fn from(err: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(err))
    }
}

/// Superviseur d'alimentation outbox vers le dispatcher in-process.
pub struct OutboxFeeder<T = EventDelivery>
where
    T: Clone + Send + 'static,
{
    client: Surreal<Any>,
    lease_manager: Arc<OutboxLeaseManager>,
    dispatcher: Arc<Mutex<ReliableDispatcher<T>>>,
    trackers: HashMap<RecordId, SubscriptionProgressTracker>,
    delivery_seq_to_id: HashMap<u64, RecordId>,
    delivery_seq_to_sub: HashMap<u64, RecordId>,
    cancellation: CancellationToken,
}

#[async_trait]
impl<T: Clone + Send + 'static> LyxalSurrealCall for OutboxFeeder<T> {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

impl<T: Clone + Send + 'static> OutboxFeeder<T> {
    /// Crée une nouvelle instance de l'OutboxFeeder.
    pub fn new(
        client: Surreal<Any>,
        lease_manager: Arc<OutboxLeaseManager>,
        dispatcher: Arc<Mutex<ReliableDispatcher<T>>>,
    ) -> Self {
        let cancellation = lease_manager.cancellation_token();
        Self {
            client,
            lease_manager,
            dispatcher,
            trackers: HashMap::new(),
            delivery_seq_to_id: HashMap::new(),
            delivery_seq_to_sub: HashMap::new(),
            cancellation,
        }
    }

    /// Enregistre ou récupère le tracker de progression pour un abonnement.
    pub fn get_or_create_tracker(
        &mut self,
        subscription: &RecordId,
    ) -> &mut SubscriptionProgressTracker {
        let node_id = self.lease_manager.node_id().to_string();
        let client = self.client.clone();
        let gen = Arc::new(std::sync::atomic::AtomicU64::new(
            self.lease_manager.current_generation(),
        ));
        let cancel = self.cancellation.clone();

        self.trackers
            .entry(subscription.clone())
            .or_insert_with(|| {
                SubscriptionProgressTracker::new(client, subscription.clone(), node_id, gen, cancel)
            })
    }

    /// Attribue une séquence transactionnelle durable et injecte le message dans le dispatcher in-process.
    ///
    /// # Contrôles de Sûreté
    /// 1. Vérification du leadership actif et non annulé.
    /// 2. Contrôle de backpressure (`dispatcher.has_capacity()`).
    /// 3. Appel de la fonction SurrealQL atomique `fn::event_delivery_assign_seq`.
    /// 4. Injection dans la fenêtre du dispatcher sous le numéro de séquence retourné.
    pub async fn assign_and_enqueue<F>(
        &mut self,
        outbox_event: &RecordId,
        subscription: &RecordId,
        target_module: &str,
        context: serde_json::Value,
        message: T,
        extractor: F,
    ) -> Result<u64, FeederError>
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        if !self.lease_manager.is_leader() {
            return Err(FeederError::NotLeader);
        }

        {
            let disp = self.dispatcher.lock().await;
            if !disp.has_capacity() {
                return Err(FeederError::Backpressure);
            }
        }

        let generation = self.lease_manager.current_generation();
        let node_id = self.lease_manager.node_id().to_string();

        let params = DeliveryAssignSeqParams {
            outbox_event: outbox_event.clone(),
            subscription: subscription.clone(),
            target_module: target_module.to_string(),
            node_id,
            generation,
            context,
            lock_seconds: None,
        };

        let delivery: EventDelivery = match self.call_fn("event_delivery_assign_seq", params).await
        {
            Ok(del) => del,
            Err(e) => {
                if crate::error::is_stale_leader_fenced(&e) {
                    tracing::warn!(
                        node_id = %self.lease_manager.node_id(),
                        generation,
                        "Fencing détecté au séquencement : mandat de leader révoqué"
                    );
                    self.cancellation.cancel();
                    return Err(FeederError::Fenced);
                }
                return Err(FeederError::Surreal(Box::new(e)));
            }
        };

        let seq = delivery.delivery_seq.ok_or(FeederError::MissingSequence)?;

        if self.delivery_seq_to_id.contains_key(&seq) {
            return Ok(seq);
        }

        // Enregistre l'association séquence -> identifiant de livraison et abonnement
        self.delivery_seq_to_id.insert(seq, delivery.id.clone());
        self.delivery_seq_to_sub.insert(seq, subscription.clone());

        // Enqueue dans le dispatcher in-process
        {
            let mut disp = self.dispatcher.lock().await;
            disp.submit_message(seq, message, extractor)?;
        }

        debug!(
            subscription = %subscription.to_sql(),
            seq = seq,
            "Message outbox séquencé et enfilé dans le Dispatcher"
        );

        Ok(seq)
    }

    /// Avance le curseur durable de chaque abonnement jusqu'au curseur contigu du dispatcher,
    /// pour les trackers qui ont des résolutions en attente.
    async fn flush_trackers(&mut self, safe_cursor: Option<u64>) -> Result<(), FeederError> {
        let Some(cursor) = safe_cursor else {
            return Ok(());
        };
        let mut flushed = false;
        for tracker in self.trackers.values_mut() {
            if tracker.pending_resolutions_count() > 0 && cursor > tracker.last_persisted_cursor() {
                tracker.flush_progress(cursor).await?;
                flushed = true;
            }
        }
        if flushed {
            self.delivery_seq_to_id.retain(|&seq, _| seq > cursor);
            self.delivery_seq_to_sub.retain(|&seq, _| seq > cursor);
        }
        Ok(())
    }

    /// Identifiants (livraison, abonnement) d'une séquence enfilée par ce feeder.
    fn delivery_of(&self, offset: u64) -> Option<(RecordId, RecordId)> {
        Some((
            self.delivery_seq_to_id.get(&offset)?.clone(),
            self.delivery_seq_to_sub.get(&offset)?.clone(),
        ))
    }

    /// Relance l'avancement durable du curseur resté en attente après un échec d'écriture.
    ///
    /// Sans ce rattrapage, un échec de `flush_batch` sur la dernière livraison d'un abonnement
    /// ne serait jamais rejoué (le flush n'est déclenché que par une nouvelle résolution) : la
    /// livraison resterait verrouillée et le curseur bloqué.
    pub async fn retry_pending_flush(&mut self) -> Result<(), FeederError> {
        let safe_cursor = {
            let disp = self.dispatcher.lock().await;
            disp.safe_cursor()
        };
        self.flush_trackers(safe_cursor).await
    }

    /// Traite un acquittement de consommation (ACK) et avance la progression durable.
    pub async fn handle_ack(
        &mut self,
        offset: u64,
        attempt_id: u32,
    ) -> Result<AckReport, FeederError> {
        let (ack_report, safe_cursor) = {
            let mut disp = self.dispatcher.lock().await;
            let report = disp.handle_ack(offset, attempt_id);
            let cursor = disp.safe_cursor();
            (report, cursor)
        };

        if let Some((delivery_id, subscription)) = self.delivery_of(offset) {
            self.get_or_create_tracker(&subscription)
                .record_delivered(offset, delivery_id);
        }
        self.flush_trackers(safe_cursor).await?;
        Ok(ack_report)
    }

    /// Transfère en dead letter les livraisons épuisées remontées par le dispatcher.
    async fn transfer_dead_letters(
        &mut self,
        dead_letters: Vec<crate::engine::poison_handler::DeadLetterEnvelope>,
        default_reason: &str,
    ) -> Result<(), FeederError> {
        for envelope in dead_letters {
            let offset = envelope.original_offset;
            if let Some((delivery_id, subscription)) = self.delivery_of(offset) {
                let reason = envelope
                    .failure_reason
                    .unwrap_or_else(|| default_reason.to_string());
                // Barrière DLQ atomique : persistée avant toute avance du curseur
                self.get_or_create_tracker(&subscription)
                    .record_dead_letter(offset, delivery_id, reason)
                    .await?;
            }
        }
        Ok(())
    }

    /// Traite un refus de consommation (NACK) et gère le retry ou la bascule vers le poison.
    pub async fn handle_nack<F>(
        &mut self,
        offset: u64,
        attempt_id: u32,
        reason: Option<String>,
        is_terminal: bool,
        extractor: F,
    ) -> Result<crate::engine::dispatcher::NackReport, FeederError>
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        let (nack_report, dead_letters, safe_cursor) = {
            let mut disp = self.dispatcher.lock().await;
            let report = if is_terminal {
                disp.handle_terminal_nack(offset, attempt_id, reason.clone(), extractor)
            } else {
                disp.handle_nack(offset, attempt_id, reason.clone(), extractor)
            };
            let dlqs = disp.drain_dead_letters();
            let cursor = disp.safe_cursor();
            (report, dlqs, cursor)
        };

        // Retry programmé : l'échec transitoire est persisté sur la livraison
        if let crate::engine::dispatcher::NackReport::ScheduledRetry { offset, .. } = &nack_report {
            if let Some(delivery_id) = self.delivery_seq_to_id.get(offset).cloned() {
                let params = DeliveryFailureParams {
                    delivery_id,
                    error: reason
                        .clone()
                        .unwrap_or_else(|| "Handler failed".to_string()),
                    retry_delay_seconds: 1,
                };
                let failure: Result<bool, LyxalSurrealError> =
                    self.call_fn("event_delivery_failure", params).await;
                failure.map_err(|e| FeederError::Surreal(Box::new(e)))?;
            }
        }

        self.transfer_dead_letters(dead_letters, "NACK retry budget exhausted")
            .await?;

        // Politique poison Drop : résolution sans enveloppe DLQ
        if let crate::engine::dispatcher::NackReport::RetryExhausted {
            offset: off,
            resolution: crate::engine::poison_handler::PoisonResolution::Resolved,
        } = &nack_report
        {
            if let Some((delivery_id, subscription)) = self.delivery_of(*off) {
                self.get_or_create_tracker(&subscription).record_dropped(
                    *off,
                    delivery_id,
                    "Poison policy drop".to_string(),
                );
            }
        }

        self.flush_trackers(safe_cursor).await?;
        Ok(nack_report)
    }

    /// Exécute un cycle de surveillance des délais d'acquittement : redélivrance, et transfert en
    /// dead letter des messages dont le budget est épuisé.
    pub async fn handle_watchdog_and_poison<F>(
        &mut self,
        now: tokio::time::Instant,
        extractor: F,
    ) -> Result<usize, FeederError>
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        let (dead_letters, safe_cursor) = {
            let mut disp = self.dispatcher.lock().await;
            let _watchdog_report = disp.watchdog_tick(now, extractor);
            let dlqs = disp.drain_dead_letters();
            let cursor = disp.safe_cursor();
            (dlqs, cursor)
        };
        let processed_poison_count = dead_letters.len();
        self.transfer_dead_letters(dead_letters, "Retry budget exhausted")
            .await?;
        self.flush_trackers(safe_cursor).await?;
        Ok(processed_poison_count)
    }

    /// Déclenche l'arrêt gracieux du feeder.
    pub async fn shutdown(&mut self) -> Result<(), FeederError> {
        info!("Arrêt gracieux de l'OutboxFeeder demandé");
        self.cancellation.cancel();

        let safe_cursor = {
            let disp = self.dispatcher.lock().await;
            disp.safe_cursor()
        };

        // Flush final des trackers actifs ; une erreur est remontée, jamais ignorée
        self.flush_trackers(safe_cursor).await
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::dispatcher::{DispatcherConfig, ReliableDispatcher};
    use std::time::Duration;

    #[tokio::test]
    async fn test_feeder_not_leader_rejected() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let lease = Arc::new(OutboxLeaseManager::new(
            client.clone(),
            "node_1",
            Duration::from_secs(5),
        ));
        let cancel = CancellationToken::new();
        let disp_config = DispatcherConfig {
            max_unacked: 10,
            ..Default::default()
        };
        let dispatcher = Arc::new(Mutex::new(ReliableDispatcher::new(disp_config, cancel)));

        let mut feeder = OutboxFeeder::new(client, lease, dispatcher);

        // Pas leader -> rejet immédiat
        let res = feeder
            .assign_and_enqueue(
                &RecordId::new("event_outbox", "evt_1"),
                &RecordId::new("event_subscription", "sub_1"),
                "mod_1",
                serde_json::Value::Null,
                "msg_payload".to_string(),
                |_| (String::new(), serde_json::Value::Null, None),
            )
            .await;

        assert!(matches!(res, Err(FeederError::NotLeader)));
    }

    #[tokio::test]
    async fn test_feeder_backpressure_when_dispatcher_full() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let lease = Arc::new(OutboxLeaseManager::new(
            client.clone(),
            "node_1",
            Duration::from_secs(5),
        ));
        // Force leader flag en mémoire pour le test unitaire
        lease
            .is_leader
            .store(true, std::sync::atomic::Ordering::SeqCst);
        lease
            .generation
            .store(1, std::sync::atomic::Ordering::SeqCst);

        let cancel = CancellationToken::new();
        let disp_config = DispatcherConfig {
            max_unacked: 1, // Capacité 1
            ..Default::default()
        };
        let dispatcher = Arc::new(Mutex::new(ReliableDispatcher::new(disp_config, cancel)));

        // Remplir la capacité du dispatcher
        {
            let mut disp = dispatcher.lock().await;
            disp.submit_message(100, "first_msg".to_string(), |_| {
                (String::new(), serde_json::Value::Null, None)
            })
            .unwrap();
            assert!(!disp.has_capacity());
        }

        let mut feeder = OutboxFeeder::new(client, lease, dispatcher);

        // Tentative d'attribution -> bloquée par la backpressure avant même l'appel RPC !
        let res = feeder
            .assign_and_enqueue(
                &RecordId::new("event_outbox", "evt_2"),
                &RecordId::new("event_subscription", "sub_1"),
                "mod_1",
                serde_json::Value::Null,
                "second_msg".to_string(),
                |_| (String::new(), serde_json::Value::Null, None),
            )
            .await;

        assert!(matches!(res, Err(FeederError::Backpressure)));
    }
}
