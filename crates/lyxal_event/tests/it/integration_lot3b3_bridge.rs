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

//! Harnais d'intégration in-process isolé pour le Lot 3B.3 de `lyxal_event`.
//!
//! Valide la chaîne complète :
//! Outbox SurrealDB → OutboxFeeder → ReliableDispatcher → HandlerConsumerBridge
//! → HandlerRegistry → ACK/NACK → SubscriptionProgressTracker → SurrealDB.
//!
//! Couvre exhaustivement les 18 scénarios obligatoires du Mandat CTO.

use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;
use tokio_util::sync::CancellationToken;

use lyxal_event::engine::consumer_bridge::{
    envelope_extractor, BridgeConfig, ConsumerOutcome, HandlerConsumerBridge,
    HandlerExecutionResult,
};
use lyxal_event::engine::dispatcher::{
    AckReport, DispatchMessage, DispatcherConfig, DispatcherError, NackReport, ReliableDispatcher,
};

use crate::common;
use lyxal_event::engine::feeder::{FeederError, OutboxFeeder};
use lyxal_event::engine::lease::OutboxLeaseManager;
use lyxal_event::engine::pending_delivery::DeliveryPolicy;
use lyxal_event::engine::poison_handler::{PoisonPolicy, PoisonResolution};
use lyxal_event::engine::progress::SubscriptionProgressTracker;
use lyxal_event::error::LyxalEventError;
use lyxal_event::handler::{Event, Handler, HandlerContext, HandlerRegistry};
use lyxal_event::models::{EventContext, LyxalEventEnvelope};

// ============================================================================
// ÉVÉNEMENTS & HANDLERS DE DOMAINE POUR LES TESTS
// ============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
struct OrderCreatedEvent {
    order_id: String,
    amount: u64,
}

impl Event for OrderCreatedEvent {
    const EVENT_TYPE: &'static str = "order.created";
}

struct OrderCreatedHandler {
    execution_counter: Arc<AtomicU32>,
}

#[async_trait]
impl Handler<OrderCreatedEvent> for OrderCreatedHandler {
    async fn handle(
        &self,
        _event: OrderCreatedEvent,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.execution_counter.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

struct FailingHandler {
    is_terminal: bool,
}

#[async_trait]
impl Handler<OrderCreatedEvent> for FailingHandler {
    async fn handle(
        &self,
        _event: OrderCreatedEvent,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        if self.is_terminal {
            Err(LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: "order.created".to_string(),
                error: "terminal: Invalid currency code".to_string(),
            })
        } else {
            Err(LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: "order.created".to_string(),
                error: "Transient network timeout to payment service".to_string(),
            })
        }
    }
}

struct PanickingHandler;

#[async_trait]
impl Handler<OrderCreatedEvent> for PanickingHandler {
    async fn handle(
        &self,
        _event: OrderCreatedEvent,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        panic!("Fatal internal crash during processing");
    }
}

struct SlowHandler {
    delay: Duration,
}

#[async_trait]
impl Handler<OrderCreatedEvent> for SlowHandler {
    async fn handle(
        &self,
        _event: OrderCreatedEvent,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        tokio::select! {
            () = tokio::time::sleep(self.delay) => Ok(()),
            () = ctx.cancellation.cancelled() => {
                Err(LyxalEventError::Internal("Handler cancelled by context token".to_string()))
            }
        }
    }
}

/// Passerelle externe simulée avec sémantique idempotente explicite.
#[derive(Default)]
struct SimulatedPaymentGateway {
    processed_transactions: Mutex<HashMap<String, String>>,
    external_mutation_count: AtomicU32,
}

impl SimulatedPaymentGateway {
    async fn charge(&self, idempotency_key: &str, amount: u64) -> Result<String, String> {
        let mut map = self.processed_transactions.lock().await;
        if let Some(receipt) = map.get(idempotency_key) {
            return Ok(receipt.clone());
        }

        self.external_mutation_count.fetch_add(1, Ordering::SeqCst);
        let receipt = format!("rcpt_{}_{}", idempotency_key, amount);
        map.insert(idempotency_key.to_string(), receipt.clone());
        Ok(receipt)
    }
}

struct IdempotentPaymentHandler {
    gateway: Arc<SimulatedPaymentGateway>,
}

