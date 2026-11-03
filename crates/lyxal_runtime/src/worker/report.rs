use crate::types::ModuleId;
use crate::worker::id::WorkerId;
use crate::worker::state::WorkerState;
use serde::{Deserialize, Serialize};

/// Rapport d'opération individuelle sur un worker (démarrage, arrêt, redémarrage).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkerOperationReport {
    /// Identifiant du worker opéré.
    pub worker_id: WorkerId,
    /// État résultant du worker.
    pub state: WorkerState,
    /// Durée de l'opération en millisecondes.
    pub duration_ms: u64,
    /// Message d'erreur éventuel en cas d'anomalie.
    pub error: Option<String>,
}

/// Échec d'un worker lors d'une opération groupée.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkerFailure {
    /// Worker concerné.
    pub worker_id: WorkerId,
    /// Cause de l'échec.
    pub error: String,
}

/// Rapport synthétique d'opération groupée sur l'ensemble des workers d'un module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkerBatchReport {
    /// Identifiant du module cible.
    pub module_id: ModuleId,
    /// Liste des workers démarrés avec succès.
    pub started: Vec<WorkerId>,
    /// Liste des workers arrêtés avec succès.
    pub stopped: Vec<WorkerId>,
    /// Liste des workers ayant rencontré un échec, avec leur cause.
    pub failed: Vec<WorkerFailure>,
    /// Liste des workers déjà dans l'état désiré (opération omise par idempotence).
    pub skipped: Vec<WorkerId>,
    /// Durée totale du batch en millisecondes.
    pub duration_ms: u64,
}

impl WorkerBatchReport {
    /// Crée un rapport de batch vide pour un module donné.
    pub fn new(module_id: ModuleId) -> Self {
        Self {
            module_id,
            started: Vec::new(),
            stopped: Vec::new(),
            failed: Vec::new(),
            skipped: Vec::new(),
            duration_ms: 0,
        }
    }

    /// Indique si l'ensemble des opérations du batch s'est déroulé sans aucun échec.
    pub fn is_success(&self) -> bool {
        self.failed.is_empty()
    }
}
