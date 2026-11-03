use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;

use crate::common;
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct PaymentProcessed {
    pub payment_id: String,
    pub amount: u64,
}

impl Event for PaymentProcessed {
    const EVENT_TYPE: &'static str = "payment.processed";
}

struct FlakyPaymentHandler {
    pub attempts: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<PaymentProcessed> for FlakyPaymentHandler {
    async fn handle(
        &self,
        _event: PaymentProcessed,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        let current = self.attempts.fetch_add(1, Ordering::SeqCst);
        if current < 2 {
            Err(LyxalEventError::HandlerFailed {
                event_id: uuid::Uuid::now_v7(),
                event_type: "payment.processed".to_string(),
                error: "Transient gateway network error".to_string(),
                terminal: false,
            })
        } else {
            Ok(())
        }
    }
}

struct FailingPaymentHandler;

#[async_trait::async_trait]
impl Handler<PaymentProcessed> for FailingPaymentHandler {
    async fn handle(
        &self,
        _event: PaymentProcessed,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        Err(LyxalEventError::HandlerFailed {
            event_id: uuid::Uuid::now_v7(),
            event_type: "payment.processed".to_string(),
            error: "Permanent card declined error".to_string(),
            terminal: false,
        })
    }
}

#[tokio::test]
async fn test_retry_dlq_and_replay_cycle() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    // 1. Abonnement avec max_attempts = 3
    let sub = EventSubscription::new(
        "payment_sub",
        "lyxal_accounting",
        "payment.processed",
        "record_ledger",
    )
    .with_max_attempts(3);
    store.register_subscription(&sub).await.unwrap();

    // 2. Publication d'un événement
    let publisher = EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default());
    let event = PaymentProcessed {
        payment_id: "pay_111".to_string(),
        amount: 25000,
    };
    publisher.publish(&event).await.unwrap();

    // 3. Handler toujours en échec : retries in-process, puis dead letter après 3 tentatives
    let mut registry = HandlerRegistry::new();
    registry.register(FailingPaymentHandler).unwrap();
    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_failing").with_max_redelivery_count(3),
    ));
    let dead_lettered = common::run_worker_until(worker, Duration::from_secs(15), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["dead_letter"] }
    })
    .await;
    assert!(
        dead_lettered,
        "la livraison doit finir en dead letter : {:?}",
        common::delivery_statuses(&db).await
    );

    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(dead_letters.len(), 1, "une seule dead letter attendue");
    assert!(dead_letters[0]
        .last_error
        .contains("Permanent card declined"));

    // 4. Rejeu refusé tant que le curseur persisté ne couvre pas la séquence de la livraison
    db.query("UPDATE event_subscription_progress SET last_persisted_cursor = 0")
        .await
        .unwrap();
    let premature = store
        .dead_letter_replay(&dead_letters[0].id)
        .await
        .expect_err("rejeu prématuré refusé");
    assert!(
        matches!(&premature, LyxalEventError::Surreal(e) if e.is_business_code("EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED")),
        "{premature:?}"
    );
    db.query("UPDATE event_subscription_progress SET last_persisted_cursor = 1")
        .await
        .unwrap();

    // 5. Rejeu : la livraison redevient éligible et recevra une nouvelle séquence
    let delivery_id = dead_letters[0].delivery.clone();
    let replay_ok = store.dead_letter_replay(&dead_letters[0].id).await.unwrap();
    assert!(replay_ok, "le rejeu doit réussir");
    let replayed = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(replayed.status, DeliveryStatus::Pending);
    assert_eq!(replayed.attempts, 0);
    assert_eq!(replayed.delivery_seq, None);

    // 6. Handler corrigé : la livraison rejouée est livrée
    let mut fix_registry = HandlerRegistry::new();
    fix_registry
        .register(FlakyPaymentHandler {
            attempts: Arc::new(AtomicUsize::new(2)),
        })
        .unwrap();
    let fix_worker = Arc::new(EventWorker::new(
        store.clone(),
        fix_registry,
        common::fast_config("worker_fixed"),
    ));
    let delivered = common::run_worker_until(fix_worker, Duration::from_secs(15), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["delivered"] }
    })
    .await;
    assert!(
        delivered,
        "la livraison rejouée doit être livrée : {:?}",
        common::delivery_statuses(&db).await
    );
    let redelivered = store.get_delivery(&delivery_id).await.unwrap().unwrap();
    assert_eq!(
        redelivered.delivery_seq,
        Some(2),
        "nouvelle séquence en fin de flux"
    );
}

