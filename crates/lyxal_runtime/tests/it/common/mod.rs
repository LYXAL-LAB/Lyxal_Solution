//! Préparation commune des tests d'intégration du Runtime.

use std::path::PathBuf;
use surrealdb::engine::any::connect;

/// Hôte des runtimes de test qui n'ont pas besoin d'un nom particulier.
pub const TEST_HOST: &str = "lyxal_test";

/// Hôte de test au nom donné.
pub fn host(name: &str) -> lyxal_runtime::HostId {
    lyxal_runtime::HostId::new(name).expect("nom d'hôte de test")
}

/// Configuration d'un runtime de test, pour l'hôte `TEST_HOST`.
pub fn runtime_config() -> lyxal_runtime::RuntimeConfig {
    lyxal_runtime::RuntimeConfig::new(host(TEST_HOST))
}

/// Base mémoire vierge et isolée.
pub async fn blank_db(ns: &str, db: &str) -> surrealdb::Surreal<surrealdb::engine::any::Any> {
    let client = connect("mem://").await.expect("connect mem://");
    client.use_ns(ns).use_db(db).await.expect("use_ns/use_db");
    client
}

/// Modules du socle hors runtime (`lyxal_core`, `lyxal_error`), lus depuis leurs dossiers.
pub fn foundation_modules() -> Vec<(lyxal_runtime::manifest::ModuleManifest, DirResourceProvider)> {
    let crates = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("dossier crates")
        .to_path_buf();
    ["lyxal_core", "lyxal_error"]
        .iter()
        .map(|name| {
            let dir = crates.join(name);
            let manifest =
                lyxal_runtime::manifest::ManifestParser::parse_file(dir.join("manifest.toml"))
                    .expect("manifeste");
            (manifest, DirResourceProvider::new(dir))
        })
        .collect()
}

/// Crée une base mémoire isolée et y installe `lyxal_core` et `lyxal_error` par le runtime,
/// depuis leurs manifestes, phase par phase (`schema::install_batch`).
pub async fn setup_db(ns: &str, db: &str) -> surrealdb::Surreal<surrealdb::engine::any::Any> {
    let client = blank_db(ns, db).await;
    let modules = foundation_modules();
    let batch: Vec<(
        &lyxal_runtime::manifest::ModuleManifest,
        &dyn lyxal_runtime::resource::ResourceProvider,
    )> = modules
        .iter()
        .map(|(m, p)| (m, p as &dyn lyxal_runtime::resource::ResourceProvider))
        .collect();
    lyxal_runtime::schema::install_batch(&client, &batch)
        .await
        .expect("installation de lyxal_core et lyxal_error");
    lyxal_runtime::schema::install_runtime_schema(&client)
        .await
        .expect("installation du schéma du runtime");
    client
}

/// Fournisseur de ressources en mémoire pour les tests : chaque fichier ajouté est aussi
/// déclaré dans la section `[resources]` correspondant à sa phase.
pub struct MemoryProvider {
    files: std::collections::HashMap<String, String>,
    resources: lyxal_runtime::manifest::ModuleResources,
}

impl MemoryProvider {
    pub fn new() -> Self {
        Self {
            files: std::collections::HashMap::new(),
            resources: lyxal_runtime::manifest::ModuleResources::default(),
        }
    }

    pub fn add_resource(
        mut self,
        path: &str,
        kind: lyxal_runtime::resource::ResourceKind,
        content: &str,
    ) -> Self {
        use lyxal_runtime::resource::ResourceKind;
        let section = match kind {
            ResourceKind::Schema => &mut self.resources.schemas,
            ResourceKind::Function => &mut self.resources.functions,
            ResourceKind::ErrorDefinition => &mut self.resources.error_definitions,
            ResourceKind::Event => &mut self.resources.events,
            ResourceKind::Seed => &mut self.resources.seeds,
            ResourceKind::Migration => &mut self.resources.migrations,
        };
        section.push(path.to_string());
        self.files.insert(path.to_string(), content.to_string());
        self
    }

    pub fn resources(&self) -> lyxal_runtime::manifest::ModuleResources {
        self.resources.clone()
    }
}

#[async_trait::async_trait]
impl lyxal_runtime::resource::ResourceProvider for MemoryProvider {
    async fn read(&self, path: &str) -> Result<String, lyxal_runtime::error::RuntimeError> {
        self.files.get(path).cloned().ok_or_else(|| {
            lyxal_runtime::error::RuntimeError::ResourceNotFound {
                path: path.to_string(),
            }
        })
    }
}

/// Package de test : le manifeste reçoit les ressources déclarées par le fournisseur.
pub fn package(
    mut manifest: lyxal_runtime::manifest::ModuleManifest,
    provider: std::sync::Arc<MemoryProvider>,
) -> lyxal_runtime::package::ModulePackage {
    manifest.resources = provider.resources();
    lyxal_runtime::package::ModulePackage::new(manifest, provider)
}

/// Installe `lyxal_event` comme le runtime : depuis son manifeste et ses fichiers embarqués.
pub async fn install_event(client: &surrealdb::Surreal<surrealdb::engine::any::Any>) {
    lyxal_runtime::schema::install_embedded(
        client,
        lyxal_event::MANIFEST,
        lyxal_event::EMBEDDED_RESOURCES,
    )
    .await
    .expect("installation de lyxal_event");
}

/// Manifeste de test dont `resources.migrations` liste les fichiers `.surql` présents dans
/// `migrations/` sous `root`, triés par nom.
pub fn manifest_with_migrations(
    module_id: &lyxal_runtime::types::ModuleId,
    version: &str,
    root: &std::path::Path,
) -> lyxal_runtime::manifest::ModuleManifest {
    let mut migrations: Vec<String> = std::fs::read_dir(root.join("migrations"))
        .map(|entries| {
            entries
                .filter_map(|e| e.ok())
                .filter_map(|e| e.file_name().into_string().ok())
                .filter(|name| name.ends_with(".surql"))
                .map(|name| format!("migrations/{name}"))
                .collect()
        })
        .unwrap_or_default();
    migrations.sort();
    lyxal_runtime::manifest::ModuleManifest {
        manifest_version: lyxal_runtime::manifest::CURRENT_MANIFEST_VERSION,
        id: module_id.clone(),
        name: module_id.to_string(),
        version: semver::Version::parse(version).expect("version"),
        description: None,
        runtime: None,
        dependencies: Vec::new(),
        capabilities: Vec::new(),
        resources: lyxal_runtime::manifest::ModuleResources {
            migrations,
            ..Default::default()
        },
    }
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
impl lyxal_runtime::resource::ResourceProvider for DirResourceProvider {
    async fn read(&self, logical_path: &str) -> Result<String, lyxal_runtime::RuntimeError> {
        std::fs::read_to_string(self.0.join(logical_path)).map_err(|_| {
            lyxal_runtime::RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            }
        })
    }
}
