//! Dispatcher : façade simple au-dessus du pool de workers.

use std::sync::Arc;

use crate::errors::SchedulerError;
use crate::executor::JobExecutor;
use crate::task::Job;
use crate::worker::JobExecutionResult;
use crate::worker_pool::WorkerPool;

pub struct Dispatcher<E: JobExecutor> {
    pool: Arc<WorkerPool<E>>,
}

impl<E: JobExecutor + 'static> Dispatcher<E> {
    pub fn new(pool: Arc<WorkerPool<E>>) -> Self {
        Self { pool }
    }

    pub async fn dispatch(&self, job: Job) -> Result<JobExecutionResult, SchedulerError> {
        self.pool.execute(job).await
    }
}
