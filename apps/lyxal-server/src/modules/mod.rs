//! Modules hébergés par le serveur : manifestes et fichiers SurrealQL embarqués à la compilation
//! (`build.rs`), implémentations `LyxalModule` et services propres à chaque module.

#[cfg(feature = "module-ingestion")]
mod ingestion;

use crate::error::ServerError;
use async_trait::async_trait;
use lyxal_event::EventContext;
use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{EmbeddedResourceProvider, ResourceProvider};
use lyxal_runtime::{
    LyxalModule, LyxalRuntime, ModuleContext, ModuleDescriptor, ModuleManifest, ModulePackage,
    RuntimeError,
};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Module embarqué : son manifeste et les fichiers déclarés dans `[resources]`.
pub struct EmbeddedModule {
    pub id: &'static str,
    pub manifest: &'static str,
    pub files: &'static [(&'static str, &'static str)],
}

include!(concat!(env!("OUT_DIR"), "/embedded_modules.rs"));

/// Modules installés avant le runtime, dont il a besoin pour sa propre persistance.
const FOUNDATION: [&str; 2] = ["lyxal_core", "lyxal_error"];

/// Module sans code Rust (SurrealQL uniquement) : son descripteur vient de son manifeste et ses
/// hooks n'ont rien à faire, l'installation de ses ressources étant assurée par le runtime.
pub struct ManifestModule {
    descriptor: ModuleDescriptor,
}

#[async_trait]
impl LyxalModule for ManifestModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

fn manifest(module: &EmbeddedModule) -> Result<ModuleManifest, ServerError> {
    ManifestParser::parse_str(module.manifest).map_err(|source| ServerError::Module {
        module: module.id.to_string(),
        message: source.to_string(),
    })
}

/// Installe `lyxal_core`, `lyxal_error` puis le schéma du runtime. Rejouable.
pub async fn install_foundation(client: &Surreal<Any>) -> Result<(), ServerError> {
    let mut manifests = Vec::new();
    for module in EMBEDDED_MODULES
        .iter()
        .filter(|m| FOUNDATION.contains(&m.id))
    {
        manifests.push((
            manifest(module)?,
            EmbeddedResourceProvider::new(module.files),
        ));
    }
    let batch: Vec<(&ModuleManifest, &dyn ResourceProvider)> = manifests
        .iter()
        .map(|(m, p)| (m, p as &dyn ResourceProvider))
        .collect();
    lyxal_runtime::schema::install_batch(client, &batch).await?;
    lyxal_runtime::schema::install_runtime_schema(client).await?;
    Ok(())
}

/// Packages de tous les modules hébergés, avec leur implémentation `LyxalModule`.
pub fn packages() -> Result<Vec<ModulePackage>, ServerError> {
    EMBEDDED_MODULES
        .iter()
        .map(|module| {
            let manifest = manifest(module)?;
            let implementation = implementation(module.id, &manifest)?;
            Ok(ModulePackage::new(
                manifest,
                Arc::new(EmbeddedResourceProvider::new(module.files)),
            )
            .with_module_impl(implementation))
        })
        .collect()
}

#[cfg_attr(not(feature = "module-ingestion"), allow(unused_variables))]
fn implementation(
    id: &str,
    manifest: &ModuleManifest,
) -> Result<Arc<dyn LyxalModule>, ServerError> {
    #[cfg(feature = "module-ingestion")]
    if id == ingestion::MODULE_ID {
        return Ok(ingestion::module());
    }
    Ok(Arc::new(ManifestModule {
        descriptor: manifest.to_descriptor()?,
    }))
}

/// Enregistre auprès du runtime les workers et sondes de santé des modules hébergés.
#[cfg_attr(not(feature = "module-ingestion"), allow(unused_variables))]
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    context: &EventContext,
) -> Result<(), ServerError> {
    #[cfg(feature = "module-ingestion")]
    ingestion::register_services(runtime, client, context)?;
    Ok(())
}
