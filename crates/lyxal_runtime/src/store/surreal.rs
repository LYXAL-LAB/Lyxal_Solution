use crate::error::RuntimeError;
use crate::lock::MigrationLease;
use crate::migration::{MigrationChecksum, MigrationId, MigrationRecord, MigrationStatus};
use crate::store::dto::{
    ListParams, MigrationGetParams, MigrationListParams, MigrationRecordParams, MigrationRow,
    ModuleGetParams, ModuleRow, ModuleUpsertParams, ReleaseGetParams, ReleaseListParams,
    ReleaseRegisterParams, ReleaseRow, ReleaseStatusUpdateParams,
};
use crate::store::models::{StoredModule, StoredModuleRelease};
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, SurrealValue};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// `RuntimeStore` persistant dans SurrealDB : chaque opération appelle une fonction
/// `fn::runtime_*` par `call_fn`.
pub struct SurrealRuntimeStore {
    client: Surreal<Any>,
}

impl SurrealRuntimeStore {
    /// Crée une nouvelle instance de `SurrealRuntimeStore` à partir d'un client `Surreal<Any>`.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Retourne la référence au client SurrealDB.
    pub fn client(&self) -> &Surreal<Any> {
        &self.client
    }

    /// Appelle `fn::<function>` et convertit l'erreur de transport ou de contrat.
    async fn call<T, P>(&self, function: &'static str, params: P) -> Result<T, RuntimeError>
    where
        T: SurrealValue + Send,
        P: SurrealValue + Send + 'static,
    {
        self.call_fn(function, params)
            .await
            .map_err(|e| store_error(function, e))
    }
}

/// Erreur d'appel d'une fonction de persistance du runtime.
pub(crate) fn store_error(function: &'static str, err: LyxalSurrealError) -> RuntimeError {
    RuntimeError::StoreFailed {
        operation: function,
        message: err.to_string(),
    }
}

/// Code levé par `THROW` quand une écriture sous bail est refusée ; `call_fn` le renvoie en
/// erreur métier.
const LEASE_FENCED_CODE: &str = "RUNTIME_LEASE_FENCED";

fn is_lease_fenced(err: &LyxalSurrealError) -> bool {
    err.is_business_code(LEASE_FENCED_CODE)
}

impl LyxalSurrealCall for SurrealRuntimeStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

fn module_from_row(row: ModuleRow) -> StoredModule {
    StoredModule {
        module_id: ModuleId::new(row.module_id),
        name: row.name,
        description: row.description,
        created_at: row.created_at.map(|d| d.to_string()),
        updated_at: row.updated_at.map(|d| d.to_string()),
    }
}

fn release_from_row(row: ReleaseRow) -> Result<StoredModuleRelease, RuntimeError> {
    Ok(StoredModuleRelease {
        module_id: ModuleId::new(row.module_id),
        version: row.version,
        manifest_version: u32::try_from(row.manifest_version).map_err(|_| {
            RuntimeError::StoreFailed {
                operation: "runtime_release",
                message: format!("manifest_version hors bornes : {}", row.manifest_version),
            }
        })?,
        description: row.description,
        status: row.status,
        checksum: row.checksum,
        installation_phase: row.installation_phase,
        created_at: row.created_at.map(|d| d.to_string()),
        installed_at: row.installed_at.map(|d| d.to_string()),
    })
}

fn to_u64(field: &'static str, value: i64) -> Result<u64, RuntimeError> {
    u64::try_from(value).map_err(|_| RuntimeError::StoreFailed {
        operation: "runtime_migration",
        message: format!("{field} négatif : {value}"),
    })
}

fn to_i64(field: &'static str, value: u64) -> Result<i64, RuntimeError> {
    i64::try_from(value).map_err(|_| RuntimeError::StoreFailed {
        operation: "runtime_migration",
        message: format!("{field} hors bornes : {value}"),
    })
}

fn migration_status(value: &str) -> Result<MigrationStatus, RuntimeError> {
    Ok(match value {
        "Pending" => MigrationStatus::Pending,
        "Applying" => MigrationStatus::Applying,
        "Applied" => MigrationStatus::Applied,
        "Failed" => MigrationStatus::Failed,
        "RolledBack" => MigrationStatus::RolledBack,
        "Skipped" => MigrationStatus::Skipped,
        other => {
            return Err(RuntimeError::StoreFailed {
                operation: "runtime_migration",
                message: format!("statut de migration inconnu : {other}"),
            })
        }
    })
}

fn migration_from_row(row: MigrationRow) -> Result<MigrationRecord, RuntimeError> {
    Ok(MigrationRecord {
        migration_id: MigrationId::new(row.migration_id)?,
        module_id: ModuleId::new(row.module_id),
        module_version: row.module_version,
        checksum: MigrationChecksum::from_hex(row.checksum)?,
        applied_at: to_u64("applied_at", row.applied_at)?,
        duration_ms: to_u64("duration_ms", row.duration_ms)?,
        status: migration_status(&row.status)?,
        error: row.error,
    })
}

#[async_trait]
impl RuntimeStore for SurrealRuntimeStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        crate::schema::install_runtime_schema(&self.client).await
    }

    async fn upsert_module(&self, module: &StoredModule) -> Result<(), RuntimeError> {
        let _: ModuleRow = self
            .call(
                "runtime_module_upsert",
                ModuleUpsertParams {
                    module_id: module.module_id.to_string(),
                    name: module.name.clone(),
                    description: module.description.clone(),
                },
            )
            .await?;
        Ok(())
    }

    async fn get_module(&self, id: &ModuleId) -> Result<Option<StoredModule>, RuntimeError> {
        let row: Option<ModuleRow> = self
            .call(
                "runtime_module_get",
                ModuleGetParams {
                    module_id: id.to_string(),
                },
            )
            .await?;
        Ok(row.map(module_from_row))
    }

    async fn list_modules(&self) -> Result<Vec<StoredModule>, RuntimeError> {
        let rows: Vec<ModuleRow> = self
            .call("runtime_module_list", ListParams::default())
            .await?;
        Ok(rows.into_iter().map(module_from_row).collect())
    }

    async fn register_release(&self, release: &StoredModuleRelease) -> Result<(), RuntimeError> {
        let _: ReleaseRow = self
            .call(
                "runtime_release_register",
                ReleaseRegisterParams {
                    module_id: release.module_id.to_string(),
                    version: release.version.clone(),
                    manifest_version: i64::from(release.manifest_version),
                    status: release.status.clone(),
                    description: release.description.clone(),
                    checksum: release.checksum.clone(),
                    installation_phase: release.installation_phase.clone(),
                },
            )
            .await?;
        Ok(())
    }

    async fn get_release(
        &self,
        module_id: &ModuleId,
        version: &str,
    ) -> Result<Option<StoredModuleRelease>, RuntimeError> {
        let row: Option<ReleaseRow> = self
            .call(
                "runtime_release_get",
                ReleaseGetParams {
                    module_id: module_id.to_string(),
                    version: version.to_string(),
                },
            )
            .await?;
        row.map(release_from_row).transpose()
    }

    async fn list_releases(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<StoredModuleRelease>, RuntimeError> {
        let rows: Vec<ReleaseRow> = self
            .call(
                "runtime_release_list",
                ReleaseListParams {
                    module_id: module_id.to_string(),
                },
            )
            .await?;
        rows.into_iter().map(release_from_row).collect()
    }

    async fn update_release_status(
        &self,
        module_id: &ModuleId,
        version: &str,
        status: &str,
        phase: Option<&str>,
    ) -> Result<(), RuntimeError> {
        let _: ReleaseRow = self
            .call(
                "runtime_release_status_update",
                ReleaseStatusUpdateParams {
                    module_id: module_id.to_string(),
                    version: version.to_string(),
                    status: status.to_string(),
                    phase: phase.map(str::to_string),
                },
            )
            .await?;
        Ok(())
    }

    async fn record_migration(
        &self,
        migration: &MigrationRecord,
        lease: Option<&MigrationLease>,
    ) -> Result<(), RuntimeError> {
        let result: Result<MigrationRow, LyxalSurrealError> = self
            .call_fn(
                "runtime_migration_record",
                MigrationRecordParams {
                    module_id: migration.module_id.to_string(),
                    migration_id: migration.migration_id.to_string(),
                    module_version: migration.module_version.clone(),
                    checksum: migration.checksum.to_string(),
                    status: migration.status.to_string(),
                    applied_at: to_i64("applied_at", migration.applied_at)?,
                    duration_ms: to_i64("duration_ms", migration.duration_ms)?,
                    error: migration.error.clone(),
                    lease_key: lease.map(|l| l.key.canonical_string()),
                    node_id: lease.map(|l| l.owner.to_string()),
                    generation: lease
                        .map(|l| to_i64("generation", l.generation))
                        .transpose()?,
                },
            )
            .await;
        match (result, lease) {
            (Ok(_), _) => Ok(()),
            (Err(err), Some(lease)) if is_lease_fenced(&err) => Err(RuntimeError::LeaseFenced {
                key: lease.key.canonical_string(),
                owner: lease.owner.to_string(),
                generation: lease.generation,
            }),
            (Err(err), _) => Err(store_error("runtime_migration_record", err)),
        }
    }

    async fn get_migration(
        &self,
        module_id: &ModuleId,
        migration_id: &MigrationId,
    ) -> Result<Option<MigrationRecord>, RuntimeError> {
        let row: Option<MigrationRow> = self
            .call(
                "runtime_migration_get",
                MigrationGetParams {
                    module_id: module_id.to_string(),
                    migration_id: migration_id.to_string(),
                },
            )
            .await?;
        row.map(migration_from_row).transpose()
    }

    async fn list_migrations(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<MigrationRecord>, RuntimeError> {
        let rows: Vec<MigrationRow> = self
            .call(
                "runtime_migration_list",
                MigrationListParams {
                    module_id: module_id.to_string(),
                },
            )
            .await?;
        rows.into_iter().map(migration_from_row).collect()
    }
}
