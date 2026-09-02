use lyxal_runtime::migration::{
    MigrationChecksum, MigrationDiscovery, MigrationPlan, MigrationPlanAction, MigrationRecord,
    MigrationStatus,
};
use lyxal_runtime::resource::FilesystemResourceProvider;
use lyxal_runtime::store::MemoryRuntimeStore;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{RuntimeError, RuntimeStore};
use std::fs;
use tempfile::tempdir;

#[test]
fn test_parse_migration_filename_valid() {
    let (order, id) =
        MigrationDiscovery::parse_migration_filename("001_initial_schema.surql").unwrap();
    assert_eq!(order, 1);
    assert_eq!(id.as_str(), "001_initial_schema");

    let (order2, id2) =
        MigrationDiscovery::parse_migration_filename("042_add_calendar_events.surql").unwrap();
    assert_eq!(order2, 42);
    assert_eq!(id2.as_str(), "042_add_calendar_events");
}

#[test]
fn test_parse_migration_filename_invalid() {
    assert!(MigrationDiscovery::parse_migration_filename("migration.surql").is_err());
    assert!(MigrationDiscovery::parse_migration_filename("001.surql").is_err());
    assert!(MigrationDiscovery::parse_migration_filename("abc_test.surql").is_err());
    assert!(MigrationDiscovery::parse_migration_filename("001_initial.txt").is_err());
}

#[tokio::test]
async fn test_migration_discovery_order_and_duplicates() {
    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    fs::write(mig_dir.join("010_permissions.surql"), "DEFINE ACCESS test;").unwrap();
    fs::write(
        mig_dir.join("001_tables.surql"),
        "DEFINE TABLE test SCHEMAFULL;",
    )
    .unwrap();
    fs::write(
        mig_dir.join("002_fields.surql"),
        "DEFINE FIELD name ON TABLE test TYPE string;",
    )
    .unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-booking");

    let defs = MigrationDiscovery::discover_migrations(&module_id, "1.0.0", &provider)
        .await
        .unwrap();

    assert_eq!(defs.len(), 3);
    assert_eq!(defs[0].order, 1);
    assert_eq!(defs[0].id.as_str(), "001_tables");
    assert_eq!(defs[1].order, 2);
    assert_eq!(defs[1].id.as_str(), "002_fields");
    assert_eq!(defs[2].order, 10);
    assert_eq!(defs[2].id.as_str(), "010_permissions");
}

#[tokio::test]
async fn test_migration_discovery_rejects_duplicate_order() {
    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    fs::write(mig_dir.join("001_step_a.surql"), "DEFINE TABLE a;").unwrap();
    fs::write(mig_dir.join("001_step_b.surql"), "DEFINE TABLE b;").unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-booking");

    let err = MigrationDiscovery::discover_migrations(&module_id, "1.0.0", &provider)
        .await
        .unwrap_err();

    match err {
        RuntimeError::InvalidMigrationId { reason, .. } => {
            assert!(reason.contains("Duplicate migration order '1'"));
        }
        _ => panic!(
            "Expected InvalidMigrationId error with duplicate order reason, got {:?}",
            err
        ),
    }
}

#[tokio::test]
async fn test_migration_plan_building_scenarios() {
    let dir = tempdir().unwrap();
    let mig_dir = dir.path().join("migrations");
    fs::create_dir_all(&mig_dir).unwrap();

    let sql1 = "DEFINE TABLE m1;";
    let sql2 = "DEFINE TABLE m2;";
    let sql3 = "DEFINE TABLE m3;";

    fs::write(mig_dir.join("001_m1.surql"), sql1).unwrap();
    fs::write(mig_dir.join("002_m2.surql"), sql2).unwrap();
    fs::write(mig_dir.join("003_m3.surql"), sql3).unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let module_id = ModuleId::new("lyxal-scheduler");

    let defs = MigrationDiscovery::discover_migrations(&module_id, "1.0.0", &provider)
        .await
        .unwrap();

    let store = MemoryRuntimeStore::new();

    // 1. Initial plan: all 3 should be Apply
    let plan = MigrationPlan::from_definitions_and_store(&module_id, "1.0.0", &defs, &store)
        .await
        .unwrap();

    assert_eq!(plan.executable_count(), 3);
    assert_eq!(plan.skipped_count(), 0);
    assert!(!plan.has_drift());

    // 2. Simulate 001 Applied in store
    let rec1 = MigrationRecord {
        migration_id: defs[0].id.clone(),
        module_id: module_id.clone(),
        module_version: "1.0.0".to_string(),
        checksum: defs[0].checksum.clone(),
        applied_at: 1000,
        duration_ms: 10,
        status: MigrationStatus::Applied,
        error: None,
    };
    store.record_migration(&rec1).await.unwrap();

    let plan2 = MigrationPlan::from_definitions_and_store(&module_id, "1.0.0", &defs, &store)
        .await
        .unwrap();

    assert_eq!(plan2.items[0].action, MigrationPlanAction::Skip);
    assert_eq!(plan2.items[1].action, MigrationPlanAction::Apply);
    assert_eq!(plan2.items[2].action, MigrationPlanAction::Apply);
    assert_eq!(plan2.executable_count(), 2);
    assert_eq!(plan2.skipped_count(), 1);

    // 3. Simulate checksum drift on 001 (modified content)
    let bad_rec1 = MigrationRecord {
        migration_id: defs[0].id.clone(),
        module_id: module_id.clone(),
        module_version: "1.0.0".to_string(),
        checksum: MigrationChecksum::from_surql("MODIFIED CHECKSUM CONTENT"),
        applied_at: 1000,
        duration_ms: 10,
        status: MigrationStatus::Applied,
        error: None,
    };
    store.record_migration(&bad_rec1).await.unwrap();

    let plan3 = MigrationPlan::from_definitions_and_store(&module_id, "1.0.0", &defs, &store)
        .await
        .unwrap();

    assert!(plan3.has_drift());
    match &plan3.items[0].action {
        MigrationPlanAction::FailDrift { .. } => {}
        _ => panic!("Expected FailDrift action on item 0"),
    }
}
