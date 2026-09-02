use lyxal_runtime::{
    MemoryRuntimeStore, MigrationChecksum, MigrationId, MigrationRecord, MigrationStatus, ModuleId,
    RuntimeStore, StoredModule, StoredModuleRelease,
};

#[tokio::test]
async fn test_memory_store_bootstrap_idempotent() {
    let store = MemoryRuntimeStore::new();
    assert!(store.bootstrap().await.is_ok());
    assert!(store.bootstrap().await.is_ok());
    assert!(store.bootstrap().await.is_ok());
}

#[tokio::test]
async fn test_memory_store_upsert_and_get_module() {
    let store = MemoryRuntimeStore::new();
    store.bootstrap().await.unwrap();

    let module_id = ModuleId::new("lyxal-calendar");
    let module = StoredModule::new(module_id.clone(), "Lyxal Calendar")
        .with_description("Calendar module for Lyxal OS");

    store.upsert_module(&module).await.unwrap();

    let fetched = store.get_module(&module_id).await.unwrap();
    assert!(fetched.is_some());
    let m = fetched.unwrap();
    assert_eq!(m.module_id.as_str(), "lyxal-calendar");
    assert_eq!(m.name, "Lyxal Calendar");
    assert_eq!(
        m.description.as_deref(),
        Some("Calendar module for Lyxal OS")
    );

    // Update metadata
    let updated_module = StoredModule::new(module_id.clone(), "Lyxal Calendar Unified")
        .with_description("Updated description");
    store.upsert_module(&updated_module).await.unwrap();

    let refetched = store.get_module(&module_id).await.unwrap().unwrap();
    assert_eq!(refetched.name, "Lyxal Calendar Unified");
}

#[tokio::test]
async fn test_memory_store_multiple_releases() {
    let store = MemoryRuntimeStore::new();
    store.bootstrap().await.unwrap();

    let mod_id = ModuleId::new("lyxal-booking");

    let r1 = StoredModuleRelease::new(mod_id.clone(), "1.0.0", 1, "Installed");
    let r2 = StoredModuleRelease::new(mod_id.clone(), "1.1.0", 1, "Discovered");

    store.register_release(&r1).await.unwrap();
    store.register_release(&r2).await.unwrap();

    let rel_1 = store.get_release(&mod_id, "1.0.0").await.unwrap();
    assert!(rel_1.is_some());
    assert_eq!(rel_1.unwrap().status, "Installed");

    let rel_2 = store.get_release(&mod_id, "1.1.0").await.unwrap();
    assert!(rel_2.is_some());
    assert_eq!(rel_2.unwrap().status, "Discovered");

    let all_releases = store.list_releases(&mod_id).await.unwrap();
    assert_eq!(all_releases.len(), 2);
}

#[tokio::test]
async fn test_memory_store_migration_records() {
    let store = MemoryRuntimeStore::new();
    store.bootstrap().await.unwrap();

    let mod_id = ModuleId::new("lyxal-scheduler");
    let mig_id = MigrationId::new("001_initial_cron").unwrap();
    let checksum = MigrationChecksum::from_surql("DEFINE TABLE scheduler_cron;");

    let record = MigrationRecord {
        migration_id: mig_id.clone(),
        module_id: mod_id.clone(),
        module_version: "1.0.0".to_string(),
        checksum: checksum.clone(),
        applied_at: 1700000000000,
        duration_ms: 12,
        status: MigrationStatus::Applied,
        error: None,
    };

    store.record_migration(&record).await.unwrap();

    let fetched = store.get_migration(&mod_id, &mig_id).await.unwrap();
    assert!(fetched.is_some());
    let m = fetched.unwrap();
    assert_eq!(m.migration_id, mig_id);
    assert_eq!(m.checksum, checksum);
    assert_eq!(m.status, MigrationStatus::Applied);

    let list = store.list_migrations(&mod_id).await.unwrap();
    assert_eq!(list.len(), 1);
}
