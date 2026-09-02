use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

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

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

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

        DEFINE EVENT IF NOT EXISTS booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN (
            fn::event_publish({
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
            })
        );
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

    let worker = EventWorker::new(store.clone(), registry, EventWorkerConfig::default());
    let cancel = CancellationToken::new();

    let processed = worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(
        processed, 1,
        "Exactly 1 delivery produced from DEFINE EVENT mutation"
    );
    assert_eq!(
        processed_count.load(Ordering::SeqCst),
        1,
        "Handler must process the event payload"
    );
}
