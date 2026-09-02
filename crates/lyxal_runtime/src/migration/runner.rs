use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{MigrationEvent, RuntimeEventPayload};
use crate::lock::config::MigrationLockConfig;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::AcquireLeaseResult;
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use crate::lock::recovery::MigrationRecoveryPolicy;
use crate::lock::surreal::SurrealMigrationLeaseManager;
use crate::migration::definition::MigrationRecord;
use crate::migration::discovery::MigrationDiscovery;
use crate::migration::id::MigrationId;
use crate::migration::plan::{MigrationPlan, MigrationPlanAction};
use crate::migration::status::MigrationStatus;
use crate::resource::provider::ResourceProvider;
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use std::time::{Duration, Instant};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::time::sleep;

/// Résultat d'une exécution de migrations par `MigrationRunner`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationRunResult {
    pub module_id: ModuleId,
    pub module_version: String,
    pub applied: Vec<MigrationId>,
    pub skipped: Vec<MigrationId>,
    pub total_duration_ms: u64,
}

/// Résultat d'une simulation (dry-run) de migrations.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationDryRunResult {
    pub module_id: ModuleId,
    pub module_version: String,
    pub to_apply: Vec<MigrationId>,
    pub to_skip: Vec<MigrationId>,
    pub has_drift: bool,
    pub has_interrupted: bool,
}

/// Moteur officiel d'exécution des migrations SurrealQL de Lyxal OS.
///
/// Exécute les migrations de manière strictement séquentielle et déterministe,
/// protège contre les exécutions concurrentes via `MigrationLeaseManager` (fencing tokens),
/// applique la revalidation TOCTOU après acquisition de verrou,
/// enregistre les états `Applying -> Applied / Failed` dans le `RuntimeStore`,
/// et bloque immédiatement en cas d'erreur ou d'altération de checksum (drift).
pub struct MigrationRunner {
    store: Arc<dyn RuntimeStore>,
    client: Surreal<Any>,
    lease_manager: Option<Arc<dyn MigrationLeaseManager>>,
    node_id: NodeId,
    lock_config: MigrationLockConfig,
    recovery_policy: MigrationRecoveryPolicy,
    event_bus: Option<Arc<dyn RuntimeEventBus>>,
}

impl MigrationRunner {
    /// Crée une nouvelle instance de `MigrationRunner` configurée par défaut avec `SurrealMigrationLeaseManager`.
    pub fn new(store: Arc<dyn RuntimeStore>, client: Surreal<Any>) -> Self {
        let lease_mgr = Arc::new(SurrealMigrationLeaseManager::new(client.clone()));
        Self {
            store,
            client,
            lease_manager: Some(lease_mgr),
            node_id: NodeId::generate(),
            lock_config: MigrationLockConfig::default(),
            recovery_policy: MigrationRecoveryPolicy::default(),
            event_bus: None,
        }
    }

    /// Attache un bus d'événements pour la publication des étapes de migration.
    pub fn with_event_bus(mut self, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        self.event_bus = Some(event_bus);
        self
    }

    async fn emit(&self, module_id: &ModuleId, payload: MigrationEvent) {
        if let Some(bus) = &self.event_bus {
            let draft = RuntimeEventDraft::new(
                RuntimeEventKind::Migration,
                RuntimeEventPayload::Migration(payload),
            )
            .with_module_id(module_id.clone());
            let _ = bus.publish(draft).await;
        }
    }

    /// Définit le gestionnaire de baux distribués à utiliser.
    pub fn with_lease_manager(mut self, manager: Arc<dyn MigrationLeaseManager>) -> Self {
        self.lease_manager = Some(manager);
        self
    }

    /// Désactive le verrouillage distribué (pour mode single-runner isolé).
    pub fn without_lease_manager(mut self) -> Self {
        self.lease_manager = None;
        self
    }

    /// Définit l'identifiant du nœud pour cette instance.
    pub fn with_node_id(mut self, node_id: NodeId) -> Self {
        self.node_id = node_id;
        self
    }

    /// Définit la configuration des verrous.
    pub fn with_lock_config(mut self, config: MigrationLockConfig) -> Self {
        self.lock_config = config;
        self
    }

    /// Définit la politique de récupération des migrations interrompues.
    pub fn with_recovery_policy(mut self, policy: MigrationRecoveryPolicy) -> Self {
        self.recovery_policy = policy;
        self
    }

