//! Tâches de fond déclarées par l'hôte et exécutées par `lyxal_scheduler` : purge de
//! `lyxal_auth` (`auth.purge`), nettoyage de `lyxal_storage` (`storage.cleanup`) et maintenance
//! de `lyxal_secrets` (`secrets.maintenance`).
//!
//! `lyxal_scheduler` dépend de `lyxal_auth` : aucun de ces trois modules ne peut dépendre du
//! planificateur. L'hôte, qui les héberge tous, fait donc le lien à leur place :
//!
//! 1. il inscrit le handler de chaque tâche dans le registre du planificateur, avant le
//!    démarrage ([`register_handlers`]) ; le handler appelle l'opération publique du module
//!    (`AuthPurge`, `StorageCleanup`, `SecretsMaintenance`) et rend son bilan ;
//! 2. après l'installation des modules, il déclare les tâches et leur permission propre
//!    (`seeds/server_tasks.surql`, session système) et crée la planification de chacune si elle
//!    est absente ([`install`]).
//!
//! Une seule exécution à la fois pour toute l'installation (planificateur élu, chevauchement
//! `skip`), avec journal, nouvelles tentatives et suivi dans `lyxal_scheduler`.

use crate::error::ServerError;
use crate::modules::scheduler::SchedulerHost;
use async_trait::async_trait;
use lyxal_auth::models::AuthPurgeResult;
use lyxal_auth::AuthPurge;
use lyxal_scheduler::models::{Overlap, ScheduleCreateParams, ScheduleSpec, SchedulerValue};
use lyxal_scheduler::{
    HandlerRegistry, RunContext, SchedulerStore, TaskFailure, TaskHandler, TaskOutput,
};
use lyxal_secrets::{MaintenanceReport, SecretsError, SecretsMaintenance};
use lyxal_storage::{CleanupReport, StorageCleanup, StorageError};
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::{Object, SurrealValue};
use surrealdb::Surreal;

/// Tâche de fond de l'hôte : sa tâche `lyxal_scheduler`, sa planification et son rythme.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct HostTask {
    /// Nom de la tâche (`<module>.<action>`), déclarée par `seeds/server_tasks.surql`.
    pub task: &'static str,
    /// Nom de la planification de l'installation (slug).
    pub schedule: &'static str,
    /// Intervalle entre deux exécutions.
    pub every: Duration,
}

/// Purge de `lyxal_auth`, toutes les 15 minutes.
pub const AUTH_PURGE: HostTask = HostTask {
    task: "auth.purge",
    schedule: "auth-purge",
    every: Duration::from_secs(900),
};

/// Nettoyage de `lyxal_storage`, toutes les 10 minutes.
pub const STORAGE_CLEANUP: HostTask = HostTask {
    task: "storage.cleanup",
    schedule: "storage-cleanup",
    every: Duration::from_secs(600),
};

/// Maintenance de `lyxal_secrets`, toutes les 10 minutes.
pub const SECRETS_MAINTENANCE: HostTask = HostTask {
    task: "secrets.maintenance",
    schedule: "secrets-maintenance",
    every: Duration::from_secs(600),
};

/// Les trois tâches de fond de l'hôte.
pub const HOST_TASKS: [HostTask; 3] = [AUTH_PURGE, STORAGE_CLEANUP, SECRETS_MAINTENANCE];

/// Décalage aléatoire maximal de chaque échéance.
const JITTER: Duration = Duration::from_secs(30);

/// Vrai si une nouvelle tentative peut réussir : refus métier selon sa master data ; panne
/// technique (base injoignable, conflit d'écriture, réponse illisible) toujours.
fn surreal_retryable(error: &LyxalSurrealError) -> bool {
    match error {
        LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
        _ => true,
    }
}

/// Bilan rendu comme résultat court de l'exécution : les compteurs, et `interrupted` si l'arrêt
/// a été demandé avant la fin (le reste est fait à l'exécution suivante).
fn output(counters: &[(&str, i64)], ctx: &RunContext) -> TaskOutput {
    let mut result = Object::new();
    for (name, value) in counters {
        result.insert(*name, (*value).into_value());
    }
    if ctx.cancellation.is_cancelled() {
        result.insert("interrupted", true.into_value());
    }
    TaskOutput::with_result(SchedulerValue::Object(result))
}

fn count(value: u64) -> i64 {
    i64::try_from(value).unwrap_or(i64::MAX)
}

/// Handler de la tâche `auth.purge` : une purge de `lyxal_auth`.
struct AuthPurgeHandler {
    purge: AuthPurge,
}

#[async_trait]
impl TaskHandler for AuthPurgeHandler {
    fn task(&self) -> &str {
        AUTH_PURGE.task
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        match self.purge.run(&ctx.cancellation).await {
            Ok(report) => {
                let AuthPurgeResult {
                    sessions_expired,
                    flows,
                    refresh_tokens,
                    sessions,
                    login_failures,
                    invitations_expired,
                    pending_totp,
                    invitation_claims,
                    code_issuances,
                    identities_purged,
                    organizations_purged,
                } = report;
                Ok(output(
                    &[
                        ("sessions_expired", sessions_expired),
                        ("flows", flows),
                        ("refresh_tokens", refresh_tokens),
                        ("sessions", sessions),
                        ("login_failures", login_failures),
                        ("invitations_expired", invitations_expired),
                        ("pending_totp", pending_totp),
                        ("invitation_claims", invitation_claims),
                        ("code_issuances", code_issuances),
                        ("identities_purged", identities_purged),
                        ("organizations_purged", organizations_purged),
                    ],
                    &ctx,
                ))
            }
            Err(error) => {
                let retryable = surreal_retryable(&error);
                let error = lyxal_auth::AuthError::from(error);
                Err(TaskFailure {
                    code: error.code(),
                    message: error.to_string(),
                    retryable,
                })
            }
        }
    }
}

