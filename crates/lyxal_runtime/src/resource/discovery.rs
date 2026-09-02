use crate::error::RuntimeError;
use crate::resource::kind::ResourceKind;
use crate::resource::model::ModuleResource;
use crate::resource::provider::ResourceProvider;

/// Moteur de découverte des ressources SurrealQL d'un module.
pub struct ResourceDiscovery;

impl ResourceDiscovery {
    /// Découvre l'ensemble des fichiers déclaratifs de schéma dans `schema/` et les ordonne selon l'ordre officiel :
    /// `Tables -> Fields -> Indexes -> Functions -> Permissions -> Events -> Seeds`.
    pub async fn discover_schema_resources(
        provider: &dyn ResourceProvider,
    ) -> Result<Vec<ModuleResource>, RuntimeError> {
        let expected_schema_files = [
            ("schema/tables.surql", ResourceKind::Tables),
            ("schema/fields.surql", ResourceKind::Fields),
            ("schema/indexes.surql", ResourceKind::Indexes),
            ("schema/functions.surql", ResourceKind::Functions),
            ("schema/permissions.surql", ResourceKind::Permissions),
            ("schema/events.surql", ResourceKind::Events),
            ("schema/seeds.surql", ResourceKind::Seeds),
        ];

        let mut discovered = Vec::new();
        let mut seen_paths = std::collections::HashSet::new();

        for (path, expected_kind) in expected_schema_files {
            if provider.exists(path).await {
                let mut res = provider.read_resource(path).await?;
                res.kind = expected_kind;
                seen_paths.insert(path.to_string());
                discovered.push(res);
            }
        }

        // Scanner également les ressources potentielles dans les sous-dossiers de schema/
        if let Ok(schema_files) = provider.list_resources("schema").await {
            for path in schema_files {
                if !seen_paths.contains(&path) && path.ends_with(".surql") {
                    if let Some(kind) = ResourceKind::from_filename(&path) {
                        let mut res = provider.read_resource(&path).await?;
                        res.kind = kind;
                        seen_paths.insert(path);
                        discovered.push(res);
                    }
                }
            }
        }

        // Tri explicite selon la priorité d'exécution
        discovered.sort_by_key(|r| r.kind.execution_order());

        Ok(discovered)
    }

    /// Découvre l'ensemble des scripts de migration situés dans `migrations/*.surql`.
    pub async fn discover_migration_resources(
        provider: &dyn ResourceProvider,
    ) -> Result<Vec<ModuleResource>, RuntimeError> {
        let resource_paths = provider.list_resources("migrations").await?;
        let mut migrations = Vec::new();

        for path in resource_paths {
            if path.ends_with(".surql") {
                let res = provider.read_resource(&path).await?;
                migrations.push(res);
            }
        }

        Ok(migrations)
    }
}
