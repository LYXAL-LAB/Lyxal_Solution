use crate::error::RuntimeError;
use crate::package::ModulePackage;
use crate::reconciler::desired::{DesiredRuntimeState, ModuleTargetState};
use crate::reconciler::differ::RuntimeDiffer;
use crate::reconciler::observer::RuntimeObserver;
use crate::reconciler::plan::{ActionKind, ReconciliationPlan};
use crate::reconciler::report::{
    ActionOutcome, ConvergenceStatus, DriftItem, NotAttemptedAction, ReconciliationActionFailure,
    ReconciliationReport, SkippedRevalidationAction, SkippedRevalidationReason,
};
use crate::runtime::LyxalRuntime;
use crate::types::{ModuleId, ModuleState};
use std::collections::HashSet;
use std::sync::Arc;
use std::time::Instant;

/// Moteur principal d'orchestration déclarative DRA (Declarative Runtime Architecture).
///
/// Responsable d'observer l'état réel, de calculer le différentiel avec l'état souhaité (Dry-Run),
/// et d'appliquer les mutations nécessaires via les pipelines certifiés V1.0–V1.5.
pub struct RuntimeReconciler {
    runtime: Arc<LyxalRuntime>,
}

impl RuntimeReconciler {
    /// Crée un nouveau moteur de réconciliation adossé à un runtime Lyxal.
    pub fn new(runtime: Arc<LyxalRuntime>) -> Self {
        Self { runtime }
    }

