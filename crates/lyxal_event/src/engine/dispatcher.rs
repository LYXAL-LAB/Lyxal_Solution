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
//
// Portions of this file are derived from Danube Messaging (danube-broker/src/dispatcher/shared/reliable.rs),
// under Apache-2.0 license. Adapted for Lyxal OS by the Lyxal Development Team.

//! Dispatcher in-process résilient avec load balancing round-robin, supervision Tokio et anti-stale ACKs.
//!
//! Ce module implémente la distribution fiable de messages vers des consommateurs / workers locaux :
//! - Load balancing équitable round-robin avec détection de santé.
//! - Gestion des messages en vol via [`DispatchWindow`] et [`PendingDelivery`].
//! - Contrôle de flux et backpressure sur saturation de la fenêtre.
//! - Protection stricte contre les acquittements tardifs ou périmés (stale ACKs avec `attempt_id`).
//! - Watchdog de surveillance des timeouts d'ACK et réémission automatique avec backoff.
//! - Tolérance aux pannes et bascule immédiate (failover) lors du crash ou de la déconnexion d'un worker.
//! - Routage vers la Dead-Letter Queue (DLQ) sans écriture directe en base de données.
//! - Coopération avec [`CancellationToken`] pour un arrêt gracieux sans perte de messages.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::mpsc;
use tokio::time::Instant;
use tokio_util::sync::CancellationToken;
use tracing::{debug, trace, warn};

use super::dispatch_window::{AckOutcome, DispatchWindow, DispatchWindowError};
use super::pending_delivery::{DeliveryPolicy, PendingDelivery};
use super::poison_handler::{
    resolve_poison_policy, DeadLetterEnvelope, PoisonPolicy, PoisonResolution,
};

/// Message distribué à un travailleur / consommateur.
#[derive(Debug, Clone)]
pub struct DispatchMessage<T> {
    /// Offset / séquence unique du message.
    pub offset: u64,
    /// Numéro de la tentative courante (permet de rejeter les stale ACKs).
    pub attempt_id: u32,
    /// Contenu du message.
    pub message: T,
}

/// Handle représentant un travailleur / consommateur enregistré auprès du dispatcher.
pub struct ConsumerHandle<T> {
    /// Identifiant unique du consommateur (ex: "worker_1", "handler_alpha").
    pub id: String,
    /// Canal de transmission des messages.
    pub sender: mpsc::Sender<DispatchMessage<T>>,
    /// Indicateur de disponibilité atomique.
    pub active: Arc<AtomicBool>,
}

/// Configuration du dispatcher fiable in-process.
#[derive(Debug, Clone)]
pub struct DispatcherConfig {
    /// Capacité maximale de la fenêtre de messages en vol (backpressure).
    pub max_unacked: usize,
    /// Politique de retry et délais d'attente d'ACK.
    pub delivery_policy: DeliveryPolicy,
    /// Politique à appliquer lors de l'épuisement des retries.
    pub poison_policy: PoisonPolicy,
    /// Nom de la souscription logique.
    pub subscription_name: String,
    /// Topic / destination de la Dead-Letter Queue (si DeadLetter policy).
    pub dead_letter_topic: Option<String>,
}

impl Default for DispatcherConfig {
    fn default() -> Self {
        Self {
            max_unacked: 100,
            delivery_policy: DeliveryPolicy::default(),
            poison_policy: PoisonPolicy::DeadLetter,
            subscription_name: "default_subscription".to_string(),
            dead_letter_topic: Some("default.dead_letter".to_string()),
        }
    }
}

/// Rapport de traitement d'un acquittement positif (ACK).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AckReport {
    /// L'ACK a été validé et a fait progresser le curseur contigu sûr (`safe_cursor`).
    Advanced { safe_cursor: u64 },
    /// L'ACK a été enregistré en vol, mais le curseur reste bloqué par un message amont non acquitté.
    Accepted { current_safe_cursor: Option<u64> },
    /// L'ACK reçu est un doublon (offset déjà confirmé ou skippé).
    DuplicateAck(u64),
    /// L'ACK reçu correspond à une tentative obsolète / périmée suite à timeout ou réassignation.
    StaleAttempt {
        offset: u64,
        current_attempt: u32,
        received_attempt: u32,
    },
    /// L'ACK cible un offset inconnu.
    UnknownOffset(u64),
}

/// Rapport de traitement d'un refus explicite (NACK).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NackReport {
    /// Le message a été programmé pour une nouvelle tentative avec backoff.
    ScheduledRetry { offset: u64, next_attempt: u32 },
    /// Le quota de tentatives a été épuisé et la politique de poison a été déclenchée.
    RetryExhausted {
        offset: u64,
        resolution: PoisonResolution,
    },
    /// Le NACK reçu correspond à une tentative obsolète.
    StaleAttempt {
        offset: u64,
        current_attempt: u32,
        received_attempt: u32,
    },
    /// Le NACK cible un offset inconnu.
    UnknownOffset(u64),
}

