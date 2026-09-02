use async_trait::async_trait;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::lock::node_id::NodeId;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerDescriptor, WorkerId, WorkerRegistry,
    WorkerRestartBackoff, WorkerState, WorkerSupervisor,
};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

struct FlakyWorker {
    descriptor: WorkerDescriptor,
    attempts: Arc<AtomicUsize>,
    fail_until: usize,
}

impl FlakyWorker {
    fn new(
        module_id: &str,
        name: &str,
        fail_until: usize,
        policy: RestartPolicy,
    ) -> (Self, Arc<AtomicUsize>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let attempts = Arc::new(AtomicUsize::new(0));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name).with_restart_policy(policy),
                attempts: attempts.clone(),
                fail_until,
            },
            attempts,
        )
    }
}

#[async_trait]
impl LyxalWorker for FlakyWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let current = self.attempts.fetch_add(1, Ordering::SeqCst) + 1;
        if current <= self.fail_until {
            Err(RuntimeError::Internal {
                code: "FLAKY_ERROR",
                message: format!("Fail on attempt {}", current),
            })
        } else {
            while !ctx.is_cancelled() {
                sleep(Duration::from_millis(10)).await;
            }
            Ok(())
        }
    }
}

#[test]
fn test_restart_backoff_progression() {
    let backoff =
        WorkerRestartBackoff::new(Duration::from_millis(100), Duration::from_millis(800), 2.0);

    assert_eq!(backoff.calculate_delay(1), Duration::from_millis(100));
    assert_eq!(backoff.calculate_delay(2), Duration::from_millis(200));
    assert_eq!(backoff.calculate_delay(3), Duration::from_millis(400));
    assert_eq!(backoff.calculate_delay(4), Duration::from_millis(800));
    assert_eq!(backoff.calculate_delay(5), Duration::from_millis(800)); // Cap reached
}

#[tokio::test]
async fn test_restart_policy_on_failure_recovers() {
    let registry = Arc::new(WorkerRegistry::new());
    let policy = RestartPolicy::OnFailure {
        max_retries: 3,
        backoff: WorkerRestartBackoff::new(
            Duration::from_millis(20),
            Duration::from_millis(50),
            1.5,
        ),
    };
    let (worker, attempts) = FlakyWorker::new("lyxal-notification", "flaky", 2, policy);
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    // Attendre que le worker échoue 2 fois et redémarre avec succès la 3ème fois
    sleep(Duration::from_millis(200)).await;

    assert_eq!(attempts.load(Ordering::SeqCst), 3);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Running));

    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_restart_policy_max_retries_exhausted() {
    let registry = Arc::new(WorkerRegistry::new());
    let policy = RestartPolicy::OnFailure {
        max_retries: 2,
        backoff: WorkerRestartBackoff::new(
            Duration::from_millis(10),
            Duration::from_millis(30),
            1.5,
        ),
    };
    // Le worker échoue toujours (fail_until: 10 > max_retries: 2)
    let (worker, attempts) = FlakyWorker::new("lyxal-notification", "always_fails", 10, policy);
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    sleep(Duration::from_millis(200)).await;

    // 1ère exécution + 2 redémarrages = 3 tentatives totales
    assert_eq!(attempts.load(Ordering::SeqCst), 3);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Failed));
}

#[tokio::test]
async fn test_restart_is_cancelled_on_shutdown() {
    let registry = Arc::new(WorkerRegistry::new());
    let policy = RestartPolicy::OnFailure {
        max_retries: 5,
        backoff: WorkerRestartBackoff::new(
            Duration::from_millis(500), // long backoff
            Duration::from_secs(5),
            2.0,
        ),
    };
    let (worker, attempts) = FlakyWorker::new("lyxal-notification", "long_backoff", 10, policy);
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    // Attendre le 1er échec -> état Restarting
    sleep(Duration::from_millis(50)).await;
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Restarting));

    // Arrêter le worker pendant qu'il dort dans son backoff
    supervisor.stop_worker(&worker_id).await.unwrap();

    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));

    // Attendre un peu plus que le timer de 500ms
    sleep(Duration::from_millis(600)).await;

    // Le worker n'a pas été relancé (resté à 1 tentative)
    assert_eq!(attempts.load(Ordering::SeqCst), 1);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}
