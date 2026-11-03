use serde::{Deserialize, Serialize};
use std::fmt;
use std::ops::Deref;

/// Identifiant unique et fortement typé d'un événement interne du Runtime.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct RuntimeEventId(String);

impl RuntimeEventId {
    /// Crée un `RuntimeEventId` à partir d'une chaîne arbitraire validée.
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into().trim().to_string())
    }

    /// Génère un nouvel identifiant d'événement unique (UUID v7, ordonné dans le temps).
    pub fn generate() -> Self {
        Self(format!("evt-{}", uuid::Uuid::now_v7().simple()))
    }

    /// Retourne la représentation textuelle sous forme de `&str`.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Deref for RuntimeEventId {
    type Target = str;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<str> for RuntimeEventId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for RuntimeEventId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<&str> for RuntimeEventId {
    fn from(s: &str) -> Self {
        Self::new(s)
    }
}

impl From<String> for RuntimeEventId {
    fn from(s: String) -> Self {
        Self::new(s)
    }
}
