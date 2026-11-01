use serde::{Deserialize, Serialize};
use std::fmt;
use surrealdb::types::{Error as SurrealTypeError, Kind, SurrealValue, Value};
use uuid::Uuid;

/// Implémente `SurrealValue` pour un identifiant UUID typé, stocké en base sous forme de chaîne
/// (`TYPE string` dans `schema/event_outbox.surql`).
macro_rules! impl_uuid_string_surreal_value {
    ($ty:ident) => {
        impl SurrealValue for $ty {
            fn kind_of() -> Kind {
                String::kind_of()
            }

            fn into_value(self) -> Value {
                Value::String(self.0.to_string())
            }

            fn from_value(value: Value) -> Result<Self, SurrealTypeError> {
                let raw = String::from_value(value)?;
                Uuid::parse_str(&raw).map(Self).map_err(|e| {
                    SurrealTypeError::validation(
                        format!("{} invalide '{raw}' : {e}", stringify!($ty)),
                        None,
                    )
                })
            }
        }
    };
}

/// Identifiant unique d'événement (UUIDv7).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct EventId(pub Uuid);

impl EventId {
    /// Génère un nouvel identifiant d'événement UUIDv7.
    #[must_use]
    pub fn new() -> Self {
        Self(Uuid::now_v7())
    }

    /// Crée un EventId à partir d'un UUID existant.
    #[must_use]
    pub fn from_uuid(uuid: Uuid) -> Self {
        Self(uuid)
    }

    /// Retourne l'UUID sous-jacent.
    #[must_use]
    pub fn as_uuid(&self) -> Uuid {
        self.0
    }
}

impl Default for EventId {
    fn default() -> Self {
        Self::new()
    }
}

impl fmt::Display for EventId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Identifiant de corrélation pour le traçage distribué des événements.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct CorrelationId(pub Uuid);

impl CorrelationId {
    /// Génère un nouveau CorrelationId UUIDv7.
    #[must_use]
    pub fn new() -> Self {
        Self(Uuid::now_v7())
    }

    /// Crée un CorrelationId à partir d'un UUID existant.
    #[must_use]
    pub fn from_uuid(uuid: Uuid) -> Self {
        Self(uuid)
    }

    /// Retourne l'UUID sous-jacent.
    #[must_use]
    pub fn as_uuid(&self) -> Uuid {
        self.0
    }
}

impl Default for CorrelationId {
    fn default() -> Self {
        Self::new()
    }
}

impl fmt::Display for CorrelationId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Identifiant de causalité reliant un événement à son déclencheur parent.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct CausationId(pub Uuid);

impl CausationId {
    /// Crée un CausationId à partir d'un UUID existant.
    #[must_use]
    pub fn from_uuid(uuid: Uuid) -> Self {
        Self(uuid)
    }

    /// Retourne l'UUID sous-jacent.
    #[must_use]
    pub fn as_uuid(&self) -> Uuid {
        self.0
    }
}

impl fmt::Display for CausationId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl_uuid_string_surreal_value!(EventId);
impl_uuid_string_surreal_value!(CorrelationId);
impl_uuid_string_surreal_value!(CausationId);
