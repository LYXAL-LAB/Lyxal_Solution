use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

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
        })
    }
}

#[tokio::test]
async fn test_retry_dlq_and_replay_cycle() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

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

    // 3. Worker configuré avec handler défaillant
    let mut registry = HandlerRegistry::new();
    registry.register(FailingPaymentHandler).unwrap();

    let config = EventWorkerConfig::default()
        .with_max_attempts(3)
        .with_batch_size(10)
        .with_poll_interval(Duration::from_millis(10));
    let worker = EventWorker::new(store.clone(), registry, config);
    let cancel = CancellationToken::new();

    // Tentative 1 (échec)
    let processed1 = worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(processed1, 1);

    // Force la ré-éligibilité immédiate pour tester le retry sans attendre la temporisation
    db.query("UPDATE event_delivery SET next_retry_at = time::now()")
        .await
        .unwrap();

    // Tentative 2 (échec)
    let processed2 = worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(processed2, 1);

    db.query("UPDATE event_delivery SET next_retry_at = time::now()")
        .await
        .unwrap();

    // Tentative 3 (échec final -> bascule en dead letter)
    let processed3 = worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(processed3, 1);

    // Vérifie la présence de l'enregistrement dans event_dead_letter
    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(
        dead_letters.len(),
        1,
        "Expected 1 dead letter after 3 failed attempts"
    );
    assert_eq!(dead_letters[0].attempts, 3);
    assert!(dead_letters[0]
        .last_error
        .contains("Permanent card declined"));

    // Vérifie que la livraison est maintenant en statut 'dead_letter'
    let delivery = store
        .get_delivery(&dead_letters[0].delivery)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(delivery.status, DeliveryStatus::DeadLetter);

    // 4. Replay : Réinitialisation via fn::event_dead_letter_replay
    let replay_ok = store.dead_letter_replay(&dead_letters[0].id).await.unwrap();
    assert!(replay_ok, "Replay must succeed");

    // Vérifie que la livraison est redevenue 'pending' avec attempts = 0
    let replayed_delivery = store.get_delivery(&delivery.id).await.unwrap().unwrap();
    assert_eq!(replayed_delivery.status, DeliveryStatus::Pending);
    assert_eq!(replayed_delivery.attempts, 0);

    // 5. Enregistrement d'un handler corrigé qui réussit
    let flaky_count = Arc::new(AtomicUsize::new(2)); // va réussir immédiatement car count >= 2
    let mut fix_registry = HandlerRegistry::new();
    fix_registry
        .register(FlakyPaymentHandler {
            attempts: flaky_count,
        })
        .unwrap();

    let fix_worker = EventWorker::new(store.clone(), fix_registry, EventWorkerConfig::default());
    let replayed_processed = fix_worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(
        replayed_processed, 1,
        "Replayed delivery must be successfully claimed and processed"
    );

    let final_delivery = store.get_delivery(&delivery.id).await.unwrap().unwrap();
    assert_eq!(final_delivery.status, DeliveryStatus::Delivered);
}
