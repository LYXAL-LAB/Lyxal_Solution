use crate::error::LyxalEventError;
use crate::handler::Event;
use crate::types::{CausationId, CorrelationId, EventId};
use lyxal_surreal::{Datetime, RecordId, SurrealValue};
use serde::{Deserialize, Serialize};

/// Contexte d'instance et d'isolation multi-tenant pour le routage des événements.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
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

/// Enveloppe canonique universelle d'un événement au sein de Lyxal OS.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
pub struct LyxalEventEnvelope {
    /// Identifiant de l'enregistrement dans la table event_outbox (si persisté).
    #[serde(default)]
    #[surreal(default)]
    pub id: Option<RecordId>,
    /// Identifiant unique d'événement (UUIDv7).
    pub event_id: EventId,
    /// Nom de domaine qualifié de l'événement (ex: "booking.created").
    pub event_type: String,
    /// Version de schéma de l'événement.
    #[serde(default = "default_version")]
    #[surreal(default = "default_version")]
    pub version: u32,
    /// Module producteur ayant émis l'événement.
    #[serde(default)]
    #[surreal(default)]
    pub producer: String,
    /// Enregistrement source à l'origine de la mutation (optionnel).
    #[serde(default)]
    #[surreal(default)]
    pub source: Option<RecordId>,
    /// Contexte d'isolation de l'instance.
    pub context: EventContext,
    /// Identifiant de corrélation pour le traçage distribué.
    pub correlation_id: CorrelationId,
    /// Identifiant de causalité reliant l'événement à son déclencheur parent.
    #[serde(default)]
    #[surreal(default)]
    pub causation_id: Option<CausationId>,
    /// Données métier sérialisées au format JSON.
    pub payload: serde_json::Value,
    /// Métadonnées transversales (acteur, client, trace headers).
    #[serde(default)]
    #[surreal(default)]
    pub metadata: serde_json::Value,
    /// Horodatage UTC de création.
    #[serde(default)]
    #[surreal(default)]
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
        let event_id = EventId::new();
        let payload = serde_json::to_value(event)?;
        Ok(Self {
            id: None,
            event_id,
            event_type: E::EVENT_TYPE.to_string(),
            version: 1,
            producer: producer.into(),
            source: None,
            context,
            correlation_id: CorrelationId::from_uuid(event_id.as_uuid()),
            causation_id: None,
            payload,
            metadata: serde_json::json!({}),
            created_at: Datetime::default(),
        })
    }

    /// Associe un identifiant de corrélation spécifique.
    #[must_use]
    pub fn with_correlation_id(mut self, correlation_id: CorrelationId) -> Self {
        self.correlation_id = correlation_id;
        self
    }

    /// Associe un identifiant de causalité parent.
    #[must_use]
    pub fn with_causation_id(mut self, causation_id: CausationId) -> Self {
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
