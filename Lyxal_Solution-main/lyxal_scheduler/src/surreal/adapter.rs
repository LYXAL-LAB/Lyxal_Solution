use std::sync::Arc;

use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::dead_letter::DeadLetter;
use crate::errors::SchedulerError;
use crate::history::JobHistory;
use crate::instance::InstanceId;
use crate::persistence::InMemoryStore;
use crate::task::Job;

use super::mapper::surreal_job_to_core;
use super::models::SurrealJob;

pub struct SurrealAdapter {
    db: Arc<Surreal<Any>>,
}

impl SurrealAdapter {
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db: Arc::new(db) }
    }

    pub async fn load_jobs(
        &self,
        instance: Option<&InstanceId>,
    ) -> Result<Vec<Job>, SchedulerError> {
        let mut response = if let Some(instance_id) = instance {
            self.db
                .query(
                    "SELECT * FROM scheduler::task WHERE enabled = true AND instance_id = $instance",
                )
                .bind(("instance", &instance_id.0))
                .await
        } else {
            self.db
                .query("SELECT * FROM scheduler::task WHERE enabled = true")
                .await
        }
        .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

        let surreal_jobs: Vec<SurrealJob> = response
            .take(0)
            .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;

        surreal_jobs.into_iter().map(surreal_job_to_core).collect()
    }

    pub async fn persist_job(&self, job: &Job) -> Result<(), SchedulerError> {
        self.db
            .query(
                "UPDATE scheduler::task SET
                    name = $name,
                    cron = $cron,
                    max_retries = $max_retries,
                    attempts = $attempts,
                    payload = $payload,
                    enabled = $enabled,
                    next_run = $next_run,
                    instance_id = $instance_id
                 WHERE id = $id",
            )
            .bind(("id", job.id.to_string()))
            .bind(("name", job.name.clone()))
            .bind(("cron", job.cron.clone()))
            .bind(("max_retries", job.max_retries as i64))
            .bind(("attempts", job.attempts as i64))
            .bind(("payload", job.payload.clone()))
            .bind(("enabled", job.enabled))
            .bind(("next_run", job.next_run))
            .bind(("instance_id", job.instance_id.as_ref().map(|i| i.0.clone())))
            .await
            .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;
        Ok(())
    }

    pub async fn push_history(&self, history: &JobHistory) -> Result<(), SchedulerError> {
        self.db
            .query(
                "CREATE scheduler::history SET
                    job_id = $job_id,
                    result = $result,
                    timestamp = $timestamp,
                    duration_ms = $duration_ms",
            )
            .bind(("job_id", history.job_id.to_string()))
            .bind((
                "result",
                serde_json::to_string(&history.result)
                    .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?,
            ))
            .bind(("timestamp", history.timestamp))
            .bind(("duration_ms", history.duration_ms as i64))
            .await
            .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;
        Ok(())
    }

    pub async fn push_dead_letter(&self, dlq: &DeadLetter) -> Result<(), SchedulerError> {
        self.db
            .query(
                "CREATE scheduler::dead_letter SET
                    job_id = $job_id,
                    reason = $reason,
                    failed_payload = $failed_payload,
                    timestamp = $timestamp",
            )
            .bind(("job_id", dlq.job_id.to_string()))
            .bind(("reason", dlq.reason.clone()))
            .bind(("failed_payload", dlq.failed_payload.clone()))
            .bind(("timestamp", dlq.timestamp))
            .await
            .map_err(|e| SchedulerError::PersistenceError(e.to_string()))?;
        Ok(())
    }
}

pub async fn hydrate_store(
    adapter: &SurrealAdapter,
    store: &InMemoryStore,
) -> Result<(), SchedulerError> {
    let jobs = adapter.load_jobs(None).await?;
    for job in jobs {
        store.add_job(job).await?;
    }
    Ok(())
}
