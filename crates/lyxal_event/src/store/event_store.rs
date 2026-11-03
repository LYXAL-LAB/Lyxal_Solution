use crate::error::LyxalEventError;
use crate::models::{EventDeadLetter, EventDelivery, EventSubscription, LyxalEventEnvelope};
use async_trait::async_trait;
use lyxal_surreal::RecordId;
use lyxal_surreal::{LyxalSurrealCall, SurrealValue};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Manifeste du module, embarqué pour l'installation par `lyxal_runtime`.
pub const MANIFEST: &str = include_str!("../../manifest.toml");

/// Fichiers SurrealQL déclarés dans `[resources]`, embarqués (`chemin`, `contenu`) pour que
/// `lyxal_runtime` installe le module sans accès à ses sources. Un test vérifie que la liste
/// et les contenus sont ceux du manifeste et du disque.
pub const EMBEDDED_RESOURCES: &[(&str, &str)] = &[
    (
        "schema/event_outbox.surql",
        include_str!("../../schema/event_outbox.surql"),
    ),
    (
        "schema/event_subscription.surql",
        include_str!("../../schema/event_subscription.surql"),
    ),
    (
        "schema/event_delivery.surql",
        include_str!("../../schema/event_delivery.surql"),
    ),
    (
        "schema/event_dead_letter.surql",
        include_str!("../../schema/event_dead_letter.surql"),
    ),
    (
        "schema/event_stream_lease.surql",
        include_str!("../../schema/event_stream_lease.surql"),
    ),
    (
        "schema/event_subscription_progress.surql",
        include_str!("../../schema/event_subscription_progress.surql"),
    ),
    (
        "functions/event_publish.surql",
        include_str!("../../functions/event_publish.surql"),
    ),
    (
        "functions/event_fanout.surql",
        include_str!("../../functions/event_fanout.surql"),
    ),
    (
        "functions/event_recover_pending_fanouts.surql",
        include_str!("../../functions/event_recover_pending_fanouts.surql"),
    ),
    (
        "functions/event_delivery_assign_seq.surql",
        include_str!("../../functions/event_delivery_assign_seq.surql"),
    ),
    (
        "functions/event_flush_batch.surql",
        include_str!("../../functions/event_flush_batch.surql"),
    ),
    (
        "functions/event_dead_letter_transfer.surql",
        include_str!("../../functions/event_dead_letter_transfer.surql"),
    ),
    (
        "functions/event_dead_letter_replay.surql",
        include_str!("../../functions/event_dead_letter_replay.surql"),
    ),
    (
        "functions/event_progress_get.surql",
        include_str!("../../functions/event_progress_get.surql"),
    ),
    (
        "functions/event_lease_acquire.surql",
        include_str!("../../functions/event_lease_acquire.surql"),
    ),
    (
        "functions/event_lease_renew.surql",
        include_str!("../../functions/event_lease_renew.surql"),
    ),
    (
        "functions/event_lease_release.surql",
        include_str!("../../functions/event_lease_release.surql"),
    ),
    (
        "functions/event_delivery_failure.surql",
        include_str!("../../functions/event_delivery_failure.surql"),
    ),
    (
        "functions/event_purge_garbage.surql",
        include_str!("../../functions/event_purge_garbage.surql"),
    ),
    (
        "functions/event_subscription_register.surql",
        include_str!("../../functions/event_subscription_register.surql"),
    ),
    (
        "functions/event_outbox_get.surql",
        include_str!("../../functions/event_outbox_get.surql"),
    ),
    (
        "functions/event_delivery_get.surql",
        include_str!("../../functions/event_delivery_get.surql"),
    ),
    (
        "functions/event_dead_letter_list.surql",
        include_str!("../../functions/event_dead_letter_list.surql"),
    ),
    (
        "functions/event_delivery_fetch_pending.surql",
        include_str!("../../functions/event_delivery_fetch_pending.surql"),
    ),
    (
        "error/events.surql",
        include_str!("../../error/events.surql"),
    ),
];

/// Store de persistance SurrealDB pour le moteur d'événements.
#[derive(Clone)]
pub struct EventStore {
    client: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for EventStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

#[derive(SurrealValue)]
struct PublishParams {
    event_id: surrealdb::types::Uuid,
    event_type: String,
    version: u32,
    producer: String,
    source: Option<RecordId>,
    context: crate::models::EventContext,
    correlation_id: surrealdb::types::Uuid,
    causation_id: Option<surrealdb::types::Uuid>,
    payload: serde_json::Value,
    metadata: serde_json::Value,
    auto_fanout: bool,
}

#[derive(SurrealValue)]
struct FanoutParams {
    outbox_id: RecordId,
}

#[derive(SurrealValue)]
struct RecoverFanoutParams {
    limit: usize,
}

#[derive(SurrealValue)]
struct RecoverFanoutResult {
    recovered_count: usize,
}

#[derive(SurrealValue)]
struct DeadLetterReplayParams {
    dead_letter_id: RecordId,
}

#[derive(SurrealValue)]
struct PurgeGarbageParams {
    retention_days: u32,
}

#[derive(SurrealValue)]
struct SubscriptionRegisterParams {
    name: String,
    target_module: String,
    event_pattern: String,
    handler_name: String,
    is_active: bool,
    max_attempts: u32,
}

#[derive(SurrealValue)]
struct OutboxGetParams {
    id: RecordId,
}

#[derive(SurrealValue)]
struct DeliveryGetParams {
    id: RecordId,
}

#[derive(SurrealValue, Default)]
struct DeadLetterListParams {
    limit: Option<usize>,
    delivery: Option<RecordId>,
}

impl EventStore {
    /// Crée un nouveau store d'événements enveloppant le client SurrealDB.
    #[must_use]
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Référence au client SurrealDB.
    #[must_use]
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }

