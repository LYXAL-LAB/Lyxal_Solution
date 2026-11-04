use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{MigrationEvent, RuntimeEventPayload};
use crate::lock::config::MigrationLockConfig;
use crate::lock::key::MigrationLockKey;
use crate::lock::lease::{AcquireLeaseResult, MigrationLease};
use crate::lock::manager::MigrationLeaseManager;
use crate::lock::node_id::NodeId;
use crate::lock::recovery::MigrationRecoveryPolicy;
use crate::lock::surreal::SurrealMigrationLeaseManager;
use crate::manifest::ModuleManifest;
use crate::migration::definition::MigrationRecord;
use crate::migration::discovery::MigrationDiscovery;
use crate::migration::id::MigrationId;
use crate::migration::plan::{MigrationPlan, MigrationPlanAction, MigrationPlanItem};
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
            if let Err(e) = bus.publish(draft).await {
                tracing::warn!(error = %e, "Publication d'un événement interne du runtime impossible");
            }
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
        manifest: &ModuleManifest,
        provider: &dyn ResourceProvider,
    ) -> Result<MigrationPlan, RuntimeError> {
        let definitions = MigrationDiscovery::discover_migrations(manifest, provider).await?;
        let module_version = manifest.version.to_string();

        MigrationPlan::from_definitions_and_store(
            &manifest.id,
            &module_version,
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
                                self.release_lease(acquired_lease.as_ref()).await;
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
                                self.release_lease(acquired_lease.as_ref()).await;
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
                                        self.release_lease(acquired_lease.as_ref()).await;
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
                                self.release_lease(acquired_lease.as_ref()).await;
                                return Err(RuntimeError::MigrationRecoveryRequired {
                                    module: plan.module_id.clone(),
                                    migration: item.definition.id.to_string(),
                                    reason: "Previous run left migration in 'Applying' state. Conservative recovery requires manual check.".to_string(),
                                });
                            }
                        }
                    }

                    // c. Chargement de la ressource
                    let mut lease = acquired_lease;
                    let content = match provider.read(res_path(item)).await {
                        Ok(r) => r,
                        Err(err) => {
                            self.release_lease(lease.as_ref()).await;
                            return Err(err);
                        }
                    };

                    // d. Enregistrement de l'état 'Applying', sous garde du bail
                    self.emit(
                        &plan.module_id,
                        MigrationEvent::Applying {
                            migration_id: item.definition.id.clone(),
                        },
                    )
                    .await;

                    let record = |status, applied_at, duration_ms, error| MigrationRecord {
                        migration_id: item.definition.id.clone(),
                        module_id: plan.module_id.clone(),
                        module_version: plan.module_version.clone(),
                        checksum: item.definition.checksum.clone(),
                        applied_at,
                        duration_ms,
                        status,
                        error,
                    };
                    if let Err(err) = self
                        .store
                        .record_migration(
                            &record(MigrationStatus::Applying, 0, 0, None),
                            lease.as_ref(),
                        )
                        .await
                    {
                        self.release_lease(lease.as_ref()).await;
                        return Err(err);
                    }

                    // e. Exécution chronométrée, bail renouvelé tant qu'elle dure
                    let step_start = Instant::now();
                    let execution_result = self
                        .execute_with_heartbeat(plan, item, &content, lease.as_mut())
                        .await;
                    let duration_ms = elapsed_ms(step_start);

                    // f. Enregistrement du résultat, sous garde du bail : un nœud qui a perdu
                    //    son bail n'écrit jamais le résultat (RuntimeError::LeaseFenced).
                    match execution_result {
                        Ok(()) => {
                            let recorded = self
                                .store
                                .record_migration(
                                    &record(
                                        MigrationStatus::Applied,
                                        unix_now_secs(),
                                        duration_ms,
                                        None,
                                    ),
                                    lease.as_ref(),
                                )
                                .await;
                            self.release_lease(lease.as_ref()).await;
                            recorded?;
                            self.emit(
                                &plan.module_id,
                                MigrationEvent::Applied {
                                    migration_id: item.definition.id.clone(),
                                    duration_ms,
                                },
                            )
                            .await;
                            applied.push(item.definition.id.clone());
                        }
                        Err(exec_err) => {
                            let recorded = self
                                .store
                                .record_migration(
                                    &record(
                                        MigrationStatus::Failed,
                                        0,
                                        duration_ms,
                                        Some(exec_err.to_string()),
                                    ),
                                    lease.as_ref(),
                                )
                                .await;
                            self.release_lease(lease.as_ref()).await;
                            if let Err(record_err) = recorded {
                                tracing::error!(
                                    error = %record_err,
                                    migration = %item.definition.id,
                                    "Échec de migration non enregistré"
                                );
                            }
                            self.emit(
                                &plan.module_id,
                                MigrationEvent::Failed {
                                    migration_id: item.definition.id.clone(),
                                    error_code: exec_err.code().to_string(),
                                    message: exec_err.to_string(),
                                },
                            )
                            .await;
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
        manifest: &ModuleManifest,
        provider: &dyn ResourceProvider,
    ) -> Result<MigrationRunResult, RuntimeError> {
        let plan = self.plan(manifest, provider).await?;
        self.execute_plan(&plan, provider).await
    }
}

