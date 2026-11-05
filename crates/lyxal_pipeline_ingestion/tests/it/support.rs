//! Base de test : le module installé depuis son manifeste, avec ses dépendances, comme le fait
//! `lyxal_runtime` pour le serveur hôte. Tous les tests d'intégration partent de là.

use lyxal_pipeline_ingestion::storage::IngestionStore;
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::{FilesystemResourceProvider, ResourceProvider};
use std::path::PathBuf;

/// Nouvelle base embarquée où `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_base` et le
/// module sont installés depuis leurs manifestes.
pub async fn installed_store() -> IngestionStore {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client
        .use_ns("ingestion")
        .use_db("manifest")
        .await
        .expect("ns/db");
    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    let load = |name: &str| {
        let dir = crates.join(name);
        (
            ManifestParser::parse_file(dir.join("manifest.toml")).expect("manifeste"),
            FilesystemResourceProvider::new(dir),
        )
    };
    let foundation = [load("lyxal_core"), load("lyxal_error")];
    let batch: Vec<(&ModuleManifest, &dyn ResourceProvider)> = foundation
        .iter()
        .map(|(m, p)| (m, p as &dyn ResourceProvider))
        .collect();
    lyxal_runtime::schema::install_batch(&client, &batch)
        .await
        .expect("noyau");
    for name in ["lyxal_event", "lyxal_base", "lyxal_pipeline_ingestion"] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    IngestionStore::new(client)
}
