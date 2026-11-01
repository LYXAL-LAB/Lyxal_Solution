use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use tokio::sync::Mutex;
use tokio_util::sync::CancellationToken;
use tracing::{debug, error, info, trace, warn};

use super::config::EventWorkerConfig;
use super::retry::{compute_lease_duration, compute_next_retry_delay};
use crate::engine::consumer_bridge::{
    envelope_extractor, BridgeConfig, ConsumerOutcome, HandlerConsumerBridge,
};
use crate::engine::dispatcher::{DispatcherConfig, NackReport, ReliableDispatcher};
use crate::engine::feeder::{FeederError, OutboxFeeder};
use crate::engine::lease::OutboxLeaseManager;
use crate::engine::pending_delivery::DeliveryPolicy;
use crate::engine::poison_handler::PoisonPolicy;
use crate::error::LyxalEventError;
use crate::handler::HandlerRegistry;
use crate::models::LyxalEventEnvelope;
use crate::store::EventStore;
use lyxal_surreal::ToSql;

/// Métriques d'observabilité en mémoire du LYXAL Event Engine.
#[derive(Debug, Default)]
pub struct EventWorkerMetrics {
    /// Nombre total d'événements enfilés dans le dispatcher.
    pub events_enqueued: AtomicU64,
    /// Nombre total d'acquittements (ACK) réussis et persistés.
    pub deliveries_acked: AtomicU64,
    /// Nombre total d'échecs transitoires (NACK / Retry).
    pub deliveries_nacked: AtomicU64,
    /// Nombre total de transferts en quarantaine (Dead Letter Queue).
    pub deliveries_dead_lettered: AtomicU64,
    /// Nombre d'acquisitions de leadership réussies.
    pub leadership_acquisitions: AtomicU64,
    /// Nombre de pertes de leadership (TTL ou cession).
    pub leadership_losses: AtomicU64,
    /// Nombre de conflits de fencing détectés.
    pub fencing_conflicts: AtomicU64,
}

/// Moteur d'exécution asynchrone officiel de LYXAL OS (`EventWorker`).
///
/// Orchestre le bail distribué avec Fencing MVCC (`OutboxLeaseManager`), l'alimentation séquentielle
/// contiguë (`OutboxFeeder`), le dispatcher résilient in-process (`ReliableDispatcher`), la passerelle
/// d'exécution isolée des handlers (`HandlerConsumerBridge`) et le curseur durable (`SubscriptionProgressTracker`).
pub struct EventWorker {
    store: Arc<EventStore>,
    registry: Arc<HandlerRegistry>,
    config: EventWorkerConfig,
    metrics: Arc<EventWorkerMetrics>,
}

impl EventWorker {
    /// Crée une nouvelle instance de l'EventWorker lié à un store, un registre et une configuration.
    #[must_use]
    pub fn new(
        store: Arc<EventStore>,
        registry: HandlerRegistry,
        config: EventWorkerConfig,
    ) -> Self {
        Self {
            store,
            registry: Arc::new(registry),
            config,
            metrics: Arc::new(EventWorkerMetrics::default()),
        }
    }

    /// Configuration actuelle du worker.
    #[must_use]
    pub fn config(&self) -> &EventWorkerConfig {
        &self.config
    }

    /// Métriques d'observabilité en mémoire.
    #[must_use]
    pub fn metrics(&self) -> &Arc<EventWorkerMetrics> {
        &self.metrics
    }

