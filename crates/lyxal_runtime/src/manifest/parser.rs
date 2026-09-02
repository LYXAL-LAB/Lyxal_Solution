use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::manifest::model::ModuleManifest;
use crate::manifest::validation::ManifestValidator;
use std::fs;
use std::path::Path;

/// Analyseur syntaxique officiel des fichiers `manifest.toml`.
pub struct ManifestParser;

impl ManifestParser {
    /// Analyse une chaîne au format TOML et retourne le `ModuleManifest` validé.
    pub fn parse_str(input: &str) -> Result<ModuleManifest, RuntimeError> {
        let manifest: ModuleManifest =
            toml::from_str(input).map_err(|err| RuntimeError::ManifestParseError {
                message: err.to_string(),
            })?;

        ManifestValidator::validate(&manifest)?;
        Ok(manifest)
    }

    /// Lit un fichier depuis le chemin spécifié et retourne le `ModuleManifest` validé.
    pub fn parse_file(path: impl AsRef<Path>) -> Result<ModuleManifest, RuntimeError> {
        let path_ref = path.as_ref();
        let content =
            fs::read_to_string(path_ref).map_err(|err| RuntimeError::InvalidManifest {
                message: format!(
                    "Failed to read manifest file '{}': {}",
                    path_ref.display(),
                    err
                ),
            })?;

        Self::parse_str(&content)
    }

    /// Analyse une chaîne TOML et la convertit directement en `ModuleDescriptor`.
    pub fn parse_to_descriptor(input: &str) -> Result<ModuleDescriptor, RuntimeError> {
        let manifest = Self::parse_str(input)?;
        manifest.to_descriptor()
    }
}
