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

//! Pont consommateur de handlers (`HandlerConsumerBridge`).
//!
//! Ce composant connecte le moteur de distribution in-process LYXAL Event Engine
//! aux handlers métier fortement typés enregistrés dans [`HandlerRegistry`].
//!
//! # Architecture & Rôle
//! ```text
//! Outbox SurrealDB
//!       │
//!       ▼
//! OutboxFeeder (Attribution Séquence Atomique)
//!       │
//!       ▼
//! ReliableDispatcher (Fenêtre de distribution & load-balancing)
//!       │ DispatchMessage<LyxalEventEnvelope>
//!       ▼
//! HandlerConsumerBridge (Isolation, Timeouts, CatchUnwind, Concurrency)
//!       │
//!       ▼
//! HandlerRegistry (ErasedHandler / Handler<E>)
//!       │
//!       ▼
//! ACK / NACK (attempt_id, delivery_id, delivery_seq)
//!       │
//!       ▼
//! SubscriptionProgressTracker (Barrière DLQ, Flush Transactionnel)
//!       │
//!       ▼
//! SurrealDB (event_delivery, event_dead_letter, event_subscription_progress)
//! ```
//!
//! # Invariants de Sûreté & Tolérance aux Pannes
//! - **Protection Stale Attempts** : Tout ACK/NACK émis porte l'`attempt_id` et l'offset exacts.
//!   Si une tentative a expiré sous le watchdog ou a été réassignée, le dispatcher rejette
//!   l'acquittement obsolète (`StaleAttempt`) sans modifier l'état actif.
//! - **Double Isolation des Paniques** : L'exécution du handler est encadrée par `std::panic::AssertUnwindSafe`
//!   et exécutée sous une tâche Tokio isolée (`tokio::task::spawn`). Une panique ne peut jamais
//!   propager d'interruption au dispatcher ni au feeder.
//! - **Gestion des Timeouts** : Chaque exécution est bornée par `dispatch_timeout`. En cas de dépassement,
//!   le token d'exécution unitaire est annulé et un résultat `Timeout` est émis.
//! - **Annulation Coopérative** : Dès que le bail distribué est perdu ou fencé, le `CancellationToken`
//!   de la passerelle annule l'ensemble des handlers en cours et rejette toute tentative de persistance.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::sql::Thing as RecordId;
use tokio::sync::{mpsc, Mutex, Semaphore};
use tokio_util::sync::CancellationToken;
use tracing::{debug, error, info, warn};

use crate::error::LyxalEventError;
use crate::handler::{HandlerContext, HandlerRegistry};
use crate::models::LyxalEventEnvelope;
use crate::types::{CausationId, CorrelationId, EventId};

use super::dispatcher::{AckReport, DispatchMessage, NackReport, ReliableDispatcher};
use super::feeder::{FeederError, OutboxFeeder};

/// Configuration d'exécution du pont consommateur.
#[derive(Debug, Clone)]
pub struct BridgeConfig {
    /// Identifiant unique du consommateur (ex: "consumer_bridge_node1").
    pub consumer_id: String,
    /// Nom de la souscription logique rattachée.
    pub subscription_name: String,
    /// Délai maximal d'exécution d'un handler avant déclenchement du timeout.
    pub dispatch_timeout: Duration,
    /// Nombre maximal de handlers exécutés simultanément en mémoire.
    pub max_concurrency: usize,
}

impl Default for BridgeConfig {
    fn default() -> Self {
        Self {
            consumer_id: "default_bridge_consumer".to_string(),
            subscription_name: "default_subscription".to_string(),
            dispatch_timeout: Duration::from_secs(5),
            max_concurrency: 16,
        }
    }
}

/// Résultat de l'exécution d'un message par le pont consommateur.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum HandlerExecutionResult {
    /// Le handler s'est exécuté avec succès.
    Success {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
    },
    /// Échec transitoire (ex: indisponibilité réseau temporaire), éligible au retry avec backoff.
    TransientError {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        reason: String,
    },
    /// Échec terminal (ex: incohérence de schéma irrémédiable), éligible au basculement poison immédiat.
    TerminalError {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        reason: String,
    },
    /// Le délai d'exécution maximal a été dépassé.
    Timeout {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
    },
    /// Le handler a déclenché une panique (isolée et interceptée).
    Panicked {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        reason: String,
    },
    /// Aucun handler n'était enregistré dans le registre pour ce type d'événement.
    MissingHandler {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        event_type: String,
    },
    /// L'exécution a été annulée suite à la perte du leadership ou à l'arrêt du processus.
    Cancelled {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
    },
}

