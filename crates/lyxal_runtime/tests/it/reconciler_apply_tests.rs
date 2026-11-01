use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lock::installation::MemoryInstallationLeaseManager;
use lyxal_runtime::manifest::model::{ModuleDependency, CURRENT_MANIFEST_VERSION};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::reconciler::desired::DesiredRuntimeState;
use lyxal_runtime::reconciler::reconciler::RuntimeReconciler;
use lyxal_runtime::reconciler::report::{ConvergenceStatus, SkippedRevalidationReason};
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::memory::MemoryRuntimeStore;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::RuntimeConfig;
use semver::Version;
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

struct TestMockModule {
    descriptor: ModuleDescriptor,
    should_fail_install: Arc<AtomicBool>,
}

impl TestMockModule {
    fn new(id: &str, version: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
            should_fail_install: Arc::new(AtomicBool::new(false)),
        }
    }
}

#[async_trait]
impl LyxalModule for TestMockModule {
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

fn create_test_package(
    id: &str,
    version: &str,
    deps: Vec<&str>,
) -> (ModulePackage, Arc<TestMockModule>) {
    let dependencies = deps.into_iter().map(ModuleDependency::new).collect();

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

    let mock = Arc::new(TestMockModule::new(id, version));
    let pkg = ModulePackage::new(manifest, provider).with_module_impl(mock.clone());
    (pkg, mock)
}

#[tokio::test]
async fn test_apply_empty_to_full_convergence() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_rec_apply_1")
        .use_db("test_rec_apply_1")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = Arc::new(
        LyxalRuntime::new(RuntimeConfig::default())
            .with_client(client)
            .with_store(store.clone())
            .with_installation_lease_manager(lease_mgr),
    );

    let reconciler = RuntimeReconciler::new(runtime.clone());

    // Graphe de dépendances officiel :
    // timezone
    // scheduler -> timezone
    // calendar -> timezone
    // booking -> calendar + scheduler
    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let (pkg_sched, _) = create_test_package("lyxal-scheduler", "1.0.0", vec!["lyxal-timezone"]);
    let (pkg_cal, _) = create_test_package("lyxal-calendar", "1.0.0", vec!["lyxal-timezone"]);
    let (pkg_booking, _) = create_test_package(
        "lyxal-booking",
        "1.0.0",
        vec!["lyxal-calendar", "lyxal-scheduler"],
    );

    let available = vec![pkg_booking, pkg_cal, pkg_sched, pkg_tz];

    // L'appelant déclare UNIQUEMENT : booking Running
    let desired = DesiredRuntimeState::new().running("lyxal-booking");

    // 1. Première passe de réconciliation
    let report = reconciler.reconcile(&desired, &available).await.unwrap();

    assert_eq!(report.convergence, ConvergenceStatus::Converged);
    assert_eq!(report.executed.len(), 8); // 4 Installs + 4 Starts
    assert!(report.failed.is_empty());
    assert!(report.not_attempted.is_empty());
    assert!(report.remaining_drift.is_empty());

    // Vérifier que tous les 4 modules sont effectivement Running dans le runtime
    for id in &[
        "lyxal-timezone",
        "lyxal-scheduler",
        "lyxal-calendar",
        "lyxal-booking",
    ] {
        assert_eq!(
            runtime.module_state(&ModuleId::new(*id)),
            Some(ModuleState::Running)
        );
    }

    // 2. Deuxième passe immédiate : IDEMPOTENCE ABSOLUE (0 mutation)
    let report2 = reconciler.reconcile(&desired, &available).await.unwrap();
    assert_eq!(report2.convergence, ConvergenceStatus::Converged);
    assert_eq!(report2.planned_actions, 0);
    assert_eq!(report2.executed.len(), 0);
    assert!(report2.remaining_drift.is_empty());
}

#[tokio::test]
async fn test_stop_booking_while_calendar_running() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_rec_apply_2")
        .use_db("test_rec_apply_2")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = Arc::new(
        LyxalRuntime::new(RuntimeConfig::default())
            .with_client(client)
            .with_store(store.clone())
            .with_installation_lease_manager(lease_mgr),
    );

    let reconciler = RuntimeReconciler::new(runtime.clone());

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let (pkg_cal, _) = create_test_package("lyxal-calendar", "1.0.0", vec!["lyxal-timezone"]);
    let (pkg_booking, _) = create_test_package("lyxal-booking", "1.0.0", vec!["lyxal-calendar"]);

    let available = vec![pkg_booking, pkg_cal, pkg_tz];

    // Initialisation : booking Running
    let desired_initial = DesiredRuntimeState::new().running("lyxal-booking");
    reconciler
        .reconcile(&desired_initial, &available)
        .await
        .unwrap();

    // Changement d'état souhaité : booking Stopped, calendar Running
    let desired_stop = DesiredRuntimeState::new()
        .stopped("lyxal-booking")
        .running("lyxal-calendar");

    let report = reconciler
        .reconcile(&desired_stop, &available)
        .await
        .unwrap();

    assert_eq!(report.convergence, ConvergenceStatus::Converged);
    assert_eq!(report.executed.len(), 1); // Seul 1 Stop de booking
    assert_eq!(report.executed[0].module_id, ModuleId::new("lyxal-booking"));

    // booking est Stopped, calendar et timezone restent Running
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-booking")),
        Some(ModuleState::Stopped)
    );
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Running)
    );
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-timezone")),
        Some(ModuleState::Running)
    );
}

