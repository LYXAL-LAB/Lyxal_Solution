use lyxal_runtime::{
    validate_migration_definitions, MigrationChecksum, MigrationDefinition, MigrationId,
    MigrationRecord, MigrationStatus, ModuleId, RuntimeError,
};
use semver::Version;

#[test]
fn test_migration_id_valid() {
    let id1 = MigrationId::new("001_initial_schema").unwrap();
    assert_eq!(id1.as_str(), "001_initial_schema");
    assert_eq!(id1.sequence_number(), Some(1));

    let id2 = MigrationId::new("0002_add_index").unwrap();
    assert_eq!(id2.sequence_number(), Some(2));

    let id3 = MigrationId::new("100_custom_migration").unwrap();
    assert_eq!(id3.sequence_number(), Some(100));

    let id_non_numeric = MigrationId::new("init_setup").unwrap();
    assert_eq!(id_non_numeric.sequence_number(), None);
}

#[test]
fn test_migration_id_invalid() {
    // ID vide
    let err_empty = MigrationId::new("   ").unwrap_err();
    assert!(matches!(err_empty, RuntimeError::InvalidMigrationId { .. }));
    assert_eq!(err_empty.code(), "RUNTIME_INVALID_MIGRATION_ID");

    // ID avec caractères interdits (espaces, ponctuation spéciale)
    let err_invalid = MigrationId::new("001 migration with spaces").unwrap_err();
    assert!(matches!(
        err_invalid,
        RuntimeError::InvalidMigrationId { .. }
    ));
}

#[test]
fn test_migration_id_deterministic_ordering() {
    let mut ids = vec![
        MigrationId::new("010_later_migration").unwrap(),
        MigrationId::new("003_third_step").unwrap(),
        MigrationId::new("001_initial").unwrap(),
        MigrationId::new("002_second_step").unwrap(),
    ];

    ids.sort();

    let expected = vec![
        MigrationId::new("001_initial").unwrap(),
        MigrationId::new("002_second_step").unwrap(),
        MigrationId::new("003_third_step").unwrap(),
        MigrationId::new("010_later_migration").unwrap(),
    ];

    assert_eq!(ids, expected);
}

#[test]
fn test_migration_checksum_calculation_and_verification() {
    let surql = "DEFINE TABLE booking SCHEMAFULL;";
    let checksum = MigrationChecksum::from_surql(surql);

    // Un checksum SHA-256 fait toujours 64 caractères hexadécimaux
    assert_eq!(checksum.as_str().len(), 64);
    assert!(checksum.verify(surql.as_bytes()));
    assert!(!checksum.verify(b"DEFINE TABLE modified;"));

    // Vérification de la création depuis un hex existant
    let hex_val = checksum.as_str().to_string();
    let from_hex = MigrationChecksum::from_hex(&hex_val).unwrap();
    assert_eq!(checksum, from_hex);

    // Hex invalide (longueur < 64 ou caractères non-hex)
    let invalid_hex = MigrationChecksum::from_hex("invalid-hex-string").unwrap_err();
    assert!(matches!(invalid_hex, RuntimeError::InvalidChecksum { .. }));
    assert_eq!(invalid_hex.code(), "RUNTIME_INVALID_CHECKSUM");
}

#[test]
fn test_migration_definition_ownership_and_builder() {
    let id = MigrationId::new("001_init").unwrap();
    let checksum = MigrationChecksum::from_surql("DEFINE TABLE user;");
    let version = Version::parse("1.0.0").unwrap();

    let migration = MigrationDefinition::new(
        id.clone(),
        ModuleId::new("lyxal-auth"),
        version.clone(),
        checksum.clone(),
        1,
    )
    .with_reversible(true)
    .with_resource_path("migrations/001_init.surql")
    .with_description("Initial auth schema tables");

    assert_eq!(migration.id, id);
    assert_eq!(migration.module_id.as_str(), "lyxal-auth");
    assert_eq!(migration.module_version, version);
    assert_eq!(migration.checksum, checksum);
    assert_eq!(migration.order, 1);
    assert!(migration.reversible);
    assert_eq!(
        migration.resource_path.as_deref(),
        Some("migrations/001_init.surql")
    );
    assert_eq!(
        migration.description.as_deref(),
        Some("Initial auth schema tables")
    );
}

#[test]
fn test_migration_definition_canonical_ordering_by_order() {
    let checksum = MigrationChecksum::from_surql("DEFINE TABLE test;");
    let version = Version::parse("1.0.0").unwrap();

    let m1 = MigrationDefinition::new(
        MigrationId::new("001_init").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        1,
    );

    let m2 = MigrationDefinition::new(
        MigrationId::new("002_add_index").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        2,
    );

    let m10 = MigrationDefinition::new(
        MigrationId::new("010_later").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        10,
    );

    let mut list = vec![m10.clone(), m1.clone(), m2.clone()];
    list.sort();

    assert_eq!(list, vec![m1, m2, m10]);
}

#[test]
fn test_validate_migration_definitions_prevent_duplicates() {
    let checksum = MigrationChecksum::from_surql("DEFINE TABLE test;");
    let version = Version::parse("1.0.0").unwrap();

    // Duplicate order
    let m1 = MigrationDefinition::new(
        MigrationId::new("001_init").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        1,
    );
    let m2_duplicate_order = MigrationDefinition::new(
        MigrationId::new("002_indexes").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        1,
    );

    let err_order = validate_migration_definitions(&[m1.clone(), m2_duplicate_order]).unwrap_err();
    assert!(matches!(err_order, RuntimeError::InvalidMigrationId { .. }));

    // Duplicate ID
    let m2_duplicate_id = MigrationDefinition::new(
        MigrationId::new("001_init").unwrap(),
        ModuleId::new("lyxal-calendar"),
        version.clone(),
        checksum.clone(),
        2,
    );

    let err_id = validate_migration_definitions(&[m1, m2_duplicate_id]).unwrap_err();
    assert!(matches!(err_id, RuntimeError::InvalidMigrationId { .. }));
}

#[test]
fn test_migration_status_predicates() {
    let pending = MigrationStatus::Pending;
    assert!(pending.is_pending());
    assert!(!pending.is_applied());
    assert!(!pending.is_failed());

    let applied = MigrationStatus::Applied;
    assert!(applied.is_applied());
    assert!(!applied.is_pending());

    let failed = MigrationStatus::Failed;
    assert!(failed.is_failed());
    assert!(!failed.is_applied());
}

#[test]
fn test_migration_record_model() {
    let record = MigrationRecord {
        migration_id: MigrationId::new("001_init").unwrap(),
        module_id: ModuleId::new("lyxal-calendar"),
        module_version: "1.0.0".to_string(),
        checksum: MigrationChecksum::from_bytes(b"test"),
        applied_at: 1700000000000,
        duration_ms: 45,
        status: MigrationStatus::Applied,
        error: None,
    };

    assert_eq!(record.migration_id.as_str(), "001_init");
    assert_eq!(record.module_id.as_str(), "lyxal-calendar");
    assert_eq!(record.status, MigrationStatus::Applied);
    assert_eq!(record.duration_ms, 45);
}
