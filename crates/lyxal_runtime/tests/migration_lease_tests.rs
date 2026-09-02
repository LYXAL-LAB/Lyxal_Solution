use lyxal_runtime::lock::{
    AcquireLeaseResult, MemoryMigrationLeaseManager, MigrationLeaseManager, MigrationLockConfig,
    MigrationLockKey, NodeId, SurrealMigrationLeaseManager,
};
use lyxal_runtime::migration::MigrationId;
use lyxal_runtime::store::{RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeError;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::connect;
use tokio::sync::Barrier;
use tokio::time::sleep;

#[test]
fn test_node_id_creation_and_generation() {
    let n1 = NodeId::new("node-alpha");
    assert_eq!(n1.as_str(), "node-alpha");
    assert_eq!(format!("{}", n1), "node-alpha");

    let g1 = NodeId::generate();
    let g2 = NodeId::generate();
    assert!(g1.as_str().starts_with("node-"));
    assert_ne!(g1, g2);
}

#[test]
fn test_migration_lock_key() {
    let key = MigrationLockKey::new("lyxal-booking", MigrationId::new("001_init").unwrap());
    assert_eq!(key.canonical_string(), "lyxal-booking:001_init");
    assert_eq!(format!("{}", key), "lyxal-booking:001_init");
}

#[test]
fn test_lock_config_validation() {
    let valid = MigrationLockConfig::default();
    assert!(valid.validate().is_ok());

    let invalid = MigrationLockConfig {
        lease_duration: Duration::from_secs(10),
        renew_interval: Duration::from_secs(10), // >= lease_duration
        acquire_timeout: Duration::from_secs(5),
        acquire_retry_delay: Duration::from_millis(50),
    };
    assert!(invalid.validate().is_err());
}

#[tokio::test]
async fn test_memory_lease_manager_lifecycle() {
    let manager = MemoryMigrationLeaseManager::new();
    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-calendar"),
        MigrationId::new("001_init").unwrap(),
    );
    let node_a = NodeId::new("node-a");
    let node_b = NodeId::new("node-b");

    // 1. Node A acquiert le bail
    let res = manager
        .acquire(&key, &node_a, Duration::from_secs(2))
        .await
        .unwrap();

    let lease = match res {
        AcquireLeaseResult::Acquired(l) => {
            assert_eq!(l.owner, node_a);
            assert_eq!(l.generation, 1);
            l
        }
        _ => panic!("Expected Acquired, got {:?}", res),
    };

    // 2. Node A réacquiert (AlreadyOwned)
    let res_own = manager
        .acquire(&key, &node_a, Duration::from_secs(2))
        .await
        .unwrap();
    match res_own {
        AcquireLeaseResult::AlreadyOwned(l) => {
            assert_eq!(l.generation, 1);
        }
        _ => panic!("Expected AlreadyOwned, got {:?}", res_own),
    }

    // 3. Node B tente d'acquérir -> HeldByOther
    let res_b = manager
        .acquire(&key, &node_b, Duration::from_secs(2))
        .await
        .unwrap();
    match res_b {
        AcquireLeaseResult::HeldByOther { owner, .. } => {
            assert_eq!(owner, node_a);
        }
        _ => panic!("Expected HeldByOther, got {:?}", res_b),
    }

    // 4. Node A renouvelle le bail
    let renewed = manager.renew(&lease, Duration::from_secs(3)).await.unwrap();
    assert_eq!(renewed.generation, 1);
    assert!(renewed.expires_at >= lease.expires_at);

    // 5. Node A libère le bail
    manager.release(&renewed).await.unwrap();
    assert!(manager.inspect(&key).await.unwrap().is_none());

    // 6. Node B peut maintenant acquérir -> RecoveredExpiredLease avec generation == 2
    let res_b2 = manager
        .acquire(&key, &node_b, Duration::from_secs(2))
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
async fn test_memory_lease_expiration_and_recovery() {
    let manager = MemoryMigrationLeaseManager::new();
    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-scheduler"),
        MigrationId::new("001_cron").unwrap(),
    );
    let node_a = NodeId::new("node-a");
    let node_b = NodeId::new("node-b");

    // 1. Node A acquiert un bail de 1 seconde
    let res_a = manager
        .acquire(&key, &node_a, Duration::from_secs(1))
        .await
        .unwrap();
    let lease_a = match res_a {
        AcquireLeaseResult::Acquired(l) => l,
        _ => panic!("Expected Acquired"),
    };

    // Attendre l'expiration du bail de Node A
    sleep(Duration::from_millis(1100)).await;

    // 2. Node B acquiert -> RecoveredExpiredLease avec génération incrémentée
    let res_b = manager
        .acquire(&key, &node_b, Duration::from_secs(5))
        .await
        .unwrap();
    let lease_b = match res_b {
        AcquireLeaseResult::RecoveredExpiredLease(l) => {
            assert_eq!(l.owner, node_b);
            assert_eq!(l.generation, 2); // Fencing token incrémenté !
            l
        }
        _ => panic!("Expected RecoveredExpiredLease, got {:?}", res_b),
    };

    // 3. Zombie Node A tente de renouveler avec son ancien bail (génération 1) -> Rejet
    let renew_err = manager
        .renew(&lease_a, Duration::from_secs(5))
        .await
        .unwrap_err();
    match renew_err {
        RuntimeError::MigrationLeaseLost { key: k, owner, .. } => {
            assert_eq!(k, key.to_string());
            assert_eq!(owner, "node-a");
        }
        _ => panic!("Expected MigrationLeaseLost, got {:?}", renew_err),
    }

    // 4. Zombie Node A tente de libérer avec son ancien bail -> Rejet
    let release_err = manager.release(&lease_a).await.unwrap_err();
    match release_err {
        RuntimeError::MigrationLockNotOwner {
            caller,
            actual_owner,
            ..
        } => {
            assert_eq!(caller, "node-a");
            assert_eq!(actual_owner, "node-b");
        }
        _ => panic!("Expected MigrationLockNotOwner, got {:?}", release_err),
    }

    // 5. Node B libère proprement
    manager.release(&lease_b).await.unwrap();
}

