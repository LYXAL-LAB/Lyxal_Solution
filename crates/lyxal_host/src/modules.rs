//! Modules embarqués dans le binaire d'un hôte (manifestes et fichiers SurrealQL inclus à la
//! compilation par `build::embed_modules`), module sans code Rust, installation du socle et des
//! définitions et seeds de l'hôte.

use crate::HostError;
use async_trait::async_trait;
use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{EmbeddedResourceProvider, ResourceProvider};
use lyxal_runtime::{
    FoundationInstallation, HostId, LyxalModule, ModuleContext, ModuleDescriptor, ModuleManifest,
    NodeId, RuntimeError,
};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Module embarqué : son manifeste et les fichiers déclarés dans `[resources]`.
pub struct EmbeddedModule {
    pub id: &'static str,
    pub manifest: &'static str,
    pub files: &'static [(&'static str, &'static str)],
}

/// Modules du socle, installés avant le runtime, dont il a besoin pour sa propre persistance.
pub const FOUNDATION: [&str; 2] = ["lyxal_core", "lyxal_error"];

/// Module sans code Rust (SurrealQL uniquement) : son descripteur vient de son manifeste et ses
/// hooks n'ont rien à faire, l'installation de ses ressources étant assurée par le runtime.
pub struct ManifestModule {
    descriptor: ModuleDescriptor,
}

impl ManifestModule {
    /// Module décrit par son manifeste.
    pub fn new(manifest: &ModuleManifest) -> Result<Self, RuntimeError> {
        Ok(Self {
            descriptor: manifest.to_descriptor()?,
        })
    }
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

/// Manifeste d'un module embarqué.
pub fn manifest(module: &EmbeddedModule) -> Result<ModuleManifest, HostError> {
    ManifestParser::parse_str(module.manifest).map_err(|source| HostError::ModuleInstall {
        module: module.id.to_string(),
        message: source.to_string(),
    })
}

/// Manifeste de l'hôte limité à ses seeds (`seeds`), ou sans eux : ses définitions d'erreurs
/// s'installent juste après le socle, ses seeds après les modules hébergés dont ils ont besoin.
fn host_manifest(host_module: &EmbeddedModule, seeds: bool) -> Result<ModuleManifest, HostError> {
    let mut manifest = manifest(host_module)?;
    if seeds {
        manifest.resources.error_definitions.clear();
    } else {
        manifest.resources.seeds.clear();
    }
    Ok(manifest)
}

/// Installe les seeds de l'hôte `host_module` (son manifeste et ses fichiers), après
/// l'installation des modules hébergés. Rejouable.
pub async fn install_host_seeds(
    client: &Surreal<Any>,
    host_module: &EmbeddedModule,
) -> Result<(), HostError> {
    lyxal_runtime::schema::install_resources(
        client,
        &host_manifest(host_module, true)?,
        &EmbeddedResourceProvider::new(host_module.files),
    )
    .await?;
    Ok(())
}

/// Installe le socle (`lyxal_core`, `lyxal_error` pris dans `embedded`, schéma du runtime) sous
/// le bail d'installation du socle, au nom du nœud `node` de l'hôte `host`, puis les définitions
/// d'erreurs de l'hôte (`host_module`). Rejouable.
///
/// Le socle est commun à tous les hôtes d'une même base : son empreinte ne couvre pas les
/// définitions d'erreurs de l'hôte, propres à chaque binaire et installées à part.
pub async fn install_foundation(
    client: &Surreal<Any>,
    host: &HostId,
    node: &NodeId,
    embedded: &[EmbeddedModule],
    host_module: &EmbeddedModule,
) -> Result<FoundationInstallation, HostError> {
    let mut manifests = Vec::new();
    for module in embedded.iter().filter(|m| FOUNDATION.contains(&m.id)) {
        manifests.push((
            manifest(module)?,
            EmbeddedResourceProvider::new(module.files),
        ));
    }
    let batch: Vec<(&ModuleManifest, &dyn ResourceProvider)> = manifests
        .iter()
        .map(|(m, p)| (m, p as &dyn ResourceProvider))
        .collect();
    let foundation = lyxal_runtime::schema::install_foundation(client, host, node, &batch).await?;
    lyxal_runtime::schema::install_resources(
        client,
        &host_manifest(host_module, false)?,
        &EmbeddedResourceProvider::new(host_module.files),
    )
    .await?;
    Ok(foundation)
}
