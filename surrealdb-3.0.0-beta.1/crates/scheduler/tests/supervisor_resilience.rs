use std::sync::Arc;
use std::time::Duration;

use async_trait::async_trait;
use chrono::Utc;
use lyxal_scheduler::errors::SchedulerError;
use lyxal_scheduler::executor::JobExecutor;
use lyxal_scheduler::instance::InstanceId;
use lyxal_scheduler::instance_manager::InstanceManager;
use lyxal_scheduler::persistence::InMemoryStore;
use lyxal_scheduler::scheduler::Scheduler;
use lyxal_scheduler::task::{Job, JobResult};
use serde_json::json;
use tokio::sync::Mutex;

#[derive(Clone, Default)]
struct PanicExecutor {
    panics_left: Arc<Mutex<u32>>,
}

#[async_trait]
impl JobExecutor for PanicExecutor {
    async fn execute(&self, _job: &Job) -> Result<JobResult, SchedulerError> {
        let mut left = self.panics_left.lock().await;
        if *left > 0 {
            *left -= 1;
            panic!("boom");
        }
        Ok(JobResult::Success)
    }
}

#[derive(Clone, Default)]
struct SlowExecutor;

#[async_trait]
impl JobExecutor for SlowExecutor {
    async fn execute(&self, job: &Job) -> Result<JobResult, SchedulerError> {
        let sleep_ms = job
            .payload
            .get("sleep_ms")
            .and_then(|v| v.as_u64())
            .unwrap_or(0);
        tokio::time::sleep(Duration::from_millis(sleep_ms)).await;
        Ok(JobResult::Success)
    }
}

#[tokio::test]
async fn panic_is_caught_and_worker_continues() {
    let store = InMemoryStore::new();
    let executor = Arc::new(PanicExecutor {
        panics_left: Arc::new(Mutex::new(1)),
    });
    let manager = Arc::new(InstanceManager::new(1, executor));
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let mut job = Job::new("panic", "* * * * * *", 2, json!({})).unwrap();
    job.next_run = Utc::now();
    store.add_job(job.clone()).await.unwrap();

    scheduler.tick_once().await.unwrap();

    // Second run should now succeed
    let mut job_due = store.get_job(&job.id).await.unwrap();
    job_due.next_run = Utc::now();
    store.update_job(job_due).await.unwrap();
    scheduler.tick_once().await.unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 2);
    assert!(matches!(history[0].result, JobResult::Failed(_)));
    assert!(matches!(history[1].result, JobResult::Success));
}

#[tokio::test]
async fn hard_timeout_triggers_failure() {
    let store = InMemoryStore::new();
    let executor = Arc::new(SlowExecutor);
    // timeout in pool set to 50ms
    let manager = Arc::new(InstanceManager::new_with_timeout(
        1,
        executor,
        Duration::from_millis(50),
    ));
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let mut job = Job::new("slow", "* * * * * *", 1, json!({ "sleep_ms": 200u64 })).unwrap();
    job.next_run = Utc::now();
    store.add_job(job.clone()).await.unwrap();

    scheduler.tick_once().await.unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 1);
    assert!(matches!(history[0].result, JobResult::Failed(_)));
}

#[tokio::test]
async fn panic_in_one_instance_does_not_block_other() {
    let store = InMemoryStore::new();
    let executor = Arc::new(PanicExecutor {
        panics_left: Arc::new(Mutex::new(1)),
    });
    let manager = Arc::new(InstanceManager::new(1, executor));
    let instance_a = InstanceId("A".into());
    let instance_b = InstanceId("B".into());
    manager.register_instance(instance_a.clone());
    manager.register_instance(instance_b.clone());
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let mut job_a = Job::new("panicA", "* * * * * *", 1, json!({})).unwrap();
    job_a.instance_id = Some(instance_a);
    job_a.next_run = Utc::now();
    store.add_job(job_a.clone()).await.unwrap();

    let mut job_b = Job::new("okB", "* * * * * *", 1, json!({})).unwrap();
    job_b.instance_id = Some(instance_b);
    job_b.next_run = Utc::now();
    store.add_job(job_b.clone()).await.unwrap();

    scheduler.tick_once().await.unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 2);
    assert!(history
        .iter()
        .any(|h| matches!(h.result, JobResult::Failed(_))));
    assert!(history
        .iter()
        .any(|h| matches!(h.result, JobResult::Success)));
}
