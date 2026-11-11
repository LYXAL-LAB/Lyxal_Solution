//! Module `lyxal_storage` pour `lyxal_runtime` et sonde de santé.

use async_trait::async_trait;
use bytes::Bytes;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use object_store::path::Path;
use object_store::{ObjectStore, ObjectStoreExt};
use std::sync::Arc;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

use crate::backend::{remove, Backends};
use crate::error::{StorageError, StorageResult};
use crate::models::SettingsGetParams;
use crate::store::StorageStore;

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_storage";

/// Dossier des fichiers témoins de la sonde, hors de toute portée.
const PROBE_DIRECTORY: &str = "_lyxal_probe";
/// Contenu du fichier témoin.
const PROBE_CONTENT: &[u8] = b"lyxal_storage";

/// Module `lyxal_storage` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; worker et sonde sont enregistrés par l'hôte.
pub struct StorageModule {
    descriptor: ModuleDescriptor,
}

impl Default for StorageModule {
    fn default() -> Self {
        Self::new()
    }
}

impl StorageModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Storage")
            .description(
                "Fichiers et documents stockés : buckets, fiches de fichiers, états, droits et quotas",
            )
            .capability("database")
            .capability("events")
            .capability("storage")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for StorageModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

/// Sonde de santé : réglages lisibles, et chaque support écrit, relit puis retire un petit
/// fichier témoin. Sans support configuré : « dégradé », aucun fichier n'est écrit ni lu.
pub struct StorageHealthCheck {
    module_id: ModuleId,
    store: StorageStore,
    backends: Arc<Backends>,
}

impl StorageHealthCheck {
    /// Sonde sur le store de la session système de l'hôte et les supports configurés.
    pub fn new(store: StorageStore, backends: Arc<Backends>) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
            backends,
        }
    }
}

/// Écrit, relit et retire un fichier témoin.
async fn probe(store: &dyn ObjectStore) -> StorageResult<()> {
    let stamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_or(0, |elapsed| elapsed.as_nanos());
    let path = Path::from(PROBE_DIRECTORY).join(format!("{}-{stamp}", std::process::id()));
    store
        .put(&path, Bytes::from_static(PROBE_CONTENT).into())
        .await?;
    let read = match store.get(&path).await {
        Ok(result) => result.bytes().await.map_err(StorageError::from),
        Err(error) => Err(error.into()),
    };
    remove(store, &path).await?;
    if read?.as_ref() != PROBE_CONTENT {
        return Err(StorageError::IntegrityFailed(
            "fichier témoin relu différent".to_string(),
        ));
    }
    Ok(())
}

#[async_trait]
impl ModuleHealthCheck for StorageHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let elapsed = || u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        if let Err(error) = self.store.settings_get(SettingsGetParams::default()).await {
            return Ok(HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(elapsed()),
                Some(format!("réglages illisibles : {error}")),
            ));
        }
        if self.backends.is_empty() {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(
                    "STORAGE_BACKEND_UNKNOWN : aucun support configuré, aucun fichier n'est écrit ni lu"
                        .to_string(),
                ),
            ));
        }
        for (name, backend) in self.backends.iter() {
            if let Err(error) = probe(backend.as_ref()).await {
                return Ok(HealthCheckResult::degraded(
                    self.module_id.clone(),
                    elapsed(),
                    Some(format!("support {name} : {error}")),
                ));
            }
        }
        Ok(HealthCheckResult::healthy(
            self.module_id.clone(),
            elapsed(),
            Some("supports de stockage joignables".to_string()),
        ))
    }
}
