use crate::error::LyxalEventError;
use crate::models::{EventDeadLetter, EventDelivery, EventSubscription, LyxalEventEnvelope};
use async_trait::async_trait;
use lyxal_surreal::RecordId;
use lyxal_surreal::{LyxalSurrealCall, SurrealValue};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

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
    event_id: String,
    event_type: String,
    version: u32,
    producer: String,
    source: Option<RecordId>,
    context: crate::models::EventContext,
    correlation_id: String,
    causation_id: Option<String>,
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

#[derive(SurrealValue, Clone)]
struct ClaimParams {
    limit: usize,
    lease_seconds: u64,
    worker_id: String,
    instance_id: Option<String>,
}

#[derive(SurrealValue, Clone)]
struct DeliverySuccessParams {
    delivery_id: RecordId,
}

#[derive(SurrealValue, Clone)]
struct DeliveryFailureParams {
    delivery_id: RecordId,
    error: String,
    retry_delay_seconds: u64,
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

    /// Initialise le schéma et les fonctions SurrealQL pour lyxal_event.
    pub async fn init_schema(&self) -> Result<(), LyxalEventError> {
        let ddl_schema = concat!(
            include_str!("../../schema/event_outbox.surql"),
            "\n",
            include_str!("../../schema/event_subscription.surql"),
            "\n",
            include_str!("../../schema/event_delivery.surql"),
            "\n",
            include_str!("../../schema/event_dead_letter.surql"),
            "\n",
            include_str!("../../schema/event_stream_lease.surql"),
            "\n",
            include_str!("../../schema/event_subscription_progress.surql"),
        );

        let ddl_functions = concat!(
            include_str!("../../functions/event_publish.surql"),
            "\n",
            include_str!("../../functions/event_fanout.surql"),
            "\n",
            include_str!("../../functions/event_recover_pending_fanouts.surql"),
            "\n",
            include_str!("../../functions/event_claim_batch.surql"),
            "\n",
            include_str!("../../functions/event_delivery_success.surql"),
            "\n",
            include_str!("../../functions/event_delivery_failure.surql"),
            "\n",
            include_str!("../../functions/event_dead_letter_replay.surql"),
            "\n",
            include_str!("../../functions/event_purge_garbage.surql"),
            "\n",
            include_str!("../../functions/event_lease_acquire.surql"),
            "\n",
            include_str!("../../functions/event_lease_renew.surql"),
            "\n",
            include_str!("../../functions/event_lease_release.surql"),
            "\n",
            include_str!("../../functions/event_progress_get.surql"),
            "\n",
            include_str!("../../functions/event_delivery_assign_seq.surql"),
            "\n",
            include_str!("../../functions/event_dead_letter_transfer.surql"),
            "\n",
            include_str!("../../functions/event_flush_batch.surql"),
            "\n",
            include_str!("../../functions/event_subscription_register.surql"),
            "\n",
            include_str!("../../functions/event_outbox_get.surql"),
            "\n",
            include_str!("../../functions/event_delivery_get.surql"),
            "\n",
            include_str!("../../functions/event_dead_letter_list.surql"),
            "\n",
            include_str!("../../functions/event_delivery_fetch_pending.surql"),
        );

        let ddl_errors = include_str!("../../error/events.surql");

        self.client
            .query(ddl_schema)
            .await
            .map_err(LyxalEventError::from)?
            .check()
            .map_err(LyxalEventError::from)?;

        self.client
            .query(ddl_functions)
            .await
            .map_err(LyxalEventError::from)?
            .check()
            .map_err(LyxalEventError::from)?;

        self.client
            .query(ddl_errors)
            .await
            .map_err(LyxalEventError::from)?
            .check()
            .map_err(LyxalEventError::from)?;

        Ok(())
    }

