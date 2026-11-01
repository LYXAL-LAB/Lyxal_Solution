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

//! Suivi et réconciliation de la progression durable par abonnement (`SubscriptionProgressTracker`).
//!
//! Ce composant fait le pont entre les acquittements en mémoire (Lots 1 & 2) et la persistance
//! transactionnelle dans SurrealDB 3.2.0 (Lot 3B.1).
//!
//! # Invariants de Sûreté
//! - La progression mémoire n'est JAMAIS confondue avec la progression durable (`last_persisted_cursor`).
//! - Une livraison n'est considérée comme `dead_letter` qu'après confirmation préalable et durable
//!   dans `event_dead_letter` via `fn::event_dead_letter_transfer` (Barrière DLQ).
//! - En cas d'échec transitoire ou de commit ambigu, les résultats en attente sont strictement conservés
//!   et réconciliés par relecture durable (`fn::event_progress_get`) avant toute nouvelle tentative.
//! - Tout rejet de fencing (`EVENT_STALE_LEADER_FENCED`) annule immédiatement le jeton local.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use std::collections::{BTreeMap, HashSet};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use thiserror::Error;
use tokio_util::sync::CancellationToken;
use tracing::{debug, info, warn};

use super::dto::{
    DeadLetterTransferParams, DeadLetterTransferResult, FlushBatchParams, FlushBatchResult,
    ProgressGetParams, ProgressGetResult,
};

/// Erreurs de suivi de la progression.
#[derive(Debug, Error)]
pub enum ProgressError {
    /// Erreur SurrealDB.
    #[error("Erreur SurrealDB lors du flush de progression: {0}")]
    Surreal(Box<LyxalSurrealError>),

    /// Rejet transactionnel par le Fencing.
    #[error("Opération de progression rejetée par le Fencing (leader évincé)")]
    Fenced,

    /// Échec de la barrière DLQ.
    #[error("Échec de la barrière DLQ pour la livraison {delivery_id}: {reason}")]
    DlqBarrierFailed { delivery_id: String, reason: String },

    /// Invariant de curseur violé (non-monotone, trou ou séquences non résolues).
    #[error("Violation d'invariant de curseur: {0}")]
    InvariantViolation(String),

    /// Autre erreur interne.
    #[error("Erreur interne du tracker de progression: {0}")]
    Internal(String),
}

impl From<LyxalSurrealError> for ProgressError {
    fn from(err: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(err))
    }
}

/// Gestionnaire de suivi et de flush durable pour un abonnement spécifique.
pub struct SubscriptionProgressTracker {
    client: Surreal<Any>,
    subscription: String,
    node_id: String,
    generation: Arc<AtomicU64>,
    lease_cancellation: CancellationToken,

    // État durable confirmé
    last_persisted_cursor: u64,
    last_assigned_seq: u64,

    // Buffers mémoire des résolutions en attente de flush
    delivered_ids: Vec<String>,
    dead_letter_ids: Vec<String>,
    dropped_ids: Vec<String>,
    drop_reason: Option<String>,

    // Indexation séquence -> delivery_id pour validation d'intégrité
    seq_map: BTreeMap<u64, String>,
    recorded_ids: HashSet<String>,
}

#[async_trait]
impl LyxalSurrealCall for SubscriptionProgressTracker {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

impl SubscriptionProgressTracker {
    /// Crée un nouveau tracker de progression pour un abonnement donné.
    pub fn new(
        client: Surreal<Any>,
        subscription: impl Into<String>,
        node_id: impl Into<String>,
        generation: Arc<AtomicU64>,
        lease_cancellation: CancellationToken,
    ) -> Self {
        Self {
            client,
            subscription: subscription.into(),
            node_id: node_id.into(),
            generation,
            lease_cancellation,
            last_persisted_cursor: 0,
            last_assigned_seq: 0,
            delivered_ids: Vec::new(),
            dead_letter_ids: Vec::new(),
            dropped_ids: Vec::new(),
            drop_reason: None,
            seq_map: BTreeMap::new(),
            recorded_ids: HashSet::new(),
        }
    }

    /// Curseur durable confirmé en base de données.
    pub fn last_persisted_cursor(&self) -> u64 {
        self.last_persisted_cursor
    }

    /// Dernière séquence allouée connue.
    pub fn last_assigned_seq(&self) -> u64 {
        self.last_assigned_seq
    }

    /// Nombre total de résolutions en attente de flush.
    pub fn pending_resolutions_count(&self) -> usize {
        self.delivered_ids.len() + self.dead_letter_ids.len() + self.dropped_ids.len()
    }

