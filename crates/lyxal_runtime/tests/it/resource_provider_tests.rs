use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{
    EmbeddedResourceProvider, ModuleResource, ResourceDiscovery, ResourceKind,
};
use lyxal_runtime::RuntimeError;

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
