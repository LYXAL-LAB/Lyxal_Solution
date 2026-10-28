use std::path::{Path, PathBuf};

#[test]
fn test_manifest_validity_and_completeness() {
    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manifest.toml");
    assert!(manifest_path.exists(), "manifest.toml must exist");

    let content = std::fs::read_to_string(&manifest_path).expect("Read manifest.toml");
    let parsed: toml::Value = toml::from_str(&content).expect("Parse manifest.toml");

    let table = parsed.as_table().expect("manifest root must be a table");
    assert_eq!(table.get("id").and_then(|v| v.as_str()), Some("lyxal_error"));
    assert_eq!(table.get("version").and_then(|v| v.as_str()), Some("0.1.0"));

    let resources = table.get("resources").and_then(|v| v.as_table())
        .expect("resources section must exist");

    let check_file_list = |key: &str| {
        let list = resources.get(key).and_then(|v| v.as_array())
            .unwrap_or_else(|| panic!("Key {} must be an array in resources", key));
        for item in list {
            let rel_path = item.as_str().expect("resource path must be string");
            let full_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(rel_path);
            assert!(
                full_path.exists(),
                "Resource '{}' declared in manifest.toml does not exist at {:?}",
                rel_path,
                full_path
            );
            let metadata = std::fs::metadata(&full_path).unwrap();
            assert!(
                metadata.len() > 0,
                "Resource '{}' declared in manifest.toml is empty",
                rel_path
            );
        }
    };

    check_file_list("schemas");
    check_file_list("migrations");
    check_file_list("functions");
    check_file_list("seeds");
    check_file_list("error_definitions");
}

#[test]
fn test_no_orphan_surql_files() {
    let manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("manifest.toml");
    let content = std::fs::read_to_string(&manifest_path).expect("Read manifest.toml");
    let parsed: toml::Value = toml::from_str(&content).expect("Parse manifest.toml");
    let resources = parsed.get("resources").and_then(|v| v.as_table()).unwrap();

    let mut declared_files = std::collections::HashSet::new();
    for (_k, v) in resources {
        if let Some(arr) = v.as_array() {
            for item in arr {
                if let Some(s) = item.as_str() {
                    let norm = s.replace('\\', "/");
                    declared_files.insert(norm);
                }
            }
        }
    }

    fn collect_surql_files(dir: &Path, base: &Path, acc: &mut Vec<String>) {
        if let Ok(entries) = std::fs::read_dir(dir) {
            for entry in entries.flatten() {
                let p = entry.path();
                if p.is_dir() {
                    collect_surql_files(&p, base, acc);
                } else if p.extension().is_some_and(|ext| ext == "surql") {
                    let rel = p.strip_prefix(base).unwrap().to_str().unwrap().replace('\\', "/");
                    acc.push(rel);
                }
            }
        }
    }

    let base_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mut found = Vec::new();
    collect_surql_files(&base_dir.join("schema"), &base_dir, &mut found);
    collect_surql_files(&base_dir.join("migrations"), &base_dir, &mut found);
    collect_surql_files(&base_dir.join("functions"), &base_dir, &mut found);
    collect_surql_files(&base_dir.join("seeds"), &base_dir, &mut found);
    collect_surql_files(&base_dir.join("error"), &base_dir, &mut found);

    for f in &found {
        assert!(
            declared_files.contains(f),
            "Orphan .surql file not declared in manifest.toml: {}",
            f
        );
    }
}
