use crate::error::LyxalEventError;
use crate::handler::Event;
use serde::{Deserialize, Serialize};
use surrealdb::sql::{Datetime, Thing as RecordId};
use uuid::Uuid;

/// Contexte d'instance et d'isolation multi-tenant pour le routage des événements.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct EventContext {
    /// Identifiant de l'instance Lyxal OS (ex: "inst_alpha").
    pub instance_id: String,
    /// Namespace SurrealDB associé (ex: "client_acme").
    pub namespace: String,
    /// Base de données SurrealDB associée (ex: "production").
    pub database: String,
}

impl EventContext {
    /// Crée un nouveau contexte d'événement complet.
    #[must_use]
    pub fn new(
        instance_id: impl Into<String>,
        namespace: impl Into<String>,
        database: impl Into<String>,
    ) -> Self {
        Self {
            instance_id: instance_id.into(),
            namespace: namespace.into(),
            database: database.into(),
        }
    }

    /// Contexte par défaut pour les environnements de test ou monolithiques.
    #[must_use]
    pub fn default_context() -> Self {
        Self {
            instance_id: "default".to_string(),
            namespace: "default".to_string(),
            database: "default".to_string(),
        }
    }
}

impl Default for EventContext {
    fn default() -> Self {
        Self::default_context()
    }
}

pub mod uuid_serde {
    use serde::{self, Deserialize, Deserializer, Serializer};
    use uuid::Uuid;

    pub fn serialize<S>(uuid: &Uuid, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&uuid.to_string())
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Uuid, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(untagged)]
        enum UuidRepr {
            Str(String),
            Bytes(Vec<u8>),
            Uuid(Uuid),
        }

        match UuidRepr::deserialize(deserializer)? {
            UuidRepr::Str(s) => Uuid::parse_str(&s).map_err(serde::de::Error::custom),
            UuidRepr::Bytes(b) => {
                if b.len() == 16 {
                    let mut arr = [0u8; 16];
                    arr.copy_from_slice(&b);
                    Ok(Uuid::from_bytes(arr))
                } else {
                    Uuid::parse_str(&String::from_utf8_lossy(&b)).map_err(serde::de::Error::custom)
                }
            }
            UuidRepr::Uuid(u) => Ok(u),
        }
    }
}

pub mod opt_uuid_serde {
    use serde::{self, Deserialize, Deserializer, Serializer};
    use uuid::Uuid;

    pub fn serialize<S>(uuid: &Option<Uuid>, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        match uuid {
            Some(u) => serializer.serialize_some(&u.to_string()),
            None => serializer.serialize_none(),
        }
    }

    pub fn deserialize<'de, D>(deserializer: D) -> Result<Option<Uuid>, D::Error>
    where
        D: Deserializer<'de>,
    {
        #[derive(Deserialize)]
        #[serde(untagged)]
        enum OptUuidRepr {
            Str(String),
            Bytes(Vec<u8>),
            Uuid(Uuid),
            None,
        }

        let opt: Option<OptUuidRepr> = Option::deserialize(deserializer)?;
        match opt {
            Some(OptUuidRepr::Str(s)) if !s.is_empty() => Uuid::parse_str(&s)
                .map(Some)
                .map_err(serde::de::Error::custom),
            Some(OptUuidRepr::Bytes(b)) => {
                if b.len() == 16 {
                    let mut arr = [0u8; 16];
                    arr.copy_from_slice(&b);
                    Ok(Some(Uuid::from_bytes(arr)))
                } else {
                    Uuid::parse_str(&String::from_utf8_lossy(&b))
                        .map(Some)
                        .map_err(serde::de::Error::custom)
                }
            }
            Some(OptUuidRepr::Uuid(u)) => Ok(Some(u)),
            _ => Ok(None),
        }
    }
}

/// Enveloppe canonique universelle d'un événement au sein de Lyxal OS.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyxalEventEnvelope {
    /// Identifiant de l'enregistrement dans la table event_outbox (si persisté).
    #[serde(default)]
    pub id: Option<RecordId>,
    /// Identifiant unique d'événement (UUIDv7).
    #[serde(with = "uuid_serde")]
    pub event_id: Uuid,
    /// Nom de domaine qualifié de l'événement (ex: "booking.created").
    pub event_type: String,
    /// Version de schéma de l'événement.
    #[serde(default = "default_version")]
    pub version: u32,
    /// Module producteur ayant émis l'événement.
    #[serde(default)]
    pub producer: String,
    /// Enregistrement source à l'origine de la mutation (optionnel).
    #[serde(default)]
    pub source: Option<RecordId>,
    /// Contexte d'isolation de l'instance.
    pub context: EventContext,
    /// Identifiant de corrélation pour le traçage distribué.
    #[serde(with = "uuid_serde")]
    pub correlation_id: Uuid,
    /// Identifiant de causalité reliant l'événement à son déclencheur parent.
    #[serde(default, with = "opt_uuid_serde")]
    pub causation_id: Option<Uuid>,
    /// Données métier sérialisées au format JSON.
    pub payload: serde_json::Value,
    /// Métadonnées transversales (acteur, client, trace headers).
    #[serde(default)]
    pub metadata: serde_json::Value,
    /// Horodatage UTC de création.
    #[serde(default)]
    pub created_at: Datetime,
}

fn default_version() -> u32 {
    1
}

impl LyxalEventEnvelope {
    /// Construit une nouvelle enveloppe à partir d'un événement typé.
    pub fn new<E: Event>(
        producer: impl Into<String>,
        context: EventContext,
        event: &E,
    ) -> Result<Self, LyxalEventError> {
        let event_id = Uuid::now_v7();
        let payload = serde_json::to_value(event)?;
        Ok(Self {
            id: None,
            event_id,
            event_type: E::EVENT_TYPE.to_string(),
            version: 1,
            producer: producer.into(),
            source: None,
            context,
            correlation_id: event_id,
            causation_id: None,
            payload,
            metadata: serde_json::json!({}),
            created_at: Datetime::default(),
        })
    }

    /// Associe un identifiant de corrélation spécifique.
    #[must_use]
    pub fn with_correlation_id(mut self, correlation_id: Uuid) -> Self {
        self.correlation_id = correlation_id;
        self
    }

    /// Associe un identifiant de causalité parent.
    #[must_use]
    pub fn with_causation_id(mut self, causation_id: Uuid) -> Self {
        self.causation_id = Some(causation_id);
        self
    }

    /// Associe un enregistrement source d'origine.
    #[must_use]
    pub fn with_source(mut self, source: RecordId) -> Self {
        self.source = Some(source);
        self
    }

    /// Associe des métadonnées transversales.
    #[must_use]
    pub fn with_metadata(mut self, metadata: serde_json::Value) -> Self {
        self.metadata = metadata;
        self
    }

    /// Décode le payload JSON dans le type d'événement strongly-typed `E`.
    pub fn decode<E: Event>(&self) -> Result<E, LyxalEventError> {
        if self.event_type != E::EVENT_TYPE {
            return Err(LyxalEventError::TypeMismatch {
                expected: E::EVENT_TYPE,
                actual: self.event_type.clone(),
            });
        }
        serde_json::from_value(self.payload.clone()).map_err(LyxalEventError::from)
    }
}
