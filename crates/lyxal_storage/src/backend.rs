//! Supports : où sont écrits les octets (`object_store`) : disque local, service S3 ou
//! compatible, mémoire. Chaque bucket nomme son support ; l'hôte construit les supports depuis sa
//! configuration.

use futures::StreamExt;
use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::SecretString;
use object_store::aws::AmazonS3Builder;
use object_store::local::LocalFileSystem;
use object_store::memory::InMemory;
use object_store::path::Path;
use object_store::{ObjectStore, ObjectStoreExt};
use std::collections::BTreeMap;
use std::io::ErrorKind;
use std::path::PathBuf;
use std::sync::Arc;

use crate::error::{StorageError, StorageResult};

/// Configuration d'un support.
#[derive(Debug)]
pub enum BackendConfig {
    /// Disque local : tout est écrit sous `root`, créé s'il n'existe pas.
    Disk {
        /// Dossier racine du support.
        root: PathBuf,
    },
    /// Service S3 ou compatible (Bunny Storage, par exemple) : un bucket du service porte les
    /// octets.
    S3 {
        /// Point d'accès du service (`https://de-s3.storage.bunnycdn.com`).
        endpoint: String,
        /// Région attendue par le service.
        region: String,
        /// Bucket du service (chez Bunny : nom de la zone de stockage).
        bucket: String,
        /// Clé d'accès (chez Bunny : nom de la zone de stockage).
        access_key_id: String,
        /// Clé secrète (chez Bunny : mot de passe de la zone de stockage).
        secret_access_key: SecretString,
        /// Adresses de la forme `/<bucket>/<clé>` (seule forme admise par Bunny) ; sinon le
        /// bucket est dans le nom d'hôte.
        path_style: bool,
        /// Autorise un point d'accès `http://` (tests, réseau privé).
        allow_http: bool,
    },
    /// Mémoire du processus (tests).
    Memory,
}

/// Support configuré.
#[derive(Debug, Clone)]
pub struct Backend {
    store: Arc<dyn ObjectStore>,
    /// Dossier racine d'un support disque.
    root: Option<PathBuf>,
}

impl Backend {
    /// Accès `object_store` au support.
    pub fn store(&self) -> &Arc<dyn ObjectStore> {
        &self.store
    }

    /// Dossier ou fichier du disque pour un emplacement (support disque seulement).
    fn disk_path(&self, path: &Path) -> Option<PathBuf> {
        self.root.as_ref().map(|root| {
            path.parts()
                .fold(root.clone(), |dir, part| dir.join(part.as_ref()))
        })
    }

    /// Retire un fichier du support ; des octets déjà absents ne sont pas une erreur. Sur
    /// disque, retire aussi les fichiers d'écriture en cours (`<fichier>#<n>`) laissés par un
    /// arrêt brutal du serveur : `object_store` ne les liste pas.
    pub(crate) async fn remove(&self, path: &Path) -> StorageResult<()> {
        match self.store.delete(path).await {
            Ok(()) | Err(object_store::Error::NotFound { .. }) => {}
            Err(error) => return Err(error.into()),
        }
        let (Some(file), Some(name)) = (self.disk_path(path), path.filename()) else {
            return Ok(());
        };
        let Some(directory) = file.parent() else {
            return Ok(());
        };
        let mut entries = match tokio::fs::read_dir(directory).await {
            Ok(entries) => entries,
            Err(error) if error.kind() == ErrorKind::NotFound => return Ok(()),
            Err(error) => return Err(io_error(directory, &error)),
        };
        let staged = format!("{name}#");
        while let Some(entry) = entries
            .next_entry()
            .await
            .map_err(|error| io_error(directory, &error))?
        {
            let is_staged = entry.file_name().to_str().is_some_and(|entry_name| {
                entry_name.strip_prefix(&staged).is_some_and(|suffix| {
                    !suffix.is_empty() && suffix.bytes().all(|b| b.is_ascii_digit())
                })
            });
            if is_staged {
                remove_file(&entry.path()).await?;
            }
        }
        // Dossier devenu vide : retiré ; un dossier encore occupé refuse, ce qui est attendu
        let _ = tokio::fs::remove_dir(directory).await;
        Ok(())
    }

