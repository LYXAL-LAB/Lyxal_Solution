use super::config::EventWorkerConfig;
use super::retry::{compute_lease_duration, compute_next_retry_delay};
use crate::error::LyxalEventError;
use crate::handler::{HandlerContext, HandlerRegistry};
use crate::models::EventDelivery;
use crate::store::EventStore;
use crate::types::{CausationId, CorrelationId, EventId};
use std::sync::Arc;
use tokio_util::sync::CancellationToken;
use tracing::{debug, error, info, trace, warn};

/// Moteur asynchrone d'exécution et de distribution des événements pour Lyxal OS.
pub struct EventWorker {
    store: Arc<EventStore>,
    registry: Arc<HandlerRegistry>,
    config: EventWorkerConfig,
}

impl EventWorker {
    /// Crée un nouveau worker d'événements lié à un store, un registre et une configuration.
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
        }
    }

    /// Configuration actuelle du worker.
    #[must_use]
    pub fn config(&self) -> &EventWorkerConfig {
        &self.config
    }

    /// Démarre la boucle de traitement asynchrone jusqu'à annulation du CancellationToken.
    pub async fn run(&self, cancel: CancellationToken) -> Result<(), LyxalEventError> {
        info!(
            worker_id = %self.config.worker_id,
            batch_size = self.config.batch_size,
            "Lyxal Event Worker started"
        );

        // Tâche de fond pour la reprise des fan-outs interrompus par un crash ou redémarrage
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

        // Boucle principale de claim et de dispatch
        while !cancel.is_cancelled() {
            let sleep_for = match self.poll_cycle(&cancel).await {
                Ok(0) => Some(self.config.poll_interval),
                Ok(_) => {
                    if self.config.min_cycle_delay.is_zero() {
                        None
                    } else {
                        Some(self.config.min_cycle_delay)
                    }
                }
                Err(err) => {
                    error!(error = ?err, "Event worker poll cycle error, sleeping before retry");
                    Some(self.config.poll_interval)
                }
            };

            if let Some(delay) = sleep_for {
                tokio::select! {
                    () = tokio::time::sleep(delay) => {}
                    () = cancel.cancelled() => break,
                }
            }
        }

        info!(worker_id = %self.config.worker_id, "Lyxal Event Worker stopped");
        Ok(())
    }

    /// Exécute un cycle unitaire de claim et de traitement par lot.
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
                    delivery_id = %delivery.id,
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
        delivery: &EventDelivery,
        cancel: &CancellationToken,
    ) -> Result<(), LyxalEventError> {
        let envelope = match self.store.get_outbox_event(&delivery.outbox_event).await? {
            Some(env) => env,
            None => {
                let err_msg = format!("Outbox event '{}' not found", delivery.outbox_event);
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

        // Création du contexte avec un child token d'annulation pour isoler les timeouts
        let child_cancel = cancel.child_token();
        let ctx = HandlerContext::new(
            EventId::from_uuid(envelope.event_id),
            delivery.id.clone(),
            CorrelationId::from_uuid(envelope.correlation_id),
            envelope.causation_id.map(CausationId::from_uuid),
            envelope.context.clone(),
            delivery.attempts,
            child_cancel.clone(),
        );

        debug!(
            delivery_id = %delivery.id,
            event_id = %envelope.event_id,
            event_type = %envelope.event_type,
            attempt = delivery.attempts,
            "Dispatching event delivery to handler"
        );

        // Exécution avec timeout strict
        match tokio::time::timeout(
            self.config.dispatch_timeout,
            handler.handle(&envelope, &ctx),
        )
        .await
        {
            Ok(Ok(())) => {
                debug!(
                    delivery_id = %delivery.id,
                    event_id = %envelope.event_id,
                    "Handler succeeded, settling delivery"
                );
                self.store.delivery_success(&delivery.id).await?;
            }
            Ok(Err(err)) => {
                let err_str = err.to_string();
                warn!(
                    delivery_id = %delivery.id,
                    event_id = %envelope.event_id,
                    error = %err_str,
                    "Handler execution returned error"
                );
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
                error!(
                    delivery_id = %delivery.id,
                    event_id = %envelope.event_id,
                    "Handler timed out, cancelling child token"
                );
                let retry_delay = compute_next_retry_delay(&self.config, delivery.attempts);
                self.store
                    .delivery_failure(&delivery.id, &err_str, retry_delay.as_secs().max(1))
                    .await?;
            }
        }

        Ok(())
    }
}