    /// Construit l'observateur d'état réel en lecture seule.
    pub fn observer(&self) -> RuntimeObserver<'_> {
        RuntimeObserver::new(
            self.runtime.store(),
            self.runtime.registry(),
            self.runtime.lifecycle(),
        )
    }

    /// Calcule le plan de réconciliation en mode Dry-Run pur (zéro I/O mutationnel).
    pub async fn plan(
        &self,
        desired: &DesiredRuntimeState,
        available: &[ModulePackage],
    ) -> Result<ReconciliationPlan, RuntimeError> {
        let observer = self.observer();
        let actual = observer.observe().await?;
        let known_descriptors = self.runtime.registry().descriptors();

        RuntimeDiffer::diff(
            desired,
            &actual,
            available,
            self.runtime.config().runtime_version(),
            &known_descriptors,
        )
    }

    /// Applique les actions planifiées en revalidant systématiquement les préconditions (TOCTOU).
    pub async fn apply(
        &self,
        plan: ReconciliationPlan,
        available: &[ModulePackage],
        desired: &DesiredRuntimeState,
    ) -> Result<ReconciliationReport, RuntimeError> {
        let start_time = Instant::now();
        let planned_count = plan.actions.len();

        let mut executed = Vec::new();
        let mut skipped_revalidation = Vec::new();
        let mut failed = Vec::new();
        let mut not_attempted = Vec::new();
        let mut failed_modules: HashSet<ModuleId> = HashSet::new();

        // Exécution ordonnée des actions
        for action in plan.actions {
            let mod_id = action.module_id.clone();

            // 1. Isolation des pannes : si le module lui-même ou l'une de ses dépendances a échoué
            if failed_modules.contains(&mod_id) {
                not_attempted.push(NotAttemptedAction {
                    module_id: mod_id,
                    intended_action: action.kind,
                    reason: "Module has previously failed in this reconciliation pass".to_string(),
                });
                continue;
            }

            let desc_opt = self
                .runtime
                .registry()
                .get_descriptor(&mod_id)
                .or_else(|| {
                    action
                        .package
                        .as_ref()
                        .and_then(|p| p.manifest().to_descriptor().ok())
                })
                .or_else(|| {
                    available
                        .iter()
                        .find(|p| p.id() == &mod_id)
                        .and_then(|p| p.manifest().to_descriptor().ok())
                });

            if let Some(desc) = desc_opt {
                let has_failed_dep = desc.dependencies.iter().any(|d| failed_modules.contains(d));
                if has_failed_dep {
                    failed_modules.insert(mod_id.clone());
                    not_attempted.push(NotAttemptedAction {
                        module_id: mod_id,
                        intended_action: action.kind,
                        reason: "A required dependency failed to install or start in this reconciliation pass".to_string(),
                    });
                    continue;
                }
            }

            // 2. Revalidation TOCTOU avant exécution
            let current_lifecycle = self.runtime.module_state(&mod_id);

            match &action.kind {
                ActionKind::Install { candidate_version } => {
                    // Si déjà installé et conforme, ignorer
                    if let Some(store) = self.runtime.store() {
                        if let Ok(Some(rel)) = store
                            .get_release(&mod_id, &candidate_version.to_string())
                            .await
                        {
                            if rel.status == "Installed" || rel.status == "Active" {
                                skipped_revalidation.push(SkippedRevalidationAction {
                                    module_id: mod_id,
                                    action_kind: action.kind,
                                    reason: SkippedRevalidationReason::AlreadyConverged,
                                });
                                continue;
                            }
                        }
                    }

                    // Recherche du package à installer
                    let pkg = action.package.clone().or_else(|| {
                        available
                            .iter()
                            .find(|p| p.id() == &mod_id && p.version() == candidate_version)
                            .cloned()
                    });

                    let package_to_install = match pkg {
                        Some(p) => p,
                        None => {
                            let err = RuntimeError::Internal {
                                code: "PACKAGE_MISSING_DURING_APPLY",
                                message: format!(
                                    "Package for module '{}' (v{}) was not provided during apply",
                                    mod_id, candidate_version
                                ),
                            };
                            failed.push(ReconciliationActionFailure {
                                module_id: mod_id.clone(),
                                action_kind: action.kind,
                                error: err,
                            });
                            failed_modules.insert(mod_id);
                            continue;
                        }
                    };

                    // Exécution de l'installation via le pipeline V1.5
                    match self.runtime.install_package(package_to_install).await {
                        Ok(_) => {
                            executed.push(ActionOutcome {
                                module_id: mod_id,
                                kind: action.kind,
                                success: true,
                            });
                        }
                        Err(err) => {
                            failed.push(ReconciliationActionFailure {
                                module_id: mod_id.clone(),
                                action_kind: action.kind,
                                error: err,
                            });
                            failed_modules.insert(mod_id);
                        }
                    }
                }

                ActionKind::Start => {
                    // Revalidation de l'état Running
                    if current_lifecycle == Some(ModuleState::Running) {
                        skipped_revalidation.push(SkippedRevalidationAction {
                            module_id: mod_id,
                            action_kind: action.kind,
                            reason: SkippedRevalidationReason::AlreadyConverged,
                        });
                        continue;
                    }

                    // Si en échec inattendu
                    if let Some(ModuleState::Failed { error, .. }) = &current_lifecycle {
                        let err = RuntimeError::StartFailure {
                            module: mod_id.clone(),
                            message: format!("Module is in failed state: {}", error),
                        };
                        failed.push(ReconciliationActionFailure {
                            module_id: mod_id.clone(),
                            action_kind: action.kind,
                            error: err,
                        });
                        failed_modules.insert(mod_id);
                        continue;
                    }

                    // Exécution du démarrage
                    match self.runtime.start_module(&mod_id).await {
                        Ok(()) => {
                            executed.push(ActionOutcome {
                                module_id: mod_id,
                                kind: action.kind,
                                success: true,
                            });
                        }
                        Err(err) => {
                            failed.push(ReconciliationActionFailure {
                                module_id: mod_id.clone(),
                                action_kind: action.kind,
                                error: err,
                            });
                            failed_modules.insert(mod_id);
                        }
                    }
                }

                ActionKind::Stop => {
                    // Revalidation de l'état Stopped
                    if current_lifecycle.as_ref().map(|s| s.is_running()) != Some(true) {
                        skipped_revalidation.push(SkippedRevalidationAction {
                            module_id: mod_id,
                            action_kind: action.kind,
                            reason: SkippedRevalidationReason::AlreadyConverged,
                        });
                        continue;
                    }

                    // Exécution de l'arrêt
                    match self.runtime.stop_module(&mod_id).await {
                        Ok(()) => {
                            executed.push(ActionOutcome {
                                module_id: mod_id,
                                kind: action.kind,
                                success: true,
                            });
                        }
                        Err(err) => {
                            failed.push(ReconciliationActionFailure {
                                module_id: mod_id.clone(),
                                action_kind: action.kind,
                                error: err,
                            });
                            failed_modules.insert(mod_id);
                        }
                    }
                }

                ActionKind::MarkInactive => {
                    // Marquage inactif persistant si applicable
                    if let Some(store) = self.runtime.store() {
                        if let Some(desc) = self
                            .runtime
                            .registry()
                            .get(&mod_id)
                            .map(|m| m.descriptor().clone())
                        {
                            let _ = store
                                .update_release_status(&mod_id, &desc.version, "Inactive", None)
                                .await;
                        }
                    }
                    executed.push(ActionOutcome {
                        module_id: mod_id,
                        kind: action.kind,
                        success: true,
                    });
                }
            }
        }

        // 3. Ré-observation réelle finale à l'issue de la passe
        let observer = self.observer();
        let final_state = observer.observe().await?;

        // 4. Calcul des divergences résiduelles (Drift)
        let mut remaining_drift = Vec::new();
        for m in &desired.modules {
            let actual_obs = final_state.get(&m.module_id);
            let is_match = match m.target {
                ModuleTargetState::Running => actual_obs.map(|a| a.is_running()).unwrap_or(false),
                ModuleTargetState::Installed => actual_obs
                    .map(|a| a.is_installed() && !a.is_running())
                    .unwrap_or(false),
                ModuleTargetState::Stopped => actual_obs
                    .map(|a| a.is_stopped_or_installed())
                    .unwrap_or(false),
                ModuleTargetState::Absent => actual_obs.map(|a| !a.is_running()).unwrap_or(true),
            };

            if !is_match {
                let actual_desc = actual_obs
                    .and_then(|a| a.runtime_state.as_ref())
                    .map(|s| s.to_string())
                    .or_else(|| {
                        actual_obs
                            .and_then(|a| a.release_status.as_ref())
                            .map(|s| s.to_string())
                    })
                    .unwrap_or_else(|| "Absent".to_string());

                remaining_drift.push(DriftItem {
                    module_id: m.module_id.clone(),
                    desired: m.target,
                    actual: actual_desc,
                });
            }
        }

        // 5. Détermination du statut de convergence
        let convergence =
            if failed.is_empty() && plan.blockers.is_empty() && remaining_drift.is_empty() {
                ConvergenceStatus::Converged
            } else if !executed.is_empty() || (!remaining_drift.is_empty() && failed.is_empty()) {
                ConvergenceStatus::PartiallyConverged
            } else {
                ConvergenceStatus::Failed
            };

        let duration_ms = start_time.elapsed().as_millis() as u64;

        Ok(ReconciliationReport {
            planned_actions: planned_count,
            executed,
            skipped_revalidation,
            failed,
            not_attempted,
            final_state,
            remaining_drift,
            convergence,
            duration_ms,
        })
    }

    /// Raccourci One-Pass pour planifier et appliquer directement la réconciliation.
    pub async fn reconcile(
        &self,
        desired: &DesiredRuntimeState,
        available: &[ModulePackage],
    ) -> Result<ReconciliationReport, RuntimeError> {
        let plan = self.plan(desired, available).await?;
        self.apply(plan, available, desired).await
    }
}
