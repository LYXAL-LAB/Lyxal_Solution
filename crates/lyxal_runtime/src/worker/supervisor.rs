use crate::context::ModuleContext;
use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{RuntimeEventPayload, WorkerEvent};
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use crate::worker::context::WorkerContext;
use crate::worker::definition::LyxalWorker;
use crate::worker::handle::WorkerHandle;
use crate::worker::id::WorkerId;
use crate::worker::metrics::{WorkerHealth, WorkerMetrics};
use crate::worker::registry::WorkerRegistry;
use crate::worker::report::WorkerBatchReport;
use crate::worker::state::{WorkerExitReason, WorkerState};
use crate::worker::store::WorkerStore;
use std::collections::{BTreeMap, HashMap};
use std::sync::{Arc, RwLock};
use std::time::{Duration, Instant};
use tokio::task::JoinHandle;

/// Moteur officiel de supervision et d'orchestration des workers d'arrière-plan de Lyxal OS.
pub struct WorkerSupervisor {
    registry: Arc<WorkerRegistry>,
    handles: Arc<RwLock<HashMap<WorkerId, Arc<WorkerHandle>>>>,
    store: Option<Arc<dyn WorkerStore>>,
    node_id: NodeId,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl WorkerSupervisor {
    /// Crée une nouvelle instance de `WorkerSupervisor`.
    pub fn new(registry: Arc<WorkerRegistry>, node_id: NodeId) -> Self {
        Self {
            registry,
            handles: Arc::new(RwLock::new(HashMap::new())),
            store: None,
            node_id,
            event_bus: None,
        }
    }

    /// Associe un bus d'événements pour la publication des étapes de cycle de vie des workers.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    async fn emit(&self, module_id: &ModuleId, payload: WorkerEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Worker,
                RuntimeEventPayload::Worker(payload),
            )
            .with_module_id(module_id.clone());
            let _ = bus.publish(draft).await;
        }
    }

    /// Associe un magasin de persistance pour l'état des workers.
    pub fn with_store(mut self, store: Arc<dyn WorkerStore>) -> Self {
        self.store = Some(store);
        self
    }

    /// Retourne une référence vers le registre de workers supervisé.
    pub fn registry(&self) -> &WorkerRegistry {
        &self.registry
    }

    /// Retourne l'identifiant du nœud d'exécution.
    pub fn node_id(&self) -> &NodeId {
        &self.node_id
    }

    /// Récupère ou instancie le handle de gestion d'un worker.
    fn get_or_create_handle(&self, worker: &Arc<dyn LyxalWorker>) -> Arc<WorkerHandle> {
        let descriptor = worker.descriptor();
        let id = descriptor.id.clone();
        let module_id = descriptor.module_id.clone();

        let mut handles = self
            .handles
            .write()
            .unwrap_or_else(|poisoned| poisoned.into_inner());

        handles
            .entry(id.clone())
            .or_insert_with(|| Arc::new(WorkerHandle::new(id, module_id)))
            .clone()
    }

    /// Démarre un worker individuel de manière contrôlée et supervisée.
    ///
    /// Garantit le single-instance invariant (10 appels concurrents convergent vers une seule tâche).
    pub async fn start_worker(&self, worker_id: &WorkerId) -> Result<(), RuntimeError> {
        let worker = self
            .registry
            .get(worker_id)
            .ok_or_else(|| RuntimeError::WorkerNotFound {
                worker: worker_id.to_string(),
            })?;

        let descriptor = worker.descriptor();
        let module_id = descriptor.module_id.clone();
        let handle = self.get_or_create_handle(&worker);

        // 1. Contrôle d'état atomique
        let (current_epoch, cancellation) = {
            let current_state = handle.state();
            if current_state == WorkerState::Running || current_state == WorkerState::Starting {
                // Déjà actif : idempotence immédiate
                return Ok(());
            }

            if !current_state.can_transition_to(&WorkerState::Starting) {
                return Err(RuntimeError::WorkerInvalidTransition {
                    worker: worker_id.to_string(),
                    from: current_state.to_string(),
                    to: WorkerState::Starting.to_string(),
                });
            }

            let next_epoch = handle.next_generation();
            handle.set_state(WorkerState::Starting);
            handle.record_started();
            let token = handle.renew_cancellation();
            (next_epoch, token)
        };

        self.emit(
            &module_id,
            WorkerEvent::Starting {
                worker_id: worker_id.clone(),
            },
        )
        .await;

        // 2. Persistance synchrone initiale
        self.persist_worker_state(&worker, &handle, WorkerState::Starting)
            .await;

        // 3. Lancement de la tâche Tokio supervisée
        let supervisor_ref = Arc::new(Self {
            registry: self.registry.clone(),
            handles: self.handles.clone(),
            store: self.store.clone(),
            node_id: self.node_id.clone(),
            event_bus: self.event_bus.clone(),
        });

        let worker_clone = worker.clone();
        let handle_clone = handle.clone();

        let join_handle: JoinHandle<()> = tokio::spawn(async move {
            supervisor_ref
                .supervise_loop(worker_clone, handle_clone, cancellation, current_epoch)
                .await;
        });

        handle.set_join_handle(join_handle);

        Ok(())
    }

    /// Boucle de supervision continue d'un worker avec capture des paniques et application de la `RestartPolicy`.
    async fn supervise_loop(
        &self,
        worker: Arc<dyn LyxalWorker>,
        handle: Arc<WorkerHandle>,
        mut cancellation: crate::worker::context::CancellationToken,
        mut current_epoch: u64,
    ) {
        let descriptor = worker.descriptor();
        let module_id = descriptor.module_id.clone();
        let worker_id = descriptor.id.clone();

        loop {
            // Vérification anti-zombie : si l'époque a changé ou annulation demandée, arrêt immédiat
            if handle.generation() != current_epoch || cancellation.is_cancelled() {
                handle.set_state(WorkerState::Stopped);
                handle.record_stopped();
                self.persist_worker_state(&worker, &handle, WorkerState::Stopped)
                    .await;
                self.emit(
                    &module_id,
                    WorkerEvent::Stopped {
                        worker_id: worker_id.clone(),
                        reason: WorkerExitReason::Cancelled,
                    },
                )
                .await;
                break;
            }

            // A. Passage à l'état Running
            handle.set_state(WorkerState::Running);
            self.persist_worker_state(&worker, &handle, WorkerState::Running)
                .await;
            self.emit(
                &module_id,
                WorkerEvent::Started {
                    worker_id: worker_id.clone(),
                },
            )
            .await;

            // B. Exécution protégée contre les paniques
            let ctx = WorkerContext::new(
                module_id.clone(),
                worker_id.clone(),
                ModuleContext::new(module_id.clone()),
                cancellation.clone(),
            );

            let worker_ref = worker.clone();
            let run_future = async move { worker_ref.run(ctx).await };

            let run_result = tokio::spawn(run_future).await;

            // C. Analyse typée de la cause de sortie
            let exit_reason = match run_result {
                Ok(Ok(())) => {
                    if cancellation.is_cancelled() {
                        WorkerExitReason::Cancelled
                    } else {
                        WorkerExitReason::Completed
                    }
                }
                Ok(Err(err)) => {
                    if cancellation.is_cancelled() {
                        WorkerExitReason::Cancelled
                    } else {
                        WorkerExitReason::Failed(err.to_string())
                    }
                }
                Err(join_err) => {
                    if join_err.is_cancelled() || cancellation.is_cancelled() {
                        WorkerExitReason::Cancelled
                    } else if join_err.is_panic() {
                        let panic_msg = match join_err.into_panic().downcast::<String>() {
                            Ok(msg) => *msg,
                            Err(any_panic) => match any_panic.downcast::<&str>() {
                                Ok(msg) => msg.to_string(),
                                Err(_) => "Unknown panic payload".to_string(),
                            },
                        };
                        WorkerExitReason::Panicked(panic_msg)
                    } else {
                        WorkerExitReason::Failed(join_err.to_string())
                    }
                }
            };

            handle.record_exit(exit_reason.clone());

            if exit_reason.is_failure() {
                self.emit(
                    &module_id,
                    WorkerEvent::Failed {
                        worker_id: worker_id.clone(),
                        message: format!("{:?}", exit_reason),
                    },
                )
                .await;
            }

            // D. Si arrêt volontaire ou invalidation d'époque : arrêt terminal immédiat
            if matches!(exit_reason, WorkerExitReason::Cancelled)
                || handle.generation() != current_epoch
            {
                handle.set_state(WorkerState::Stopped);
                handle.record_stopped();
                self.persist_worker_state(&worker, &handle, WorkerState::Stopped)
                    .await;
                self.emit(
                    &module_id,
                    WorkerEvent::Stopped {
                        worker_id: worker_id.clone(),
                        reason: exit_reason,
                    },
                )
                .await;
                break;
            }

            // E. Évaluation de la politique de redémarrage
            let current_retries = handle.restart_attempts();
            let restart_policy = &descriptor.restart_policy;

            if restart_policy.should_restart(&exit_reason, current_retries) {
                // Transition vers Restarting
                handle.set_state(WorkerState::Restarting);
                self.persist_worker_state(&worker, &handle, WorkerState::Restarting)
                    .await;

                let next_attempt = handle.increment_restart_attempts();
                let backoff_delay = restart_policy
                    .backoff()
                    .map(|b| b.calculate_delay(next_attempt))
                    .unwrap_or(Duration::from_millis(500));

                self.emit(
                    &module_id,
                    WorkerEvent::RestartScheduled {
                        worker_id: worker_id.clone(),
                        attempt: next_attempt,
                        delay_ms: backoff_delay.as_millis() as u64,
                    },
                )
                .await;

                // Sommeil interruptible par CancellationToken
                tokio::select! {
                    _ = cancellation.cancelled() => {
                        // Annulation pendant le sommeil de backoff
                        handle.set_state(WorkerState::Stopped);
                        handle.record_stopped();
                        self.persist_worker_state(&worker, &handle, WorkerState::Stopped).await;
                        self.emit(
                            &module_id,
                            WorkerEvent::Stopped {
                                worker_id: worker_id.clone(),
                                reason: WorkerExitReason::Cancelled,
                            },
                        )
                        .await;
                        break;
                    }
                    _ = tokio::time::sleep(backoff_delay) => {}
                }

                // Vérification post-sommeil (Anti-Zombie Protection)
                if handle.generation() != current_epoch || cancellation.is_cancelled() {
                    handle.set_state(WorkerState::Stopped);
                    handle.record_stopped();
                    self.persist_worker_state(&worker, &handle, WorkerState::Stopped)
                        .await;
                    self.emit(
                        &module_id,
                        WorkerEvent::Stopped {
                            worker_id: worker_id.clone(),
                            reason: WorkerExitReason::Cancelled,
                        },
                    )
                    .await;
                    break;
                }

                // Renouvellement du token et poursuite du cycle
                cancellation = handle.renew_cancellation();
                current_epoch = handle.generation();
                self.emit(
                    &module_id,
                    WorkerEvent::Restarted {
                        worker_id: worker_id.clone(),
                        attempt: next_attempt,
                    },
                )
                .await;
                continue;
            } else {
                // Échec terminal ou arrêt normal
                let final_state = if exit_reason.is_failure() {
                    WorkerState::Failed
                } else {
                    WorkerState::Stopped
                };

                handle.set_state(final_state);
                handle.record_stopped();
                self.persist_worker_state(&worker, &handle, final_state)
                    .await;
                self.emit(
                    &module_id,
                    WorkerEvent::Stopped {
                        worker_id: worker_id.clone(),
                        reason: exit_reason,
                    },
                )
                .await;
                break;
            }
        }
    }

    /// Arrête un worker individuel avec graceful shutdown et forçage par abort après timeout.
    pub async fn stop_worker(&self, worker_id: &WorkerId) -> Result<(), RuntimeError> {
        let worker = self
            .registry
            .get(worker_id)
            .ok_or_else(|| RuntimeError::WorkerNotFound {
                worker: worker_id.to_string(),
            })?;

        let descriptor = worker.descriptor();
        let module_id = descriptor.module_id.clone();
        let handle = self.get_or_create_handle(&worker);

        // 1. Marquage Stopping & Invalidation de génération (Anti-Zombie)
        let join_handle = {
            let current_state = handle.state();
            if current_state == WorkerState::Stopped || current_state == WorkerState::Registered {
                return Ok(());
            }

            let _ = handle.next_generation();
            handle.set_state(WorkerState::Stopping);
            handle.cancel();
            handle.take_join_handle()
        };

        self.emit(
            &module_id,
            WorkerEvent::Stopping {
                worker_id: worker_id.clone(),
            },
        )
        .await;

        self.persist_worker_state(&worker, &handle, WorkerState::Stopping)
            .await;

        // 2. Attente gracieuse avec timeout
        if let Some(mut task) = join_handle {
            let shutdown_timeout = descriptor.shutdown_timeout;
            match tokio::time::timeout(shutdown_timeout, &mut task).await {
                Ok(_) => {}
                Err(_) => {
                    // Délai dépassé : abort forcé
                    task.abort();
                    handle.record_exit(WorkerExitReason::ForcedAbort);
                    self.emit(
                        &module_id,
                        WorkerEvent::ForcedAbort {
                            worker_id: worker_id.clone(),
                        },
                    )
                    .await;
                }
            }
        }

        // 3. Finalisation Stopped
        handle.set_state(WorkerState::Stopped);
        handle.record_stopped();
        handle.reset_restart_attempts();
        self.persist_worker_state(&worker, &handle, WorkerState::Stopped)
            .await;

        self.emit(
            &module_id,
            WorkerEvent::Stopped {
                worker_id: worker_id.clone(),
                reason: handle
                    .last_exit_reason()
                    .unwrap_or(WorkerExitReason::Cancelled),
            },
        )
        .await;

        Ok(())
    }

    /// Redémarre un worker de manière séquentielle et déterministe.
    pub async fn restart_worker(&self, worker_id: &WorkerId) -> Result<(), RuntimeError> {
        self.stop_worker(worker_id).await?;
        self.start_worker(worker_id).await?;
        Ok(())
    }

    /// Démarre l'ensemble des workers déclarés pour un module donné.
    pub async fn start_module_workers(
        &self,
        module_id: &ModuleId,
    ) -> Result<WorkerBatchReport, RuntimeError> {
        let start_time = Instant::now();
        let mut report = WorkerBatchReport::new(module_id.clone());
        let workers = self.registry.list_for_module(module_id);

        for worker in workers {
            let id = worker.descriptor().id.clone();
            let current_state = self.state(&id).unwrap_or(WorkerState::Registered);

            if current_state == WorkerState::Running || current_state == WorkerState::Starting {
                report.skipped.push(id);
                continue;
            }

            match self.start_worker(&id).await {
                Ok(()) => report.started.push(id),
                Err(err) => report.failed.push((id, err.to_string())),
            }
        }

        report.duration_ms = start_time.elapsed().as_millis() as u64;
        Ok(report)
    }

    /// Arrête l'ensemble des workers déclarés pour un module donné (exécuté avant `module.stop()`).
    pub async fn stop_module_workers(
        &self,
        module_id: &ModuleId,
    ) -> Result<WorkerBatchReport, RuntimeError> {
        let start_time = Instant::now();
        let mut report = WorkerBatchReport::new(module_id.clone());
        let workers = self.registry.list_for_module(module_id);

        for worker in workers {
            let id = worker.descriptor().id.clone();
            let current_state = self.state(&id).unwrap_or(WorkerState::Stopped);

            if current_state == WorkerState::Stopped || current_state == WorkerState::Registered {
                report.skipped.push(id);
                continue;
            }

            match self.stop_worker(&id).await {
                Ok(()) => report.stopped.push(id),
                Err(err) => report.failed.push((id, err.to_string())),
            }
        }

        report.duration_ms = start_time.elapsed().as_millis() as u64;
        Ok(report)
    }

    /// Démarre l'ensemble des workers enregistrés dans le superviseur.
    pub async fn start_all(&self) -> Result<Vec<WorkerId>, RuntimeError> {
        let mut started = Vec::new();
        for worker in self.registry.list() {
            let id = worker.descriptor().id.clone();
            self.start_worker(&id).await?;
            started.push(id);
        }
        Ok(started)
    }

    /// Arrête l'ensemble des workers enregistrés dans le superviseur.
    pub async fn stop_all(&self) -> Result<Vec<WorkerId>, RuntimeError> {
        let mut stopped = Vec::new();
        for worker in self.registry.list() {
            let id = worker.descriptor().id.clone();
            self.stop_worker(&id).await?;
            stopped.push(id);
        }
        Ok(stopped)
    }

    /// Retourne l'état courant d'un worker s'il est managé ou enregistré.
    pub fn state(&self, worker_id: &WorkerId) -> Option<WorkerState> {
        if let Ok(handles) = self.handles.read() {
            if let Some(h) = handles.get(worker_id) {
                return Some(h.state());
            }
        }
        if self.registry.contains(worker_id) {
            return Some(WorkerState::Registered);
        }
        None
    }

    /// Retourne la carte de tous les états des workers managés.
    pub fn all_states(&self) -> BTreeMap<WorkerId, WorkerState> {
        let mut map = BTreeMap::new();
        for worker in self.registry.list() {
            let id = worker.descriptor().id.clone();
            let state = self.state(&id).unwrap_or(WorkerState::Registered);
            map.insert(id, state);
        }
        map
    }

    /// Retourne la synthèse de santé de tous les workers pour l'intégration `HealthEngine`.
    pub fn all_health(&self) -> BTreeMap<WorkerId, WorkerHealth> {
        let mut map = BTreeMap::new();
        for worker in self.registry.list() {
            let descriptor = worker.descriptor();
            let id = descriptor.id.clone();
            let handle = self.get_or_create_handle(&worker);
            let state = handle.state();
            let metrics = handle.metrics();

            map.insert(
                id.clone(),
                WorkerHealth {
                    worker_id: id,
                    state,
                    criticality: descriptor.criticality,
                    restart_count: metrics.restart_count,
                    last_error: metrics.last_error,
                },
            );
        }
        map
    }

    /// Retourne les métriques d'un worker.
    pub fn metrics(&self, worker_id: &WorkerId) -> Option<WorkerMetrics> {
        let handles = self.handles.read().ok()?;
        handles.get(worker_id).map(|h| h.metrics())
    }

    /// Exécute la persistance non-bloquante de l'état d'un worker vers le `WorkerStore`.
    async fn persist_worker_state(
        &self,
        worker: &Arc<dyn LyxalWorker>,
        handle: &Arc<WorkerHandle>,
        state: WorkerState,
    ) {
        if let Some(store) = &self.store {
            let descriptor = worker.descriptor();
            let metrics = handle.metrics();
            let _ = store
                .upsert_worker(
                    &self.node_id,
                    &descriptor.id,
                    &descriptor.module_id,
                    state,
                    descriptor.criticality,
                    &metrics,
                )
                .await;
        }
    }
}
