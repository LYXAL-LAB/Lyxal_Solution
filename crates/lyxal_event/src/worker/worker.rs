use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use tokio::sync::Mutex;
use tokio_util::sync::CancellationToken;
use tokio_util::task::AbortOnDropHandle;
use tracing::{error, info, trace, warn};

use super::config::EventWorkerConfig;
use crate::engine::consumer_bridge::{
    envelope_extractor, BridgeConfig, ConsumerOutcome, HandlerConsumerBridge,
};
use crate::engine::dispatcher::{
    DispatchMessage, DispatcherConfig, NackReport, ReliableDispatcher,
};
use crate::engine::feeder::{FeederError, OutboxFeeder};
use crate::engine::lease::OutboxLeaseManager;
use crate::engine::pending_delivery::DeliveryPolicy;
use crate::engine::poison_handler::PoisonPolicy;
use crate::error::LyxalEventError;
use crate::handler::HandlerRegistry;
use crate::models::LyxalEventEnvelope;
use crate::store::EventStore;
use lyxal_surreal::{RecordId, ToSql};

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

/// File d'un abonnement pendant un mandat de leader : son dispatcher, son feeder (curseur
/// contigu propre à l'abonnement) et la passerelle d'exécution des handlers.
struct SubscriptionPipeline {
    feeder: OutboxFeeder<LyxalEventEnvelope>,
    bridge: HandlerConsumerBridge,
    rx: tokio::sync::mpsc::Receiver<DispatchMessage<LyxalEventEnvelope>>,
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
        // Tâches de fond liées à la vie du worker : interrompues si `run` est abandonné, pour
        // qu'aucune ne survive au worker (un heartbeat orphelin garderait le bail indéfiniment).
        let _recovery_task = AbortOnDropHandle::new(tokio::spawn(async move {
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
        }));

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

            // 2. Leadership actif : une file par abonnement pour ce mandat, créée à la première
            //    livraison de l'abonnement. Chaque abonnement numérote ses livraisons à partir de 1
            //    et garde son propre curseur contigu (§5.6.4) : une file commune les confondrait.
            let lease_cancel = lease_manager.cancellation_token();
            let term_cancel = CancellationToken::new();

            // Enfant de l'annulation globale et du fencing
            let linked_cancel = term_cancel.clone();
            let lc_global = cancel.clone();
            let lc_lease = lease_cancel.clone();
            let lc_task = linked_cancel.clone();
            let _link_task = AbortOnDropHandle::new(tokio::spawn(async move {
                tokio::select! {
                    () = lc_global.cancelled() => lc_task.cancel(),
                    () = lc_lease.cancelled() => lc_task.cancel(),
                }
            }));

            let mut pipelines: HashMap<String, SubscriptionPipeline> = HashMap::new();

            // Tâche de fond de renouvellement du bail (Heartbeat & Fencing)
            let renew_lease_mgr = Arc::clone(&lease_manager);
            let renew_interval = self.config.lease_renew_interval;
            let renew_cancel = linked_cancel.clone();
            let metrics_renew = Arc::clone(&self.metrics);

