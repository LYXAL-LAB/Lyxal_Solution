use serde::{Deserialize, Serialize};
use std::fmt;

/// Catégorie fonctionnelle d'un événement émis par le Lyxal Runtime.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum RuntimeEventKind {
    /// Événements liés à l'enregistrement et aux métadonnées des modules.
    Module,
    /// Événements liés aux transitions du cycle de vie des modules.
    Lifecycle,
    /// Événements liés au pipeline d'installation et de release de packages.
    Installation,
    /// Événements liés à l'exécution et au verrouillage des migrations de schéma.
    Migration,
    /// Événements liés aux contrôles de santé et transitions de santé des modules.
    Health,
    /// Événements liés à la boucle de réconciliation continue et à l'alignement déclaratif.
    Reconciliation,
    /// Événements liés au superviseur et cycle de vie des workers d'arrière-plan.
    Worker,
    /// Événements liés au cycle de vie global du moteur Runtime local.
    Runtime,
}

impl RuntimeEventKind {
    /// Retourne la représentation textuelle canonique en minuscules.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Module => "module",
            Self::Lifecycle => "lifecycle",
            Self::Installation => "installation",
            Self::Migration => "migration",
            Self::Health => "health",
            Self::Reconciliation => "reconciliation",
            Self::Worker => "worker",
            Self::Runtime => "runtime",
        }
    }
}

impl fmt::Display for RuntimeEventKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.as_str())
    }
}
