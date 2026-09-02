use serde::{Deserialize, Serialize};
use std::fmt;
use std::ops::Deref;

/// Identifiant unique et immuable d'un module Lyxal OS (ex: "timezone", "scheduler", "booking").
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct ModuleId(String);

impl ModuleId {
    /// Crée un nouvel identifiant de module après normalisation.
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into().trim().to_lowercase())
    }

    /// Retourne la référence sous forme de slice str.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Deref for ModuleId {
    type Target = str;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<str> for ModuleId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for ModuleId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<&str> for ModuleId {
    fn from(s: &str) -> Self {
        Self::new(s)
    }
}

impl From<String> for ModuleId {
    fn from(s: String) -> Self {
        Self::new(s)
    }
}

/// États officiels du cycle de vie d'un module dans Lyxal OS.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ModuleState {
    /// Module enregistré dans le registre runtime, non encore installé.
    Registered,
    /// Installation en cours.
    Installing,
    /// Module installé avec succès.
    Installed,
    /// Démarrage des services en cours.
    Starting,
    /// Module actif et opérationnel.
    Running,
    /// Arrêt des services en cours.
    Stopping,
    /// Module arrêté proprement.
    Stopped,
    /// Échec survenu durant une transition.
    Failed {
        error: String,
        previous_state: Box<ModuleState>,
    },
}

impl ModuleState {
    /// Crée un état d'échec avec mémorisation de l'état d'origine.
    pub fn failed(error: impl Into<String>, previous: ModuleState) -> Self {
        Self::Failed {
            error: error.into(),
            previous_state: Box::new(previous),
        }
    }

    /// Indique si le module est enregistré (non encore installé).
    pub fn is_registered(&self) -> bool {
        matches!(self, Self::Registered)
    }

    /// Indique si le module est installé ou prêt à démarrer.
    pub fn is_installed(&self) -> bool {
        matches!(self, Self::Installed)
    }

    /// Indique si le module est en cours d'exécution actif.
    pub fn is_running(&self) -> bool {
        matches!(self, Self::Running)
    }

    /// Indique si le module est arrêté.
    pub fn is_stopped(&self) -> bool {
        matches!(self, Self::Stopped)
    }

    /// Indique si le module est en état d'erreur.
    pub fn is_failed(&self) -> bool {
        matches!(self, Self::Failed { .. })
    }

    /// Vérifie si la transition vers l'état cible est permise par la machine d'état.
    pub fn can_transition_to(&self, next: &ModuleState) -> bool {
        match (self, next) {
            // De Registered -> Installing ou Failed
            (Self::Registered, Self::Installing) => true,
            // De Installing -> Installed ou Failed
            (Self::Installing, Self::Installed) => true,
            // De Installed -> Starting ou Installing (réinstallation) ou Failed
            (Self::Installed, Self::Starting) => true,
            (Self::Installed, Self::Installing) => true,
            // De Starting -> Running ou Failed
            (Self::Starting, Self::Running) => true,
            // De Running -> Stopping ou Failed
            (Self::Running, Self::Stopping) => true,
            // De Stopping -> Stopped ou Failed
            (Self::Stopping, Self::Stopped) => true,
            // De Stopped -> Starting ou Installing ou Failed
            (Self::Stopped, Self::Starting) => true,
            (Self::Stopped, Self::Installing) => true,
            // Depuis un état Failed, on peut tenter une réinstallation ou un redémarrage
            (Self::Failed { .. }, Self::Installing) => true,
            (Self::Failed { .. }, Self::Starting) => true,
            // Toute transition vers Failed est permise
            (_, Self::Failed { .. }) => true,
            // Reste des transitions interdites
            _ => false,
        }
    }
}

impl fmt::Display for ModuleState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Registered => write!(f, "Registered"),
            Self::Installing => write!(f, "Installing"),
            Self::Installed => write!(f, "Installed"),
            Self::Starting => write!(f, "Starting"),
            Self::Running => write!(f, "Running"),
            Self::Stopping => write!(f, "Stopping"),
            Self::Stopped => write!(f, "Stopped"),
            Self::Failed {
                error,
                previous_state,
            } => {
                write!(f, "Failed(from: {}, err: {})", previous_state, error)
            }
        }
    }
}
