//! API haut-niveau pour manipuler les jobs.

use serde_json::Value;
use uuid::Uuid;

use crate::errors::SchedulerError;
use crate::persistence::InMemoryStore;
use crate::task::Job;

pub async fn create_job(
    store: &InMemoryStore,
    name: impl Into<String>,
    cron: impl Into<String>,
    max_retries: u32,
    payload: Value,
) -> Result<Job, SchedulerError> {
    let job = Job::new(name, cron, max_retries, payload)?;
    store.add_job(job.clone()).await?;
    Ok(job)
}

pub async fn delete_job(store: &InMemoryStore, id: &Uuid) -> Result<(), SchedulerError> {
    store.remove_job(id).await
}

pub async fn enable_job(store: &InMemoryStore, id: &Uuid) -> Result<(), SchedulerError> {
    if let Some(mut job) = store.get_job(id).await {
        job.enabled = true;
        store.update_job(job).await
    } else {
        Err(SchedulerError::JobNotFound)
    }
}

pub async fn disable_job(store: &InMemoryStore, id: &Uuid) -> Result<(), SchedulerError> {
    if let Some(mut job) = store.get_job(id).await {
        job.enabled = false;
        store.update_job(job).await
    } else {
        Err(SchedulerError::JobNotFound)
    }
}

pub async fn list_jobs(store: &InMemoryStore) -> Vec<Job> {
    store.list_jobs().await
}
