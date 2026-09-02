use crate::error::LyxalEventError;
use crate::models::{EventDeadLetter, EventDelivery, EventSubscription, LyxalEventEnvelope};
use async_trait::async_trait;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::engine::any::Any;
use surrealdb::sql::Thing as RecordId;
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

#[derive(Serialize)]
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

#[derive(Serialize)]
struct FanoutParams {
    outbox_id: RecordId,
}

#[derive(Serialize)]
struct RecoverFanoutParams {
    limit: usize,
}

#[derive(Deserialize)]
struct RecoverFanoutResult {
    recovered_count: usize,
}

#[derive(Serialize, Clone)]
struct ClaimParams {
    limit: usize,
    lease_seconds: u64,
    worker_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    instance_id: Option<String>,
}

#[derive(Serialize, Clone)]
struct DeliverySuccessParams {
    id: RecordId,
}

#[derive(Serialize, Clone)]
struct DeliveryFailureParams {
    id: RecordId,
    error_message: String,
    retry_delay_seconds: u64,
}

#[derive(Serialize)]
struct DeadLetterReplayParams {
    dead_letter_id: RecordId,
}

#[derive(Serialize)]
struct PurgeGarbageParams {
    retention_days: u32,
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
        let ddl = r#"
            -- Tables
            DEFINE TABLE IF NOT EXISTS event_outbox SCHEMALESS;
            DEFINE FIELD IF NOT EXISTS event_id ON TABLE event_outbox TYPE string;
            DEFINE FIELD IF NOT EXISTS event_type ON TABLE event_outbox TYPE string;
            DEFINE FIELD IF NOT EXISTS version ON TABLE event_outbox TYPE number DEFAULT 1;
            DEFINE FIELD IF NOT EXISTS producer ON TABLE event_outbox TYPE string;
            DEFINE FIELD IF NOT EXISTS source ON TABLE event_outbox TYPE option<record>;
            DEFINE FIELD IF NOT EXISTS context ON TABLE event_outbox TYPE object;
            DEFINE FIELD IF NOT EXISTS correlation_id ON TABLE event_outbox TYPE string;
            DEFINE FIELD IF NOT EXISTS causation_id ON TABLE event_outbox TYPE option<string>;
            DEFINE FIELD IF NOT EXISTS payload ON TABLE event_outbox TYPE object;
            DEFINE FIELD IF NOT EXISTS metadata ON TABLE event_outbox TYPE object DEFAULT {};
            DEFINE FIELD IF NOT EXISTS status ON TABLE event_outbox TYPE string DEFAULT "pending";
            DEFINE FIELD IF NOT EXISTS created_at ON TABLE event_outbox TYPE datetime DEFAULT time::now();
            DEFINE FIELD IF NOT EXISTS fanned_out_at ON TABLE event_outbox TYPE option<datetime>;
            DEFINE INDEX IF NOT EXISTS idx_outbox_event_id ON TABLE event_outbox COLUMNS event_id UNIQUE;
            DEFINE INDEX IF NOT EXISTS idx_outbox_pending_fanout ON TABLE event_outbox COLUMNS status, created_at;

            DEFINE TABLE IF NOT EXISTS event_subscription SCHEMALESS;
            DEFINE FIELD IF NOT EXISTS name ON TABLE event_subscription TYPE string;
            DEFINE FIELD IF NOT EXISTS target_module ON TABLE event_subscription TYPE string;
            DEFINE FIELD IF NOT EXISTS event_pattern ON TABLE event_subscription TYPE string;
            DEFINE FIELD IF NOT EXISTS handler_name ON TABLE event_subscription TYPE string;
            DEFINE FIELD IF NOT EXISTS is_active ON TABLE event_subscription TYPE bool DEFAULT true;
            DEFINE FIELD IF NOT EXISTS max_attempts ON TABLE event_subscription TYPE number DEFAULT 5;
            DEFINE FIELD IF NOT EXISTS created_at ON TABLE event_subscription TYPE datetime DEFAULT time::now();
            DEFINE INDEX IF NOT EXISTS idx_subscription_lookup ON TABLE event_subscription COLUMNS event_pattern, is_active;

