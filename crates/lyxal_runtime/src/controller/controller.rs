use crate::context::ModuleContext;
use crate::controller::backoff::ReconciliationBackoff;
use crate::controller::config::ReconciliationLoopConfig;
use crate::controller::snapshot::{ReconciliationReportSummary, RuntimeStatusSnapshot};
use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{ReconciliationEvent, RuntimeEventPayload};
use crate::health::check::chrono_now_string;
use crate::health::engine::HealthEngine;
use crate::health::store::HealthStore;
use crate::lock::node_id::NodeId;
use crate::package::ModulePackage;
use crate::reconciler::desired::DesiredRuntimeState;
use crate::reconciler::reconciler::RuntimeReconciler;
use crate::worker::supervisor::WorkerSupervisor;
use std::future::Future;
use std::pin::pin;
use std::sync::atomic::{AtomicBool, AtomicU32, AtomicU64, Ordering};
use std::sync::{Arc, RwLock};
use std::time::Instant;

/// Guard RAII garantissant la réinitialisation de l'indicateur de passe en cours au Drop.
struct PassGuard(Arc<AtomicBool>);

impl Drop for PassGuard {
    fn drop(&mut self) {
        self.0.store(false, Ordering::SeqCst);
    }
}

/// Contrôleur de réconciliation continue et de supervision de santé (Lyxal Runtime V1.7).
pub struct ContinuousReconciliationController {
    reconciler: Arc<RuntimeReconciler>,
    health_engine: Arc<HealthEngine>,
    node_id: NodeId,
    health_store: Option<Arc<dyn HealthStore>>,
    worker_supervisor: Option<Arc<WorkerSupervisor>>,
    config: ReconciliationLoopConfig,
    desired_state: Arc<RwLock<DesiredRuntimeState>>,
    desired_revision: Arc<AtomicU64>,
    available_packages: Arc<RwLock<Vec<ModulePackage>>>,
    is_running_pass: Arc<AtomicBool>,
    pass_count: Arc<AtomicU64>,
    consecutive_failures: Arc<AtomicU32>,
    last_snapshot: Arc<RwLock<Option<RuntimeStatusSnapshot>>>,
    last_reconciled_at: Arc<RwLock<Option<String>>>,
    backoff: Arc<RwLock<ReconciliationBackoff>>,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl ContinuousReconciliationController {
    /// Construit un nouveau contrôleur de réconciliation continue.
    pub fn new(
        reconciler: Arc<RuntimeReconciler>,
        health_engine: Arc<HealthEngine>,
        node_id: NodeId,
        config: ReconciliationLoopConfig,
    ) -> Self {
        let backoff = Arc::new(RwLock::new(ReconciliationBackoff::new(config.clone())));
        Self {
            reconciler,
            health_engine,
            node_id,
            health_store: None,
            worker_supervisor: None,
            config,
            desired_state: Arc::new(RwLock::new(DesiredRuntimeState::new())),
            desired_revision: Arc::new(AtomicU64::new(1)),
            available_packages: Arc::new(RwLock::new(Vec::new())),
            is_running_pass: Arc::new(AtomicBool::new(false)),
            pass_count: Arc::new(AtomicU64::new(0)),
            consecutive_failures: Arc::new(AtomicU32::new(0)),
            last_snapshot: Arc::new(RwLock::new(None)),
            last_reconciled_at: Arc::new(RwLock::new(None)),
            backoff,
            event_bus: None,
        }
    }

    /// Attache un bus d'événements pour la publication des cycles de réconciliation.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    async fn emit(&self, payload: ReconciliationEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Reconciliation,
                RuntimeEventPayload::Reconciliation(payload),
            );
            let _ = bus.publish(draft).await;
        }
    }

    /// Associe un magasin de santé persistant au contrôleur.
    pub fn with_health_store(mut self, store: Arc<dyn HealthStore>) -> Self {
        self.health_store = Some(store);
        self
    }

    /// Associe un superviseur de workers au contrôleur pour l'observation des workers.
    pub fn with_worker_supervisor(mut self, supervisor: Arc<WorkerSupervisor>) -> Self {
        self.worker_supervisor = Some(supervisor);
        self
    }

    /// Retourne la référence au nœud local.
    pub fn node_id(&self) -> &NodeId {
        &self.node_id
    }

    /// Retourne la configuration de la boucle.
    pub fn config(&self) -> &ReconciliationLoopConfig {
        &self.config
    }

    /// Met à jour l'état cible désiré (`DesiredRuntimeState`).
    ///
    /// Incrémente le numéro de révision de configuration.
    pub fn set_desired_state(&self, desired: DesiredRuntimeState) {
        if let Ok(mut state) = self.desired_state.write() {
            *state = desired;
            self.desired_revision.fetch_add(1, Ordering::SeqCst);
        }
    }

    /// Retourne une copie de l'état désiré actuel.
    pub fn desired_state(&self) -> DesiredRuntimeState {
        self.desired_state
            .read()
            .map(|s| s.clone())
            .unwrap_or_default()
    }

    /// Définit la liste des packages de modules disponibles pour l'installation.
    pub fn set_available_packages(&self, packages: Vec<ModulePackage>) {
        if let Ok(mut pkgs) = self.available_packages.write() {
            *pkgs = packages;
        }
    }

    /// Ajoute un package de module disponible.
    pub fn add_package(&self, package: ModulePackage) {
        if let Ok(mut pkgs) = self.available_packages.write() {
            pkgs.retain(|p| !(p.id() == package.id() && p.version() == package.version()));
            pkgs.push(package);
        }
    }

    /// Retourne la dernière photographie d'état enregistrée.
    pub fn current_snapshot(&self) -> Option<RuntimeStatusSnapshot> {
        self.last_snapshot.read().ok().and_then(|s| s.clone())
    }

    /// Exécute un cycle unique de réconciliation et de contrôle de santé.
    ///
    /// Séquence formelle CTO (Directive #14) :
    /// 1. Observe Actual Initial.
    /// 2. Plan Desired vs Actual Initial (pur in-memory).
    /// 3. Si actions $\to$ Apply puis Observe Actual Final ; sinon Actual Final = Initial.
    /// 4. Run Health Checks sur Actual Final (uniquement modules Running).
    /// 5. Persist Health Snapshot dans `system_health` (si configuré).
    /// 6. Build RuntimeStatusSnapshot & mise à jour du backoff.
    pub async fn run_once(&self) -> Result<RuntimeStatusSnapshot, RuntimeError> {
        // Protection anti-chevauchement (No overlapping passes)
        if self
            .is_running_pass
            .compare_exchange(false, true, Ordering::SeqCst, Ordering::SeqCst)
            .is_err()
        {
            return Err(RuntimeError::Internal {
                code: "CONTROLLER_PASS_ALREADY_RUNNING",
                message: "A continuous reconciliation pass is already in progress".to_string(),
            });
        }
        let _guard = PassGuard(self.is_running_pass.clone());

        let pass_start = Instant::now();
        let current_pass_num = self.pass_count.load(Ordering::SeqCst) + 1;
        self.emit(ReconciliationEvent::PassStarted {
            pass: current_pass_num,
        })
        .await;

        // Snapshot immuable du DesiredState et des Packages (libère les verrous immédiatement)
        let (desired, desired_rev) = {
            let state = self
                .desired_state
                .read()
                .map_err(|_| RuntimeError::Internal {
                    code: "CONTROLLER_LOCK_POISONED",
                    message: "DesiredState read lock was poisoned".to_string(),
                })?
                .clone();
            let rev = self.desired_revision.load(Ordering::SeqCst);
            (state, rev)
        };

        let packages = {
            self.available_packages
                .read()
                .map_err(|_| RuntimeError::Internal {
                    code: "CONTROLLER_LOCK_POISONED",
                    message: "AvailablePackages read lock was poisoned".to_string(),
                })?
                .clone()
        };

        // 1. Observe Actual Initial
        let actual_initial = match self.reconciler.observer().observe().await {
            Ok(actual) => actual,
            Err(err) => {
                if let Ok(mut backoff) = self.backoff.write() {
                    backoff.on_failure();
                    self.consecutive_failures
                        .store(backoff.consecutive_failures(), Ordering::SeqCst);
                }
                self.emit(ReconciliationEvent::PassFailed {
                    pass: current_pass_num,
                    error_code: err.code().to_string(),
                    message: err.to_string(),
                })
                .await;
                return Err(err);
            }
        };

        // 2. Plan Desired vs Actual Initial
        let plan = match self.reconciler.plan(&desired, &packages).await {
            Ok(plan) => plan,
            Err(err) => {
                if let Ok(mut backoff) = self.backoff.write() {
                    backoff.on_failure();
                    self.consecutive_failures
                        .store(backoff.consecutive_failures(), Ordering::SeqCst);
                }
                self.emit(ReconciliationEvent::PassFailed {
                    pass: current_pass_num,
                    error_code: err.code().to_string(),
                    message: err.to_string(),
                })
                .await;
                return Err(err);
            }
        };

        self.emit(ReconciliationEvent::PlanCreated {
            action_count: plan.actions.len(),
            blocker_count: plan.blockers.len(),
        })
        .await;

        // 3. Exécution si actions requises
        let (actual_final, summary, reconciled_at, convergence) = if !plan.actions.is_empty() {
            let report = match self.reconciler.apply(plan, &packages, &desired).await {
                Ok(report) => report,
                Err(err) => {
                    if let Ok(mut backoff) = self.backoff.write() {
                        backoff.on_failure();
                        self.consecutive_failures
                            .store(backoff.consecutive_failures(), Ordering::SeqCst);
                    }
                    self.emit(ReconciliationEvent::PassFailed {
                        pass: current_pass_num,
                        error_code: err.code().to_string(),
                        message: err.to_string(),
                    })
                    .await;
                    return Err(err);
                }
            };

            for executed in &report.executed {
                self.emit(ReconciliationEvent::ActionExecuted {
                    module_id: executed.module_id.clone(),
                    action: format!("{:?}", executed.kind),
                })
                .await;
            }

            let final_actual = match self.reconciler.observer().observe().await {
                Ok(a) => a,
                Err(err) => {
                    if let Ok(mut backoff) = self.backoff.write() {
                        backoff.on_failure();
                        self.consecutive_failures
                            .store(backoff.consecutive_failures(), Ordering::SeqCst);
                    }
                    self.emit(ReconciliationEvent::PassFailed {
                        pass: current_pass_num,
                        error_code: err.code().to_string(),
                        message: err.to_string(),
                    })
                    .await;
                    return Err(err);
                }
            };

            let convergence = report.convergence;
            let summary = Some(ReconciliationReportSummary::from(&report));
            let now_str = chrono_now_string();
            if let Ok(mut lr) = self.last_reconciled_at.write() {
                *lr = Some(now_str.clone());
            }
            (final_actual, summary, Some(now_str), convergence)
        } else {
            let lr = self.last_reconciled_at.read().ok().and_then(|r| r.clone());
            (
                actual_initial,
                None,
                lr,
                crate::reconciler::report::ConvergenceStatus::Converged,
            )
        };

        // 4. Run Health Checks sur Actual Final
        let ctx = ModuleContext::new("system_controller");
        let health_snapshot = self.health_engine.check_all(&actual_final, &ctx).await;

        // Publication des transitions de santé si snapshot précédent existant
        let previous_snapshot = self.last_snapshot.read().ok().and_then(|s| s.clone());
        if let Some(prev) = &previous_snapshot {
            self.health_engine
                .publish_transitions(&prev.health_snapshot, &health_snapshot)
                .await;
        }

        // 5. Persistance de l'état de santé instantané (si configuré)
        if let Some(store) = &self.health_store {
            let _ = store
                .record_health_snapshot(&self.node_id, &health_snapshot)
                .await;
        }

        // 6. Mise à jour de l'état du contrôleur et réinitialisation du backoff
        let pass_num = self.pass_count.fetch_add(1, Ordering::SeqCst) + 1;
        if let Ok(mut backoff) = self.backoff.write() {
            backoff.on_success();
            self.consecutive_failures.store(0, Ordering::SeqCst);
        }

        self.emit(ReconciliationEvent::PassCompleted {
            pass: pass_num,
            convergence,
            duration_ms: pass_start.elapsed().as_millis() as u64,
        })
        .await;

        let worker_states = self
            .worker_supervisor
            .as_ref()
            .map(|s| s.all_states())
            .unwrap_or_default();

        let worker_health = self
            .worker_supervisor
            .as_ref()
            .map(|s| s.all_health())
            .unwrap_or_default();

        let snapshot = RuntimeStatusSnapshot {
            actual_state: actual_final,
            health_snapshot,
            last_report_summary: summary,
            last_reconciled_at: reconciled_at,
            pass_count: pass_num,
            consecutive_failures: 0,
            desired_revision: desired_rev,
            worker_states,
            worker_health,
        };

        if let Ok(mut ls) = self.last_snapshot.write() {
            *ls = Some(snapshot.clone());
        }

        Ok(snapshot)
    }

    /// Démarre la boucle continue de réconciliation et de supervision de santé.
    ///
    /// La boucle s'arrête proprement dès réception du signal `shutdown_signal`.
    pub async fn run<F>(&self, shutdown_signal: F) -> Result<(), RuntimeError>
    where
        F: Future<Output = ()>,
    {
        let mut shutdown_fut = pin!(shutdown_signal);

        // Délai initial optionnel
        if self.config.initial_delay > std::time::Duration::ZERO {
            tokio::select! {
                _ = &mut shutdown_fut => {
                    return Ok(());
                }
                _ = tokio::time::sleep(self.config.initial_delay) => {}
            }
        }

        loop {
            // Exécution d'un cycle
            let _ = self.run_once().await;

            // Calcul du délai d'attente selon le backoff
            let delay = self
                .backoff
                .read()
                .map(|b| b.next_delay())
                .unwrap_or(self.config.interval);

            // Attente sans aucun verrou maintenu
            tokio::select! {
                _ = &mut shutdown_fut => {
                    break;
                }
                _ = tokio::time::sleep(delay) => {}
            }
        }

        Ok(())
    }
}
