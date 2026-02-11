use std::sync::Arc;
use std::time::{Duration, Instant};

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
struct RecordingExecutor {
    calls: Arc<Mutex<Vec<(String, String)>>>,
}

#[async_trait]
impl JobExecutor for RecordingExecutor {
    async fn execute(&self, job: &Job) -> Result<JobResult, SchedulerError> {
        if let Some(ms) = job.payload.get("sleep_ms").and_then(|v| v.as_u64()) {
            tokio::time::sleep(Duration::from_millis(ms)).await;
        }

        let instance = job
            .instance_id
            .as_ref()
            .map(|id| id.0.clone())
            .unwrap_or_else(|| "default".to_string());

        self.calls.lock().await.push((instance, job.name.clone()));

        let status = job.payload.get("force_status").and_then(|v| v.as_str());
        match status {
            Some("failed") => Ok(JobResult::Failed(
                job.payload
                    .get("reason")
                    .and_then(|v| v.as_str())
                    .unwrap_or("failed")
                    .to_string(),
            )),
            Some("timeout") => Ok(JobResult::Timeout),
            _ => Ok(JobResult::Success),
        }
    }
}

#[tokio::test]
async fn isolation_per_instance() {
    let store = InMemoryStore::new();
    let executor = Arc::new(RecordingExecutor::default());
    let manager = Arc::new(InstanceManager::new(1, executor.clone()));

    let instance_a = InstanceId("A".into());
    let instance_b = InstanceId("B".into());
    manager.register_instance(instance_a.clone());
    manager.register_instance(instance_b.clone());

    let scheduler = Scheduler::new(store.clone(), manager.clone(), 1);

    let mut job_a = Job::new("jobA", "* * * * * *", 1, json!({})).unwrap();
    job_a.instance_id = Some(instance_a.clone());
    job_a.next_run = Utc::now();
    store.add_job(job_a.clone()).await.unwrap();

    let mut job_b = Job::new("jobB", "* * * * * *", 1, json!({})).unwrap();
    job_b.instance_id = Some(instance_b.clone());
    job_b.next_run = Utc::now();
    store.add_job(job_b.clone()).await.unwrap();

    scheduler.tick_once().await.unwrap();

    let calls = executor.calls.lock().await.clone();
    assert!(calls.contains(&(instance_a.0.clone(), "jobA".to_string())));
    assert!(calls.contains(&(instance_b.0.clone(), "jobB".to_string())));
    assert_eq!(calls.len(), 2);
}

#[tokio::test]
async fn parallel_between_instances() {
    let store = InMemoryStore::new();
    let executor = Arc::new(RecordingExecutor::default());
    let manager = Arc::new(InstanceManager::new(1, executor));
    let instance_a = InstanceId("A".into());
    let instance_b = InstanceId("B".into());
    manager.register_instance(instance_a.clone());
    manager.register_instance(instance_b.clone());

    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let mut slow = Job::new("slow", "* * * * * *", 1, json!({ "sleep_ms": 300u64 })).unwrap();
    slow.instance_id = Some(instance_a);
    slow.next_run = Utc::now();
    store.add_job(slow).await.unwrap();

    let mut fast = Job::new("fast", "* * * * * *", 1, json!({ "sleep_ms": 50u64 })).unwrap();
    fast.instance_id = Some(instance_b);
    fast.next_run = Utc::now();
    store.add_job(fast).await.unwrap();

    let start = Instant::now();
    scheduler.tick_once().await.unwrap();
    let elapsed = start.elapsed();

    // Si les pools sont parallèles, on doit rester proche du temps max (300ms) et non la somme (~350ms+).
    // On laisse une marge pour le runtime.
    assert!(elapsed < Duration::from_millis(700));
}

#[tokio::test]
async fn unknown_instance_returns_error() {
    let store = InMemoryStore::new();
    let manager = Arc::new(InstanceManager::new(
        1,
        Arc::new(RecordingExecutor::default()),
    ));
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let mut job = Job::new(
        "unknown",
        "* * * * * *",
        2,
        json!({ "force_status": "success" }),
    )
    .unwrap();
    job.instance_id = Some(InstanceId("nope".into()));
    job.next_run = Utc::now();
    let job_id = job.id;
    store.add_job(job.clone()).await.unwrap();

    scheduler.tick_once().await.unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 1);
    assert!(matches!(history[0].result, JobResult::Failed(_)));

    let stored = store.get_job(&job_id).await.unwrap();
    assert!(stored.enabled);
    assert!(stored.next_run > Utc::now());

    let dlq = store.list_dead_letters().await;
    assert!(dlq.is_empty());
}
