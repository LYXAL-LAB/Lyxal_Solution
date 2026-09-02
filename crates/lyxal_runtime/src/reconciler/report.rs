use crate::error::RuntimeError;
use crate::reconciler::actual::ActualRuntimeState;
use crate::reconciler::desired::ModuleTargetState;
use crate::reconciler::plan::ActionKind;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Statut de convergence global obtenu à l'issue de la passe de réconciliation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ConvergenceStatus {
    /// L'état désiré est totalement satisfait pour tous les modules gérés (0 drift restant).
    Converged,
    /// Une partie a convergé, mais des facteurs bloquants ou échecs subsistent.
    PartiallyConverged,
    /// Aucune action utile n'a pu converger en raison d'échecs fondamentaux.
    Failed,
}

impl std::fmt::Display for ConvergenceStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Converged => write!(f, "Converged"),
            Self::PartiallyConverged => write!(f, "PartiallyConverged"),
            Self::Failed => write!(f, "Failed"),
        }
    }
}

/// Résultat d'exécution d'une action unitaire.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActionOutcome {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Nature de l'action exécutée.
    pub kind: ActionKind,
    /// Succès de l'exécution.
    pub success: bool,
}

/// Cause structurée d'abandon d'une action lors de la revalidation TOCTOU.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum SkippedRevalidationReason {
    /// L'état réel a déjà atteint la cible souhaitée (succès sans mutation).
    AlreadyConverged,
    /// L'action a été rendue obsolète par une action concurrente.
    SupersededByConcurrentAction,
    /// Une précondition obligatoire a été modifiée.
    PreconditionChanged { details: String },
}

/// Détail d'une action ignorée lors de la revalidation TOCTOU.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkippedRevalidationAction {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Nature de l'action planifiée qui a été ignorée.
    pub action_kind: ActionKind,
    /// Raison de l'abandon.
    pub reason: SkippedRevalidationReason,
}

/// Détail d'une action ayant échoué pendant l'application du plan.
#[derive(Debug)]
pub struct ReconciliationActionFailure {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Nature de l'action qui a échoué.
    pub action_kind: ActionKind,
    /// Erreur survenue.
    pub error: RuntimeError,
}

/// Détail d'une action qui n'a pas été tentée en raison de l'échec d'une dépendance.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotAttemptedAction {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Action initialement prévue.
    pub intended_action: ActionKind,
    /// Cause de la non-exécution.
    pub reason: String,
}

/// Élément de divergence résiduel (Drift) entre état désiré et état réel final.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DriftItem {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Cible souhaitée.
    pub desired: ModuleTargetState,
    /// État réel observé à la fin de la passe.
    pub actual: String,
}

/// Rapport structuré complet de la passe de réconciliation (One-Pass Reconciliation Report).
#[derive(Debug)]
pub struct ReconciliationReport {
    /// Nombre d'actions initialement planifiées.
    pub planned_actions: usize,
    /// Actions exécutées avec succès ou échec.
    pub executed: Vec<ActionOutcome>,
    /// Actions ignorées à la revalidation (TOCTOU).
    pub skipped_revalidation: Vec<SkippedRevalidationAction>,
    /// Actions ayant échoué.
    pub failed: Vec<ReconciliationActionFailure>,
    /// Actions non tentées (isolation des pannes).
    pub not_attempted: Vec<NotAttemptedAction>,
    /// Photographie de l'état réel final ré-observé à l'issue de la passe.
    pub final_state: ActualRuntimeState,
    /// Divergences restantes (Drift résiduel).
    pub remaining_drift: Vec<DriftItem>,
    /// Statut global de convergence.
    pub convergence: ConvergenceStatus,
    /// Durée totale de la passe de réconciliation en millisecondes.
    pub duration_ms: u64,
}

impl ReconciliationReport {
    /// Indique si la réconciliation est totalement convergée.
    pub fn is_converged(&self) -> bool {
        self.convergence == ConvergenceStatus::Converged
    }

    /// Indique si des erreurs sont survenues.
    pub fn has_failures(&self) -> bool {
        !self.failed.is_empty()
    }
}
