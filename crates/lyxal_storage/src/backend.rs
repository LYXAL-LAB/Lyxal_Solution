//! Supports : où sont écrits les octets (`object_store`). Chaque bucket nomme son support ;
//! l'hôte construit les supports depuis sa configuration.

use object_store::local::LocalFileSystem;
use object_store::memory::InMemory;
use object_store::path::Path;
use object_store::ObjectStore;
use std::collections::BTreeMap;
use std::path::PathBuf;
use std::sync::Arc;

use crate::error::{StorageError, StorageResult};

/// Configuration d'un support.
#[derive(Debug, Clone)]
pub enum BackendConfig {
    /// Disque local : tout est écrit sous `root`, créé s'il n'existe pas.
    Disk {
        /// Dossier racine du support.
        root: PathBuf,
    },
    /// Mémoire du processus (tests).
    Memory,
}

/// Supports configurés, par nom.
#[derive(Debug, Default, Clone)]
pub struct Backends {
    stores: BTreeMap<String, Arc<dyn ObjectStore>>,
}

impl Backends {
    /// Aucun support : toute écriture et toute lecture sont refusées.
    pub fn new() -> Self {
        Self::default()
    }

    /// Ajoute le support `name`.
    pub fn with(mut self, name: &str, config: BackendConfig) -> StorageResult<Self> {
        let store: Arc<dyn ObjectStore> = match config {
            BackendConfig::Disk { root } => {
                std::fs::create_dir_all(&root).map_err(|error| {
                    StorageError::BackendUnavailable(format!("{} : {error}", root.display()))
                })?;
                Arc::new(LocalFileSystem::new_with_prefix(&root)?.with_automatic_cleanup(true))
            }
            BackendConfig::Memory => Arc::new(InMemory::new()),
        };
        self.stores.insert(name.to_string(), store);
        Ok(self)
    }

    /// Support `name`.
    pub fn get(&self, name: &str) -> StorageResult<&Arc<dyn ObjectStore>> {
        self.stores
            .get(name)
            .ok_or_else(|| StorageError::BackendUnknown(name.to_string()))
    }

    /// Noms et supports configurés.
    pub fn iter(&self) -> impl Iterator<Item = (&str, &Arc<dyn ObjectStore>)> {
        self.stores
            .iter()
            .map(|(name, store)| (name.as_str(), store))
    }

    /// Vrai si aucun support n'est configuré.
    pub fn is_empty(&self) -> bool {
        self.stores.is_empty()
    }
}

/// Emplacement sur un support, depuis le chemin rendu par SurrealQL (`path`, `prefix`).
pub(crate) fn location(path: &str) -> StorageResult<Path> {
    Path::parse(path)
        .map_err(|error| StorageError::BackendUnavailable(format!("emplacement refusé : {error}")))
}

/// Retire un fichier du support ; des octets déjà absents ne sont pas une erreur.
pub(crate) async fn remove(store: &dyn ObjectStore, path: &Path) -> StorageResult<()> {
    use object_store::ObjectStoreExt;
    match store.delete(path).await {
        Ok(()) | Err(object_store::Error::NotFound { .. }) => Ok(()),
        Err(error) => Err(error.into()),
    }
}
