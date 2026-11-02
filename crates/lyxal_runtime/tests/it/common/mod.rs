//! Préparation commune des tests d'intégration du Runtime.

use std::path::PathBuf;
use surrealdb::engine::any::connect;

/// Crée une base mémoire isolée et y installe `lyxal_core` (validation des entrées) et
/// `lyxal_error` (contrat de résultat, définitions d'erreurs) depuis leurs manifestes, phase
/// par phase : schémas, puis fonctions, puis définitions d'erreurs.
pub async fn setup_db(ns: &str, db: &str) -> surrealdb::Surreal<surrealdb::engine::any::Any> {
    let client = connect("mem://").await.expect("connect mem://");
    client.use_ns(ns).use_db(db).await.expect("use_ns/use_db");

    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    let manifests: Vec<(PathBuf, toml::Value)> =
        [crates.join("lyxal_core"), crates.join("lyxal_error")]
            .into_iter()
            .map(|dir| {
                let content =
                    std::fs::read_to_string(dir.join("manifest.toml")).expect("manifeste");
                let manifest = toml::from_str(&content).expect("manifeste TOML");
                (dir, manifest)
            })
            .collect();
    for key in ["schemas", "functions", "error_definitions"] {
        for (dir, manifest) in &manifests {
            let Some(files) = manifest
                .get("resources")
                .and_then(|r| r.get(key))
                .and_then(|v| v.as_array())
            else {
                continue;
            };
            let script: String = files
                .iter()
                .map(|f| {
                    let path = dir.join(f.as_str().expect("chemin"));
                    std::fs::read_to_string(&path)
                        .unwrap_or_else(|e| panic!("{} : {e}", path.display()))
                })
                .collect::<Vec<_>>()
                .join("\n");
            client
                .query(script)
                .await
                .and_then(|r| r.check())
                .unwrap_or_else(|e| panic!("{} [{key}] : {e}", dir.display()));
        }
    }

    client
}
