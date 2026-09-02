use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::manifest::model::{ModuleDependency, CURRENT_MANIFEST_VERSION};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::types::ModuleReleaseStatus;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::memory::MemoryRuntimeStore;
use lyxal_runtime::store::traits::RuntimeStore;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeConfig;
use semver::{Version, VersionReq};
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use surrealdb::engine::any::connect;

struct MemoryTestResourceProvider {
    resources: HashMap<String, ModuleResource>,
}

impl MemoryTestResourceProvider {
    fn new() -> Self {
        Self {
            resources: HashMap::new(),
        }
    }

    fn add_resource(mut self, path: &str, kind: ResourceKind, content: &str) -> Self {
        self.resources
            .insert(path.to_string(), ModuleResource::new(path, kind, content));
        self
    }
}

#[async_trait]
impl ResourceProvider for MemoryTestResourceProvider {
    async fn read_resource(&self, path: &str) -> Result<ModuleResource, RuntimeError> {
        self.resources
            .get(path)
            .cloned()
            .ok_or_else(|| RuntimeError::ResourceNotFound {
                path: path.to_string(),
            })
    }

    async fn list_resources(&self, prefix: &str) -> Result<Vec<String>, RuntimeError> {
        let p = prefix.trim_start_matches('/');
        let matches: Vec<String> = self
            .resources
            .keys()
            .filter(|k| k.starts_with(p))
            .cloned()
            .collect();
        Ok(matches)
    }

    async fn exists(&self, path: &str) -> bool {
        self.resources.contains_key(path)
    }
}

struct MockBatchModule {
    descriptor: ModuleDescriptor,
    should_fail_install: Arc<AtomicBool>,
}

impl MockBatchModule {
    fn new(id: &str, version: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
            should_fail_install: Arc::new(AtomicBool::new(false)),
        }
    }
}

#[async_trait]
impl LyxalModule for MockBatchModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        if self.should_fail_install.load(Ordering::SeqCst) {
            return Err(RuntimeError::InstallFailure {
                module: self.descriptor.id.clone(),
                message: format!("Simulated install failure in {}", self.descriptor.id),
            });
        }
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

fn create_package(
    id: &str,
    version: &str,
    deps: Vec<(&str, Option<&str>)>,
) -> (ModulePackage, Arc<MockBatchModule>) {
    let dependencies = deps
        .into_iter()
        .map(|(dep_id, req_str)| {
            if let Some(r) = req_str {
                ModuleDependency::with_version(dep_id, VersionReq::parse(r).unwrap())
            } else {
                ModuleDependency::new(dep_id)
            }
        })
        .collect();

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new(id),
        name: format!("Module {}", id),
        version: Version::parse(version).unwrap(),
        description: None,
        runtime: None,
        dependencies,
        capabilities: Vec::new(),
    };

    let provider = Arc::new(
        MemoryTestResourceProvider::new()
            .add_resource(
                &format!("schema/tables/{}.surql", id),
                ResourceKind::Tables,
                &format!("DEFINE TABLE {} SCHEMALESS;", id.replace('-', "_")),
            )
            .add_resource(
                "migrations/001_init.surql",
                ResourceKind::Migration,
                &format!(
                    "DEFINE FIELD created_at ON TABLE {} TYPE datetime;",
                    id.replace('-', "_")
                ),
            ),
    );

    let mock = Arc::new(MockBatchModule::new(id, version));
    let pkg = ModulePackage::new(manifest, provider).with_module_impl(mock.clone());
    (pkg, mock)
}

