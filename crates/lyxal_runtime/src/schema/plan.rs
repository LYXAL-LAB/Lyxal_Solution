use crate::error::RuntimeError;
use crate::resource::discovery::ResourceDiscovery;
use crate::resource::model::ModuleResource;
use crate::resource::provider::ResourceProvider;
use crate::types::ModuleId;

/// Plan déterministe d'importation des ressources de schéma d'un module.
///
/// Les ressources sont ordonnées strictement selon l'ordre officiel :
/// `Tables -> Fields -> Indexes -> Functions -> Permissions -> Events -> Seeds`.
#[derive(Debug, Clone)]
pub struct SchemaImportPlan {
    pub module_id: ModuleId,
    pub resources: Vec<ModuleResource>,
}

impl SchemaImportPlan {
    /// Crée un plan d'importation à partir d'une liste de ressources (les trie automatiquement).
    pub fn new(module_id: ModuleId, mut resources: Vec<ModuleResource>) -> Self {
        resources.sort_by_key(|r| r.kind.execution_order());
        Self {
            module_id,
            resources,
        }
    }

    /// Construit le plan d'importation en découvrant les ressources d'un `ResourceProvider`.
    pub async fn from_provider(
        module_id: ModuleId,
        provider: &dyn ResourceProvider,
    ) -> Result<Self, RuntimeError> {
        let resources = ResourceDiscovery::discover_schema_resources(provider).await?;
        Ok(Self::new(module_id, resources))
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