    /// Retire tous les fichiers d'un préfixe ; rend faux si l'annulation l'a interrompu (le
    /// retrait reprend au passage suivant).
    pub(crate) async fn remove_prefix(
        &self,
        prefix: &Path,
        cancellation: &CancellationToken,
    ) -> StorageResult<bool> {
        let mut listed = self.store.list(Some(prefix));
        while let Some(meta) = listed.next().await {
            if cancellation.is_cancelled() {
                return Ok(false);
            }
            match self.store.delete(&meta?.location).await {
                Ok(()) | Err(object_store::Error::NotFound { .. }) => {}
                Err(error) => return Err(error.into()),
            }
        }
        // Sur disque : le reste du dossier (fichiers d'écriture en cours, dossiers vides)
        if let Some(directory) = self.disk_path(prefix) {
            match tokio::fs::remove_dir_all(&directory).await {
                Ok(()) => {}
                Err(error) if error.kind() == ErrorKind::NotFound => {}
                Err(error) => return Err(io_error(&directory, &error)),
            }
        }
        Ok(true)
    }
}

fn io_error(path: &std::path::Path, error: &std::io::Error) -> StorageError {
    StorageError::BackendUnavailable(format!("{} : {error}", path.display()))
}

async fn remove_file(path: &std::path::Path) -> StorageResult<()> {
    match tokio::fs::remove_file(path).await {
        Ok(()) => Ok(()),
        Err(error) if error.kind() == ErrorKind::NotFound => Ok(()),
        Err(error) => Err(io_error(path, &error)),
    }
}

/// Supports configurés, par nom.
#[derive(Debug, Default, Clone)]
pub struct Backends {
    backends: BTreeMap<String, Backend>,
}

impl Backends {
    /// Aucun support : toute écriture et toute lecture sont refusées.
    pub fn new() -> Self {
        Self::default()
    }

    /// Ajoute le support `name`.
    pub fn with(mut self, name: &str, config: BackendConfig) -> StorageResult<Self> {
        let backend = match config {
            BackendConfig::Disk { root } => {
                std::fs::create_dir_all(&root).map_err(|error| io_error(&root, &error))?;
                // Chemin résolu : le même que celui sous lequel `object_store` écrit
                let root = root
                    .canonicalize()
                    .map_err(|error| io_error(&root, &error))?;
                Backend {
                    store: Arc::new(
                        LocalFileSystem::new_with_prefix(&root)?.with_automatic_cleanup(true),
                    ),
                    root: Some(root),
                }
            }
            BackendConfig::S3 {
                endpoint,
                region,
                bucket,
                access_key_id,
                secret_access_key,
                path_style,
                allow_http,
            } => Backend {
                // Requêtes signées par `object_store` ; ses nouvelles tentatives par défaut
                // couvrent les erreurs passagères et les réponses `503` du service
                store: Arc::new(
                    AmazonS3Builder::new()
                        .with_endpoint(endpoint)
                        .with_region(region)
                        .with_bucket_name(bucket)
                        .with_access_key_id(access_key_id)
                        .with_secret_access_key(secret_access_key.expose_secret())
                        .with_virtual_hosted_style_request(!path_style)
                        .with_allow_http(allow_http)
                        .build()?,
                ),
                root: None,
            },
            BackendConfig::Memory => Backend {
                store: Arc::new(InMemory::new()),
                root: None,
            },
        };
        self.backends.insert(name.to_string(), backend);
        Ok(self)
    }

    /// Support `name`.
    pub fn get(&self, name: &str) -> StorageResult<&Backend> {
        self.backends
            .get(name)
            .ok_or_else(|| StorageError::BackendUnknown(name.to_string()))
    }

    /// Noms et supports configurés.
    pub fn iter(&self) -> impl Iterator<Item = (&str, &Backend)> {
        self.backends
            .iter()
            .map(|(name, backend)| (name.as_str(), backend))
    }

    /// Vrai si aucun support n'est configuré.
    pub fn is_empty(&self) -> bool {
        self.backends.is_empty()
    }
}

/// Emplacement sur un support, depuis le chemin rendu par SurrealQL (`path`, `prefix`).
pub(crate) fn location(path: &str) -> StorageResult<Path> {
    Path::parse(path)
        .map_err(|error| StorageError::BackendUnavailable(format!("emplacement refusé : {error}")))
}
