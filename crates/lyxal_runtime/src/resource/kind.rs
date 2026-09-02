use serde::{Deserialize, Serialize};
use std::cmp::Ordering;
use std::fmt;

/// Classification officielle des ressources SurrealQL d'un module Lyxal OS.
///
/// L'ordre des variantes respecte la constitution d'architecture de Lyxal OS :
/// `Tables -> Fields -> Indexes -> Functions -> Permissions -> Events -> Seeds`.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum ResourceKind {
    /// Définitions de tables (`schema/tables.surql`)
    Tables,
    /// Définitions de champs typés (`schema/fields.surql`)
    Fields,
    /// Définitions d'index (`schema/indexes.surql`)
    Indexes,
    /// Fonctions métier SurrealQL (`schema/functions.surql`)
    Functions,
    /// Définitions de permissions / ACCESS (`schema/permissions.surql`)
    Permissions,
    /// Événements et déclencheurs (`schema/events.surql`)
    Events,
    /// Données initiales / démonstration (`schema/seeds.surql`)
    Seeds,
    /// Migration incrémentale versionnée (`migrations/*.surql`)
    Migration,
    /// Ressource personnalisée
    Custom(String),
}

impl ResourceKind {
    /// Retourne l'ordre de priorité d'exécution pour les ressources de schéma.
    pub fn execution_order(&self) -> u8 {
        match self {
            Self::Tables => 1,
            Self::Fields => 2,
            Self::Indexes => 3,
            Self::Functions => 4,
            Self::Permissions => 5,
            Self::Events => 6,
            Self::Seeds => 7,
            Self::Migration => 8,
            Self::Custom(_) => 9,
        }
    }

    /// Déduit le type de ressource à partir du nom de fichier standard.
    pub fn from_filename(filename: &str) -> Option<Self> {
        let raw = filename.trim().to_lowercase();
        let name = raw.strip_prefix("schema/").unwrap_or(&raw);
        if name == "tables.surql" || name.starts_with("tables/") {
            Some(Self::Tables)
        } else if name == "fields.surql" || name.starts_with("fields/") {
            Some(Self::Fields)
        } else if name == "indexes.surql" || name.starts_with("indexes/") {
            Some(Self::Indexes)
        } else if name == "functions.surql" || name.starts_with("functions/") {
            Some(Self::Functions)
        } else if name == "permissions.surql" || name.starts_with("permissions/") {
            Some(Self::Permissions)
        } else if name == "events.surql" || name.starts_with("events/") {
            Some(Self::Events)
        } else if name == "seeds.surql" || name.starts_with("seeds/") {
            Some(Self::Seeds)
        } else if name.ends_with(".surql") {
            Some(Self::Migration)
        } else {
            None
        }
    }
}

impl PartialOrd for ResourceKind {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for ResourceKind {
    fn cmp(&self, other: &Self) -> Ordering {
        self.execution_order().cmp(&other.execution_order())
    }
}

impl fmt::Display for ResourceKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Tables => write!(f, "Tables"),
            Self::Fields => write!(f, "Fields"),
            Self::Indexes => write!(f, "Indexes"),
            Self::Functions => write!(f, "Functions"),
            Self::Permissions => write!(f, "Permissions"),
            Self::Events => write!(f, "Events"),
            Self::Seeds => write!(f, "Seeds"),
            Self::Migration => write!(f, "Migration"),
            Self::Custom(name) => write!(f, "Custom({})", name),
        }
    }
}
