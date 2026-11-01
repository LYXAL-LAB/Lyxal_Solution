//! Préparation commune des tests d'intégration du Runtime.

use std::path::PathBuf;
use surrealdb::engine::any::connect;

/// Helper pour créer une base de données mémoire SurrealDB isolée avec les primitives canoniques de base (lyxal_error)
pub async fn setup_db(ns: &str, db: &str) -> surrealdb::Surreal<surrealdb::engine::any::Any> {
    let client = connect("mem://").await.expect("connect mem://");
    client.use_ns(ns).use_db(db).await.expect("use_ns/use_db");

    let error_manifest_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Parent crates dir")
        .join("lyxal_error")
        .join("manifest.toml");

    let content = std::fs::read_to_string(&error_manifest_path).unwrap_or_else(|e| {
        panic!(
            "Failed to read lyxal_error manifest at {:?}: {}",
            error_manifest_path, e
        )
    });
    let parsed: toml::Value =
        toml::from_str(&content).expect("Failed to parse lyxal_error manifest");
    let resources = parsed
        .get("resources")
        .and_then(|v| v.as_table())
        .expect("Resources table in lyxal_error manifest");

    let error_base_dir = error_manifest_path.parent().expect("lyxal_error dir");

    if let Some(schemas) = resources.get("schemas").and_then(|v| v.as_array()) {
        for s in schemas {
            let rel = s.as_str().expect("schema rel path");
            let surql = std::fs::read_to_string(error_base_dir.join(rel))
                .unwrap_or_else(|e| panic!("Failed to read {}: {}", rel, e));
            client
                .query(&surql)
                .await
                .expect("query failed")
                .check()
                .expect("check failed");
        }
    }

    if let Some(functions) = resources.get("functions").and_then(|v| v.as_array()) {
        for f in functions {
            let rel = f.as_str().expect("function rel path");
            let surql = std::fs::read_to_string(error_base_dir.join(rel))
                .unwrap_or_else(|e| panic!("Failed to read {}: {}", rel, e));
            client
                .query(&surql)
                .await
                .expect("query failed")
                .check()
                .expect("check failed");
        }
    }

    client
}