    /// Publie une enveloppe d'événement dans l'outbox.
    pub async fn publish(
        &self,
        envelope: &LyxalEventEnvelope,
        auto_fanout: bool,
    ) -> Result<LyxalEventEnvelope, LyxalEventError> {
        let params = PublishParams {
            event_id: envelope.event_id.to_string(),
            event_type: envelope.event_type.clone(),
            version: envelope.version,
            producer: envelope.producer.clone(),
            source: envelope.source.clone(),
            context: envelope.context.clone(),
            correlation_id: envelope.correlation_id.to_string(),
            causation_id: envelope.causation_id.map(|c| c.to_string()),
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

    /// Réclame atomiquement un lot de livraisons prêtes.
    pub async fn claim_batch(
        &self,
        limit: usize,
        lease_seconds: u64,
        worker_id: &str,
        instance_id: Option<&str>,
    ) -> Result<Vec<EventDelivery>, LyxalEventError> {
        let params = ClaimParams {
            limit,
            lease_seconds,
            worker_id: worker_id.to_string(),
            instance_id: instance_id.map(|s| s.to_string()),
        };

        let mut attempts = 0;
        loop {
            match self
                .call_fn::<Vec<EventDelivery>, _>("event_claim_batch", params.clone())
                .await
            {
                Ok(deliveries) => return Ok(deliveries),
                Err(err) => {
                    attempts += 1;
                    let err_str = err.to_string();
                    if (err_str.contains("conflict") || err_str.contains("retry")) && attempts < 5 {
                        let jitter = fastrand::u64(5..25);
                        tokio::time::sleep(std::time::Duration::from_millis(jitter)).await;
                        continue;
                    }
                    return Err(LyxalEventError::Surreal(Box::new(err)));
                }
            }
        }
    }

    /// Acquitte le succès d'une livraison.
    pub async fn delivery_success(&self, id: &RecordId) -> Result<(), LyxalEventError> {
        let params = DeliverySuccessParams {
            delivery_id: id.clone(),
        };
        let mut attempts = 0;
        loop {
            match self
                .call_fn::<bool, _>("event_delivery_success", params.clone())
                .await
            {
                Ok(true) => return Ok(()),
                Ok(false) => {
                    return Err(LyxalEventError::Internal(
                        "Delivery not found or invalid delivery_id".to_string(),
                    ))
                }
                Err(err) => {
                    attempts += 1;
                    let err_str = err.to_string();
                    if (err_str.contains("conflict") || err_str.contains("retry")) && attempts < 5 {
                        let jitter = fastrand::u64(5..25);
                        tokio::time::sleep(std::time::Duration::from_millis(jitter)).await;
                        continue;
                    }
                    return Err(LyxalEventError::Surreal(Box::new(err)));
                }
            }
        }
    }

    /// Enregistre l'échec d'une livraison et reprogramme un retry ou bascule en dead-letter.
    pub async fn delivery_failure(
        &self,
        id: &RecordId,
        error_message: &str,
        retry_delay_seconds: u64,
    ) -> Result<(), LyxalEventError> {
        let params = DeliveryFailureParams {
            delivery_id: id.clone(),
            error: error_message.to_string(),
            retry_delay_seconds,
        };
        let mut attempts = 0;
        loop {
            match self
                .call_fn::<bool, _>("event_delivery_failure", params.clone())
                .await
            {
                Ok(true) => return Ok(()),
                Ok(false) => return Err(LyxalEventError::Internal(
                    "Failed to record delivery failure (delivery not found or invalid parameters)"
                        .to_string(),
                )),
                Err(err) => {
                    attempts += 1;
                    let err_str = err.to_string();
                    if (err_str.contains("conflict") || err_str.contains("retry")) && attempts < 5 {
                        let jitter = fastrand::u64(5..25);
                        tokio::time::sleep(std::time::Duration::from_millis(jitter)).await;
                        continue;
                    }
                    return Err(LyxalEventError::Surreal(Box::new(err)));
                }
            }
        }
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
