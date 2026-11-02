use lyxal_event::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
struct OrderCreated {
    pub order_id: String,
    pub amount: u64,
}

impl Event for OrderCreated {
    const EVENT_TYPE: &'static str = "orders.created";
}

struct DummyHandler {
    pub count: Arc<AtomicUsize>,
}

#[async_trait::async_trait]
impl Handler<OrderCreated> for DummyHandler {
    async fn handle(
        &self,
        _event: OrderCreated,
        _ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.count.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

#[test]
fn test_envelope_creation_and_decoding() {
    let order = OrderCreated {
        order_id: "ord_123".to_string(),
        amount: 4500,
    };
    let context = EventContext::new("inst_test", "ns_test", "db_test");
    let envelope = LyxalEventEnvelope::new("orders", context, &order).unwrap();

    assert_eq!(envelope.event_type, "orders.created");
    assert_eq!(envelope.producer, "orders");
    assert_eq!(envelope.context.instance_id, "inst_test");

    let decoded: OrderCreated = envelope.decode().unwrap();
    assert_eq!(decoded, order);
}

#[test]
fn test_handler_registry_duplicate_rejection() {
    let mut registry = HandlerRegistry::new();
    let handler1 = DummyHandler {
        count: Arc::new(AtomicUsize::new(0)),
    };
    let handler2 = DummyHandler {
        count: Arc::new(AtomicUsize::new(0)),
    };

    assert!(registry.register(handler1).is_ok());
    let duplicate_res = registry.register(handler2);
    assert!(duplicate_res.is_err(), "Duplicate registration must fail");
}
