use crate::error::RuntimeError;
use crate::migration::{MigrationChecksum, MigrationId, MigrationRecord, MigrationStatus};
use crate::store::models::{StoredModule, StoredModuleRelease};
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Implémentation officielle du `RuntimeStore` persistant dans SurrealDB via `lyxal_surreal`.
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
}

impl LyxalSurrealCall for SurrealRuntimeStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

// Structures de persistance internes pour la désérialisation SurrealDB
#[derive(Debug, Serialize, Deserialize)]
struct SystemModuleRow {
    module_id: String,
    name: String,
    #[serde(default)]
    description: Option<String>,
    #[serde(default)]
    created_at: Option<surrealdb::Datetime>,
    #[serde(default)]
    updated_at: Option<surrealdb::Datetime>,
}

#[derive(Debug, Serialize, Deserialize)]
struct SystemReleaseRow {
    module_id: String,
    version: String,
    manifest_version: i64,
    #[serde(default)]
    description: Option<String>,
    status: String,
    #[serde(default)]
    checksum: Option<String>,
    #[serde(default)]
    installation_phase: Option<String>,
    #[serde(default)]
    created_at: Option<surrealdb::Datetime>,
    #[serde(default)]
    installed_at: Option<surrealdb::Datetime>,
}

#[derive(Debug, Serialize, Deserialize)]
struct SystemMigrationRow {
    migration_id: String,
    module_id: String,
    module_version: String,
    #[serde(default)]
    order: Option<i64>,
    checksum: String,
    status: String,
    #[serde(default)]
    applied_at: Option<i64>,
    #[serde(default)]
    duration_ms: Option<i64>,
    #[serde(default)]
    error: Option<String>,
}

