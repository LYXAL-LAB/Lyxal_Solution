use chrono::Utc;
use lyxal_scheduler::api;
use lyxal_scheduler::executor::MockExecutor;
use lyxal_scheduler::instance_manager::InstanceManager;
use lyxal_scheduler::persistence::InMemoryStore;
use lyxal_scheduler::scheduler::Scheduler;
use lyxal_scheduler::task::{Job, JobResult};
use lyxal_scheduler::worker_pool::WorkerPool;
use serde_json::json;
use std::sync::Arc;
use std::time::Duration;
use tokio::task::JoinSet;

#[tokio::test]
async fn worker_pool_executes_in_parallel() {
    let pool = WorkerPool::new(4, Arc::new(MockExecutor), Duration::from_secs(5));
    assert_eq!(pool.size(), 4);

    let mut set = JoinSet::new();
    for i in 0..10 {
        let pool = pool.clone();
        set.spawn(async move {
            let job = Job::new(
                format!("job-{i}"),
                "* * * * * *",
                1,
                json!({ "force_status": "success" }),
            )
            .unwrap();
            pool.execute(job).await
        });
    }

    let mut results = Vec::new();
    while let Some(res) = set.join_next().await {
        let exec = res.expect("join worker task");
        let exec = exec.expect("worker execution");
        results.push(exec);
    }

    assert_eq!(results.len(), 10);
    assert!(results
        .iter()
        .all(|r| matches!(r.result, JobResult::Success)));
}

#[tokio::test]
async fn scheduler_with_pool_handles_dlq_and_history() {
    let store = InMemoryStore::new();
    let manager = Arc::new(InstanceManager::new(2, Arc::new(MockExecutor)));
    let scheduler = Scheduler::new(store.clone(), manager, 1);

    let ok_job = api::create_job(
        &store,
        "ok",
        "* * * * * *",
        2,
        json!({ "force_status": "success" }),
    )
    .await
    .unwrap();

    let fail_job = api::create_job(
        &store,
        "fail",
        "* * * * * *",
        1,
        json!({ "force_status": "failed", "reason": "oops" }),
    )
    .await
    .unwrap();

    for id in [ok_job.id, fail_job.id] {
        let mut job = store.get_job(&id).await.unwrap();
        job.next_run = Utc::now();
        store.update_job(job).await.unwrap();
    }

    scheduler.tick_once().await.unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 2);

    let dlq = store.list_dead_letters().await;
    assert_eq!(dlq.len(), 1);
    assert_eq!(dlq[0].job_id, fail_job.id);

    let failed = store.get_job(&fail_job.id).await.unwrap();
    assert!(!failed.enabled);

    let succeeded = store.get_job(&ok_job.id).await.unwrap();
    assert!(succeeded.enabled);
    assert_eq!(succeeded.attempts, 0);
}
