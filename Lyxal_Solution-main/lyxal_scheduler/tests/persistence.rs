use chrono::Utc;
use lyxal_scheduler::dead_letter::DeadLetter;
use lyxal_scheduler::history::JobHistory;
use lyxal_scheduler::persistence::InMemoryStore;
use lyxal_scheduler::task::{Job, JobResult};
use serde_json::json;

#[tokio::test]
async fn crud_jobs_and_reconstruction() {
    let store = InMemoryStore::new();
    let job = Job::new("test", "* * * * * *", 3, json!({"foo": "bar"})).unwrap();

    store.add_job(job.clone()).await.unwrap();
    let fetched = store.get_job(&job.id).await.unwrap();
    assert_eq!(fetched.name, "test");

    let mut updated = fetched.clone();
    updated.enabled = false;
    store.update_job(updated.clone()).await.unwrap();

    let listed = store.list_jobs().await;
    assert_eq!(listed.len(), 1);
    assert!(!listed[0].enabled);

    // Vérifie la désérialisation avec reconstruction de schedule
    let serialized = serde_json::to_string(&updated).unwrap();
    let deserialized: Job = serde_json::from_str(&serialized).unwrap();
    let next = deserialized.schedule.after(&Utc::now()).next();
    assert!(next.is_some());

    store.remove_job(&updated.id).await.unwrap();
    assert!(store.get_job(&updated.id).await.is_none());
}

#[tokio::test]
async fn history_and_dead_letters() {
    let store = InMemoryStore::new();
    let job = Job::new("test", "* * * * * *", 1, json!({})).unwrap();
    store.add_job(job.clone()).await.unwrap();

    store
        .push_history(JobHistory {
            job_id: job.id,
            result: JobResult::Success,
            timestamp: Utc::now(),
            duration_ms: 10,
        })
        .await
        .unwrap();

    store
        .push_dead_letter(DeadLetter {
            job_id: job.id,
            reason: "failure".into(),
            failed_payload: job.payload.clone(),
            timestamp: Utc::now(),
        })
        .await
        .unwrap();

    let history = store.list_history().await;
    assert_eq!(history.len(), 1);

    let dlq = store.list_dead_letters().await;
    assert_eq!(dlq.len(), 1);
    assert_eq!(dlq[0].reason, "failure");
}
