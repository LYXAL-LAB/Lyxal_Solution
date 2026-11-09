//! Base de test : le module installé depuis son manifeste, avec ses dépendances, comme le fait
//! `lyxal_runtime` pour le serveur hôte. Tous les tests d'intégration partent de là.

use lyxal_auth::{AccessConfig, AccessService, AuthStore, SigningKeyService};
use lyxal_crypto::{
    CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, SecretString, StaticKeyResolver,
};
use lyxal_pipeline_ingestion::error::{IngestionError, IngestionResult};
use lyxal_pipeline_ingestion::publisher::{CatalogueTokenIssuer, CATALOGUE_SYNC_CLIENT_ID};
use lyxal_pipeline_ingestion::storage::{BatchClaim, IngestionStore, NewBatch};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use std::path::PathBuf;
use std::sync::Arc;

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

/// Nouvelle base embarquée où `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`,
/// `lyxal_base`, `lyxal_catalogue` et le module sont installés depuis leurs manifestes.
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
        "lyxal_auth",
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

/// Émetteur de test : sessions du compte de service `lyxal-catalogue-sync` ouvertes par
/// `lyxal_auth` (clés de signature et trousseau éphémères), comme le fait l'hôte.
pub struct AuthSyncIssuer {
    access: AccessService<StaticKeyResolver>,
}

#[async_trait::async_trait]
impl CatalogueTokenIssuer for AuthSyncIssuer {
    async fn issue(&self) -> IngestionResult<SecretString> {
        self.access
            .internal_service_token(CATALOGUE_SYNC_CLIENT_ID)
            .await
            .map(|issued| issued.access_token)
            .map_err(|e| IngestionError::Validation(format!("Jeton de synchronisation : {e}")))
    }
}

/// Émetteur des jetons du compte de service de synchronisation pour la base du store.
pub async fn sync_issuer(store: &IngestionStore) -> Arc<AuthSyncIssuer> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("ingestion-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    let engine = Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))));
    let auth = AuthStore::new(store.client().clone());
    let keys = Arc::new(SigningKeyService::new(auth.clone(), engine.clone()));
    keys.ensure().await.expect("clés de signature");
    let access = AccessService::new(
        auth,
        engine,
        keys,
        AccessConfig {
            namespace: "ingestion".into(),
            database: "manifest".into(),
            public_url: "https://lyxal.test".into(),
            issuer: "Lyxal Test".into(),
            passkey_rp_id: None,
        },
    )
    .expect("service d'accès");
    Arc::new(AuthSyncIssuer { access })
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

/// Enregistrements d'une source lue par un adaptateur, sans aucun rejet attendu.
pub fn records_of(
    items: Vec<lyxal_pipeline_ingestion::adapters::SourceItem>,
) -> Vec<lyxal_pipeline_ingestion::adapters::RawRecordDto> {
    items
        .into_iter()
        .map(|item| match item {
            lyxal_pipeline_ingestion::adapters::SourceItem::Record(record) => *record,
            lyxal_pipeline_ingestion::adapters::SourceItem::Rejected(rejection) => {
                panic!("rejet inattendu : {rejection:?}")
            }
        })
        .collect()
}
