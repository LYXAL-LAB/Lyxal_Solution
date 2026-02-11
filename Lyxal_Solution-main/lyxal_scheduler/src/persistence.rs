//! Stockage des tâches et des événements.

use std::collections::HashMap;
use std::sync::Arc;

use tokio::sync::RwLock;
use uuid::Uuid;

use crate::dead_letter::DeadLetter;
use crate::errors::SchedulerError;
use crate::history::JobHistory;
use crate::task::Job;

#[derive(Default)]
struct State {
    jobs: HashMap<Uuid, Job>,
    history: Vec<JobHistory>,
    dead_letters: Vec<DeadLetter>,
}

#[derive(Clone, Default)]
pub struct InMemoryStore {
    inner: Arc<RwLock<State>>,
}

impl InMemoryStore {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(RwLock::new(State::default())),
        }
    }

    pub async fn add_job(&self, job: Job) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.jobs.insert(job.id, job);
        Ok(())
    }

    pub async fn get_job(&self, id: &Uuid) -> Option<Job> {
        let guard = self.inner.read().await;
        guard.jobs.get(id).cloned()
    }

    pub async fn update_job(&self, job: Job) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        match guard.jobs.entry(job.id) {
            std::collections::hash_map::Entry::Occupied(mut entry) => {
                entry.insert(job);
                Ok(())
            }
            std::collections::hash_map::Entry::Vacant(_) => Err(SchedulerError::JobNotFound),
        }
    }

    pub async fn remove_job(&self, id: &Uuid) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard
            .jobs
            .remove(id)
            .map(|_| ())
            .ok_or(SchedulerError::JobNotFound)
    }

    pub async fn list_jobs(&self) -> Vec<Job> {
        let guard = self.inner.read().await;
        guard.jobs.values().cloned().collect()
    }

    pub async fn push_history(&self, entry: JobHistory) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.history.push(entry);
        Ok(())
    }

    pub async fn push_dead_letter(&self, dlq: DeadLetter) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.dead_letters.push(dlq);
        Ok(())
    }

    pub async fn list_history(&self) -> Vec<JobHistory> {
        let guard = self.inner.read().await;
        guard.history.clone()
    }

    pub async fn list_dead_letters(&self) -> Vec<DeadLetter> {
        let guard = self.inner.read().await;
        guard.dead_letters.clone()
    }

    pub async fn drain_history(&self) -> Vec<JobHistory> {
        let mut guard = self.inner.write().await;
        guard.history.drain(..).collect()
    }

    pub async fn drain_dead_letters(&self) -> Vec<DeadLetter> {
        let mut guard = self.inner.write().await;
        guard.dead_letters.drain(..).collect()
    }
}
