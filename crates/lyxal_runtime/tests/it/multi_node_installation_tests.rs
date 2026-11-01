use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lock::installation::{
    InstallationLeaseManager, InstallationLockKey, SurrealInstallationLeaseManager,
};
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::manifest::model::CURRENT_MANIFEST_VERSION;
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::types::ModuleInstallationOutcome;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::surreal::SurrealRuntimeStore;
use lyxal_runtime::store::traits::RuntimeStore;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeConfig;
use semver::Version;
use std::collections::HashMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
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

struct SlowConcurrentModule {
    descriptor: ModuleDescriptor,
    install_count: Arc<AtomicUsize>,
    delay: Duration,
}

impl SlowConcurrentModule {
    fn new(id: &str, version: &str, count: Arc<AtomicUsize>, delay: Duration) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
            install_count: count,
            delay,
        }
    }
}

#[async_trait]
impl LyxalModule for SlowConcurrentModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.install_count.fetch_add(1, Ordering::SeqCst);
        tokio::time::sleep(self.delay).await;
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

#[tokio::test]
async fn test_concurrent_nodes_installation_mutual_exclusion_and_idempotence() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_concurrent_inst")
        .use_db("test_concurrent_inst")
        .await
        .unwrap();

    let store = Arc::new(SurrealRuntimeStore::new(client.clone()));
    store.bootstrap().await.unwrap();

    let shared_counter = Arc::new(AtomicUsize::new(0));

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-booking"),
        name: "Booking Service".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: None,
        runtime: None,
        dependencies: Vec::new(),
        capabilities: Vec::new(),
    };

    let provider = Arc::new(
        MemoryTestResourceProvider::new()
            .add_resource(
                "schema/tables/booking.surql",
                ResourceKind::Tables,
                "DEFINE TABLE OVERWRITE booking SCHEMALESS;",
            )
            .add_resource(
                "migrations/001_init.surql",
                ResourceKind::Migration,
                "DEFINE FIELD OVERWRITE date ON TABLE booking TYPE datetime;",
            ),
    );

    // Noeud A
    let node_a_id = NodeId::new("node-alpha");
    let lease_mgr_a = Arc::new(SurrealInstallationLeaseManager::new(client.clone()));
    let runtime_a = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_store(store.clone())
        .with_installation_lease_manager(lease_mgr_a)
        .with_node_id(node_a_id);

    let mod_a = Arc::new(SlowConcurrentModule::new(
        "lyxal-booking",
        "1.0.0",
        shared_counter.clone(),
        Duration::from_millis(50),
    ));
    let pkg_a = ModulePackage::new(manifest.clone(), provider.clone()).with_module_impl(mod_a);

    // Noeud B
    let node_b_id = NodeId::new("node-beta");
    let lease_mgr_b = Arc::new(SurrealInstallationLeaseManager::new(client.clone()));
    let runtime_b = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client.clone())
        .with_store(store.clone())
        .with_installation_lease_manager(lease_mgr_b)
        .with_node_id(node_b_id);

    let mod_b = Arc::new(SlowConcurrentModule::new(
        "lyxal-booking",
        "1.0.0",
        shared_counter.clone(),
        Duration::from_millis(50),
    ));
    let pkg_b = ModulePackage::new(manifest, provider).with_module_impl(mod_b);

    // Exécution concurrente simultanée
    let (res_a, res_b) = tokio::join!(
        runtime_a.install_package(pkg_a),
        runtime_b.install_package(pkg_b)
    );

    let rep_a = res_a.unwrap();
    let rep_b = res_b.unwrap();

    let outcomes = [rep_a.outcome.clone(), rep_b.outcome.clone()];
    let counter = shared_counter.load(Ordering::SeqCst);

    // Invariant strict 1 : Exactement 1 nœud installe (section critique mutuellement exclusive)
    assert!(
        outcomes.contains(&ModuleInstallationOutcome::Installed),
        "Expected exactly one Installed outcome, got: {:?}",
        outcomes
    );

    // Invariant strict 2 : L'autre nœud constate AlreadyInstalled via revalidation TOCTOU
    assert!(
        outcomes.contains(&ModuleInstallationOutcome::AlreadyInstalled),
        "Expected exactly one AlreadyInstalled outcome, got: {:?}",
        outcomes
    );

    // Invariant strict 3 : Le hook d'installation ne doit avoir été exécuté qu'UNE SEULE FOIS
    assert_eq!(
        counter, 1,
        "Install hook must be executed exactly once across all concurrent nodes"
    );
}

#[tokio::test]
async fn test_expired_installation_lease_recovery() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_recovery")
        .use_db("test_recovery")
        .await
        .unwrap();

    let lease_mgr = SurrealInstallationLeaseManager::new(client.clone());
    let key = InstallationLockKey::new(ModuleId::new("lyxal-scheduler"), "1.0.0");

    let dead_node = NodeId::new("crashed-node");
    let recovery_node = NodeId::new("active-node");

    // 1. Noeud mort acquiert un bail très court qui expire (1 sec)
    let acq1 = lease_mgr
        .acquire(&key, &dead_node, Duration::from_secs(1))
        .await
        .unwrap();
    let lease1 = match acq1 {
        lyxal_runtime::lock::installation::AcquireInstallationLeaseResult::Acquired(l) => l,
        _ => panic!("Expected Acquired"),
    };
    assert_eq!(lease1.generation, 1);

    // Attendre expiration
    tokio::time::sleep(Duration::from_millis(1100)).await;

    // 2. Le nœud de reprise acquiert le bail expiré
    let acq2 = lease_mgr
        .acquire(&key, &recovery_node, Duration::from_secs(30))
        .await
        .unwrap();
    let lease2 = match acq2 {
        lyxal_runtime::lock::installation::AcquireInstallationLeaseResult::RecoveredExpiredLease(l) => l,
        _ => panic!("Expected RecoveredExpiredLease"),
    };

    assert_eq!(lease2.owner, recovery_node);
    assert_eq!(lease2.generation, 2); // Fencing token incrémenté
}
