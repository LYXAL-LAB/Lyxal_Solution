use lyxal_runtime::lock::{
    AcquireInstallationLeaseResult, AcquireLeaseResult, InstallationLeaseManager,
    InstallationLockKey, MigrationLeaseManager, MigrationLockConfig, MigrationLockKey,
    MigrationRecoveryPolicy, NodeId, SurrealInstallationLeaseManager, SurrealMigrationLeaseManager,
};
use lyxal_runtime::migration::{
    MigrationChecksum, MigrationDefinition, MigrationId, MigrationPlan, MigrationRecord,
    MigrationRunner, MigrationStatus,
};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_runtime::store::{RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeError;
use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio::sync::Barrier;

/// ResourceProvider en mémoire pour les tests d'intégration
struct MockResourceProvider {
    resources: HashMap<String, String>,
}

impl MockResourceProvider {
    fn new() -> Self {
        Self {
            resources: HashMap::new(),
        }
    }

    fn add(&mut self, path: &str, content: &str) {
        self.resources.insert(path.to_string(), content.to_string());
    }
}

#[async_trait::async_trait]
impl ResourceProvider for MockResourceProvider {
    async fn list_resources(&self, _prefix: &str) -> Result<Vec<String>, RuntimeError> {
        Ok(self.resources.keys().cloned().collect())
    }

    async fn read_resource(
        &self,
        logical_path: &str,
    ) -> Result<lyxal_runtime::resource::ModuleResource, RuntimeError> {
        let content =
            self.resources
                .get(logical_path)
                .ok_or_else(|| RuntimeError::ResourceNotFound {
                    path: logical_path.to_string(),
                })?;

        Ok(lyxal_runtime::resource::ModuleResource::new(
            logical_path,
            lyxal_runtime::resource::ResourceKind::Migration,
            content.clone(),
        ))
    }

    async fn exists(&self, logical_path: &str) -> bool {
        self.resources.contains_key(logical_path)
    }
}

async fn setup_shared_surreal_db(
    ns: &str,
    db: &str,
) -> (
    surrealdb::Surreal<surrealdb::engine::any::Any>,
    Arc<SurrealRuntimeStore>,
) {
    let client = connect("mem://").await.unwrap();
    client.use_ns(ns).use_db(db).await.unwrap();

    let store = Arc::new(SurrealRuntimeStore::new(client.clone()));
    store.bootstrap().await.unwrap();

    (client, store)
}

#[tokio::test]
async fn test_surreal_lease_manager_lifecycle() {
    let (client, _store) = setup_shared_surreal_db("test_lease_mgr", "test_lease_mgr").await;
    let manager = SurrealMigrationLeaseManager::new(client);

    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-booking"),
        MigrationId::new("001_init").unwrap(),
    );
    let node_a = NodeId::new("node-a");
    let node_b = NodeId::new("node-b");

    // 1. Node A acquiert un bail de 5 secondes
    let res_a = manager
        .acquire(&key, &node_a, Duration::from_secs(5))
        .await
        .unwrap();

    let lease_a = match res_a {
        AcquireLeaseResult::Acquired(l) => {
            assert_eq!(l.owner, node_a);
            assert_eq!(l.generation, 1);
            l
        }
        _ => panic!("Expected Acquired, got {:?}", res_a),
    };

    // 2. Node A réacquiert -> AlreadyOwned
    let res_a2 = manager
        .acquire(&key, &node_a, Duration::from_secs(5))
        .await
        .unwrap();
    match res_a2 {
        AcquireLeaseResult::AlreadyOwned(l) => {
            assert_eq!(l.generation, 1);
        }
        _ => panic!("Expected AlreadyOwned"),
    }

    // 3. Node B tente d'acquérir -> HeldByOther
    let res_b = manager
        .acquire(&key, &node_b, Duration::from_secs(5))
        .await
        .unwrap();
    match res_b {
        AcquireLeaseResult::HeldByOther { owner, .. } => {
            assert_eq!(owner, node_a);
        }
        _ => panic!("Expected HeldByOther"),
    }

    // 4. Node A renouvelle son bail
    let renewed = manager
        .renew(&lease_a, Duration::from_secs(10))
        .await
        .unwrap();
    assert_eq!(renewed.generation, 1);

    // 5. Node A libère le bail
    manager.release(&renewed).await.unwrap();

    // 6. Node B peut acquérir après libération -> RecoveredExpiredLease avec generation == 2 (anti-ABA)
    let res_b2 = manager
        .acquire(&key, &node_b, Duration::from_secs(5))
        .await
        .unwrap();
    match res_b2 {
        AcquireLeaseResult::RecoveredExpiredLease(l) => {
            assert_eq!(l.owner, node_b);
            assert_eq!(l.generation, 2);
        }
        _ => panic!(
            "Expected RecoveredExpiredLease for node-b, got {:?}",
            res_b2
        ),
    }
}

