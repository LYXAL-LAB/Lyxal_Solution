use crate::common::DirResourceProvider;
use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{ResourceDiscovery, ResourceKind};
use std::path::PathBuf;

#[test]
fn test_manifest_parser_supports_catalogue_manifest() {
    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("lyxal_catalogue")
        .join("manifest.toml");

    let manifest = ManifestParser::parse_file(&manifest_path)
        .expect("Failed to parse catalogue manifest.toml");

    assert_eq!(manifest.id.as_str(), "lyxal_catalogue");
    assert_eq!(manifest.name, "Lyxal Catalogue");
    assert_eq!(manifest.version.to_string(), "0.1.0");
    assert_eq!(manifest.capabilities, vec!["database"]);
    assert_eq!(manifest.dependencies.len(), 3);
    assert_eq!(manifest.dependencies[0].id.as_str(), "lyxal_core");
    assert_eq!(manifest.dependencies[1].id.as_str(), "lyxal_error");
    assert_eq!(manifest.dependencies[2].id.as_str(), "lyxal_base");
    assert!(manifest.runtime.is_some());
    assert_eq!(
        manifest
            .runtime
            .as_ref()
            .unwrap()
            .min_version
            .as_ref()
            .unwrap()
            .to_string(),
        ">=0.1.0"
    );
}

/// Les ressources du catalogue sont exactement celles de son manifeste : tous les fichiers
/// déclarés existent et sont lus dans l'ordre des phases puis de déclaration.
#[tokio::test]
async fn test_catalogue_resources_follow_manifest() {
    let catalogue_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("lyxal_catalogue");
    let manifest = ManifestParser::parse_file(catalogue_dir.join("manifest.toml")).unwrap();
    let provider = DirResourceProvider::new(&catalogue_dir);

    let resources = ResourceDiscovery::install_resources(&manifest, &provider)
        .await
        .expect("fichiers déclarés présents");

    let declared = &manifest.resources;
    let expected: Vec<(String, ResourceKind)> = declared
        .schemas
        .iter()
        .map(|p| (p.clone(), ResourceKind::Schema))
        .chain(
            declared
                .functions
                .iter()
                .map(|p| (p.clone(), ResourceKind::Function)),
        )
        .chain(
            declared
                .error_definitions
                .iter()
                .map(|p| (p.clone(), ResourceKind::ErrorDefinition)),
        )
        .chain(
            declared
                .seeds
                .iter()
                .map(|p| (p.clone(), ResourceKind::Seed)),
        )
        .collect();
    let actual: Vec<(String, ResourceKind)> = resources
        .iter()
        .map(|r| (r.logical_path.clone(), r.kind))
        .collect();
    assert_eq!(actual, expected);
    assert_eq!(resources.len(), 14 + 26 + 8 + 2);
}
