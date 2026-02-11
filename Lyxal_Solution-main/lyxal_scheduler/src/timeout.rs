//! Timeout "hard" pour empêcher un job de bloquer indéfiniment.

use std::future::Future;
use std::time::Duration;

use crate::errors::SchedulerError;

pub async fn with_hard_timeout<F, T>(fut: F, duration: Duration) -> Result<T, SchedulerError>
where
    F: Future<Output = Result<T, SchedulerError>> + Send,
{
    match tokio::time::timeout(duration, fut).await {
        Ok(res) => res,
        Err(_) => Err(SchedulerError::ExecutionError(
            "hard timeout exceeded".into(),
        )),
    }
}

/// Variante spécialisée pour JoinHandle afin d'aborter la tâche sur timeout.
pub async fn with_hard_timeout_join<T>(
    handle: tokio::task::JoinHandle<Result<T, SchedulerError>>,
    duration: Duration,
) -> Result<T, SchedulerError> {
    tokio::pin!(handle);
    let sleep = tokio::time::sleep(duration);
    tokio::pin!(sleep);

    tokio::select! {
        res = &mut handle => match res {
            Ok(r) => r,
            Err(err) if err.is_panic() => Err(SchedulerError::ExecutionError("worker panic".into())),
            Err(err) => Err(SchedulerError::ExecutionError(format!("worker join error: {err}"))),
        },
        _ = &mut sleep => {
            handle.abort();
            Err(SchedulerError::ExecutionError("hard timeout exceeded".into()))
        }
    }
}