    /// Démarre la boucle de traitement supervisée jusqu'à annulation du CancellationToken.
    pub async fn run(&self, cancel: CancellationToken) -> Result<(), LyxalEventError> {
        info!(
            worker_id = %self.config.worker_id,
            subscription = %self.config.subscription_name,
            "LYXAL Event Worker démarré"
        );

        let client = self.store.client().clone();
        let lease_manager = Arc::new(OutboxLeaseManager::new(
            client.clone(),
            &self.config.worker_id,
            self.config.lease_ttl,
        ));

        // Tâche de fond pour la reprise des fan-outs interrompus par un crash antérieur
        let store_recovery = self.store.clone();
        let cancel_recovery = cancel.clone();
        let recovery_interval = self.config.fanout_recovery_interval;
        tokio::spawn(async move {
            while !cancel_recovery.is_cancelled() {
                tokio::select! {
                    () = tokio::time::sleep(recovery_interval) => {
                        if let Err(e) = store_recovery.recover_pending_fanouts(50).await {
                            warn!(error = ?e, "Pending fanout recovery cycle failed");
                        }
                    }
                    () = cancel_recovery.cancelled() => break,
                }
            }
        });

        // Boucle principale de supervision et de cycle de vie
        while !cancel.is_cancelled() {
            // 1. Tente d'acquérir le leadership si non détenu
            if !lease_manager.is_leader() {
                match lease_manager.acquire_lease().await {
                    Ok(true) => {
                        self.metrics
                            .leadership_acquisitions
                            .fetch_add(1, Ordering::SeqCst);
                        info!(
                            worker_id = %self.config.worker_id,
                            generation = lease_manager.current_generation(),
                            "Leadership de streaming outbox acquis avec succès"
                        );
                    }
                    Ok(false) => {
                        tokio::select! {
                            () = tokio::time::sleep(self.config.poll_interval) => continue,
                            () = cancel.cancelled() => break,
                        }
                    }
                    Err(e) => {
                        warn!(error = ?e, "Erreur lors de la tentative d'acquisition de bail");
                        tokio::select! {
                            () = tokio::time::sleep(self.config.poll_interval) => continue,
                            () = cancel.cancelled() => break,
                        }
                    }
                }
            }

            // 2. Si le leadership est actif, instancie le pipeline résilient pour ce mandat
            let lease_cancel = lease_manager.cancellation_token();
            let term_cancel = CancellationToken::new();

            // Enfant de l'annulation globale et du fencing
            let linked_cancel = term_cancel.clone();
            let lc_global = cancel.clone();
            let lc_lease = lease_cancel.clone();
            let lc_task = linked_cancel.clone();
            tokio::spawn(async move {
                tokio::select! {
                    () = lc_global.cancelled() => lc_task.cancel(),
                    () = lc_lease.cancelled() => lc_task.cancel(),
                }
            });

            let disp_config = DispatcherConfig {
                max_unacked: self.config.max_unacked,
                delivery_policy: DeliveryPolicy {
                    max_redelivery_count: self.config.max_redelivery_count,
                    ack_timeout: self.config.ack_timeout,
                    ..Default::default()
                },
                poison_policy: PoisonPolicy::DeadLetter,
                subscription_name: self.config.subscription_name.clone(),
                dead_letter_topic: self.config.dead_letter_topic.clone(),
            };

            let dispatcher = Arc::new(Mutex::new(ReliableDispatcher::new(
                disp_config,
                linked_cancel.clone(),
            )));

            let mut feeder = OutboxFeeder::new(
                client.clone(),
                Arc::clone(&lease_manager),
                Arc::clone(&dispatcher),
            );

            let bridge_config = BridgeConfig {
                consumer_id: format!("{}_bridge", self.config.worker_id),
                subscription_name: self.config.subscription_name.clone(),
                dispatch_timeout: self.config.dispatch_timeout,
                max_concurrency: self.config.max_unacked,
            };

            let bridge = HandlerConsumerBridge::new(
                bridge_config,
                (*self.registry).clone(),
                linked_cancel.clone(),
            );

            let mut rx = {
                let mut disp = dispatcher.lock().await;
                bridge.register_with_dispatcher(&mut disp, self.config.max_unacked)
            };

            // Tâche de fond de renouvellement du bail (Heartbeat & Fencing)
            let renew_lease_mgr = Arc::clone(&lease_manager);
            let renew_interval = self.config.lease_renew_interval;
            let renew_cancel = linked_cancel.clone();
            let metrics_renew = Arc::clone(&self.metrics);

            let heartbeat_handle = tokio::spawn(async move {
                while !renew_cancel.is_cancelled() {
                    tokio::select! {
                        () = tokio::time::sleep(renew_interval) => {
                            match renew_lease_mgr.renew_lease().await {
                                Ok(true) => {
                                    trace!("Bail renouvelé avec succès");
                                }
                                Ok(false) => {
                                    warn!("Perte du bail lors du renouvellement (supplanté ou expiré)");
                                    metrics_renew.leadership_losses.fetch_add(1, Ordering::SeqCst);
                                    renew_cancel.cancel();
                                    break;
                                }
                                Err(e) => {
                                    let err_str = e.to_string();
                                    if err_str.contains("EVENT_STALE_LEADER_FENCED") {
                                        error!("Fencing détecté lors du renouvellement de bail !");
                                        metrics_renew.fencing_conflicts.fetch_add(1, Ordering::SeqCst);
                                    } else {
                                        warn!(error = ?e, "Erreur réseau lors du renouvellement de bail");
                                    }
                                    renew_cancel.cancel();
                                    break;
                                }
                            }
                        }
                        () = renew_cancel.cancelled() => break,
                    }
                }
            });

            // Boucle d'exécution du mandat leader
            while !linked_cancel.is_cancelled() {
                let has_capacity = {
                    let disp = dispatcher.lock().await;
                    disp.has_capacity()
                };

                let mut work_done = 0;

                // Si le dispatcher a de la capacité, chercher et séquencer des événements outbox
                if has_capacity {
                    match self.fetch_and_enqueue_pending(&mut feeder).await {
                        Ok(n) => {
                            work_done += n;
                        }
                        Err(e) => {
                            let err_str = e.to_string();
                            if err_str.contains("EVENT_STALE_LEADER_FENCED") {
                                self.metrics
                                    .fencing_conflicts
                                    .fetch_add(1, Ordering::SeqCst);
                                linked_cancel.cancel();
                                break;
                            }
                            warn!(error = ?e, "Erreur lors de la récupération et de l'enfilage outbox");
                        }
                    }
                }

                // Dépilage et traitement des messages par le Bridge
                tokio::select! {
                    msg_opt = rx.recv() => {
                        if let Some(msg) = msg_opt {
                            match bridge.process_and_settle(&msg, &mut feeder).await {
                                Ok(outcome) => {
                                    work_done += 1;
                                    match outcome {
                                        ConsumerOutcome::Ack { .. } => {
                                            self.metrics.deliveries_acked.fetch_add(1, Ordering::SeqCst);
                                        }
                                        ConsumerOutcome::Nack { report, .. } => {
                                            match report {
                                                NackReport::RetryExhausted { .. } => {
                                                    self.metrics.deliveries_dead_lettered.fetch_add(1, Ordering::SeqCst);
                                                }
                                                _ => {
                                                    self.metrics.deliveries_nacked.fetch_add(1, Ordering::SeqCst);
                                                }
                                            }
                                        }
                                        ConsumerOutcome::Cancelled { .. } => {
                                            trace!("Consommation de livraison annulée");
                                        }
                                    }
                                }
                                Err(e) => {
                                    let err_str = e.to_string();
                                    if err_str.contains("EVENT_STALE_LEADER_FENCED") {
                                        self.metrics.fencing_conflicts.fetch_add(1, Ordering::SeqCst);
                                        linked_cancel.cancel();
                                        break;
                                    }
                                    warn!(error = ?e, "Erreur lors du traitement et règlement par le Bridge");
                                }
                            }
                        }
                    }
                    () = tokio::time::sleep(self.config.poll_interval) => {
                        let mut disp = dispatcher.lock().await;
                        let _report = disp.watchdog_tick(tokio::time::Instant::now(), envelope_extractor);
                    }
                    () = linked_cancel.cancelled() => break,
                }

                if work_done == 0 {
                    tokio::select! {
                        () = tokio::time::sleep(self.config.poll_interval) => {}
                        () = linked_cancel.cancelled() => break,
                    }
                }
            }

            // Arrêt propre du terme leader
            let _ = heartbeat_handle.await;

            // Si l'arrêt est dû à une annulation globale (propre), libérer formellement le bail
            if cancel.is_cancelled() && lease_manager.is_leader() {
                info!(
                    worker_id = %self.config.worker_id,
                    "Arrêt gracieux détecté : libération formelle du bail"
                );
                let _ = lease_manager.release_lease().await;
                break;
            }
        }

        info!(worker_id = %self.config.worker_id, "LYXAL Event Worker arrêté");
        Ok(())
    }

