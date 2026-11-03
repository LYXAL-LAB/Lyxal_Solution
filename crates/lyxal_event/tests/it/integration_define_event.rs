use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;

use crate::common;
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct BookingCreatedEvent {
    pub customer: String,
    pub service: String,
}

impl Event for BookingCreatedEvent {
    const EVENT_TYPE: &'static str = "booking.created";
}

struct TestBookingHandler {
    pub processed: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<BookingCreatedEvent> for TestBookingHandler {
    async fn handle(
        &self,
        event: BookingCreatedEvent,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        assert_eq!(event.customer, "Jean Dupont");
        self.processed.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

#[tokio::test]
async fn test_surrealdb_define_event_triggers_lyxal_event() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    common::setup_test_db(&db).await;

    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    // 1. Déclaration de la subscription
    let sub = EventSubscription::new(
        "booking_notif",
        "lyxal_notification",
        "booking.created",
        "send_email",
    );
    store.register_subscription(&sub).await.unwrap();

    // 2. Déclaration de la table métier 'booking' et du DEFINE EVENT SurrealDB
    let define_event_ddl = r#"
        DEFINE TABLE IF NOT EXISTS booking SCHEMALESS;

        DEFINE EVENT IF NOT EXISTS booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN {
            LET $published = fn::event_publish({
                event_id: rand::uuid::v7(),
                event_type: "booking.created",
                producer: "lyxal_booking",
                source: $after.id,
                context: {
                    instance_id: "inst_demo",
                    namespace: "test_ns",
                    database: "test_db"
                },
                payload: {
                    customer: $after.customer,
                    service: $after.service
                }
            });
            -- Une publication refusée fait échouer la mutation au lieu d'être perdue
            IF !$published.ok { THROW $published.error.code; };
        };
    "#;
    db.query(define_event_ddl).await.unwrap();

    // 3. Insertion métier dans la table booking (mutation)
    db.query("CREATE booking CONTENT { customer: 'Jean Dupont', service: 'Consultation' }")
        .await
        .unwrap();

    // 4. Configuration et exécution du worker
    let processed_count = Arc::new(AtomicUsize::new(0));
    let mut registry = HandlerRegistry::new();
    registry
        .register(TestBookingHandler {
            processed: processed_count.clone(),
        })
        .unwrap();

    let worker = Arc::new(EventWorker::new(
        store.clone(),
        registry,
        common::fast_config("worker_define_event"),
    ));
    let delivered = common::run_worker_until(worker, Duration::from_secs(10), || {
        let db = db.clone();
        async move { common::delivery_statuses(&db).await == ["delivered"] }
    })
    .await;
    assert!(
        delivered,
        "la livraison produite par DEFINE EVENT doit être livrée : {:?}",
        common::delivery_statuses(&db).await
    );
    assert_eq!(
        processed_count.load(Ordering::SeqCst),
        1,
        "Handler must process the event payload"
    );
}

/// Une publication refusée par la validation fait échouer la mutation qui la déclenche :
/// l'événement n'est jamais perdu en silence.
#[tokio::test]
async fn test_invalid_publish_in_define_event_aborts_mutation() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_invalid").await.unwrap();
    common::setup_test_db(&db).await;
    let store = Arc::new(EventStore::new(db.clone()));
    store.install().await.unwrap();

    db.query(
        r#"
        DEFINE TABLE IF NOT EXISTS booking SCHEMALESS;
        DEFINE EVENT IF NOT EXISTS booking_bad_event ON TABLE booking WHEN $event = "CREATE" THEN {
            LET $published = fn::event_publish({
                event_id: rand::uuid::v7(),
                event_type: "booking.created",
                producer: "lyxal_booking",
                unknown_field: true
            });
            IF !$published.ok { THROW $published.error.code; };
        };
    "#,
    )
    .await
    .unwrap();

    let res = db
        .query("CREATE booking:b1 CONTENT { customer: 'Jean' }")
        .await
        .unwrap()
        .check();
    let err = res.expect_err("la mutation doit échouer");
    assert!(
        err.to_string().contains("EVENT_INVALID_PARAMETERS"),
        "{err}"
    );

    let mut check = db.query("RETURN record::exists(booking:b1)").await.unwrap();
    let exists: Option<bool> = check.take(0).unwrap();
    assert_eq!(exists, Some(false), "la mutation doit être annulée");
    let mut outbox = db
        .query("RETURN count(SELECT * FROM event_outbox)")
        .await
        .unwrap();
    let count: Option<i64> = outbox.take(0).unwrap();
    assert_eq!(count, Some(0));
}
