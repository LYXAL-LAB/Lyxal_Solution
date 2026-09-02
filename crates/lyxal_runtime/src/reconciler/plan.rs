use crate::package::ModulePackage;
use crate::reconciler::desired::ModuleTargetState;
use crate::types::ModuleId;
use semver::Version;
use serde::{Deserialize, Serialize};

/// Raison structurée expliquant pourquoi une action de réconciliation ou un blocker est produit.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReconciliationReason {
    /// Cible souhaitée pour le module.
    pub desired: Option<ModuleTargetState>,
    /// Description de l'état réel observé.
    pub actual: String,
    /// Indique si cette exigence provient d'une dépendance implicite (closure).
    pub implicit: bool,
    /// Détails ou explications complémentaires.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub details: Option<String>,
}

impl ReconciliationReason {
    /// Crée une nouvelle raison de réconciliation.
    pub fn new(
        desired: Option<ModuleTargetState>,
        actual: impl Into<String>,
        implicit: bool,
    ) -> Self {
        Self {
            desired,
            actual: actual.into(),
            implicit,
            details: None,
        }
    }

    /// Associe des détails textuels à la raison.
    pub fn with_details(mut self, details: impl Into<String>) -> Self {
        self.details = Some(details.into());
        self
    }
}

/// Précondition nécessaire à l'exécution d'une action.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ActionPrecondition {
    /// Identifiant de la dépendance qui doit satisfaire la précondition.
    pub dependency_id: ModuleId,
    /// État cible requis pour cette dépendance.
    pub required_state: ModuleTargetState,
}

/// Type d'action opérationnelle mutationnelle planifiée.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ActionKind {
    /// Installer une nouvelle release candidate.
    Install { candidate_version: Version },
    /// Démarrer le module (`start_module`).
    Start,
    /// Arrêter le module (`stop_module`).
    Stop,
    /// Marquer le module comme inactif sans destruction.
    MarkInactive,
}

impl std::fmt::Display for ActionKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Install { candidate_version } => write!(f, "Install({})", candidate_version),
            Self::Start => write!(f, "Start"),
            Self::Stop => write!(f, "Stop"),
            Self::MarkInactive => write!(f, "MarkInactive"),
        }
    }
}

/// Action unitaire exécutable planifiée par le Reconciler.
#[derive(Clone)]
pub struct ReconciliationAction {
    /// Module concerné.
    pub module_id: ModuleId,
    /// Nature de l'action mutationnelle.
    pub kind: ActionKind,
    /// Justification diagnostique.
    pub reason: ReconciliationReason,
    /// Package disponible requis pour l'action `Install` (le cas échéant).
    pub package: Option<ModulePackage>,
    /// Préconditions d'exécution.
    pub preconditions: Vec<ActionPrecondition>,
}

impl PartialEq for ReconciliationAction {
    fn eq(&self, other: &Self) -> bool {
        self.module_id == other.module_id
            && self.kind == other.kind
            && self.reason == other.reason
            && self.preconditions == other.preconditions
            && match (&self.package, &other.package) {
                (Some(p1), Some(p2)) => p1.id() == p2.id() && p1.version() == p2.version(),
                (None, None) => true,
                _ => false,
            }
    }
}

impl Eq for ReconciliationAction {}

impl std::fmt::Debug for ReconciliationAction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ReconciliationAction")
            .field("module_id", &self.module_id)
            .field("kind", &self.kind)
            .field("reason", &self.reason)
            .field("has_package", &self.package.is_some())
            .field("preconditions", &self.preconditions)
            .finish()
    }
}

/// Classification des facteurs bloquants identifiés lors du planning DRA.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum BlockerKind {
    /// Aucun package candidat disponible pour satisfaire le module absent.
    MissingPackage,
    /// Aucun package candidat ne satisfait la contrainte SemVer ou de compatibilité Runtime.
    UnsatisfiedVersion,
    /// Tentative de rétrogradation automatique (downgrade) non supportée.
    UnsupportedDowngrade,
    /// Intervention manuelle d'un administrateur requise.
    ManualInterventionRequired,
    /// Conflit logique entre états souhaités déclarés et dépendances.
    DesiredStateConflict,
}

/// Facteur bloquant empêchant la convergence totale d'un module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReconciliationBlocker {
    /// Module concerné par le blocage.
    pub module_id: ModuleId,
    /// Type de blocage.
    pub kind: BlockerKind,
    /// Description explicative de la cause du blocage.
    pub reason: String,
}

impl ReconciliationBlocker {
    /// Crée un nouveau bloqueur.
    pub fn new(
        module_id: impl Into<ModuleId>,
        kind: BlockerKind,
        reason: impl Into<String>,
    ) -> Self {
        Self {
            module_id: module_id.into(),
            kind,
            reason: reason.into(),
        }
    }
}

/// Plan de réconciliation calculé par `RuntimeDiffer` (Dry-Run pur, zéro mutation).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReconciliationPlan {
    /// Actions opérationnelles mutationnelles à exécuter (strictement ordonnées).
    pub actions: Vec<ReconciliationAction>,
    /// Bloqueurs identifiés empêchant certaines branches de converger.
    pub blockers: Vec<ReconciliationBlocker>,
}

impl ReconciliationPlan {
    /// Crée un plan vide.
    pub fn new() -> Self {
        Self {
            actions: Vec::new(),
            blockers: Vec::new(),
        }
    }

    /// Indique si le plan ne contient aucune action mutationnelle.
    pub fn is_empty(&self) -> bool {
        self.actions.is_empty()
    }

    /// Indique si le plan est totalement convergé (0 actions et 0 bloqueurs).
    pub fn is_converged(&self) -> bool {
        self.actions.is_empty() && self.blockers.is_empty()
    }

    /// Indique si le plan comporte des facteurs bloquants.
    pub fn has_blockers(&self) -> bool {
        !self.blockers.is_empty()
    }

    /// Nombre total d'actions mutationnelles planifiées.
    pub fn actions_count(&self) -> usize {
        self.actions.len()
    }
}

impl Default for ReconciliationPlan {
    fn default() -> Self {
        Self::new()
    }
}
