use crate::health::snapshot::HealthSnapshot;
use crate::reconciler::actual::ActualRuntimeState;
use crate::reconciler::report::{ConvergenceStatus, ReconciliationReport};
use crate::worker::id::WorkerId;
use crate::worker::metrics::WorkerHealth;
use crate::worker::state::WorkerState;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

/// Résumé synthétique et léger d'un rapport de réconciliation (sans dépendances lourdes).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReconciliationReportSummary {
    /// Statut global de convergence.
    pub convergence: ConvergenceStatus,
    /// Nombre d'actions exécutées avec succès.
    pub executed_count: usize,
    /// Nombre d'actions ayant échoué.
    pub failed_count: usize,
    /// Nombre d'actions ignorées lors de la revalidation TOCTOU.
    pub skipped_count: usize,
    /// Nombre d'actions non tentées par cascade d'échec.
    pub not_attempted_count: usize,
    /// Durée totale de la passe en millisecondes.
    pub duration_ms: u64,
}

impl From<&ReconciliationReport> for ReconciliationReportSummary {
    fn from(report: &ReconciliationReport) -> Self {
        Self {
            convergence: report.convergence,
            executed_count: report.executed.len(),
            failed_count: report.failed.len(),
            skipped_count: report.skipped_revalidation.len(),
            not_attempted_count: report.not_attempted.len(),
            duration_ms: report.duration_ms,
        }
    }
}

/// Photographie globale de l'état du runtime, de sa santé, des workers et de la réconciliation.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeStatusSnapshot {
    /// État réel des modules observés sur le nœud.
    pub actual_state: ActualRuntimeState,
    /// Synthèse de santé des modules et santé globale.
    pub health_snapshot: HealthSnapshot,
    /// Résumé du dernier rapport de réconciliation (si une passe a été exécutée).
    pub last_report_summary: Option<ReconciliationReportSummary>,
    /// Horodatage de la dernière passe de réconciliation (format ISO 8601 UTC).
    pub last_reconciled_at: Option<String>,
    /// Compteur séquentiel du nombre total de passes exécutées.
    pub pass_count: u64,
    /// Nombre d'échecs consécutifs d'infrastructure enregistrés.
    pub consecutive_failures: u32,
    /// Numéro de révision du `DesiredRuntimeState` utilisé lors de cette passe.
    pub desired_revision: u64,
    /// États observés de tous les workers d'arrière-plan du nœud.
    #[serde(default)]
    pub worker_states: BTreeMap<WorkerId, WorkerState>,
    /// Instantané de santé de tous les workers du nœud.
    #[serde(default)]
    pub worker_health: BTreeMap<WorkerId, WorkerHealth>,
}