impl MigrationRunner {
    /// Libère le bail s'il y en a un ; un échec est journalisé, le bail expirant à son échéance.
    async fn release_lease(&self, lease: Option<&MigrationLease>) {
        if let (Some(mgr), Some(lease)) = (&self.lease_manager, lease) {
            if let Err(e) = mgr.release(lease).await {
                tracing::warn!(error = %e, "Libération du bail impossible : il expirera à son échéance");
            }
        }
    }

    /// Exécute le SurrealQL de la migration en renouvelant le bail tous les `renew_interval`.
    /// Un renouvellement refusé n'interrompt pas la requête en cours : il est journalisé, et
    /// l'enregistrement du résultat sera refusé par la garde de bail.
    async fn execute_with_heartbeat(
        &self,
        plan: &MigrationPlan,
        item: &MigrationPlanItem,
        content: &str,
        lease: Option<&mut MigrationLease>,
    ) -> Result<(), RuntimeError> {
        let execution = self.execute_content(plan, item, content);
        let (Some(mgr), Some(lease)) = (&self.lease_manager, lease) else {
            return execution.await;
        };
        tokio::pin!(execution);
        let mut ticker = tokio::time::interval(self.lock_config.renew_interval);
        ticker.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
        ticker.tick().await;
        let mut renewing = true;
        loop {
            tokio::select! {
                result = &mut execution => return result,
                _ = ticker.tick(), if renewing => {
                    match mgr.renew(lease, self.lock_config.lease_duration).await {
                        Ok(renewed) => *lease = renewed,
                        Err(e) => {
                            tracing::error!(
                                error = %e,
                                migration = %item.definition.id,
                                "Bail de migration perdu pendant l'exécution"
                            );
                            renewing = false;
                        }
                    }
                }
            }
        }
    }

    /// Exécute le SurrealQL de la migration, avec quelques reprises sur conflit transactionnel.
    async fn execute_content(
        &self,
        plan: &MigrationPlan,
        item: &MigrationPlanItem,
        content: &str,
    ) -> Result<(), RuntimeError> {
        let failure = |message: String| RuntimeError::MigrationExecutionFailed {
            module: plan.module_id.clone(),
            migration: item.definition.id.to_string(),
            message,
        };
        let mut attempts: u64 = 0;
        loop {
            attempts += 1;
            let message = match self.client.query(content).await {
                Ok(res) => match res.check() {
                    Ok(_) => return Ok(()),
                    Err(err) => format!("SurrealDB execution check failed: {err}"),
                },
                Err(err) => format!("SurrealDB query dispatch failed: {err}"),
            };
            let retryable = message.contains("conflict") || message.contains("retry");
            if attempts >= 5 || !retryable {
                return Err(failure(message));
            }
            sleep(Duration::from_millis(25 * attempts)).await;
        }
    }
}

fn res_path(item: &MigrationPlanItem) -> &str {
    item.definition.resource_path.as_deref().unwrap_or("")
}

fn elapsed_ms(start: Instant) -> u64 {
    u64::try_from(start.elapsed().as_millis()).unwrap_or(u64::MAX)
}

impl LyxalSurrealCall for MigrationRunner {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

/// Horodatage Unix en secondes du nœud (`applied_at`).
fn unix_now_secs() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}
