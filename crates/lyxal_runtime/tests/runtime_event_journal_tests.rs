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
use surrealdb::engine::any::connect;

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
    let client = connect("mem://").await.unwrap();
    client.use_ns("test_ns").use_db("test_db").await.unwrap();

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
