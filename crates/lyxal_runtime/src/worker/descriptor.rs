use crate::types::ModuleId;
use crate::worker::id::WorkerId;
use crate::worker::restart::RestartPolicy;
use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Niveau de criticité d'un worker pour le calcul de la santé de son module propriétaire.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum WorkerCriticality {
    /// Worker indispensable au bon fonctionnement du module. S'il échoue, le module devient `Unhealthy`.
    #[default]
    Required,
    /// Worker auxiliaire / optionnel. S'il échoue, le module devient `Degraded`.
    Optional,
}

/// Descripteur statique et immuable définissant les propriétés d'un worker.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct WorkerDescriptor {
    /// Identifiant canonique unique du worker (`<module-id>:<worker-name>`).
    pub id: WorkerId,
    /// Identifiant du module propriétaire.
    pub module_id: ModuleId,
    /// Nom lisible du worker.
    pub name: String,
    /// Description optionnelle du rôle du worker.
    pub description: Option<String>,
    /// Niveau de criticité du worker pour la santé globale.
    pub criticality: WorkerCriticality,
    /// Politique de redémarrage appliquée par le `WorkerSupervisor`.
    pub restart_policy: RestartPolicy,
    /// Délai maximal accordé au worker pour terminer son travail lors d'un arrêt gracieux.
    pub shutdown_timeout: Duration,
}

impl WorkerDescriptor {
    /// Crée un nouveau descripteur avec les valeurs par défaut canoniques.
    pub fn new(id: WorkerId, module_id: ModuleId, name: impl Into<String>) -> Self {
        Self {
            id,
            module_id,
            name: name.into(),
            description: None,
            criticality: WorkerCriticality::Required,
            restart_policy: RestartPolicy::default(),
            shutdown_timeout: Duration::from_secs(5),
        }
    }

    /// Associe une description fonctionnelle au worker.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = Some(description.into());
        self
    }

    /// Définit le niveau de criticité du worker.
    pub fn with_criticality(mut self, criticality: WorkerCriticality) -> Self {
        self.criticality = criticality;
        self
    }

    /// Définit la politique de redémarrage.
    pub fn with_restart_policy(mut self, restart_policy: RestartPolicy) -> Self {
        self.restart_policy = restart_policy;
        self
    }

    /// Définit le délai d'arrêt gracieux.
    pub fn with_shutdown_timeout(mut self, timeout: Duration) -> Self {
        self.shutdown_timeout = timeout;
        self
    }
}
