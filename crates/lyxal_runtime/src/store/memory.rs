use crate::error::RuntimeError;
use crate::migration::{MigrationId, MigrationRecord};
use crate::store::models::{StoredModule, StoredModuleRelease};
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use async_trait::async_trait;
use std::collections::HashMap;
use std::sync::RwLock;

/// Implémentation en mémoire du `RuntimeStore` pour les tests unitaires isolés.
#[derive(Default)]
pub struct MemoryRuntimeStore {
    modules: RwLock<HashMap<ModuleId, StoredModule>>,
    releases: RwLock<HashMap<(ModuleId, String), StoredModuleRelease>>,
    migrations: RwLock<HashMap<(ModuleId, MigrationId), MigrationRecord>>,
    bootstrapped: RwLock<bool>,
}

impl MemoryRuntimeStore {
    /// Crée un nouveau store mémoire vierge.
    pub fn new() -> Self {
        Self::default()
    }
}

#[async_trait]
impl RuntimeStore for MemoryRuntimeStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        let mut bootstrapped = self
            .bootstrapped
            .write()
            .map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock during bootstrap".to_string(),
            })?;
        *bootstrapped = true;
        Ok(())
    }

    async fn upsert_module(&self, module: &StoredModule) -> Result<(), RuntimeError> {
        let mut modules = self.modules.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire write lock for module".to_string(),
        })?;
        modules.insert(module.module_id.clone(), module.clone());
        Ok(())
    }

    async fn get_module(&self, id: &ModuleId) -> Result<Option<StoredModule>, RuntimeError> {
        let modules = self.modules.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for module".to_string(),
        })?;
        Ok(modules.get(id).cloned())
    }

    async fn list_modules(&self) -> Result<Vec<StoredModule>, RuntimeError> {
        let modules = self.modules.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for module list".to_string(),
        })?;
        let mut list: Vec<StoredModule> = modules.values().cloned().collect();
        list.sort_by(|a, b| a.module_id.cmp(&b.module_id));
        Ok(list)
    }

    async fn register_release(&self, release: &StoredModuleRelease) -> Result<(), RuntimeError> {
        let mut releases = self.releases.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire write lock for release".to_string(),
        })?;
        releases.insert(
            (release.module_id.clone(), release.version.clone()),
            release.clone(),
        );
        Ok(())
    }

    async fn get_release(
        &self,
        module_id: &ModuleId,
        version: &str,
    ) -> Result<Option<StoredModuleRelease>, RuntimeError> {
        let releases = self.releases.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for release".to_string(),
        })?;
        Ok(releases
            .get(&(module_id.clone(), version.to_string()))
            .cloned())
    }

    async fn list_releases(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<StoredModuleRelease>, RuntimeError> {
        let releases = self.releases.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for release list".to_string(),
        })?;
        let mut list: Vec<StoredModuleRelease> = releases
            .values()
            .filter(|r| &r.module_id == module_id)
            .cloned()
            .collect();
        list.sort_by(|a, b| a.version.cmp(&b.version));
        Ok(list)
    }

    async fn update_release_status(
        &self,
        module_id: &ModuleId,
        version: &str,
        status: &str,
        phase: Option<&str>,
    ) -> Result<(), RuntimeError> {
        let mut releases = self.releases.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire write lock for release status update".to_string(),
        })?;
        if let Some(rel) = releases.get_mut(&(module_id.clone(), version.to_string())) {
            rel.status = status.to_string();
            rel.installation_phase = phase.map(|p| p.to_string());
        }
        Ok(())
    }

    async fn record_migration(&self, migration: &MigrationRecord) -> Result<(), RuntimeError> {
        let mut migrations = self
            .migrations
            .write()
            .map_err(|_| RuntimeError::Internal {
                code: "RUNTIME_LOCK_POISONED",
                message: "Failed to acquire write lock for migration".to_string(),
            })?;
        migrations.insert(
            (migration.module_id.clone(), migration.migration_id.clone()),
            migration.clone(),
        );
        Ok(())
    }

    async fn get_migration(
        &self,
        module_id: &ModuleId,
        migration_id: &MigrationId,
    ) -> Result<Option<MigrationRecord>, RuntimeError> {
        let migrations = self.migrations.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for migration".to_string(),
        })?;
        Ok(migrations
            .get(&(module_id.clone(), migration_id.clone()))
            .cloned())
    }

    async fn list_migrations(
        &self,
        module_id: &ModuleId,
    ) -> Result<Vec<MigrationRecord>, RuntimeError> {
        let migrations = self.migrations.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "Failed to acquire read lock for migration list".to_string(),
        })?;
        let mut list: Vec<MigrationRecord> = migrations
            .values()
            .filter(|m| &m.module_id == module_id)
            .cloned()
            .collect();
        list.sort_by(|a, b| a.migration_id.cmp(&b.migration_id));
        Ok(list)
    }
}
