use lyxal_runtime::event::bus::{MemoryRuntimeEventBus, RuntimeEventBus};
use lyxal_runtime::event::event::RuntimeEventDraft;
use lyxal_runtime::event::filter::RuntimeEventFilter;
use lyxal_runtime::event::kind::RuntimeEventKind;
use lyxal_runtime::event::payload::{
    LifecycleEvent, ModuleEvent, RuntimeEventPayload, RuntimeSystemEvent,
};
use lyxal_runtime::event::subscription::SubscriptionError;
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use std::collections::HashSet;
use std::sync::Arc;

#[tokio::test]
async fn test_publish_assigns_monotonic_sequence() {
    let node_id = NodeId::new("node-seq-test");
    let bus = MemoryRuntimeEventBus::new(node_id.clone());

    for i in 1..=10 {
        let draft = RuntimeEventDraft::new(
            RuntimeEventKind::Runtime,
            RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
        );
        let event = bus.publish(draft).await.unwrap();
        assert_eq!(event.sequence, i);
        assert_eq!(event.node_id, node_id);
        assert!(!event.id.as_str().is_empty());
    }

    let stats = bus.stats();
    assert_eq!(stats.published, 10);
}

#[tokio::test]
async fn test_multiple_subscribers_receive_event() {
    let node_id = NodeId::new("node-multi");
    let bus = MemoryRuntimeEventBus::new(node_id);

    let mut sub1 = bus.subscribe(RuntimeEventFilter::all());
    let mut sub2 = bus.subscribe(RuntimeEventFilter::all());

    let draft = RuntimeEventDraft::new(
        RuntimeEventKind::Runtime,
        RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
    );
    let published = bus.publish(draft).await.unwrap();

    let evt1 = sub1.recv().await.unwrap();
    let evt2 = sub2.recv().await.unwrap();

    assert_eq!(evt1.id, published.id);
    assert_eq!(evt2.id, published.id);
    assert_eq!(evt1.sequence, published.sequence);
}

#[tokio::test]
async fn test_filter_by_kind() {
    let node_id = NodeId::new("node-filter-kind");
    let bus = MemoryRuntimeEventBus::new(node_id);

    let filter = RuntimeEventFilter::for_kinds([RuntimeEventKind::Lifecycle]);
    let mut sub = bus.subscribe(filter);

    // 1. Publier un événement Module (doit être filtré)
    let draft_mod = RuntimeEventDraft::new(
        RuntimeEventKind::Module,
        RuntimeEventPayload::Module(ModuleEvent::Registered {
            version: "1.0".to_string(),
            description: None,
        }),
    );
    bus.publish(draft_mod).await.unwrap();

    // 2. Publier un événement Lifecycle (doit être reçu)
    let draft_lc = RuntimeEventDraft::new(
        RuntimeEventKind::Lifecycle,
        RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
    );
    let pub_lc = bus.publish(draft_lc).await.unwrap();

    let received = sub.recv().await.unwrap();
    assert_eq!(received.id, pub_lc.id);
    assert_eq!(received.kind, RuntimeEventKind::Lifecycle);
}

#[tokio::test]
async fn test_filter_by_module() {
    let node_id = NodeId::new("node-filter-mod");
    let bus = MemoryRuntimeEventBus::new(node_id);

    let target_mod = ModuleId::new("lyxal-target");
    let other_mod = ModuleId::new("lyxal-other");

    let filter = RuntimeEventFilter::for_modules([target_mod.clone()]);
    let mut sub = bus.subscribe(filter);

    // Événement pour autre module -> filtré
    let draft_other = RuntimeEventDraft::new(
        RuntimeEventKind::Lifecycle,
        RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
    )
    .with_module_id(other_mod);
    bus.publish(draft_other).await.unwrap();

    // Événement pour target module -> reçu
    let draft_target = RuntimeEventDraft::new(
        RuntimeEventKind::Lifecycle,
        RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
    )
    .with_module_id(target_mod.clone());
    let pub_target = bus.publish(draft_target).await.unwrap();

    let received = sub.recv().await.unwrap();
    assert_eq!(received.id, pub_target.id);
    assert_eq!(received.module_id, Some(target_mod));
}

#[tokio::test]
async fn test_slow_subscriber_does_not_block_publisher() {
    let node_id = NodeId::new("node-slow");
    // Capacité réduite pour tester rapidement le débordement
    let bus = MemoryRuntimeEventBus::with_capacity(node_id, 32);

    let mut slow_sub = bus.subscribe(RuntimeEventFilter::all());

    // Le producteur publie 100 événements sans jamais être bloqué
    for _ in 0..100 {
        let draft = RuntimeEventDraft::new(
            RuntimeEventKind::Runtime,
            RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
        );
        bus.publish(draft).await.unwrap();
    }

    assert_eq!(bus.stats().published, 100);

    // Le consommateur lent tente de lire et constate un retard (Lagged)
    match slow_sub.recv().await {
        Err(SubscriptionError::Lagged(missed)) => {
            assert!(missed > 0);
        }
        other => panic!("Expected Lagged error, got: {:?}", other),
    }

    // Après l'erreur Lagged, le consommateur reçoit l'événement le plus récent disponible
    let next_evt = slow_sub.recv().await.unwrap();
    assert!(next_evt.sequence > 50);
}

#[tokio::test]
async fn test_closed_subscriber_does_not_break_bus() {
    let node_id = NodeId::new("node-drop");
    let bus = MemoryRuntimeEventBus::new(node_id);

    {
        let _sub = bus.subscribe(RuntimeEventFilter::all());
        // `_sub` est détruit ici
    }

    // Publier après fermeture des souscriptions ne génère aucune erreur
    let draft = RuntimeEventDraft::new(
        RuntimeEventKind::Runtime,
        RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
    );
    let res = bus.publish(draft).await;
    assert!(res.is_ok());
}

#[tokio::test]
async fn test_concurrent_publishers_preserve_unique_sequences() {
    let node_id = NodeId::new("node-concurrent");
    let bus = Arc::new(MemoryRuntimeEventBus::new(node_id));

    let mut tasks = Vec::new();
    for _ in 0..10 {
        let bus_clone = bus.clone();
        tasks.push(tokio::spawn(async move {
            let mut events = Vec::new();
            for _ in 0..50 {
                let draft = RuntimeEventDraft::new(
                    RuntimeEventKind::Runtime,
                    RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
                );
                let evt = bus_clone.publish(draft).await.unwrap();
                events.push(evt);
            }
            events
        }));
    }

    let mut all_events = Vec::new();
    for t in tasks {
        let evts = t.await.unwrap();
        all_events.extend(evts);
    }

    assert_eq!(all_events.len(), 500);

    let mut seq_set = HashSet::new();
    let mut id_set = HashSet::new();
    for e in all_events {
        assert!(seq_set.insert(e.sequence));
        assert!(id_set.insert(e.id.as_str().to_string()));
    }

    assert_eq!(seq_set.len(), 500);
    assert_eq!(id_set.len(), 500);
}
