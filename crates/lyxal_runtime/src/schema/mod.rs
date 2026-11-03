pub mod importer;
pub mod plan;

pub use importer::{SchemaImportResult, SchemaImporter};
pub use plan::SchemaImportPlan;

use crate::error::RuntimeError;
use crate::manifest::{ManifestParser, ModuleManifest};
use crate::resource::{EmbeddedResourceProvider, ResourceProvider};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Installe les ressources déclarées dans `[resources]` d'un module (`schemas`, `functions`,
/// `error_definitions`, `events`, `seeds`), dans l'ordre du manifeste. Rejouable : chaque
/// ressource doit être idempotente (`OVERWRITE`, seeds protégés par `record::exists`).
pub async fn install_resources(
    client: &Surreal<Any>,
    manifest: &ModuleManifest,
    provider: &dyn ResourceProvider,
) -> Result<SchemaImportResult, RuntimeError> {
    let plan = SchemaImportPlan::from_manifest(manifest, provider).await?;
    SchemaImporter::new(client.clone())
        .execute_plan(&plan)
        .await
}

/// Installe un module à partir de son manifeste et de ses fichiers embarqués dans le binaire
/// (par exemple `lyxal_event::MANIFEST` et `lyxal_event::EMBEDDED_RESOURCES`).
pub async fn install_embedded(
    client: &Surreal<Any>,
    manifest: &str,
    files: &'static [(&'static str, &'static str)],
) -> Result<SchemaImportResult, RuntimeError> {
    let manifest = ManifestParser::parse_str(manifest)?;
    install_resources(client, &manifest, &EmbeddedResourceProvider::new(files)).await
}

/// Installe plusieurs modules phase par phase : les `schemas` de tous les modules, puis leurs
/// `functions`, leurs `error_definitions`, leurs `events` et leurs `seeds`. Dans chaque phase,
/// les modules suivent l'ordre donné (ordre des dépendances).
///
/// Nécessaire pour installer `lyxal_core` avec `lyxal_error` : les définitions d'erreurs de
/// `lyxal_core` vont dans la table `error_definition` de `lyxal_error`, qui dépend elle-même de
/// `lyxal_core`.
pub async fn install_batch(
    client: &Surreal<Any>,
    modules: &[(&ModuleManifest, &dyn ResourceProvider)],
) -> Result<Vec<SchemaImportResult>, RuntimeError> {
    use crate::resource::{ResourceDiscovery, ResourceKind};

    let mut plans = Vec::new();
    for (manifest, provider) in modules {
        let resources = ResourceDiscovery::install_resources(manifest, *provider).await?;
        plans.push((manifest.id.clone(), resources));
    }
    let importer = SchemaImporter::new(client.clone());
    let mut results = Vec::new();
    for kind in [
        ResourceKind::Schema,
        ResourceKind::Function,
        ResourceKind::ErrorDefinition,
        ResourceKind::Event,
        ResourceKind::Seed,
    ] {
        for (module_id, resources) in &plans {
            let phase: Vec<_> = resources
                .iter()
                .filter(|r| r.kind == kind)
                .cloned()
                .collect();
            if phase.is_empty() {
                continue;
            }
            let plan = SchemaImportPlan::new(module_id.clone(), phase);
            results.push(importer.execute_plan(&plan).await?);
        }
    }
    Ok(results)
}
