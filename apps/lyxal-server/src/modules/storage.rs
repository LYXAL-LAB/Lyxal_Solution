//! Module `lyxal_storage` : implémentation `LyxalModule`, supports, worker de nettoyage et sonde
//! de santé.
//!
//! Le support `default` est un dossier du serveur (`LYXAL__STORAGE__DISK__ROOT`) ; des services
//! S3 ou compatibles sont déclarés par nom (`LYXAL__STORAGE__S3__<NOM>__*`). Sans aucun support :
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

/// Supports de l'installation, depuis la configuration : le dossier disque (`default`) et les
/// services S3 nommés.
fn backends(config: &AppConfig) -> Result<Backends, ServerError> {
    let storage = &config.storage;
    let mut backends = Backends::new();
    if let Some(disk) = &storage.disk {
        backends = backends
            .with(
                DEFAULT_BACKEND,
                BackendConfig::Disk {
                    root: disk.root.clone(),
                },
            )
            .map_err(|error| ServerError::Configuration {
                message: format!("storage.disk.root : {error}"),
            })?;
    }
    for (name, s3) in &storage.s3 {
        if storage.disk.is_some() && name == DEFAULT_BACKEND {
            return Err(ServerError::Configuration {
                message: format!(
                    "storage.s3.{name} : le support `{DEFAULT_BACKEND}` est déjà le dossier storage.disk.root"
                ),
            });
        }
        backends = backends
            .with(
                name,
                BackendConfig::S3 {
                    endpoint: s3.endpoint.clone(),
                    region: s3.region.clone(),
                    bucket: s3.bucket.clone(),
                    access_key_id: s3.access_key_id.clone(),
                    secret_access_key: s3.secret_access_key.to_secret().map_err(|_| {
                        ServerError::Configuration {
                            message: format!(
                                "storage.s3.{name}.secret_access_key : valeur refusée"
                            ),
                        }
                    })?,
                    path_style: s3.path_style,
                    allow_http: s3.allow_http,
                },
            )
            .map_err(|error| ServerError::Configuration {
                message: format!("storage.s3.{name} : {error}"),
            })?;
    }
    if backends.is_empty() {
        tracing::warn!(
            "stockage des fichiers désactivé : LYXAL__STORAGE__DISK__ROOT ou LYXAL__STORAGE__S3__<NOM>__* requis"
        );
    }
    Ok(backends)
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
