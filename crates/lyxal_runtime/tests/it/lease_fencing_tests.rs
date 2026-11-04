//! Baux du runtime : échéances à l'heure de la base, garde de bail sur l'enregistrement d'une
//! migration et renouvellement pendant une migration plus longue que le bail.

use crate::common;
use lyxal_runtime::lock::{
    AcquireLeaseResult, MigrationLease, MigrationLeaseManager, MigrationLockConfig,
    MigrationLockKey, NodeId, SurrealMigrationLeaseManager,
};
use lyxal_runtime::migration::{
    MigrationChecksum, MigrationDefinition, MigrationId, MigrationPlan, MigrationRecord,
    MigrationRunner, MigrationStatus,
};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_runtime::store::{RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeError;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::types::SurrealValue;

struct SingleResource {
    path: &'static str,
    content: &'static str,
}

#[async_trait::async_trait]
impl ResourceProvider for SingleResource {
    async fn read(&self, logical_path: &str) -> Result<String, RuntimeError> {
        if logical_path == self.path {
            Ok(self.content.to_string())
        } else {
            Err(RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            })
        }
    }
}

fn key() -> MigrationLockKey {
    MigrationLockKey::new(
        ModuleId::new("lyxal_booking"),
        MigrationId::new("0001_initial").unwrap(),
    )
}

fn acquired(result: AcquireLeaseResult) -> MigrationLease {
    match result {
        AcquireLeaseResult::Acquired(l) | AcquireLeaseResult::RecoveredExpiredLease(l) => l,
        other => panic!("bail attendu, obtenu {other:?}"),
    }
}

async fn db_now(client: &surrealdb::Surreal<surrealdb::engine::any::Any>) -> i64 {
    let mut res = client
        .query("RETURN time::unix(time::now());")
        .await
        .unwrap();
    res.take::<Option<i64>>(0).unwrap().unwrap()
}

fn record(status: MigrationStatus) -> MigrationRecord {
    MigrationRecord {
        migration_id: MigrationId::new("0001_initial").unwrap(),
        module_id: ModuleId::new("lyxal_booking"),
        module_version: "0.1.0".to_string(),
        checksum: MigrationChecksum::from_surql("-- vide"),
        applied_at: 0,
        duration_ms: 0,
        status,
        error: None,
    }
}

#[tokio::test]
async fn test_lease_deadlines_follow_database_time() {
    let client = common::setup_db("lease_db_time", "lease_db_time").await;
    let manager = SurrealMigrationLeaseManager::new(client.clone());

    let before = db_now(&client).await;
    let lease = acquired(
        manager
            .acquire(&key(), &NodeId::new("node-a"), Duration::from_secs(30))
            .await
            .unwrap(),
    );
    let after = db_now(&client).await;

    let acquired_at = i64::try_from(lease.acquired_at).unwrap();
    assert!(before <= acquired_at && acquired_at <= after);
    assert_eq!(lease.expires_at - lease.acquired_at, 30);

    // Un bail dont l'échéance, à l'heure de la base, est dépassée est repris quelle que soit
    // l'horloge du nœud ; un bail dont l'échéance est à venir ne l'est pas.
    client
        .query("UPDATE runtime_lease SET expires_at = time::unix(time::now()) + 3600;")
        .await
        .unwrap()
        .check()
        .unwrap();
    let held = manager
        .acquire(&key(), &NodeId::new("node-b"), Duration::from_secs(30))
        .await
        .unwrap();
    assert!(matches!(held, AcquireLeaseResult::HeldByOther { .. }));

    client
        .query("UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1;")
        .await
        .unwrap()
        .check()
        .unwrap();
    let recovered = manager
        .acquire(&key(), &NodeId::new("node-b"), Duration::from_secs(30))
        .await
        .unwrap();
    match recovered {
        AcquireLeaseResult::RecoveredExpiredLease(l) => {
            assert_eq!(l.owner, NodeId::new("node-b"));
            assert_eq!(l.generation, lease.generation + 1);
        }
        other => panic!("reprise attendue, obtenu {other:?}"),
    }
    assert!(manager.inspect(&key()).await.unwrap().is_some());
}

