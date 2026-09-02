use crate::models::EventContext;
use crate::types::{CausationId, CorrelationId, EventId};
use surrealdb::sql::Thing as RecordId;
use tokio_util::sync::CancellationToken;

/// Contexte d'exécution transmis au handler lors du traitement d'une livraison.
#[derive(Debug, Clone)]
pub struct HandlerContext {
    /// Identifiant unique de l'événement d'origine.
    pub event_id: EventId,
    /// Identifiant de l'enregistrement de livraison unitaire.
    pub delivery_id: RecordId,
    /// Identifiant de corrélation pour le traçage distribué.
    pub correlation_id: CorrelationId,
    /// Identifiant de causalité parent (si existant).
    pub causation_id: Option<CausationId>,
    /// Contexte d'isolation de l'instance et de la base de données.
    pub context: EventContext,
    /// Numéro de la tentative en cours (1 pour la première).
    pub attempt: u32,
    /// Token d'annulation coopératif pour intercepter les timeouts et les arrêts.
    pub cancellation: CancellationToken,
}

impl HandlerContext {
    /// Construit un nouveau contexte de traitement pour un handler.
    #[must_use]
    pub fn new(
        event_id: EventId,
        delivery_id: RecordId,
        correlation_id: CorrelationId,
        causation_id: Option<CausationId>,
        context: EventContext,
        attempt: u32,
        cancellation: CancellationToken,
    ) -> Self {
        Self {
            event_id,
            delivery_id,
            correlation_id,
            causation_id,
            context,
            attempt,
            cancellation,
        }
    }
}
