use async_trait::async_trait;
use lyxal_runtime::config::RuntimeConfig;
use lyxal_runtime::context::ModuleContext;
use lyxal_runtime::descriptor::ModuleDescriptor;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::health::status::HealthStatus;
use lyxal_runtime::module::LyxalModule;
use lyxal_runtime::reconciler::desired::DesiredRuntimeState;
use lyxal_runtime::reconciler::reconciler::RuntimeReconciler;
use lyxal_runtime::runtime::LyxalRuntime;
use lyxal_runtime::types::{ModuleId, ModuleState};
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerState,
};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

struct MockModule {
    descriptor: ModuleDescriptor,
    stop_called_after_workers: Arc<AtomicBool>,
}

impl MockModule {
    fn new(id: &str, stop_flag: Arc<AtomicBool>) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, "1.0.0"),
            stop_called_after_workers: stop_flag,
        }
    }
}

#[async_trait]
impl LyxalModule for MockModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        self.stop_called_after_workers.store(true, Ordering::SeqCst);
        Ok(())
    }
}

struct TrackingWorker {
    descriptor: WorkerDescriptor,
    is_running: Arc<AtomicBool>,
}

impl TrackingWorker {
    fn new(
        module_id: &str,
        name: &str,
        criticality: WorkerCriticality,
        policy: RestartPolicy,
    ) -> (Self, Arc<AtomicBool>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let is_running = Arc::new(AtomicBool::new(false));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name)
                    .with_criticality(criticality)
                    .with_restart_policy(policy)
                    .with_shutdown_timeout(Duration::from_millis(200)),
                is_running: is_running.clone(),
            },
            is_running,
        )
    }
}

#[async_trait]
impl LyxalWorker for TrackingWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.is_running.store(true, Ordering::SeqCst);
        while !ctx.is_cancelled() {
            sleep(Duration::from_millis(10)).await;
        }
        self.is_running.store(false, Ordering::SeqCst);
        Ok(())
    }
}

struct ErrorWorker {
    descriptor: WorkerDescriptor,
}

impl ErrorWorker {
    fn new(module_id: &str, name: &str, criticality: WorkerCriticality) -> Self {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        Self {
            descriptor: WorkerDescriptor::new(id, mod_id, name)
                .with_criticality(criticality)
                .with_restart_policy(RestartPolicy::Never),
        }
    }
}

#[async_trait]
impl LyxalWorker for ErrorWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        sleep(Duration::from_millis(10)).await;
        Err(RuntimeError::Internal {
            code: "WORKER_FAILED",
            message: "Worker failed intentionally".to_string(),
        })
    }
}

#[tokio::test]
async fn test_start_and_stop_module_orchestrates_workers() {
    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    let stop_flag = Arc::new(AtomicBool::new(false));
    let module = Arc::new(MockModule::new("lyxal-notification", stop_flag.clone()));
    let mod_id = ModuleId::new("lyxal-notification");

    let (worker, worker_running) = TrackingWorker::new(
        "lyxal-notification",
        "delivery",
        WorkerCriticality::Required,
        RestartPolicy::Never,
    );
    let worker_id = worker.descriptor().id.clone();

    runtime.register(module).unwrap();
    runtime.register_worker(Arc::new(worker)).unwrap();

    // Module passe de Registered à Installed
    runtime.install_all().await.unwrap();

    // Start module démarre aussi ses workers
    runtime.start_module(&mod_id).await.unwrap();

    sleep(Duration::from_millis(50)).await;

    assert_eq!(runtime.module_state(&mod_id), Some(ModuleState::Running));
    assert!(worker_running.load(Ordering::SeqCst));
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Running)
    );

    // Stop module arrête les workers avant module.stop()
    runtime.stop_module(&mod_id).await.unwrap();

    assert_eq!(runtime.module_state(&mod_id), Some(ModuleState::Stopped));
    assert!(!worker_running.load(Ordering::SeqCst));
    assert_eq!(
        runtime.worker_supervisor().state(&worker_id),
        Some(WorkerState::Stopped)
    );
    assert!(stop_flag.load(Ordering::SeqCst));
}

