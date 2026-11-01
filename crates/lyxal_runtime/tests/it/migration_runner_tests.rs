use lyxal_runtime::migration::{
    MigrationChecksum, MigrationId, MigrationRecord, MigrationRunner, MigrationStatus,
};
use lyxal_runtime::resource::FilesystemResourceProvider;
use lyxal_runtime::store::{MemoryRuntimeStore, RuntimeStore, SurrealRuntimeStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeError;
use lyxal_surreal::LyxalSurrealCall;
use std::fs;
use std::sync::Arc;
use surrealdb::engine::any::connect;
use tempfile::tempdir;

#[tokio::test]
async fn test_migration_runner_happy_path_and_idempotence() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let surreal_store = SurrealRuntimeStore::new(client.clone());
    surreal_store.bootstrap().await.unwrap();
    let store: Arc<dyn RuntimeStore> = Arc::new(surreal_store);

    let runner = MigrationRunner::new(store.clone(), client.clone());
    assert!(runner.surreal_client().health().await.is_ok());

    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    fs::write(
        mig_dir.join("001_create_booking.surql"),
        "DEFINE TABLE booking_run SCHEMAFULL;",
    )
    .unwrap();
    fs::write(
        mig_dir.join("002_add_field.surql"),
        "DEFINE FIELD customer_name ON TABLE booking_run TYPE string;",
    )
    .unwrap();
    fs::write(
        mig_dir.join("003_add_index.surql"),
        "DEFINE INDEX idx_customer ON TABLE booking_run COLUMNS customer_name;",
    )
    .unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-booking");

    // 1. Premier run : les 3 migrations doivent être appliquées
    let res1 = runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap();

    assert_eq!(res1.applied.len(), 3);
    assert_eq!(res1.skipped.len(), 0);
    assert_eq!(res1.applied[0].as_str(), "001_create_booking");
    assert_eq!(res1.applied[1].as_str(), "002_add_field");
    assert_eq!(res1.applied[2].as_str(), "003_add_index");

    // Vérifier la persistance dans SurrealDB system_migration
    let m1 = store
        .get_migration(&module_id, &MigrationId::new("001_create_booking").unwrap())
        .await
        .unwrap()
        .expect("Migration 001 must exist in store");
    assert_eq!(m1.status, MigrationStatus::Applied);
    assert!(m1.applied_at > 0);
    assert!(m1.error.is_none());

    // 2. Second run : 0 exécutée, 3 skipped
    let res2 = runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap();

    assert_eq!(res2.applied.len(), 0);
    assert_eq!(res2.skipped.len(), 3);
}

#[tokio::test]
async fn test_migration_runner_checksum_drift_fails_hard() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let surreal_store = SurrealRuntimeStore::new(client.clone());
    surreal_store.bootstrap().await.unwrap();
    let store: Arc<dyn RuntimeStore> = Arc::new(surreal_store);

    let runner = MigrationRunner::new(store.clone(), client.clone());

    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    let file1 = mig_dir.join("001_initial.surql");
    fs::write(&file1, "DEFINE TABLE drift_test;").unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-calendar");

    // Première exécution normale
    runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap();

    // Modification illégale du fichier 001 déjà appliqué
    fs::write(&file1, "DEFINE TABLE drift_test_MODIFIED;").unwrap();

    let err = runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap_err();

    match err {
        RuntimeError::MigrationChecksumMismatch {
            module,
            migration,
            expected,
            actual,
        } => {
            assert_eq!(module.as_str(), "lyxal-calendar");
            assert_eq!(migration, "001_initial");
            assert_ne!(expected, actual);
        }
        _ => panic!("Expected MigrationChecksumMismatch, got {:?}", err),
    }
}

#[tokio::test]
async fn test_migration_runner_failure_blocks_subsequent_migrations() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store: Arc<dyn RuntimeStore> = Arc::new(MemoryRuntimeStore::new());
    let runner = MigrationRunner::new(store.clone(), client.clone());

    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    fs::write(
        mig_dir.join("001_valid.surql"),
        "DEFINE TABLE step1 SCHEMAFULL;",
    )
    .unwrap();
    fs::write(
        mig_dir.join("002_invalid.surql"),
        "INVALID SURREALQL SYNTAX ERROR;",
    )
    .unwrap();
    fs::write(
        mig_dir.join("003_valid.surql"),
        "DEFINE TABLE step3 SCHEMAFULL;",
    )
    .unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-timezone");

    let err = runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap_err();

    match err {
        RuntimeError::MigrationExecutionFailed {
            module,
            migration,
            message,
        } => {
            assert_eq!(module.as_str(), "lyxal-timezone");
            assert_eq!(migration, "002_invalid");
            assert!(!message.is_empty());
        }
        _ => panic!("Expected MigrationExecutionFailed, got {:?}", err),
    }

    // Vérifier l'état dans le store : 001 Applied, 002 Failed, 003 absent
    let m1 = store
        .get_migration(&module_id, &MigrationId::new("001_valid").unwrap())
        .await
        .unwrap()
        .unwrap();
    assert_eq!(m1.status, MigrationStatus::Applied);

    let m2 = store
        .get_migration(&module_id, &MigrationId::new("002_invalid").unwrap())
        .await
        .unwrap()
        .unwrap();
    assert_eq!(m2.status, MigrationStatus::Failed);
    assert!(m2.error.is_some());

    let m3 = store
        .get_migration(&module_id, &MigrationId::new("003_valid").unwrap())
        .await
        .unwrap();
    assert!(m3.is_none());
}

#[tokio::test]
async fn test_migration_runner_interrupted_applying_fails_hard() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store: Arc<dyn RuntimeStore> = Arc::new(MemoryRuntimeStore::new());
    let runner = MigrationRunner::new(store.clone(), client.clone());

    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    let sql = "DEFINE TABLE inter_test;";
    fs::write(mig_dir.join("001_interrupted.surql"), sql).unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-scheduler");

    // Simuler une migration laissée dans l'état 'Applying' suite à un crash
    let record = MigrationRecord {
        migration_id: MigrationId::new("001_interrupted").unwrap(),
        module_id: module_id.clone(),
        module_version: "1.0.0".to_string(),
        checksum: MigrationChecksum::from_surql(sql),
        applied_at: 0,
        duration_ms: 0,
        status: MigrationStatus::Applying,
        error: None,
    };
    store.record_migration(&record).await.unwrap();

    let err = runner
        .run_module(&module_id, "1.0.0", &provider)
        .await
        .unwrap_err();

    match err {
        RuntimeError::MigrationInterrupted { module, migration } => {
            assert_eq!(module.as_str(), "lyxal-scheduler");
            assert_eq!(migration, "001_interrupted");
        }
        _ => panic!("Expected MigrationInterrupted, got {:?}", err),
    }
}
