use crate::worker::descriptor::WorkerCriticality;
use crate::worker::id::WorkerId;
use crate::worker::state::WorkerState;
use serde::{Deserialize, Serialize};

/// Métriques légères et locales d'exécution d'un worker.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub struct WorkerMetrics {
    /// Timestamp Unix (secondes) du dernier démarrage.
    pub started_at: Option<u64>,
    /// Timestamp Unix (secondes) du dernier arrêt.
    pub stopped_at: Option<u64>,
    /// Nombre total de redémarrages automatiques effectués.
    pub restart_count: u64,
    /// Nombre total d'échecs (erreurs ou paniques) constatés.
    pub failure_count: u64,
    /// Timestamp Unix (secondes) du dernier incident survenu.
    pub last_failure_at: Option<u64>,
    /// Dernier message d'erreur ou de panique enregistré.
    pub last_error: Option<String>,
}

/// Instantané de santé et d'état opérationnel d'un worker pour l'agrégation `HealthEngine`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkerHealth {
    /// Identifiant du worker.
    pub worker_id: WorkerId,
    /// État d'exécution courant.
    pub state: WorkerState,
    /// Niveau de criticité du worker.
    pub criticality: WorkerCriticality,
    /// Nombre de redémarrages subis.
    pub restart_count: u64,
    /// Dernier message d'erreur s'il est en échec.
    pub last_error: Option<String>,
}
