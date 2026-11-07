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
    common::install_event(store.client()).await;

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
        common::fast_config("worker_failing"),
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
    common::install_event(store.client()).await;

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
        common::fast_config("worker_verbose"),
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
    common::install_event(store.client()).await;

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

/// La purge supprime les livraisons livrées couvertes par le curseur et les événements anciens,
/// mais garde un événement tant qu'une de ses livraisons n'est pas livrée (en attente ou en dead
/// letter rejouable).
#[tokio::test]
async fn test_purge_keeps_events_of_unresolved_deliveries() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_purge").await.unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    common::install_event(store.client()).await;

    let sub = EventSubscription::new(
        "payment_purge_sub",
        "lyxal_accounting",
        "payment.processed",
        "record_ledger",
    );
    store.register_subscription(&sub).await.unwrap();
    let publisher = EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default());
    for id in ["pay_done", "pay_waiting"] {
        publisher
            .publish(&PaymentProcessed {
                payment_id: id.to_string(),
                amount: 1,
            })
            .await
            .unwrap();
    }
    // Événements anciens ; seule la livraison de pay_done (séquence 1) est livrée depuis
    // longtemps, et le curseur durable de l'abonnement la couvre
    db.query(
        "UPDATE event_outbox SET fanned_out_at = time::now() - 10d;
         UPDATE event_delivery SET status = 'delivered', delivered_at = time::now() - 10d,
            delivery_seq = 1 WHERE outbox_event.payload.payment_id = 'pay_done';
         UPDATE event_delivery SET delivery_seq = 2
            WHERE outbox_event.payload.payment_id = 'pay_waiting';
         LET $sub = (SELECT VALUE id FROM ONLY event_subscription LIMIT 1);
         CREATE type::record('event_subscription_progress', 'prog_' + <string> record::id($sub))
            CONTENT { subscription: $sub, last_assigned_seq: 2, last_persisted_cursor: 1 };",
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    assert!(store.purge_garbage(1).await.unwrap());

    let mut res = db
        .query(
            "SELECT VALUE payload.payment_id FROM event_outbox;
             SELECT VALUE status FROM event_delivery;",
        )
        .await
        .unwrap();
    let outbox: Vec<String> = res.take(0).unwrap();
    let deliveries: Vec<String> = res.take(1).unwrap();
    assert_eq!(outbox, ["pay_waiting"]);
    assert_eq!(deliveries, ["pending"]);
}

