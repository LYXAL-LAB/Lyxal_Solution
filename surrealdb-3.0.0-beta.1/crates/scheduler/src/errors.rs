//! Erreurs spécifiques au scheduler.

use thiserror::Error;

#[derive(Debug, Error)]
pub enum SchedulerError {
    #[error("invalid cron expression")]
    InvalidCron,
    #[error("job not found")]
    JobNotFound,
    #[error("execution error: {0}")]
    ExecutionError(String),
    #[error("persistence error: {0}")]
    PersistenceError(String),
}
