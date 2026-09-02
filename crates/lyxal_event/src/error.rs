use lyxal_surreal::LyxalSurrealError;
use std::time::Duration;
use thiserror::Error;
use uuid::Uuid;

/// Erreurs levées par le moteur lyxal_event.
#[derive(Debug, Error)]
pub enum LyxalEventError {
    /// Erreur de persistance ou de requête émise par SurrealDB.
    #[error("SurrealDB error: {0}")]
    Surreal(Box<LyxalSurrealError>),

    /// Erreur de sérialisation ou désérialisation JSON.
    #[error("Serialization error: {0}")]
    Serialization(#[from] serde_json::Error),

    /// Aucun handler n'a été enregistré pour le type d'événement requis.
    #[error("No handler registered for event type '{event_type}'")]
    MissingHandler { event_type: String },

    /// Délai maximal d'exécution du handler dépassé.
    #[error("Handler dispatch timed out after {timeout:?} for event '{event_id}' ({event_type})")]
    HandlerTimeout {
        event_id: Uuid,
        event_type: String,
        timeout: Duration,
    },

    /// Échec d'exécution du handler utilisateur.
    #[error("Handler execution failed for event '{event_id}' ({event_type}): {error}")]
    HandlerFailed {
        event_id: Uuid,
        event_type: String,
        error: String,
    },

    /// Non-concordance de type lors du décodage du payload.
    #[error("Type mismatch: expected event type '{expected}', got '{actual}'")]
    TypeMismatch {
        expected: &'static str,
        actual: String,
    },

    /// Contexte d'instance ou de multi-tenance non concordant.
    #[error("Instance context mismatch: expected '{expected}', got '{actual}'")]
    ContextMismatch { expected: String, actual: String },

    /// Erreur interne ou d'incohérence d'état.
    #[error("Internal event engine error: {0}")]
    Internal(String),
}

impl From<LyxalSurrealError> for LyxalEventError {
    fn from(err: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(err))
    }
}

impl From<surrealdb::Error> for LyxalEventError {
    fn from(err: surrealdb::Error) -> Self {
        Self::Surreal(Box::new(LyxalSurrealError::from(err)))
    }
}
