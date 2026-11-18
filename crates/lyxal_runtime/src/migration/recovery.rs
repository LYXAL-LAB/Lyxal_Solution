//! Reprise guidée d'une migration interrompue : liste des migrations restées « en cours » après
//! une coupure, et décision de l'exploitant (`retry` ou `abandon`) prise sous le bail
//! d'installation de la release du module, puis tracée au journal du runtime.

use crate::error::RuntimeError;
use crate::event::bus::RuntimeEventBus;
use crate::event::event::RuntimeEventDraft;
use crate::event::journal::RuntimeEventJournal;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::{MigrationEvent, RuntimeEventPayload};
use crate::event::store::SurrealRuntimeEventJournal;
use crate::lock::installation::{
    AcquireInstallationLeaseResult, InstallationLease, InstallationLeaseManager,
    InstallationLockKey, SurrealInstallationLeaseManager,
};
use crate::lock::node_id::NodeId;
use crate::migration::id::MigrationId;
use crate::store::dto::{MigrationGetParams, MigrationResolveCallParams, MigrationRow};
use crate::types::ModuleId;
use lyxal_surreal::{Datetime, LyxalCallError, LyxalSurrealCall, LyxalSurrealError, SurrealValue};
use std::fmt;
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Durée du bail d'installation pris le temps d'une décision.
const RESOLVE_LEASE_DURATION: Duration = Duration::from_secs(30);

const NOT_INTERRUPTED_CODE: &str = "RUNTIME_MIGRATION_NOT_INTERRUPTED";
const LEASE_FENCED_CODE: &str = "RUNTIME_LEASE_FENCED";
const INVALID_PARAMETERS_CODE: &str = "RUNTIME_INVALID_PARAMETERS";

/// `fn::runtime_migration_interrupted_list` : toutes les migrations interrompues, ou celles
/// d'un seul module.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct MigrationInterruptedParams {
    pub module: Option<String>,
}

/// Dernière décision de l'exploitant sur une migration interrompue.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationResolution {
    /// `retry` ou `abandon`.
    pub action: String,
    /// Identifiant de l'auteur de la décision.
    pub actor: String,
    /// Motif donné par l'auteur.
    pub reason: String,
    /// Nœud qui a pris la décision.
    pub node_id: String,
    /// Date de la décision (heure de la base).
    pub at: Datetime,
}

/// Migration interrompue, telle que rendue par `fn::runtime_migration_interrupted_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct InterruptedMigration {
    /// Module propriétaire.
    pub module: String,
    /// Identifiant de la migration (ex. `0001_initial`).
    pub migration: String,
    /// Version du module en cours d'installation.
    pub version: String,
    /// Script de la migration (chemin déclaré au manifeste), s'il est connu.
    #[surreal(default)]
    pub script: Option<String>,
    /// Nœud qui exécutait la migration, s'il est connu.
    #[surreal(default)]
    pub node: Option<String>,
    /// `interrupted` (restée en cours) ou `abandoned` (abandonnée, non rejouée).
    pub state: String,
    /// Début de l'exécution interrompue (heure de la base).
    #[surreal(default)]
    pub started_at: Option<Datetime>,
    /// Dernière décision de l'exploitant, s'il y en a eu une.
    #[surreal(default)]
    pub resolution: Option<MigrationResolution>,
}

/// Décision de l'exploitant sur une migration interrompue.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MigrationResolveAction {
    /// La migration sera rejouée à la prochaine installation du module.
    Retry,
    /// La migration est abandonnée : l'installation du module reste refusée tant qu'une
    /// décision `Retry` ne l'a pas remise à rejouer.
    Abandon,
}

impl MigrationResolveAction {
    /// Valeur attendue par `fn::runtime_migration_resolve`.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Retry => "retry",
            Self::Abandon => "abandon",
        }
    }

    /// Lit `retry` ou `abandon` ; toute autre valeur est refusée.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "retry" => Some(Self::Retry),
            "abandon" => Some(Self::Abandon),
            _ => None,
        }
    }
}