    /// Exécute un cycle unitaire de claim et de traitement par lot (utilisé notamment en tests et en exécution pas-à-pas).
    pub async fn poll_cycle(&self, cancel: &CancellationToken) -> Result<usize, LyxalEventError> {
        let lease = compute_lease_duration(&self.config, self.config.batch_size);
        let lease_secs = lease.as_secs().max(5);

        // Phase 1 : Claim atomique par lot
        let deliveries = self
            .store
            .claim_batch(
                self.config.batch_size,
                lease_secs,
                &self.config.worker_id,
                self.config.instance_id.as_deref(),
            )
            .await?;

        let count = deliveries.len();
        if count == 0 {
            trace!("No pending event deliveries claimed");
            return Ok(0);
        }

        debug!(
            worker_id = %self.config.worker_id,
            count,
            "Claimed event delivery batch"
        );

        // Phase 2 : Traitement séquentiel et acquittement unitaire hors du verrou de claim
        for delivery in deliveries {
            if cancel.is_cancelled() {
                break;
            }

            if let Err(err) = self.dispatch_delivery(&delivery, cancel).await {
                warn!(
                    delivery_id = %delivery.id.to_sql(),
                    target_module = %delivery.target_module,
                    error = ?err,
                    "Failed to settle event delivery; proceeding with batch"
                );
            }
        }

        Ok(count)
    }

