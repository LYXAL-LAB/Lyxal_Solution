//! Base de test : le module installé depuis son manifeste, avec ses dépendances, comme le fait
//! `lyxal_runtime` pour le serveur hôte. Tous les tests d'intégration partent de là.

use lyxal_auth::{AccessConfig, AccessService, AuthStore, SigningKeyService};
use lyxal_crypto::{
    CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, SecretString, StaticKeyResolver,
};
use lyxal_pipeline_ingestion::error::{IngestionError, IngestionResult};
use lyxal_pipeline_ingestion::publisher::{CatalogueTokenIssuer, CATALOGUE_SYNC_CLIENT_ID};
use lyxal_pipeline_ingestion::storage::{BatchClaim, IngestionStore, NewBatch};
use lyxal_pipeline_ingestion::worker::IngestionWorker;
use lyxal_pipeline_ingestion::SOURCE_BUCKET;
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_storage::models::{BucketCreateParams, BucketListParams, ObjectGetParams};
use lyxal_storage::{BackendConfig, Backends, PutRequest, StorageService, StorageStore};
use lyxal_surreal::ToSql;
use std::path::PathBuf;
use std::sync::{Arc, OnceLock};

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
/// `lyxal_i18n`, `lyxal_base`, `lyxal_catalogue`, `lyxal_storage` et le module sont installés
/// depuis leurs manifestes.
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
        "lyxal_i18n",
        "lyxal_base",
        "lyxal_catalogue",
        "lyxal_storage",
        "lyxal_pipeline_ingestion",
    ] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    IngestionStore::new(client)
}

/// Support de stockage en mémoire, commun à tous les tests du processus (les emplacements portent
/// l'identifiant de leur fiche : deux bases de test ne se croisent pas).
fn backends() -> Arc<Backends> {
    static BACKENDS: OnceLock<Arc<Backends>> = OnceLock::new();
    BACKENDS
        .get_or_init(|| {
            Arc::new(
                Backends::new()
                    .with("default", BackendConfig::Memory)
                    .expect("support mémoire"),
            )
        })
        .clone()
}

/// Service de stockage des fichiers sources sur la base du store (session système).
pub fn storage(store: &IngestionStore) -> StorageService {
    StorageService::new(StorageStore::new(store.client().clone()), backends())
}

/// Worker de test : fichiers sources lus dans le stockage en mémoire.
pub fn worker(store: &IngestionStore) -> IngestionWorker {
    IngestionWorker::new(store.clone(), storage(store)).expect("worker")
}

/// Envoie un fichier source dans le bucket de l'ingestion (créé au premier appel) ; rend sa
/// fiche `storage_object:<clé>`, à donner à [`NewBatch::source_object`]. Deux lots d'un même
/// format ne peuvent pas porter le même contenu (`INGESTION_BATCH_DUPLICATE`).
pub async fn source(store: &IngestionStore, name: &str, content: &[u8]) -> String {
    let service = storage(store);
    let buckets = service
        .store()
        .bucket_list(BucketListParams {
            tenant: None,
            limit: 100,
            start: 0,
        })
        .await
        .expect("buckets")
        .items;
    let bucket = match buckets
        .into_iter()
        .find(|bucket| bucket.name == SOURCE_BUCKET)
    {
        Some(bucket) => bucket.id,
        None => {
            service
                .store()
                .bucket_create(BucketCreateParams::named(None, SOURCE_BUCKET))
                .await
                .expect("bucket")
                .id
        }
    };
    let chunk: Result<bytes::Bytes, std::convert::Infallible> =
        Ok(bytes::Bytes::copy_from_slice(content));
    service
        .put(
            PutRequest {
                bucket: bucket.to_sql(),
                key: name.to_string(),
                filename: name.to_string(),
                content_type: None,
                size: Some(content.len() as u64),
            },
            futures::stream::iter([chunk]),
        )
        .await
        .expect("fichier source")
        .id
        .to_sql()
}

/// Remplace sur le support les octets d'un fichier source, sans toucher à sa fiche (fichier
/// altéré après la création du lot).
pub async fn tamper(store: &IngestionStore, source_object: &str, content: &[u8]) {
    use object_store::ObjectStoreExt;
    let fiche = storage(store)
        .store()
        .object_get(ObjectGetParams::by_id(source_object))
        .await
        .expect("fiche");
    backends()
        .get(&fiche.backend)
        .expect("support")
        .store()
        .put(
            &object_store::path::Path::from(fiche.path.as_str()),
            content.to_vec().into(),
        )
        .await
        .expect("octets remplacés");
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