/// Handler de la tâche `storage.cleanup` : un passage du nettoyage. Sans support configuré sur
/// ce nœud (`cleanup` absent), rien n'est écrit ni lu : l'exécution se termine sans rien faire.
struct StorageCleanupHandler {
    cleanup: Option<StorageCleanup>,
}

#[async_trait]
impl TaskHandler for StorageCleanupHandler {
    fn task(&self) -> &str {
        STORAGE_CLEANUP.task
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        let Some(cleanup) = &self.cleanup else {
            let mut result = Object::new();
            result.insert("skipped", SchedulerValue::String("no_backend".to_string()));
            return Ok(TaskOutput::with_result(SchedulerValue::Object(result)));
        };
        match cleanup.run(&ctx.cancellation).await {
            Ok(report) => {
                let CleanupReport {
                    expired,
                    assembled,
                    purged,
                    reclaimed,
                    failed,
                } = report;
                Ok(output(
                    &[
                        ("expired", count(expired)),
                        ("assembled", count(assembled)),
                        ("purged", count(purged)),
                        ("reclaimed", count(reclaimed)),
                        ("failed", count(failed)),
                    ],
                    &ctx,
                ))
            }
            Err(error) => Err(TaskFailure {
                code: error.code(),
                message: error.to_string(),
                retryable: match &error {
                    StorageError::Surreal(inner) => surreal_retryable(inner),
                    other => other.is_retryable(),
                },
            }),
        }
    }
}

/// Handler de la tâche `secrets.maintenance` : un passage de la maintenance du coffre-fort.
struct SecretsMaintenanceHandler {
    maintenance: SecretsMaintenance,
}

#[async_trait]
impl TaskHandler for SecretsMaintenanceHandler {
    fn task(&self) -> &str {
        SECRETS_MAINTENANCE.task
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        match self.maintenance.run(&ctx.cancellation).await {
            Ok(report) => {
                let MaintenanceReport {
                    purged,
                    resealed,
                    rewrapped,
                    destroyed_keys,
                    failed,
                    alerts,
                    rotations_succeeded,
                    rotations_failed,
                    tenant_keys_rotated,
                    requests_expired,
                    grants_removed,
                    shares_expired,
                    shares_removed,
                } = report;
                Ok(output(
                    &[
                        ("purged", count(purged)),
                        ("resealed", count(resealed)),
                        ("rewrapped", count(rewrapped)),
                        ("destroyed_keys", count(destroyed_keys)),
                        ("failed", count(failed)),
                        ("alerts", count(alerts)),
                        ("rotations_succeeded", count(rotations_succeeded)),
                        ("rotations_failed", count(rotations_failed)),
                        ("tenant_keys_rotated", count(tenant_keys_rotated)),
                        ("requests_expired", count(requests_expired)),
                        ("grants_removed", count(grants_removed)),
                        ("shares_expired", count(shares_expired)),
                        ("shares_removed", count(shares_removed)),
                    ],
                    &ctx,
                ))
            }
            Err(error) => Err(TaskFailure {
                code: error.code(),
                message: error.to_string(),
                retryable: match &error {
                    SecretsError::Surreal(inner) => surreal_retryable(inner),
                    other => other.is_retryable(),
                },
            }),
        }
    }
}

/// Inscrit les handlers des trois tâches dans le registre du planificateur, avant le démarrage
/// du runtime. `storage` : absent si aucun support n'est configuré.
pub fn register_handlers(
    registry: &mut HandlerRegistry,
    auth: AuthPurge,
    storage: Option<StorageCleanup>,
    secrets: SecretsMaintenance,
) -> Result<(), ServerError> {
    let handlers: [Arc<dyn TaskHandler>; 3] = [
        Arc::new(AuthPurgeHandler { purge: auth }),
        Arc::new(StorageCleanupHandler { cleanup: storage }),
        Arc::new(SecretsMaintenanceHandler {
            maintenance: secrets,
        }),
    ];
    for handler in handlers {
        let task = handler.task().to_string();
        registry
            .register(handler)
            .map_err(|error| install_error(&task, error.code()))?;
    }
    Ok(())
}

fn install_error(task: &str, detail: impl std::fmt::Display) -> ServerError {
    ServerError::ModuleInstall {
        module: super::SERVER_MODULE_ID.to_string(),
        message: format!("tâche de fond {task} : {detail}"),
    }
}

/// Après l'installation des modules : déclare les trois tâches et leur permission propre
/// (`seeds/server_tasks.surql`), puis crée la planification de chacune si elle est absente.
/// Rejouable : ni tâche ni planification en double. `client` : session système de l'hôte.
pub async fn install(client: &Surreal<Any>, scheduler: &SchedulerHost) -> Result<(), ServerError> {
    super::install_host_seeds(client).await?;
    let scheduler = scheduler.client(SchedulerStore::new(client.clone()));
    for task in HOST_TASKS {
        let mut spec = ScheduleSpec::new("UTC");
        spec.every = vec![task.every.into()];
        spec.jitter = Some(JITTER.into());
        let mut params = ScheduleCreateParams::new(task.schedule, task.task, spec);
        params.overlap = Some(Overlap::Skip);
        match scheduler.schedule(params).await {
            Ok(_) => tracing::info!(
                task = task.task,
                schedule = task.schedule,
                "tâche de fond planifiée"
            ),
            Err(error) if error.is_code("SCHEDULER_SCHEDULE_EXISTS") => {}
            Err(error) => return Err(install_error(task.task, error.code())),
        }
    }
    Ok(())
}
