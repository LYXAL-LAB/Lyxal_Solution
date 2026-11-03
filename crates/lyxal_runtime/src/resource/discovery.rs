use crate::error::RuntimeError;
use crate::manifest::ModuleManifest;
use crate::resource::kind::ResourceKind;
use crate::resource::model::ModuleResource;
use crate::resource::provider::ResourceProvider;

/// Lecture des ressources déclarées dans `[resources]` du manifeste.
pub struct ResourceDiscovery;

impl ResourceDiscovery {
    /// Ressources à installer, dans l'ordre des phases (`schemas`, `functions`,
    /// `error_definitions`, `events`, `seeds`) puis dans l'ordre déclaré. Un fichier déclaré mais
    /// absent est une erreur.
    pub async fn install_resources(
        manifest: &ModuleManifest,
        provider: &dyn ResourceProvider,
    ) -> Result<Vec<ModuleResource>, RuntimeError> {
        let declared = &manifest.resources;
        let phases = [
            (ResourceKind::Schema, &declared.schemas),
            (ResourceKind::Function, &declared.functions),
            (ResourceKind::ErrorDefinition, &declared.error_definitions),
            (ResourceKind::Event, &declared.events),
            (ResourceKind::Seed, &declared.seeds),
        ];
        let mut resources = Vec::new();
        for (kind, paths) in phases {
            for path in paths {
                let content = provider.read(path).await?;
                resources.push(ModuleResource::new(path.clone(), kind, content));
            }
        }
        Ok(resources)
    }

    /// Migrations déclarées dans `resources.migrations`, dans l'ordre déclaré.
    pub async fn migration_resources(
        manifest: &ModuleManifest,
        provider: &dyn ResourceProvider,
    ) -> Result<Vec<ModuleResource>, RuntimeError> {
        let mut migrations = Vec::new();
        for path in &manifest.resources.migrations {
            let content = provider.read(path).await?;
            migrations.push(ModuleResource::new(
                path.clone(),
                ResourceKind::Migration,
                content,
            ));
        }
        Ok(migrations)
    }
}
