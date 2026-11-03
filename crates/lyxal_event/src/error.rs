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

    /// Échec d'exécution du handler utilisateur. `terminal = true` envoie la livraison
    /// directement en DLQ ; `false` déclenche un nouvel essai avec backoff.
    #[error("Handler execution failed for event '{event_id}' ({event_type}): {error}")]
    HandlerFailed {
        event_id: Uuid,
        event_type: String,
        error: String,
        terminal: bool,
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

    /// Mandat de leader révoqué (`EVENT_STALE_LEADER_FENCED`) : un autre nœud détient le bail.
    #[error("Leader fenced: the outbox lease is held by another node")]
    StaleLeaderFenced,

    /// Erreur interne ou d'incohérence d'état.
    #[error("Internal event engine error: {0}")]
    Internal(String),
}

/// Codes levés par `THROW` dans les fonctions protégées par le bail (`event_delivery_assign_seq`,
/// `event_flush_batch`, `event_dead_letter_transfer`) : l'échec y suit une écriture de la même
/// transaction, que seul `THROW` annule. SurrealDB ne les transmet que dans le texte de l'erreur ;
/// c'est le seul endroit qui les y reconnaît.
pub const GUARDED_ERROR_CODES: [&str; 6] = [
    "EVENT_STALE_LEADER_FENCED",
    "EVENT_CURSOR_NON_MONOTONIC",
    "EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ",
    "EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES",
    "EVENT_CURSOR_MISSING_SEQUENCE_HOLE",
    "EVENT_DELIVERY_NOT_FOUND",
];

/// Code d'erreur levé par `THROW` dans une fonction protégée par le bail, s'il y en a un.
#[must_use]
pub fn guarded_error_code(err: &LyxalSurrealError) -> Option<&'static str> {
    let message = err.to_string();
    GUARDED_ERROR_CODES
        .into_iter()
        .find(|code| message.contains(code))
}

/// Indique si l'erreur est la révocation du mandat de leader (fencing).
#[must_use]
pub fn is_stale_leader_fenced(err: &LyxalSurrealError) -> bool {
    guarded_error_code(err) == Some("EVENT_STALE_LEADER_FENCED")
}

impl From<LyxalSurrealError> for LyxalEventError {
    fn from(err: LyxalSurrealError) -> Self {
        if is_stale_leader_fenced(&err) {
            return Self::StaleLeaderFenced;
        }
        Self::Surreal(Box::new(err))
    }
}

impl From<surrealdb::Error> for LyxalEventError {
    fn from(err: surrealdb::Error) -> Self {
        Self::Surreal(Box::new(LyxalSurrealError::from(err)))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_guarded_error_codes_are_recognized_once() {
        let fenced = LyxalSurrealError::Database(surrealdb::Error::internal(
            "An error occurred: EVENT_STALE_LEADER_FENCED".into(),
        ));
        assert!(is_stale_leader_fenced(&fenced));
        assert!(matches!(
            LyxalEventError::from(fenced),
            LyxalEventError::StaleLeaderFenced
        ));

        let hole = LyxalSurrealError::Database(surrealdb::Error::internal(
            "An error occurred: EVENT_CURSOR_MISSING_SEQUENCE_HOLE".into(),
        ));
        assert_eq!(
            guarded_error_code(&hole),
            Some("EVENT_CURSOR_MISSING_SEQUENCE_HOLE")
        );
        assert!(!is_stale_leader_fenced(&hole));
    }
}