#[tokio::test]
async fn test_two_concurrent_runners_execute_exactly_once() {
    let (client, store) = setup_shared_surreal_db("test_two_runners", "test_two_runners").await;

    // Deux instances de MigrationRunner partageant la même base SurrealDB
    let runner_a = MigrationRunner::new(store.clone(), client.clone())
        .with_node_id(NodeId::new("node-alpha"))
        .with_lock_config(MigrationLockConfig {
            lease_duration: Duration::from_secs(15),
            renew_interval: Duration::from_secs(1),
            acquire_timeout: Duration::from_secs(15),
            acquire_retry_delay: Duration::from_millis(50),
        });

    let runner_b = MigrationRunner::new(store.clone(), client.clone())
        .with_node_id(NodeId::new("node-beta"))
        .with_lock_config(MigrationLockConfig {
            lease_duration: Duration::from_secs(15),
            renew_interval: Duration::from_secs(1),
            acquire_timeout: Duration::from_secs(15),
            acquire_retry_delay: Duration::from_millis(50),
        });

    // Fournisseur de ressource contenant une migration créant une table et insérant une ligne
    let mut provider = MockResourceProvider::new();
    let migration_sql = r#"
        DEFINE TABLE OVERWRITE test_counter SCHEMAFULL;
        DEFINE FIELD OVERWRITE val ON TABLE test_counter TYPE int;
        CREATE test_counter:main SET val = 42;
    "#;
    provider.add("migrations/001_create_counter.surql", migration_sql);
    let provider_arc = Arc::new(provider);

    let module_id = ModuleId::new("lyxal-booking");
    let version = "1.0.0";

    let mut def = MigrationDefinition::new(
        MigrationId::new("001_create_counter").unwrap(),
        module_id.clone(),
        semver::Version::parse(version).unwrap(),
        MigrationChecksum::from_surql(migration_sql),
        1,
    );
    def.resource_path = Some("migrations/001_create_counter.surql".to_string());

    let plan_a = MigrationPlan::from_definitions_and_store(
        &module_id,
        version,
        &[def.clone()],
        store.as_ref(),
    )
    .await
    .unwrap();

    let plan_b = MigrationPlan::from_definitions_and_store(
        &module_id,
        version,
        &[def.clone()],
        store.as_ref(),
    )
    .await
    .unwrap();

    let p_a = provider_arc.clone();
    let p_b = provider_arc.clone();

    // Lancement concurrent des deux runners sur la même migration
    let handle_a = tokio::spawn(async move { runner_a.execute_plan(&plan_a, p_a.as_ref()).await });

    let handle_b = tokio::spawn(async move { runner_b.execute_plan(&plan_b, p_b.as_ref()).await });

    let res_a = handle_a.await.unwrap().unwrap();
    let res_b = handle_b.await.unwrap().unwrap();

    // L'un a appliqué la migration, l'autre l'a skippée grâce à la revalidation TOCTOU après lock !
    let total_applied = res_a.applied.len() + res_b.applied.len();
    let total_skipped = res_a.skipped.len() + res_b.skipped.len();

    assert_eq!(
        total_applied, 1,
        "Exactly one runner must have applied the migration"
    );
    assert_eq!(
        total_skipped, 1,
        "The second runner must have skipped the migration after lock TOCTOU revalidation"
    );

    // Vérifier l'état final persistant dans SurrealDB
    let stored_mig = store
        .get_migration(&module_id, &MigrationId::new("001_create_counter").unwrap())
        .await
        .unwrap()
        .expect("Migration record must exist");

    assert_eq!(stored_mig.status, MigrationStatus::Applied);

    #[derive(serde::Deserialize)]
    struct CounterRow {
        val: i64,
    }

    // Vérifier que la table créée contient exactement 1 ligne
    let mut check_res = client.query("SELECT val FROM test_counter;").await.unwrap();
    let rows: Vec<CounterRow> = check_res.take(0).unwrap();
    assert_eq!(rows.len(), 1);
    assert_eq!(rows[0].val, 42);
}

