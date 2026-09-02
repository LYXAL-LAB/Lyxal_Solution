use crate::worker::state::WorkerExitReason;
use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Configuration du backoff exponentiel pour les redémarrages de workers.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct WorkerRestartBackoff {
    /// Délai initial avant la première tentative de redémarrage.
    pub initial_delay: Duration,
    /// Plafond maximal du délai entre deux redémarrages.
    pub max_delay: Duration,
    /// Facteur multiplicateur pour chaque échec consécutif (ex: 2.0).
    pub factor: f64,
}

impl Default for WorkerRestartBackoff {
    fn default() -> Self {
        Self {
            initial_delay: Duration::from_millis(500),
            max_delay: Duration::from_secs(30),
            factor: 2.0,
        }
    }
}

impl WorkerRestartBackoff {
    /// Crée une nouvelle configuration de backoff.
    pub fn new(initial_delay: Duration, max_delay: Duration, factor: f64) -> Self {
        Self {
            initial_delay,
            max_delay,
            factor: factor.max(1.0),
        }
    }

    /// Calcule le délai de redémarrage pour une tentative donnée (indexée à partir de 1).
    pub fn calculate_delay(&self, attempt: u32) -> Duration {
        if attempt <= 1 {
            return self.initial_delay.min(self.max_delay);
        }

        let power = (attempt - 1) as i32;
        let multiplier = self.factor.powi(power);
        let base_millis = self.initial_delay.as_millis() as f64;
        let calculated_millis = (base_millis * multiplier) as u64;

        Duration::from_millis(calculated_millis).min(self.max_delay)
    }
}

/// Politique de redémarrage d'un worker en cas d'interruption ou d'échec.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum RestartPolicy {
    /// Ne redémarre jamais le worker, quelle que soit la raison de sortie.
    Never,

    /// Redémarre le worker uniquement en cas de défaillance (Failed, Panicked, ForcedAbort).
    OnFailure {
        /// Nombre maximal de tentatives consécutives avant abandon.
        max_retries: u32,
        /// Stratégie de temporisation entre tentatives.
        backoff: WorkerRestartBackoff,
    },

    /// Redémarre toujours le worker (même après une sortie propre `Completed`).
    Always {
        /// Nombre maximal de tentatives (ou `None` pour un redémarrage perpétuel).
        max_retries: Option<u32>,
        /// Stratégie de temporisation entre tentatives.
        backoff: WorkerRestartBackoff,
    },
}

impl Default for RestartPolicy {
    fn default() -> Self {
        Self::OnFailure {
            max_retries: 5,
            backoff: WorkerRestartBackoff::default(),
        }
    }
}

impl RestartPolicy {
    /// Détermine si un redémarrage doit être initié selon la cause de sortie et le compteur de tentatives.
    pub fn should_restart(&self, exit_reason: &WorkerExitReason, current_retries: u32) -> bool {
        match self {
            Self::Never => false,
            Self::OnFailure { max_retries, .. } => {
                // Si annulé volontairement par le Runtime, pas de redémarrage
                if matches!(exit_reason, WorkerExitReason::Cancelled) {
                    return false;
                }
                // Redémarrage uniquement si sortie en défaillance
                if exit_reason.is_failure() {
                    current_retries < *max_retries
                } else {
                    false
                }
            }
            Self::Always { max_retries, .. } => {
                // Si annulé volontairement par le Runtime, pas de redémarrage
                if matches!(exit_reason, WorkerExitReason::Cancelled) {
                    return false;
                }
                if let Some(limit) = max_retries {
                    current_retries < *limit
                } else {
                    true
                }
            }
        }
    }

    /// Retourne la configuration de backoff si la politique en prévoit une.
    pub fn backoff(&self) -> Option<&WorkerRestartBackoff> {
        match self {
            Self::Never => None,
            Self::OnFailure { backoff, .. } => Some(backoff),
            Self::Always { backoff, .. } => Some(backoff),
        }
    }
}