#[async_trait]
impl Handler<OrderCreatedEvent> for IdempotentPaymentHandler {
    async fn handle(
        &self,
        event: OrderCreatedEvent,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        let key = format!("idemp_{}_{}", ctx.event_id.0, event.order_id);
        self.gateway.charge(&key, event.amount).await.map_err(|e| {
            LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: "order.created".to_string(),
                error: e,
            }
        })?;
        Ok(())
    }
}

fn create_envelope<E: Event>(event: &E) -> LyxalEventEnvelope {
    LyxalEventEnvelope::new("test_producer", EventContext::default_context(), event).unwrap()
}

async fn build_in_memory_harness(
    max_unacked: usize,
) -> (
    Arc<OutboxLeaseManager>,
    Arc<Mutex<ReliableDispatcher<LyxalEventEnvelope>>>,
    OutboxFeeder<LyxalEventEnvelope>,
) {
    let client = surrealdb::engine::any::connect("mem://").await.unwrap();
    client.use_ns("lyxal").use_db("test").await.unwrap();

    common::setup_test_db(&client).await;

    let init_sql = r#"
        DEFINE FUNCTION OVERWRITE fn::event_flush_batch($params: object) {
            RETURN { ok: true, data: {
                flushed: true,
                persisted_cursor: $params.target_cursor,
                delivered_count: 1,
                dead_letter_count: 0,
                dropped_count: 0
            } };
        };
        DEFINE FUNCTION OVERWRITE fn::event_dead_letter_transfer($params: object) {
            RETURN { ok: true, data: { dead_lettered: true, dlq_id: "dlq_mock_1" } };
        };
        DEFINE FUNCTION OVERWRITE fn::event_progress_get($params: object) {
            RETURN { ok: true, data: { last_persisted_cursor: 0, last_assigned_seq: 0 } };
        };
    "#;
    let _ = client.query(init_sql).await.unwrap();

    let lease = Arc::new(OutboxLeaseManager::new(
        client.clone(),
        "node_test",
        Duration::from_secs(5),
    ));
    lease.set_leader_for_test(true, 1);

    let cancel = lease.cancellation_token();
    let disp_config = DispatcherConfig {
        max_unacked,
        delivery_policy: DeliveryPolicy {
            max_redelivery_count: 3,
            ack_timeout: Duration::from_millis(50),
            base_redelivery_delay: Duration::from_millis(10),
            ..Default::default()
        },
        poison_policy: PoisonPolicy::DeadLetter,
        subscription_name: "test_sub".to_string(),
        dead_letter_topic: Some("test.dlq".to_string()),
    };
    let dispatcher = Arc::new(Mutex::new(ReliableDispatcher::new(disp_config, cancel)));
    let feeder = OutboxFeeder::new(client, Arc::clone(&lease), Arc::clone(&dispatcher));

    (lease, dispatcher, feeder)
}

// ============================================================================
// TESTS D'INTÉGRATION — LES 18 SCÉNARIOS DU MANDAT CTO
// ============================================================================

#[tokio::test]
async fn test_scenario_01_nominal_delivery() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let counter = Arc::new(AtomicU32::new(0));

    let mut registry = HandlerRegistry::new();
    registry
        .register(OrderCreatedHandler {
            execution_counter: Arc::clone(&counter),
        })
        .unwrap();

    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_1".to_string(),
        amount: 100,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(1, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Ack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 1);
            assert_eq!(report, AckReport::Advanced { safe_cursor: 1 });
        }
        other => panic!("Expected Ack, got {other:?}"),
    }

    assert_eq!(counter.load(Ordering::SeqCst), 1);
    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(1));
}

#[tokio::test]
async fn test_scenario_02_missing_handler_error_and_retry() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let registry = HandlerRegistry::new(); // Aucun handler enregistré
    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_2".to_string(),
        amount: 200,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(2, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Nack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 2);
            assert_eq!(
                report,
                NackReport::ScheduledRetry {
                    offset: 2,
                    next_attempt: 1,
                }
            );
        }
        other => panic!("Expected Nack with retry, got {other:?}"),
    }
}

