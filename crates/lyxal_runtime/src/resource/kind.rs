use serde::{Deserialize, Serialize};
use std::fmt;

/// Phase d'installation d'une ressource, déduite de la section de `[resources]` qui la déclare.
///
/// L'ordre des variantes est l'ordre d'installation : `Schema`, `Function`, `ErrorDefinition`,
/// `Event`, `Seed`. Les migrations sont appliquées à part, par le moteur de migration.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub enum ResourceKind {
    /// `resources.schemas` : tables, champs, index.
    Schema,
    /// `resources.functions` : fonctions SurrealQL.
    Function,
    /// `resources.error_definitions` : définitions d'erreurs (master data).
    ErrorDefinition,
    /// `resources.events` : `DEFINE EVENT`.
    Event,
    /// `resources.seeds` : données initiales rejouables.
    Seed,
    /// `resources.migrations` : migrations versionnées.
    Migration,
}

impl fmt::Display for ResourceKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Schema => "schema",
            Self::Function => "function",
            Self::ErrorDefinition => "error_definition",
            Self::Event => "event",
            Self::Seed => "seed",
            Self::Migration => "migration",
        };
        f.write_str(name)
    }
}