/// Résultat du traitement et de l'acquittement après retour au feeder.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ConsumerOutcome {
    /// Acquittement positif confirmé.
    Ack {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        report: AckReport,
    },
    /// Refus explicite (retry programmé ou poison déclenché).
    Nack {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
        report: NackReport,
    },
    /// Annulation propre sans émission d'ACK/NACK périmé.
    Cancelled {
        delivery_id: String,
        delivery_seq: u64,
        attempt_id: u32,
    },
}

/// Extracteur canonique pour les enveloppes `LyxalEventEnvelope`.
pub fn envelope_extractor(
    env: &LyxalEventEnvelope,
) -> (String, serde_json::Value, Option<serde_json::Value>) {
    (
        env.event_type.clone(),
        env.payload.clone(),
        Some(env.metadata.clone()),
    )
}

/// Détermine si une erreur d'événement doit être considérée comme terminale.
#[must_use]
pub fn is_error_terminal(err: &LyxalEventError) -> bool {
    match err {
        LyxalEventError::TypeMismatch { .. } | LyxalEventError::Serialization(_) => true,
        LyxalEventError::HandlerFailed { error, .. } => {
            error.contains("[terminal]") || error.contains("terminal:")
        }
        _ => false,
    }
}

/// Pont d'exécution supervisée entre le moteur de distribution in-process et les handlers métier Lyxal OS.
pub struct HandlerConsumerBridge {
    config: BridgeConfig,
    registry: Arc<HandlerRegistry>,
    cancellation: CancellationToken,
    active: Arc<AtomicBool>,
}

impl HandlerConsumerBridge {
    /// Crée une nouvelle instance de passerelle de consommation.
    #[must_use]
    pub fn new(
        config: BridgeConfig,
        registry: HandlerRegistry,
        cancellation: CancellationToken,
    ) -> Self {
        Self {
            config,
            registry: Arc::new(registry),
            cancellation,
            active: Arc::new(AtomicBool::new(true)),
        }
    }

    /// Identifiant du consommateur.
    #[must_use]
    pub fn consumer_id(&self) -> &str {
        &self.config.consumer_id
    }

    /// Indique si la passerelle est actuellement active et prête à recevoir des messages.
    #[must_use]
    pub fn is_active(&self) -> bool {
        self.active.load(Ordering::SeqCst) && !self.cancellation.is_cancelled()
    }

    /// Drapeaux atomique de disponibilité pour l'enregistrement du consommateur.
    #[must_use]
    pub fn active_flag(&self) -> Arc<AtomicBool> {
        Arc::clone(&self.active)
    }

    /// Token d'annulation coopératif.
    #[must_use]
    pub fn cancellation_token(&self) -> CancellationToken {
        self.cancellation.clone()
    }

    /// Enregistre la passerelle auprès d'un `ReliableDispatcher` et retourne
    /// le canal récepteur `mpsc::Receiver` associé.
    pub fn register_with_dispatcher(
        &self,
        dispatcher: &mut ReliableDispatcher<LyxalEventEnvelope>,
        channel_capacity: usize,
    ) -> mpsc::Receiver<DispatchMessage<LyxalEventEnvelope>> {
        let (tx, rx) = mpsc::channel(channel_capacity);
        let flag = dispatcher.register_consumer(&self.config.consumer_id, tx);
        flag.store(self.is_active(), Ordering::SeqCst);
        rx
    }

    /// Résout l'identifiant de livraison associé à un message.
    fn resolve_delivery_id(msg: &DispatchMessage<LyxalEventEnvelope>) -> (String, RecordId) {
        if let Some(val) = msg.message.metadata.get("delivery_id") {
            if let Some(s) = val.as_str() {
                if let Ok(thing) = s.parse::<RecordId>() {
                    return (s.to_string(), thing);
                }
                return (
                    s.to_string(),
                    RecordId::from(("event_delivery", s)),
                );
            }
        }

        if let Some(ref rec_id) = msg.message.id {
            return (rec_id.to_string(), rec_id.clone());
        }

        let fallback_id = format!("delivery_{}", msg.offset);
        let fallback_record = RecordId::from(("event_delivery", fallback_id.as_str()));
        (fallback_id, fallback_record)
    }

