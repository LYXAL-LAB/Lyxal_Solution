use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{
    EmbeddedResourceProvider, FilesystemResourceProvider, ModuleResource, ResourceDiscovery,
    ResourceKind, ResourceProvider,
};
use lyxal_runtime::RuntimeError;
use std::fs;
use tempfile::tempdir;

#[tokio::test]
async fn test_filesystem_provider_read() {
    let dir = tempdir().unwrap();
    let schema_dir = dir.path().join("schema");
    fs::create_dir_all(&schema_dir).unwrap();

    let table_file = schema_dir.join("tables.surql");
    fs::write(&table_file, "DEFINE TABLE booking SCHEMAFULL;").unwrap();

    let provider = FilesystemResourceProvider::new(dir.path());

    let content = provider.read("schema/tables.surql").await.unwrap();
    assert_eq!(content, "DEFINE TABLE booking SCHEMAFULL;");
}

#[tokio::test]
async fn test_filesystem_provider_not_found() {
    let dir = tempdir().unwrap();
    let provider = FilesystemResourceProvider::new(dir.path());

    let err = provider.read("schema/missing.surql").await.unwrap_err();
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
    let err = provider.read("../secret.surql").await.unwrap_err();
    assert_eq!(err.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    let err2 = provider.read("schema/../../etc/passwd").await.unwrap_err();
    assert_eq!(err2.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    // Tentative chemin absolu Unix
    let err3 = provider.read("/etc/passwd").await.unwrap_err();
    assert_eq!(err3.code(), "RUNTIME_RESOURCE_INVALID_PATH");

    // Tentative chemin absolu Windows
    let err4 = provider.read("C:/Windows/system.ini").await.unwrap_err();
    assert_eq!(err4.code(), "RUNTIME_RESOURCE_INVALID_PATH");
}

#[tokio::test]
async fn test_filesystem_provider_max_size_enforced() {
    let dir = tempdir().unwrap();
    let file = dir.path().join("big.surql");
    fs::write(&file, vec![b'a'; 1000]).unwrap();

    let provider = FilesystemResourceProvider::new(dir.path()).with_max_size(500);

    let err = provider.read("big.surql").await.unwrap_err();
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
    let r1 = ModuleResource::new("test", ResourceKind::Schema, "");
    assert!(r1.is_empty_or_whitespace());

    let r2 = ModuleResource::new("test", ResourceKind::Schema, "   \n\t  \n");
    assert!(r2.is_empty_or_whitespace());

    let r3 = ModuleResource::new(
        "test",
        ResourceKind::Schema,
        "-- This is a comment\n// Another comment\n# Third comment",
    );
    assert!(r3.is_empty_or_whitespace());

    let r4 = ModuleResource::new(
        "test",
        ResourceKind::Schema,
        "/* Block comment */\n-- Line comment",
    );
    assert!(r4.is_empty_or_whitespace());

    let r5 = ModuleResource::new(
        "test",
        ResourceKind::Schema,
        "-- Comment\nDEFINE TABLE valid SCHEMAFULL;",
    );
    assert!(!r5.is_empty_or_whitespace());
}

/// Les ressources sont lues dans l'ordre des phases du manifeste (`schemas`, `functions`,
/// `error_definitions`, `events`, `seeds`), puis dans l'ordre déclaré dans chaque phase.
#[tokio::test]
async fn test_install_resources_follow_manifest_order() {
    static FILES: &[(&str, &str)] = &[
        ("seeds/demo.surql", "CREATE demo:1;"),
        ("schema/b.surql", "DEFINE TABLE b;"),
        ("schema/a.surql", "DEFINE TABLE a;"),
        ("functions/f.surql", "DEFINE FUNCTION fn::f() {};"),
        ("error/e.surql", "-- erreurs"),
    ];
    let manifest = ManifestParser::parse_str(
        r#"
id = "lyxal_order"
name = "Ordre"
version = "0.1.0"

[resources]
seeds = ["seeds/demo.surql"]
error_definitions = ["error/e.surql"]
functions = ["functions/f.surql"]
schemas = ["schema/b.surql", "schema/a.surql"]
"#,
    )
    .unwrap();
    let resources =
        ResourceDiscovery::install_resources(&manifest, &EmbeddedResourceProvider::new(FILES))
            .await
            .unwrap();
    let order: Vec<(&str, ResourceKind)> = resources
        .iter()
        .map(|r| (r.logical_path.as_str(), r.kind))
        .collect();
    assert_eq!(
        order,
        vec![
            ("schema/b.surql", ResourceKind::Schema),
            ("schema/a.surql", ResourceKind::Schema),
            ("functions/f.surql", ResourceKind::Function),
            ("error/e.surql", ResourceKind::ErrorDefinition),
            ("seeds/demo.surql", ResourceKind::Seed),
        ]
    );
}

/// Un fichier déclaré dans le manifeste mais absent fait échouer l'installation.
#[tokio::test]
async fn test_declared_missing_resource_fails() {
    static FILES: &[(&str, &str)] = &[];
    let manifest = ManifestParser::parse_str(
        r#"
id = "lyxal_missing"
name = "Manquant"
version = "0.1.0"

[resources]
schemas = ["schema/absent.surql"]
"#,
    )
    .unwrap();
    let err =
        ResourceDiscovery::install_resources(&manifest, &EmbeddedResourceProvider::new(FILES))
            .await
            .unwrap_err();
    assert!(
        matches!(err, RuntimeError::ResourceNotFound { .. }),
        "{err:?}"
    );
}