#[tokio::test]
async fn test_partial_failure_and_not_attempted_reporting() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_rec_apply_3")
        .use_db("test_rec_apply_3")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = Arc::new(
        LyxalRuntime::new(RuntimeConfig::default())
            .with_client(client)
            .with_store(store.clone())
            .with_installation_lease_manager(lease_mgr),
    );

    let reconciler = RuntimeReconciler::new(runtime.clone());

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let (pkg_cal, mock_cal) =
        create_test_package("lyxal-calendar", "1.0.0", vec!["lyxal-timezone"]);
    let (pkg_booking, _) = create_test_package("lyxal-booking", "1.0.0", vec!["lyxal-calendar"]);

    // Simuler un échec à l'installation de calendar
    mock_cal.should_fail_install.store(true, Ordering::SeqCst);

    let available = vec![pkg_booking, pkg_cal, pkg_tz];
    let desired = DesiredRuntimeState::new().running("lyxal-booking");

    let report = reconciler.reconcile(&desired, &available).await.unwrap();

    assert_eq!(report.convergence, ConvergenceStatus::PartiallyConverged);
    // timezone a été installé et démarré avec succès
    assert!(report
        .executed
        .iter()
        .any(|e| e.module_id == ModuleId::new("lyxal-timezone") && e.success));
    // calendar a échoué
    assert_eq!(report.failed.len(), 1);
    assert_eq!(report.failed[0].module_id, ModuleId::new("lyxal-calendar"));
    // booking n'a pas été tenté en raison de l'échec de sa dépendance calendar
    assert!(!report.not_attempted.is_empty());
    assert_eq!(
        report.not_attempted[0].module_id,
        ModuleId::new("lyxal-booking")
    );
}

#[tokio::test]
async fn test_revalidation_already_converged_is_successful_skip() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_rec_apply_4")
        .use_db("test_rec_apply_4")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = Arc::new(
        LyxalRuntime::new(RuntimeConfig::default())
            .with_client(client)
            .with_store(store.clone())
            .with_installation_lease_manager(lease_mgr),
    );

    let reconciler = RuntimeReconciler::new(runtime.clone());

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let available = vec![pkg_tz.clone()];
    let desired = DesiredRuntimeState::new().running("lyxal-timezone");

    // 1. Calcul du plan (planifie Install + Start)
    let plan = reconciler.plan(&desired, &available).await.unwrap();
    assert_eq!(plan.actions.len(), 2);

    // 2. Interférence : installation et démarrage manuels avant apply
    runtime.install_package(pkg_tz).await.unwrap();
    runtime
        .start_module(&ModuleId::new("lyxal-timezone"))
        .await
        .unwrap();

    // 3. Application du plan : les actions doivent être ignorées avec AlreadyConverged
    let report = reconciler.apply(plan, &available, &desired).await.unwrap();

    assert_eq!(report.convergence, ConvergenceStatus::Converged);
    assert_eq!(report.skipped_revalidation.len(), 2);
    assert_eq!(
        report.skipped_revalidation[0].reason,
        SkippedRevalidationReason::AlreadyConverged
    );
    assert_eq!(
        report.skipped_revalidation[1].reason,
        SkippedRevalidationReason::AlreadyConverged
    );
}

#[tokio::test]
async fn test_revalidation_failed_state_is_not_silent_skip() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_rec_apply_5")
        .use_db("test_rec_apply_5")
        .await
        .unwrap();

    let store = Arc::new(MemoryRuntimeStore::new());
    let lease_mgr = Arc::new(MemoryInstallationLeaseManager::new());

    let runtime = Arc::new(
        LyxalRuntime::new(RuntimeConfig::default())
            .with_client(client)
            .with_store(store.clone())
            .with_installation_lease_manager(lease_mgr),
    );

    let reconciler = RuntimeReconciler::new(runtime.clone());

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let available = vec![pkg_tz.clone()];
    let desired = DesiredRuntimeState::new().running("lyxal-timezone");

    // Installer le module pour qu'il soit dans l'état Installed
    runtime.install_package(pkg_tz).await.unwrap();

    // Calculer le plan (Start)
    let plan = reconciler.plan(&desired, &available).await.unwrap();
    assert_eq!(plan.actions.len(), 1);

    // Forcer l'état du module en Failed dans le lifecycle
    // (en tentant un start avec une dépendance absente ou transition)
    // On peut simuler l'état d'échec
    let desc = ModuleDescriptor::new("lyxal-timezone", "1.0.0");
    runtime
        .lifecycle()
        .register_state(ModuleId::new("lyxal-timezone"));
    let mock_failed: Arc<dyn LyxalModule> = Arc::new(TestMockModule {
        descriptor: desc,
        should_fail_install: Arc::new(AtomicBool::new(true)),
    });
    let _ = runtime
        .lifecycle()
        .install_module(
            &mock_failed,
            &lyxal_runtime::context::ModuleContext::new("lyxal-timezone"),
        )
        .await;

    // L'application du plan ne doit PAS ignorer silencieusement, elle doit remonter l'erreur !
    let report = reconciler.apply(plan, &available, &desired).await.unwrap();
    assert!(
        !report.failed.is_empty(),
        "Failed state must not be silently skipped during revalidation"
    );
}
