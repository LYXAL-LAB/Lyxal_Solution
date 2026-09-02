use crate::error::RuntimeError;
use crate::resource::kind::ResourceKind;
use crate::resource::model::ModuleResource;
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
    async fn list_resources(&self, prefix: &str) -> Result<Vec<String>, RuntimeError> {
        let dir_path = self.resolve_path(prefix)?;

        if !dir_path.exists() || !dir_path.is_dir() {
            return Ok(Vec::new());
        }

        let mut results = Vec::new();
        let entries = fs::read_dir(&dir_path).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_RESOURCE_READ_DIR_FAILED",
            message: format!("Failed to read directory '{}': {}", dir_path.display(), err),
        })?;

        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_file() {
                if let Some(name) = path.file_name().and_then(|n| n.to_str()) {
                    let clean_prefix = prefix.trim().trim_matches('/').replace('\\', "/");
                    let logical = if clean_prefix.is_empty() {
                        name.to_string()
                    } else {
                        format!("{}/{}", clean_prefix, name)
                    };
                    results.push(logical);
                }
            }
        }

        results.sort();
        Ok(results)
    }

    async fn read_resource(&self, logical_path: &str) -> Result<ModuleResource, RuntimeError> {
        let target_path = self.resolve_path(logical_path)?;

        if !target_path.exists() || !target_path.is_file() {
            return Err(RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            });
        }

        // Vérification de la taille
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

        // Lecture brute et vérification UTF-8
        let raw_bytes = fs::read(&target_path).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_RESOURCE_READ_FAILED",
            message: format!("Failed to read file '{}': {}", target_path.display(), err),
        })?;

        let content =
            String::from_utf8(raw_bytes).map_err(|err| RuntimeError::ResourceEncodingError {
                path: logical_path.to_string(),
                message: format!("Resource is not valid UTF-8: {}", err),
            })?;

        let filename = target_path
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(logical_path);

        let kind = ResourceKind::from_filename(filename)
            .unwrap_or(ResourceKind::Custom(logical_path.trim().replace('\\', "/")));

        Ok(ModuleResource::new(
            logical_path.trim().replace('\\', "/"),
            kind,
            content,
        ))
    }

    async fn exists(&self, logical_path: &str) -> bool {
        match self.resolve_path(logical_path) {
            Ok(p) => p.exists() && p.is_file(),
            Err(_) => false,
        }
    }
}