            let heartbeat_handle = AbortOnDropHandle::new(tokio::spawn(async move {
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
                                    let fenced = matches!(
                                        &e,
                                        crate::engine::lease::LeaseError::Surreal(inner)
                                            if crate::error::is_stale_leader_fenced(inner)
                                    );
                                    if fenced {
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
            }));

            // Boucle d'exécution du mandat leader
            'term: while !linked_cancel.is_cancelled() {
                let mut work_done = 0;

                // Séquencement des livraisons en attente, chacune dans la file de son abonnement
                match self
                    .fetch_and_enqueue_pending(
                        &mut pipelines,
                        &client,
                        &lease_manager,
                        &linked_cancel,
                    )
                    .await
                {
                    Ok(n) => work_done += n,
                    Err(e) => {
                        if matches!(e, LyxalEventError::StaleLeaderFenced) {
                            self.metrics
                                .fencing_conflicts
                                .fetch_add(1, Ordering::SeqCst);
                            linked_cancel.cancel();
                            break;
                        }
                        warn!(error = ?e, "Erreur lors de la récupération et de l'enfilage outbox");
                    }
                }

                // Traitement des messages prêts de chaque file, borné par file à chaque tour
                for pipeline in pipelines.values_mut() {
                    for _ in 0..self.config.max_unacked.max(1) {
                        let Ok(msg) = pipeline.rx.try_recv() else {
                            break;
                        };
                        match pipeline
                            .bridge
                            .process_and_settle(&msg, &mut pipeline.feeder)
                            .await
                        {
                            Ok(outcome) => {
                                work_done += 1;
                                self.record_outcome(outcome);
                            }
                            Err(e) => {
                                if matches!(
                                    e,
                                    FeederError::Fenced
                                        | FeederError::Progress(
                                            crate::engine::progress::ProgressError::Fenced
                                        )
                                ) {
                                    self.metrics
                                        .fencing_conflicts
                                        .fetch_add(1, Ordering::SeqCst);
                                    linked_cancel.cancel();
                                    break 'term;
                                }
                                warn!(error = ?e, "Erreur lors du traitement et règlement par le Bridge");
                            }
                        }
                    }

                    // Rattrapage d'un avancement de curseur resté en attente (échec d'écriture)
                    if let Err(e) = pipeline.feeder.retry_pending_flush().await {
                        if matches!(
                            e,
                            FeederError::Fenced
                                | FeederError::Progress(
                                    crate::engine::progress::ProgressError::Fenced
                                )
                        ) {
                            self.metrics
                                .fencing_conflicts
                                .fetch_add(1, Ordering::SeqCst);
                            linked_cancel.cancel();
                            break 'term;
                        }
                        warn!(error = ?e, "Échec du rattrapage de l'avancement du curseur");
                    }

                    // Redélivrance des messages non acquittés dans les délais, et transfert en
                    // dead letter de ceux dont le budget est épuisé
                    if let Err(e) = pipeline
                        .feeder
                        .handle_watchdog_and_poison(tokio::time::Instant::now(), envelope_extractor)
                        .await
                    {
                        if matches!(
                            e,
                            FeederError::Fenced
                                | FeederError::Progress(
                                    crate::engine::progress::ProgressError::Fenced
                                )
                        ) {
                            self.metrics
                                .fencing_conflicts
                                .fetch_add(1, Ordering::SeqCst);
                            linked_cancel.cancel();
                            break 'term;
                        }
                        warn!(error = ?e, "Échec du traitement des délais d'acquittement");
                    }
                }

                if work_done == 0 {
                    tokio::select! {
                        () = tokio::time::sleep(self.config.poll_interval) => {}
                        () = linked_cancel.cancelled() => break,
                    }
                }
            }

            // Arrêt propre du terme leader
            if let Err(e) = heartbeat_handle.await {
                error!(error = ?e, "La tâche de renouvellement du bail s'est terminée anormalement");
            }

