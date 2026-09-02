use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Représentation persistée de l'identité stable d'un module dans la table `system_module`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct StoredModule {
    /// Identifiant canonique du module (ex: "lyxal-calendar").
    pub module_id: ModuleId,
    /// Nom lisible du module.
    pub name: String,
    /// Description optionnelle du module.
    #[serde(default)]
    pub description: Option<String>,
    /// Horodatage de première découverte / enregistrement.
    #[serde(default)]
    pub created_at: Option<String>,
    /// Horodatage de dernière modification des métadonnées.
    #[serde(default)]
    pub updated_at: Option<String>,
}

impl StoredModule {
    /// Crée un nouvel enregistrement de module.
    pub fn new(module_id: impl Into<ModuleId>, name: impl Into<String>) -> Self {
        Self {
            module_id: module_id.into(),
            name: name.into(),
            description: None,
            created_at: None,
            updated_at: None,
        }
    }

    /// Associe une description au module.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = Some(description.into());
        self
    }
}

/// Représentation persistée d'une release spécifique de module dans la table `system_module_release`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct StoredModuleRelease {
    /// Module propriétaire de cette release.
    pub module_id: ModuleId,
    /// Version sémantique de la release (ex: "1.2.0").
    pub version: String,
    /// Version du format de manifeste.
    pub manifest_version: u32,
    /// Description optionnelle de la release.
    #[serde(default)]
    pub description: Option<String>,
    /// Statut persistant de la release (ex: "Discovered", "Installing", "Installed", "Active", "Inactive", "Failed").
    pub status: String,
    /// Somme de contrôle optionnelle de l'archive / du package.
    #[serde(default)]
    pub checksum: Option<String>,
    /// Phase d'installation courante pour checkpoint / reprise (ex: "Schema", "Migration", "InstallHook", "Complete").
    #[serde(default)]
    pub installation_phase: Option<String>,
    /// Horodatage de découverte de la release.
    #[serde(default)]
    pub created_at: Option<String>,
    /// Horodatage d'installation effective.
    #[serde(default)]
    pub installed_at: Option<String>,
}

impl StoredModuleRelease {
    /// Crée un nouvel enregistrement de release pour un module.
    pub fn new(
        module_id: impl Into<ModuleId>,
        version: impl Into<String>,
        manifest_version: u32,
        status: impl Into<String>,
    ) -> Self {
        Self {
            module_id: module_id.into(),
            version: version.into(),
            manifest_version,
            description: None,
            status: status.into(),
            checksum: None,
            installation_phase: None,
            created_at: None,
            installed_at: None,
        }
    }

    /// Associe une description à la release.
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = Some(description.into());
        self
    }

    /// Associe une somme de contrôle du package à la release.
    pub fn with_checksum(mut self, checksum: impl Into<String>) -> Self {
        self.checksum = Some(checksum.into());
        self
    }

    /// Associe une phase d'installation checkpointée à la release.
    pub fn with_installation_phase(mut self, phase: impl Into<String>) -> Self {
        self.installation_phase = Some(phase.into());
        self
    }
}