#[tokio::test]
async fn test_surreal_recovery_interrupted_applying() {
    let (client, store) =
        setup_shared_surreal_db("test_recovery_interrupted", "test_recovery_interrupted").await;

    let module_id = ModuleId::new("lyxal-scheduler");
    let version = "1.0.0";
    let mig_id = MigrationId::new("001_init").unwrap();
    let script = "DEFINE TABLE OVERWRITE test_sched SCHEMAFULL;";

    let mut provider = MockResourceProvider::new();
    provider.add("migrations/001_init.surql", script);
    let provider_arc = Arc::new(provider);

    let mut def = MigrationDefinition::new(
        mig_id.clone(),
        module_id.clone(),
        semver::Version::parse(version).unwrap(),
        MigrationChecksum::from_surql(script),
        1,
    );
    def.resource_path = Some("migrations/001_init.surql".to_string());

    // 1. Simuler un crash pendant l'état 'Applying'
    let applying_record = MigrationRecord {
        migration_id: mig_id.clone(),
        module_id: module_id.clone(),
        module_version: version.to_string(),
        checksum: def.checksum.clone(),
        applied_at: 0,
        duration_ms: 0,
        status: MigrationStatus::Applying,
        error: None,
    };
    store.record_migration(&applying_record).await.unwrap();

    // 2. Un runner avec politique par défaut (RequireManualIntervention) doit échouer et exiger recovery
    let runner_conservative = MigrationRunner::new(store.clone(), client.clone())
        .with_node_id(NodeId::new("node-gamma"))
        .with_recovery_policy(MigrationRecoveryPolicy::RequireManualIntervention);

    let plan = MigrationPlan::from_definitions_and_store(
        &module_id,
        version,
        &[def.clone()],
        store.as_ref(),
    )
    .await
    .unwrap();

    let res_err = runner_conservative
        .execute_plan(&plan, provider_arc.as_ref())
        .await
        .unwrap_err();

    match res_err {
        RuntimeError::MigrationInterrupted { .. }
        | RuntimeError::MigrationRecoveryRequired { .. } => {
            // Comportement de protection conservatrice validé
        }
        _ => panic!(
            "Expected recovery requirement or interruption error, got {:?}",
            res_err
        ),
    }

    // 3. Un runner avec politique AllowRetryIfChecksumMatches doit pouvoir réappliquer avec succès
    let runner_retry = MigrationRunner::new(store.clone(), client.clone())
        .with_node_id(NodeId::new("node-delta"))
        .with_recovery_policy(MigrationRecoveryPolicy::AllowRetryIfChecksumMatches);

    let retry_plan = MigrationPlan::from_definitions_and_store(
        &module_id,
        version,
        &[def.clone()],
        store.as_ref(),
    )
    .await
    .unwrap();

    // S'assurer que le plan identifie bien Retry
    assert!(retry_plan.has_interrupted());

    // Si on exécute directement un plan d'application avec politique permissive
    let forced_apply_plan = MigrationPlan::new(
        module_id.clone(),
        version.to_string(),
        vec![lyxal_runtime::migration::MigrationPlanItem {
            definition: def.clone(),
            action: lyxal_runtime::migration::MigrationPlanAction::Retry,
            existing_record: Some(applying_record),
        }],
    );

    let retry_res = runner_retry
        .execute_plan(&forced_apply_plan, provider_arc.as_ref())
        .await
        .unwrap();

    assert_eq!(retry_res.applied.len(), 1);
    assert_eq!(retry_res.applied[0], mig_id);

    let final_record = store
        .get_migration(&module_id, &mig_id)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(final_record.status, MigrationStatus::Applied);
}

