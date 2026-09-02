use lyxal_runtime::health::check::HealthCheckResult;
use lyxal_runtime::health::snapshot::HealthSnapshot;
use lyxal_runtime::health::status::HealthStatus;
use lyxal_runtime::health::store::{HealthStore, MemoryHealthStore, SurrealHealthStore};
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use surrealdb::engine::any::connect;

#[tokio::test]
async fn test_memory_health_store_crud() {
    let store = MemoryHealthStore::new();
    let node_id = NodeId::new("node-1");

    let snapshot = HealthSnapshot::new(vec![HealthCheckResult::healthy(
        ModuleId::new("lyxal-auth"),
        12,
        Some("OK".to_string()),
    )]);

    store
        .record_health_snapshot(&node_id, &snapshot)
        .await
        .unwrap();

    let fetched = store
        .get_node_health(&node_id)
        .await
        .unwrap()
        .expect("Must exist");
    assert_eq!(fetched.modules.len(), 1);
    assert_eq!(
        fetched.get_status(&ModuleId::new("lyxal-auth")),
        Some(HealthStatus::Healthy)
    );
}

#[tokio::test]
async fn test_surreal_health_store_bootstrap_and_upsert() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_health_store_1")
        .use_db("test_health_store_1")
        .await
        .unwrap();

    let store = SurrealHealthStore::new(client);
    store.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-alpha");
    let snapshot = HealthSnapshot::new(vec![
        HealthCheckResult::healthy(ModuleId::new("lyxal-timezone"), 5, None),
        HealthCheckResult::degraded(
            ModuleId::new("lyxal-calendar"),
            25,
            Some("High latency".to_string()),
        ),
    ]);

    store
        .record_health_snapshot(&node_id, &snapshot)
        .await
        .unwrap();

    let fetched = store
        .get_node_health(&node_id)
        .await
        .unwrap()
        .expect("Must exist");
    assert_eq!(fetched.modules.len(), 2);
    assert_eq!(
        fetched.get_status(&ModuleId::new("lyxal-timezone")),
        Some(HealthStatus::Healthy)
    );
    assert_eq!(
        fetched.get_status(&ModuleId::new("lyxal-calendar")),
        Some(HealthStatus::Degraded)
    );
}

#[tokio::test]
async fn test_surreal_health_store_idempotence_and_status_update() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_health_store_2")
        .use_db("test_health_store_2")
        .await
        .unwrap();

    let store = SurrealHealthStore::new(client);
    store.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-beta");

    // 1. Initial : Healthy
    let snapshot1 = HealthSnapshot::new(vec![HealthCheckResult::healthy(
        ModuleId::new("lyxal-booking"),
        10,
        None,
    )]);
    store
        .record_health_snapshot(&node_id, &snapshot1)
        .await
        .unwrap();

    // 2. Mise à jour idempotente : Unhealthy
    let snapshot2 = HealthSnapshot::new(vec![HealthCheckResult::unhealthy(
        ModuleId::new("lyxal-booking"),
        Some(10),
        Some("Crash".to_string()),
    )]);
    store
        .record_health_snapshot(&node_id, &snapshot2)
        .await
        .unwrap();

    let fetched = store
        .get_node_health(&node_id)
        .await
        .unwrap()
        .expect("Must exist");
    assert_eq!(fetched.modules.len(), 1);
    assert_eq!(
        fetched.get_status(&ModuleId::new("lyxal-booking")),
        Some(HealthStatus::Unhealthy)
    );
}

#[tokio::test]
async fn test_health_status_not_stale_after_module_stop() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_health_store_3")
        .use_db("test_health_store_3")
        .await
        .unwrap();

    let store = SurrealHealthStore::new(client);
    store.bootstrap().await.unwrap();

    let node_id = NodeId::new("node-gamma");

    // 1. Module Running -> Healthy
    let snapshot_running = HealthSnapshot::new(vec![HealthCheckResult::healthy(
        ModuleId::new("lyxal-booking"),
        8,
        None,
    )]);
    store
        .record_health_snapshot(&node_id, &snapshot_running)
        .await
        .unwrap();

    // 2. Module devient Stopped -> NotApplicable
    let snapshot_stopped = HealthSnapshot::new(vec![HealthCheckResult::not_applicable(
        ModuleId::new("lyxal-booking"),
        Some("Module is stopped".to_string()),
    )]);
    store
        .record_health_snapshot(&node_id, &snapshot_stopped)
        .await
        .unwrap();

    let fetched = store
        .get_node_health(&node_id)
        .await
        .unwrap()
        .expect("Must exist");
    assert_eq!(
        fetched.get_status(&ModuleId::new("lyxal-booking")),
        Some(HealthStatus::NotApplicable),
        "Store must record NotApplicable and not retain stale Healthy state"
    );
}