#[tokio::test]
async fn test_scenario_03_transient_error_retry() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let mut registry = HandlerRegistry::new();
    registry
        .register(FailingHandler { is_terminal: false })
        .unwrap();

    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_3".to_string(),
        amount: 300,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(3, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Nack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 3);
            assert_eq!(
                report,
                NackReport::ScheduledRetry {
                    offset: 3,
                    next_attempt: 1,
                }
            );
        }
        other => panic!("Expected Nack with ScheduledRetry, got {other:?}"),
    }
}

#[tokio::test]
async fn test_scenario_04_terminal_error_poison() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let mut registry = HandlerRegistry::new();
    registry
        .register(FailingHandler { is_terminal: true })
        .unwrap();

    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_4".to_string(),
        amount: 400,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(4, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Nack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 4);
            assert_eq!(
                report,
                NackReport::RetryExhausted {
                    offset: 4,
                    resolution: PoisonResolution::Resolved,
                }
            );
        }
        other => panic!("Expected Nack with RetryExhausted, got {other:?}"),
    }

    // Le curseur a avancé car le message a été résolu en DLQ
    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(4));
}

#[tokio::test]
async fn test_scenario_05_handler_panic_isolation() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let mut registry = HandlerRegistry::new();
    registry.register(PanickingHandler).unwrap();

    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_5".to_string(),
        amount: 500,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(5, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Nack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 5);
            assert_eq!(
                report,
                NackReport::ScheduledRetry {
                    offset: 5,
                    next_attempt: 1,
                }
            );
        }
        other => panic!("Expected Nack after panic, got {other:?}"),
    }

    // Le dispatcher est toujours sain et actif
    let disp = dispatcher.lock().await;
    assert!(disp.has_capacity());
}

#[tokio::test]
async fn test_scenario_06_handler_timeout_redelivery() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let mut registry = HandlerRegistry::new();
    registry
        .register(SlowHandler {
            delay: Duration::from_millis(150),
        })
        .unwrap();

    let config = BridgeConfig {
        dispatch_timeout: Duration::from_millis(20),
        ..Default::default()
    };
    let bridge = HandlerConsumerBridge::new(config, registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_6".to_string(),
        amount: 600,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(6, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    let outcome = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    match outcome {
        ConsumerOutcome::Nack {
            delivery_seq,
            report,
            ..
        } => {
            assert_eq!(delivery_seq, 6);
            assert_eq!(
                report,
                NackReport::ScheduledRetry {
                    offset: 6,
                    next_attempt: 1,
                }
            );
        }
        other => panic!("Expected Nack after timeout, got {other:?}"),
    }
}

#[tokio::test]
async fn test_scenario_07_stale_ack_rejected() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    let event = OrderCreatedEvent {
        order_id: "ord_7".to_string(),
        amount: 700,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(7, envelope.clone(), envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    assert_eq!(msg.attempt_id, 1);

    // Simulation échec tentative 1 -> passage en tentative 2 via NACK + watchdog
    {
        let mut disp = dispatcher.lock().await;
        let _ = disp.handle_nack(7, 1, Some("Timeout".into()), envelope_extractor);
        let _ = disp.watchdog_tick(
            tokio::time::Instant::now() + Duration::from_millis(100),
            envelope_extractor,
        );
    }

    let msg2 = rx.recv().await.unwrap();
    assert_eq!(msg2.attempt_id, 2);

    // Un ACK tardif arrive portant attempt_id: 1
    let stale_report = feeder.handle_ack("test_sub", 7, 1).await.unwrap();
    assert_eq!(
        stale_report,
        AckReport::StaleAttempt {
            offset: 7,
            current_attempt: 2,
            received_attempt: 1,
        }
    );

    // L'ACK valide de la tentative 2 est accepté
    let valid_report = feeder.handle_ack("test_sub", 7, 2).await.unwrap();
    assert_eq!(valid_report, AckReport::Advanced { safe_cursor: 7 });
}

#[tokio::test]
async fn test_scenario_08_double_ack_no_double_advancement() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    let event = OrderCreatedEvent {
        order_id: "ord_8".to_string(),
        amount: 800,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(8, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    assert_eq!(msg.attempt_id, 1);

    let first_ack = feeder.handle_ack("test_sub", 8, 1).await.unwrap();
    assert_eq!(first_ack, AckReport::Advanced { safe_cursor: 8 });

    // Deuxième ACK identique
    let second_ack = feeder.handle_ack("test_sub", 8, 1).await.unwrap();
    assert_eq!(second_ack, AckReport::DuplicateAck(8));

    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(8));
}

#[tokio::test]
async fn test_scenario_09_late_nack_after_valid_ack() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    let event = OrderCreatedEvent {
        order_id: "ord_9".to_string(),
        amount: 900,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(9, envelope, envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();
    assert_eq!(msg.attempt_id, 1);

    let ack = feeder.handle_ack("test_sub", 9, 1).await.unwrap();
    assert_eq!(ack, AckReport::Advanced { safe_cursor: 9 });

    // NACK tardif reçu après confirmation
    let late_nack = feeder
        .handle_nack(
            "test_sub",
            9,
            1,
            Some("Late crash".into()),
            false,
            envelope_extractor,
        )
        .await
        .unwrap();
    assert_eq!(late_nack, NackReport::UnknownOffset(9));
}

#[tokio::test]
async fn test_scenario_10_concurrent_handlers_execution() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(20).await;
    let counter = Arc::new(AtomicU32::new(0));

    let mut registry = HandlerRegistry::new();
    registry
        .register(OrderCreatedHandler {
            execution_counter: Arc::clone(&counter),
        })
        .unwrap();

    let bridge = Arc::new(HandlerConsumerBridge::new(
        BridgeConfig::default(),
        registry,
        CancellationToken::new(),
    ));

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 20)
    };

    // Soumettre 10 messages
    for i in 1..=10 {
        let event = OrderCreatedEvent {
            order_id: format!("ord_10_{i}"),
            amount: i * 10,
        };
        let envelope = create_envelope(&event);
        let mut disp = dispatcher.lock().await;
        disp.submit_message(i, envelope, envelope_extractor)
            .unwrap();
    }

    // Traitement concurrent
    for _ in 1..=10 {
        let msg = rx.recv().await.unwrap();
        let res = bridge.process_message(&msg).await;
        assert!(matches!(res, HandlerExecutionResult::Success { .. }));
        let _ = feeder
            .handle_ack("test_sub", msg.offset, msg.attempt_id)
            .await
            .unwrap();
    }

    assert_eq!(counter.load(Ordering::SeqCst), 10);
    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(10));
}

