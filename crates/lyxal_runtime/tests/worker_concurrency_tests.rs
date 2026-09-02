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

struct ConcurrentWorker {
    descriptor: WorkerDescriptor,
    active_instances: Arc<AtomicUsize>,
    total_launches: Arc<AtomicUsize>,
}

impl ConcurrentWorker {
    fn new(module_id: &str, name: &str) -> (Self, Arc<AtomicUsize>, Arc<AtomicUsize>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let active = Arc::new(AtomicUsize::new(0));
        let total = Arc::new(AtomicUsize::new(0));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name)
                    .with_restart_policy(RestartPolicy::Never)
                    .with_shutdown_timeout(Duration::from_millis(500)),
                active_instances: active.clone(),
                total_launches: total.clone(),
            },
            active,
            total,
        )
    }
}

#[async_trait]
impl LyxalWorker for ConcurrentWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.active_instances.fetch_add(1, Ordering::SeqCst);
        self.total_launches.fetch_add(1, Ordering::SeqCst);

        while !ctx.is_cancelled() {
            sleep(Duration::from_millis(10)).await;
        }

        self.active_instances.fetch_sub(1, Ordering::SeqCst);
        Ok(())
    }
}

struct ResurrectingFlakyWorker {
    descriptor: WorkerDescriptor,
    runs: Arc<AtomicUsize>,
}

impl ResurrectingFlakyWorker {
    fn new(module_id: &str, name: &str) -> (Self, Arc<AtomicUsize>) {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        let runs = Arc::new(AtomicUsize::new(0));
        (
            Self {
                descriptor: WorkerDescriptor::new(id, mod_id, name)
                    .with_restart_policy(RestartPolicy::Always {
                        max_retries: Some(10),
                        backoff: WorkerRestartBackoff::new(
                            Duration::from_millis(300),
                            Duration::from_millis(500),
                            1.5,
                        ),
                    })
                    .with_shutdown_timeout(Duration::from_millis(100)),
                runs: runs.clone(),
            },
            runs,
        )
    }
}

#[async_trait]
impl LyxalWorker for ResurrectingFlakyWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let count = self.runs.fetch_add(1, Ordering::SeqCst) + 1;
        if count == 1 {
            // Premier run échoue immédiatement pour déclencher un sommeil de restart
            Err(RuntimeError::Internal {
                code: "FIRST_FAIL",
                message: "First run failure".to_string(),
            })
        } else {
            while !ctx.is_cancelled() {
                sleep(Duration::from_millis(10)).await;
            }
            Ok(())
        }
    }
}

#[tokio::test]
async fn test_concurrent_start_single_joinhandle() {
    let registry = Arc::new(WorkerRegistry::new());
    let (worker, active, total) = ConcurrentWorker::new("lyxal-notification", "concurrent_test");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = Arc::new(WorkerSupervisor::new(registry, node_id));

    // 10 appels simultanés à start_worker
    let mut handles = Vec::new();
    for _ in 0..10 {
        let sup = supervisor.clone();
        let wid = worker_id.clone();
        handles.push(tokio::spawn(async move { sup.start_worker(&wid).await }));
    }

    for h in handles {
        let res = h.await.unwrap();
        assert!(res.is_ok());
    }

    sleep(Duration::from_millis(50)).await;

    // Invariant Single Worker Instance : Exactement 1 instance active et 1 lancement total
    assert_eq!(active.load(Ordering::SeqCst), 1);
    assert_eq!(total.load(Ordering::SeqCst), 1);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Running));

    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(active.load(Ordering::SeqCst), 0);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_start_stop_race_final_state_consistent() {
    let registry = Arc::new(WorkerRegistry::new());
    let (worker, active, _) = ConcurrentWorker::new("lyxal-notification", "race_test");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = Arc::new(WorkerSupervisor::new(registry, node_id));

    // Déclenchements concurrents de start et stop
    for _ in 0..5 {
        let sup1 = supervisor.clone();
        let wid1 = worker_id.clone();
        let sup2 = supervisor.clone();
        let wid2 = worker_id.clone();

        let _ = tokio::join!(
            tokio::spawn(async move { sup1.start_worker(&wid1).await }),
            tokio::spawn(async move { sup2.stop_worker(&wid2).await })
        );
    }

    // Assurer l'arrêt final
    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(active.load(Ordering::SeqCst), 0);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_stale_restart_epoch_cannot_resurrect_worker() {
    let registry = Arc::new(WorkerRegistry::new());
    let (worker, runs) = ResurrectingFlakyWorker::new("lyxal-notification", "anti_resurrect");
    let worker_id = worker.descriptor().id.clone();
    registry.register(Arc::new(worker)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);

    supervisor.start_worker(&worker_id).await.unwrap();

    // Attendre que le worker échoue et passe à l'état Restarting (sommeil de 300ms)
    sleep(Duration::from_millis(50)).await;
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Restarting));

    // Arrêt du worker pendant le sommeil (incrémentation de génération)
    supervisor.stop_worker(&worker_id).await.unwrap();
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));

    // Attendre que le timer de 300ms expire
    sleep(Duration::from_millis(400)).await;

    // Invariant No Zombie : Le worker ne doit JAMAIS avoir exécuté son 2ème run
    assert_eq!(runs.load(Ordering::SeqCst), 1);
    assert_eq!(supervisor.state(&worker_id), Some(WorkerState::Stopped));
}

#[tokio::test]
async fn test_stop_module_cancels_pending_restart() {
    let registry = Arc::new(WorkerRegistry::new());
    let (w1, r1) = ResurrectingFlakyWorker::new("lyxal-notification", "w1");
    let (w2, r2) = ResurrectingFlakyWorker::new("lyxal-notification", "w2");
    registry.register(Arc::new(w1)).unwrap();
    registry.register(Arc::new(w2)).unwrap();

    let node_id = NodeId::new("test-node");
    let supervisor = WorkerSupervisor::new(registry, node_id);
    let mod_id = ModuleId::new("lyxal-notification");

    supervisor.start_module_workers(&mod_id).await.unwrap();

    sleep(Duration::from_millis(50)).await;

    // Arrêt global de tous les workers du module
    supervisor.stop_module_workers(&mod_id).await.unwrap();

    let states = supervisor.all_states();
    for (id, state) in states {
        if id.module_id() == mod_id {
            assert_eq!(state, WorkerState::Stopped);
        }
    }

    // Attendre l'expiration potentielle des backoffs
    sleep(Duration::from_millis(400)).await;

    assert_eq!(r1.load(Ordering::SeqCst), 1);
    assert_eq!(r2.load(Ordering::SeqCst), 1);
}
