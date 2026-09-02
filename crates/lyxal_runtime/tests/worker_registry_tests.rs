use async_trait::async_trait;
use lyxal_runtime::error::RuntimeError;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    LyxalWorker, WorkerContext, WorkerDescriptor, WorkerId, WorkerRegistry,
};
use std::sync::Arc;

struct TestWorker {
    descriptor: WorkerDescriptor,
}

impl TestWorker {
    fn new(module_id: &str, name: &str) -> Self {
        let mod_id = ModuleId::new(module_id);
        let id = WorkerId::new(&mod_id, name).unwrap();
        Self {
            descriptor: WorkerDescriptor::new(id, mod_id, name),
        }
    }
}

#[async_trait]
impl LyxalWorker for TestWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, _ctx: WorkerContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

#[test]
fn test_worker_registration() {
    let registry = WorkerRegistry::new();
    let worker = Arc::new(TestWorker::new("lyxal-notification", "delivery"));

    assert_eq!(registry.count(), 0);
    assert!(!registry.contains(&worker.descriptor().id));

    registry.register(worker.clone()).unwrap();

    assert_eq!(registry.count(), 1);
    assert!(registry.contains(&worker.descriptor().id));

    let fetched = registry.get(&worker.descriptor().id).unwrap();
    assert_eq!(fetched.descriptor().id, worker.descriptor().id);
}

#[test]
fn test_duplicate_worker_rejected() {
    let registry = WorkerRegistry::new();
    let worker1 = Arc::new(TestWorker::new("lyxal-notification", "delivery"));
    let worker2 = Arc::new(TestWorker::new("lyxal-notification", "delivery"));

    registry.register(worker1).unwrap();
    let err = registry.register(worker2).unwrap_err();

    assert_eq!(err.code(), "RUNTIME_WORKER_DUPLICATE");
}

#[test]
fn test_list_and_filter_by_module() {
    let registry = WorkerRegistry::new();
    let w1 = Arc::new(TestWorker::new("lyxal-notification", "email"));
    let w2 = Arc::new(TestWorker::new("lyxal-notification", "sms"));
    let w3 = Arc::new(TestWorker::new("lyxal-webhook", "dispatcher"));

    registry.register(w1).unwrap();
    registry.register(w2).unwrap();
    registry.register(w3).unwrap();

    assert_eq!(registry.count(), 3);

    let notif_mod = ModuleId::new("lyxal-notification");
    let notif_workers = registry.list_for_module(&notif_mod);
    assert_eq!(notif_workers.len(), 2);

    let webhook_mod = ModuleId::new("lyxal-webhook");
    let webhook_workers = registry.list_for_module(&webhook_mod);
    assert_eq!(webhook_workers.len(), 1);

    let crm_mod = ModuleId::new("lyxal-crm");
    let crm_workers = registry.list_for_module(&crm_mod);
    assert_eq!(crm_workers.len(), 0);
}

#[test]
fn test_deterministic_ordering() {
    let registry = WorkerRegistry::new();
    let w_z = Arc::new(TestWorker::new("lyxal-notification", "z-worker"));
    let w_a = Arc::new(TestWorker::new("lyxal-notification", "a-worker"));
    let w_m = Arc::new(TestWorker::new("lyxal-notification", "m-worker"));

    // Enregistrement dans le désordre
    registry.register(w_z).unwrap();
    registry.register(w_a).unwrap();
    registry.register(w_m).unwrap();

    let list = registry.list();
    assert_eq!(list[0].descriptor().name, "a-worker");
    assert_eq!(list[1].descriptor().name, "m-worker");
    assert_eq!(list[2].descriptor().name, "z-worker");
}