/// Une livraison livrée après une séquence encore en attente n'est pas purgée tant que le curseur
/// durable ne la couvre pas : la résolution ultérieure du trou avance le curseur sans
/// `EVENT_CURSOR_MISSING_SEQUENCE_HOLE`, puis la purge suivante retire les livraisons couvertes.
#[tokio::test]
async fn test_purge_never_creates_a_hole_before_the_cursor() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns")
        .use_db("test_purge_hole")
        .await
        .unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    common::install_event(store.client()).await;

    store
        .register_subscription(&EventSubscription::new(
            "payment_hole_sub",
            "lyxal_accounting",
            "payment.processed",
            "record_ledger",
        ))
        .await
        .unwrap();
    let publisher = EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default());
    for id in ["pay_1", "pay_2", "pay_3"] {
        publisher
            .publish(&PaymentProcessed {
                payment_id: id.to_string(),
                amount: 1,
            })
            .await
            .unwrap();
    }
    // Séquences 1 à 3 ; la 2 reste en attente, la 1 et la 3 sont livrées depuis longtemps ;
    // curseur durable à 0
    db.query(
        "UPDATE event_outbox SET fanned_out_at = time::now() - 10d;
         UPDATE event_delivery SET delivery_seq = 1, status = 'delivered',
            delivered_at = time::now() - 10d WHERE outbox_event.payload.payment_id = 'pay_1';
         UPDATE event_delivery SET delivery_seq = 2
            WHERE outbox_event.payload.payment_id = 'pay_2';
         UPDATE event_delivery SET delivery_seq = 3, status = 'delivered',
            delivered_at = time::now() - 10d WHERE outbox_event.payload.payment_id = 'pay_3';
         LET $sub = (SELECT VALUE id FROM ONLY event_subscription LIMIT 1);
         CREATE type::record('event_subscription_progress', 'prog_' + <string> record::id($sub))
            CONTENT { subscription: $sub, last_assigned_seq: 3, last_persisted_cursor: 0 };",
    )
    .await
    .unwrap()
    .check()
    .unwrap();

    // Purge : rien n'est couvert par le curseur, aucune livraison ne disparaît
    assert!(store.purge_garbage(1).await.unwrap());
    let mut res = db
        .query("SELECT VALUE delivery_seq FROM event_delivery ORDER BY delivery_seq")
        .await
        .unwrap();
    let seqs: Vec<i64> = res.take(0).unwrap();
    assert_eq!(seqs, [1, 2, 3]);

    // Le trou se résout : la séquence 2 est livrée et le curseur avance jusqu'à 3
    let mut res = db
        .query(
            "LET $sub = (SELECT VALUE id FROM ONLY event_subscription LIMIT 1);
             LET $lease = fn::event_lease_acquire({ node_id: 'node_purge', ttl_seconds: 60 });
             LET $pending = (SELECT VALUE id FROM ONLY event_delivery WHERE delivery_seq = 2 LIMIT 1);
             RETURN fn::event_flush_batch({
                 subscription: $sub,
                 target_cursor: 3,
                 node_id: 'node_purge',
                 generation: $lease.data.generation,
                 delivered_ids: [$pending]
             });",
        )
        .await
        .unwrap();
    let flushed: Option<lyxal_surreal::Value> = res.take(3).unwrap();
    let flushed = flushed.unwrap().into_json_value();
    assert_eq!(flushed["ok"], true, "{flushed}");
    assert_eq!(flushed["data"]["persisted_cursor"], 3, "{flushed}");

    // Purge suivante : les séquences 1 et 3, anciennes et couvertes, disparaissent ; la 2,
    // livrée à l'instant, reste ; seul l'événement de pay_2 est encore référencé
    assert!(store.purge_garbage(1).await.unwrap());
    let mut res = db
        .query(
            "SELECT VALUE delivery_seq FROM event_delivery;
             SELECT VALUE payload.payment_id FROM event_outbox;",
        )
        .await
        .unwrap();
    let seqs: Vec<i64> = res.take(0).unwrap();
    let outbox: Vec<String> = res.take(1).unwrap();
    assert_eq!(seqs, [2]);
    assert_eq!(outbox, ["pay_2"]);
}

/// Une livraison dont l'abonnement a disparu part en dead letter avec son motif, sans bloquer
/// les livraisons des autres abonnements.
#[tokio::test]
async fn test_orphan_delivery_goes_to_dead_letter() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_orphan").await.unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    common::install_event(store.client()).await;

    for name in ["payment_orphan_sub", "payment_live_sub"] {
        store
            .register_subscription(&EventSubscription::new(
                name,
                "lyxal_accounting",
                "payment.processed",
                "record_ledger",
            ))
            .await
            .unwrap();
    }
    EventPublisher::new(store.clone(), "lyxal_billing", EventContext::default())
        .publish(&PaymentProcessed {
            payment_id: "pay_1".to_string(),
            amount: 1,
        })
        .await
        .unwrap();
    db.query("DELETE event_subscription WHERE name = 'payment_orphan_sub'")
        .await
        .unwrap();

    let handled = Arc::new(AtomicUsize::new(2));
    let mut registry = HandlerRegistry::new();
    registry
        .register(FlakyPaymentHandler {
            attempts: handled.clone(),
        })
        .unwrap();
    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_orphan"),
    ));
    let settled = common::run_worker_until(worker, Duration::from_secs(10), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["dead_letter", "delivered"] }
    })
    .await;
    assert!(settled, "{:?}", common::delivery_statuses(&db).await);
    let dead_letters = store.get_dead_letters().await.unwrap();
    assert_eq!(dead_letters.len(), 1);
    assert!(
        dead_letters[0].last_error.contains("orpheline"),
        "{}",
        dead_letters[0].last_error
    );
}