    /// Relit l'état durable en base via `fn::event_progress_get` (utilisé au boot ou après reprise).
    pub async fn recover_durable_state(&mut self) -> Result<ProgressGetResult, ProgressError> {
        let params = ProgressGetParams {
            subscription: self.subscription.clone(),
        };

        let result: ProgressGetResult = self.call_fn("event_progress_get", params).await?;
        self.last_persisted_cursor = result.last_persisted_cursor;
        self.last_assigned_seq = result.last_assigned_seq;

        info!(
            subscription = %self.subscription,
            persisted_cursor = self.last_persisted_cursor,
            assigned_seq = self.last_assigned_seq,
            "Progression durable récupérée avec succès depuis SurrealDB"
        );

        Ok(result)
    }

    /// Enregistre un acquittement positif (delivered) pour une séquence.
    pub fn record_delivered(&mut self, seq: u64, delivery_id: String) {
        if self.recorded_ids.insert(delivery_id.clone()) {
            self.delivered_ids.push(delivery_id.clone());
            self.seq_map.insert(seq, delivery_id);
        }
    }

    /// Enregistre une livraison empoisonnée (dead-letter) sous garantie de Barrière DLQ.
    ///
    /// Cette méthode persiste d'abord l'enregistrement dans `event_dead_letter`
    /// via `fn::event_dead_letter_transfer`. Si le transfert échoue, la résolution n'est PAS
    /// enregistrée pour le flush du curseur.
    pub async fn record_dead_letter(
        &mut self,
        seq: u64,
        delivery_id: String,
        error_msg: String,
    ) -> Result<DeadLetterTransferResult, ProgressError> {
        if self.lease_cancellation.is_cancelled() {
            return Err(ProgressError::Fenced);
        }

        let gen = self.generation.load(Ordering::SeqCst);
        let params = DeadLetterTransferParams {
            delivery_id: delivery_id.clone(),
            error: error_msg.clone(),
            node_id: self.node_id.clone(),
            generation: gen,
        };

        let dlq_res: Result<DeadLetterTransferResult, LyxalSurrealError> =
            self.call_fn("event_dead_letter_transfer", params).await;

        match dlq_res {
            Ok(result) => {
                if self.recorded_ids.insert(delivery_id.clone()) {
                    self.dead_letter_ids.push(delivery_id.clone());
                    self.seq_map.insert(seq, delivery_id);
                }
                Ok(result)
            }
            Err(e) => {
                let err_str = e.to_string();
                if err_str.contains("EVENT_STALE_LEADER_FENCED") {
                    self.lease_cancellation.cancel();
                    Err(ProgressError::Fenced)
                } else {
                    Err(ProgressError::DlqBarrierFailed {
                        delivery_id,
                        reason: err_str,
                    })
                }
            }
        }
    }

    /// Enregistre un abandon volontaire (dropped) selon la politique de Poison.
    pub fn record_dropped(&mut self, seq: u64, delivery_id: String, reason: String) {
        if self.recorded_ids.insert(delivery_id.clone()) {
            self.dropped_ids.push(delivery_id.clone());
            self.seq_map.insert(seq, delivery_id);
            self.drop_reason = Some(reason);
        }
    }