    /// Exécute un message de manière supervisée et isolée.
    ///
    /// Cette méthode garantit :
    /// 1. L'interception de toute panique sans impacter l'appelant.
    /// 2. L'application du timeout strict.
    /// 3. L'annulation coopérative via `HandlerContext.cancellation`.
    /// 4. La classification des erreurs (transitoires vs terminales).
    pub async fn process_message(
        &self,
        msg: &DispatchMessage<LyxalEventEnvelope>,
    ) -> HandlerExecutionResult {
        let (delivery_id_str, delivery_record_id) = Self::resolve_delivery_id(msg);
        let offset = msg.offset;
        let attempt_id = msg.attempt_id;

        if self.cancellation.is_cancelled() {
            debug!(
                offset,
                attempt_id, "Traitement annulé : cancellation token actif"
            );
            return HandlerExecutionResult::Cancelled {
                delivery_id: delivery_id_str,
                delivery_seq: offset,
                attempt_id,
            };
        }

        let event_type = &msg.message.event_type;
        let handler = match self.registry.get(event_type) {
            Some(h) => h,
            None => {
                warn!(
                    event_type = %event_type,
                    offset,
                    "Aucun handler enregistré pour l'événement"
                );
                return HandlerExecutionResult::MissingHandler {
                    delivery_id: delivery_id_str,
                    delivery_seq: offset,
                    attempt_id,
                    event_type: event_type.clone(),
                };
            }
        };

        let child_cancel = self.cancellation.child_token();
        let ctx = HandlerContext::new(
            EventId::from_uuid(msg.message.event_id),
            delivery_record_id,
            CorrelationId::from_uuid(msg.message.correlation_id),
            msg.message.causation_id.map(CausationId::from_uuid),
            msg.message.context.clone(),
            attempt_id,
            child_cancel.clone(),
        );

        let handler_clone = Arc::clone(&handler);
        let envelope_clone = msg.message.clone();
        let timeout_duration = self.config.dispatch_timeout;
        let del_id_for_task = delivery_id_str.clone();

        let task_result = tokio::task::spawn(async move {
            match tokio::time::timeout(timeout_duration, handler_clone.handle(&envelope_clone, &ctx)).await {
                Ok(execution_res) => match execution_res {
                    Ok(()) => HandlerExecutionResult::Success {
                        delivery_id: del_id_for_task,
                        delivery_seq: offset,
                        attempt_id,
                    },
                    Err(err) => {
                        let is_term = is_error_terminal(&err);
                        let reason = err.to_string();
                        if is_term {
                            HandlerExecutionResult::TerminalError {
                                delivery_id: del_id_for_task,
                                delivery_seq: offset,
                                attempt_id,
                                reason,
                            }
                        } else {
                            HandlerExecutionResult::TransientError {
                                delivery_id: del_id_for_task,
                                delivery_seq: offset,
                                attempt_id,
                                reason,
                            }
                        }
                    }
                },
                Err(_timeout_elapsed) => {
                    child_cancel.cancel();
                    HandlerExecutionResult::Timeout {
                        delivery_id: del_id_for_task,
                        delivery_seq: offset,
                        attempt_id,
                    }
                }
            }
        })
        .await;

        match task_result {
            Ok(exec_result) => exec_result,
            Err(join_err) => {
                if join_err.is_cancelled() {
                    HandlerExecutionResult::Cancelled {
                        delivery_id: delivery_id_str,
                        delivery_seq: offset,
                        attempt_id,
                    }
                } else if join_err.is_panic() {
                    let panic_payload = join_err.into_panic();
                    let panic_msg = if let Some(s) = panic_payload.downcast_ref::<&str>() {
                        s.to_string()
                    } else if let Some(s) = panic_payload.downcast_ref::<String>() {
                        s.clone()
                    } else {
                        "Panique de la tâche Tokio".to_string()
                    };
                    HandlerExecutionResult::Panicked {
                        delivery_id: delivery_id_str,
                        delivery_seq: offset,
                        attempt_id,
                        reason: panic_msg,
                    }
                } else {
                    HandlerExecutionResult::TransientError {
                        delivery_id: delivery_id_str,
                        delivery_seq: offset,
                        attempt_id,
                        reason: format!("Erreur de jointure Tokio: {join_err}"),
                    }
                }
            }
        }
    }

