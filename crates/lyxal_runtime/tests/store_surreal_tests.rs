use lyxal_runtime::{
    MigrationChecksum, MigrationId, MigrationRecord, MigrationStatus, ModuleId, RuntimeStore,
    StoredModule, StoredModuleRelease, SurrealRuntimeStore,
};
use surrealdb::engine::any::connect;

async fn create_test_store() -> SurrealRuntimeStore {
    let client = connect("mem://")
        .await
        .expect("Failed to connect to mem://");
    client
        .use_ns("lyxal_test")
        .use_db("runtime_test")
        .await
        .expect("Failed to use namespace and database");
    SurrealRuntimeStore::new(client)
}

#[tokio::test]
async fn test_surreal_store_bootstrap_idempotence() {
    let store = create_test_store().await;

    // Bootstrap initial
    assert!(store.bootstrap().await.is_ok());

    // Bootstrap répété (vérifie la stricte idempotence)
    assert!(store.bootstrap().await.is_ok());
    assert!(store.bootstrap().await.is_ok());
}

#[tokio::test]
async fn test_surreal_store_module_crud() {
    let store = create_test_store().await;
    store.bootstrap().await.unwrap();

    let module_id = ModuleId::new("lyxal-calendar");
    let module = StoredModule::new(module_id.clone(), "Lyxal Calendar")
        .with_description("Moteur de calendrier pour Lyxal OS");

    // 1. Insertion
    store.upsert_module(&module).await.unwrap();

    // 2. Récupération
    let fetched = store.get_module(&module_id).await.unwrap();
    assert!(fetched.is_some());
    let m = fetched.unwrap();
    assert_eq!(m.module_id.as_str(), "lyxal-calendar");
    assert_eq!(m.name, "Lyxal Calendar");
    assert_eq!(
        m.description.as_deref(),
        Some("Moteur de calendrier pour Lyxal OS")
    );

    // 3. Mise à jour de métadonnées
    let updated = StoredModule::new(module_id.clone(), "Lyxal Calendar V2")
        .with_description("Description mise à jour");
    store.upsert_module(&updated).await.unwrap();

    let refetched = store.get_module(&module_id).await.unwrap().unwrap();
    assert_eq!(refetched.name, "Lyxal Calendar V2");
    assert_eq!(
        refetched.description.as_deref(),
        Some("Description mise à jour")
    );

    // 4. Liste
    let all_modules = store.list_modules().await.unwrap();
    assert_eq!(all_modules.len(), 1);
    assert_eq!(all_modules[0].module_id.as_str(), "lyxal-calendar");
}

#[tokio::test]
async fn test_surreal_store_multiple_releases() {
    let store = create_test_store().await;
    store.bootstrap().await.unwrap();

    let mod_id = ModuleId::new("lyxal-booking");

    let r1 = StoredModuleRelease::new(mod_id.clone(), "1.0.0", 1, "Installed")
        .with_description("Release initiale");
    let r2 = StoredModuleRelease::new(mod_id.clone(), "1.1.0", 1, "Discovered")
        .with_description("Release mineure");

    store.register_release(&r1).await.unwrap();
    store.register_release(&r2).await.unwrap();

    // Récupération de 1.0.0
    let rel_1 = store.get_release(&mod_id, "1.0.0").await.unwrap();
    assert!(rel_1.is_some());
    let r1_unwrapped = rel_1.unwrap();
    assert_eq!(r1_unwrapped.status, "Installed");
    assert_eq!(
        r1_unwrapped.description.as_deref(),
        Some("Release initiale")
    );

    // Récupération de 1.1.0
    let rel_2 = store.get_release(&mod_id, "1.1.0").await.unwrap();
    assert!(rel_2.is_some());
    let r2_unwrapped = rel_2.unwrap();
    assert_eq!(r2_unwrapped.status, "Discovered");

    // Liste des releases
    let releases = store.list_releases(&mod_id).await.unwrap();
    assert_eq!(releases.len(), 2);
}

#[tokio::test]
async fn test_surreal_store_migration_crud() {
    let store = create_test_store().await;
    store.bootstrap().await.unwrap();

    let mod_id = ModuleId::new("lyxal-scheduler");
    let mig_id = MigrationId::new("001_initial_cron").unwrap();
    let checksum = MigrationChecksum::from_surql("DEFINE TABLE scheduler_cron SCHEMAFULL;");

    let record = MigrationRecord {
        migration_id: mig_id.clone(),
        module_id: mod_id.clone(),
        module_version: "1.0.0".to_string(),
        checksum: checksum.clone(),
        applied_at: 1700000000000,
        duration_ms: 18,
        status: MigrationStatus::Applied,
        error: None,
    };

    // 1. Enregistrement
    store.record_migration(&record).await.unwrap();

    // 2. Lecture
    let fetched = store.get_migration(&mod_id, &mig_id).await.unwrap();
    assert!(fetched.is_some());
    let m = fetched.unwrap();
    assert_eq!(m.migration_id, mig_id);
    assert_eq!(m.module_id, mod_id);
    assert_eq!(m.checksum, checksum);
    assert_eq!(m.status, MigrationStatus::Applied);
    assert_eq!(m.duration_ms, 18);

    // 3. Liste par module
    let list = store.list_migrations(&mod_id).await.unwrap();
    assert_eq!(list.len(), 1);
    assert_eq!(list[0].migration_id.as_str(), "001_initial_cron");
}