    /// Effectue le flush granulaire vers SurrealDB 3.2.0 et avance le curseur contigu sûr.
    ///
    /// # Garantie de Robustesse
    /// Si l'appel échoue (conflit MVCC ou réseau), les résolutions mémoires sont STRICTEMENT conservées.
    /// Une réconciliation par relecture durable (`recover_durable_state`) est tentée pour détecter
    /// si le commit a effectivement été validé malgré une coupure de socket.
    pub async fn flush_progress(
        &mut self,
        target_cursor: u64,
    ) -> Result<FlushBatchResult, ProgressError> {
        if target_cursor <= self.last_persisted_cursor {
            // Rien à avancer
            return Ok(FlushBatchResult {
                flushed: true,
                persisted_cursor: self.last_persisted_cursor,
                delivered_count: 0,
                dead_letter_count: 0,
                dropped_count: 0,
            });
        }

        if self.lease_cancellation.is_cancelled() {
            return Err(ProgressError::Fenced);
        }

        let gen = self.generation.load(Ordering::SeqCst);
        let params = FlushBatchParams {
            subscription: self.subscription.clone(),
            target_cursor,
            node_id: self.node_id.clone(),
            generation: gen,
            delivered_ids: self.delivered_ids.clone(),
            dead_letter_ids: self.dead_letter_ids.clone(),
            dropped_ids: self.dropped_ids.clone(),
            drop_reason: self.drop_reason.clone(),
        };

        let flush_res: Result<FlushBatchResult, LyxalSurrealError> =
            self.call_fn("event_flush_batch", params).await;

        match flush_res {
            Ok(result) => {
                self.last_persisted_cursor = result.persisted_cursor;
                // Nettoyage des IDs confirmés
                self.clear_flushed_resolutions(target_cursor);
                debug!(
                    subscription = %self.subscription,
                    persisted_cursor = self.last_persisted_cursor,
                    "Flush batch exécuté et curseur durable avancé avec succès"
                );
                Ok(result)
            }
            Err(e) => {
                let err_str = e.to_string();
                if err_str.contains("EVENT_STALE_LEADER_FENCED") {
                    self.lease_cancellation.cancel();
                    return Err(ProgressError::Fenced);
                }

                warn!(
                    subscription = %self.subscription,
                    error = %err_str,
                    "Échec de l'appel flush_batch — tentative de réconciliation durable"
                );

                // Réconciliation par relecture durable (en cas de commit ambigu)
                if let Ok(rec) = self.recover_durable_state().await {
                    if rec.last_persisted_cursor >= target_cursor {
                        info!(
                            subscription = %self.subscription,
                            persisted_cursor = rec.last_persisted_cursor,
                            "Réconciliation réussie : le commit ambigu était en fait validé !"
                        );
                        self.clear_flushed_resolutions(rec.last_persisted_cursor);
                        return Ok(FlushBatchResult {
                            flushed: true,
                            persisted_cursor: rec.last_persisted_cursor,
                            delivered_count: 0,
                            dead_letter_count: 0,
                            dropped_count: 0,
                        });
                    }
                }

                // Si le commit n'était pas passé, on conserve intacts les buffers pour le prochain cycle
                Err(ProgressError::Surreal(Box::new(e)))
            }
        }
    }

    fn clear_flushed_resolutions(&mut self, target_cursor: u64) {
        // Supprime les résolutions <= target_cursor
        let confirmed_ids: Vec<String> = self
            .seq_map
            .range(..=target_cursor)
            .map(|(_, id)| id.clone())
            .collect();

        let confirmed_set: HashSet<String> = confirmed_ids.into_iter().collect();

        self.delivered_ids.retain(|id| !confirmed_set.contains(id));
        self.dead_letter_ids
            .retain(|id| !confirmed_set.contains(id));
        self.dropped_ids.retain(|id| !confirmed_set.contains(id));
        self.recorded_ids.retain(|id| !confirmed_set.contains(id));

        self.seq_map.retain(|seq, _| *seq > target_cursor);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_progress_tracker_buffer_and_clear() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let cancel = CancellationToken::new();
        let gen = Arc::new(AtomicU64::new(1));
        let mut tracker =
            SubscriptionProgressTracker::new(client, "test_sub", "test_node", gen, cancel);

        assert_eq!(tracker.last_persisted_cursor(), 0);
        assert_eq!(tracker.pending_resolutions_count(), 0);

        // Record out-of-order ACKs
        tracker.record_delivered(3, "del_3".to_string());
        tracker.record_delivered(1, "del_1".to_string());
        tracker.record_dropped(2, "del_2".to_string(), "ttl_expired".to_string());
        tracker.record_delivered(4, "del_4".to_string());

        assert_eq!(tracker.pending_resolutions_count(), 4);

        // Clear flushed up to sequence 2
        tracker.clear_flushed_resolutions(2);
        assert_eq!(tracker.pending_resolutions_count(), 2);
        assert_eq!(
            tracker.delivered_ids,
            vec!["del_3".to_string(), "del_4".to_string()]
        );

        // Clear remaining
        tracker.clear_flushed_resolutions(4);
        assert_eq!(tracker.pending_resolutions_count(), 0);
    }

    #[tokio::test]
    async fn test_progress_tracker_fenced_rejection() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let cancel = CancellationToken::new();
        let gen = Arc::new(AtomicU64::new(1));
        let mut tracker =
            SubscriptionProgressTracker::new(client, "test_sub", "test_node", gen, cancel.clone());

        cancel.cancel(); // Simulate lease revocation

        let dlq_res = tracker
            .record_dead_letter(1, "del_1".to_string(), "err".to_string())
            .await;
        assert!(matches!(dlq_res, Err(ProgressError::Fenced)));

        let flush_res = tracker.flush_progress(5).await;
        assert!(matches!(flush_res, Err(ProgressError::Fenced)));
    }
}
