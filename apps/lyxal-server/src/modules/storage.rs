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
use lyxal_host::database::Database;
use lyxal_host::services::{storage_backends, storage_scanner};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_secrets::FileKeys;
use lyxal_storage::{StorageCleanup, StorageHealthCheck, StorageModule, StorageStore};
use std::sync::Arc;

pub const MODULE_ID: &str = lyxal_storage::MODULE_ID;

/// Éléments nettoyés par paquet.
const CLEANUP_BATCH: u32 = 200;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(StorageModule::new())
}

/// Nettoyage du stockage sur la session système de l'hôte, exécuté par la tâche
/// `storage.cleanup` ; absent si aucun support n'est configuré. Les envois reprenables qu'il
/// assemble passent par le même antivirus que les routes ; les clés de fichiers des buckets
/// chiffrés y sont rescellées après la rotation de la clé « fichiers » d'une organisation.
pub fn cleanup(database: &Database, host: &StorageHost) -> Option<StorageCleanup> {
    if host.backends.is_empty() {
        return None;
    }
    let mut cleanup = StorageCleanup::new(
        StorageStore::new(database.clone()),
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
    database: &Database,
    config: &AppConfig,
    file_keys: FileKeys,
) -> Result<StorageHost, ServerError> {
    let store = StorageStore::new(database.clone());
    let backends = Arc::new(storage_backends(&config.storage)?);
    if backends.is_empty() {
        tracing::warn!(
            "stockage des fichiers désactivé : LYXAL__STORAGE__DISK__ROOT ou LYXAL__STORAGE__S3__<NOM>__* requis"
        );
    }
    let scanner = storage_scanner(&config.storage);
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