impl fmt::Display for MigrationResolveAction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Décision demandée au runtime (`LyxalRuntime::resolve_migration`).
#[derive(Debug, Clone)]
pub struct MigrationResolveParams {
    /// Module propriétaire.
    pub module: String,
    /// Identifiant de la migration.
    pub migration: String,
    /// Décision.
    pub action: MigrationResolveAction,
    /// Motif (obligatoire, 1 000 caractères au plus), gardé avec la décision et au journal :
    /// ni secret ni donnée personnelle.
    pub reason: String,
    /// Identifiant de l'auteur de la décision (256 caractères au plus).
    pub actor: String,
}

/// Résultat de `fn::runtime_migration_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationResolved {
    pub module: String,
    pub migration: String,
    pub version: String,
    /// `retry` ou `abandon`.
    pub action: String,
    /// Nouvel état : `RetryRequested` ou `Abandoned`.
    pub status: String,
    /// État avant la décision : `Applying` ou `Abandoned`.
    pub previous_status: String,
    /// Date de la décision (heure de la base).
    pub resolved_at: Datetime,
}

/// Opérations de reprise sur la base du runtime (session système).
pub struct MigrationRecovery {
    client: Surreal<Any>,
    leases: SurrealInstallationLeaseManager,
    journal: SurrealRuntimeEventJournal,
    node_id: NodeId,
    event_bus: Arc<dyn RuntimeEventBus>,
}

impl LyxalSurrealCall for MigrationRecovery {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

impl MigrationRecovery {
    /// Crée les opérations de reprise du nœud `node_id` sur `client`.
    pub fn new(client: Surreal<Any>, node_id: NodeId, event_bus: Arc<dyn RuntimeEventBus>) -> Self {
        Self {
            leases: SurrealInstallationLeaseManager::new(client.clone()),
            journal: SurrealRuntimeEventJournal::new(client.clone()),
            client,
            node_id,
            event_bus,
        }
    }

    /// Migrations interrompues (restées « en cours » sans bail de migration détenu) ou
    /// abandonnées et non rejouées.
    pub async fn interrupted(
        &self,
        params: MigrationInterruptedParams,
    ) -> Result<Vec<InterruptedMigration>, RuntimeError> {
        self.call_fn("runtime_migration_interrupted_list", params)
            .await
            .map_err(|e| call_error("runtime_migration_interrupted_list", e, None))
    }

