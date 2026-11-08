//! Base embarquée avec `lyxal_core`, `lyxal_error`, `lyxal_event` et `lyxal_auth` installés comme
//! le fait l'hôte ; trousseau de clés éphémère.

use lyxal_auth::AuthStore;
use lyxal_crypto::{CryptoEngine, EncryptionKey, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver};
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use std::path::PathBuf;
use std::sync::Arc;

pub async fn installed_store() -> AuthStore {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client.use_ns("auth").use_db("test").await.expect("ns/db");
    install(&client).await;
    AuthStore::new(client)
}

/// Installe le noyau, `lyxal_event` et `lyxal_auth` dans la base courante du client.
pub async fn install(client: &surrealdb::Surreal<surrealdb::engine::any::Any>) {
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
    lyxal_runtime::schema::install_batch(client, &batch)
        .await
        .expect("noyau");
    for name in ["lyxal_event", "lyxal_auth"] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
}

pub fn crypto() -> Arc<CryptoEngine<StaticKeyResolver>> {
    let mut builder = KeyRingBuilder::new();
    builder
        .insert(
            KeyId::parse("auth-test").expect("id"),
            EncryptionKey::generate().expect("clé"),
            KeyUse::Active,
        )
        .expect("trousseau");
    Arc::new(CryptoEngine::new(StaticKeyResolver::new(Arc::new(
        builder.build().expect("trousseau"),
    ))))
}

/// Lecteur de test : ressource lue sous le dossier source d'un module (le serveur embarque les
/// ressources dans le binaire).
pub struct DirResourceProvider(PathBuf);

impl DirResourceProvider {
    pub fn new(dir: impl Into<PathBuf>) -> Self {
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
