use chrono::Utc;
use lyxal_scheduler::api;
use lyxal_scheduler::executor::MockExecutor;
use lyxal_scheduler::instance_manager::InstanceManager;
use lyxal_scheduler::persistence::InMemoryStore;
use lyxal_scheduler::scheduler::Scheduler;
use lyxal_scheduler::task::JobResult;
use serde_json::json;
use std::sync::Arc;

#[tokio::test]
async fn failed_job_retries_then_dlq() {
    let store = InMemoryStore::new();
    let executor = Arc::new(MockExecutor);
    let manager = Arc::new(InstanceManager::new(2, executor));
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let job = api::create_job(
        &store,
        "fail_twice",
        "* * * * * *",
        2,
        json!({ "force_status": "failed", "reason": "boom" }),
    )
    .await
    .unwrap();

    // Première exécution immédiate
    let mut job_due = store.get_job(&job.id).await.unwrap();
    job_due.next_run = Utc::now();
    store.update_job(job_due).await.unwrap();

    scheduler.tick_once().await.unwrap();

    // Seconde exécution immédiate (max_retries atteint)
    let mut job_due = store.get_job(&job.id).await.unwrap();
    job_due.next_run = Utc::now();
    store.update_job(job_due).await.unwrap();

    scheduler.tick_once().await.unwrap();

    let stored = store.get_job(&job.id).await.unwrap();
    assert!(!stored.enabled);

    let dlq = store.list_dead_letters().await;
    assert_eq!(dlq.len(), 1);
    assert_eq!(dlq[0].job_id, job.id);

    let history = store.list_history().await;
    assert_eq!(history.len(), 2);
    assert!(matches!(history[0].result, JobResult::Failed(_)));
}
