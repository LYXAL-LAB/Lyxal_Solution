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

/// La liste compilée des ressources installées par `EventStore::install` est exactement celle de
/// `manifest.toml`, dans le même ordre : une ressource ajoutée d'un seul côté fait échouer ce test.
#[test]
fn test_install_resources_match_manifest() {
    let manifest_path = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manifest.toml");
    let manifest: toml::Value =
        toml::from_str(&std::fs::read_to_string(&manifest_path).unwrap()).unwrap();
    let resources = &manifest["resources"];
    let expected: Vec<String> = ["schemas", "functions", "error_definitions"]
        .iter()
        .flat_map(|key| {
            resources[key]
                .as_array()
                .unwrap()
                .iter()
                .map(|f| f.as_str().unwrap().to_string())
                .collect::<Vec<_>>()
        })
        .collect();
    let compiled: Vec<String> = lyxal_event::store::event_store::INSTALL_RESOURCES
        .iter()
        .map(|(path, _)| path.to_string())
        .collect();
    assert_eq!(compiled, expected);
    for (path, script) in lyxal_event::store::event_store::INSTALL_RESOURCES {
        let on_disk = std::fs::read_to_string(
            std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(path),
        )
        .unwrap();
        assert_eq!(*script, on_disk, "{path} compilé différent du fichier");
    }
}
