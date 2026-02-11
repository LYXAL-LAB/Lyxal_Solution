//! Worker simple : reçoit une requête d'exécution et retourne le résultat.

use std::panic::AssertUnwindSafe;
use std::sync::Arc;
use std::time::{Duration, Instant};

use futures::FutureExt;
use tokio::sync::{mpsc::Receiver, oneshot, Mutex};
use tokio::task::JoinHandle;
use tracing::{error, info, warn};

use crate::errors::SchedulerError;
use crate::executor::JobExecutor;
use crate::task::{Job, JobResult};
use crate::timeout::with_hard_timeout_join;
// use uuid::Uuid; // Removed unused import

/// Requête envoyée à un worker pour exécuter un job.
pub struct JobExecutionRequest {
    pub job: Job,
    pub respond_to: oneshot::Sender<JobExecutionResult>,
}

/// Résultat renvoyé par un worker après exécution.
#[derive(Debug, Clone)]
pub struct JobExecutionResult {
    pub job_id: String,
    pub result: JobResult,
    pub duration_ms: u128,
}

#[derive(Debug)]
pub struct Worker {
    pub id: usize,
    timeout: Duration,
}

impl Worker {
    pub fn spawn<E: JobExecutor + 'static>(
        id: usize,
        executor: Arc<E>,
        receiver: Arc<Mutex<Receiver<JobExecutionRequest>>>,
        timeout: Duration,
    ) -> JoinHandle<()> {
        tokio::spawn(async move {
            let worker = Worker { id, timeout };
            worker.run(executor, receiver).await;
        })
    }

    async fn run<E: JobExecutor + 'static>(
        self,
        executor: Arc<E>,
        receiver: Arc<Mutex<Receiver<JobExecutionRequest>>>,
    ) {
        loop {
            let req = {
                let mut guard = receiver.lock().await;
                guard.recv().await
            };

            let Some(req) = req else {
                break;
            };

            let started = Instant::now();
            let job_for_exec = req.job.clone();
            let handle = tokio::spawn({
                let executor = executor.clone();
                async move {
                    AssertUnwindSafe(executor.execute(&job_for_exec))
                        .catch_unwind()
                        .await
                        .map_err(|_| SchedulerError::ExecutionError("worker panic".to_string()))?
                }
            });

            let exec_res = with_hard_timeout_join(handle, self.timeout)
                .await
                .map_err(|err| {
                    if err.to_string().contains("hard timeout exceeded") {
                        warn!(worker_id = self.id, "hard timeout triggered");
                    } else {
                        error!(worker_id = self.id, reason = %err, "worker execution error");
                    }
                    err
                });

            let duration_ms = started.elapsed().as_millis();

            let result = match exec_res {
                Ok(res) => res,
                Err(err) => JobResult::Failed(format!("executor error: {err}")),
            };

            let _ = req.respond_to.send(JobExecutionResult {
                job_id: req.job.id,
                result,
                duration_ms,
            });
        }
        info!(worker_id = self.id, "worker loop stopped");
    }
}
