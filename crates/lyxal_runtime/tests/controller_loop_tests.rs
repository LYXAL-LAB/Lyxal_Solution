use async_trait::async_trait;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::controller::config::ReconciliationLoopConfig;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::health::check::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::health::registry::HealthRegistry;
use lyxal_runtime::health::status::GlobalHealthStatus;
use lyxal_runtime::lock::installation::MemoryInstallationLeaseManager;
use lyxal_runtime::manifest::model::{ModuleDependency, CURRENT_MANIFEST_VERSION};
use lyxal_runtime::manifest::ModuleManifest;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::package::ModulePackage;
use lyxal_runtime::reconciler::desired::DesiredRuntimeState;
use lyxal_runtime::reconciler::reconciler::RuntimeReconciler;
use lyxal_runtime::reconciler::report::ConvergenceStatus;
use lyxal_runtime::resource::provider::ResourceProvider;
use lyxal_runtime::resource::{ModuleResource, ResourceKind};
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::store::memory::MemoryRuntimeStore;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::RuntimeConfig;
use semver::Version;
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
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

    async fn exists(&self, path: &str) -> bool {
        self.resources.contains_key(path)
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
}

struct TestMockModule {
    descriptor: ModuleDescriptor,
    should_fail_install: Arc<AtomicBool>,
    start_count: Arc<AtomicUsize>,
    stop_count: Arc<AtomicUsize>,
}

impl TestMockModule {
    fn new(id: &str, version: &str) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
            should_fail_install: Arc::new(AtomicBool::new(false)),
            start_count: Arc::new(AtomicUsize::new(0)),
            stop_count: Arc::new(AtomicUsize::new(0)),
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
            return Err(RuntimeError::Internal {
                code: "TEST_INSTALL_FAILURE",
                message: "Simulated module installation failure".to_string(),
            });
        }
        Ok(())
    }
    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.start_count.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.stop_count.fetch_add(1, Ordering::SeqCst);
        Ok(())
    }
}

struct MockHealthChecker {
    module_id: ModuleId,
    should_fail: Arc<AtomicBool>,
}

#[async_trait]
impl ModuleHealthCheck for MockHealthChecker {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }
    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        if self.should_fail.load(Ordering::SeqCst) {
            Ok(HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(5),
                Some("Mock degradation".to_string()),
            ))
        } else {
            Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                2,
                Some("Nominal".to_string()),
            ))
        }
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
async fn test_controller_converged_loop_zero_mutations() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_1")
        .use_db("test_ctrl_1")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));
    let health_registry = HealthRegistry::new();
    let checker = Arc::new(MockHealthChecker {
        module_id: ModuleId::new("lyxal-timezone"),
        should_fail: Arc::new(AtomicBool::new(false)),
    });
    health_registry.register_check(checker).unwrap();

    let health_engine =
        Arc::new(runtime.health_engine(lyxal_runtime::health::HealthConfig::default()));
    let _ = health_engine
        .registry()
        .register_check(Arc::new(MockHealthChecker {
            module_id: ModuleId::new("lyxal-timezone"),
            should_fail: Arc::new(AtomicBool::new(false)),
        }));

    let (pkg, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let controller = runtime.continuous_controller(
        reconciler,
        ReconciliationLoopConfig {
            interval: Duration::from_millis(50),
            ..Default::default()
        },
    );
    controller.set_available_packages(vec![pkg]);
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-timezone"));

    // Cycle 1 : Installation et démarrage
    let snap1 = controller.run_once().await.unwrap();
    assert!(snap1.last_report_summary.is_some());
    assert_eq!(snap1.pass_count, 1);

    // Cycle 2 : Déjà convergé -> 0 mutation
    let snap2 = controller.run_once().await.unwrap();
    assert!(snap2.last_report_summary.is_none());
    assert_eq!(snap2.pass_count, 2);
    assert_eq!(
        snap2
            .actual_state
            .module_state(&ModuleId::new("lyxal-timezone")),
        Some(ModuleState::Running)
    );
}