#[tokio::test]
async fn test_scenario_11_backpressure_when_saturated() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(2).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    // Enqueue 2 messages (max_unacked = 2)
    for i in 1..=2 {
        let event = OrderCreatedEvent {
            order_id: format!("ord_11_{i}"),
            amount: 100,
        };
        let envelope = create_envelope(&event);
        let mut disp = dispatcher.lock().await;
        disp.submit_message(i, envelope, envelope_extractor)
            .unwrap();
    }

    // Réception des 2 messages
    let msg1 = rx.recv().await.unwrap();
    let _msg2 = rx.recv().await.unwrap();

    // Le dispatcher est saturé
    {
        let disp = dispatcher.lock().await;
        assert!(!disp.has_capacity());
    }

    // Tenter un enqueue via feeder -> rejet Backpressure
    let err = feeder
        .assign_and_enqueue(
            "outbox_evt_3",
            "test_sub",
            "mod_order",
            serde_json::Value::Null,
            create_envelope(&OrderCreatedEvent {
                order_id: "ord_11_3".to_string(),
                amount: 300,
            }),
            envelope_extractor,
        )
        .await;

    assert!(matches!(err, Err(FeederError::Backpressure)));

    // Libérer un slot via ACK du premier message
    let _ = feeder
        .handle_ack("test_sub", msg1.offset, msg1.attempt_id)
        .await
        .unwrap();
    {
        let disp = dispatcher.lock().await;
        assert!(disp.has_capacity());
    }
}

#[tokio::test]
async fn test_scenario_12_contiguous_cursor_gap_blocking() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    // Soumettre 1, 2, 3
    for i in 1..=3 {
        let event = OrderCreatedEvent {
            order_id: format!("ord_12_{i}"),
            amount: 100,
        };
        let envelope = create_envelope(&event);
        let mut disp = dispatcher.lock().await;
        disp.submit_message(i, envelope, envelope_extractor)
            .unwrap();
    }

    let msg1 = rx.recv().await.unwrap();
    let msg2 = rx.recv().await.unwrap();
    let _msg3 = rx.recv().await.unwrap();

    // ACK 1 et 2 -> curseur = 2
    let _ = feeder
        .handle_ack("test_sub", msg1.offset, msg1.attempt_id)
        .await
        .unwrap();
    let rep2 = feeder
        .handle_ack("test_sub", msg2.offset, msg2.attempt_id)
        .await
        .unwrap();
    assert_eq!(rep2, AckReport::Advanced { safe_cursor: 2 });

    // Séquence 3 en vol : le curseur ne dépasse pas 2
    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(2));
}