#[tokio::test]
async fn test_concurrent_lease_contention() {
    let manager = Arc::new(MemoryMigrationLeaseManager::new());
    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-booking"),
        MigrationId::new("001_concurrency").unwrap(),
    );

    let mut handles = Vec::new();

    for i in 0..10 {
        let mgr = manager.clone();
        let k = key.clone();
        let node = NodeId::new(format!("node-{}", i));

        handles.push(tokio::spawn(async move {
            mgr.acquire(&k, &node, Duration::from_secs(10)).await
        }));
    }

    let mut acquired_count = 0;
    let mut held_count = 0;

    for h in handles {
        let res = h.await.unwrap().unwrap();
        match res {
            AcquireLeaseResult::Acquired(_) => acquired_count += 1,
            AcquireLeaseResult::HeldByOther { .. } => held_count += 1,
            _ => {}
        }
    }

    // Exactement un seul gagnant parmi les 10 requêtes concurrentes !
    assert_eq!(acquired_count, 1);
    assert_eq!(held_count, 9);
}

#[tokio::test]
async fn test_surreal_migration_lease_monotone_generation_anti_aba() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_anti_aba_mig")
        .use_db("test_anti_aba_mig")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = SurrealMigrationLeaseManager::new(client);
    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-booking"),
        MigrationId::new("001_anti_aba").unwrap(),
    );

    let node_a = NodeId::new("node-a");
    let node_b = NodeId::new("node-b");
    let node_c = NodeId::new("node-c");

    // 1. Node A acquiert -> generation == 1
    let res_a = manager
        .acquire(&key, &node_a, Duration::from_secs(10))
        .await
        .unwrap();
    let lease_a = match res_a {
        AcquireLeaseResult::Acquired(l) => {
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
        AcquireLeaseResult::RecoveredExpiredLease(l) => {
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
        AcquireLeaseResult::RecoveredExpiredLease(l) => {
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
async fn test_surreal_migration_lease_exactly_one_winner() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_concurrent_mig_lease")
        .use_db("test_concurrent_mig_lease")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealMigrationLeaseManager::new(client));
    let key = MigrationLockKey::new(
        ModuleId::new("lyxal-crm"),
        MigrationId::new("001_concurrency_barrier").unwrap(),
    );

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

    for (i, h) in handles.into_iter().enumerate() {
        let res = h.await.unwrap().unwrap();
        eprintln!("Task {} got: {:?}", i, res);
        match res {
            AcquireLeaseResult::Acquired(l) | AcquireLeaseResult::RecoveredExpiredLease(l) => {
                acquired_count += 1;
                winner_lease = Some(l);
            }
            AcquireLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            AcquireLeaseResult::AlreadyOwned(_) => {}
        }
    }

    // Exactement UN SEUL gagnant garanti sous concurrence extrême avec barrière
    assert_eq!(
        acquired_count, 1,
        "Exactly one task must acquire the migration lease"
    );
    assert_eq!(held_count, 9, "All other 9 tasks must receive HeldByOther");

    if let Some(l) = winner_lease {
        manager.release(&l).await.unwrap();
    }
}

#[tokio::test]
async fn test_surreal_migration_lease_released_takeover_contention_42_to_43() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_lease_42_rel")
        .use_db("test_lease_42_rel")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealMigrationLeaseManager::new(client.clone()));

    let key = MigrationLockKey::new(
        ModuleId::new("lyxal_booking"),
        MigrationId::new("0001_init").unwrap(),
    );
    let key_record_id = key.canonical_string().replace([':', '.', '-'], "_");

    // Pré-initialisation d'un record sentinel libéré à generation = 42
    let setup_sql = r#"
        CREATE ONLY type::thing('system_migration_lock', $key_id) SET
            lock_key = $lock_key,
            module_id = 'lyxal_booking',
            migration_id = '0001_init',
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
            AcquireLeaseResult::RecoveredExpiredLease(l) => {
                winners.push(l);
            }
            AcquireLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            other => panic!("Unexpected result: {:?}", other),
        }
    }

    assert_eq!(
        winners.len(),
        1,
        "Exactly ONE winner must take over released lease"
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
async fn test_surreal_migration_lease_expired_takeover_contention_42_to_43() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_lease_42_exp")
        .use_db("test_lease_42_exp")
        .await
        .unwrap();

    let store = SurrealRuntimeStore::new(client.clone());
    store.bootstrap().await.unwrap();

    let manager = Arc::new(SurrealMigrationLeaseManager::new(client.clone()));

    let key = MigrationLockKey::new(
        ModuleId::new("lyxal_booking"),
        MigrationId::new("0001_init").unwrap(),
    );
    let key_record_id = key.canonical_string().replace([':', '.', '-'], "_");

    // Pré-initialisation d'un record expiré à generation = 42
    let setup_sql = r#"
        CREATE ONLY type::thing('system_migration_lock', $key_id) SET
            lock_key = $lock_key,
            module_id = 'lyxal_booking',
            migration_id = '0001_init',
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
            AcquireLeaseResult::RecoveredExpiredLease(l) => {
                winners.push(l);
            }
            AcquireLeaseResult::HeldByOther { .. } => {
                held_count += 1;
            }
            other => panic!("Unexpected result: {:?}", other),
        }
    }

    assert_eq!(
        winners.len(),
        1,
        "Exactly ONE winner must take over expired lease"
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
