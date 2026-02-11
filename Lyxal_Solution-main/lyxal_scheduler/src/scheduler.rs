//! Boucle principale de planification et d'exécution.

use std::sync::Arc;

use chrono::Utc;
use tokio::task::JoinSet;
use tokio::time::{sleep, Duration};
use tracing::instrument;

use crate::cron_parser::next_after;
use crate::dead_letter::DeadLetter;
use crate::errors::SchedulerError;
use crate::executor::JobExecutor;
use crate::history::JobHistory;
use crate::instance::InstanceId;
use crate::instance_manager::InstanceManager;
use crate::persistence::InMemoryStore;
use crate::retry::compute_backoff;
use crate::task::JobResult;

pub struct Scheduler<E: JobExecutor> {
    pub store: InMemoryStore,
    pub instance_manager: Arc<InstanceManager<E>>,
    pub interval_secs: u64,
}

impl<E: JobExecutor + 'static> Scheduler<E> {
    pub fn new(
        store: InMemoryStore,
        instance_manager: Arc<InstanceManager<E>>,
        interval_secs: u64,
    ) -> Self {
        Self {
            store,
            instance_manager,
            interval_secs: interval_secs.max(1),
        }
    }

    /// Lance la boucle infinie de scheduling.
    pub async fn start(self) {
        let interval = Duration::from_secs(self.interval_secs);
        loop {
            if let Err(err) = self.tick_once().await {
                tracing::error!(?err, "scheduler tick failed");
            }
            sleep(interval).await;
        }
    }

    #[instrument(skip(self))]
    pub async fn tick_once(&self) -> Result<(), SchedulerError> {
        let now = Utc::now();
        let jobs = self.store.list_jobs().await;
        let mut set = JoinSet::new();

        for job in jobs {
            if !job.enabled || job.next_run > now {
                continue;
            }

            let manager = self.instance_manager.clone();
            set.spawn(async move {
                let instance = job.instance_id.clone().unwrap_or_else(InstanceId::default);
                let exec_result = manager.execute(instance, job.clone()).await;
                (job, exec_result)
            });
        }

        while let Some(res) = set.join_next().await {
            let (mut job, exec_result) = res.map_err(|err| {
                SchedulerError::ExecutionError(format!("worker task panicked: {err}"))
            })?;

            match exec_result {
                Ok(execution) => {
                    let duration_ms = execution.duration_ms.min(u64::MAX as u128);
                    let result = execution.result;

                    self.store
                        .push_history(JobHistory {
                            job_id: job.id,
                            result: result.clone(),
                            timestamp: now,
                            duration_ms: duration_ms as u64,
                        })
                        .await?;

                    match result {
                        JobResult::Success => {
                            job.attempts = 0;
                            if let Some(next) = next_after(&job.schedule, now) {
                                job.next_run = next;
                            } else {
                                job.enabled = false;
                            }
                            self.store.update_job(job).await?;
                        }
                        JobResult::Failed(reason) => {
                            job.attempts = job.attempts.saturating_add(1);
                            if job.attempts < job.max_retries {
                                job.next_run = now + compute_backoff(job.attempts);
                                self.store.update_job(job).await?;
                            } else {
                                self.store
                                    .push_dead_letter(DeadLetter {
                                        job_id: job.id,
                                        reason,
                                        failed_payload: job.payload.clone(),
                                        timestamp: now,
                                    })
                                    .await?;
                                job.enabled = false;
                                self.store.update_job(job).await?;
                            }
                        }
                        JobResult::Timeout => {
                            job.attempts = job.attempts.saturating_add(1);
                            if job.attempts < job.max_retries {
                                job.next_run = now + compute_backoff(job.attempts);
                                self.store.update_job(job).await?;
                            } else {
                                self.store
                                    .push_dead_letter(DeadLetter {
                                        job_id: job.id,
                                        reason: "timeout".to_string(),
                                        failed_payload: job.payload.clone(),
                                        timestamp: now,
                                    })
                                    .await?;
                                job.enabled = false;
                                self.store.update_job(job).await?;
                            }
                        }
                    }
                }
                Err(err) => {
                    let reason = format!("executor error: {err}");
                    self.store
                        .push_history(JobHistory {
                            job_id: job.id,
                            result: JobResult::Failed(reason.clone()),
                            timestamp: now,
                            duration_ms: 0,
                        })
                        .await?;

                    job.attempts = job.attempts.saturating_add(1);
                    if job.attempts < job.max_retries {
                        job.next_run = now + compute_backoff(job.attempts);
                        self.store.update_job(job).await?;
                    } else {
                        self.store
                            .push_dead_letter(DeadLetter {
                                job_id: job.id,
                                reason,
                                failed_payload: job.payload.clone(),
                                timestamp: now,
                            })
                            .await?;
                        job.enabled = false;
                        self.store.update_job(job).await?;
                    }
                }
            }
        }

        Ok(())
    }
}