            DEFINE TABLE IF NOT EXISTS event_delivery SCHEMALESS;
            DEFINE FIELD IF NOT EXISTS outbox_event ON TABLE event_delivery TYPE record<event_outbox>;
            DEFINE FIELD IF NOT EXISTS subscription ON TABLE event_delivery TYPE record<event_subscription>;
            DEFINE FIELD IF NOT EXISTS target_module ON TABLE event_delivery TYPE string;
            DEFINE FIELD IF NOT EXISTS context ON TABLE event_delivery TYPE object;
            DEFINE FIELD IF NOT EXISTS status ON TABLE event_delivery TYPE string DEFAULT "pending";
            DEFINE FIELD IF NOT EXISTS attempts ON TABLE event_delivery TYPE number DEFAULT 0;
            DEFINE FIELD IF NOT EXISTS max_attempts ON TABLE event_delivery TYPE number DEFAULT 5;
            DEFINE FIELD IF NOT EXISTS next_retry_at ON TABLE event_delivery TYPE datetime DEFAULT time::now();
            DEFINE FIELD IF NOT EXISTS locked_until ON TABLE event_delivery TYPE option<datetime>;
            DEFINE FIELD IF NOT EXISTS lease_owner ON TABLE event_delivery TYPE option<string>;
            DEFINE FIELD IF NOT EXISTS last_error ON TABLE event_delivery TYPE option<string>;
            DEFINE FIELD IF NOT EXISTS delivered_at ON TABLE event_delivery TYPE option<datetime>;
            DEFINE FIELD IF NOT EXISTS created_at ON TABLE event_delivery TYPE datetime DEFAULT time::now();
            DEFINE INDEX IF NOT EXISTS idx_delivery_unique_fanout ON TABLE event_delivery COLUMNS outbox_event, subscription UNIQUE;

            DEFINE TABLE IF NOT EXISTS event_dead_letter SCHEMALESS;
            DEFINE FIELD IF NOT EXISTS delivery ON TABLE event_dead_letter TYPE record<event_delivery>;
            DEFINE FIELD IF NOT EXISTS outbox_event ON TABLE event_dead_letter TYPE record<event_outbox>;
            DEFINE FIELD IF NOT EXISTS target_module ON TABLE event_dead_letter TYPE string;
            DEFINE FIELD IF NOT EXISTS context ON TABLE event_dead_letter TYPE object;
            DEFINE FIELD IF NOT EXISTS attempts ON TABLE event_dead_letter TYPE number;
            DEFINE FIELD IF NOT EXISTS last_error ON TABLE event_dead_letter TYPE string;
            DEFINE FIELD IF NOT EXISTS payload ON TABLE event_dead_letter TYPE object;
            DEFINE FIELD IF NOT EXISTS metadata ON TABLE event_dead_letter TYPE object DEFAULT {};
            DEFINE FIELD IF NOT EXISTS replayed ON TABLE event_dead_letter TYPE bool DEFAULT false;
            DEFINE FIELD IF NOT EXISTS replayed_at ON TABLE event_dead_letter TYPE option<datetime>;
            DEFINE FIELD IF NOT EXISTS exhausted_at ON TABLE event_dead_letter TYPE datetime DEFAULT time::now();
            DEFINE INDEX IF NOT EXISTS idx_dead_letter_audit ON TABLE event_dead_letter COLUMNS exhausted_at, replayed;

            -- Functions
            DEFINE FUNCTION OVERWRITE fn::result_ok($data: any) {
                RETURN { ok: true, data: $data, error: NONE };
            };

