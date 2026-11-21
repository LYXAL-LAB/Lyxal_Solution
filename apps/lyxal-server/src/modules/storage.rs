//! Module `lyxal_storage` : implémentation `LyxalModule`, supports, nettoyage (exécuté par
//! `lyxal_scheduler`, tâche `storage.cleanup` de `modules::tasks`) et sonde de santé.
//!
//! Le support `default` est un dossier du serveur (`LYXAL__STORAGE__DISK__ROOT`) ; des services
//! S3 ou compatibles sont déclarés par nom (`LYXAL__STORAGE__S3__<NOM>__*`). Sans aucun support :
//! aucun fichier n'est écrit ni lu, le nettoyage ne fait rien sur ce nœud et la sonde le signale.
//!
//! Les buckets chiffrés reçoivent les clés de fichiers du coffre-fort (`lyxal_secrets`, clé
//! maîtresse `LYXAL__SECRETS__MASTER_KEY`) ; sans clé maîtresse, aucun fichier n'y est écrit ni
//! lu (`STORAGE_ENCRYPTION_UNAVAILABLE`). Les buckets en clair n'en dépendent pas.

use crate::config::AppConfig;
use crate::context::StorageHost;
use crate::error::ServerError;
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_secrets::FileKeys;
use lyxal_storage::{
    BackendConfig, Backends, ClamAvScanner, ContentScanner, ScannerConfig, StorageCleanup,
    StorageHealthCheck, StorageModule, StorageStore,
};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_storage::MODULE_ID;

/// Nom du support d'un bucket créé sans support précisé.
const DEFAULT_BACKEND: &str = "default";
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

/// Antivirus de l'installation, s'il est configuré (`LYXAL__STORAGE__ANTIVIRUS__*`).
fn scanner(config: &AppConfig) -> Option<Arc<dyn ContentScanner>> {
    let antivirus = config.storage.antivirus.as_ref()?;
    let address = match (&antivirus.address, &antivirus.socket) {
        (Some(address), _) => ScannerConfig::Tcp {
            address: address.clone(),
        },
        (None, Some(path)) => ScannerConfig::Socket { path: path.clone() },
        // Écarté par la validation de la configuration
        (None, None) => return None,
    };
    Some(Arc::new(ClamAvScanner::new(
        address,
        Duration::from_secs(antivirus.timeout_seconds),
    )))
}

/// Nettoyage du stockage sur la session système de l'hôte, exécuté par la tâche
/// `storage.cleanup` ; absent si aucun support n'est configuré. Les envois reprenables qu'il
/// assemble passent par le même antivirus que les routes ; les clés de fichiers des buckets
/// chiffrés y sont rescellées après la rotation de la clé « fichiers » d'une organisation.
pub fn cleanup(client: &Surreal<Any>, host: &StorageHost) -> Option<StorageCleanup> {
    if host.backends.is_empty() {
        return None;
    }
    let mut cleanup = StorageCleanup::new(
        StorageStore::new(client.clone()),
        host.backends.clone(),
        CLEANUP_BATCH,
    );
    if let Some(scanner) = &host.scanner {
        cleanup = cleanup.with_scanner(scanner.clone());
    }
    if let Some(keys) = &host.file_keys {
        cleanup = cleanup.with_file_keys(keys.clone());
    }
    Some(cleanup)
}

/// Sonde de santé. Rend les supports, l'antivirus et les clés de fichiers du coffre-fort
/// (`file_keys`), utilisés par les routes `/storage/*` et par le nettoyage.
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
    file_keys: FileKeys,
) -> Result<StorageHost, ServerError> {
    let store = StorageStore::new(client.clone());
    let backends = Arc::new(backends(config)?);
    let scanner = scanner(config);
    let mut probe = StorageHealthCheck::new(store, backends.clone());
    if let Some(scanner) = &scanner {
        probe = probe.with_scanner(scanner.clone());
    }
    runtime.health_registry().register_check(Arc::new(probe))?;
    Ok(StorageHost {
        backends,
        scanner,
        file_keys: Some(file_keys),
    })
}