    /// Publie une enveloppe d'événement dans l'outbox.
    pub async fn publish(
        &self,
        envelope: &LyxalEventEnvelope,
        auto_fanout: bool,
    ) -> Result<LyxalEventEnvelope, LyxalEventError> {
        let params = PublishParams {
            event_id: envelope.event_id.as_uuid().into(),
            event_type: envelope.event_type.clone(),
            version: envelope.version,
            producer: envelope.producer.clone(),
            source: envelope.source.clone(),
            context: envelope.context.clone(),
            correlation_id: envelope.correlation_id.as_uuid().into(),
            causation_id: envelope.causation_id.map(|c| c.as_uuid().into()),
            payload: envelope.payload.clone(),
            metadata: envelope.metadata.clone(),
            auto_fanout,
        };

        let result: LyxalEventEnvelope = self.call_fn("event_publish", params).await?;
        Ok(result)
    }

    /// Enregistre ou met à jour une subscription dans SurrealDB.
    pub async fn register_subscription(
        &self,
        sub: &EventSubscription,
    ) -> Result<EventSubscription, LyxalEventError> {
        let params = SubscriptionRegisterParams {
            name: sub.name.clone(),
            target_module: sub.target_module.clone(),
            event_pattern: sub.event_pattern.clone(),
            handler_name: sub.handler_name.clone(),
            is_active: sub.is_active,
            max_attempts: sub.max_attempts,
        };
        let created: EventSubscription =
            self.call_fn("event_subscription_register", params).await?;
        Ok(created)
    }

    /// Déclenche le fan-out explicite pour un événement outbox.
    pub async fn fanout(&self, outbox_id: &RecordId) -> Result<serde_json::Value, LyxalEventError> {
        let params = FanoutParams {
            outbox_id: outbox_id.clone(),
        };
        let res: serde_json::Value = self.call_fn("event_fanout", params).await?;
        Ok(res)
    }

    /// Reprend les fan-outs restés en statut 'pending'.
    pub async fn recover_pending_fanouts(&self, limit: usize) -> Result<usize, LyxalEventError> {
        let params = RecoverFanoutParams { limit };
        let res: RecoverFanoutResult = self
            .call_fn("event_recover_pending_fanouts", params)
            .await?;
        Ok(res.recovered_count)
    }

    /// Rejoue une dead letter.
    pub async fn dead_letter_replay(
        &self,
        dead_letter_id: &RecordId,
    ) -> Result<bool, LyxalEventError> {
        let params = DeadLetterReplayParams {
            dead_letter_id: dead_letter_id.clone(),
        };
        let ok: bool = self.call_fn("event_dead_letter_replay", params).await?;
        Ok(ok)
    }

    /// Purge les éléments archivés ayant dépassé la période de rétention.
    pub async fn purge_garbage(&self, retention_days: u32) -> Result<bool, LyxalEventError> {
        let params = PurgeGarbageParams { retention_days };
        let ok: bool = self.call_fn("event_purge_garbage", params).await?;
        Ok(ok)
    }

    /// Récupère un événement outbox par son identifiant.
    pub async fn get_outbox_event(
        &self,
        id: &RecordId,
    ) -> Result<Option<LyxalEventEnvelope>, LyxalEventError> {
        let params = OutboxGetParams { id: id.clone() };
        let event: Option<LyxalEventEnvelope> = self.call_fn("event_outbox_get", params).await?;
        Ok(event)
    }

    /// Récupère une livraison par son identifiant.
    pub async fn get_delivery(
        &self,
        id: &RecordId,
    ) -> Result<Option<EventDelivery>, LyxalEventError> {
        let params = DeliveryGetParams { id: id.clone() };
        let delivery: Option<EventDelivery> = self.call_fn("event_delivery_get", params).await?;
        Ok(delivery)
    }

    /// Récupère les dead letters associées à une livraison.
    pub async fn get_dead_letters(&self) -> Result<Vec<EventDeadLetter>, LyxalEventError> {
        let params = DeadLetterListParams {
            limit: Some(100),
            delivery: None,
        };
        let list: Vec<EventDeadLetter> = self.call_fn("event_dead_letter_list", params).await?;
        Ok(list)
    }

    /// Récupère les livraisons éligibles au traitement outbox ou à la reprise après crash.
    pub async fn fetch_pending_deliveries(
        &self,
        params: crate::engine::dto::DeliveryFetchPendingParams,
    ) -> Result<Vec<crate::engine::dto::PendingDeliveryItem>, LyxalEventError> {
        let items: Vec<crate::engine::dto::PendingDeliveryItem> =
            self.call_fn("event_delivery_fetch_pending", params).await?;
        Ok(items)
    }
}
