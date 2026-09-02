use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    MemoryWorkerStore, SurrealWorkerStore, WorkerCriticality, WorkerId, WorkerMetrics, WorkerState,
    WorkerStore,
};
use surrealdb::engine::any::connect;

#[tokio::test]
async fn test_worker_state_persistence_memory() {
    let store = MemoryWorkerStore::new();
    store.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-alpha");
    let mod_id = ModuleId::new("lyxal-notification");
    let worker_id = WorkerId::new(&mod_id, "delivery").unwrap();

    let metrics = WorkerMetrics {
        started_at: Some(1700000000),
        restart_count: 2,
        failure_count: 1,
        last_error: Some("Transient error".to_string()),
        ..Default::default()
    };

    store
        .upsert_worker(
            &node_id,
            &worker_id,
            &mod_id,
            WorkerState::Running,
            WorkerCriticality::Required,
            &metrics,
        )
        .await
        .unwrap();

    let row = store
        .get_worker(&node_id, &worker_id)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(row.node_id, "node-alpha");
    assert_eq!(row.worker_id, "lyxal-notification:delivery");
    assert_eq!(row.module_id, "lyxal-notification");
    assert_eq!(row.state, "running");
    assert_eq!(row.criticality, "required");
    assert_eq!(row.restart_count, 2);
    assert_eq!(row.failure_count, 1);
    assert_eq!(row.last_error, Some("Transient error".to_string()));

    let list = store.list_node_workers(&node_id).await.unwrap();
    assert_eq!(list.len(), 1);
}

#[tokio::test]
async fn test_worker_state_persistence_surreal() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_worker_store")
        .use_db("test_worker_store")
        .await
        .unwrap();

    let store = SurrealWorkerStore::new(client);
    store.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-beta");
    let mod_id = ModuleId::new("lyxal-webhook");
    let worker_id = WorkerId::new(&mod_id, "dispatcher").unwrap();

    let mut metrics = WorkerMetrics {
        started_at: Some(1700000100),
        restart_count: 0,
        failure_count: 0,
        ..Default::default()
    };

    store
        .upsert_worker(
            &node_id,
            &worker_id,
            &mod_id,
            WorkerState::Running,
            WorkerCriticality::Optional,
            &metrics,
        )
        .await
        .unwrap();

    let row = store
        .get_worker(&node_id, &worker_id)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(row.node_id, "node-beta");
    assert_eq!(row.worker_id, "lyxal-webhook:dispatcher");
    assert_eq!(row.state, "running");
    assert_eq!(row.criticality, "optional");

    // Mise à jour de l'état vers Stopped
    metrics.stopped_at = Some(1700000200);
    store
        .upsert_worker(
            &node_id,
            &worker_id,
            &mod_id,
            WorkerState::Stopped,
            WorkerCriticality::Optional,
            &metrics,
        )
        .await
        .unwrap();

    let row_updated = store
        .get_worker(&node_id, &worker_id)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(row_updated.state, "stopped");
    assert_eq!(row_updated.stopped_at, Some(1700000200));

    let list = store.list_node_workers(&node_id).await.unwrap();
    assert_eq!(list.len(), 1);
}
