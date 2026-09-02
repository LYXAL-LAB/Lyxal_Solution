use lyxal_runtime::resource::{
    FilesystemResourceProvider, ModuleResource, ResourceDiscovery, ResourceKind, ResourceProvider,
};
use lyxal_runtime::RuntimeError;
use std::fs;
use tempfile::tempdir;

#[tokio::test]
async fn test_filesystem_provider_read_and_exists() {
    let dir = tempdir().unwrap();
    let schema_dir = dir.path().join("schema");
    fs::create_dir_all(&schema_dir).unwrap();

    let table_file = schema_dir.join("tables.surql");
    fs::write(&table_file, "DEFINE TABLE booking SCHEMAFULL;").unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());

    assert!(provider.exists("schema/tables.surql").await);
    assert!(!provider.exists("schema/non_existent.surql").await);

    let res = provider.read_resource("schema/tables.surql").await.unwrap();
    assert_eq!(res.logical_path, "schema/tables.surql");
    assert_eq!(res.kind, ResourceKind::Tables);
    assert_eq!(res.content, "DEFINE TABLE booking SCHEMAFULL;");
    assert!(!res.is_empty_or_whitespace());
}

#[tokio::test]
async fn test_filesystem_provider_not_found() {
    let dir = tempdir().unwrap();
    let provider = FilesystemResourceProvider::new(dir.path());

    let err = provider
        .read_resource("schema/missing.surql")
        .await
        .unwrap_err();
    match err {
        RuntimeError::ResourceNotFound { path } => {
            assert_eq!(path, "schema/missing.surql");
        }
        _ => panic!("Expected ResourceNotFound, got {:?}", err),
    }
}

#[tokio::test]
async fn test_filesystem_provider_security_path_traversal() {
    let dir = tempdir().unwrap();
    let provider = FilesystemResourceProvider::new(dir.path());

    // Tentative traversal avec '..'
    let err = provider.read_resource("../secret.surql").await.unwrap_err();
    assert_eq!(err.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    let err2 = provider
        .read_resource("schema/../../etc/passwd")
        .await
        .unwrap_err();
    assert_eq!(err2.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    // Tentative chemin absolu Unix
    let err3 = provider.read_resource("/etc/passwd").await.unwrap_err();
    assert_eq!(err3.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    // Tentative chemin absolu Windows
    let err4 = provider
        .read_resource("C:/Windows/system.ini")
        .await
        .unwrap_err();
    assert_eq!(err4.code(), "RUNTIME_RESOURCE_INVALID_PATH");
}

#[tokio::test]
async fn test_filesystem_provider_max_size_enforced() {
    let dir = tempdir().unwrap();
    let file = dir.path().join("big.surql");
    fs::write(&file, vec![b'a'; 1000]).unwrap();

    let provider = FilesystemResourceProvider::new(dir.path()).with_max_size(500);

    let err = provider.read_resource("big.surql").await.unwrap_err();
    match err {
        RuntimeError::ResourceTooLarge { size, max_size, .. } => {
            assert_eq!(size, 1000);
            assert_eq!(max_size, 500);
        }
        _ => panic!("Expected ResourceTooLarge, got {:?}", err),
    }
}

#[test]
fn test_resource_is_empty_or_whitespace() {
    let r1 = ModuleResource::new("test", ResourceKind::Tables, "");
    assert!(r1.is_empty_or_whitespace());

    let r2 = ModuleResource::new("test", ResourceKind::Tables, "   \n\t  \n");
    assert!(r2.is_empty_or_whitespace());

    let r3 = ModuleResource::new(
        "test",
        ResourceKind::Tables,
        "-- This is a comment\n// Another comment\n# Third comment",
    );
    assert!(r3.is_empty_or_whitespace());

    let r4 = ModuleResource::new(
        "test",
        ResourceKind::Tables,
        "/* Block comment */\n-- Line comment",
    );
    assert!(r4.is_empty_or_whitespace());

    let r5 = ModuleResource::new(
        "test",
        ResourceKind::Tables,
        "-- Comment\nDEFINE TABLE valid SCHEMAFULL;",
    );
    assert!(!r5.is_empty_or_whitespace());
}

#[tokio::test]
async fn test_resource_discovery_schema_order() {
    let dir = tempdir().unwrap();
    let schema = dir.path().join("schema");
    fs::create_dir_all(&schema).unwrap();

    // Création volontairement désordonnée
    fs::write(schema.join("seeds.surql"), "CREATE demo:1;").unwrap();
    fs::write(schema.join("tables.surql"), "DEFINE TABLE test;").unwrap();
    fs::write(
        schema.join("functions.surql"),
        "DEFINE FUNCTION fn::test() {};",
    )
    .unwrap();
    fs::write(
        schema.join("indexes.surql"),
        "DEFINE INDEX idx ON TABLE test COLUMNS id;",
    )
    .unwrap();
    fs::write(
        schema.join("fields.surql"),
        "DEFINE FIELD id ON TABLE test TYPE int;",
    )
    .unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());
    let discovered = ResourceDiscovery::discover_schema_resources(&provider)
        .await
        .unwrap();

    let kinds: Vec<ResourceKind> = discovered.into_iter().map(|r| r.kind).collect();
    assert_eq!(
        kinds,
        vec![
            ResourceKind::Tables,
            ResourceKind::Fields,
            ResourceKind::Indexes,
            ResourceKind::Functions,
            ResourceKind::Seeds,
        ]
    );
}