/// Erreur survenue lors des opérations du dispatcher.
#[derive(Debug, thiserror::Error, Clone, PartialEq, Eq)]
pub enum DispatcherError {
    /// La fenêtre de messages en vol est saturée (backpressure).
    #[error("Dispatch window is full (current: {current}, max: {max})")]
    WindowFull { current: usize, max: usize },
    /// Le dispatcher est en cours d'arrêt coopératif, les nouvelles soumissions sont refusées.
    #[error("Dispatcher is shutting down")]
    ShuttingDown,
    /// Aucun consommateur actif n'est disponible pour recevoir le message.
    #[error("No active consumer available")]
    NoConsumersAvailable,
    /// L'offset proposé a déjà été committé au niveau du safe cursor.
    #[error("Offset {offset} already committed (safe_cursor: {safe_cursor})")]
    OffsetAlreadyCommitted { offset: u64, safe_cursor: u64 },
    /// L'offset est déjà présent en vol dans la fenêtre.
    #[error("Offset {0} is already in-flight")]
    DuplicateInFlightOffset(u64),
    /// Le curseur persisté ne peut plus être restauré : des séquences ont déjà été reçues.
    #[error("Cursor cannot be restored once sequences have been received")]
    CursorAlreadyStarted,
    /// Erreur liée à la résolution du poison.
    #[error("Poison resolution error: {0}")]
    PoisonResolutionError(String),
}

/// Rapport synthétique d'une passe de surveillance du watchdog.
#[derive(Debug, Default, Clone, PartialEq, Eq)]
pub struct WatchdogReport {
    /// Nombre de messages ayant dépassé leur deadline d'ACK.
    pub timed_out_count: usize,
    /// Nombre de messages réexpédiés vers un travailleur.
    pub retried_count: usize,
    /// Nombre de messages ayant épuisé leurs retries et résolus en poison.
    pub exhausted_count: usize,
}

/// Dispatcher in-process résilient avec load balancing round-robin.
pub struct ReliableDispatcher<T> {
    config: DispatcherConfig,
    consumers: Vec<ConsumerHandle<T>>,
    rr_index: usize,
    window: DispatchWindow<T>,
    dead_letters: Vec<DeadLetterEnvelope>,
    cancellation_token: CancellationToken,
}