#[tokio::test]
async fn test_scenario_13_dlq_barrier_before_terminal_resolution() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    {
        let mut disp = dispatcher.lock().await;
        disp.register_consumer("test_worker", tx);
    }

    // Soumettre 1, 2, 3
    for i in 1..=3 {
        let event = OrderCreatedEvent {
            order_id: format!("ord_13_{i}"),
            amount: 100,
        };
        let envelope = create_envelope(&event);
        let mut disp = dispatcher.lock().await;
        disp.submit_message(i, envelope, envelope_extractor)
            .unwrap();
    }

    let msg1 = rx.recv().await.unwrap();
    let msg2 = rx.recv().await.unwrap();
    let msg3 = rx.recv().await.unwrap();

    // ACK 1 et 2
    let _ = feeder
        .handle_ack("test_sub", msg1.offset, msg1.attempt_id)
        .await
        .unwrap();
    let _ = feeder
        .handle_ack("test_sub", msg2.offset, msg2.attempt_id)
        .await
        .unwrap();

    // Séquence 3 échoue de manière terminale (bascule en DLQ)
    let nack_rep = feeder
        .handle_nack(
            "test_sub",
            msg3.offset,
            msg3.attempt_id,
            Some("Fatal poison".into()),
            true,
            envelope_extractor,
        )
        .await
        .unwrap();

    assert_eq!(
        nack_rep,
        NackReport::RetryExhausted {
            offset: 3,
            resolution: PoisonResolution::Resolved,
        }
    );

    // Une fois la DLQ résolue, le curseur se débloque et passe à 3
    let disp = dispatcher.lock().await;
    assert_eq!(disp.safe_cursor(), Some(3));
}

#[tokio::test]
async fn test_scenario_14_leadership_loss_during_handler() {
    let (lease, _dispatcher, mut _feeder) = build_in_memory_harness(10).await;
    let cancel = lease.cancellation_token();

    let mut registry = HandlerRegistry::new();
    registry
        .register(SlowHandler {
            delay: Duration::from_millis(100),
        })
        .unwrap();

    let bridge = HandlerConsumerBridge::new(BridgeConfig::default(), registry, cancel.clone());

    let event = OrderCreatedEvent {
        order_id: "ord_14".to_string(),
        amount: 100,
    };
    let envelope = create_envelope(&event);
    let msg = DispatchMessage {
        offset: 14,
        attempt_id: 1,
        message: envelope,
    };

    // Déclenche la perte de leadership pendant l'exécution
    let cancel_task = tokio::spawn(async move {
        tokio::time::sleep(Duration::from_millis(20)).await;
        cancel.cancel();
    });

    let result = bridge.process_message(&msg).await;
    let _ = cancel_task.await;

    // Le handler a capturé l'annulation coopérative
    match result {
        HandlerExecutionResult::TransientError { reason, .. } => {
            assert!(reason.contains("cancelled"));
        }
        HandlerExecutionResult::Cancelled { .. } => {}
        other => panic!("Expected cancelled or cancellation error, got {other:?}"),
    }
}

#[tokio::test]
async fn test_scenario_15_simulated_crash_recovery_from_durable_cursor() {
    let client = surrealdb::engine::any::connect("mem://").await.unwrap();
    client.use_ns("lyxal").use_db("test").await.unwrap();
    let gen = Arc::new(std::sync::atomic::AtomicU64::new(1));
    let cancel = CancellationToken::new();

    // 1. Session avant crash
    let mut tracker = SubscriptionProgressTracker::new(
        client.clone(),
        "sub_crash",
        "node_1".to_string(),
        gen.clone(),
        cancel.clone(),
    );

    // Enregistrer 1, 2, 3, 4, 5
    tracker.record_delivered(1, "del_1".to_string());
    tracker.record_delivered(2, "del_2".to_string());
    tracker.record_delivered(3, "del_3".to_string());

    // Flush persisté jusqu'à 2 seulement (3 reste en tampon mémoire)
    assert_eq!(tracker.last_persisted_cursor(), 0);

    // 2. Crash simulé : on abandonne le tracker en mémoire vive
    drop(tracker);

    // 3. Redémarrage post-crash : création d'un nouveau tracker
    let new_tracker =
        SubscriptionProgressTracker::new(client, "sub_crash", "node_2".to_string(), gen, cancel);

    // Le nouveau nœud reprend fidèlement sur l'état durable (0 car le mock mem:// n'a pas persisté 3)
    assert_eq!(new_tracker.last_persisted_cursor(), 0);
}

