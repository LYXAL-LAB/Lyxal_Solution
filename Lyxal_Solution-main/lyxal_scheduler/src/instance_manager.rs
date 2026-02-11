//! Gestionnaire d'instances : un WorkerPool dédié par instance.

use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use std::time::Duration;

use crate::errors::SchedulerError;
use crate::executor::JobExecutor;
use crate::instance::{InstanceId, DEFAULT_INSTANCE};
use crate::task::Job;
use crate::worker::JobExecutionResult;
use crate::worker_pool::WorkerPool;

const DEFAULT_TIMEOUT: Duration = Duration::from_secs(30);

pub struct InstanceManager<E: JobExecutor> {
    pools: Arc<RwLock<HashMap<InstanceId, Arc<WorkerPool<E>>>>>,
    default_pool_size: usize,
    executor: Arc<E>,
    timeout: Duration,
}

impl<E: JobExecutor + 'static> InstanceManager<E> {
    pub fn new(default_pool_size: usize, executor: Arc<E>) -> Self {
        Self::new_with_timeout(default_pool_size, executor, DEFAULT_TIMEOUT)
    }

    pub fn new_with_timeout(default_pool_size: usize, executor: Arc<E>, timeout: Duration) -> Self {
        let manager = Self {
            pools: Arc::new(RwLock::new(HashMap::new())),
            default_pool_size: default_pool_size.max(1),
            executor,
            timeout,
        };
        manager.register_instance(InstanceId(DEFAULT_INSTANCE.to_string()));
        manager
    }

    pub fn register_instance(&self, instance_id: InstanceId) {
        let mut guard = self.pools.write().expect("lock poisoned");
        guard.entry(instance_id).or_insert_with(|| {
            Arc::new(WorkerPool::new(
                self.default_pool_size,
                self.executor.clone(),
                self.timeout,
            ))
        });
    }

    pub fn get_pool(&self, instance_id: &InstanceId) -> Option<Arc<WorkerPool<E>>> {
        let guard = self.pools.read().expect("lock poisoned");
        guard.get(instance_id).cloned()
    }

    pub async fn execute(
        &self,
        instance_id: InstanceId,
        job: Job,
    ) -> Result<JobExecutionResult, SchedulerError> {
        if let Some(pool) = self.get_pool(&instance_id) {
            pool.execute(job).await
        } else {
            Err(SchedulerError::ExecutionError(format!(
                "unknown instance: {}",
                instance_id.0
            )))
        }
    }
}