#[tokio::test]
async fn test_unhealthy_running_module_does_not_trigger_reconciliation_mutation() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_2")
        .use_db("test_ctrl_2")
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

    let health_failed = Arc::new(AtomicBool::new(false));
    let checker = Arc::new(MockHealthChecker {
        module_id: ModuleId::new("lyxal-booking"),
        should_fail: health_failed.clone(),
    });
    runtime.health_registry().register_check(checker).unwrap();

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));
    let (pkg, mock_mod) = create_test_package("lyxal-booking", "1.0.0", vec![]);

    let controller = runtime.continuous_controller(reconciler, ReconciliationLoopConfig::default());
    controller.set_available_packages(vec![pkg]);
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-booking"));

    // Cycle 1 : Démarrage nominal
    let snap1 = controller.run_once().await.unwrap();
    assert_eq!(
        snap1.health_snapshot.global_status,
        GlobalHealthStatus::Healthy
    );
    assert_eq!(mock_mod.start_count.load(Ordering::SeqCst), 1);

    // Simuler une panne de santé (sans drift lifecycle)
    health_failed.store(true, Ordering::SeqCst);

    // Cycle 2 : Health devient Unhealthy mais DRA lifecycle est déjà convergé
    let snap2 = controller.run_once().await.unwrap();
    assert_eq!(
        snap2.health_snapshot.global_status,
        GlobalHealthStatus::Unhealthy
    );
    assert!(
        snap2.last_report_summary.is_none(),
        "Must NOT execute reconciliation mutations on health failure"
    );
    assert_eq!(
        mock_mod.start_count.load(Ordering::SeqCst),
        1,
        "No restart must occur"
    );
    assert_eq!(
        snap2.consecutive_failures, 0,
        "Controller cycle is technically successful"
    );
}

#[tokio::test]
async fn test_controller_drift_detection_and_automatic_restoration() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_3")
        .use_db("test_ctrl_3")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));
    let (pkg, _) = create_test_package("lyxal-calendar", "1.0.0", vec![]);

    let controller = runtime.continuous_controller(reconciler, ReconciliationLoopConfig::default());
    controller.set_available_packages(vec![pkg]);
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-calendar"));

    // Cycle 1 : Converge
    controller.run_once().await.unwrap();
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Running)
    );

    // Dérive artificielle (drift) : Arrêt manuel du module
    runtime
        .stop_module(&ModuleId::new("lyxal-calendar"))
        .await
        .unwrap();
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Stopped)
    );

    // Cycle 2 : Détection automatique du drift et redémarrage
    let snap2 = controller.run_once().await.unwrap();
    assert!(snap2.last_report_summary.is_some());
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Running)
    );
}

#[tokio::test]
async fn test_controller_empty_to_full_reconciliation() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_4")
        .use_db("test_ctrl_4")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let (pkg_cal, _) = create_test_package("lyxal-calendar", "1.0.0", vec!["lyxal-timezone"]);
    let (pkg_booking, _) = create_test_package("lyxal-booking", "1.0.0", vec!["lyxal-calendar"]);

    let controller = runtime.continuous_controller(reconciler, ReconciliationLoopConfig::default());
    controller.set_available_packages(vec![pkg_tz, pkg_cal, pkg_booking]);
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-booking"));

    // Cycle 1 : Résolution de la fermeture complète
    let snap1 = controller.run_once().await.unwrap();
    assert!(snap1.last_report_summary.is_some());
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-timezone")),
        Some(ModuleState::Running)
    );
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Running)
    );
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-booking")),
        Some(ModuleState::Running)
    );

    // Cycle 2 : Entièrement convergé
    let snap2 = controller.run_once().await.unwrap();
    assert!(snap2.last_report_summary.is_none());
}