            // Si l'arrêt est dû à une annulation globale (propre), libérer formellement le bail
            if cancel.is_cancelled() && lease_manager.is_leader() {
                info!(
                    worker_id = %self.config.worker_id,
                    "Arrêt gracieux détecté : libération formelle du bail"
                );
                // Enregistre les résolutions déjà acquittées, encore valides sous ce bail,
                // pour qu'elles ne soient pas relivrées au redémarrage
                for (sub_id, pipeline) in &mut pipelines {
                    if let Err(e) = pipeline.feeder.retry_pending_flush().await {
                        warn!(subscription = %sub_id, error = ?e, "Avancement final du curseur impossible : les livraisons concernées seront relivrées");
                    }
                }
                if let Err(e) = lease_manager.release_lease().await {
                    warn!(error = ?e, "Échec de la libération du bail : il expirera à l'échéance de son TTL");
                }
                break;
            }
        }

        info!(worker_id = %self.config.worker_id, "LYXAL Event Worker arrêté");
        Ok(())
    }

    /// Comptabilise l'issue d'un traitement dans les métriques.
    fn record_outcome(&self, outcome: ConsumerOutcome) {
        match outcome {
            ConsumerOutcome::Ack { .. } => {
                self.metrics.deliveries_acked.fetch_add(1, Ordering::SeqCst);
            }
            ConsumerOutcome::Nack {
                report: NackReport::RetryExhausted { .. },
                ..
            } => {
                self.metrics
                    .deliveries_dead_lettered
                    .fetch_add(1, Ordering::SeqCst);
            }
            ConsumerOutcome::Nack { .. } => {
                self.metrics
                    .deliveries_nacked
                    .fetch_add(1, Ordering::SeqCst);
            }
            ConsumerOutcome::Cancelled { .. } => {
                trace!("Consommation de livraison annulée");
            }
        }
    }

    /// Crée la file d'un abonnement pour le mandat en cours : dispatcher, feeder (curseur
    /// contigu propre à l'abonnement, repris de la base) et passerelle d'exécution des handlers.
    async fn build_pipeline(
        &self,
        subscription_id: &RecordId,
        client: &surrealdb::Surreal<surrealdb::engine::any::Any>,
        lease_manager: &Arc<OutboxLeaseManager>,
        cancel: &CancellationToken,
    ) -> Result<SubscriptionPipeline, LyxalEventError> {
        let subscription = subscription_id.to_sql();
        let disp_config = DispatcherConfig {
            max_unacked: self.config.max_unacked,
            delivery_policy: DeliveryPolicy {
                max_redelivery_count: self.config.max_redelivery_count,
                ack_timeout: self.config.ack_timeout,
                base_redelivery_delay: self.config.retry_base_delay,
                max_redelivery_delay: self.config.retry_max_delay,
                jitter: self.config.jitter,
                ..Default::default()
            },
            poison_policy: PoisonPolicy::DeadLetter,
            subscription_name: subscription.to_string(),
            // La politique DeadLetter exige un topic : à défaut de configuration, un topic propre
            // à l'abonnement (sinon le message épuisé reste bloqué, jamais transféré en DLQ).
            dead_letter_topic: Some(
                self.config
                    .dead_letter_topic
                    .clone()
                    .unwrap_or_else(|| format!("{subscription}.dead_letter")),
            ),
        };
        let dispatcher = Arc::new(Mutex::new(ReliableDispatcher::new(
            disp_config,
            cancel.clone(),
        )));
        let mut feeder = OutboxFeeder::new(
            client.clone(),
            Arc::clone(lease_manager),
            Arc::clone(&dispatcher),
        );
        match feeder.restore_progress(subscription_id).await {
            Ok(_) => {}
            Err(FeederError::Fenced) => return Err(LyxalEventError::StaleLeaderFenced),
            Err(e) => {
                return Err(LyxalEventError::Internal(format!(
                    "reprise de la progression de {subscription} : {e}"
                )))
            }
        }
        let bridge = HandlerConsumerBridge::new(
            BridgeConfig {
                consumer_id: format!("{}_bridge", self.config.worker_id),
                dispatch_timeout: self.config.dispatch_timeout,
            },
            (*self.registry).clone(),
            cancel.clone(),
        );
        let rx = {
            let mut disp = dispatcher.lock().await;
            bridge.register_with_dispatcher(&mut disp, self.config.max_unacked)
        };
        Ok(SubscriptionPipeline { feeder, bridge, rx })
    }

    async fn fetch_and_enqueue_pending(
        &self,
        pipelines: &mut HashMap<String, SubscriptionPipeline>,
        client: &surrealdb::Surreal<surrealdb::engine::any::Any>,
        lease_manager: &Arc<OutboxLeaseManager>,
        cancel: &CancellationToken,
    ) -> Result<usize, LyxalEventError> {
        // 1. Reprise des fan-outs en attente (création des event_delivery manquantes). Un échec est
        //    remonté au tour du worker, jamais ignoré.
        self.store
            .recover_pending_fanouts(self.config.batch_size)
            .await?;

        // 2. Récupère les livraisons éligibles via la fonction canonique SurrealQL
        let params = crate::engine::dto::DeliveryFetchPendingParams {
            limit: self.config.batch_size,
            instance_id: self.config.instance_id.clone(),
            subscription: None,
        };
        let deliveries = self.store.fetch_pending_deliveries(params).await?;

        let mut enqueued = 0;
        for rec in deliveries {
            let sub_id = rec.subscription.to_sql();
            if !pipelines.contains_key(&sub_id) {
                let pipeline = self
                    .build_pipeline(&rec.subscription, client, lease_manager, cancel)
                    .await?;
                pipelines.insert(sub_id.clone(), pipeline);
            }
            let Some(pipeline) = pipelines.get_mut(&sub_id) else {
                continue;
            };

            // Une livraison dont l'événement d'origine est incomplet (outbox supprimé ou corrompu)
            // part en dead letter avec son motif : jamais d'événement aux valeurs inventées.
            let envelope = match envelope_from_pending(&rec) {
                Ok(envelope) => envelope,
                Err(missing) => {
                    let reason = format!(
                        "Livraison incomplète : champ(s) absent(s) de l'événement d'origine : {}",
                        missing.join(", ")
                    );
                    match pipeline
                        .feeder
                        .dead_letter_incomplete(
                            rec.id.clone(),
                            &rec.subscription,
                            rec.delivery_seq,
                            reason,
                        )
                        .await
                    {
                        Ok(()) => {
                            self.metrics
                                .deliveries_dead_lettered
                                .fetch_add(1, Ordering::SeqCst);
                        }
                        Err(FeederError::Fenced) => return Err(LyxalEventError::StaleLeaderFenced),
                        Err(e) => {
                            warn!(error = ?e, "Échec du transfert d'une livraison incomplète en dead letter")
                        }
                    }
                    continue;
                }
            };

            let target_module = rec.target_module.clone();
            let context = serde_json::to_value(&envelope.context)?;

            match pipeline
                .feeder
                .assign_and_enqueue(
                    &rec.outbox_event,
                    &rec.subscription,
                    &target_module,
                    context,
                    envelope,
                )
                .await
            {
                Ok(_seq) => {
                    enqueued += 1;
                    self.metrics.events_enqueued.fetch_add(1, Ordering::SeqCst);
                }
                // File de cet abonnement pleine : la livraison reste en attente pour un tour suivant
                Err(FeederError::Backpressure) => {}
                Err(FeederError::Fenced) => return Err(LyxalEventError::StaleLeaderFenced),
                Err(e) => {
                    warn!(error = ?e, "Échec lors de assign_and_enqueue");
                }
            }
        }

        Ok(enqueued)
    }
}

