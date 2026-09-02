use crate::error::RuntimeError;
use crate::manifest::model::{ModuleManifest, CURRENT_MANIFEST_VERSION};
use std::collections::HashSet;

/// Validateur des règles structurelles et sémantiques d'un `ModuleManifest`.
pub struct ManifestValidator;

impl ManifestValidator {
    /// Valide l'intégrité et la cohérence d'un manifeste.
    ///
    /// # Erreurs
    /// - `RuntimeError::UnsupportedManifestVersion` si la version du format dépasse la version maximale supportée.
    /// - `RuntimeError::InvalidManifest` si l'identifiant ou le nom est vide.
    /// - `RuntimeError::SelfDependency` si le module déclare une dépendance vers lui-même.
    /// - `RuntimeError::DuplicateDependency` si une même dépendance est déclarée plusieurs fois.
    pub fn validate(manifest: &ModuleManifest) -> Result<(), RuntimeError> {
        // 1. Validation de la version du format de manifeste
        if manifest.manifest_version > CURRENT_MANIFEST_VERSION {
            return Err(RuntimeError::UnsupportedManifestVersion {
                version: manifest.manifest_version,
                supported: CURRENT_MANIFEST_VERSION,
            });
        }

        // 2. Validation de l'identifiant du module
        if manifest.id.as_str().trim().is_empty() {
            return Err(RuntimeError::InvalidManifest {
                message: "Module id cannot be empty".to_string(),
            });
        }

        // 3. Validation du nom lisible
        if manifest.name.trim().is_empty() {
            return Err(RuntimeError::InvalidManifest {
                message: "Module name cannot be empty".to_string(),
            });
        }

        // 4. Validation des dépendances (anti-auto-dépendance et anti-doublon)
        let mut seen_deps = HashSet::new();

        for dep in &manifest.dependencies {
            if dep.id.as_str().trim().is_empty() {
                return Err(RuntimeError::InvalidManifest {
                    message: "Dependency module id cannot be empty".to_string(),
                });
            }

            if dep.id == manifest.id {
                return Err(RuntimeError::SelfDependency {
                    module: manifest.id.clone(),
                });
            }

            if !seen_deps.insert(dep.id.clone()) {
                return Err(RuntimeError::DuplicateDependency {
                    module: manifest.id.clone(),
                    dependency: dep.id.clone(),
                });
            }
        }

        Ok(())
    }
}
