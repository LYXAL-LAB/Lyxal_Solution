//! Pool de workers parallèles pour exécuter les jobs.

use std::sync::Arc;

use tokio::sync::{mpsc, oneshot, Mutex};
use tokio::time::{timeout, Duration};

use crate::errors::SchedulerError;
use crate::executor::JobExecutor;
use crate::supervisor::Supervisor;
use crate::task::Job;
use crate::worker::{JobExecutionRequest, JobExecutionResult};

#[derive(Clone)]
pub struct WorkerPool<E: JobExecutor> {
    sender: mpsc::Sender<JobExecutionRequest>,
    size: usize,
    /// Conserve l'exécuteur pour éviter son drop prématuré.
    _executor: Arc<E>,
    timeout: Duration,
}

impl<E: JobExecutor + 'static> WorkerPool<E> {
    pub fn new(size: usize, executor: Arc<E>, timeout: Duration) -> Self {
        let size = size.max(1);
        let (sender, receiver) = mpsc::channel::<JobExecutionRequest>(size * 4);
        let shared_receiver = Arc::new(Mutex::new(receiver));

        for id in 0..size {
            Supervisor::spawn(id, executor.clone(), shared_receiver.clone(), timeout);
        }

        Self {
            sender,
            size,
            _executor: executor,
            timeout,
        }
    }

    pub fn size(&self) -> usize {
        self.size
    }

    pub async fn execute(&self, job: Job) -> Result<JobExecutionResult, SchedulerError> {
        let (tx, rx) = oneshot::channel();
        let req = JobExecutionRequest {
            job,
            respond_to: tx,
        };

        self.sender
            .send(req)
            .await
            .map_err(|err| SchedulerError::ExecutionError(format!("dispatch failed: {err}")))?;

        match timeout(self.timeout, rx).await {
            Ok(Ok(res)) => Ok(res),
            Ok(Err(_)) => Err(SchedulerError::ExecutionError(
                "worker dropped response".to_string(),
            )),
            Err(_) => Err(SchedulerError::ExecutionError(
                "execution timed out".to_string(),
            )),
        }
    }
}
