use crate::migration::MigrationId;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};
use std::fmt;

/// Clé canonique désignant l'unité logique protégée par un verrou de migration.
///
/// La granularité standard est `module_id + migration_id` (ex: `lyxal-booking:001_initial_schema`).
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct MigrationLockKey {
    pub module_id: ModuleId,
    pub migration_id: MigrationId,
}

impl MigrationLockKey {
    /// Crée une nouvelle clé de verrou de migration.
    pub fn new(module_id: impl Into<ModuleId>, migration_id: MigrationId) -> Self {
        Self {
            module_id: module_id.into(),
            migration_id,
        }
    }

    /// Retourne la chaîne canonique unique associée à cette clé.
    pub fn canonical_string(&self) -> String {
        format!("{}:{}", self.module_id.as_str(), self.migration_id.as_str())
    }
}

impl fmt::Display for MigrationLockKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.canonical_string())
    }
}
