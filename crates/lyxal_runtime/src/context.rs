use crate::types::ModuleId;
use serde_json::Value;
use std::collections::HashMap;

/// Contexte d'exécution découplé et extensible transmis à chaque module lors des phases du cycle de vie.
///
/// Ce contexte est conçu pour accueillir ultérieurement des services transversaux (SurrealDB,
/// Event Bus, Metrics, Secrets, Workers) sans rupture d'API.
#[derive(Debug, Clone)]
pub struct ModuleContext {
    module_id: ModuleId,
    properties: HashMap<String, Value>,
}

impl ModuleContext {
    /// Crée un nouveau contexte pour un module donné.
    pub fn new(module_id: impl Into<ModuleId>) -> Self {
        Self {
            module_id: module_id.into(),
            properties: HashMap::new(),
        }
    }

    /// Retourne l'identifiant du module associé à ce contexte.
    pub fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    /// Ajoute ou met à jour une propriété dans le contexte.
    pub fn with_property(mut self, key: impl Into<String>, value: impl Into<Value>) -> Self {
        self.properties.insert(key.into(), value.into());
        self
    }

    /// Récupère une propriété brute depuis le contexte.
    pub fn get_property(&self, key: &str) -> Option<&Value> {
        self.properties.get(key)
    }

    /// Vérifie la présence d'une propriété.
    pub fn has_property(&self, key: &str) -> bool {
        self.properties.contains_key(key)
    }
}
