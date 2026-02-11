//! Exécuteur de tâches.

use async_trait::async_trait;
use serde_json::Value;
use tracing::instrument;

use crate::errors::SchedulerError;
use crate::task::{Job, JobResult};

#[async_trait]
pub trait JobExecutor: Send + Sync {
    async fn execute(&self, job: &Job) -> Result<JobResult, SchedulerError>;
}

#[derive(Debug, Default, Clone)]
pub struct MockExecutor;

#[async_trait]
impl JobExecutor for MockExecutor {
    #[instrument(skip(self, job))]
    async fn execute(&self, job: &Job) -> Result<JobResult, SchedulerError> {
        let status = extract_str(&job.payload, "force_status");
        match status {
            Some("failed") => {
                let reason = extract_str(&job.payload, "reason")
                    .unwrap_or("forced failure")
                    .to_string();
                Ok(JobResult::Failed(reason))
            }
            Some("timeout") => Ok(JobResult::Timeout),
            _ => Ok(JobResult::Success),
        }
    }
}

fn extract_str<'a>(payload: &'a Value, key: &str) -> Option<&'a str> {
    payload.get(key).and_then(Value::as_str)
}