#[tokio::test]
async fn test_batch_dag_diamond_installation_and_start_order() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store.clone());

    // DAG en diamant :
    // lyxal-auth
    //   ├── lyxal-calendar (dep: lyxal-auth >=1.0.0)
    //   └── lyxal-scheduler (dep: lyxal-auth >=1.0.0)
    //         └── lyxal-booking (dep: lyxal-calendar, lyxal-scheduler)

    let (pkg_booking, _) = create_package(
        "lyxal-booking",
        "1.0.0",
        vec![("lyxal-calendar", None), ("lyxal-scheduler", None)],
    );
    let (pkg_calendar, _) = create_package(
        "lyxal-calendar",
        "1.0.0",
        vec![("lyxal-auth", Some(">=1.0.0"))],
    );
    let (pkg_scheduler, _) = create_package(
        "lyxal-scheduler",
        "1.0.0",
        vec![("lyxal-auth", Some("^1.0"))],
    );
    let (pkg_auth, _) = create_package("lyxal-auth", "1.0.0", vec![]);

    // Ordre intentionnellement inversé dans la requête batch
    let batch = vec![pkg_booking, pkg_calendar, pkg_scheduler, pkg_auth];

    let result = runtime.install_packages(batch).await.unwrap();
    println!("DEBUG result: {:?}", result);

    assert!(result.is_success());
    assert_eq!(result.installed.len(), 4);
    assert_eq!(result.failed.len(), 0);
    assert_eq!(result.not_attempted.len(), 0);

    // L'ordre d'installation effectif doit respecter le DAG (auth en premier, booking en dernier)
    assert_eq!(result.installed[0], ModuleId::new("lyxal-auth"));
    assert_eq!(result.installed[3], ModuleId::new("lyxal-booking"));

    // Tous les modules doivent être persistés dans l'état Installed
    for id in &[
        "lyxal-auth",
        "lyxal-calendar",
        "lyxal-scheduler",
        "lyxal-booking",
    ] {
        let release = store
            .get_release(&ModuleId::new(*id), "1.0.0")
            .await
            .unwrap()
            .expect("Must be in store");
        assert_eq!(release.status, ModuleReleaseStatus::Installed.as_str());
    }

    // Démarrage global start_all() puis arrêt stop_all()
    runtime.start_all().await.unwrap();
    runtime.stop_all().await.unwrap();
}

#[tokio::test]
async fn test_batch_duplicate_module_rejection() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store);

    let (pkg_auth_v1, _) = create_package("lyxal-auth", "1.0.0", vec![]);
    let (pkg_auth_v2, _) = create_package("lyxal-auth", "2.0.0", vec![]);

    // Deux versions conflictuelles du même module dans le même batch
    let batch = vec![pkg_auth_v1, pkg_auth_v2];

    let err = runtime.install_packages(batch).await.unwrap_err();
    assert!(matches!(err, RuntimeError::BatchDuplicateModule { .. }));
}

#[tokio::test]
async fn test_batch_fault_isolation_and_not_attempted_reporting() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store);

    // Graphe :
    // lyxal-auth (échoue à l'installation)
    //   ├── lyxal-calendar (doit être marqué not_attempted)
    // lyxal-standalone (indépendant, doit être installé avec succès)

    let (pkg_auth, mock_auth) = create_package("lyxal-auth", "1.0.0", vec![]);
    mock_auth.should_fail_install.store(true, Ordering::SeqCst);

    let (pkg_calendar, _) = create_package("lyxal-calendar", "1.0.0", vec![("lyxal-auth", None)]);
    let (pkg_standalone, _) = create_package("lyxal-standalone", "1.0.0", vec![]);

    let batch = vec![pkg_auth, pkg_calendar, pkg_standalone];

    let result = runtime.install_packages(batch).await.unwrap();

    assert!(!result.is_success());
    assert_eq!(result.installed, vec![ModuleId::new("lyxal-standalone")]);
    assert_eq!(result.failed.len(), 1);
    assert_eq!(result.failed[0].0, ModuleId::new("lyxal-auth"));
    assert_eq!(result.not_attempted.len(), 1);
    assert_eq!(
        result.not_attempted[0],
        (ModuleId::new("lyxal-calendar"), ModuleId::new("lyxal-auth"))
    );
}
