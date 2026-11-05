//! Base de test : le module installé depuis son manifeste, avec ses dépendances, comme le fait
//! `lyxal_runtime` pour le serveur hôte. Tous les tests d'intégration partent de là.

use lyxal_crypto::SecretString;
use lyxal_pipeline_ingestion::publisher::{CatalogueSyncKey, HmacCatalogueTokenIssuer};
use lyxal_pipeline_ingestion::storage::IngestionStore;
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::{FilesystemResourceProvider, ResourceProvider};
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;

/// Nouvelle base embarquée où `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_base`,
/// `lyxal_catalogue` et le module sont installés depuis leurs manifestes.
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
    for name in [
        "lyxal_event",
        "lyxal_base",
        "lyxal_catalogue",
        "lyxal_pipeline_ingestion",
    ] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    IngestionStore::new(client)
}

/// Accès JWT de l'agent de synchronisation, défini comme le fait l'hôte, et émetteur de jetons
/// signés avec la même clé (aléatoire, propre au test).
pub async fn sync_issuer(store: &IngestionStore) -> Arc<HmacCatalogueTokenIssuer> {
    let key = CatalogueSyncKey::parse(
        SecretString::new(uuid::Uuid::new_v4().simple().to_string()).expect("clé"),
    )
    .expect("clé de test");
    store
        .client()
        .query(format!(
            "DEFINE ACCESS OVERWRITE lyxal_catalogue_sync ON DATABASE TYPE JWT ALGORITHM HS256 KEY '{}' DURATION FOR SESSION 15m;",
            key.expose_secret()
        ))
        .await
        .expect("accès JWT")
        .check()
        .expect("accès JWT défini");
    Arc::new(
        HmacCatalogueTokenIssuer::new(
            &key,
            "ingestion",
            "manifest",
            "lyxal_catalogue_sync",
            Duration::from_secs(300),
        )
        .expect("émetteur"),
    )
}
