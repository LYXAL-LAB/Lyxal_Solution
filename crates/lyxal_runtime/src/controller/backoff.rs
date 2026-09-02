use crate::controller::config::ReconciliationLoopConfig;
use std::time::Duration;

/// Gestionnaire de temporisation et de repli exponentiel borné (*exponential backoff*).
#[derive(Debug, Clone)]
pub struct ReconciliationBackoff {
    config: ReconciliationLoopConfig,
    consecutive_failures: u32,
}

impl ReconciliationBackoff {
    /// Construit une nouvelle instance de calcul de backoff.
    pub fn new(config: ReconciliationLoopConfig) -> Self {
        Self {
            config,
            consecutive_failures: 0,
        }
    }

    /// Retourne le nombre d'échecs consécutifs actuels.
    pub fn consecutive_failures(&self) -> u32 {
        self.consecutive_failures
    }

    /// Calcule le prochain délai d'attente.
    ///
    /// Règles formelles CTO :
    /// - `failures == 0` $\to$ retourne `config.interval`.
    /// - `failures > 0` $\to$ retourne `max(interval, base_backoff * factor^(failures - 1))` plafonné à `max_backoff`.
    pub fn next_delay(&self) -> Duration {
        if self.consecutive_failures == 0 {
            return self.config.interval;
        }

        let base_secs = self.config.base_backoff.as_secs_f64();
        let exponent = (self.consecutive_failures - 1) as i32;
        let factor = self.config.backoff_factor;
        let computed = base_secs * factor.powi(exponent);

        let nominal_secs = self.config.interval.as_secs_f64();
        let max_secs = self.config.max_backoff.as_secs_f64();

        let effective = computed.max(nominal_secs).min(max_secs);
        Duration::from_secs_f64(effective)
    }

    /// Notifie un succès technique du cycle $\to$ réinitialise le compteur d'échecs.
    pub fn on_success(&mut self) {
        self.consecutive_failures = 0;
    }

    /// Notifie un échec technique d'infrastructure $\to$ incrémente le compteur d'échecs.
    pub fn on_failure(&mut self) {
        self.consecutive_failures = self.consecutive_failures.saturating_add(1);
    }
}
