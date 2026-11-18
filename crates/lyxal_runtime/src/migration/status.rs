use serde::{Deserialize, Serialize};
use std::fmt;

/// Statut du cycle de vie d'une migration de schéma.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum MigrationStatus {
    /// Migration découverte mais pas encore exécutée.
    Pending,
    /// Migration en cours d'application dans la base de données.
    Applying,
    /// Migration appliquée avec succès.
    Applied,
    /// Échec survenu durant l'application de la migration.
    Failed,
    /// Migration annulée / restaurée.
    RolledBack,
    /// Migration ignorée (ex: migration conditionnelle non requise).
    Skipped,
    /// Migration interrompue que l'exploitant a décidé de rejouer
    /// (`fn::runtime_migration_resolve`, action `retry`) : rejouée à la prochaine installation.
    RetryRequested,
    /// Migration interrompue que l'exploitant a abandonnée (action `abandon`) : l'installation
    /// du module est refusée tant qu'une décision `retry` ne l'a pas remise à rejouer.
    Abandoned,
}

impl MigrationStatus {
    /// Indique si la migration est en attente d'exécution.
    pub fn is_pending(&self) -> bool {
        matches!(self, Self::Pending)
    }

    /// Indique si la migration a été appliquée avec succès.
    pub fn is_applied(&self) -> bool {
        matches!(self, Self::Applied)
    }

    /// Indique si la migration a échoué.
    pub fn is_failed(&self) -> bool {
        matches!(self, Self::Failed)
    }

    /// Indique si l'exploitant a demandé de rejouer la migration interrompue.
    pub fn is_retry_requested(&self) -> bool {
        matches!(self, Self::RetryRequested)
    }

    /// Indique si l'exploitant a abandonné la migration interrompue.
    pub fn is_abandoned(&self) -> bool {
        matches!(self, Self::Abandoned)
    }
}

impl fmt::Display for MigrationStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Pending => write!(f, "Pending"),
            Self::Applying => write!(f, "Applying"),
            Self::Applied => write!(f, "Applied"),
            Self::Failed => write!(f, "Failed"),
            Self::RolledBack => write!(f, "RolledBack"),
            Self::Skipped => write!(f, "Skipped"),
            Self::RetryRequested => write!(f, "RetryRequested"),
            Self::Abandoned => write!(f, "Abandoned"),
        }
    }
}
