//! Module `lyxal_storage` : implémentation `LyxalModule`, supports, worker de nettoyage et sonde
//! de santé.
//!
//! Le support `default` est un dossier du serveur (`LYXAL__STORAGE__DISK__ROOT`). Sans dossier :
//! aucun fichier n'est écrit ni lu, le worker n'est pas lancé et la sonde le signale.

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_storage::{
    BackendConfig, Backends, StorageCleanupWorker, StorageHealthCheck, StorageModule, StorageStore,
};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_storage::MODULE_ID;

/// Nom du support d'un bucket créé sans support précisé.
const DEFAULT_BACKEND: &str = "default";
/// Intervalle du nettoyage.
const CLEANUP_INTERVAL: Duration = Duration::from_secs(600);
/// Éléments nettoyés par paquet.
const CLEANUP_BATCH: u32 = 200;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(StorageModule::new())
}

/// Supports de l'installation, depuis la configuration.
fn backends(config: &AppConfig) -> Result<Backends, ServerError> {
    let Some(disk) = &config.storage.disk else {
        tracing::warn!(
            "stockage des fichiers désactivé : LYXAL__STORAGE__DISK__ROOT requis (dossier du support)"
        );
        return Ok(Backends::new());
    };
    Backends::new()
        .with(
            DEFAULT_BACKEND,
            BackendConfig::Disk {
                root: disk.root.clone(),
            },
        )
        .map_err(|error| ServerError::Configuration {
            message: format!("storage.disk.root : {error}"),
        })
}

/// Sonde, et worker de nettoyage si un support est configuré. Rend les supports, utilisés par
/// les routes `/storage/*`.
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
) -> Result<Arc<Backends>, ServerError> {
    let store = StorageStore::new(client.clone());
    let backends = Arc::new(backends(config)?);
    if !backends.is_empty() {
        runtime.register_worker(Arc::new(StorageCleanupWorker::new(
            store.clone(),
            backends.clone(),
            CLEANUP_INTERVAL,
            CLEANUP_BATCH,
        )?))?;
    }
    runtime
        .health_registry()
        .register_check(Arc::new(StorageHealthCheck::new(store, backends.clone())))?;
    Ok(backends)
}
