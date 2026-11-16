//! Base embarquée avec `lyxal_core`, `lyxal_error`, le schéma du runtime, `lyxal_event`,
//! `lyxal_auth` et `lyxal_scheduler` installés comme le fait l'hôte ; session système (racine) ;
//! module d'essai `lyxal_essai` installé (release du runtime), organisation et tâches d'essai
//! déclarées comme le seed d'un module.

use lyxal_runtime::manifest::{ManifestParser, ModuleManifest};
use lyxal_runtime::resource::ResourceProvider;
use lyxal_scheduler::{SchedulerService, SchedulerStore};
use lyxal_surreal::{LyxalSurrealCall, SurrealValue, Value};
use std::path::PathBuf;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub async fn installed_client() -> Surreal<Any> {
    let client = surrealdb::engine::any::connect("mem://")
        .await
        .expect("connexion");
    client
        .use_ns("scheduler")
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
    lyxal_runtime::schema::install_runtime_schema(&client)
        .await
        .expect("schéma du runtime");
    for name in ["lyxal_event", "lyxal_auth", "lyxal_scheduler"] {
        let (manifest, provider) = load(name);
        lyxal_runtime::schema::install_resources(&client, &manifest, &provider)
            .await
            .unwrap_or_else(|e| panic!("{name} : {e}"));
    }
    client
        .query(
            r#"
            fn::runtime_module_upsert({ module_id: "lyxal_essai", name: "Essai" });
            fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.1.0", manifest_version: 1, status: "Installed" });
            CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
            CREATE scheduler_task:⟨essai.rapport⟩ CONTENT {
                module: "lyxal_essai", executor: "handler", target: "essai.rapport",
                description: { fr: "Rapport", en: "Report" },
                args_schema: { fields: { format: { pipeline: [{ rule: "enum", options: { allowed: ["pdf", "csv"], case_sensitive: true } }], required: true } }, unknown_keys: "reject" },
                retry: { max_attempts: 3, strategy: "exponential", initial_delay: 10s, max_delay: 30s }, timeout: 1m
            };
            CREATE scheduler_task:⟨essai.global⟩ CONTENT {
                module: "lyxal_essai", executor: "event", target: "essai.global.tick", scope: "installation",
                retry: { max_attempts: 1, strategy: "fixed", initial_delay: 1s, max_delay: 1s }
            };
            "#,
        )
        .await
        .and_then(|r| r.check())
        .expect("données d'essai");
    client
}

/// Prend le bail du planificateur pour le nœud `node` (une heure) et rend sa génération : la
/// garde des fonctions du planificateur appelées directement par un test (Y2).
pub async fn leader(client: &Surreal<Any>, node: &str) -> i64 {
    let mut response = client
        .query("RETURN fn::runtime_lease_acquire({ kind: 'leader', key: 'scheduler', node_id: $node, ttl_seconds: 3600 }).data.lease.generation;")
        .bind(("node", node.to_string()))
        .await
        .expect("bail du planificateur");
    let generation: Option<i64> = response.take(0).expect("génération");
    generation.expect("bail du planificateur pris")
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

pub async fn bench() -> (Surreal<Any>, SchedulerStore, SchedulerService) {
    let client = installed_client().await;
    let store = SchedulerStore::new(client.clone());
    let service = SchedulerService::new(store.clone());
    (client, store, service)
}

/// Appel sans type de résultat : la donnée brute rendue par la fonction.
pub async fn raw<P: SurrealValue + Send + 'static>(
    store: &SchedulerStore,
    function: &'static str,
    params: P,
) -> Value {
    store
        .call_fn::<Value, P>(function, params)
        .await
        .unwrap_or_else(|e| panic!("{function} : {e}"))
}

/// Décode `raw` en `T` et vérifie qu'aucune donnée n'est perdue : chaque champ renseigné de la
/// donnée brute se retrouve, à l'identique, dans le type ré-encodé. Les champs `ignored` sont
/// exclus (jeton de bail, jamais rendu dans `Run`).
pub fn lossless<T: SurrealValue>(raw: Value, ignored: &[&str]) -> T {
    let decoded = T::from_value(raw.clone()).unwrap_or_else(|e| panic!("décodage : {e} — {raw:?}"));
    let encoded = T::from_value(raw.clone()).expect("décodage").into_value();
    contained(&raw, &encoded, "$", ignored);
    decoded
}

fn contained(raw: &Value, encoded: &Value, path: &str, ignored: &[&str]) {
    match (raw, encoded) {
        (Value::Object(r), Value::Object(e)) => {
            for (key, value) in r.iter() {
                if matches!(value, Value::None) || ignored.contains(&key.as_str()) {
                    continue;
                }
                let inner = e
                    .get(key)
                    .unwrap_or_else(|| panic!("champ perdu : {path}.{key} = {value:?}"));
                contained(value, inner, &format!("{path}.{key}"), ignored);
            }
        }
        (Value::Array(r), Value::Array(e)) => {
            assert_eq!(r.len(), e.len(), "longueur de {path}");
            for (i, (a, b)) in r.iter().zip(e.iter()).enumerate() {
                contained(a, b, &format!("{path}[{i}]"), ignored);
            }
        }
        (a, b) => assert_eq!(a, b, "valeur de {path}"),
    }
}
