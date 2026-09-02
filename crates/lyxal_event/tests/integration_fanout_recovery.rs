use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use surrealdb::engine::any::connect;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct InvoiceIssued {
    pub invoice_id: String,
    pub total: u64,
}

impl Event for InvoiceIssued {
    const EVENT_TYPE: &'static str = "invoice.issued";
}

#[tokio::test]
async fn test_recover_pending_fanouts_after_crash() {
    let db = connect("mem://").await.unwrap();
    db.use_ns("test_ns").use_db("test_db").await.unwrap();

    let store = Arc::new(EventStore::new(db.clone()));
    store.init_schema().await.unwrap();

    // Enregistrement de 2 subscriptions
    let sub1 = EventSubscription::new(
        "sub_accounting",
        "lyxal_accounting",
        "invoice.issued",
        "handle_invoice",
    );
    let sub2 = EventSubscription::new(
        "sub_analytics",
        "lyxal_analytics",
        "invoice.*",
        "track_revenue",
    );
    store.register_subscription(&sub1).await.unwrap();
    store.register_subscription(&sub2).await.unwrap();

    // Publication avec auto_fanout = false (simule un crash ou arrêt du processus juste après la création dans outbox)
    let event = InvoiceIssued {
        invoice_id: "inv_999".to_string(),
        total: 15000,
    };
    let envelope = LyxalEventEnvelope::new("billing", EventContext::default(), &event).unwrap();
    let published = store.publish(&envelope, false).await.unwrap();
    assert_eq!(published.event_type, "invoice.issued");

    // Vérifie que l'événement outbox est resté en statut 'pending'
    let mut check_outbox = db
        .query("SELECT * FROM event_outbox WHERE status = 'pending'")
        .await
        .unwrap();
    let pending_outboxes: Vec<LyxalEventEnvelope> = check_outbox.take(0).unwrap();
    assert_eq!(
        pending_outboxes.len(),
        1,
        "Outbox should be in status pending"
    );

    // Vérifie qu'aucune livraison n'existe encore
    let mut check_deliveries = db.query("SELECT * FROM event_delivery").await.unwrap();
    let initial_deliveries: Vec<EventDelivery> = check_deliveries.take(0).unwrap();
    assert_eq!(
        initial_deliveries.len(),
        0,
        "No deliveries should exist before fanout recovery"
    );

    // Déclenchement de la reprise des fan-outs (simule le redémarrage du runtime / worker)
    let recovered_count = store.recover_pending_fanouts(10).await.unwrap();
    assert_eq!(
        recovered_count, 1,
        "Exactly 1 pending outbox event recovered"
    );

    // Vérifie que les 2 livraisons existent maintenant
    let mut check_deliveries2 = db.query("SELECT * FROM event_delivery").await.unwrap();
    let created_deliveries: Vec<EventDelivery> = check_deliveries2.take(0).unwrap();
    assert_eq!(
        created_deliveries.len(),
        2,
        "2 deliveries should have been created during recovery"
    );

    // Relance la reprise pour prouver l'idempotence stricte (0 livraison dupliquée)
    let second_recovery = store.recover_pending_fanouts(10).await.unwrap();
    assert_eq!(second_recovery, 0, "No more pending outboxes to recover");

    let mut check_deliveries3 = db.query("SELECT * FROM event_delivery").await.unwrap();
    let idempotent_deliveries: Vec<EventDelivery> = check_deliveries3.take(0).unwrap();
    assert_eq!(
        idempotent_deliveries.len(),
        2,
        "Idempotence must ensure exactly 2 deliveries exist"
    );
}
