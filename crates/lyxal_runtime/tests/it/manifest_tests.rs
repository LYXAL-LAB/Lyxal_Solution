use lyxal_runtime::{
    ManifestParser, ModuleDependency, ModuleDescriptor, ModuleId, ModuleManifest, RuntimeError,
    CURRENT_MANIFEST_VERSION,
};
use semver::{Version, VersionReq};
use std::path::PathBuf;

#[test]
fn test_parse_minimal_manifest() {
    let toml = r#"
        id = "timezone"
        name = "Lyxal Timezone"
        version = "0.1.0"
    "#;

    let manifest = ManifestParser::parse_str(toml).unwrap();
    assert_eq!(manifest.manifest_version, CURRENT_MANIFEST_VERSION);
    assert_eq!(manifest.id.as_str(), "timezone");
    assert_eq!(manifest.name, "Lyxal Timezone");
    assert_eq!(manifest.version, Version::parse("0.1.0").unwrap());
    assert!(manifest.dependencies.is_empty());
    assert!(manifest.capabilities.is_empty());
}

#[test]
fn test_parse_full_manifest() {
    let toml = r#"
        manifest_version = 1
        id = "calendar"
        name = "Lyxal Calendar"
        version = "1.2.0"
        description = "Calendar scheduling engine"
        capabilities = ["database", "workers"]

        [runtime]
        min_version = ">=0.1.0"

        [[dependencies]]
        id = "timezone"
        version = ">=1.0.0"

        [[dependencies]]
        id = "scheduler"
        version = "^0.5"
    "#;

    let manifest = ManifestParser::parse_str(toml).unwrap();
    assert_eq!(manifest.id.as_str(), "calendar");
    assert_eq!(manifest.name, "Lyxal Calendar");
    assert_eq!(manifest.version, Version::parse("1.2.0").unwrap());
    assert_eq!(
        manifest.description.as_deref(),
        Some("Calendar scheduling engine")
    );
    assert_eq!(manifest.dependencies.len(), 2);
    assert_eq!(manifest.capabilities, vec!["database", "workers"]);

    let dep_tz = &manifest.dependencies[0];
    assert_eq!(dep_tz.id.as_str(), "timezone");
    assert!(dep_tz.matches(&Version::parse("1.0.0").unwrap()));
    assert!(dep_tz.matches(&Version::parse("1.5.0").unwrap()));
    assert!(!dep_tz.matches(&Version::parse("0.9.0").unwrap()));
}

#[test]
fn test_reject_unsupported_manifest_version() {
    let toml = r#"
        manifest_version = 99
        id = "future_module"
        name = "Future"
        version = "1.0.0"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(
        err,
        RuntimeError::UnsupportedManifestVersion { .. }
    ));
    assert_eq!(err.code(), "RUNTIME_UNSUPPORTED_MANIFEST_VERSION");
}

#[test]
fn test_reject_invalid_semver() {
    let toml = r#"
        id = "invalid_version_mod"
        name = "Invalid Version"
        version = "not-a-semver"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(err, RuntimeError::ManifestParseError { .. }));
}

#[test]
fn test_reject_empty_id() {
    let toml = r#"
        id = "  "
        name = "Empty ID Module"
        version = "1.0.0"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(err, RuntimeError::InvalidManifest { .. }));
    assert_eq!(err.code(), "RUNTIME_INVALID_MANIFEST");
}

#[test]
fn test_reject_empty_name() {
    let toml = r#"
        id = "valid_id"
        name = ""
        version = "1.0.0"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(err, RuntimeError::InvalidManifest { .. }));
}

#[test]
fn test_reject_self_dependency() {
    let toml = r#"
        id = "self_mod"
        name = "Self Dependant"
        version = "1.0.0"

        [[dependencies]]
        id = "self_mod"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(err, RuntimeError::SelfDependency { .. }));
    assert_eq!(err.code(), "RUNTIME_SELF_DEPENDENCY");
}

#[test]
fn test_reject_duplicate_dependency() {
    let toml = r#"
        id = "booking"
        name = "Lyxal Booking"
        version = "1.0.0"

        [[dependencies]]
        id = "calendar"
        version = ">=1.0"

        [[dependencies]]
        id = "calendar"
        version = ">=2.0"
    "#;

    let err = ManifestParser::parse_str(toml).unwrap_err();
    assert!(matches!(err, RuntimeError::DuplicateDependency { .. }));
    assert_eq!(err.code(), "RUNTIME_DUPLICATE_DEPENDENCY");
}

#[test]
fn test_manifest_to_descriptor_conversion() {
    let toml = r#"
        id = "booking"
        name = "Lyxal Booking"
        version = "2.1.0"
        description = "Unified booking engine"
        capabilities = ["api", "database"]

        [[dependencies]]
        id = "calendar"

        [[dependencies]]
        id = "scheduler"
    "#;

    let desc = ManifestParser::parse_to_descriptor(toml).unwrap();
    assert_eq!(desc.id.as_str(), "booking");
    assert_eq!(desc.name, "Lyxal Booking");
    assert_eq!(desc.version, "2.1.0");
    assert_eq!(desc.description.as_deref(), Some("Unified booking engine"));
    assert_eq!(
        desc.dependencies,
        vec![ModuleId::new("calendar"), ModuleId::new("scheduler")]
    );
    assert_eq!(desc.capabilities, vec!["api", "database"]);

    // Test TryFrom
    let manifest = ManifestParser::parse_str(toml).unwrap();
    let desc_from_try: ModuleDescriptor = manifest.try_into().unwrap();
    assert_eq!(desc, desc_from_try);
}

#[test]
fn test_serde_roundtrip() {
    let manifest = ModuleManifest {
        manifest_version: 1,
        id: ModuleId::new("test-roundtrip"),
        name: "Roundtrip Test".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: Some("Description test".to_string()),
        runtime: None,
        dependencies: vec![ModuleDependency::with_version(
            "core",
            VersionReq::parse(">=1.0.0").unwrap(),
        )],
        capabilities: vec!["db".to_string()],
    };

    let serialized = toml::to_string(&manifest).unwrap();
    let deserialized: ModuleManifest = toml::from_str(&serialized).unwrap();
    assert_eq!(manifest, deserialized);
}

#[test]
fn test_parse_from_fixture_file() {
    let fixture_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("fixtures")
        .join("valid_manifest.toml");

    let manifest = ManifestParser::parse_file(&fixture_path).unwrap();
    assert_eq!(manifest.id.as_str(), "calendar");
    assert_eq!(manifest.version, Version::parse("1.2.0").unwrap());
    assert_eq!(manifest.dependencies.len(), 2);
}