impl<T: Clone + Send + 'static> ReliableDispatcher<T> {
    /// Crée un nouveau dispatcher avec la configuration et le jeton d'annulation spécifiés.
    pub fn new(config: DispatcherConfig, cancellation_token: CancellationToken) -> Self {
        let max_unacked = config.max_unacked;
        Self {
            config,
            consumers: Vec::new(),
            rr_index: 0,
            window: DispatchWindow::new(max_unacked),
            dead_letters: Vec::new(),
            cancellation_token,
        }
    }

    /// Enregistre un nouveau travailleur / consommateur.
    ///
    /// Retourne un drapeau atomique `Arc<AtomicBool>` permettant au consommateur ou au
    /// superviseur d'activer ou de désactiver sa disponibilité.
    pub fn register_consumer(
        &mut self,
        id: impl Into<String>,
        sender: mpsc::Sender<DispatchMessage<T>>,
    ) -> Arc<AtomicBool> {
        let id_str = id.into();
        let active = Arc::new(AtomicBool::new(true));
        self.consumers.push(ConsumerHandle {
            id: id_str,
            sender,
            active: active.clone(),
        });
        active
    }

    /// Désenregistre un consommateur et déclenche immédiatement la réattribution de tous ses messages en vol.
    pub fn unregister_consumer(&mut self, id: &str) {
        self.consumers.retain(|c| c.id != id);
        // Failover immédiat des messages assignés à ce worker
        self.window
            .force_retry_for_consumer(id, Some("Consumer disconnected".to_string()));
    }

    /// Retourne le nombre de consommateurs actuellement enregistrés et actifs.
    pub fn active_consumer_count(&self) -> usize {
        self.consumers
            .iter()
            .filter(|c| c.active.load(Ordering::Acquire) && !c.sender.is_closed())
            .count()
    }

    /// Indique si la fenêtre dispose de capacité pour accepter de nouveaux messages.
    pub fn has_capacity(&self) -> bool {
        self.window.has_capacity()
    }

    /// Nombre de messages actuellement en vol.
    pub fn in_flight_count(&self) -> usize {
        self.window.in_flight_count()
    }

    /// Curseur contigu sûr actuel.
    pub fn safe_cursor(&self) -> Option<u64> {
        self.window.safe_cursor()
    }

    /// Positionne le curseur sûr sur la valeur persistée, avant toute soumission.
    pub fn restore_cursor(&mut self, cursor: u64) -> Result<(), DispatcherError> {
        self.window
            .restore_cursor(cursor)
            .map_err(|_| DispatcherError::CursorAlreadyStarted)
    }

    /// Résout une séquence qui ne sera jamais soumise (livraison transférée en dead letter
    /// sans passer par la fenêtre), pour qu'elle ne bloque pas le curseur contigu. Une séquence
    /// déjà couverte par le curseur est ignorée.
    pub fn skip_unsubmitted(&mut self, offset: u64) -> Option<u64> {
        if self.window.safe_cursor().is_some_and(|sc| offset <= sc) {
            return None;
        }
        self.window.on_skipped(offset)
    }

    /// Indique si la fenêtre est entièrement vide.
    pub fn is_empty(&self) -> bool {
        self.window.is_empty()
    }

    /// Extrait et vide la file des enveloppes Dead-Letter générées en mémoire.
    pub fn drain_dead_letters(&mut self) -> Vec<DeadLetterEnvelope> {
        std::mem::take(&mut self.dead_letters)
    }

    /// Soumet un nouveau message au dispatcher.
    ///
    /// Si le dispatcher dispose de capacité et de consommateurs actifs, le message est expédié
    /// immédiatement au prochain travailleur en round-robin. Sinon, il est enregistré en attente.
    ///
    /// # Errors
    /// Retourne [`DispatcherError::ShuttingDown`] si le jeton d'annulation est activé.
    /// Retourne [`DispatcherError::WindowFull`] si la fenêtre a atteint sa capacité maximale.
    pub fn submit_message(
        &mut self,
        offset: u64,
        message: T,
        extractor: impl Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    ) -> Result<bool, DispatcherError> {
        if self.cancellation_token.is_cancelled() {
            return Err(DispatcherError::ShuttingDown);
        }

        if !self.window.has_capacity() {
            return Err(DispatcherError::WindowFull {
                current: self.window.in_flight_count(),
                max: self.window.max_capacity(),
            });
        }

        // Un offset refusé par la fenêtre ne doit jamais atteindre un consommateur
        if let Some(safe_cursor) = self.window.safe_cursor() {
            if offset <= safe_cursor {
                return Err(DispatcherError::OffsetAlreadyCommitted {
                    offset,
                    safe_cursor,
                });
            }
        }
        if self.window.get(offset).is_some() {
            return Err(DispatcherError::DuplicateInFlightOffset(offset));
        }

        let mut delivery = PendingDelivery::new(message.clone());

        let (dispatched, dead_ids) = Self::send_round_robin(
            &mut self.consumers,
            &mut self.rr_index,
            self.config.delivery_policy.ack_timeout,
            offset,
            &mut delivery,
            message,
        );
        for dead_id in dead_ids {
            self.unregister_consumer(&dead_id);
        }

        self.window
            .mark_dispatched(offset, delivery)
            .map_err(|e| match e {
                DispatchWindowError::CapacityExceeded { current, max } => {
                    DispatcherError::WindowFull { current, max }
                }
                DispatchWindowError::OffsetAlreadyCommitted {
                    offset,
                    safe_cursor,
                } => DispatcherError::OffsetAlreadyCommitted {
                    offset,
                    safe_cursor,
                },
                DispatchWindowError::DuplicateInFlightOffset(off) => {
                    DispatcherError::DuplicateInFlightOffset(off)
                }
                DispatchWindowError::CursorAlreadyStarted => DispatcherError::CursorAlreadyStarted,
            })?;

        let _ = extractor;
        Ok(dispatched)
    }

    /// Traite un acquittement positif (ACK) reçu d'un travailleur.
    ///
    /// Protège contre les acquittements tardifs en comparant `attempt_id`.
    pub fn handle_ack(&mut self, offset: u64, attempt_id: u32) -> AckReport {
        if let Some(pending) = self.window.get(offset) {
            if pending.delivery_attempt != attempt_id {
                trace!(
                    offset = %offset,
                    current_attempt = %pending.delivery_attempt,
                    received_attempt = %attempt_id,
                    "Stale ACK rejected: attempt mismatch"
                );
                return AckReport::StaleAttempt {
                    offset,
                    current_attempt: pending.delivery_attempt,
                    received_attempt: attempt_id,
                };
            }

            match self.window.on_ack(offset) {
                AckOutcome::Advanced { safe_cursor } => AckReport::Advanced { safe_cursor },
                AckOutcome::Accepted {
                    current_safe_cursor,
                } => AckReport::Accepted {
                    current_safe_cursor,
                },
                AckOutcome::DuplicateAck(o) => AckReport::DuplicateAck(o),
                AckOutcome::UnknownOffset(o) => AckReport::UnknownOffset(o),
            }
        } else {
            // L'offset n'est plus en vol : vérifier s'il s'agit d'un doublon
            match self.window.on_ack(offset) {
                AckOutcome::DuplicateAck(o) => AckReport::DuplicateAck(o),
                _ => AckReport::UnknownOffset(offset),
            }
        }
    }

    /// Traite un refus explicite (NACK) reçu d'un travailleur.
    pub fn handle_nack<F>(
        &mut self,
        offset: u64,
        attempt_id: u32,
        reason: Option<String>,
        extractor: F,
    ) -> NackReport
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        let delivery_policy = self.config.delivery_policy.clone();
        let poison_policy = self.config.poison_policy;
        let subscription_name = self.config.subscription_name.clone();
        let dead_letter_topic = self.config.dead_letter_topic.as_deref();

        let Some(pending) = self.window.get_mut(offset) else {
            return NackReport::UnknownOffset(offset);
        };

        if pending.delivery_attempt != attempt_id {
            trace!(
                offset = %offset,
                current_attempt = %pending.delivery_attempt,
                received_attempt = %attempt_id,
                "Stale NACK rejected: attempt mismatch"
            );
            return NackReport::StaleAttempt {
                offset,
                current_attempt: pending.delivery_attempt,
                received_attempt: attempt_id,
            };
        }

        pending.on_nack(&delivery_policy, reason);

        if pending.is_retry_exhausted() {
            let (resolution, dead_letter) = match resolve_poison_policy(
                pending,
                offset,
                &subscription_name,
                &poison_policy,
                dead_letter_topic,
                &extractor,
            ) {
                Ok(res) => res,
                Err(e) => {
                    warn!(offset = %offset, error = %e, "Poison policy resolution failed");
                    (PoisonResolution::Blocked, None)
                }
            };

            if let Some(dlq) = dead_letter {
                self.dead_letters.push(dlq);
            }

            if resolution == PoisonResolution::Resolved {
                self.window.on_skipped(offset);
            }

            NackReport::RetryExhausted { offset, resolution }
        } else {
            NackReport::ScheduledRetry {
                offset,
                next_attempt: pending.delivery_attempt,
            }
        }
    }

    /// Traite un refus explicite terminal (échec non rejouable).
    ///
    /// Force l'épuisement immédiat des retries et résout le poison (DLQ ou Drop).
    pub fn handle_terminal_nack<F>(
        &mut self,
        offset: u64,
        attempt_id: u32,
        reason: Option<String>,
        extractor: F,
    ) -> NackReport
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        let poison_policy = self.config.poison_policy;
        let subscription_name = self.config.subscription_name.clone();
        let dead_letter_topic = self.config.dead_letter_topic.as_deref();

        let Some(pending) = self.window.get_mut(offset) else {
            return NackReport::UnknownOffset(offset);
        };

        if pending.delivery_attempt != attempt_id {
            trace!(
                offset = %offset,
                current_attempt = %pending.delivery_attempt,
                received_attempt = %attempt_id,
                "Stale terminal NACK rejected: attempt mismatch"
            );
            return NackReport::StaleAttempt {
                offset,
                current_attempt: pending.delivery_attempt,
                received_attempt: attempt_id,
            };
        }

        pending.force_exhaust(reason);

        let (resolution, dead_letter) = match resolve_poison_policy(
            pending,
            offset,
            &subscription_name,
            &poison_policy,
            dead_letter_topic,
            &extractor,
        ) {
            Ok(res) => res,
            Err(e) => {
                warn!(offset = %offset, error = %e, "Poison policy resolution failed");
                (PoisonResolution::Blocked, None)
            }
        };

        if let Some(dlq) = dead_letter {
            self.dead_letters.push(dlq);
        }

        if resolution == PoisonResolution::Resolved {
            let _ = self.window.on_skipped(offset);
        }

        NackReport::RetryExhausted { offset, resolution }
    }

    /// Passe périodique de surveillance du watchdog :
    /// - Détecte les dépassements de délai d'ACK (`ack_deadline_at`).
    /// - Résout les messages en poison si le quota est épuisé.
    /// - Réexpédie les messages prêts (`is_retry_ready`) vers les travailleurs sains.
    pub fn watchdog_tick<F>(&mut self, now: Instant, extractor: F) -> WatchdogReport
    where
        F: Fn(&T) -> (String, serde_json::Value, Option<serde_json::Value>),
    {
        let mut report = WatchdogReport::default();

        let delivery_policy = self.config.delivery_policy.clone();
        let poison_policy = self.config.poison_policy;
        let subscription_name = self.config.subscription_name.clone();
        let dead_letter_topic = self.config.dead_letter_topic.as_deref();

        // 1. Détection des timeouts d'ACK
        let timed_out_offsets = self.window.collect_ack_timed_out(now);
        for offset in timed_out_offsets {
            if let Some(pending) = self.window.get_mut(offset) {
                pending.on_ack_timeout(&delivery_policy);
                report.timed_out_count += 1;

                if pending.is_retry_exhausted() {
                    let (resolution, dead_letter) = match resolve_poison_policy(
                        pending,
                        offset,
                        &subscription_name,
                        &poison_policy,
                        dead_letter_topic,
                        &extractor,
                    ) {
                        Ok(res) => res,
                        Err(e) => {
                            warn!(offset = %offset, error = %e, "Poison resolution failed on timeout");
                            (PoisonResolution::Blocked, None)
                        }
                    };

                    if let Some(dlq) = dead_letter {
                        self.dead_letters.push(dlq);
                    }

                    if resolution == PoisonResolution::Resolved {
                        self.window.on_skipped(offset);
                    }

                    report.exhausted_count += 1;
                }
            }
        }

        // 2. Réémission des messages prêts à être retentés
        let retry_offsets = self.window.collect_retry_ready(now);
        let mut disconnected_all = Vec::new();
        for offset in retry_offsets {
            if let Some(pending) = self.window.get_mut(offset) {
                let msg = pending.message.clone();
                let (sent, dead) = Self::send_round_robin(
                    &mut self.consumers,
                    &mut self.rr_index,
                    delivery_policy.ack_timeout,
                    offset,
                    pending,
                    msg,
                );
                disconnected_all.extend(dead);
                if sent {
                    report.retried_count += 1;
                }
            }
        }

        for dead_id in disconnected_all {
            self.unregister_consumer(&dead_id);
        }

        report
    }

    /// Tente d'expédier un message au prochain consommateur actif via round-robin.
    ///
    /// Retourne `(sent, disconnected_ids)`.
    fn send_round_robin(
        consumers: &mut [ConsumerHandle<T>],
        rr_index: &mut usize,
        ack_timeout: Duration,
        offset: u64,
        pending: &mut PendingDelivery<T>,
        message: T,
    ) -> (bool, Vec<String>) {
        if consumers.is_empty() {
            return (false, Vec::new());
        }

        let num_consumers = consumers.len();
        let mut attempts = 0;
        let mut disconnected_indices = Vec::new();
        let mut sent = false;

        while attempts < num_consumers {
            let idx = *rr_index % num_consumers;
            *rr_index = rr_index.wrapping_add(1);
            attempts += 1;

            let consumer = &mut consumers[idx];

            if !consumer.active.load(Ordering::Acquire) || consumer.sender.is_closed() {
                if consumer.sender.is_closed() {
                    disconnected_indices.push(consumer.id.clone());
                }
                continue;
            }

            // Calcul du prochain attempt_id avant expédition
            let next_attempt_id = pending.delivery_attempt + 1;
            let dispatch_msg = DispatchMessage {
                offset,
                attempt_id: next_attempt_id,
                message: message.clone(),
            };

            match consumer.sender.try_send(dispatch_msg) {
                Ok(()) => {
                    pending.on_send_attempt(&consumer.id, ack_timeout);
                    sent = true;
                    trace!(
                        offset = %offset,
                        consumer_id = %consumer.id,
                        attempt = %pending.delivery_attempt,
                        "Dispatched message to consumer"
                    );
                    break;
                }
                Err(mpsc::error::TrySendError::Full(_)) => {
                    debug!(
                        consumer_id = %consumer.id,
                        "Consumer channel full, trying next consumer"
                    );
                    continue;
                }
                Err(mpsc::error::TrySendError::Closed(_)) => {
                    warn!(
                        consumer_id = %consumer.id,
                        "Consumer channel closed, marking disconnected"
                    );
                    disconnected_indices.push(consumer.id.clone());
                    continue;
                }
            }
        }

        (sent, disconnected_indices)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::pending_delivery::BackoffStrategy;

    fn helper_extractor(msg: &String) -> (String, serde_json::Value, Option<serde_json::Value>) {
        (
            "test.topic".to_string(),
            serde_json::json!({ "content": msg }),
            Some(serde_json::json!({ "trace": "123" })),
        )
    }

    fn test_config() -> DispatcherConfig {
        DispatcherConfig {
            max_unacked: 10,
            delivery_policy: DeliveryPolicy {
                max_redelivery_count: 3,
                ack_timeout: Duration::from_millis(50),
                base_redelivery_delay: Duration::from_millis(20),
                max_redelivery_delay: Duration::from_millis(100),
                backoff_strategy: BackoffStrategy::Fixed,
                jitter: false,
            },
            poison_policy: PoisonPolicy::DeadLetter,
            subscription_name: "test_sub".to_string(),
            dead_letter_topic: Some("test.dlq".to_string()),
        }
    }

    #[test]
    fn test_dispatcher_multi_consumer_nominal() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx1, mut rx1) = mpsc::channel(10);
        let (tx2, mut rx2) = mpsc::channel(10);
        let (tx3, mut rx3) = mpsc::channel(10);

        dispatcher.register_consumer("worker_1", tx1);
        dispatcher.register_consumer("worker_2", tx2);
        dispatcher.register_consumer("worker_3", tx3);

        for offset in 1..=6 {
            let res = dispatcher.submit_message(offset, format!("msg_{offset}"), helper_extractor);
            assert!(res.is_ok(), "Submit should succeed");
            assert!(res.unwrap(), "Message should be dispatched immediately");
        }

        let mut counts = [0usize; 3];
        while let Ok(msg) = rx1.try_recv() {
            counts[0] += 1;
            assert!(msg.offset <= 6);
        }
        while let Ok(msg) = rx2.try_recv() {
            counts[1] += 1;
            assert!(msg.offset <= 6);
        }
        while let Ok(msg) = rx3.try_recv() {
            counts[2] += 1;
            assert!(msg.offset <= 6);
        }

        assert_eq!(
            counts,
            [2, 2, 2],
            "Load should be balanced round-robin 2 each"
        );
    }

    #[test]
    fn test_dispatcher_ack_advances_window() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "msg1".into(), helper_extractor)
            .unwrap();
        dispatcher
            .submit_message(2, "msg2".into(), helper_extractor)
            .unwrap();

        let msg1 = rx.try_recv().unwrap();
        let msg2 = rx.try_recv().unwrap();

        let ack1 = dispatcher.handle_ack(msg1.offset, msg1.attempt_id);
        assert_eq!(ack1, AckReport::Advanced { safe_cursor: 1 });
        assert_eq!(dispatcher.safe_cursor(), Some(1));

        let ack2 = dispatcher.handle_ack(msg2.offset, msg2.attempt_id);
        assert_eq!(ack2, AckReport::Advanced { safe_cursor: 2 });
        assert_eq!(dispatcher.safe_cursor(), Some(2));
        assert!(dispatcher.is_empty());
    }

    #[test]
    fn test_dispatcher_nack_reschedules_redelivery() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "msg1".into(), helper_extractor)
            .unwrap();
        let msg = rx.try_recv().unwrap();

        let nack_res = dispatcher.handle_nack(
            msg.offset,
            msg.attempt_id,
            Some("Transient network error".into()),
            helper_extractor,
        );
        assert_eq!(
            nack_res,
            NackReport::ScheduledRetry {
                offset: 1,
                next_attempt: 1
            }
        );

        let report =
            dispatcher.watchdog_tick(Instant::now() + Duration::from_millis(30), helper_extractor);
        assert_eq!(report.retried_count, 1);

        let retried_msg = rx.try_recv().unwrap();
        assert_eq!(retried_msg.offset, 1);
        assert_eq!(retried_msg.attempt_id, 2);
    }

    #[test]
    fn test_dispatcher_out_of_order_acks() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        dispatcher
            .submit_message(2, "m2".into(), helper_extractor)
            .unwrap();
        dispatcher
            .submit_message(3, "m3".into(), helper_extractor)
            .unwrap();

        let m1 = rx.try_recv().unwrap();
        let m2 = rx.try_recv().unwrap();
        let m3 = rx.try_recv().unwrap();

        // ACK 1
        let ack1 = dispatcher.handle_ack(m1.offset, m1.attempt_id);
        assert_eq!(ack1, AckReport::Advanced { safe_cursor: 1 });

        // ACK 3 before 2
        let ack3 = dispatcher.handle_ack(m3.offset, m3.attempt_id);
        assert_eq!(
            ack3,
            AckReport::Accepted {
                current_safe_cursor: Some(1)
            }
        );
        assert_eq!(dispatcher.safe_cursor(), Some(1));

        // ACK 2 resolves gap -> cursor jumps straight to 3
        let ack2 = dispatcher.handle_ack(m2.offset, m2.attempt_id);
        assert_eq!(ack2, AckReport::Advanced { safe_cursor: 3 });
        assert_eq!(dispatcher.safe_cursor(), Some(3));
    }

    #[test]
    fn test_dispatcher_duplicate_acks() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        let m1 = rx.try_recv().unwrap();

        let ack1 = dispatcher.handle_ack(m1.offset, m1.attempt_id);
        assert_eq!(ack1, AckReport::Advanced { safe_cursor: 1 });

        // Duplicate ACK
        let ack_dup = dispatcher.handle_ack(m1.offset, m1.attempt_id);
        assert_eq!(ack_dup, AckReport::DuplicateAck(1));
    }

    #[tokio::test]
    async fn test_dispatcher_stale_ack_rejected() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        let m1 = rx.try_recv().unwrap();
        assert_eq!(m1.attempt_id, 1);

        // Sleep until ACK timeout (50ms) expires
        tokio::time::sleep(Duration::from_millis(60)).await;
        let rep1 = dispatcher.watchdog_tick(Instant::now(), helper_extractor);
        assert_eq!(rep1.timed_out_count, 1);

        // Sleep until retry delay (20ms) expires
        tokio::time::sleep(Duration::from_millis(30)).await;
        let rep2 = dispatcher.watchdog_tick(Instant::now(), helper_extractor);
        assert_eq!(rep2.retried_count, 1);

        let m1_retry = rx.try_recv().unwrap();
        assert_eq!(m1_retry.attempt_id, 2);

        // Late ACK from attempt 1 arrives -> must be rejected as StaleAttempt
        let stale_ack = dispatcher.handle_ack(1, 1);
        assert_eq!(
            stale_ack,
            AckReport::StaleAttempt {
                offset: 1,
                current_attempt: 2,
                received_attempt: 1,
            }
        );
        assert_eq!(dispatcher.safe_cursor(), None);

        // Valid ACK from attempt 2 arrives -> accepted
        let valid_ack = dispatcher.handle_ack(1, 2);
        assert_eq!(valid_ack, AckReport::Advanced { safe_cursor: 1 });
        assert_eq!(dispatcher.safe_cursor(), Some(1));
    }

    #[test]
    fn test_dispatcher_handler_timeout() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, _rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();

        let report =
            dispatcher.watchdog_tick(Instant::now() + Duration::from_millis(60), helper_extractor);
        assert_eq!(report.timed_out_count, 1);
        assert_eq!(report.exhausted_count, 0);
    }

    #[test]
    fn test_dispatcher_handler_panic_recovery() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx1, rx1) = mpsc::channel(10);
        let (tx2, mut rx2) = mpsc::channel(10);

        dispatcher.register_consumer("failing_worker", tx1);
        dispatcher.register_consumer("healthy_worker", tx2);

        // Drop rx1 to simulate task panic / channel drop
        drop(rx1);

        // Submit message: try_send to failing_worker fails because channel is closed.
        // Failing worker is marked disconnected, and message is routed to healthy_worker.
        let dispatched = dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        assert!(dispatched, "Message should be routed to healthy worker");

        let m = rx2.try_recv().expect("Healthy worker must receive message");
        assert_eq!(m.offset, 1);
        assert_eq!(dispatcher.active_consumer_count(), 1);
    }

    #[test]
    fn test_dispatcher_consumer_disconnect_failover() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx1, mut rx1) = mpsc::channel(10);
        let (tx2, mut rx2) = mpsc::channel(10);

        dispatcher.register_consumer("w1", tx1);
        dispatcher.register_consumer("w2", tx2);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        let m1 = rx1.try_recv().unwrap();
        assert_eq!(m1.offset, 1);

        // Disconnect w1 while m1 is in flight
        dispatcher.unregister_consumer("w1");
        assert_eq!(dispatcher.active_consumer_count(), 1);

        // Watchdog tick réexpédie immédiatement m1 à w2
        let report = dispatcher.watchdog_tick(Instant::now(), helper_extractor);
        assert_eq!(report.retried_count, 1);

        let m1_reassigned = rx2.try_recv().expect("w2 must receive reassigned message");
        assert_eq!(m1_reassigned.offset, 1);
        assert_eq!(m1_reassigned.attempt_id, 2);
    }

    #[test]
    fn test_dispatcher_retry_exhaustion_to_poison() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "bad_msg".into(), helper_extractor)
            .unwrap();

        // Tentative 1
        let m1 = rx.try_recv().unwrap();
        let rep1 = dispatcher.handle_nack(
            m1.offset,
            m1.attempt_id,
            Some("err1".into()),
            helper_extractor,
        );
        assert!(matches!(rep1, NackReport::ScheduledRetry { .. }));

        // Tick retry -> Tentative 2
        dispatcher.watchdog_tick(Instant::now() + Duration::from_millis(30), helper_extractor);
        let m2 = rx.try_recv().unwrap();
        let rep2 = dispatcher.handle_nack(
            m2.offset,
            m2.attempt_id,
            Some("err2".into()),
            helper_extractor,
        );
        assert!(matches!(rep2, NackReport::ScheduledRetry { .. }));

        // Tick retry -> Tentative 3 (max_redelivery_count = 3)
        dispatcher.watchdog_tick(Instant::now() + Duration::from_millis(60), helper_extractor);
        let m3 = rx.try_recv().unwrap();
        let rep3 = dispatcher.handle_nack(
            m3.offset,
            m3.attempt_id,
            Some("err3".into()),
            helper_extractor,
        );

        // Exhaustion!
        assert_eq!(
            rep3,
            NackReport::RetryExhausted {
                offset: 1,
                resolution: PoisonResolution::Resolved
            }
        );
        assert_eq!(dispatcher.safe_cursor(), Some(1));
    }

    #[test]
    fn test_dispatcher_dlq_envelope_generation() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(42, "poison_payload".into(), helper_extractor)
            .unwrap();

        // Forcer 3 NACKs
        for _ in 0..3 {
            let m = rx.try_recv().unwrap();
            let _ = dispatcher.handle_nack(
                m.offset,
                m.attempt_id,
                Some("Fatal crash".into()),
                helper_extractor,
            );
            dispatcher.watchdog_tick(
                Instant::now() + Duration::from_millis(100),
                helper_extractor,
            );
        }

        let dlqs = dispatcher.drain_dead_letters();
        assert_eq!(dlqs.len(), 1, "One DLQ envelope must be generated");

        let dlq = &dlqs[0];
        assert_eq!(dlq.original_offset, 42);
        assert_eq!(dlq.original_event_type, "test.topic");
        assert_eq!(dlq.subscription_name, "test_sub");
        assert_eq!(dlq.dead_letter_topic, "test.dlq");
        assert_eq!(dlq.failure_reason, Some("Fatal crash".into()));

        let meta = dlq.metadata.as_object().unwrap();
        assert_eq!(meta.get("x-original-topic").unwrap(), "test.topic");
        assert_eq!(meta.get("x-original-offset").unwrap(), "42");
        assert_eq!(meta.get("x-original-subscription").unwrap(), "test_sub");
        assert_eq!(meta.get("x-poison-policy").unwrap(), "dead_letter");
        assert_eq!(meta.get("x-failure-reason").unwrap(), "Fatal crash");
    }

    #[test]
    fn test_dispatcher_window_saturation_backpressure() {
        let cancel = CancellationToken::new();
        let mut cfg = test_config();
        cfg.max_unacked = 2; // Capacité réduite à 2
        let mut dispatcher = ReliableDispatcher::<String>::new(cfg, cancel);

        let (tx, _rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        assert!(dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .is_ok());
        assert!(dispatcher
            .submit_message(2, "m2".into(), helper_extractor)
            .is_ok());

        // La fenêtre est pleine (2/2) -> le 3ème doit être refusé
        let err = dispatcher
            .submit_message(3, "m3".into(), helper_extractor)
            .expect_err("Window saturation must reject with WindowFull");

        assert_eq!(err, DispatcherError::WindowFull { current: 2, max: 2 });
    }

    #[test]
    fn test_dispatcher_cooperative_shutdown() {
        let cancel = CancellationToken::new();
        let mut dispatcher = ReliableDispatcher::<String>::new(test_config(), cancel.clone());

        let (tx, _rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "m1".into(), helper_extractor)
            .unwrap();
        assert_eq!(dispatcher.in_flight_count(), 1);

        // Déclenchement de l'annulation
        cancel.cancel();

        // Les nouvelles soumissions doivent être refusées
        let err = dispatcher
            .submit_message(2, "m2".into(), helper_extractor)
            .expect_err("Submission after cancel must fail with ShuttingDown");
        assert_eq!(err, DispatcherError::ShuttingDown);

        // Les messages en vol restent présents et intacts pour le drain
        assert_eq!(dispatcher.in_flight_count(), 1);
    }

    #[test]
    fn test_dispatcher_unresolved_failure_blocks_cursor() {
        let cancel = CancellationToken::new();
        let mut cfg = test_config();
        cfg.poison_policy = PoisonPolicy::Block; // Politique BLOCK
        let mut dispatcher = ReliableDispatcher::<String>::new(cfg, cancel);

        let (tx, mut rx) = mpsc::channel(10);
        dispatcher.register_consumer("w1", tx);

        dispatcher
            .submit_message(1, "poison".into(), helper_extractor)
            .unwrap();
        dispatcher
            .submit_message(2, "normal".into(), helper_extractor)
            .unwrap();

        let m1 = rx.try_recv().unwrap();
        let m2 = rx.try_recv().unwrap();

        // Message 2 est ACKé
        let ack2 = dispatcher.handle_ack(m2.offset, m2.attempt_id);
        assert_eq!(
            ack2,
            AckReport::Accepted {
                current_safe_cursor: None
            }
        );

        // Message 1 épuise ses retries
        for _ in 0..3 {
            let _ = dispatcher.handle_nack(
                m1.offset,
                m1.attempt_id,
                Some("block error".into()),
                helper_extractor,
            );
            dispatcher.watchdog_tick(
                Instant::now() + Duration::from_millis(100),
                helper_extractor,
            );
        }

        // Le curseur contigu reste impérativement bloqué à None !
        assert_eq!(
            dispatcher.safe_cursor(),
            None,
            "Block policy must halt safe cursor progression"
        );
        assert_eq!(
            dispatcher.in_flight_count(),
            1,
            "Blocked message remains in flight"
        );
    }
}
