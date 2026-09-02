use crate::package::types::ModuleReleaseStatus;
use crate::types::{ModuleId, ModuleState};
use semver::Version;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Photographie observée de l'état réel d'un module individuel.
///
/// Distingue rigoureusement l'état persistant dans SurrealDB (`release_status`, `installed_version`)
/// de l'état d'exécution node-local (`runtime_state`, `is_registered`).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ObservedModuleState {
    /// Identifiant canonique du module.
    pub module_id: ModuleId,
    /// Version de la release installée observée dans le store persistant.
    pub installed_version: Option<Version>,
    /// Statut persistant de la release dans SurrealDB (`Installed`, `Failed`, etc.).
    pub release_status: Option<ModuleReleaseStatus>,
    /// État d'exécution local géré par le `LifecycleManager` (`Running`, `Stopped`, `Installed`, etc.).
    pub runtime_state: Option<ModuleState>,
    /// Indique si le module est présent dans le `ModuleRegistry` en mémoire.
    pub is_registered: bool,
}

impl ObservedModuleState {
    /// Crée un état pour un module absent de toute persistance et de la mémoire.
    pub fn absent(module_id: impl Into<ModuleId>) -> Self {
        Self {
            module_id: module_id.into(),
            installed_version: None,
            release_status: None,
            runtime_state: None,
            is_registered: false,
        }
    }

    /// Indique si le module est actuellement en cours d'exécution actif sur ce nœud.
    pub fn is_running(&self) -> bool {
        self.runtime_state
            .as_ref()
            .map(|s| s.is_running())
            .unwrap_or(false)
    }

    /// Indique si le module est installé (persistance valide ou état local installé/arrêté/en cours).
    pub fn is_installed(&self) -> bool {
        if let Some(status) = &self.release_status {
            if *status == ModuleReleaseStatus::Installed {
                return true;
            }
        }
        if let Some(state) = &self.runtime_state {
            if matches!(
                state,
                ModuleState::Installed | ModuleState::Running | ModuleState::Stopped
            ) {
                return true;
            }
        }
        false
    }

    /// Indique si le module est installé mais actuellement arrêté ou inactif.
    pub fn is_stopped_or_installed(&self) -> bool {
        self.is_installed() && !self.is_running()
    }
}

/// Photographie globale de l'état réel du Runtime Lyxal OS.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct ActualRuntimeState {
    /// États observés indexés par identifiant de module.
    pub modules: HashMap<ModuleId, ObservedModuleState>,
}

impl ActualRuntimeState {
    /// Crée un état réel vide.
    pub fn new() -> Self {
        Self {
            modules: HashMap::new(),
        }
    }

    /// Crée un état réel vide (alias).
    pub fn empty() -> Self {
        Self::new()
    }

    /// Enregistre ou met à jour l'état observé d'un module.
    pub fn insert(&mut self, state: ObservedModuleState) {
        self.modules.insert(state.module_id.clone(), state);
    }

    /// Enregistre un état observé pour un module spécifique.
    pub fn set(&mut self, id: ModuleId, state: ObservedModuleState) {
        self.modules.insert(id, state);
    }

    /// Retourne la référence vers la table des états de modules observés.
    pub fn modules(&self) -> &HashMap<ModuleId, ObservedModuleState> {
        &self.modules
    }

    /// Récupère l'état d'un module s'il existe.
    pub fn get(&self, id: &ModuleId) -> Option<&ObservedModuleState> {
        self.modules.get(id)
    }

    /// Récupère l'état de cycle de vie local d'un module s'il existe.
    pub fn module_state(&self, id: &ModuleId) -> Option<ModuleState> {
        self.get(id).and_then(|s| s.runtime_state.clone())
    }

    /// Vérifie si un module est en cours d'exécution.
    pub fn is_running(&self, id: &ModuleId) -> bool {
        self.get(id).map(|s| s.is_running()).unwrap_or(false)
    }

    /// Vérifie si un module est installé.
    pub fn is_installed(&self, id: &ModuleId) -> bool {
        self.get(id).map(|s| s.is_installed()).unwrap_or(false)
    }

    /// Retourne la liste de tous les identifiants de modules observés.
    pub fn module_ids(&self) -> Vec<ModuleId> {
        self.modules.keys().cloned().collect()
    }
}
