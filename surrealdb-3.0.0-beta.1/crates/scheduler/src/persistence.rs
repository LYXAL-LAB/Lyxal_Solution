//! Stockage des tâches et des événements.

use std::collections::HashMap;
use std::sync::Arc;
use async_trait::async_trait;
use tokio::sync::RwLock;

use crate::dead_letter::DeadLetter;
use crate::errors::SchedulerError;
use crate::history::JobHistory;
use crate::task::Job;

/// Interface générique pour le stockage des tâches.
/// Cette abstraction permet de brancher le scheduler sur n'importe quel backend
/// (InMemory, SurrealDB, SQL, Redis, etc.).
#[async_trait]
pub trait TaskStore: Send + Sync {
    /// Récupère la liste des jobs (filtrage souvent fait en amont ou par l'appelant pour l'instant).
    /// Dans une V2 optimisée, on passera des filtres (ex: due_before).
    async fn list_jobs(&self) -> Result<Vec<Job>, SchedulerError>;

    /// Met à jour l'état d'un job.
    async fn update_job(&self, job: Job) -> Result<(), SchedulerError>;

    /// Ajoute une entrée dans l'historique d'exécution.
    async fn push_history(&self, entry: JobHistory) -> Result<(), SchedulerError>;

    /// Ajoute une entrée dans la Dead Letter Queue.
    async fn push_dead_letter(&self, dlq: DeadLetter) -> Result<(), SchedulerError>;
}

#[derive(Default)]
struct State {
    jobs: HashMap<String, Job>,
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

    // Méthodes spécifiques à l'implémentation mémoire (pour les tests/debug)
    pub async fn add_job(&self, job: Job) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.jobs.insert(job.id.clone(), job);
        Ok(())
    }

    pub async fn get_job(&self, id: &str) -> Option<Job> {
        let guard = self.inner.read().await;
        guard.jobs.get(id).cloned()
    }

    pub async fn remove_job(&self, id: &str) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard
            .jobs
            .remove(id)
            .map(|_| ())
            .ok_or(SchedulerError::JobNotFound)
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

#[async_trait]
impl TaskStore for InMemoryStore {
    async fn list_jobs(&self) -> Result<Vec<Job>, SchedulerError> {
        let guard = self.inner.read().await;
        Ok(guard.jobs.values().cloned().collect())
    }

    async fn update_job(&self, job: Job) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        match guard.jobs.entry(job.id.clone()) {
            std::collections::hash_map::Entry::Occupied(mut entry) => {
                entry.insert(job);
                Ok(())
            }
            std::collections::hash_map::Entry::Vacant(_) => Err(SchedulerError::JobNotFound),
        }
    }

    async fn push_history(&self, entry: JobHistory) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.history.push(entry);
        Ok(())
    }

    async fn push_dead_letter(&self, dlq: DeadLetter) -> Result<(), SchedulerError> {
        let mut guard = self.inner.write().await;
        guard.dead_letters.push(dlq);
        Ok(())
    }
}