    /// Retourne la référence au `RuntimeStore`.
    pub fn store(&self) -> &Arc<dyn RuntimeStore> {
        &self.store
    }

    /// Retourne la référence au client SurrealDB.
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }

    /// Retourne le `NodeId` de cette instance.
    pub fn node_id(&self) -> &NodeId {
        &self.node_id
    }

    /// Construit le plan de migration pour un module donné.
    pub async fn plan(
        &self,
        module_id: &ModuleId,
        module_version: &str,
        provider: &dyn ResourceProvider,
    ) -> Result<MigrationPlan, RuntimeError> {
        let definitions =
            MigrationDiscovery::discover_migrations(module_id, module_version, provider).await?;

        MigrationPlan::from_definitions_and_store(
            module_id,
            module_version,
            &definitions,
            self.store.as_ref(),
        )
        .await
    }

    /// Exécute une simulation (dry-run) à partir d'un `MigrationPlan`.
    pub fn dry_run(&self, plan: &MigrationPlan) -> MigrationDryRunResult {
        let mut to_apply = Vec::new();
        let mut to_skip = Vec::new();

        for item in plan.items() {
            match &item.action {
                MigrationPlanAction::Apply | MigrationPlanAction::Retry => {
                    to_apply.push(item.definition.id.clone());
                }
                MigrationPlanAction::Skip => {
                    to_skip.push(item.definition.id.clone());
                }
                _ => {}
            }
        }

        MigrationDryRunResult {
            module_id: plan.module_id.clone(),
            module_version: plan.module_version.clone(),
            to_apply,
            to_skip,
            has_drift: plan.has_drift(),
            has_interrupted: plan.has_interrupted(),
        }
    }

    /// Exécute un plan de migration avec verrouillage distribué et revalidation TOCTOU.
    pub async fn execute_plan(
        &self,
        plan: &MigrationPlan,
        provider: &dyn ResourceProvider,
    ) -> Result<MigrationRunResult, RuntimeError> {
        let total_start = Instant::now();
        let mut applied = Vec::new();
        let mut skipped = Vec::new();

        // 1. Vérification préalable globale du plan
        for item in plan.items() {
            match &item.action {
                MigrationPlanAction::FailDrift { expected, actual } => {
                    return Err(RuntimeError::MigrationChecksumMismatch {
                        module: plan.module_id.clone(),
                        migration: item.definition.id.to_string(),
                        expected: expected.as_str().to_string(),
                        actual: actual.as_str().to_string(),
                    });
                }
                MigrationPlanAction::FailInterrupted => {
                    return Err(RuntimeError::MigrationInterrupted {
                        module: plan.module_id.clone(),
                        migration: item.definition.id.to_string(),
                    });
                }
                _ => {}
            }
        }

        // 2. Exécution séquentielle migration par migration
        for item in plan.items() {
            match &item.action {
                MigrationPlanAction::Skip => {
                    skipped.push(item.definition.id.clone());
                }
                MigrationPlanAction::Apply | MigrationPlanAction::Retry => {
                    let lock_key =
                        MigrationLockKey::new(plan.module_id.clone(), item.definition.id.clone());

                    // a. Acquisition du bail distribué si configuré (avec retry jusqu'à timeout)
                    let acquired_lease = if let Some(mgr) = &self.lease_manager {
                        let acquire_start = Instant::now();

                        let lease = loop {
                            let lease_result = mgr
                                .acquire(&lock_key, &self.node_id, self.lock_config.lease_duration)
                                .await?;

                            match lease_result {
                                AcquireLeaseResult::Acquired(l)
                                | AcquireLeaseResult::AlreadyOwned(l) => break l,
                                AcquireLeaseResult::RecoveredExpiredLease(l) => {
                                    self.emit(
                                        &plan.module_id,
                                        MigrationEvent::LeaseRecovered {
                                            migration_id: item.definition.id.clone(),
                                            generation: l.generation,
                                        },
                                    )
                                    .await;
                                    break l;
                                }
                                AcquireLeaseResult::HeldByOther { .. } => {
                                    if acquire_start.elapsed() >= self.lock_config.acquire_timeout {
                                        return Err(RuntimeError::MigrationLockTimeout {
                                            key: lock_key.to_string(),
                                            duration_ms: self
                                                .lock_config
                                                .acquire_timeout
                                                .as_millis()
                                                as u64,
                                        });
                                    }
                                    sleep(self.lock_config.acquire_retry_delay).await;
                                }
                            }
                        };

                        Some(lease)
                    } else {
                        None
                    };

                    // b. REVALIDATION TOCTOU (Time Of Check to Time Of Use)
                    let current_record = self
                        .store
                        .get_migration(&plan.module_id, &item.definition.id)
                        .await?;

                    if let Some(r) = &current_record {
                        if r.status == MigrationStatus::Applied {
                            if r.checksum == item.definition.checksum {
                                // Déjà appliquée par un autre nœud entre-temps !
                                if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease)
                                {
                                    let _ = mgr.release(l).await;
                                }
                                self.emit(
                                    &plan.module_id,
                                    MigrationEvent::Skipped {
                                        migration_id: item.definition.id.clone(),
                                        reason: "Already applied by concurrent node".to_string(),
                                    },
                                )
                                .await;
                                skipped.push(item.definition.id.clone());
                                continue;
                            } else {
                                if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease)
                                {
                                    let _ = mgr.release(l).await;
                                }
                                return Err(RuntimeError::MigrationChecksumMismatch {
                                    module: plan.module_id.clone(),
                                    migration: item.definition.id.to_string(),
                                    expected: r.checksum.as_str().to_string(),
                                    actual: item.definition.checksum.as_str().to_string(),
                                });
                            }
                        } else if r.status == MigrationStatus::Applying {
                            let mut resolved = false;
                            for _ in 0..5 {
                                sleep(Duration::from_millis(50)).await;
                                let double_check = self
                                    .store
                                    .get_migration(&plan.module_id, &item.definition.id)
                                    .await?;

                                if let Some(r2) = double_check {
                                    if r2.status == MigrationStatus::Applied
                                        && r2.checksum == item.definition.checksum
                                    {
                                        if let (Some(mgr), Some(l)) =
                                            (&self.lease_manager, &acquired_lease)
                                        {
                                            let _ = mgr.release(l).await;
                                        }
                                        self.emit(
                                            &plan.module_id,
                                            MigrationEvent::Skipped {
                                                migration_id: item.definition.id.clone(),
                                                reason:
                                                    "Applied by previous node during revalidation"
                                                        .to_string(),
                                            },
                                        )
                                        .await;
                                        skipped.push(item.definition.id.clone());
                                        resolved = true;
                                        break;
                                    }
                                }
                            }

                            if resolved {
                                continue;
                            }

                            if self.recovery_policy
                                == MigrationRecoveryPolicy::RequireManualIntervention
                            {
                                if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease)
                                {
                                    let _ = mgr.release(l).await;
                                }
                                return Err(RuntimeError::MigrationRecoveryRequired {
                                    module: plan.module_id.clone(),
                                    migration: item.definition.id.to_string(),
                                    reason: "Previous run left migration in 'Applying' state. Conservative recovery requires manual check.".to_string(),
                                });
                            }
                        }
                    }

                    // c. Chargement de la ressource
                    let res_path = item.definition.resource_path.as_deref().unwrap_or("");
                    let resource = match provider.read_resource(res_path).await {
                        Ok(r) => r,
                        Err(err) => {
                            if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease) {
                                let _ = mgr.release(l).await;
                            }
                            return Err(err);
                        }
                    };

                    // d. Enregistrement de l'état 'Applying'
                    self.emit(
                        &plan.module_id,
                        MigrationEvent::Applying {
                            migration_id: item.definition.id.clone(),
                        },
                    )
                    .await;

                    let applying_record = MigrationRecord {
                        migration_id: item.definition.id.clone(),
                        module_id: plan.module_id.clone(),
                        module_version: plan.module_version.clone(),
                        checksum: item.definition.checksum.clone(),
                        applied_at: 0,
                        duration_ms: 0,
                        status: MigrationStatus::Applying,
                        error: None,
                    };
                    if let Err(err) = self.store.record_migration(&applying_record).await {
                        if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease) {
                            let _ = mgr.release(l).await;
                        }
                        return Err(err);
                    }

                    // e. Exécution chronométrée SurrealQL
                    let step_start = Instant::now();
                    let mut attempts = 0;
                    let execution_result = loop {
                        attempts += 1;
                        let query_result = self.client.query(&resource.content).await;

                        match query_result {
                            Ok(res) => match res.check() {
                                Ok(_) => break Ok(()),
                                Err(err) => {
                                    let err_str = err.to_string();
                                    if attempts < 5
                                        && (err_str.contains("conflict")
                                            || err_str.contains("retried")
                                            || err_str.contains("retry"))
                                    {
                                        sleep(Duration::from_millis(25 * attempts)).await;
                                        continue;
                                    }
                                    break Err(RuntimeError::MigrationExecutionFailed {
                                        module: plan.module_id.clone(),
                                        migration: item.definition.id.to_string(),
                                        message: format!(
                                            "SurrealDB execution check failed: {}",
                                            err
                                        ),
                                    });
                                }
                            },
                            Err(err) => {
                                let err_str = err.to_string();
                                if attempts < 5
                                    && (err_str.contains("conflict")
                                        || err_str.contains("retried")
                                        || err_str.contains("retry"))
                                {
                                    sleep(Duration::from_millis(25 * attempts)).await;
                                    continue;
                                }
                                break Err(RuntimeError::MigrationExecutionFailed {
                                    module: plan.module_id.clone(),
                                    migration: item.definition.id.to_string(),
                                    message: format!("SurrealDB query dispatch failed: {}", err),
                                });
                            }
                        }
                    };

                    match execution_result {
                        Ok(()) => {
                            let duration_ms = step_start.elapsed().as_millis() as u64;
                            let applied_record = MigrationRecord {
                                migration_id: item.definition.id.clone(),
                                module_id: plan.module_id.clone(),
                                module_version: plan.module_version.clone(),
                                checksum: item.definition.checksum.clone(),
                                applied_at: chrono_timestamp_now(),
                                duration_ms,
                                status: MigrationStatus::Applied,
                                error: None,
                            };
                            self.store.record_migration(&applied_record).await?;
                            self.emit(
                                &plan.module_id,
                                MigrationEvent::Applied {
                                    migration_id: item.definition.id.clone(),
                                    duration_ms,
                                },
                            )
                            .await;
                            applied.push(item.definition.id.clone());

                            // Libération du verrou après succès
                            if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease) {
                                let _ = mgr.release(l).await;
                            }
                        }
                        Err(exec_err) => {
                            let duration_ms = step_start.elapsed().as_millis() as u64;
                            let failed_record = MigrationRecord {
                                migration_id: item.definition.id.clone(),
                                module_id: plan.module_id.clone(),
                                module_version: plan.module_version.clone(),
                                checksum: item.definition.checksum.clone(),
                                applied_at: 0,
                                duration_ms,
                                status: MigrationStatus::Failed,
                                error: Some(exec_err.to_string()),
                            };
                            self.store.record_migration(&failed_record).await?;
                            self.emit(
                                &plan.module_id,
                                MigrationEvent::Failed {
                                    migration_id: item.definition.id.clone(),
                                    error_code: "RUNTIME_MIGRATION_EXECUTION_FAILED".to_string(),
                                    message: exec_err.to_string(),
                                },
                            )
                            .await;

                            // Libération du verrou après échec
                            if let (Some(mgr), Some(l)) = (&self.lease_manager, &acquired_lease) {
                                let _ = mgr.release(l).await;
                            }

                            return Err(exec_err);
                        }
                    }
                }
                _ => {}
            }
        }

        let total_duration_ms = total_start.elapsed().as_millis() as u64;

        Ok(MigrationRunResult {
            module_id: plan.module_id.clone(),
            module_version: plan.module_version.clone(),
            applied,
            skipped,
            total_duration_ms,
        })
    }

    /// Découvre, planifie et applique les migrations d'un module en un seul appel.
    pub async fn run_module(
        &self,
        module_id: &ModuleId,
        module_version: &str,
        provider: &dyn ResourceProvider,
    ) -> Result<MigrationRunResult, RuntimeError> {
        let plan = self.plan(module_id, module_version, provider).await?;
        self.execute_plan(&plan, provider).await
    }
}

impl LyxalSurrealCall for MigrationRunner {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

/// Helper interne pour produire un horodatage unix en secondes.
fn chrono_timestamp_now() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}