#[tokio::test]
async fn test_required_worker_failure_affects_health() {
    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    let stop_flag = Arc::new(AtomicBool::new(false));
    let module = Arc::new(MockModule::new("lyxal-notification", stop_flag));
    let mod_id = ModuleId::new("lyxal-notification");

    let worker = ErrorWorker::new(
        "lyxal-notification",
        "required_fail",
        WorkerCriticality::Required,
    );

    runtime.register(module).unwrap();
    runtime.register_worker(Arc::new(worker)).unwrap();

    runtime.install_all().await.unwrap();
    runtime.start_module(&mod_id).await.unwrap();

    // Attendre l'échec du worker
    sleep(Duration::from_millis(50)).await;

    let ctx = ModuleContext::new(mod_id.clone());
    let health_engine = runtime.health_engine(Default::default());
    let health = health_engine.check_module(&mod_id, &ctx).await;

    // Worker Required en Failed -> Module Unhealthy
    assert_eq!(health.status, HealthStatus::Unhealthy);
    assert!(health
        .message
        .unwrap()
        .contains("Required worker 'lyxal-notification:required_fail' failed"));
}

#[tokio::test]
async fn test_optional_worker_failure_degrades_health() {
    let runtime = LyxalRuntime::new(RuntimeConfig::default());
    let stop_flag = Arc::new(AtomicBool::new(false));
    let module = Arc::new(MockModule::new("lyxal-webhook", stop_flag));
    let mod_id = ModuleId::new("lyxal-webhook");

    let worker = ErrorWorker::new(
        "lyxal-webhook",
        "optional_fail",
        WorkerCriticality::Optional,
    );

    runtime.register(module).unwrap();
    runtime.register_worker(Arc::new(worker)).unwrap();

    runtime.install_all().await.unwrap();
    runtime.start_module(&mod_id).await.unwrap();

    sleep(Duration::from_millis(50)).await;

    let ctx = ModuleContext::new(mod_id.clone());
    let health_engine = runtime.health_engine(Default::default());
    let health = health_engine.check_module(&mod_id, &ctx).await;

    // Worker Optional en Failed -> Module Degraded
    assert_eq!(health.status, HealthStatus::Degraded);
    assert!(health
        .message
        .unwrap()
        .contains("Optional worker 'lyxal-webhook:optional_fail' failed"));
}

#[tokio::test]
async fn test_controller_observes_worker_state() {
    let runtime = Arc::new(LyxalRuntime::new(RuntimeConfig::default()));
    let stop_flag = Arc::new(AtomicBool::new(false));
    let module = Arc::new(MockModule::new("lyxal-notification", stop_flag));
    let mod_id = ModuleId::new("lyxal-notification");

    let (worker, _) = TrackingWorker::new(
        "lyxal-notification",
        "delivery",
        WorkerCriticality::Required,
        RestartPolicy::Never,
    );
    let worker_id = worker.descriptor().id.clone();

    runtime.register(module).unwrap();
    runtime.register_worker(Arc::new(worker)).unwrap();

    runtime.install_all().await.unwrap();
    runtime.start_module(&mod_id).await.unwrap();

    let reconciler = Arc::new(RuntimeReconciler::new(runtime.clone()));

    let controller = runtime.continuous_controller(reconciler, Default::default());
    controller.set_desired_state(DesiredRuntimeState::new().running("lyxal-notification"));

    let snapshot = controller.run_once().await.unwrap();

    // Le snapshot du controller contient l'état exact des workers
    assert_eq!(
        snapshot.worker_states.get(&worker_id),
        Some(&WorkerState::Running)
    );
    assert!(snapshot.worker_health.contains_key(&worker_id));
}