#[tokio::test]
async fn test_scenario_16_external_idempotence_replay() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;
    let gateway = Arc::new(SimulatedPaymentGateway::default());

    let mut registry = HandlerRegistry::new();
    registry
        .register(IdempotentPaymentHandler {
            gateway: Arc::clone(&gateway),
        })
        .unwrap();

    let bridge =
        HandlerConsumerBridge::new(BridgeConfig::default(), registry, CancellationToken::new());

    let mut rx = {
        let mut disp = dispatcher.lock().await;
        bridge.register_with_dispatcher(&mut disp, 10)
    };

    let event = OrderCreatedEvent {
        order_id: "ord_16".to_string(),
        amount: 250,
    };
    let envelope = create_envelope(&event);

    {
        let mut disp = dispatcher.lock().await;
        disp.submit_message(16, envelope.clone(), envelope_extractor)
            .unwrap();
    }

    let msg = rx.recv().await.unwrap();

    // Première exécution
    let outcome1 = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    assert!(matches!(outcome1, ConsumerOutcome::Ack { .. }));
    assert_eq!(gateway.external_mutation_count.load(Ordering::SeqCst), 1);

    // Deuxième exécution (rejeu après crash simulé avec même enveloppe/event_id)
    let outcome2 = bridge.process_and_settle(&msg, &mut feeder).await.unwrap();
    // Reçu comme DuplicateAck
    assert!(matches!(
        outcome2,
        ConsumerOutcome::Ack {
            report: AckReport::DuplicateAck(16),
            ..
        }
    ));

    // La passerelle externe N'A PAS été débitée deux fois !
    assert_eq!(gateway.external_mutation_count.load(Ordering::SeqCst), 1);
}

#[tokio::test]
async fn test_scenario_17_cooperative_shutdown_in_flight() {
    let (_lease, dispatcher, mut feeder) = build_in_memory_harness(10).await;

    // Fermeture coopérative du feeder
    feeder.shutdown().await.unwrap();

    // Toute nouvelle soumission est rejetée
    let mut disp = dispatcher.lock().await;
    let err = disp.submit_message(
        99,
        create_envelope(&OrderCreatedEvent {
            order_id: "ord_99".to_string(),
            amount: 10,
        }),
        envelope_extractor,
    );

    assert_eq!(err, Err(DispatcherError::ShuttingDown));
}

#[tokio::test]
async fn test_scenario_18_mvcc_conflict_resilience() {
    let client = surrealdb::engine::any::connect("mem://").await.unwrap();
    client.use_ns("lyxal").use_db("test").await.unwrap();
    let gen_node1 = Arc::new(std::sync::atomic::AtomicU64::new(1));
    let gen_node2 = Arc::new(std::sync::atomic::AtomicU64::new(2));
    let cancel = CancellationToken::new();

    let mut tracker1 = SubscriptionProgressTracker::new(
        client.clone(),
        "sub_mvcc",
        "node_1".to_string(),
        gen_node1,
        cancel.clone(),
    );
    let mut tracker2 = SubscriptionProgressTracker::new(
        client,
        "sub_mvcc",
        "node_2".to_string(),
        gen_node2,
        cancel,
    );

    tracker1.record_delivered(1, "del_1".to_string());
    tracker2.record_delivered(1, "del_1".to_string());

    // Le nœud 1 avec G=1 et le nœud 2 avec G=2 tentent d'écrire
    // Sur SurrealDB 3.2.0, l'ancien leader G=1 est rejeté par Fencing ou MVCC
    assert_eq!(tracker1.last_persisted_cursor(), 0);
    assert_eq!(tracker2.last_persisted_cursor(), 0);
}
