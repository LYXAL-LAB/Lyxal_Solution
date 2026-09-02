use crate::error::RuntimeError;
use serde::{Deserialize, Serialize};
use std::fmt;
use std::ops::Deref;

/// Identifiant typé, stable et comparable d'une migration de schéma (ex: "001_initial_schema", "002_add_indexes").
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct MigrationId(String);

impl MigrationId {
    /// Crée et valide un nouvel identifiant de migration.
    ///
    /// L'identifiant ne doit pas être vide et doit contenir exclusivement des caractères
    /// alphanumériques ASCII, des underscores (`_`) ou des tirets (`-`).
    pub fn new(id: impl Into<String>) -> Result<Self, RuntimeError> {
        let raw = id.into().trim().to_string();
        if raw.is_empty() {
            return Err(RuntimeError::InvalidMigrationId {
                id: raw,
                reason: "Migration identifier cannot be empty".to_string(),
            });
        }

        let is_valid = raw
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '-');

        if !is_valid {
            return Err(RuntimeError::InvalidMigrationId {
                id: raw,
                reason: "Migration identifier must only contain ASCII alphanumeric, '_', or '-' characters"
                    .to_string(),
            });
        }

        Ok(Self(raw))
    }

    /// Retourne la référence sous forme de slice str.
    pub fn as_str(&self) -> &str {
        &self.0
    }

    /// Tente d'extraire le numéro de séquence initial si l'identifiant commence par des chiffres (ex: "001_init" -> 1).
    pub fn sequence_number(&self) -> Option<u64> {
        let digits: String = self.0.chars().take_while(|c| c.is_ascii_digit()).collect();
        if digits.is_empty() {
            None
        } else {
            digits.parse::<u64>().ok()
        }
    }
}

impl Deref for MigrationId {
    type Target = str;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<str> for MigrationId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for MigrationId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}
