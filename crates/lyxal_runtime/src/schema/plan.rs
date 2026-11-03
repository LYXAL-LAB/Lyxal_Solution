use crate::error::RuntimeError;
use crate::manifest::ModuleManifest;
use crate::resource::discovery::ResourceDiscovery;
use crate::resource::model::ModuleResource;
use crate::resource::provider::ResourceProvider;
use crate::types::ModuleId;

/// Plan déterministe d'importation des ressources de schéma d'un module.
///
/// Les ressources sont celles de `[resources]`, dans l'ordre des phases du manifeste
/// (`schemas`, `functions`, `error_definitions`, `events`, `seeds`).
#[derive(Debug, Clone)]
pub struct SchemaImportPlan {
    pub module_id: ModuleId,
    pub resources: Vec<ModuleResource>,
}

impl SchemaImportPlan {
    /// Crée un plan d'importation ; le tri par phase est stable et conserve l'ordre déclaré.
    pub fn new(module_id: ModuleId, mut resources: Vec<ModuleResource>) -> Self {
        resources.sort_by_key(|r| r.kind);
        Self {
            module_id,
            resources,
        }
    }

    /// Construit le plan d'importation à partir de `[resources]` du manifeste.
    pub async fn from_manifest(
        manifest: &ModuleManifest,
        provider: &dyn ResourceProvider,
    ) -> Result<Self, RuntimeError> {
        let resources = ResourceDiscovery::install_resources(manifest, provider).await?;
        Ok(Self::new(manifest.id.clone(), resources))
    }

    /// Indique si le plan ne contient aucune ressource.
    pub fn is_empty(&self) -> bool {
        self.resources.is_empty()
    }

    /// Nombre de ressources incluses dans le plan.
    pub fn len(&self) -> usize {
        self.resources.len()
    }

    /// Retourne la tranche des ressources ordonnées.
    pub fn resources(&self) -> &[ModuleResource] {
        &self.resources
    }
}