    async fn dispatch_delivery(
        &self,
        delivery: &crate::models::EventDelivery,
        cancel: &CancellationToken,
    ) -> Result<(), LyxalEventError> {
        let envelope = match self.store.get_outbox_event(&delivery.outbox_event).await? {
            Some(env) => env,
            None => {
                let err_msg = format!(
                    "Outbox event '{}' not found",
                    delivery.outbox_event.to_sql()
                );
                self.store
                    .delivery_failure(&delivery.id, &err_msg, 5)
                    .await?;
                return Err(LyxalEventError::Internal(err_msg));
            }
        };

        let handler = match self.registry.get(&envelope.event_type) {
            Some(h) => h,
            None => {
                let err_msg = format!(
                    "No handler registered for event type '{}'",
                    envelope.event_type
                );
                warn!(event_type = %envelope.event_type, "Missing handler for delivery");
                let retry_delay = compute_next_retry_delay(&self.config, delivery.attempts);
                self.store
                    .delivery_failure(&delivery.id, &err_msg, retry_delay.as_secs().max(1))
                    .await?;
                return Ok(());
            }
        };

        let child_cancel = cancel.child_token();
        let ctx = crate::handler::HandlerContext::new(
            envelope.event_id,
            delivery.id.clone(),
            envelope.correlation_id,
            envelope.causation_id,
            envelope.context.clone(),
            delivery.attempts,
            child_cancel.clone(),
        );

        match tokio::time::timeout(
            self.config.dispatch_timeout,
            handler.handle(&envelope, &ctx),
        )
        .await
        {
            Ok(Ok(())) => {
                self.store.delivery_success(&delivery.id).await?;
            }
            Ok(Err(err)) => {
                let err_str = err.to_string();
                let retry_delay = compute_next_retry_delay(&self.config, delivery.attempts);
                self.store
                    .delivery_failure(&delivery.id, &err_str, retry_delay.as_secs().max(1))
                    .await?;
            }
            Err(_elapsed) => {
                child_cancel.cancel();
                let err_str = format!(
                    "Handler execution timed out after {:?}",
                    self.config.dispatch_timeout
                );
                let retry_delay = compute_next_retry_delay(&self.config, delivery.attempts);
                self.store
                    .delivery_failure(&delivery.id, &err_str, retry_delay.as_secs().max(1))
                    .await?;
            }
        }

        Ok(())
    }

    async fn fetch_and_enqueue_pending(
        &self,
        feeder: &mut OutboxFeeder<LyxalEventEnvelope>,
    ) -> Result<usize, LyxalEventError> {
        // 1. Déclenche la reprise des fan-outs en attente pour créer les event_delivery correspondants
        let _ = self
            .store
            .recover_pending_fanouts(self.config.batch_size)
            .await;

        // 2. Récupère les livraisons éligibles via la fonction canonique SurrealQL
        let params = crate::engine::dto::DeliveryFetchPendingParams {
            limit: self.config.batch_size,
            instance_id: self.config.instance_id.clone(),
            subscription: None,
        };
        let deliveries = self.store.fetch_pending_deliveries(params).await?;

        let count = deliveries.len();
        if count == 0 {
            return Ok(0);
        }

        for rec in deliveries {
            let event_id = rec.event_id.unwrap_or_default();
            let correlation_id = rec
                .correlation_id
                .unwrap_or_else(|| crate::types::CorrelationId::from_uuid(event_id.as_uuid()));
            let causation_id = rec.causation_id;

            let mut meta = rec.metadata.unwrap_or_else(|| serde_json::json!({}));
            if let serde_json::Value::Object(ref mut map) = meta {
                map.insert(
                    "delivery_id".to_string(),
                    serde_json::Value::String(rec.id.to_sql()),
                );
            }

            let envelope = LyxalEventEnvelope {
                id: Some(rec.outbox_event.clone()),
                event_id,
                event_type: rec.event_type.unwrap_or_else(|| "unknown".to_string()),
                version: rec.version.unwrap_or(1),
                producer: rec.producer.unwrap_or_else(|| rec.target_module.clone()),
                source: rec.source,
                context: rec.context.clone().unwrap_or_default(),
                correlation_id,
                causation_id,
                payload: rec.payload.unwrap_or_else(|| serde_json::json!({})),
                metadata: meta,
                created_at: rec.created_at.unwrap_or_default(),
            };

            let outbox_id = rec.outbox_event.to_sql();
            let sub_id = rec.subscription.to_sql();
            let target_module = rec.target_module.clone();
            let context = serde_json::to_value(&envelope.context).unwrap_or_default();

            match feeder
                .assign_and_enqueue(
                    &outbox_id,
                    &sub_id,
                    &target_module,
                    context,
                    envelope,
                    envelope_extractor,
                )
                .await
            {
                Ok(_seq) => {
                    self.metrics.events_enqueued.fetch_add(1, Ordering::SeqCst);
                }
                Err(FeederError::Backpressure) => {
                    break;
                }
                Err(FeederError::Fenced) => {
                    return Err(LyxalEventError::Internal(
                        "EVENT_STALE_LEADER_FENCED: leadership revoked".to_string(),
                    ));
                }
                Err(e) => {
                    warn!(error = ?e, "Échec lors de assign_and_enqueue");
                }
            }
        }

        Ok(count)
    }
}
