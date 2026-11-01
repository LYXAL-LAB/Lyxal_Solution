use lyxal_runtime::resource::{FilesystemResourceProvider, ModuleResource, ResourceKind};
use lyxal_runtime::schema::{SchemaImportPlan, SchemaImporter};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeError;
use lyxal_surreal::LyxalSurrealCall;
use std::fs;
use surrealdb::engine::any::connect;
use tempfile::tempdir;

#[tokio::test]
async fn test_schema_import_plan_ordering() {
    let module_id = ModuleId::new("lyxal-booking");

    let r_seeds = ModuleResource::new("schema/seeds.surql", ResourceKind::Seeds, "CREATE x;");
    let r_tables = ModuleResource::new(
        "schema/tables.surql",
        ResourceKind::Tables,
        "DEFINE TABLE t;",
    );
    let r_indexes = ModuleResource::new(
        "schema/indexes.surql",
        ResourceKind::Indexes,
        "DEFINE INDEX idx;",
    );
    let r_fields = ModuleResource::new(
        "schema/fields.surql",
        ResourceKind::Fields,
        "DEFINE FIELD f;",
    );

    let plan = SchemaImportPlan::new(
        module_id.clone(),
        vec![
            r_seeds.clone(),
            r_tables.clone(),
            r_indexes.clone(),
            r_fields.clone(),
        ],
    );

    let ordered_kinds: Vec<ResourceKind> =
        plan.resources().iter().map(|r| r.kind.clone()).collect();
    assert_eq!(
        ordered_kinds,
        vec![
            ResourceKind::Tables,
            ResourceKind::Fields,
            ResourceKind::Indexes,
            ResourceKind::Seeds,
        ]
    );
}

#[tokio::test]
async fn test_schema_importer_execution_on_surreal_mem() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let importer = SchemaImporter::new(client.clone());
    assert!(importer.surreal_client().health().await.is_ok());

    let dir = tempdir().unwrap();
    let schema_dir = dir.path().join("schema");
    fs::create_dir_all(&schema_dir).unwrap();

    fs::write(
        schema_dir.join("tables.surql"),
        "DEFINE TABLE booking_test SCHEMAFULL;",
    )
    .unwrap();
    fs::write(
        schema_dir.join("fields.surql"),
        "DEFINE FIELD title ON TABLE booking_test TYPE string;",
    )
    .unwrap();
    fs::write(
        schema_dir.join("indexes.surql"),
        "DEFINE INDEX idx_title ON TABLE booking_test COLUMNS title;",
    )
    .unwrap();
    fs::write(schema_dir.join("seeds.surql"), "-- Comment only seed\n").unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let plan = SchemaImportPlan::from_provider(ModuleId::new("lyxal-booking"), &provider)
        .await
        .unwrap();

    assert_eq!(plan.len(), 4);

    let result = importer.execute_plan(&plan).await.unwrap();
    assert_eq!(result.module_id.as_str(), "lyxal-booking");
    assert_eq!(result.imported_resources.len(), 3);
    assert_eq!(result.skipped_empty_resources, vec!["schema/seeds.surql"]);

    // Vérifier l'insertion réelle dans SurrealDB
    let check_res = client.query("INFO FOR TABLE booking_test;").await.unwrap();
    assert!(check_res.check().is_ok());
}

#[tokio::test]
async fn test_schema_importer_invalid_sql_fails_hard() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let importer = SchemaImporter::new(client);

    let bad_resource = ModuleResource::new(
        "schema/tables.surql",
        ResourceKind::Tables,
        "INVALID SYNTAX SQL NOT SURREALQL;",
    );
    let plan = SchemaImportPlan::new(ModuleId::new("lyxal-invalid"), vec![bad_resource]);

    let err = importer.execute_plan(&plan).await.unwrap_err();
    match err {
        RuntimeError::SchemaImportFailed {
            module,
            resource,
            message,
        } => {
            assert_eq!(module.as_str(), "lyxal-invalid");
            assert_eq!(resource, "schema/tables.surql");
            assert!(!message.is_empty());
        }
        _ => panic!("Expected SchemaImportFailed, got {:?}", err),
    }
}
