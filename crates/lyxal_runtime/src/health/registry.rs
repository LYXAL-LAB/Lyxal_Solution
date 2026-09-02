use crate::error::RuntimeError;
use crate::health::check::ModuleHealthCheck;
use crate::types::ModuleId;
use std::collections::HashMap;
use std::sync::{Arc, RwLock};

/// Registre centralisé et thread-safe des vérificateurs de santé (`ModuleHealthCheck`).
#[derive(Default, Clone)]
pub struct HealthRegistry {
    checkers: Arc<RwLock<HashMap<ModuleId, Arc<dyn ModuleHealthCheck>>>>,
}

impl HealthRegistry {
    /// Crée un nouveau registre de santé vide.
    pub fn new() -> Self {
        Self {
            checkers: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Enregistre un vérificateur de santé pour un module.
    ///
    /// # Erreurs
    /// Retourne une erreur `RuntimeError::Internal` si un checker est déjà enregistré pour ce `ModuleId`.
    pub fn register_check(&self, checker: Arc<dyn ModuleHealthCheck>) -> Result<(), RuntimeError> {
        let mut map = self.checkers.write().map_err(|_| RuntimeError::Internal {
            code: "HEALTH_REGISTRY_LOCK_POISONED",
            message: "HealthRegistry write lock was poisoned".to_string(),
        })?;

        let id = checker.module_id();
        if map.contains_key(id) {
            return Err(RuntimeError::Internal {
                code: "HEALTH_CHECKER_ALREADY_REGISTERED",
                message: format!("A health checker for module '{}' is already registered", id),
            });
        }

        map.insert(id.clone(), checker);
        Ok(())
    }

    /// Récupère le vérificateur de santé d'un module s'il existe.
    pub fn get_check(&self, id: &ModuleId) -> Option<Arc<dyn ModuleHealthCheck>> {
        let map = self.checkers.read().ok()?;
        map.get(id).cloned()
    }

    /// Indique si un vérificateur de santé est enregistré pour ce module.
    pub fn has_check(&self, id: &ModuleId) -> bool {
        let Ok(map) = self.checkers.read() else {
            return false;
        };
        map.contains_key(id)
    }

    /// Liste tous les identifiants de modules disposant d'un vérificateur enregistré.
    pub fn list_checkers(&self) -> Vec<ModuleId> {
        let Ok(map) = self.checkers.read() else {
            return Vec::new();
        };
        let mut ids: Vec<ModuleId> = map.keys().cloned().collect();
        ids.sort();
        ids
    }

    /// Désenregistre un vérificateur de santé.
    pub fn unregister_check(&self, id: &ModuleId) -> Option<Arc<dyn ModuleHealthCheck>> {
        let Ok(mut map) = self.checkers.write() else {
            return None;
        };
        map.remove(id)
    }
}