#[tokio::test]
async fn test_surreal_installation_lease_monotone_generation_anti_aba() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_anti_aba_inst")
        .use_db("test_anti_aba_inst")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = SurrealInstallationLeaseManager::new(client);
    let key = InstallationLockKey::new(ModuleId::new("lyxal-booking"), "1.0.0");

    let node_a = NodeId::new("node-a");
    let node_b = NodeId::new("node-b");
    let node_c = NodeId::new("node-c");

    // 1. Node A acquiert -> generation == 1
    let res_a = manager
        .acquire(&key, &node_a, Duration::from_secs(10))
        .await
        .unwrap();
    let lease_a = match res_a {
        AcquireInstallationLeaseResult::Acquired(l) => {
            assert_eq!(l.generation, 1);
            assert_eq!(l.owner, node_a);
            l
        }
        _ => panic!("Expected Acquired for node-a, got {:?}", res_a),
    };

    // 2. Node A libère -> ZÉRO DELETE : record conservé avec generation == 1
    manager.release(&lease_a).await.unwrap();

    // 3. Node B acquiert -> Transition vers generation == 2 (strictly monotone !)
    let res_b = manager
        .acquire(&key, &node_b, Duration::from_secs(10))
        .await
        .unwrap();
    let lease_b = match res_b {
        AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => {
            assert_eq!(
                l.generation, 2,
                "Generation must monotonically increase to 2"
            );
            assert_eq!(l.owner, node_b);
            l
        }
        _ => panic!("Expected RecoveredExpiredLease for node-b, got {:?}", res_b),
    };

    // 4. Node B libère -> Record conservé avec generation == 2
    manager.release(&lease_b).await.unwrap();

    // 5. Node C acquiert -> Transition vers generation == 3
    let res_c = manager
        .acquire(&key, &node_c, Duration::from_secs(10))
        .await
        .unwrap();
    let lease_c = match res_c {
        AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => {
            assert_eq!(
                l.generation, 3,
                "Generation must monotonically increase to 3"
            );
            assert_eq!(l.owner, node_c);
            l
        }
        _ => panic!("Expected RecoveredExpiredLease for node-c, got {:?}", res_c),
    };

    // 6. Zombie Node A (gen 1) tente renew -> REJETÉ
    let zombie_renew = manager.renew(&lease_a, Duration::from_secs(10)).await;
    assert!(
        zombie_renew.is_err(),
        "Zombie Node A with stale generation 1 must be rejected on renew"
    );

    // 7. Zombie Node A (gen 1) tente release -> REJETÉ
    let zombie_release = manager.release(&lease_a).await;
    assert!(
        zombie_release.is_err(),
        "Zombie Node A with stale generation 1 must be rejected on release"
    );

    // 8. Zombie Node B (gen 2) tente renew -> REJETÉ
    let zombie_renew_b = manager.renew(&lease_b, Duration::from_secs(10)).await;
    assert!(
        zombie_renew_b.is_err(),
        "Zombie Node B with stale generation 2 must be rejected on renew"
    );

    // 9. Node C (gen 3) actif libère proprement
    manager.release(&lease_c).await.unwrap();
}

#[tokio::test]
async fn test_surreal_installation_lease_exactly_one_winner() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_concurrent_inst_lease")
        .use_db("test_concurrent_inst_lease")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealInstallationLeaseManager::new(client));
    let key = InstallationLockKey::new(ModuleId::new("lyxal-auth"), "2.0.0");

    let num_tasks = 10;
    let barrier = Arc::new(Barrier::new(num_tasks));
    let done_barrier = Arc::new(Barrier::new(num_tasks));

    let mut handles = Vec::new();

    for i in 0..num_tasks {
        let mgr = manager.clone();
        let k = key.clone();
        let node = NodeId::new(format!("node-{}", i));
        let b = barrier.clone();
        let db = done_barrier.clone();

        handles.push(tokio::spawn(async move {
            b.wait().await;
            let result = mgr.acquire(&k, &node, Duration::from_secs(30)).await;
            // Ne pas libérer le lease avant que toutes les tâches aient terminé leur acquire() !
            db.wait().await;
            result
        }));
    }

    let mut acquired_count = 0;
    let mut held_count = 0;
    let mut winner_lease = None;

    for h in handles {
        let res = h.await.unwrap().unwrap();
        match res {
            AcquireInstallationLeaseResult::Acquired(l)
            | AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => {
                acquired_count += 1;
                winner_lease = Some(l);
            }
            AcquireInstallationLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            AcquireInstallationLeaseResult::AlreadyOwned(_) => {}
        }
    }

    // Exactement UN SEUL gagnant garanti sous concurrence extrême avec barrière
    assert_eq!(
        acquired_count, 1,
        "Exactly one task must acquire the installation lease"
    );
    assert_eq!(held_count, 9, "All other 9 tasks must receive HeldByOther");

    if let Some(l) = winner_lease {
        manager.release(&l).await.unwrap();
    }
}