#[async_trait]
impl RuntimeStore for SurrealRuntimeStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        let bootstrap_sql = r#"
            -- Tables système
            DEFINE TABLE OVERWRITE system_module SCHEMAFULL
                COMMENT "Table système enregistrant l'identité canonique des modules connus du Runtime";

            DEFINE TABLE OVERWRITE system_module_release SCHEMAFULL
                COMMENT "Table système enregistrant l'historique des releases de modules";

            DEFINE TABLE OVERWRITE system_migration SCHEMAFULL
                COMMENT "Table système enregistrant l'historique des migrations de schéma appliquées";

            DEFINE TABLE OVERWRITE system_migration_lock SCHEMAFULL
                COMMENT "Table système enregistrant les baux distribués temporaires de migration";

            DEFINE TABLE OVERWRITE system_installation_lock SCHEMAFULL
                COMMENT "Table système enregistrant les baux distribués temporaires d'installation de release";

            -- Champs system_module
            DEFINE FIELD OVERWRITE module_id ON TABLE system_module TYPE string;
            DEFINE FIELD OVERWRITE name ON TABLE system_module TYPE string;
            DEFINE FIELD OVERWRITE description ON TABLE system_module TYPE option<string>;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_module TYPE datetime DEFAULT time::now() READONLY;
            DEFINE FIELD OVERWRITE updated_at ON TABLE system_module TYPE datetime DEFAULT time::now();

            -- Champs system_module_release
            DEFINE FIELD OVERWRITE module_id ON TABLE system_module_release TYPE string;
            DEFINE FIELD OVERWRITE version ON TABLE system_module_release TYPE string;
            DEFINE FIELD OVERWRITE manifest_version ON TABLE system_module_release TYPE int;
            DEFINE FIELD OVERWRITE description ON TABLE system_module_release TYPE option<string>;
            DEFINE FIELD OVERWRITE status ON TABLE system_module_release TYPE string;
            DEFINE FIELD OVERWRITE checksum ON TABLE system_module_release TYPE option<string>;
            DEFINE FIELD OVERWRITE installation_phase ON TABLE system_module_release TYPE option<string>;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_module_release TYPE datetime DEFAULT time::now() READONLY;
            DEFINE FIELD OVERWRITE installed_at ON TABLE system_module_release TYPE option<datetime>;

            -- Champs system_migration
            DEFINE FIELD OVERWRITE migration_id ON TABLE system_migration TYPE string;
            DEFINE FIELD OVERWRITE module_id ON TABLE system_migration TYPE string;
            DEFINE FIELD OVERWRITE module_version ON TABLE system_migration TYPE string;
            DEFINE FIELD OVERWRITE order ON TABLE system_migration TYPE option<int>;
            DEFINE FIELD OVERWRITE checksum ON TABLE system_migration TYPE string;
            DEFINE FIELD OVERWRITE status ON TABLE system_migration TYPE string;
            DEFINE FIELD OVERWRITE reversible ON TABLE system_migration TYPE option<bool>;
            DEFINE FIELD OVERWRITE resource_path ON TABLE system_migration TYPE option<string>;
            DEFINE FIELD OVERWRITE applied_at ON TABLE system_migration TYPE option<int>;
            DEFINE FIELD OVERWRITE duration_ms ON TABLE system_migration TYPE option<int>;
            DEFINE FIELD OVERWRITE error ON TABLE system_migration TYPE option<string>;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_migration TYPE datetime DEFAULT time::now() READONLY;
            DEFINE FIELD OVERWRITE updated_at ON TABLE system_migration TYPE datetime DEFAULT time::now();

            -- Champs system_migration_lock
            DEFINE FIELD OVERWRITE lock_key ON TABLE system_migration_lock TYPE string;
            DEFINE FIELD OVERWRITE module_id ON TABLE system_migration_lock TYPE string;
            DEFINE FIELD OVERWRITE migration_id ON TABLE system_migration_lock TYPE string;
            DEFINE FIELD OVERWRITE owner_node_id ON TABLE system_migration_lock TYPE string;
            DEFINE FIELD OVERWRITE generation ON TABLE system_migration_lock TYPE int;
            DEFINE FIELD OVERWRITE is_released ON TABLE system_migration_lock TYPE option<bool>;
            DEFINE FIELD OVERWRITE acquired_at ON TABLE system_migration_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE renewed_at ON TABLE system_migration_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE expires_at ON TABLE system_migration_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE released_at ON TABLE system_migration_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_migration_lock TYPE datetime DEFAULT time::now() READONLY;
            DEFINE FIELD OVERWRITE updated_at ON TABLE system_migration_lock TYPE datetime DEFAULT time::now();

            -- Champs system_installation_lock
            DEFINE FIELD OVERWRITE lock_key ON TABLE system_installation_lock TYPE string;
            DEFINE FIELD OVERWRITE module_id ON TABLE system_installation_lock TYPE string;
            DEFINE FIELD OVERWRITE version ON TABLE system_installation_lock TYPE string;
            DEFINE FIELD OVERWRITE owner_node_id ON TABLE system_installation_lock TYPE string;
            DEFINE FIELD OVERWRITE generation ON TABLE system_installation_lock TYPE int;
            DEFINE FIELD OVERWRITE is_released ON TABLE system_installation_lock TYPE option<bool>;
            DEFINE FIELD OVERWRITE acquired_at ON TABLE system_installation_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE renewed_at ON TABLE system_installation_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE expires_at ON TABLE system_installation_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE released_at ON TABLE system_installation_lock TYPE option<int>;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_installation_lock TYPE datetime DEFAULT time::now() READONLY;
            DEFINE FIELD OVERWRITE updated_at ON TABLE system_installation_lock TYPE datetime DEFAULT time::now();

            -- Indexes
            DEFINE INDEX OVERWRITE idx_system_module_id ON TABLE system_module COLUMNS module_id UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_module_version ON TABLE system_module_release COLUMNS module_id, version UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_migration_module_id ON TABLE system_migration COLUMNS module_id, migration_id UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_migration_status ON TABLE system_migration COLUMNS status;
            DEFINE INDEX OVERWRITE idx_system_migration_lock_key ON TABLE system_migration_lock COLUMNS lock_key UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_installation_lock_key ON TABLE system_installation_lock COLUMNS lock_key UNIQUE;
        "#;

        let res = self
            .client
            .query(bootstrap_sql)
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_BOOTSTRAP_FAILED",
                message: format!("Failed to bootstrap SurrealDB runtime schema: {}", err),
            })?;

        res.check().map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_BOOTSTRAP_FAILED",
            message: format!("SurrealDB bootstrap check failed: {}", err),
        })?;

        Ok(())
    }

    async fn upsert_module(&self, module: &StoredModule) -> Result<(), RuntimeError> {
        let key_id = module.module_id.as_str().replace([':', '.', '-'], "_");
        let query = r#"
            UPSERT type::thing('system_module', $key_id) SET
                module_id = $module_id,
                name = $name,
                description = $description,
                updated_at = time::now();
        "#;

        let mut attempts = 0;
        loop {
            attempts += 1;
            let res = self
                .client
                .query(query)
                .bind(("key_id", key_id.clone()))
                .bind(("module_id", module.module_id.to_string()))
                .bind(("name", module.name.clone()))
                .bind(("description", module.description.clone()))
                .await;

            match res {
                Ok(r) => match r.check() {
                    Ok(_) => return Ok(()),
                    Err(err) => {
                        let err_str = err.to_string();
                        if attempts < 5
                            && (err_str.contains("conflict") || err_str.contains("retried"))
                        {
                            tokio::time::sleep(tokio::time::Duration::from_millis(20 * attempts))
                                .await;
                            continue;
                        }
                        return Err(RuntimeError::Internal {
                            code: "RUNTIME_MODULE_PERSISTENCE_FAILED",
                            message: format!(
                                "Failed to check upsert module '{}': {}",
                                module.module_id, err
                            ),
                        });
                    }
                },
                Err(err) => {
                    let err_str = err.to_string();
                    if attempts < 5 && (err_str.contains("conflict") || err_str.contains("retried"))
                    {
                        tokio::time::sleep(tokio::time::Duration::from_millis(20 * attempts)).await;
                        continue;
                    }
                    return Err(RuntimeError::Internal {
                        code: "RUNTIME_MODULE_PERSISTENCE_FAILED",
                        message: format!("Failed to upsert module '{}': {}", module.module_id, err),
                    });
                }
            }
        }
    }

    async fn get_module(&self, id: &ModuleId) -> Result<Option<StoredModule>, RuntimeError> {
        let query = "SELECT * FROM system_module WHERE module_id = $module_id LIMIT 1;";

        let mut res = self
            .client
            .query(query)
            .bind(("module_id", id.to_string()))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!("Failed to fetch module '{}': {}", id, err),
            })?;

        let rows: Vec<SystemModuleRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize module rows: {}", err),
        })?;

        let row = rows.into_iter().next();

        Ok(row.map(|r| StoredModule {
            module_id: ModuleId::new(r.module_id),
            name: r.name,
            description: r.description,
            created_at: r.created_at.map(|d| d.to_string()),
            updated_at: r.updated_at.map(|d| d.to_string()),
        }))
    }

    async fn list_modules(&self) -> Result<Vec<StoredModule>, RuntimeError> {
        let query = "SELECT * FROM system_module ORDER BY module_id ASC;";

        let mut res = self
            .client
            .query(query)
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!("Failed to list modules: {}", err),
            })?;

        let rows: Vec<SystemModuleRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize modules list: {}", err),
        })?;

        Ok(rows
            .into_iter()
            .map(|r| StoredModule {
                module_id: ModuleId::new(r.module_id),
                name: r.name,
                description: r.description,
                created_at: r.created_at.map(|d| d.to_string()),
                updated_at: r.updated_at.map(|d| d.to_string()),
            })
            .collect())
    }

    async fn register_release(&self, release: &StoredModuleRelease) -> Result<(), RuntimeError> {
        let key_id = format!(
            "{}_{}",
            release.module_id.as_str().replace([':', '.', '-'], "_"),
            release.version.replace([':', '.', '-'], "_")
        );

        let query = r#"
            UPSERT type::thing('system_module_release', $key_id) SET
                module_id = $module_id,
                version = $version,
                manifest_version = $manifest_version,
                description = $description,
                status = $status,
                checksum = $checksum,
                installation_phase = $installation_phase,
                updated_at = time::now();
        "#;

        let mut attempts = 0;
        loop {
            attempts += 1;
            let res = self
                .client
                .query(query)
                .bind(("key_id", key_id.clone()))
                .bind(("module_id", release.module_id.to_string()))
                .bind(("version", release.version.clone()))
                .bind(("manifest_version", release.manifest_version as i64))
                .bind(("description", release.description.clone()))
                .bind(("status", release.status.clone()))
                .bind(("checksum", release.checksum.clone()))
                .bind(("installation_phase", release.installation_phase.clone()))
                .await;

            match res {
                Ok(query_res) => match query_res.check() {
                    Ok(_) => return Ok(()),
                    Err(err) => {
                        let err_str = err.to_string();
                        if attempts < 5
                            && (err_str.contains("conflict") || err_str.contains("retried"))
                        {
                            tokio::time::sleep(std::time::Duration::from_millis(25 * attempts))
                                .await;
                            continue;
                        }
                        return Err(RuntimeError::Internal {
                            code: "RUNTIME_RELEASE_PERSISTENCE_FAILED",
                            message: format!(
                                "Failed to check register release '{}:{}': {}",
                                release.module_id, release.version, err
                            ),
                        });
                    }
                },
                Err(err) => {
                    let err_str = err.to_string();
                    if attempts < 5 && (err_str.contains("conflict") || err_str.contains("retried"))
                    {
                        tokio::time::sleep(std::time::Duration::from_millis(25 * attempts)).await;
                        continue;
                    }
                    return Err(RuntimeError::Internal {
                        code: "RUNTIME_RELEASE_PERSISTENCE_FAILED",
                        message: format!(
                            "Failed to register release '{}:{}': {}",
                            release.module_id, release.version, err
                        ),
                    });
                }
            }
        }
    }

    async fn get_release(
        &self,
        module_id: &ModuleId,
        version: &str,
    ) -> Result<Option<StoredModuleRelease>, RuntimeError> {
        let key_id = format!(
            "{}_{}",
            module_id.as_str().replace([':', '.', '-'], "_"),
            version.replace([':', '.', '-'], "_")
        );

        let query = "SELECT * FROM type::thing('system_module_release', $key_id);";

        let mut res = self
            .client
            .query(query)
            .bind(("key_id", key_id))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!(
                    "Failed to fetch release '{}:{}': {}",
                    module_id, version, err
                ),
            })?;

        let rows: Vec<SystemReleaseRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize release rows: {}", err),
        })?;

        let row = rows.into_iter().next();

        Ok(row.map(|r| StoredModuleRelease {
            module_id: ModuleId::new(r.module_id),
            version: r.version,
            manifest_version: r.manifest_version as u32,
            description: r.description,
            status: r.status,
            checksum: r.checksum,
            installation_phase: r.installation_phase,
            created_at: r.created_at.map(|d| d.to_string()),
            installed_at: r.installed_at.map(|d| d.to_string()),
        }))
    }

    async fn list_releases(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<StoredModuleRelease>, RuntimeError> {
        let query =
            "SELECT * FROM system_module_release WHERE module_id = $module_id ORDER BY version ASC;";

        let mut res = self
            .client
            .query(query)
            .bind(("module_id", module_id.to_string()))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!(
                    "Failed to list releases for module '{}': {}",
                    module_id, err
                ),
            })?;

        let rows: Vec<SystemReleaseRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize releases list: {}", err),
        })?;

        Ok(rows
            .into_iter()
            .map(|r| StoredModuleRelease {
                module_id: ModuleId::new(r.module_id),
                version: r.version,
                manifest_version: r.manifest_version as u32,
                description: r.description,
                status: r.status,
                checksum: r.checksum,
                installation_phase: r.installation_phase,
                created_at: r.created_at.map(|d| d.to_string()),
                installed_at: r.installed_at.map(|d| d.to_string()),
            })
            .collect())
    }

    async fn update_release_status(
        &self,
        module_id: &ModuleId,
        version: &str,
        status: &str,
        phase: Option<&str>,
    ) -> Result<(), RuntimeError> {
        let key_id = format!(
            "{}_{}",
            module_id.as_str().replace([':', '.', '-'], "_"),
            version.replace([':', '.', '-'], "_")
        );

        let query = r#"
            UPSERT type::thing('system_module_release', $key_id) SET
                status = $status,
                installation_phase = $phase,
                updated_at = time::now();
        "#;

        let mut attempts = 0;
        loop {
            attempts += 1;
            let res = self
                .client
                .query(query)
                .bind(("key_id", key_id.clone()))
                .bind(("status", status.to_string()))
                .bind(("phase", phase.map(|p| p.to_string())))
                .await;

            match res {
                Ok(query_res) => match query_res.check() {
                    Ok(_) => return Ok(()),
                    Err(err) => {
                        let err_str = err.to_string();
                        if attempts < 5
                            && (err_str.contains("conflict") || err_str.contains("retried"))
                        {
                            tokio::time::sleep(std::time::Duration::from_millis(25 * attempts))
                                .await;
                            continue;
                        }
                        return Err(RuntimeError::Internal {
                            code: "RUNTIME_RELEASE_PERSISTENCE_FAILED",
                            message: format!(
                                "Failed to check update release status '{}:{}': {}",
                                module_id, version, err
                            ),
                        });
                    }
                },
                Err(err) => {
                    let err_str = err.to_string();
                    if attempts < 5 && (err_str.contains("conflict") || err_str.contains("retried"))
                    {
                        tokio::time::sleep(std::time::Duration::from_millis(25 * attempts)).await;
                        continue;
                    }
                    return Err(RuntimeError::Internal {
                        code: "RUNTIME_RELEASE_PERSISTENCE_FAILED",
                        message: format!(
                            "Failed to update release status '{}:{}': {}",
                            module_id, version, err
                        ),
                    });
                }
            }
        }
    }

    async fn record_migration(&self, migration: &MigrationRecord) -> Result<(), RuntimeError> {
        let key_id = format!(
            "{}_{}",
            migration.module_id.as_str().replace([':', '.', '-'], "_"),
            migration
                .migration_id
                .as_str()
                .replace([':', '.', '-'], "_")
        );

        let query = r#"
            UPSERT type::thing('system_migration', $key_id) SET
                migration_id = $migration_id,
                module_id = $module_id,
                module_version = $module_version,
                checksum = $checksum,
                status = $status,
                applied_at = $applied_at,
                duration_ms = $duration_ms,
                error = $error,
                updated_at = time::now();
        "#;

        let mut attempts = 0;
        loop {
            attempts += 1;
            let res = self
                .client
                .query(query)
                .bind(("key_id", key_id.clone()))
                .bind(("migration_id", migration.migration_id.to_string()))
                .bind(("module_id", migration.module_id.to_string()))
                .bind(("module_version", migration.module_version.clone()))
                .bind(("checksum", migration.checksum.to_string()))
                .bind(("status", migration.status.to_string()))
                .bind(("applied_at", migration.applied_at as i64))
                .bind(("duration_ms", migration.duration_ms as i64))
                .bind(("error", migration.error.clone()))
                .await;

            match res {
                Ok(query_res) => match query_res.check() {
                    Ok(_) => return Ok(()),
                    Err(err) => {
                        let err_str = err.to_string();
                        if attempts < 5
                            && (err_str.contains("conflict") || err_str.contains("retried"))
                        {
                            tokio::time::sleep(std::time::Duration::from_millis(25 * attempts))
                                .await;
                            continue;
                        }
                        return Err(RuntimeError::Internal {
                            code: "RUNTIME_MIGRATION_PERSISTENCE_FAILED",
                            message: format!(
                                "Failed to check record migration '{}:{}': {}",
                                migration.module_id, migration.migration_id, err
                            ),
                        });
                    }
                },
                Err(err) => {
                    let err_str = err.to_string();
                    if attempts < 5 && (err_str.contains("conflict") || err_str.contains("retried"))
                    {
                        tokio::time::sleep(std::time::Duration::from_millis(25 * attempts)).await;
                        continue;
                    }
                    return Err(RuntimeError::Internal {
                        code: "RUNTIME_MIGRATION_PERSISTENCE_FAILED",
                        message: format!(
                            "Failed to record migration '{}:{}': {}",
                            migration.module_id, migration.migration_id, err
                        ),
                    });
                }
            }
        }
    }

    async fn get_migration(
        &self,
        module_id: &ModuleId,
        migration_id: &MigrationId,
    ) -> Result<Option<MigrationRecord>, RuntimeError> {
        let key_id = format!(
            "{}_{}",
            module_id.as_str().replace([':', '.', '-'], "_"),
            migration_id.as_str().replace([':', '.', '-'], "_")
        );

        let query = "SELECT * FROM type::thing('system_migration', $key_id);";

        let mut res = self
            .client
            .query(query)
            .bind(("key_id", key_id.clone()))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!(
                    "Failed to fetch migration '{}:{}': {}",
                    module_id, migration_id, err
                ),
            })?;

        let rows: Vec<SystemMigrationRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize migration rows: {}", err),
        })?;

        let row = rows.into_iter().next();

        match row {
            Some(r) => {
                let checksum = MigrationChecksum::from_hex(r.checksum)?;
                let status = match r.status.as_str() {
                    "Pending" => MigrationStatus::Pending,
                    "Applying" => MigrationStatus::Applying,
                    "Applied" => MigrationStatus::Applied,
                    "Failed" => MigrationStatus::Failed,
                    "RolledBack" => MigrationStatus::RolledBack,
                    "Skipped" => MigrationStatus::Skipped,
                    _ => MigrationStatus::Pending,
                };
                let mig_id = MigrationId::new(r.migration_id)?;

                Ok(Some(MigrationRecord {
                    migration_id: mig_id,
                    module_id: ModuleId::new(r.module_id),
                    module_version: r.module_version,
                    checksum,
                    applied_at: r.applied_at.map(|v| v as u64).unwrap_or(0),
                    duration_ms: r.duration_ms.map(|v| v as u64).unwrap_or(0),
                    status,
                    error: r.error,
                }))
            }
            None => Ok(None),
        }
    }

    async fn list_migrations(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<MigrationRecord>, RuntimeError> {
        let query =
            "SELECT * FROM system_migration WHERE module_id = $module_id ORDER BY migration_id ASC;";

        let mut res = self
            .client
            .query(query)
            .bind(("module_id", module_id.to_string()))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_STORE_QUERY_FAILED",
                message: format!(
                    "Failed to list migrations for module '{}': {}",
                    module_id, err
                ),
            })?;

        let rows: Vec<SystemMigrationRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_STORE_DATA_INVALID",
            message: format!("Failed to deserialize migrations list: {}", err),
        })?;

        let mut list = Vec::new();
        for r in rows {
            let checksum = MigrationChecksum::from_hex(r.checksum)?;
            let status = match r.status.as_str() {
                "Pending" => MigrationStatus::Pending,
                "Applying" => MigrationStatus::Applying,
                "Applied" => MigrationStatus::Applied,
                "Failed" => MigrationStatus::Failed,
                "RolledBack" => MigrationStatus::RolledBack,
                "Skipped" => MigrationStatus::Skipped,
                _ => MigrationStatus::Pending,
            };
            let mig_id = MigrationId::new(r.migration_id)?;

            list.push(MigrationRecord {
                migration_id: mig_id,
                module_id: ModuleId::new(r.module_id),
                module_version: r.module_version,
                checksum,
                applied_at: r.applied_at.map(|v| v as u64).unwrap_or(0),
                duration_ms: r.duration_ms.map(|v| v as u64).unwrap_or(0),
                status,
                error: r.error,
            });
        }

        Ok(list)
    }
}
