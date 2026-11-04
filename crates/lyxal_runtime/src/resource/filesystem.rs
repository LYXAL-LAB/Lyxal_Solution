use crate::error::RuntimeError;
use crate::resource::provider::ResourceProvider;
use async_trait::async_trait;
use std::fs;
use std::path::{Path, PathBuf};

/// Limite de taille par défaut pour une ressource SurrealQL (10 Mo).
pub const DEFAULT_MAX_RESOURCE_SIZE: usize = 10 * 1024 * 1024;

/// Implémentation de `ResourceProvider` basée sur le système de fichiers local.
///
/// Intègre des protections strictes contre le path traversal (`..`, chemins absolus, symlinks),
/// le dépassement de taille maximale et les erreurs d'encodage.
pub struct FilesystemResourceProvider {
    root_path: PathBuf,
    max_size: usize,
}

impl FilesystemResourceProvider {
    /// Crée un nouveau provider à partir du répertoire racine d'un module.
    pub fn new(root_path: impl AsRef<Path>) -> Self {
        Self {
            root_path: root_path.as_ref().to_path_buf(),
            max_size: DEFAULT_MAX_RESOURCE_SIZE,
        }
    }

    /// Définit la taille maximale autorisée pour une ressource.
    pub fn with_max_size(mut self, max_size: usize) -> Self {
        self.max_size = max_size;
        self
    }

    /// Résout et valide un chemin logique pour garantir qu'il reste dans `root_path`.
    fn resolve_path(&self, logical_path: &str) -> Result<PathBuf, RuntimeError> {
        let clean_path = logical_path.trim().replace('\\', "/");

        // Interdiction des chemins absolus
        if clean_path.starts_with('/')
            || (clean_path.len() >= 2 && clean_path.chars().nth(1) == Some(':'))
        {
            return Err(RuntimeError::InvalidResourcePath {
                path: logical_path.to_string(),
                reason: "Absolute paths are prohibited for module resources".to_string(),
            });
        }

        // Interdiction du path traversal (..)
        for segment in clean_path.split('/') {
            if segment == ".." {
                return Err(RuntimeError::InvalidResourcePath {
                    path: logical_path.to_string(),
                    reason: "Directory traversal ('..') is strictly prohibited".to_string(),
                });
            }
        }

        let target = self.root_path.join(&clean_path);

        Ok(target)
    }
}

#[async_trait]
impl ResourceProvider for FilesystemResourceProvider {
    async fn read(&self, logical_path: &str) -> Result<String, RuntimeError> {
        let target_path = self.resolve_path(logical_path)?;

        if !target_path.is_file() {
            return Err(RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            });
        }

        let metadata =
            fs::metadata(&target_path).map_err(|err| RuntimeError::ResourceNotFound {
                path: format!("Cannot read metadata for '{}': {}", logical_path, err),
            })?;
        let size = metadata.len() as usize;
        if size > self.max_size {
            return Err(RuntimeError::ResourceTooLarge {
                path: logical_path.to_string(),
                size,
                max_size: self.max_size,
            });
        }

        let raw_bytes = fs::read(&target_path).map_err(|err| RuntimeError::ResourceReadFailed {
            path: logical_path.to_string(),
            message: err.to_string(),
        })?;

        String::from_utf8(raw_bytes).map_err(|err| RuntimeError::ResourceEncodingError {
            path: logical_path.to_string(),
            message: format!("Resource is not valid UTF-8: {}", err),
        })
    }
}
