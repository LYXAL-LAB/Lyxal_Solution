use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lock::installation::MemoryInstallationLeaseManager;
use lyxal_runtime::manifest::model::{
    ModuleDependency, RuntimeRequirement, CURRENT_MANIFEST_VERSION,
};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::types::{
    InstallationPhase, ModuleInstallationOutcome, ModuleReleaseStatus,
};
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::memory::MemoryRuntimeStore;
use lyxal_runtime::store::models::StoredModuleRelease;
use lyxal_runtime::store::traits::RuntimeStore;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::RuntimeConfig;
use semver::{Version, VersionReq};
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::Arc;
use surrealdb::engine::any::connect;

/// Fournisseur de ressources en mémoire simulant un package de module.
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

/// Module mock avec compteurs d'appels atomiques pour vérifier l'idempotence et les hooks.
struct MockTestModule {
    descriptor: ModuleDescriptor,
    install_count: Arc<AtomicUsize>,
    start_count: Arc<AtomicUsize>,
    should_fail_install: Arc<AtomicBool>,
}

impl MockTestModule {
    fn new(id: &str, version: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
            install_count: Arc::new(AtomicUsize::new(0)),
            start_count: Arc::new(AtomicUsize::new(0)),
            should_fail_install: Arc::new(AtomicBool::new(false)),
        }
    }
}

#[async_trait]
impl LyxalModule for MockTestModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.install_count.fetch_add(1, Ordering::SeqCst);
        if self.should_fail_install.load(Ordering::SeqCst) {
            return Err(RuntimeError::InstallFailure {
                module: self.descriptor.id.clone(),
                message: "Simulated hook install failure".to_string(),
            });
        }
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.start_count.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

#[tokio::test]
async fn test_single_module_full_installation_pipeline() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_single_mod_inst")
        .use_db("test_single_mod_inst")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store.clone())
        .with_installation_lease_manager(lease_mgr);

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-booking"),
        name: "Lyxal Booking Engine".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: Some("Core booking service".to_string()),
        runtime: None,
        dependencies: Vec::new(),
        capabilities: vec!["database".to_string()],
    };

    let provider = Arc::new(
        MemoryTestResourceProvider::new()
            .add_resource(
                "schema/tables/booking.surql",
                ResourceKind::Tables,
                "DEFINE TABLE booking SCHEMALESS;",
            )
            .add_resource(
                "migrations/001_initial_schema.surql",
                ResourceKind::Migration,
                "DEFINE FIELD status ON TABLE booking TYPE string;",
            ),
    );

    let mock_module = Arc::new(MockTestModule::new("lyxal-booking", "1.0.0"));
    let install_counter = mock_module.install_count.clone();

    let package = ModulePackage::new(manifest, provider).with_module_impl(mock_module);

    // 1. Première installation réussie
    let report = runtime.install_package(package.clone()).await.unwrap();

    assert_eq!(report.module_id, ModuleId::new("lyxal-booking"));
    assert_eq!(report.version, "1.0.0");
    assert_eq!(report.outcome, ModuleInstallationOutcome::Installed);
    assert_eq!(report.schema_resources_count, 1);
    assert_eq!(report.migrations_applied, 1);
    assert_eq!(report.phase, InstallationPhase::Complete);
    assert_eq!(install_counter.load(Ordering::SeqCst), 1);

    // Vérifier l'état dans le Store
    let release = store
        .get_release(&ModuleId::new("lyxal-booking"), "1.0.0")
        .await
        .unwrap()
        .expect("Release must be persisted");
    assert_eq!(release.status, "Installed");

    // 2. Ré-installation idempotente
    let report2 = runtime.install_package(package).await.unwrap();
    assert_eq!(report2.outcome, ModuleInstallationOutcome::AlreadyInstalled);
    // Le hook d'installation ne doit pas avoir été ré-exécuté
    assert_eq!(install_counter.load(Ordering::SeqCst), 1);
}