/// Reconstitue l'enveloppe d'un événement depuis une livraison en attente. Renvoie la liste des
/// champs absents si l'événement d'origine est incomplet.
fn envelope_from_pending(
    rec: &crate::engine::dto::PendingDeliveryItem,
) -> Result<LyxalEventEnvelope, Vec<&'static str>> {
    let mut missing = Vec::new();
    if rec.event_id.is_none() {
        missing.push("event_id");
    }
    if rec.event_type.is_none() {
        missing.push("event_type");
    }
    if rec.version.is_none() {
        missing.push("version");
    }
    if rec.producer.is_none() {
        missing.push("producer");
    }
    if rec.correlation_id.is_none() {
        missing.push("correlation_id");
    }
    if rec.payload.is_none() {
        missing.push("payload");
    }
    if rec.context.is_none() {
        missing.push("context");
    }
    if rec.created_at.is_none() {
        missing.push("created_at");
    }
    let (
        Some(event_id),
        Some(event_type),
        Some(version),
        Some(producer),
        Some(correlation_id),
        Some(payload),
        Some(context),
        Some(created_at),
    ) = (
        rec.event_id,
        rec.event_type.clone(),
        rec.version,
        rec.producer.clone(),
        rec.correlation_id,
        rec.payload.clone(),
        rec.context.clone(),
        rec.created_at,
    )
    else {
        return Err(missing);
    };

    let mut metadata = rec
        .metadata
        .clone()
        .unwrap_or_else(|| serde_json::json!({}));
    if let serde_json::Value::Object(ref mut map) = metadata {
        map.insert(
            "delivery_id".to_string(),
            serde_json::Value::String(rec.id.to_sql()),
        );
    }
    Ok(LyxalEventEnvelope {
        id: Some(rec.outbox_event.clone()),
        event_id,
        event_type,
        version,
        producer,
        source: rec.source.clone(),
        context,
        correlation_id,
        causation_id: rec.causation_id,
        payload,
        metadata,
        created_at,
    })
}
