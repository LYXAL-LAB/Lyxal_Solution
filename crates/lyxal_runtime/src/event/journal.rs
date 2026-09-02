use crate::error::RuntimeError;
use crate::event::event::RuntimeEvent;
use crate::types::ModuleId;
use async_trait::async_trait;
use std::collections::VecDeque;
use std::sync::{Arc, RwLock};

/// Contrat d'observabilité et d'audit historique des événements du Runtime.
#[async_trait]
pub trait RuntimeEventJournal: Send + Sync {
    /// Ajoute un événement immuable au journal d'audit.
    async fn append(&self, event: &RuntimeEvent) -> Result<(), RuntimeError>;

    /// Récupère les événements les plus récents (ordonnés du plus récent au plus ancien ou par séquence).
    async fn recent(&self, limit: usize) -> Result<Vec<RuntimeEvent>, RuntimeError>;

    /// Récupère les événements récents associés à un module spécifique.
    async fn by_module(
        &self,
        module_id: &ModuleId,
        limit: usize,
    ) -> Result<Vec<RuntimeEvent>, RuntimeError>;
}

/// Implémentation volatile en mémoire vive du journal d'événements avec capacité maximale bornée.
pub struct MemoryRuntimeEventJournal {
    events: Arc<RwLock<VecDeque<RuntimeEvent>>>,
    max_capacity: usize,
}

impl Default for MemoryRuntimeEventJournal {
    fn default() -> Self {
        Self::new(5000)
    }
}

impl MemoryRuntimeEventJournal {
    /// Crée un nouveau journal mémoire avec une capacité maximale d'événements retenus.
    pub fn new(max_capacity: usize) -> Self {
        Self {
            events: Arc::new(RwLock::new(VecDeque::with_capacity(max_capacity.min(1024)))),
            max_capacity: max_capacity.max(1),
        }
    }

    /// Crée un nouveau journal mémoire avec la capacité spécifiée.
    pub fn with_capacity(max_capacity: usize) -> Self {
        Self::new(max_capacity)
    }

    /// Retourne le nombre d'événements actuellement stockés dans le journal.
    pub async fn len(&self) -> usize {
        self.events.read().map(|l| l.len()).unwrap_or(0)
    }

    /// Vérifie si le journal est vide.
    pub async fn is_empty(&self) -> bool {
        self.events.read().map(|l| l.is_empty()).unwrap_or(true)
    }
}

#[async_trait]
impl RuntimeEventJournal for MemoryRuntimeEventJournal {
    async fn append(&self, event: &RuntimeEvent) -> Result<(), RuntimeError> {
        let mut lock = self.events.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryRuntimeEventJournal write lock poisoned".to_string(),
        })?;

        if lock.len() >= self.max_capacity {
            lock.pop_front();
        }

        lock.push_back(event.clone());
        Ok(())
    }

    async fn recent(&self, limit: usize) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        let lock = self.events.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryRuntimeEventJournal read lock poisoned".to_string(),
        })?;

        let count = limit.min(lock.len());
        let result: Vec<RuntimeEvent> = lock.iter().rev().take(count).cloned().collect();
        Ok(result)
    }

    async fn by_module(
        &self,
        module_id: &ModuleId,
        limit: usize,
    ) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        let lock = self.events.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryRuntimeEventJournal read lock poisoned".to_string(),
        })?;

        let result: Vec<RuntimeEvent> = lock
            .iter()
            .rev()
            .filter(|e| e.module_id.as_ref() == Some(module_id))
            .take(limit)
            .cloned()
            .collect();

        Ok(result)
    }
}