            DEFINE FUNCTION OVERWRITE fn::event_publish($params: object) {
                LET $event_id = $params.event_id;
                LET $event_type = $params.event_type;
                LET $version = IF $params.version != NONE { $params.version } ELSE { 1 };
                LET $producer = IF $params.producer != NONE { $params.producer } ELSE { "unknown" };
                LET $source = $params.source;
                LET $context = IF $params.context != NONE { $params.context } ELSE { { instance_id: "default", namespace: "default", database: "default" } };
                LET $correlation_id = IF $params.correlation_id != NONE { $params.correlation_id } ELSE { $event_id };
                LET $causation_id = $params.causation_id;
                LET $payload = IF $params.payload != NONE { $params.payload } ELSE { {} };
                LET $metadata = IF $params.metadata != NONE { $params.metadata } ELSE { {} };
                LET $auto_fanout = IF $params.auto_fanout != NONE { $params.auto_fanout } ELSE { true };

                LET $created = (
                    CREATE event_outbox CONTENT {
                        event_id: $event_id,
                        event_type: $event_type,
                        version: $version,
                        producer: $producer,
                        source: $source,
                        context: $context,
                        correlation_id: $correlation_id,
                        causation_id: $causation_id,
                        payload: $payload,
                        metadata: $metadata,
                        status: "pending",
                        created_at: time::now()
                    }
                )[0];

                IF $auto_fanout {
                    LET $f = fn::event_fanout({ outbox_id: $created.id });
                };

                RETURN fn::result_ok($created);
            };

            DEFINE FUNCTION OVERWRITE fn::event_fanout($params: object) {
                LET $outbox_id = $params.outbox_id;
                LET $events = (SELECT * FROM $outbox_id);

                IF array::len($events) == 0 {
                    RETURN fn::result_ok({ deliveries_created: 0, status: "not_found" });
                };
                LET $event = $events[0];

                LET $type = $event.event_type;
                LET $all_subs = (SELECT * FROM event_subscription WHERE is_active = true);
                LET $created_count = 0;

                FOR $sub IN $all_subs {
                    LET $pat = $sub.event_pattern;
                    LET $pat_prefix = IF string::ends_with($pat, ".*") { string::slice($pat, 0, string::len($pat) - 2) + "." } ELSE { $pat };
                    LET $matches = ($pat == $type) 
                        OR ($pat == "*")
                        OR (string::ends_with($pat, ".*") AND string::starts_with($type, $pat_prefix));

                    IF $matches {
                        LET $existing = (SELECT id FROM event_delivery WHERE outbox_event = $event.id AND subscription = $sub.id);
                        IF array::len($existing) == 0 {
                            CREATE event_delivery CONTENT {
                                outbox_event: $event.id,
                                subscription: $sub.id,
                                target_module: $sub.target_module,
                                context: $event.context,
                                status: "pending",
                                attempts: 0,
                                max_attempts: $sub.max_attempts,
                                next_retry_at: time::now(),
                                created_at: time::now()
                            };
                        };
                    };
                };

                UPDATE $event.id SET status = "fanned_out", fanned_out_at = time::now();
                RETURN fn::result_ok({ outbox_id: $event.id, status: "fanned_out" });
            };

            DEFINE FUNCTION OVERWRITE fn::event_recover_pending_fanouts($params: object) {
                LET $limit = IF $params.limit != NONE { $params.limit } ELSE { 50 };
                LET $pending_events = (SELECT id, created_at FROM event_outbox WHERE status = "pending" ORDER BY created_at ASC LIMIT $limit);
                IF array::len($pending_events) == 0 {
                    RETURN fn::result_ok({ recovered_count: 0 });
                };
                FOR $ev IN $pending_events {
                    LET $r = fn::event_fanout({ outbox_id: $ev.id });
                };
                RETURN fn::result_ok({ recovered_count: array::len($pending_events) });
            };