#[tokio::test]
async fn test_migration_record_is_fenced_after_takeover() {
    let client = common::setup_db("lease_fenced_record", "lease_fenced_record").await;
    let store = SurrealRuntimeStore::new(client.clone());
    let manager = SurrealMigrationLeaseManager::new(client.clone());

    let lease_a = acquired(
        manager
            .acquire(&key(), &NodeId::new("node-a"), Duration::from_secs(30))
            .await
            .unwrap(),
    );
    store
        .record_migration(&record(MigrationStatus::Applying), Some(&lease_a))
        .await
        .unwrap();

    // Le bail de A expire (nœud figé) et B le reprend.
    client
        .query("UPDATE runtime_lease SET expires_at = time::unix(time::now()) - 1;")
        .await
        .unwrap()
        .check()
        .unwrap();
    let lease_b = acquired(
        manager
            .acquire(&key(), &NodeId::new("node-b"), Duration::from_secs(30))
            .await
            .unwrap(),
    );
    assert_eq!(lease_b.generation, lease_a.generation + 1);

    // A ne peut plus écrire le résultat ; rien n'est écrit.
    let err = store
        .record_migration(&record(MigrationStatus::Applied), Some(&lease_a))
        .await
        .unwrap_err();
    assert!(
        matches!(&err, RuntimeError::LeaseFenced { generation, .. } if *generation == lease_a.generation),
        "{err:?}"
    );
    assert_eq!(err.code(), "RUNTIME_LEASE_FENCED");
    let stored = store
        .get_migration(
            &ModuleId::new("lyxal_booking"),
            &MigrationId::new("0001_initial").unwrap(),
        )
        .await
        .unwrap()
        .unwrap();
    assert_eq!(stored.status, MigrationStatus::Applying);

    // B, détenteur actuel, écrit.
    store
        .record_migration(&record(MigrationStatus::Applied), Some(&lease_b))
        .await
        .unwrap();
}

#[tokio::test]
async fn test_migration_longer_than_lease_runs_exactly_once() {
    let client = common::setup_db("lease_long_migration", "lease_long_migration").await;
    let store: Arc<dyn RuntimeStore> = Arc::new(SurrealRuntimeStore::new(client.clone()));

    const PATH: &str = "migrations/0001_initial.surql";
    const SQL: &str = "CREATE long_counter SET val = 1; SLEEP 3s;";
    let provider = Arc::new(SingleResource {
        path: PATH,
        content: SQL,
    });
    let module_id = ModuleId::new("lyxal_booking");
    let mut def = MigrationDefinition::new(
        MigrationId::new("0001_initial").unwrap(),
        module_id.clone(),
        semver::Version::parse("0.1.0").unwrap(),
        MigrationChecksum::from_surql(SQL),
        1,
    );
    def.resource_path = Some(PATH.to_string());

    // Bail de 2 s, renouvelé toutes les 500 ms ; la migration dure 3 s.
    let config = MigrationLockConfig {
        lease_duration: Duration::from_secs(2),
        renew_interval: Duration::from_millis(500),
        acquire_timeout: Duration::from_secs(20),
        acquire_retry_delay: Duration::from_millis(100),
    };
    let mut handles = Vec::new();
    for node in ["node-a", "node-b"] {
        let runner = MigrationRunner::new(store.clone(), client.clone())
            .with_node_id(NodeId::new(node))
            .with_lock_config(config.clone());
        let plan = MigrationPlan::from_definitions_and_store(
            &module_id,
            "0.1.0",
            &[def.clone()],
            store.as_ref(),
        )
        .await
        .unwrap();
        let provider = provider.clone();
        handles.push(tokio::spawn(async move {
            runner.execute_plan(&plan, provider.as_ref()).await
        }));
    }

    let mut applied = 0;
    let mut skipped = 0;
    for handle in handles {
        let result = handle.await.unwrap().unwrap();
        applied += result.applied.len();
        skipped += result.skipped.len();
    }
    assert_eq!((applied, skipped), (1, 1));

    #[derive(SurrealValue)]
    struct Row {
        val: i64,
    }
    let mut res = client.query("SELECT val FROM long_counter;").await.unwrap();
    let rows: Vec<Row> = res.take(0).unwrap();
    assert_eq!(rows.len(), 1, "la migration ne doit s'exécuter qu'une fois");
}