#[tokio::test]
async fn test_installation_hook_failure_and_recovery() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_hook_failure")
        .use_db("test_hook_failure")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store.clone());

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-calendar"),
        name: "Lyxal Calendar".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: None,
        runtime: None,
        dependencies: Vec::new(),
        capabilities: Vec::new(),
    };

    let provider = Arc::new(
        MemoryTestResourceProvider::new()
            .add_resource(
                "schema/tables/calendar.surql",
                ResourceKind::Tables,
                "DEFINE TABLE calendar SCHEMALESS;",
            )
            .add_resource(
                "migrations/001_init.surql",
                ResourceKind::Migration,
                "DEFINE FIELD name ON TABLE calendar TYPE string;",
            ),
    );

    let mock_module = Arc::new(MockTestModule::new("lyxal-calendar", "1.0.0"));
    mock_module
        .should_fail_install
        .store(true, Ordering::SeqCst);

    let package = ModulePackage::new(manifest.clone(), provider.clone())
        .with_module_impl(mock_module.clone());

    // 1. Tentative avec échec au hook install()
    let err = runtime.install_package(package).await.unwrap_err();
    assert!(matches!(err, RuntimeError::ModuleInstallFailed { .. }));

    // Vérifier l'état dans le Store (doit être Failed à la phase InstallHook)
    let release = store
        .get_release(&ModuleId::new("lyxal-calendar"), "1.0.0")
        .await
        .unwrap()
        .expect("Release must exist");
    assert_eq!(release.status, ModuleReleaseStatus::Failed.as_str());
    assert_eq!(
        release.installation_phase.as_deref(),
        Some(InstallationPhase::InstallHook.as_str())
    );

    // 2. Réparation et nouvelle tentative (Recovery)
    mock_module
        .should_fail_install
        .store(false, Ordering::SeqCst);
    let package_recovered =
        ModulePackage::new(manifest, provider).with_module_impl(mock_module.clone());

    let report = runtime.install_package(package_recovered).await.unwrap();
    assert_eq!(report.outcome, ModuleInstallationOutcome::Recovered);
    assert_eq!(report.phase, InstallationPhase::Complete);

    let release_recovered = store
        .get_release(&ModuleId::new("lyxal-calendar"), "1.0.0")
        .await
        .unwrap()
        .unwrap();
    assert_eq!(
        release_recovered.status,
        ModuleReleaseStatus::Installed.as_str()
    );
}

#[tokio::test]
async fn test_missing_module_implementation_fails() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store);

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-crm"),
        name: "Lyxal CRM".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: None,
        runtime: None,
        dependencies: Vec::new(),
        capabilities: Vec::new(),
    };

    let provider = Arc::new(MemoryTestResourceProvider::new());
    // Package sans implémentation Rust
    let package = ModulePackage::new(manifest, provider);

    let err = runtime.install_package(package).await.unwrap_err();
    assert!(matches!(
        err,
        RuntimeError::ModuleImplementationMissing { .. }
    ));
}

#[tokio::test]
async fn test_incompatible_runtime_version_fails() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    // Runtime version = 0.1.0
    let runtime = LyxalRuntime::new(
        RuntimeConfig::default().with_runtime_version(Version::parse("0.1.0").unwrap()),
    )
    .with_client(client)
    .with_store(store);

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-future"),
        name: "Future Module".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: None,
        // Requiert Runtime >= 2.0.0
        runtime: Some(RuntimeRequirement {
            min_version: Some(VersionReq::parse(">=2.0.0").unwrap()),
        }),
        dependencies: Vec::new(),
        capabilities: Vec::new(),
    };

    let provider = Arc::new(MemoryTestResourceProvider::new());
    let mock = Arc::new(MockTestModule::new("lyxal-future", "1.0.0"));
    let package = ModulePackage::new(manifest, provider).with_module_impl(mock);

    let err = runtime.install_package(package).await.unwrap_err();
    assert!(matches!(
        err,
        RuntimeError::RuntimeVersionIncompatible { .. }
    ));
}

#[tokio::test]
async fn test_dependency_version_incompatibility_fails() {
    let client = connect("mem://").await.unwrap();
    client.use_ns("test").use_db("test").await.unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());

    // Déjà installé : lyxal-auth version 1.0.0
    store
        .register_release(
            &StoredModuleRelease::new("lyxal-auth", "1.0.0", 1, "Installed")
                .with_installation_phase("Complete"),
        )
        .await
        .unwrap();

    let runtime = LyxalRuntime::new(RuntimeConfig::default())
        .with_client(client)
        .with_store(store);

    let manifest = ModuleManifest {
        manifest_version: CURRENT_MANIFEST_VERSION,
        id: ModuleId::new("lyxal-admin"),
        name: "Admin".to_string(),
        version: Version::parse("1.0.0").unwrap(),
        description: None,
        runtime: None,
        // Requiert auth >= 2.0.0 (incompatible avec 1.0.0)
        dependencies: vec![ModuleDependency::with_version(
            "lyxal-auth",
            VersionReq::parse(">=2.0.0").unwrap(),
        )],
        capabilities: Vec::new(),
    };

    let provider = Arc::new(MemoryTestResourceProvider::new());
    let mock = Arc::new(MockTestModule::new("lyxal-admin", "1.0.0"));
    let package = ModulePackage::new(manifest, provider).with_module_impl(mock);

    let err = runtime.install_package(package).await.unwrap_err();
    assert!(matches!(
        err,
        RuntimeError::DependencyVersionIncompatible { .. }
    ));
}
