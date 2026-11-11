//! Base embarquée avec `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` et
//! `lyxal_storage` installés comme le fait l'hôte ; supports mémoire et disque.

use bytes::Bytes;
use futures::{stream, Stream, StreamExt};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_storage::models::BucketCreateParams;
use lyxal_storage::{
    BackendConfig, Backends, OpenedObject, PutRequest, StorageService, StorageStore,
};
use lyxal_surreal::ToSql;
use std::convert::Infallible;
use std::path::PathBuf;
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub async fn installed_client() -> Surreal<Any> {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client
        .use_ns("storage")
        .use_db("test")
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
            DirResourceProvider(dir),
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
    for name in ["lyxal_event", "lyxal_auth", "lyxal_storage"] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    client
}

/// Lecteur de test : ressource lue sous le dossier source d'un module.
pub struct DirResourceProvider(PathBuf);

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

/// Banc : base installée, support `default` et service sur la session système.
pub struct Bench {
    pub client: Surreal<Any>,
    pub store: StorageStore,
    pub backends: Arc<Backends>,
    pub service: StorageService,
    /// Dossier temporaire du support disque (retiré à la fin du test).
    _root: Option<tempfile::TempDir>,
}

/// Support `default` d'un banc.
#[derive(Clone, Copy, Debug)]
pub enum Kind {
    Memory,
    Disk,
}

pub const KINDS: [Kind; 2] = [Kind::Memory, Kind::Disk];

pub async fn bench(kind: Kind) -> Bench {
    let client = installed_client().await;
    let (config, root) = match kind {
        Kind::Memory => (BackendConfig::Memory, None),
        Kind::Disk => {
            let root = tempfile::tempdir().expect("dossier temporaire");
            (
                BackendConfig::Disk {
                    root: root.path().to_path_buf(),
                },
                Some(root),
            )
        }
    };
    let backends = Arc::new(Backends::new().with("default", config).expect("support"));
    let store = StorageStore::new(client.clone());
    Bench {
        service: StorageService::new(store.clone(), backends.clone()),
        client,
        store,
        backends,
        _root: root,
    }
}

impl Bench {
    /// Bucket de l'installation ; rend son identifiant `storage_bucket:<clé>`.
    pub async fn bucket(&self, name: &str) -> String {
        self.store
            .bucket_create(BucketCreateParams::named(None, name))
            .await
            .expect("bucket")
            .id
            .to_sql()
    }

    /// Emplacements présents sur le support `default`.
    pub async fn stored_paths(&self) -> Vec<String> {
        let backend = self.backends.get("default").expect("support");
        let mut paths: Vec<String> = backend
            .list(None)
            .map(|meta| meta.expect("liste").location.to_string())
            .collect()
            .await;
        paths.sort();
        paths
    }

    /// Exécute une requête de préparation sous la session système.
    pub async fn run(&self, query: &str) {
        self.client
            .query(query.to_string())
            .await
            .expect("requête")
            .check()
            .expect("requête refusée");
    }
}

pub fn request(bucket: &str, key: &str) -> PutRequest {
    PutRequest {
        bucket: bucket.to_string(),
        key: key.to_string(),
        filename: key.rsplit('/').next().unwrap_or(key).to_string(),
        content_type: None,
        size: None,
    }
}

/// Flux sans erreur sur des morceaux donnés.
pub fn chunks(parts: &[&[u8]]) -> impl Stream<Item = Result<Bytes, Infallible>> + Send {
    let owned: Vec<Result<Bytes, Infallible>> = parts
        .iter()
        .map(|part| Ok(Bytes::copy_from_slice(part)))
        .collect();
    stream::iter(owned)
}

/// Lit tout le contenu d'un fichier ouvert.
pub async fn read_all(mut opened: OpenedObject) -> Vec<u8> {
    let mut content = Vec::new();
    while let Some(chunk) = opened.content.next().await {
        content.extend_from_slice(&chunk.expect("lecture"));
    }
    content
}
