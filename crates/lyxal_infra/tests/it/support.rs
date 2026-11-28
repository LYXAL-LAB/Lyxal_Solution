//! Base embarquée (`mem://`, session système) avec le socle (`lyxal_core`, `lyxal_error`),
//! schéma du runtime, `lyxal_event`, `lyxal_auth`, `lyxal_secrets`, `lyxal_scheduler` et
//! `lyxal_infra` installés depuis leurs manifestes, comme le fait l'hôte.

use lyxal_infra::InfraStore;
use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use std::path::PathBuf;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Banc : client de la base installée et store sur ce client.
pub struct Bench {
    pub client: Surreal<Any>,
    pub store: InfraStore,
}

pub async fn bench() -> Bench {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client.use_ns("infra").use_db("test").await.expect("ns/db");
    install(&client).await;
    Bench {
        store: InfraStore::new(client.clone()),
        client,
    }
}

async fn install(client: &Surreal<Any>) {
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
    lyxal_runtime::schema::install_batch(client, &batch)
        .await
        .expect("socle");
    lyxal_runtime::schema::install_runtime_schema(client)
        .await
        .expect("schéma du runtime");
    for name in [
        "lyxal_event",
        "lyxal_auth",
        "lyxal_secrets",
        "lyxal_scheduler",
        "lyxal_infra",
    ] {
        // Release en cours d'installation, comme le runtime : le seed du module déclare ses
        // tâches du planificateur (la garde de scheduler_task l'exige)
        client
            .query("fn::runtime_module_upsert({ module_id: $id, name: $id }); fn::runtime_release_register({ module_id: $id, version: '0.1.0', manifest_version: 1, status: 'Installing' });")
            .bind(("id", name.to_string()))
            .await
            .and_then(|r| r.check())
            .unwrap_or_else(|e| panic!("release de {name} : {e}"));
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
}

/// Exécute une requête de préparation (session système) et vérifie qu'elle a réussi.
pub async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .expect("requête de préparation");
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
