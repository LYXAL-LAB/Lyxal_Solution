//! Superviseur de worker : relance en cas de panic ou arrêt inattendu.

use std::sync::Arc;
use std::time::Duration;

use tokio::sync::Mutex;
use tracing::info;

use crate::executor::JobExecutor;
use crate::worker::JobExecutionRequest;
use crate::worker::Worker;

pub struct Supervisor;

impl Supervisor {
    pub fn spawn<E: JobExecutor + 'static>(
        worker_id: usize,
        executor: Arc<E>,
        receiver: Arc<Mutex<tokio::sync::mpsc::Receiver<JobExecutionRequest>>>,
        timeout: Duration,
    ) {
        tokio::spawn(async move {
            loop {
                info!(worker_id, "worker starting");
                let handle = Worker::spawn(worker_id, executor.clone(), receiver.clone(), timeout);
                match handle.await {
                    Ok(_) => {
                        info!(worker_id, "worker stopped gracefully");
                        break;
                    }
                    Err(err) => {
                        info!(?err, worker_id, "worker panicked, restarting");
                        continue;
                    }
                }
            }
        });
    }
}
