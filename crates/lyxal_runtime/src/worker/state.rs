use serde::{Deserialize, Serialize};
use std::fmt;

/// Machine d'état formelle du cycle de vie d'un worker supervisé.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum WorkerState {
    /// Le worker est enregistré mais n'a pas encore démarré.
    Registered,
    /// Le worker est en cours d'initialisation et de démarrage.
    Starting,
    /// Le worker est actif et en cours d'exécution continue.
    Running,
    /// Le worker a reçu un signal d'arrêt gracieux (`cancellation.cancel()`).
    Stopping,
    /// Le worker est complètement arrêté (proprement ou après forçage).
    Stopped,
    /// Le worker a rencontré un incident et attend l'échéance de son backoff de redémarrage.
    Restarting,
    /// Le worker est en échec terminal (restart policy épuisée ou `Never`).
    Failed,
}

impl WorkerState {
    /// Retourne la représentation textuelle canonique.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Registered => "registered",
            Self::Starting => "starting",
            Self::Running => "running",
            Self::Stopping => "stopping",
            Self::Stopped => "stopped",
            Self::Restarting => "restarting",
            Self::Failed => "failed",
        }
    }

    /// Indique si le worker est dans une phase active (Starting, Running, Restarting).
    pub fn is_active(&self) -> bool {
        matches!(self, Self::Starting | Self::Running | Self::Restarting)
    }

    /// Indique si le worker est dans une phase d'inactivité terminale ou au repos (Registered, Stopped, Failed).
    pub fn is_inactive(&self) -> bool {
        matches!(self, Self::Registered | Self::Stopped | Self::Failed)
    }

    /// Valide si la transition d'état demandée est autorisée par la charte d'architecture.
    pub fn can_transition_to(&self, next: &WorkerState) -> bool {
        match (self, next) {
            // Démarrage initial ou redémarrage
            (Self::Registered, Self::Starting) => true,
            (Self::Stopped, Self::Starting) => true,
            (Self::Failed, Self::Starting) => true, // Relance manuelle explicite

            // Progression du démarrage
            (Self::Starting, Self::Running) => true,
            (Self::Starting, Self::Stopping) => true, // Arrêt pendant démarrage
            (Self::Starting, Self::Failed) => true,   // Échec immédiat
            (Self::Starting, Self::Restarting) => true,

            // Exécution normale vers arrêt ou échec
            (Self::Running, Self::Stopping) => true,
            (Self::Running, Self::Stopped) => true, // Sortie spontanée propre
            (Self::Running, Self::Failed) => true,
            (Self::Running, Self::Restarting) => true,

            // Arrêt en cours vers état arrêté
            (Self::Stopping, Self::Stopped) => true,
            (Self::Stopping, Self::Failed) => true,

            // Backoff de redémarrage
            (Self::Restarting, Self::Starting) => true, // Relance après backoff
            (Self::Restarting, Self::Stopping) => true, // Arrêt demandé pendant le sommeil
            (Self::Restarting, Self::Stopped) => true,  // Arrêt direct
            (Self::Restarting, Self::Failed) => true,   // Abandon / épuisement

            // Auto-transition idempotente
            (a, b) if a == b => true,

            _ => false,
        }
    }
}

impl fmt::Display for WorkerState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Cause explicite de fin d'exécution d'un worker.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum WorkerExitReason {
    /// Le worker s'est terminé avec succès (`Ok(())`) sans demande d'arrêt.
    Completed,
    /// Le worker s'est arrêté en réponse au signal de `CancellationToken`.
    Cancelled,
    /// Le worker a retourné une erreur d'exécution (`Err(RuntimeError)`).
    Failed(String),
    /// Le worker a paniqué pendant son exécution.
    Panicked(String),
    /// Le worker a dépassé le `shutdown_timeout` et a été tué de force (`abort`).
    ForcedAbort,
}

impl WorkerExitReason {
    /// Retourne la représentation textuelle canonique de la raison de sortie.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Completed => "completed",
            Self::Cancelled => "cancelled",
            Self::Failed(_) => "failed",
            Self::Panicked(_) => "panicked",
            Self::ForcedAbort => "forced_abort",
        }
    }

    /// Indique si la sortie constitue une défaillance / anomalie (Failed, Panicked, ForcedAbort).
    pub fn is_failure(&self) -> bool {
        matches!(
            self,
            Self::Failed(_) | Self::Panicked(_) | Self::ForcedAbort
        )
    }
}

impl fmt::Display for WorkerExitReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Completed => write!(f, "completed"),
            Self::Cancelled => write!(f, "cancelled"),
            Self::Failed(msg) => write!(f, "failed: {}", msg),
            Self::Panicked(msg) => write!(f, "panicked: {}", msg),
            Self::ForcedAbort => write!(f, "forced_abort"),
        }
    }
}
