use crate::error::RuntimeError;
use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Configuration du gestionnaire de verrous distribués de migration.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationLockConfig {
    /// Durée de validité initiale d'un bail (TTL).
    pub lease_duration: Duration,
    /// Intervalle de renouvellement périodique du bail pendant une exécution longue.
    pub renew_interval: Duration,
    /// Délai maximal d'attente lors de l'acquisition d'un verrou détenu par un tiers.
    pub acquire_timeout: Duration,
    /// Délai d'attente entre deux tentatives d'acquisition (backoff).
    pub acquire_retry_delay: Duration,
}

impl Default for MigrationLockConfig {
    fn default() -> Self {
        Self {
            lease_duration: Duration::from_secs(30),
            renew_interval: Duration::from_secs(10),
            acquire_timeout: Duration::from_secs(10),
            acquire_retry_delay: Duration::from_millis(100),
        }
    }
}

impl MigrationLockConfig {
    /// Valide la cohérence interne des durées configurées.
    pub fn validate(&self) -> Result<(), RuntimeError> {
        if self.lease_duration.is_zero() {
            return Err(RuntimeError::Internal {
                code: "RUNTIME_CONFIG_INVALID",
                message: "lease_duration cannot be zero".to_string(),
            });
        }

        if self.renew_interval >= self.lease_duration {
            return Err(RuntimeError::Internal {
                code: "RUNTIME_CONFIG_INVALID",
                message: "renew_interval must be strictly less than lease_duration".to_string(),
            });
        }

        if self.acquire_retry_delay.is_zero() {
            return Err(RuntimeError::Internal {
                code: "RUNTIME_CONFIG_INVALID",
                message: "acquire_retry_delay cannot be zero".to_string(),
            });
        }

        Ok(())
    }
}
