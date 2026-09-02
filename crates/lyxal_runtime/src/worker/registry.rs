use crate::error::RuntimeError;
use crate::types::ModuleId;
use crate::worker::definition::LyxalWorker;
use crate::worker::id::WorkerId;
use std::collections::BTreeMap;
use std::sync::{Arc, RwLock};

/// Registre thread-safe des workers déclarés auprès du Runtime.
#[derive(Clone, Default)]
pub struct WorkerRegistry {
    workers: Arc<RwLock<BTreeMap<WorkerId, Arc<dyn LyxalWorker>>>>,
}

impl WorkerRegistry {
    /// Crée un nouveau registre de workers vide.
    pub fn new() -> Self {
        Self {
            workers: Arc::new(RwLock::new(BTreeMap::new())),
        }
    }

    /// Enregistre un worker dans le registre.
    ///
    /// Échoue avec `WorkerDuplicate` si un worker avec le même `WorkerId` est déjà présent.
    pub fn register(&self, worker: Arc<dyn LyxalWorker>) -> Result<(), RuntimeError> {
        let descriptor = worker.descriptor();
        let id = descriptor.id.clone();

        let mut lock = self.workers.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "WorkerRegistry write lock poisoned".to_string(),
        })?;

        if lock.contains_key(&id) {
            return Err(RuntimeError::WorkerDuplicate {
                worker: id.to_string(),
            });
        }

        lock.insert(id, worker);
        Ok(())
    }

    /// Récupère un worker par son identifiant unique.
    pub fn get(&self, worker_id: &WorkerId) -> Option<Arc<dyn LyxalWorker>> {
        let lock = self.workers.read().ok()?;
        lock.get(worker_id).cloned()
    }

    /// Vérifie si un worker est présent dans le registre.
    pub fn contains(&self, worker_id: &WorkerId) -> bool {
        self.workers
            .read()
            .map(|l| l.contains_key(worker_id))
            .unwrap_or(false)
    }

    /// Retourne la liste ordonnée et déterministe de tous les workers enregistrés.
    pub fn list(&self) -> Vec<Arc<dyn LyxalWorker>> {
        self.workers
            .read()
            .map(|l| l.values().cloned().collect())
            .unwrap_or_default()
    }

    /// Retourne la liste des workers appartenant à un module spécifique.
    pub fn list_for_module(&self, module_id: &ModuleId) -> Vec<Arc<dyn LyxalWorker>> {
        self.workers
            .read()
            .map(|l| {
                l.values()
                    .filter(|w| &w.descriptor().module_id == module_id)
                    .cloned()
                    .collect()
            })
            .unwrap_or_default()
    }

    /// Retourne le nombre total de workers enregistrés.
    pub fn count(&self) -> usize {
        self.workers.read().map(|l| l.len()).unwrap_or(0)
    }
}