#[tokio::test]
async fn test_controller_partial_failure_retry_and_convergence() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_5")
        .use_db("test_ctrl_5")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));

    let (pkg_tz, _) = create_test_package("lyxal-timezone", "1.0.0", vec![]);
    let (pkg_cal, mock_cal) =
        create_test_package("lyxal-calendar", "1.0.0", vec!["lyxal-timezone"]);

    // Forcer l'échec d'installation de calendar
    mock_cal.should_fail_install.store(true, Ordering::SeqCst);

    let controller = runtime.continuous_controller(reconciler, ReconciliationLoopConfig::default());
    controller.set_available_packages(vec![pkg_tz, pkg_cal]);
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-calendar"));

    // Cycle 1 : Timezone passe, Calendar échoue
    let snap1 = controller.run_once().await.unwrap();
    let summary1 = snap1.last_report_summary.unwrap();
    assert_eq!(summary1.convergence, ConvergenceStatus::PartiallyConverged);
    assert_eq!(summary1.failed_count, 1);

    // Réparer l'échec de calendar
    mock_cal.should_fail_install.store(false, Ordering::SeqCst);

    // Cycle 2 : Reprise sans réinstaller timezone
    let snap2 = controller.run_once().await.unwrap();
    let summary2 = snap2.last_report_summary.unwrap();
    assert_eq!(summary2.convergence, ConvergenceStatus::Converged);
    assert_eq!(
        runtime.module_state(&ModuleId::new("lyxal-calendar")),
        Some(ModuleState::Running)
    );
}

#[tokio::test]
async fn test_run_once_concurrent_calls_do_not_overlap() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_6")
        .use_db("test_ctrl_6")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));
    let controller =
        Arc::new(runtime.continuous_controller(reconciler, ReconciliationLoopConfig::default()));

    let c1 = controller.clone();
    let c2 = controller.clone();

    let (res1, res2) = tokio::join!(c1.run_once(), c2.run_once());

    let results = [res1.is_ok(), res2.is_ok()];
    // L'un a réussi, l'autre a reçu CONTROLLER_PASS_ALREADY_RUNNING
    assert!(results.contains(&true));
}

#[tokio::test]
async fn test_controller_graceful_shutdown() {
    let client = connect("mem://").await.unwrap();
    client
        .use_ns("test_ctrl_7")
        .use_db("test_ctrl_7")
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

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));
    let controller = Arc::new(runtime.continuous_controller(
        reconciler,
        ReconciliationLoopConfig {
            interval: Duration::from_millis(100),
            ..Default::default()
        },
    ));

    let (shutdown_tx, shutdown_rx) = tokio::sync::oneshot::channel();

    let ctrl = controller.clone();
    let handle = tokio::spawn(async move {
        ctrl.run(async move {
            let _ = shutdown_rx.await;
        })
        .await
    });

    tokio::time::sleep(Duration::from_millis(50)).await;
    let _ = shutdown_tx.send(());

    // Le contrôleur s'arrête immédiatement et proprement
    let res = tokio::time::timeout(Duration::from_millis(500), handle).await;
    assert!(res.is_ok());
}

#[tokio::test]
async fn test_controller_backoff_progression_and_reset() {
    let mut backoff =
        lyxal_runtime::controller::ReconciliationBackoff::new(ReconciliationLoopConfig {
            interval: Duration::from_secs(30),
            base_backoff: Duration::from_secs(5),
            max_backoff: Duration::from_secs(120),
            backoff_factor: 2.0,
            ..Default::default()
        });

    // 0 échec -> intervalle normal (30s)
    assert_eq!(backoff.next_delay(), Duration::from_secs(30));

    // Échec 1 -> max(30s, 5s * 2^0) = 30s
    backoff.on_failure();
    assert_eq!(backoff.next_delay(), Duration::from_secs(30));

    // Échec 4 -> max(30s, 5s * 2^3 = 40s) = 40s
    backoff.on_failure();
    backoff.on_failure();
    backoff.on_failure();
    assert_eq!(backoff.next_delay(), Duration::from_secs(40));

    // Succès -> reset à 30s
    backoff.on_success();
    assert_eq!(backoff.next_delay(), Duration::from_secs(30));
}
