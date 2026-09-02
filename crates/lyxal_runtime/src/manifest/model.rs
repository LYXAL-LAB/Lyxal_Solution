use crate::descriptor::ModuleDescriptor;
use crate::error::RuntimeError;
use crate::types::ModuleId;
use semver::{Version, VersionReq};
use serde::{Deserialize, Serialize};

/// Version actuelle supportée du format de fichier `manifest.toml`.
pub const CURRENT_MANIFEST_VERSION: u32 = 1;

/// Représentation déclarative d'une dépendance vers un autre module avec contrainte de version SemVer.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ModuleDependency {
    /// Identifiant canonique du module requis.
    pub id: ModuleId,
    /// Contrainte de version sémantique optionnelle (ex: ">=1.0.0", "^0.2").
    #[serde(default)]
    pub version: Option<VersionReq>,
}

impl ModuleDependency {
    /// Crée une dépendance simple sans contrainte de version spécifique.
    pub fn new(id: impl Into<ModuleId>) -> Self {
        Self {
            id: id.into(),
            version: None,
        }
    }

    /// Crée une dépendance avec une contrainte de version SemVer.
    pub fn with_version(id: impl Into<ModuleId>, req: VersionReq) -> Self {
        Self {
            id: id.into(),
            version: Some(req),
        }
    }

    /// Vérifie si une version de module donnée satisfait la contrainte de cette dépendance.
    pub fn matches(&self, module_version: &Version) -> bool {
        match &self.version {
            Some(req) => req.matches(module_version),
            None => true,
        }
    }
}

/// Contraintes de compatibilité avec l'environnement d'exécution Lyxal OS.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub struct RuntimeRequirement {
    /// Version minimale du Runtime requise.
    pub min_version: Option<VersionReq>,
}

/// Modèle déclaratif complet issu du parsing d'un fichier `manifest.toml`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ModuleManifest {
    /// Version du format du manifeste (par défaut `1`).
    #[serde(default = "default_manifest_version")]
    pub manifest_version: u32,
    /// Identifiant canonique du module (ex: "calendar", "scheduler").
    pub id: ModuleId,
    /// Nom lisible du module.
    pub name: String,
    /// Version sémantique du module (SemVer).
    pub version: Version,
    /// Description optionnelle du module.
    pub description: Option<String>,
    /// Exigences de compatibilité d'exécution.
    #[serde(default)]
    pub runtime: Option<RuntimeRequirement>,
    /// Liste des dépendances requises vers d'autres modules.
    #[serde(default)]
    pub dependencies: Vec<ModuleDependency>,
    /// Capacités déclarées du module (ex: "database", "workers", "events").
    #[serde(default)]
    pub capabilities: Vec<String>,
}

fn default_manifest_version() -> u32 {
    CURRENT_MANIFEST_VERSION
}

impl ModuleManifest {
    /// Convertit le manifeste validé en `ModuleDescriptor` exploitable par le Runtime Core.
    pub fn to_descriptor(&self) -> Result<ModuleDescriptor, RuntimeError> {
        // Exécute la validation avant de construire le descripteur
        crate::manifest::validation::ManifestValidator::validate(self)?;

        let mut builder = ModuleDescriptor::builder(self.id.clone(), self.version.to_string())
            .name(&self.name)
            .capabilities(self.capabilities.clone());

        if let Some(ref desc) = self.description {
            builder = builder.description(desc);
        }

        for dep in &self.dependencies {
            builder = builder.dependency(dep.id.clone());
        }

        Ok(builder.build())
    }
}

impl TryFrom<ModuleManifest> for ModuleDescriptor {
    type Error = RuntimeError;

    fn try_from(manifest: ModuleManifest) -> Result<Self, Self::Error> {
        manifest.to_descriptor()
    }
}
