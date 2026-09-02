use crate::error::LyxalEventError;
use crate::handler::Event;
use crate::models::{EventContext, LyxalEventEnvelope};
use crate::store::EventStore;
use crate::types::{CausationId, CorrelationId};
use std::sync::Arc;
use surrealdb::sql::Thing as RecordId;

/// Façade producteur permettant aux modules d'émettre des événements dans le bus.
#[derive(Clone)]
pub struct EventPublisher {
    store: Arc<EventStore>,
    producer: String,
    context: EventContext,
}

impl EventPublisher {
    /// Crée un nouveau publisher attaché à un store, un module producteur et un contexte d'instance.
    #[must_use]
    pub fn new(store: Arc<EventStore>, producer: impl Into<String>, context: EventContext) -> Self {
        Self {
            store,
            producer: producer.into(),
            context,
        }
    }

    /// Publie un événement typé.
    pub async fn publish<E: Event>(
        &self,
        event: &E,
    ) -> Result<LyxalEventEnvelope, LyxalEventError> {
        let envelope = LyxalEventEnvelope::new(&self.producer, self.context.clone(), event)?;
        self.publish_envelope(&envelope).await
    }

    /// Publie un événement typé avec propagation de correlation_id, causation_id et source.
    pub async fn publish_with_context<E: Event>(
        &self,
        event: &E,
        correlation_id: Option<CorrelationId>,
        causation_id: Option<CausationId>,
        source: Option<RecordId>,
    ) -> Result<LyxalEventEnvelope, LyxalEventError> {
        let mut envelope = LyxalEventEnvelope::new(&self.producer, self.context.clone(), event)?;
        if let Some(corr) = correlation_id {
            envelope = envelope.with_correlation_id(corr.as_uuid());
        }
        if let Some(caus) = causation_id {
            envelope = envelope.with_causation_id(caus.as_uuid());
        }
        if let Some(src) = source {
            envelope = envelope.with_source(src);
        }
        self.publish_envelope(&envelope).await
    }

    /// Publie directement une enveloppe d'événement pré-construite.
    pub async fn publish_envelope(
        &self,
        envelope: &LyxalEventEnvelope,
    ) -> Result<LyxalEventEnvelope, LyxalEventError> {
        self.store.publish(envelope, true).await
    }
}