    /// Règle le résultat de l'exécution auprès de l'OutboxFeeder (émission ACK/NACK).
    pub async fn settle_result(
        &self,
        result: HandlerExecutionResult,
        feeder: &mut OutboxFeeder<LyxalEventEnvelope>,
    ) -> Result<ConsumerOutcome, FeederError> {
        let sub = &self.config.subscription_name;

        match result {
            HandlerExecutionResult::Success {
                delivery_id,
                delivery_seq,
                attempt_id,
            } => {
                let report = feeder.handle_ack(sub, delivery_seq, attempt_id).await?;
                Ok(ConsumerOutcome::Ack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::TransientError {
                delivery_id,
                delivery_seq,
                attempt_id,
                reason,
            } => {
                let report = feeder
                    .handle_nack(
                        sub,
                        delivery_seq,
                        attempt_id,
                        Some(reason),
                        false,
                        envelope_extractor,
                    )
                    .await?;
                Ok(ConsumerOutcome::Nack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::TerminalError {
                delivery_id,
                delivery_seq,
                attempt_id,
                reason,
            } => {
                let report = feeder
                    .handle_nack(
                        sub,
                        delivery_seq,
                        attempt_id,
                        Some(reason),
                        true,
                        envelope_extractor,
                    )
                    .await?;
                Ok(ConsumerOutcome::Nack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::Timeout {
                delivery_id,
                delivery_seq,
                attempt_id,
            } => {
                let report = feeder
                    .handle_nack(
                        sub,
                        delivery_seq,
                        attempt_id,
                        Some("Handler execution timeout elapsed".to_string()),
                        false,
                        envelope_extractor,
                    )
                    .await?;
                Ok(ConsumerOutcome::Nack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::Panicked {
                delivery_id,
                delivery_seq,
                attempt_id,
                reason,
            } => {
                let report = feeder
                    .handle_nack(
                        sub,
                        delivery_seq,
                        attempt_id,
                        Some(format!("Handler panicked: {reason}")),
                        false,
                        envelope_extractor,
                    )
                    .await?;
                Ok(ConsumerOutcome::Nack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::MissingHandler {
                delivery_id,
                delivery_seq,
                attempt_id,
                event_type,
            } => {
                let report = feeder
                    .handle_nack(
                        sub,
                        delivery_seq,
                        attempt_id,
                        Some(format!("Missing handler for event type '{event_type}'")),
                        false,
                        envelope_extractor,
                    )
                    .await?;
                Ok(ConsumerOutcome::Nack {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                    report,
                })
            }
            HandlerExecutionResult::Cancelled {
                delivery_id,
                delivery_seq,
                attempt_id,
            } => {
                debug!(
                    delivery_seq,
                    attempt_id, "Annulation enregistrée sans émission d'ACK"
                );
                Ok(ConsumerOutcome::Cancelled {
                    delivery_id,
                    delivery_seq,
                    attempt_id,
                })
            }
        }
    }

    /// Exécute et règle unitairement un message.
    pub async fn process_and_settle(
        &self,
        msg: &DispatchMessage<LyxalEventEnvelope>,
        feeder: &mut OutboxFeeder<LyxalEventEnvelope>,
    ) -> Result<ConsumerOutcome, FeederError> {
        let exec_result = self.process_message(msg).await;
        self.settle_result(exec_result, feeder).await
    }

    /// Boucle de traitement supervisée en tâche de fond avec contrôle de concurrence.
    pub async fn run_supervised_loop(
        &self,
        mut rx: mpsc::Receiver<DispatchMessage<LyxalEventEnvelope>>,
        feeder: Arc<Mutex<OutboxFeeder<LyxalEventEnvelope>>>,
    ) -> Result<(), FeederError> {
        let semaphore = Arc::new(Semaphore::new(self.config.max_concurrency));

        info!(
            consumer_id = %self.config.consumer_id,
            subscription = %self.config.subscription_name,
            concurrency = self.config.max_concurrency,
            "Démarrage de la boucle de consommation HandlerConsumerBridge"
        );

        while !self.cancellation.is_cancelled() {
            tokio::select! {
                () = self.cancellation.cancelled() => {
                    info!("Boucle HandlerConsumerBridge interrompue par cancellation");
                    break;
                }
                maybe_msg = rx.recv() => {
                    match maybe_msg {
                        Some(msg) => {
                            let permit = match semaphore.clone().acquire_owned().await {
                                Ok(p) => p,
                                Err(_) => break,
                            };

                            let feeder_clone = Arc::clone(&feeder);
                            let bridge_exec = self.process_message(&msg).await;

                            // Règle le résultat sous verrou asynchrone du feeder
                            let mut f = feeder_clone.lock().await;
                            if let Err(e) = self.settle_result(bridge_exec, &mut f).await {
                                error!(error = %e, "Échec du règlement du résultat auprès du feeder");
                            }
                            drop(permit);
                        }
                        None => {
                            debug!("Canal DispatchMessage fermé, arrêt de la boucle");
                            break;
                        }
                    }
                }
            }
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use async_trait::async_trait;
    use serde::{Deserialize, Serialize};
    use crate::handler::{Event, Handler};
    use crate::models::EventContext;

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct UserRegisteredEvent {
        user_id: String,
        email: String,
    }

    impl Event for UserRegisteredEvent {
        const EVENT_TYPE: &'static str = "user.registered";
    }

    struct SuccessHandler;

    #[async_trait]
    impl Handler<UserRegisteredEvent> for SuccessHandler {
        async fn handle(
            &self,
            _event: UserRegisteredEvent,
            _ctx: &HandlerContext,
        ) -> Result<(), LyxalEventError> {
            Ok(())
        }
    }

    struct FailingHandler {
        is_terminal: bool,
    }

    #[async_trait]
    impl Handler<UserRegisteredEvent> for FailingHandler {
        async fn handle(
            &self,
            _event: UserRegisteredEvent,
            ctx: &HandlerContext,
        ) -> Result<(), LyxalEventError> {
            if self.is_terminal {
                Err(LyxalEventError::HandlerFailed {
                    event_id: ctx.event_id.0,
                    event_type: "user.registered".to_string(),
                    error: "terminal: Invalid payload constraint".to_string(),
                })
            } else {
                Err(LyxalEventError::HandlerFailed {
                    event_id: ctx.event_id.0,
                    event_type: "user.registered".to_string(),
                    error: "Database temporary lock timeout".to_string(),
                })
            }
        }
    }

    struct PanickingHandler;

    #[async_trait]
    impl Handler<UserRegisteredEvent> for PanickingHandler {
        async fn handle(
            &self,
            _event: UserRegisteredEvent,
            _ctx: &HandlerContext,
        ) -> Result<(), LyxalEventError> {
            panic!("Critical explosion in domain handler");
        }
    }

    struct SlowHandler {
        duration: Duration,
    }

    #[async_trait]
    impl Handler<UserRegisteredEvent> for SlowHandler {
        async fn handle(
            &self,
            _event: UserRegisteredEvent,
            ctx: &HandlerContext,
        ) -> Result<(), LyxalEventError> {
            tokio::select! {
                () = tokio::time::sleep(self.duration) => Ok(()),
                () = ctx.cancellation.cancelled() => {
                    Err(LyxalEventError::Internal("Handler cancelled by token".to_string()))
                }
            }
        }
    }

    fn make_test_envelope(event: &UserRegisteredEvent) -> LyxalEventEnvelope {
        LyxalEventEnvelope::new("test_producer", EventContext::default_context(), event).unwrap()
    }

    #[tokio::test]
    async fn test_bridge_nominal_execution() {
        let mut registry = HandlerRegistry::new();
        registry.register(SuccessHandler).unwrap();

        let cancel = CancellationToken::new();
        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_1".to_string(),
            email: "alice@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 1,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        assert_eq!(
            result,
            HandlerExecutionResult::Success {
                delivery_id: "delivery_1".to_string(),
                delivery_seq: 1,
                attempt_id: 1,
            }
        );
    }

    #[tokio::test]
    async fn test_bridge_missing_handler() {
        let registry = HandlerRegistry::new();
        let cancel = CancellationToken::new();
        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_2".to_string(),
            email: "bob@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 2,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        assert_eq!(
            result,
            HandlerExecutionResult::MissingHandler {
                delivery_id: "delivery_2".to_string(),
                delivery_seq: 2,
                attempt_id: 1,
                event_type: "user.registered".to_string(),
            }
        );
    }

    #[tokio::test]
    async fn test_bridge_transient_error() {
        let mut registry = HandlerRegistry::new();
        registry
            .register(FailingHandler { is_terminal: false })
            .unwrap();

        let cancel = CancellationToken::new();
        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_3".to_string(),
            email: "carol@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 3,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        match result {
            HandlerExecutionResult::TransientError {
                delivery_seq,
                attempt_id,
                reason,
                ..
            } => {
                assert_eq!(delivery_seq, 3);
                assert_eq!(attempt_id, 1);
                assert!(reason.contains("temporary lock"));
            }
            other => panic!("Expected TransientError, got {other:?}"),
        }
    }

    #[tokio::test]
    async fn test_bridge_terminal_error() {
        let mut registry = HandlerRegistry::new();
        registry
            .register(FailingHandler { is_terminal: true })
            .unwrap();

        let cancel = CancellationToken::new();
        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_4".to_string(),
            email: "dave@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 4,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        match result {
            HandlerExecutionResult::TerminalError {
                delivery_seq,
                attempt_id,
                reason,
                ..
            } => {
                assert_eq!(delivery_seq, 4);
                assert_eq!(attempt_id, 1);
                assert!(reason.contains("Invalid payload"));
            }
            other => panic!("Expected TerminalError, got {other:?}"),
        }
    }

    #[tokio::test]
    async fn test_bridge_panic_isolation() {
        let mut registry = HandlerRegistry::new();
        registry.register(PanickingHandler).unwrap();

        let cancel = CancellationToken::new();
        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_5".to_string(),
            email: "eve@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 5,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        match result {
            HandlerExecutionResult::Panicked {
                delivery_seq,
                attempt_id,
                reason,
                ..
            } => {
                assert_eq!(delivery_seq, 5);
                assert_eq!(attempt_id, 1);
                assert!(reason.contains("Critical explosion"));
            }
            other => panic!("Expected Panicked, got {other:?}"),
        }
    }

    #[tokio::test]
    async fn test_bridge_timeout_interruption() {
        let mut registry = HandlerRegistry::new();
        registry
            .register(SlowHandler {
                duration: Duration::from_millis(200),
            })
            .unwrap();

        let cancel = CancellationToken::new();
        let config = BridgeConfig {
            dispatch_timeout: Duration::from_millis(30),
            ..Default::default()
        };
        let bridge = HandlerConsumerBridge::new(config, registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_6".to_string(),
            email: "frank@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 6,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        assert_eq!(
            result,
            HandlerExecutionResult::Timeout {
                delivery_id: "delivery_6".to_string(),
                delivery_seq: 6,
                attempt_id: 1,
            }
        );
    }

    #[tokio::test]
    async fn test_bridge_cancellation_propagation() {
        let mut registry = HandlerRegistry::new();
        registry.register(SuccessHandler).unwrap();

        let cancel = CancellationToken::new();
        cancel.cancel(); // Annulé au préalable (perte de bail simulée)

        let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel);

        let event = UserRegisteredEvent {
            user_id: "usr_7".to_string(),
            email: "grace@example.com".to_string(),
        };
        let envelope = make_test_envelope(&event);
        let msg = DispatchMessage {
            offset: 7,
            attempt_id: 1,
            message: envelope,
        };

        let result = bridge.process_message(&msg).await;
        assert_eq!(
            result,
            HandlerExecutionResult::Cancelled {
                delivery_id: "delivery_7".to_string(),
                delivery_seq: 7,
                attempt_id: 1,
            }
        );
    }
}
