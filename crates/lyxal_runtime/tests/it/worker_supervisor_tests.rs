use async_trait::async_trait;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    LyxalWorker, MemoryWorkerStore, RestartPolicy, WorkerContext, WorkerDescriptor, WorkerId,
    WorkerRegistry, WorkerState, WorkerStore, WorkerSupervisor,
};
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

struct InfiniteWorker {
    descriptor: WorkerDescriptor,
    ran: Arc<AtomicBool>,
}

impl InfiniteWorker {
    fn new(module_id: &str, name: &str) -> (Self, Arc<AtomicBool>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let ran = Arc::new(AtomicBool::new(false));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name)
                    .with_restart_policy(RestartPolicy::Never)
                    .with_shutdown_timeout(Duration::from_millis(500)),
                ran: ran.clone(),
            },
            ran,
        )
    }
}

#[async_trait]
impl LyxalWorker for InfiniteWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.ran.store(true, Ordering::SeqCst);
        while !ctx.is_cancelled() {
            sleep(Duration::from_millis(10)).await;
        }
        Ok(())
    }
}

struct StubbornWorker {
    descriptor: WorkerDescriptor,
}

impl StubbornWorker {
    fn new(module_id: &str, name: &str) -> Self {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        Self {
            descriptor: WorkerDescriptor::new(id, mod_id, name)
                .with_restart_policy(RestartPolicy::Never)
                .with_shutdown_timeout(Duration::from_millis(50)), // court timeout
        }
    }
}

#[async_trait]
impl LyxalWorker for StubbornWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        // Ignore le signal d'annulation et dort indéfiniment
        loop {
            sleep(Duration::from_secs(60)).await;
        }
    }
}

struct FailingWorker {
    descriptor: WorkerDescriptor,
}

impl FailingWorker {
    fn new(module_id: &str, name: &str) -> Self {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        Self {
            descriptor: WorkerDescriptor::new(id, mod_id, name)
                .with_restart_policy(RestartPolicy::Never),
        }
    }
}

#[async_trait]
impl LyxalWorker for FailingWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        sleep(Duration::from_millis(10)).await;
        Err(RuntimeError::Internal {
            code: "RUNTIME_CUSTOM_ERROR",
            message: "Simulated worker explosion".to_string(),
        })
    }
}

struct PanickingWorker {
    descriptor: WorkerDescriptor,
}

impl PanickingWorker {
    fn new(module_id: &str, name: &str) -> Self {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        Self {
            descriptor: WorkerDescriptor::new(id, mod_id, name)
                .with_restart_policy(RestartPolicy::Never),
        }
    }
}

#[async_trait]
impl LyxalWorker for PanickingWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        sleep(Duration::from_millis(10)).await;
        panic!("Boom! Worker panicked intentionally");
    }
}

struct QuickOkWorker {
    descriptor: WorkerDescriptor,
    run_count: Arc<AtomicUsize>,
}

impl QuickOkWorker {
    fn new(module_id: &str, name: &str) -> (Self, Arc<AtomicUsize>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let run_count = Arc::new(AtomicUsize::new(0));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name)
                    .with_restart_policy(RestartPolicy::Never),
                run_count: run_count.clone(),
            },
            run_count,
        )
    }
}

#[async_trait]
impl LyxalWorker for QuickOkWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.run_count.fetch_add(1, Ordering::SeqCst);
        sleep(Duration::from_millis(10)).await;
        Ok(())
    }
}

#[tokio::test]
async fn test_start_and_stop_worker_gracefully() {
    let registry = Arc::new(WorkerRegistry::new());
    let (worker, ran) = InfiniteWorker::new("lyxal-notification", "delivery");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Registered));

    supervisor.start_worker(&worker_id).await.unwrap();

    sleep(Duration::from_millis(50)).await;
    assert!(ran.load(Ordering::SeqCst));
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Running));

    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_worker_stop_timeout_forces_abort() {
    let registry = Arc::new(WorkerRegistry::new());
    let worker = StubbornWorker::new("lyxal-notification", "stubborn");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();
    sleep(Duration::from_millis(20)).await;

    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Running));

    // L'arrêt doit déclencher l'abort après 50ms et terminer promptement
    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_worker_error_is_detected() {
    let registry = Arc::new(WorkerRegistry::new());
    let worker = FailingWorker::new("lyxal-notification", "failing");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    // Attendre que le worker s'exécute et échoue
    sleep(Duration::from_millis(80)).await;

    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Failed));

    let metrics = supervisor.metrics(&worker_id).unwrap();
    assert_eq!(metrics.failure_count, 1);
    assert!(metrics
        .last_error
        .unwrap()
        .contains("Simulated worker explosion"));
}

#[tokio::test]
async fn test_worker_panic_is_isolated() {
    let registry = Arc::new(WorkerRegistry::new());
    let worker = PanickingWorker::new("lyxal-notification", "panicking");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    // Attendre que la panique soit interceptée sans crasher le test
    sleep(Duration::from_millis(80)).await;

    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Failed));

    let metrics = supervisor.metrics(&worker_id).unwrap();
    assert_eq!(metrics.failure_count, 1);
    assert!(metrics
        .last_error
        .unwrap()
        .contains("Worker panicked intentionally"));
}

#[tokio::test]
async fn test_worker_ok_without_cancellation_semantics() {
    let registry = Arc::new(WorkerRegistry::new());
    let (worker, count) = QuickOkWorker::new("lyxal-notification", "quick");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();
    sleep(Duration::from_millis(60)).await;

    assert_eq!(count.load(Ordering::SeqCst), 1);
    // RestartPolicy::Never avec Ok(()) -> Stopped propre (Completed)
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_worker_exit_reason_is_persisted() {
    let store = Arc::new(MemoryWorkerStore::new());
    let registry = Arc::new(WorkerRegistry::new());
    let worker = FailingWorker::new("lyxal-notification", "persisted_fail");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id.clone()).with_store(store.clone());

    supervisor.start_worker(&worker_id).await.unwrap();
    sleep(Duration::from_millis(80)).await;

    let row = store
        .get_worker(&node_id, &worker_id)
        .await
        .unwrap()
        .unwrap();
    assert_eq!(row.state, "failed");
    assert_eq!(row.failure_count, 1);
    assert!(row
        .last_error
        .unwrap()
        .contains("Simulated worker explosion"));
}
