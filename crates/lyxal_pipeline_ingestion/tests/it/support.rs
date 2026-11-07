//! Base de test : le module installé depuis son manifeste, avec ses dépendances, comme le fait
//! `lyxal_runtime` pour le serveur hôte. Tous les tests d'intégration partent de là.

use lyxal_crypto::SecretString;
use lyxal_pipeline_ingestion::publisher::{CatalogueSyncKey, HmacCatalogueTokenIssuer};
use lyxal_pipeline_ingestion::storage::{BatchClaim, IngestionStore, NewBatch};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;

/// Crée un lot et le réserve pour le test, comme le fait le worker avant d'écrire (lignes,
/// articles, anomalies, points de reprise, transitions). Le test libère la réservation
/// (`release_batch`) avant de confier le lot au worker.
pub async fn claimed_batch(store: &IngestionStore, batch: &NewBatch) -> BatchClaim {
    let id = store.create_batch(batch).await.expect("lot");
    store
        .claim_batch(&id, "test", 600)
        .await
        .expect("réservation du lot")
}

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
            DirResourceProvider::new(dir),
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

/// Résolutions d'une ligne par les référentiels installés (comme le worker pour un bloc).
pub async fn referentials_for(
    store: &IngestionStore,
    record: &lyxal_pipeline_ingestion::adapters::RawRecordDto,
    default_manufacturer: Option<&str>,
) -> lyxal_pipeline_ingestion::normalization::BlockReferentials {
    store
        .block_referentials(std::slice::from_ref(record), default_manufacturer)
        .await
        .expect("résolution des référentiels")
}

/// Lecteur de test : ressource lue sous le dossier source d'un module (tests seulement ; le
/// serveur embarque les ressources dans le binaire).
pub struct DirResourceProvider(pub std::path::PathBuf);

impl DirResourceProvider {
    pub fn new(dir: impl Into<std::path::PathBuf>) -> Self {
        Self(dir.into())
    }
}

#[async_trait::async_trait]
impl ResourceProvider for DirResourceProvider {
    async fn read(&self, logical_path: &str) -> Result<String, lyxal_runtime::RuntimeError> {
        std::fs::read_to_string(self.0.join(logical_path)).map_err(|_| {
            lyxal_runtime::RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            }
        })
    }
}
