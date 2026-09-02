use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::module::LyxalModule;
use crate::types::ModuleId;
use std::collections::HashMap;
use std::sync::Arc;

/// Registre générique et thread-safe des modules enregistrés dans Lyxal OS.
///
/// Sa responsabilité est strictement limitée à la conservation, la recherche et
/// la protection contre les doublons d'identifiants. Il ne gère pas le cycle de vie.
use std::sync::RwLock;

/// Registre générique et thread-safe des modules enregistrés dans Lyxal OS.
///
/// Sa responsabilité est strictement limitée à la conservation, la recherche et
/// la protection contre les doublons d'identifiants. Il ne gère pas le cycle de vie.
#[derive(Default)]
pub struct ModuleRegistry {
    modules: RwLock<HashMap<ModuleId, Arc<dyn LyxalModule>>>,
    registration_order: RwLock<Vec<ModuleId>>,
}

impl ModuleRegistry {
    /// Crée un nouveau registre vide.
    pub fn new() -> Self {
        Self {
            modules: RwLock::new(HashMap::new()),
            registration_order: RwLock::new(Vec::new()),
        }
    }

    /// Enregistre un module dans le registre.
    ///
    /// Retourne `RuntimeError::DuplicateModule` si un module portant le même `ModuleId`
    /// est déjà enregistré.
    pub fn register(&self, module: Arc<dyn LyxalModule>) -> Result<(), RuntimeError> {
        let id = module.id().clone();
        let mut modules = self.modules.write().map_err(|_| RuntimeError::Internal {
            code: "REGISTRY_LOCK_POISONED",
            message: "Failed to acquire write lock on module registry".to_string(),
        })?;
        if modules.contains_key(&id) {
            return Err(RuntimeError::DuplicateModule { id });
        }
        let mut order = self
            .registration_order
            .write()
            .map_err(|_| RuntimeError::Internal {
                code: "REGISTRY_LOCK_POISONED",
                message: "Failed to acquire write lock on module registration order".to_string(),
            })?;
        order.push(id.clone());
        modules.insert(id, module);
        Ok(())
    }

    /// Récupère un module par son identifiant.
    pub fn get(&self, id: &ModuleId) -> Option<Arc<dyn LyxalModule>> {
        self.modules.read().ok()?.get(id).cloned()
    }

    /// Vérifie si un module est présent dans le registre.
    pub fn contains(&self, id: &ModuleId) -> bool {
        self.modules
            .read()
            .map(|m| m.contains_key(id))
            .unwrap_or(false)
    }

    /// Retourne le nombre total de modules enregistrés.
    pub fn len(&self) -> usize {
        self.modules.read().map(|m| m.len()).unwrap_or(0)
    }

    /// Indique si le registre est vide.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Retourne la liste de tous les identifiants de modules enregistrés dans l'ordre d'enregistrement.
    pub fn ids(&self) -> Vec<ModuleId> {
        self.registration_order
            .read()
            .map(|o| o.clone())
            .unwrap_or_default()
    }

    /// Retourne la liste des instances de modules enregistrés dans l'ordre d'enregistrement.
    pub fn modules(&self) -> Vec<Arc<dyn LyxalModule>> {
        let order = self.ids();
        let modules = match self.modules.read() {
            Ok(m) => m,
            Err(_) => return Vec::new(),
        };
        order
            .iter()
            .filter_map(|id| modules.get(id).cloned())
            .collect()
    }

    /// Retourne la liste de tous les descripteurs de modules enregistrés dans l'ordre d'enregistrement.
    pub fn descriptors(&self) -> Vec<ModuleDescriptor> {
        let order = self.ids();
        let modules = match self.modules.read() {
            Ok(m) => m,
            Err(_) => return Vec::new(),
        };
        order
            .iter()
            .filter_map(|id| modules.get(id).map(|m| m.descriptor().clone()))
            .collect()
    }

    /// Récupère le descripteur d'un module spécifique.
    pub fn get_descriptor(&self, id: &ModuleId) -> Option<ModuleDescriptor> {
        let modules = self.modules.read().ok()?;
        modules.get(id).map(|m| m.descriptor().clone())
    }
}
