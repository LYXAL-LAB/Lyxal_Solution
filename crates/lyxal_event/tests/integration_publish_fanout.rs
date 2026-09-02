use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio_util::sync::CancellationToken;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct BookingCreated {
    pub booking_id: String,
    pub customer_email: String,
}

impl Event for BookingCreated {
    const EVENT_TYPE: &'static str = "booking.created";
}

struct NotificationBookingHandler {
    pub received: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<BookingCreated> for NotificationBookingHandler {
    async fn handle(
        &self,
        _event: BookingCreated,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.received.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

#[tokio::test]
async fn test_publish_and_fanout_end_to_end() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    // Enregistrement de 2 abonnements distincts pour le même event_type
    let sub_notification = EventSubscription::new(
        "sub_notification_booking",
        "lyxal_notification",
        "booking.created",
        "send_confirmation_email",
    );
    let sub_crm = EventSubscription::new(
        "sub_crm_booking",
        "lyxal_crm",
        "booking.*",
        "sync_customer_crm",
    );

    store
        .register_subscription(&sub_notification)
        .await
        .unwrap();
    store.register_subscription(&sub_crm).await.unwrap();

    // Configuration des handlers
    let notif_count = Arc::new(AtomicUsize::new(0));

    let mut registry = HandlerRegistry::new();
    registry
        .register(NotificationBookingHandler {
            received: notif_count.clone(),
        })
        .unwrap();

    let publisher = EventPublisher::new(
        store.clone(),
        "lyxal_booking",
        EventContext::new("inst1", "test_ns", "test_db"),
    );

    let event = BookingCreated {
        booking_id: "book_abc123".to_string(),
        customer_email: "alice@example.com".to_string(),
    };

    let published = publisher.publish(&event).await.unwrap();
    assert_eq!(published.event_type, "booking.created");

    // Vérification de la création des 2 livraisons
    let worker_config = EventWorkerConfig::default()
        .with_batch_size(10)
        .with_dispatch_timeout(Duration::from_secs(5));

    let worker = EventWorker::new(store.clone(), registry, worker_config);
    let cancel = CancellationToken::new();

    let processed = worker.poll_cycle(&cancel).await.unwrap();
    assert_eq!(processed, 2, "Expected 2 deliveries claimed and processed");

    assert_eq!(
        notif_count.load(Ordering::SeqCst),
        2,
        "Notification handler should receive both deliveries matching pattern"
    );
}