#[tokio::test]
async fn test_surreal_installation_lease_released_takeover_contention_42_to_43() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_inst_42_rel")
        .use_db("test_inst_42_rel")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealInstallationLeaseManager::new(client.clone()));

    let key = InstallationLockKey::new(ModuleId::new("lyxal_booking"), "1.0.0".to_string());
    let key_record_id = key.canonical_string().replace([':', '.', '-'], "_");

    // Pré-initialisation d'un record sentinel libéré à generation = 42
    let setup_sql = r#"
        CREATE ONLY type::thing('system_installation_lock', $key_id) SET
            lock_key = $lock_key,
            module_id = 'lyxal_booking',
            version = '1.0.0',
            owner_node_id = 'previous-node',
            generation = 42,
            is_released = true,
            expires_at = 0,
            acquired_at = 1000,
            renewed_at = 1000,
            released_at = 1050,
            updated_at = time::now();
    "#;
    client
        .query(setup_sql)
        .bind(("key_id", key_record_id.clone()))
        .bind(("lock_key", key.canonical_string()))
        .await
        .unwrap()
        .check()
        .unwrap();

    let num_tasks = 10;
    let barrier = Arc::new(tokio::sync::Barrier::new(num_tasks));
    let done_barrier = Arc::new(tokio::sync::Barrier::new(num_tasks));
    let mut handles = Vec::new();

    for i in 0..num_tasks {
        let mgr = manager.clone();
        let k = key.clone();
        let node = NodeId::new(format!("contender-{}", i));
        let b = barrier.clone();
        let db = done_barrier.clone();

        handles.push(tokio::spawn(async move {
            b.wait().await;
            let result = mgr.acquire(&k, &node, Duration::from_secs(30)).await;
            db.wait().await;
            result
        }));
    }

    let mut winners = Vec::new();
    let mut held_count = 0;

    for h in handles {
        let res = h.await.unwrap().unwrap();
        match res {
            AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => {
                winners.push(l);
            }
            AcquireInstallationLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            other => panic!("Unexpected result: {:?}", other),
        }
    }

    assert_eq!(
        winners.len(),
        1,
        "Exactly ONE winner must take over released installation lease"
    );
    assert_eq!(
        winners[0].generation, 43,
        "Winner generation must be exactly 43"
    );
    assert_eq!(held_count, 9, "9 contenders must receive HeldByOther");

    // Vérification de l'état actif du verrou : generation == 43
    let inspect_lease = manager
        .inspect(&key)
        .await
        .unwrap()
        .expect("Lease must exist");
    assert_eq!(inspect_lease.generation, 43);
    assert_eq!(inspect_lease.owner, winners[0].owner);
}

#[tokio::test]
async fn test_surreal_installation_lease_expired_takeover_contention_42_to_43() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_inst_42_exp")
        .use_db("test_inst_42_exp")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealInstallationLeaseManager::new(client.clone()));

    let key = InstallationLockKey::new(ModuleId::new("lyxal_booking"), "1.0.0".to_string());
    let key_record_id = key.canonical_string().replace([':', '.', '-'], "_");

    // Pré-initialisation d'un record expiré à generation = 42
    let setup_sql = r#"
        CREATE ONLY type::thing('system_installation_lock', $key_id) SET
            lock_key = $lock_key,
            module_id = 'lyxal_booking',
            version = '1.0.0',
            owner_node_id = 'previous-node',
            generation = 42,
            is_released = false,
            expires_at = 1,
            acquired_at = 1,
            renewed_at = 1,
            released_at = 0,
            updated_at = time::now();
    "#;
    client
        .query(setup_sql)
        .bind(("key_id", key_record_id.clone()))
        .bind(("lock_key", key.canonical_string()))
        .await
        .unwrap()
        .check()
        .unwrap();

    let num_tasks = 10;
    let barrier = Arc::new(tokio::sync::Barrier::new(num_tasks));
    let done_barrier = Arc::new(tokio::sync::Barrier::new(num_tasks));
    let mut handles = Vec::new();

    for i in 0..num_tasks {
        let mgr = manager.clone();
        let k = key.clone();
        let node = NodeId::new(format!("contender-{}", i));
        let b = barrier.clone();
        let db = done_barrier.clone();

        handles.push(tokio::spawn(async move {
            b.wait().await;
            let result = mgr.acquire(&k, &node, Duration::from_secs(30)).await;
            db.wait().await;
            result
        }));
    }

    let mut winners = Vec::new();
    let mut held_count = 0;

    for h in handles {
        let res = h.await.unwrap().unwrap();
        match res {
            AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => {
                winners.push(l);
            }
            AcquireInstallationLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            other => panic!("Unexpected result: {:?}", other),
        }
    }

    assert_eq!(
        winners.len(),
        1,
        "Exactly ONE winner must take over expired installation lease"
    );
    assert_eq!(
        winners[0].generation, 43,
        "Winner generation must be exactly 43"
    );
    assert_eq!(held_count, 9, "9 contenders must receive HeldByOther");

    // Vérification de l'état actif du verrou : generation == 43
    let inspect_lease = manager
        .inspect(&key)
        .await
        .unwrap()
        .expect("Lease must exist");
    assert_eq!(inspect_lease.generation, 43);
    assert_eq!(inspect_lease.owner, winners[0].owner);
}
