use crate::context::ModuleContext;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{HealthEvent, RuntimeEventPayload};
use crate::health::check::HealthCheckResult;
use crate::health::registry::HealthRegistry;
use crate::health::snapshot::HealthSnapshot;
use crate::health::status::HealthStatus;
use crate::reconciler::actual::ActualRuntimeState;
use crate::types::{ModuleId, ModuleState};
use crate::worker::descriptor::WorkerCriticality;
use crate::worker::state::WorkerState;
use crate::worker::supervisor::WorkerSupervisor;
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::sync::Semaphore;

/// Configuration du moteur de santé.
#[derive(Debug, Clone)]
pub struct HealthConfig {
    /// Délai maximal alloué à l'exécution d'un contrôle de santé individuel.
    pub check_timeout: Duration,
    /// Nombre maximal de contrôles de santé exécutés en parallèle.
    pub max_concurrency: usize,
}

impl Default for HealthConfig {
    fn default() -> Self {
        Self {
            check_timeout: Duration::from_secs(5),
            max_concurrency: 8,
        }
    }
}

/// Moteur d'exécution et d'agrégation des contrôles de santé.
#[derive(Clone)]
pub struct HealthEngine {
    registry: HealthRegistry,
    config: HealthConfig,
    worker_supervisor: Option<Arc<WorkerSupervisor>>,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl HealthEngine {
    /// Construit une nouvelle instance de `HealthEngine`.
    pub fn new(registry: HealthRegistry, config: HealthConfig) -> Self {
        Self {
            registry,
            config,
            worker_supervisor: None,
            event_bus: None,
        }
    }

    /// Associe un superviseur de workers au moteur de santé pour l'agrégation.
    pub fn with_worker_supervisor(mut self, supervisor: Arc<WorkerSupervisor>) -> Self {
        self.worker_supervisor = Some(supervisor);
        self
    }

    /// Attache un bus d'événements pour la publication des transitions de santé.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    /// Publie les transitions de santé significatives entre deux instantanés de santé consécutifs.
    pub async fn publish_transitions(&self, previous: &HealthSnapshot, current: &HealthSnapshot) {
        if let Some(bus) = &self.event_bus {
            let transitions = current.transitions_from(previous);
            for transition in transitions {
                let mod_id = transition.module_id.clone();
                let draft = RuntimeEventDraft::new(
                    RuntimeEventKind::Health,
                    RuntimeEventPayload::Health(HealthEvent::Transition(transition)),
                )
                .with_module_id(mod_id);
                let _ = bus.publish(draft).await;
            }
        }
    }

    /// Retourne une référence vers le registre de vérificateurs.
    pub fn registry(&self) -> &HealthRegistry {
        &self.registry
    }

    /// Retourne la configuration courante du moteur.
    pub fn config(&self) -> &HealthConfig {
        &self.config
    }

    /// Exécute le contrôle de santé pour un module spécifique.
    pub async fn check_module(
        &self,
        module_id: &ModuleId,
        ctx: &ModuleContext,
    ) -> HealthCheckResult {
        let checker = self.registry.get_check(module_id);

        let mut base_result = if let Some(checker) = checker {
            let start = Instant::now();
            let timeout_duration = self.config.check_timeout;

            match tokio::time::timeout(timeout_duration, checker.check(ctx)).await {
                Ok(Ok(result)) => result,
                Ok(Err(err)) => {
                    let latency_ms = start.elapsed().as_millis() as u64;
                    HealthCheckResult::unhealthy(
                        module_id.clone(),
                        Some(latency_ms),
                        Some(format!("Health check failed: {}", err)),
                    )
                }
                Err(_) => {
                    let latency_ms = start.elapsed().as_millis() as u64;
                    HealthCheckResult::unhealthy(
                        module_id.clone(),
                        Some(latency_ms),
                        Some(format!(
                            "Health check timed out after {}ms",
                            timeout_duration.as_millis()
                        )),
                    )
                }
            }
        } else {
            HealthCheckResult::unknown(module_id.clone())
        };

        // Intégration de la santé des workers du module
        if let Some(supervisor) = &self.worker_supervisor {
            let worker_health_map = supervisor.all_health();
            let module_workers: Vec<_> = worker_health_map
                .values()
                .filter(|wh| &wh.worker_id.module_id() == module_id)
                .collect();

            let mut has_failed_required = false;
            let mut has_failed_optional_or_restarting = false;
            let mut worker_error_msg = None;

            for wh in module_workers {
                if wh.state == WorkerState::Failed {
                    if wh.criticality == WorkerCriticality::Required {
                        has_failed_required = true;
                        worker_error_msg = Some(format!(
                            "Required worker '{}' failed: {}",
                            wh.worker_id,
                            wh.last_error.as_deref().unwrap_or("unknown error")
                        ));
                        break;
                    } else {
                        has_failed_optional_or_restarting = true;
                        if worker_error_msg.is_none() {
                            worker_error_msg = Some(format!(
                                "Optional worker '{}' failed: {}",
                                wh.worker_id,
                                wh.last_error.as_deref().unwrap_or("unknown error")
                            ));
                        }
                    }
                } else if wh.state == WorkerState::Restarting {
                    has_failed_optional_or_restarting = true;
                    if worker_error_msg.is_none() {
                        worker_error_msg = Some(format!("Worker '{}' is restarting", wh.worker_id));
                    }
                }
            }

            if has_failed_required {
                base_result.status = HealthStatus::Unhealthy;
                if let Some(msg) = worker_error_msg {
                    base_result.message = Some(msg);
                }
            } else if has_failed_optional_or_restarting
                && (base_result.status == HealthStatus::Healthy
                    || base_result.status == HealthStatus::Unknown)
            {
                base_result.status = HealthStatus::Degraded;
                if let Some(msg) = worker_error_msg {
                    base_result.message = Some(msg);
                }
            }
        }

        base_result
    }

    /// Exécute l'évaluation de santé sur l'ensemble des modules d'un `ActualRuntimeState`.
    ///
    /// Règles d'évaluation formelles CTO :
    /// - `Running` + checker $\to$ exécute le check (borné avec timeout).
    /// - `Running` + sans checker $\to$ `Unknown`.
    /// - Non `Running` (`Stopped`, `Installed`, etc.) $\to$ `NotApplicable`.
    pub async fn check_all(
        &self,
        actual_state: &ActualRuntimeState,
        base_ctx: &ModuleContext,
    ) -> HealthSnapshot {
        let semaphore = Arc::new(Semaphore::new(self.config.max_concurrency));
        let mut tasks = Vec::new();

        for (module_id, observed) in actual_state.modules() {
            let is_running = observed.runtime_state == Some(ModuleState::Running);

            if !is_running {
                let reason = format!(
                    "Module is not running (state: {:?})",
                    observed.runtime_state
                );
                let res = HealthCheckResult::not_applicable(module_id.clone(), Some(reason));
                tasks.push(tokio::spawn(async move { res }));
                continue;
            }

            let engine = self.clone();
            let mod_id = module_id.clone();
            let ctx = base_ctx.clone();
            let sem = semaphore.clone();

            tasks.push(tokio::spawn(async move {
                let _permit = sem.acquire().await.ok();
                engine.check_module(&mod_id, &ctx).await
            }));
        }

        let mut results = Vec::with_capacity(tasks.len());
        for task in tasks {
            if let Ok(res) = task.await {
                results.push(res);
            }
        }

        HealthSnapshot::new(results)
    }
}
