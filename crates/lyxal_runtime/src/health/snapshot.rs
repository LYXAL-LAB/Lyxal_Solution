use crate::health::check::{chrono_now_string, HealthCheckResult};
use crate::health::status::{GlobalHealthStatus, HealthStatus};
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

/// Représente une transition d'état de santé observée entre deux cycles successifs.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct HealthTransition {
    /// Identifiant du module concerné.
    pub module_id: ModuleId,
    /// Ancien statut de santé.
    pub from: HealthStatus,
    /// Nouveau statut de santé.
    pub to: HealthStatus,
    /// Horodatage de la transition.
    pub timestamp: String,
}

/// Photographie instantanée de l'état de santé de l'ensemble des modules du nœud.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct HealthSnapshot {
    /// Résultats individuels indexés par identifiant de module (BTreeMap pour déterminisme).
    pub modules: BTreeMap<ModuleId, HealthCheckResult>,
    /// Synthèse globale calculée à partir des statuts applicables.
    pub global_status: GlobalHealthStatus,
    /// Horodatage de capture du snapshot (ISO 8601 UTC).
    pub checked_at: String,
}

impl HealthSnapshot {
    /// Construit un nouveau snapshot à partir d'un ensemble de résultats de santé.
    pub fn new(results: Vec<HealthCheckResult>) -> Self {
        let mut modules = BTreeMap::new();
        for res in results {
            modules.insert(res.module_id.clone(), res);
        }

        let global_status = GlobalHealthStatus::from_statuses(modules.values().map(|r| &r.status));

        Self {
            modules,
            global_status,
            checked_at: chrono_now_string(),
        }
    }

    /// Construit un snapshot vide (état initial avant observation).
    pub fn empty() -> Self {
        Self {
            modules: BTreeMap::new(),
            global_status: GlobalHealthStatus::Healthy,
            checked_at: chrono_now_string(),
        }
    }

    /// Récupère le statut de santé d'un module donné s'il est présent.
    pub fn get_status(&self, module_id: &ModuleId) -> Option<HealthStatus> {
        self.modules.get(module_id).map(|r| r.status)
    }

    /// Détecte les transitions de santé par rapport à un snapshot antérieur.
    ///
    /// Règle formelle CTO :
    /// Une `HealthTransition` n'est produite que si le module avait un statut applicable
    /// dans le précédent snapshot ET un statut applicable dans le nouveau snapshot,
    /// et que ces statuts diffèrent.
    pub fn transitions_from(&self, previous: &HealthSnapshot) -> Vec<HealthTransition> {
        let mut transitions = Vec::new();

        for (module_id, curr_res) in &self.modules {
            if !curr_res.status.is_applicable() {
                continue;
            }

            if let Some(prev_res) = previous.modules.get(module_id) {
                if prev_res.status.is_applicable() && prev_res.status != curr_res.status {
                    transitions.push(HealthTransition {
                        module_id: module_id.clone(),
                        from: prev_res.status,
                        to: curr_res.status,
                        timestamp: self.checked_at.clone(),
                    });
                }
            }
        }

        transitions.sort_by(|a, b| a.module_id.cmp(&b.module_id));
        transitions
    }
}