    /// Applique la décision de l'exploitant : prend le bail d'installation de la release du
    /// module, appelle `fn::runtime_migration_resolve` sous ce bail, le libère, puis écrit la
    /// trace (qui, quand, pourquoi) au journal du runtime.
    ///
    /// Refus : `MigrationNotInterrupted` (migration inconnue, en cours ou dans un autre état),
    /// `LeaseFenced` (bail d'installation détenu par un autre nœud, par une installation en
    /// cours sur ce nœud, ou perdu), `InvalidParameters`.
    pub async fn resolve(
        &self,
        params: MigrationResolveParams,
    ) -> Result<MigrationResolved, RuntimeError> {
        // La release (donc la clé du bail d'installation) est celle de la migration enregistrée
        let row: Option<MigrationRow> = self
            .call_fn(
                "runtime_migration_get",
                MigrationGetParams {
                    module_id: params.module.clone(),
                    migration_id: params.migration.clone(),
                },
            )
            .await
            .map_err(|e| call_error("runtime_migration_get", e, None))?;
        let Some(row) = row else {
            return Err(RuntimeError::MigrationNotInterrupted {
                module: params.module,
                migration: params.migration,
                status: "unknown".to_string(),
            });
        };
        let migration_id = MigrationId::new(row.migration_id.clone())?;

        let key = InstallationLockKey::new(ModuleId::new(row.module_id), row.module_version);
        let lease = self.acquire(&key).await?;
        let generation =
            i64::try_from(lease.generation).map_err(|_| RuntimeError::StoreFailed {
                operation: "runtime_migration_resolve",
                message: format!("génération hors bornes : {}", lease.generation),
            })?;

        let result: Result<MigrationResolved, LyxalSurrealError> = self
            .call_fn(
                "runtime_migration_resolve",
                MigrationResolveCallParams {
                    module: params.module,
                    migration: params.migration,
                    action: params.action.as_str().to_string(),
                    reason: params.reason.clone(),
                    actor: params.actor.clone(),
                    node_id: self.node_id.to_string(),
                    generation,
                },
            )
            .await;
        if let Err(e) = self.leases.release(&lease).await {
            tracing::warn!(error = %e, "Libération du bail impossible : il expirera à son échéance");
        }
        let resolved =
            result.map_err(|e| call_error("runtime_migration_resolve", e, Some(&lease)))?;

        // Trace : diffusée aux abonnés du nœud et écrite au journal avant de rendre la main
        // (réécrire le même événement ne crée pas de doublon si le bus journalise aussi)
        let draft = RuntimeEventDraft::new(
            RuntimeEventKind::Migration,
            RuntimeEventPayload::Migration(MigrationEvent::Resolved {
                migration_id,
                version: resolved.version.clone(),
                action: resolved.action.clone(),
                actor: params.actor.trim().to_string(),
                reason: params.reason.trim().to_string(),
                previous_status: resolved.previous_status.clone(),
            }),
        )
        .with_module_id(ModuleId::new(resolved.module.clone()));
        let event = self.event_bus.publish(draft).await?;
        self.journal.append(&event).await?;
        Ok(resolved)
    }

    /// Prend le bail d'installation, sans attendre : détenu par un autre nœud vivant, ou par
    /// une installation en cours sur ce nœud, la décision est refusée (`LeaseFenced`).
    async fn acquire(&self, key: &InstallationLockKey) -> Result<InstallationLease, RuntimeError> {
        match self
            .leases
            .acquire(key, &self.node_id, RESOLVE_LEASE_DURATION)
            .await?
        {
            AcquireInstallationLeaseResult::Acquired(lease)
            | AcquireInstallationLeaseResult::RecoveredExpiredLease(lease) => Ok(lease),
            AcquireInstallationLeaseResult::AlreadyOwned(lease) => Err(RuntimeError::LeaseFenced {
                key: key.canonical_string(),
                owner: lease.owner.to_string(),
                generation: lease.generation,
            }),
            AcquireInstallationLeaseResult::HeldByOther { owner, .. } => {
                Err(RuntimeError::LeaseFenced {
                    key: key.canonical_string(),
                    owner: owner.to_string(),
                    generation: 0,
                })
            }
        }
    }
}

/// Erreur d'une fonction de reprise : refus métier typé, sinon échec de persistance.
fn call_error(
    function: &'static str,
    err: LyxalSurrealError,
    lease: Option<&InstallationLease>,
) -> RuntimeError {
    if let LyxalSurrealError::Call(LyxalCallError::Business(business)) = &err {
        let text = |field: &str| {
            business.details[field]
                .as_str()
                .unwrap_or_default()
                .to_string()
        };
        match business.code.as_str() {
            NOT_INTERRUPTED_CODE => {
                return RuntimeError::MigrationNotInterrupted {
                    module: text("module"),
                    migration: text("migration"),
                    status: text("status"),
                }
            }
            LEASE_FENCED_CODE => {
                return RuntimeError::LeaseFenced {
                    key: text("lock_key"),
                    owner: lease.map(|l| l.owner.to_string()).unwrap_or_default(),
                    generation: lease.map(|l| l.generation).unwrap_or_default(),
                }
            }
            INVALID_PARAMETERS_CODE => {
                return RuntimeError::InvalidParameters {
                    function,
                    fields: business.details["fields"].clone(),
                }
            }
            _ => {}
        }
    }
    RuntimeError::StoreFailed {
        operation: function,
        message: err.to_string(),
    }
}
