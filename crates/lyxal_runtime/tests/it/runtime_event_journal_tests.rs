use crate::common;
use lyxal_runtime::event::bus::{MemoryRuntimeEventBus, RuntimeEventBus};
use lyxal_runtime::event::event::RuntimeEventDraft;
use lyxal_runtime::event::id::RuntimeEventId;
use lyxal_runtime::event::journal::{MemoryRuntimeEventJournal, RuntimeEventJournal};
use lyxal_runtime::event::kind::RuntimeEventKind;
use lyxal_runtime::event::payload::{LifecycleEvent, RuntimeEventPayload, RuntimeSystemEvent};
use lyxal_runtime::event::store::SurrealRuntimeEventJournal;
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeEvent;
use std::sync::Arc;

#[tokio::test]
async fn test_memory_journal_append_and_recent() {
    let journal = MemoryRuntimeEventJournal::with_capacity(5);
    let node_id = NodeId::new("node-mem-test");

    for i in 1..=10 {
        let event = RuntimeEvent {
            id: RuntimeEventId::generate(),
            sequence: i,
            node_id: node_id.clone(),
            timestamp_ms: 1000 + i,
            kind: RuntimeEventKind::Runtime,
            module_id: None,
            correlation_id: None,
            causation_id: None,
            payload: RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
        };
        journal.append(&event).await.unwrap();
    }

    assert_eq!(journal.len().await, 5);

    let recent = journal.recent(10).await.unwrap();
    assert_eq!(recent.len(), 5);
    // Plus récent en premier
    assert_eq!(recent[0].sequence, 10);
    assert_eq!(recent[4].sequence, 6);
}

#[tokio::test]
async fn test_memory_journal_filter_by_module() {
    let journal = MemoryRuntimeEventJournal::default();
    let node_id = NodeId::new("node-mem-mod");
    let mod_a = ModuleId::new("lyxal-mod-a");
    let mod_b = ModuleId::new("lyxal-mod-b");

    for i in 1..=6 {
        let mod_id = if i % 2 == 0 {
            Some(mod_a.clone())
        } else {
            Some(mod_b.clone())
        };

        let event = RuntimeEvent {
            id: RuntimeEventId::generate(),
            sequence: i,
            node_id: node_id.clone(),
            timestamp_ms: 1000 + i,
            kind: RuntimeEventKind::Lifecycle,
            module_id: mod_id,
            correlation_id: None,
            causation_id: None,
            payload: RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
        };
        journal.append(&event).await.unwrap();
    }

    let for_a = journal.by_module(&mod_a, 10).await.unwrap();
    assert_eq!(for_a.len(), 3);
    assert_eq!(for_a[0].sequence, 6);
    assert_eq!(for_a[1].sequence, 4);
    assert_eq!(for_a[2].sequence, 2);
}

#[tokio::test]
async fn test_surreal_journal_append_and_query() {
    let client = common::setup_db("test_ns", "test_db").await;

    let journal = SurrealRuntimeEventJournal::new(client);
    journal.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-surreal-1");
    let mod_target = ModuleId::new("lyxal-auth");

    for i in 1..=5 {
        let event = RuntimeEvent {
            id: RuntimeEventId::generate(),
            sequence: i,
            node_id: node_id.clone(),
            timestamp_ms: 1700000000000 + i,
            kind: RuntimeEventKind::Lifecycle,
            module_id: Some(mod_target.clone()),
            correlation_id: Some("tx-abc".to_string()),
            causation_id: None,
            payload: RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
        };
        journal.append(&event).await.unwrap();
    }

    let recent = journal.recent(10).await.unwrap();
    assert_eq!(recent.len(), 5);
    assert_eq!(recent[0].sequence, 5);
    assert_eq!(recent[4].sequence, 1);

    let by_mod = journal.by_module(&mod_target, 2).await.unwrap();
    assert_eq!(by_mod.len(), 2);
    assert_eq!(by_mod[0].sequence, 5);
    assert_eq!(by_mod[1].sequence, 4);
}

#[tokio::test]
async fn test_bus_with_journal_persists_events_asynchronously() {
    let journal = Arc::new(MemoryRuntimeEventJournal::default());
    let node_id = NodeId::new("node-bus-journal");
    let bus = MemoryRuntimeEventBus::new(node_id).with_journal(journal.clone());

    for _i in 1..=5 {
        let draft = RuntimeEventDraft::new(
            RuntimeEventKind::Runtime,
            RuntimeEventPayload::Runtime(RuntimeSystemEvent::Started),
        );
        bus.publish(draft).await.unwrap();
    }

    // Petite attente pour le background worker mpsc
    tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;

    assert_eq!(journal.len().await, 5);
    let recent = journal.recent(5).await.unwrap();
    assert_eq!(recent.len(), 5);
}

/// Ordre total de `fn::runtime_event_list` : à date égale, le nœud puis la séquence départagent
/// (une séquence n'est unique que par nœud) ; une liste tronquée garde toujours les mêmes événements.
#[tokio::test]
async fn test_surreal_journal_orders_equal_timestamps_by_node_then_sequence() {
    let client = common::setup_db("test_ns", "test_journal_order").await;

    let journal = SurrealRuntimeEventJournal::new(client);
    journal.bootstrap().await.unwrap();

    let module = ModuleId::new("lyxal-auth");
    // (nœud, séquence, date) : trois événements à la même date, dont deux nœuds à la même séquence
    let rows = [
        ("node-a", 1, 1_700_000_000_500),
        ("node-b", 1, 1_700_000_000_500),
        ("node-a", 2, 1_700_000_000_500),
        ("node-b", 9, 1_700_000_000_400),
    ];
    for (node, sequence, timestamp_ms) in rows {
        let event = RuntimeEvent {
            id: RuntimeEventId::generate(),
            sequence,
            node_id: NodeId::new(node),
            timestamp_ms,
            kind: RuntimeEventKind::Lifecycle,
            module_id: Some(module.clone()),
            correlation_id: None,
            causation_id: None,
            payload: RuntimeEventPayload::Lifecycle(LifecycleEvent::Started),
        };
        journal.append(&event).await.unwrap();
    }

    let expected = [("node-b", 1), ("node-a", 2), ("node-a", 1), ("node-b", 9)];
    for limit in 1..=expected.len() {
        for _ in 0..2 {
            let recent: Vec<(String, u64)> = journal
                .recent(limit)
                .await
                .unwrap()
                .iter()
                .map(|event| (event.node_id.to_string(), event.sequence))
                .collect();
            let by_module: Vec<(String, u64)> = journal
                .by_module(&module, limit)
                .await
                .unwrap()
                .iter()
                .map(|event| (event.node_id.to_string(), event.sequence))
                .collect();
            let wanted: Vec<(String, u64)> = expected[..limit]
                .iter()
                .map(|(node, sequence)| (node.to_string(), *sequence))
                .collect();
            assert_eq!(recent, wanted, "limite {limit}");
            assert_eq!(by_module, wanted, "limite {limit} (par module)");
        }
    }
}