            DEFINE FUNCTION OVERWRITE fn::event_claim_batch($params: object) {
                LET $limit = IF $params.limit != NONE { $params.limit } ELSE { 20 };
                LET $lease_seconds = IF $params.lease_seconds != NONE { $params.lease_seconds } ELSE { 30 };
                LET $worker_id = IF $params.worker_id != NONE { $params.worker_id } ELSE { "worker_default" };
                LET $instance_id = IF $params.instance_id != NONE AND $params.instance_id != NULL { $params.instance_id } ELSE { NONE };
                LET $now = time::now();
                LET $lease_until = time::now() + duration::from::secs($lease_seconds);

                LET $eligible = IF $instance_id != NONE {
                    (
                        SELECT id, next_retry_at FROM event_delivery
                        WHERE (
                            (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
                            OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
                            OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
                        )
                        AND context.instance_id = $instance_id
                        ORDER BY next_retry_at ASC
                        LIMIT $limit
                    )
                } ELSE {
                    (
                        SELECT id, next_retry_at FROM event_delivery
                        WHERE (
                            (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
                            OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
                            OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
                        )
                        ORDER BY next_retry_at ASC
                        LIMIT $limit
                    )
                };

                IF array::len($eligible) == 0 {
                    RETURN fn::result_ok([]);
                };

                LET $claimed = (
                    UPDATE $eligible.id
                    SET status = "processing",
                        locked_until = $lease_until,
                        lease_owner = $worker_id,
                        attempts = attempts + 1
                    WHERE (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
                       OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
                       OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
                    RETURN AFTER
                );

                RETURN fn::result_ok($claimed);
            };

            DEFINE FUNCTION OVERWRITE fn::event_delivery_success($params: object) {
                LET $delivery_id = IF $params.id != NONE { $params.id } ELSE { $params.delivery_id };
                LET $updated = (
                    UPDATE $delivery_id SET
                        status = "delivered",
                        delivered_at = time::now(),
                        locked_until = NONE,
                        lease_owner = NONE,
                        last_error = NONE
                    RETURN AFTER
                )[0];
                RETURN fn::result_ok($updated != NONE);
            };

            DEFINE FUNCTION OVERWRITE fn::event_delivery_failure($params: object) {
                LET $delivery_id = IF $params.id != NONE { $params.id } ELSE { $params.delivery_id };
                LET $error = IF $params.error_message != NONE { $params.error_message } ELSE IF $params.error != NONE { $params.error } ELSE { "Unknown handler error" };
                LET $retry_delay_seconds = IF $params.retry_delay_seconds != NONE { $params.retry_delay_seconds } ELSE { 5 };
                LET $deliveries = (SELECT * FROM $delivery_id);

                IF array::len($deliveries) == 0 {
                    RETURN fn::result_ok(false);
                };
                LET $delivery = $deliveries[0];

                IF $delivery.attempts >= $delivery.max_attempts {
                    LET $outboxes = (SELECT * FROM $delivery.outbox_event);
                    LET $outbox = IF array::len($outboxes) > 0 { $outboxes[0] } ELSE { NONE };
                    CREATE event_dead_letter CONTENT {
                        delivery: $delivery.id,
                        outbox_event: $delivery.outbox_event,
                        target_module: $delivery.target_module,
                        context: $delivery.context,
                        attempts: $delivery.attempts,
                        last_error: $error,
                        payload: IF $outbox != NONE { $outbox.payload } ELSE { {} },
                        metadata: IF $outbox != NONE { $outbox.metadata } ELSE { {} },
                        replayed: false,
                        exhausted_at: time::now()
                    };
                    UPDATE $delivery.id SET status = "dead_letter", last_error = $error, locked_until = NONE, lease_owner = NONE;
                } ELSE {
                    LET $next_retry = time::now() + duration::from::secs($retry_delay_seconds);
                    UPDATE $delivery.id SET status = "failed", last_error = $error, next_retry_at = $next_retry, locked_until = NONE, lease_owner = NONE;
                };

                RETURN fn::result_ok(true);
            };

            DEFINE FUNCTION OVERWRITE fn::event_dead_letter_replay($params: object) {
                LET $dead_letter_id = $params.dead_letter_id;
                LET $dl = (SELECT * FROM ONLY $dead_letter_id);
                IF $dl == NONE {
                    RETURN fn::result_ok(false);
                };
                UPDATE $dl.id SET replayed = true, replayed_at = time::now();
                UPDATE $dl.delivery SET status = "pending", attempts = 0, next_retry_at = time::now(), locked_until = NONE, lease_owner = NONE, last_error = NONE;
                RETURN fn::result_ok(true);
            };

            DEFINE FUNCTION OVERWRITE fn::event_purge_garbage($params: object) {
                LET $retention_days = IF $params.retention_days != NONE { $params.retention_days } ELSE { 7 };
                LET $cutoff = time::now() - duration::from::days($retention_days);
                DELETE event_delivery WHERE status = "delivered" AND delivered_at != NONE AND delivered_at < $cutoff;
                DELETE event_outbox WHERE status = "fanned_out" AND fanned_out_at != NONE AND fanned_out_at < $cutoff;
                RETURN fn::result_ok(true);
            };
        "#;

        self.client
            .query(ddl)
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
        let mut response = self
            .client
            .query(
                r#"
                CREATE event_subscription CONTENT {
                    name: $name,
                    target_module: $target_module,
                    event_pattern: $event_pattern,
                    handler_name: $handler_name,
                    is_active: $is_active,
                    max_attempts: $max_attempts,
                    created_at: time::now()
                }
            "#,
            )
            .bind(("name", sub.name.clone()))
            .bind(("target_module", sub.target_module.clone()))
            .bind(("event_pattern", sub.event_pattern.clone()))
            .bind(("handler_name", sub.handler_name.clone()))
            .bind(("is_active", sub.is_active))
            .bind(("max_attempts", sub.max_attempts))
            .await
            .map_err(LyxalEventError::from)?;

        let created: Option<EventSubscription> = response.take(0).map_err(LyxalEventError::from)?;
        created.ok_or_else(|| {
            LyxalEventError::Internal("Failed to create event subscription".to_string())
        })
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
        let params = DeliverySuccessParams { id: id.clone() };
        let mut attempts = 0;
        loop {
            match self
                .call_fn::<bool, _>("event_delivery_success", params.clone())
                .await
            {
                Ok(_) => return Ok(()),
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
            id: id.clone(),
            error_message: error_message.to_string(),
            retry_delay_seconds,
        };
        let mut attempts = 0;
        loop {
            match self
                .call_fn::<bool, _>("event_delivery_failure", params.clone())
                .await
            {
                Ok(_) => return Ok(()),
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
        let mut res = self
            .client
            .query("SELECT * FROM ONLY $id")
            .bind(("id", id.clone()))
            .await
            .map_err(LyxalEventError::from)?;
        let event: Option<LyxalEventEnvelope> = res.take(0).map_err(LyxalEventError::from)?;
        Ok(event)
    }

    /// Récupère une livraison par son identifiant.
    pub async fn get_delivery(
        &self,
        id: &RecordId,
    ) -> Result<Option<EventDelivery>, LyxalEventError> {
        let mut res = self
            .client
            .query("SELECT * FROM ONLY $id")
            .bind(("id", id.clone()))
            .await
            .map_err(LyxalEventError::from)?;
        let delivery: Option<EventDelivery> = res.take(0).map_err(LyxalEventError::from)?;
        Ok(delivery)
    }

    /// Récupère les dead letters associées à une livraison.
    pub async fn get_dead_letters(&self) -> Result<Vec<EventDeadLetter>, LyxalEventError> {
        let mut res = self
            .client
            .query("SELECT * FROM event_dead_letter ORDER BY exhausted_at DESC")
            .await
            .map_err(LyxalEventError::from)?;
        let list: Vec<EventDeadLetter> = res.take(0).map_err(LyxalEventError::from)?;
        Ok(list)
    }
}