/// Handler en échec avec un diagnostic démesuré.
struct VerboseFailingHandler;

#[async_trait::async_trait]
impl Handler<PaymentProcessed> for VerboseFailingHandler {
    async fn handle(
        &self,
        _event: PaymentProcessed,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        Err(LyxalEventError::HandlerFailed {
            event_id: uuid::Uuid::now_v7(),
            event_type: "payment.processed".to_string(),
            error: "x".repeat(10_000),
            terminal: false,
        })
    }
}

/// Un diagnostic de handler très long n'empêche pas le transfert en dead letter : il est borné
/// à la longueur validée par `fn::event_dead_letter_transfer`.
#[tokio::test]
async fn test_oversized_error_still_reaches_dead_letter() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_verbose").await.unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    let sub = EventSubscription::new(
        "payment_verbose_sub",
        "lyxal_accounting",
        "payment.processed",
        "record_ledger",
    )
    .with_max_attempts(2);
    store.register_subscription(&sub).await.unwrap();
    EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default())
        .publish(&PaymentProcessed {
            payment_id: "pay_verbose".to_string(),
            amount: 1,
        })
        .await
        .unwrap();

    let mut registry = HandlerRegistry::new();
    registry.register(VerboseFailingHandler).unwrap();
    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_verbose").with_max_redelivery_count(2),
    ));
    let dead_lettered = common::run_worker_until(worker, Duration::from_secs(15), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["dead_letter"] }
    })
    .await;
    assert!(
        dead_lettered,
        "la livraison doit finir en dead letter : {:?}",
        common::delivery_statuses(&db).await
    );
    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(dead_letters.len(), 1);
    assert!(dead_letters[0].last_error.chars().count() <= 4000);
}

/// Une livraison dont l'événement d'origine a disparu n'est pas livrée avec des valeurs
/// inventées : elle part en dead letter avec le motif des champs manquants.
#[tokio::test]
async fn test_incomplete_delivery_goes_to_dead_letter() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns")
        .use_db("test_incomplete")
        .await
        .unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    let sub = EventSubscription::new(
        "payment_incomplete_sub",
        "lyxal_accounting",
        "payment.processed",
        "record_ledger",
    );
    store.register_subscription(&sub).await.unwrap();
    EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default())
        .publish(&PaymentProcessed {
            payment_id: "pay_orphan".to_string(),
            amount: 1,
        })
        .await
        .unwrap();
    // L'événement d'origine disparaît (purge ou corruption) avant la livraison
    db.query("DELETE event_outbox").await.unwrap();

    let handled = Arc::new(AtomicUsize::new(0));
    let mut registry = HandlerRegistry::new();
    registry
        .register(FlakyPaymentHandler {
            attempts: handled.clone(),
        })
        .unwrap();
    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_incomplete"),
    ));
    let dead_lettered = common::run_worker_until(worker, Duration::from_secs(10), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["dead_letter"] }
    })
    .await;
    assert!(
        dead_lettered,
        "la livraison incomplète doit partir en dead letter : {:?}",
        common::delivery_statuses(&db).await
    );
    assert_eq!(
        handled.load(Ordering::SeqCst),
        0,
        "le handler ne doit pas être appelé"
    );
    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(dead_letters.len(), 1);
    assert!(
        dead_letters[0].last_error.contains("event_type"),
        "{}",
        dead_letters[0].last_error
    );
}
