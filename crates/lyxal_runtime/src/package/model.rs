use crate::error::RuntimeError;
use crate::manifest::parser::ManifestParser;
use crate::manifest::ModuleManifest;
use crate::module::LyxalModule;
use crate::resource::filesystem::FilesystemResourceProvider;
use crate::resource::ResourceProvider;
use crate::types::ModuleId;
use std::path::Path;
use std::sync::Arc;

/// Unité distribuable et encapsulée représentant un module Lyxal prêt pour le Runtime.
///
/// Cette abstraction découple totalement le chargement des ressources de tout système de fichiers
/// ou protocole de transport physique.
#[derive(Clone)]
pub struct ModulePackage {
    manifest: ModuleManifest,
    provider: Arc<dyn ResourceProvider>,
    module_impl: Option<Arc<dyn LyxalModule>>,
}

impl ModulePackage {
    /// Crée un nouveau package de module avec son manifeste et son fournisseur de ressources.
    pub fn new(manifest: ModuleManifest, provider: Arc<dyn ResourceProvider>) -> Self {
        Self {
            manifest,
            provider,
            module_impl: None,
        }
    }

    /// Associe l'implémentation Rust `LyxalModule` au package.
    pub fn with_module_impl(mut self, module_impl: Arc<dyn LyxalModule>) -> Self {
        self.module_impl = Some(module_impl);
        self
    }

    /// Charge un package de module depuis une arborescence locale sur disque.
    pub async fn from_filesystem(base_path: impl AsRef<Path>) -> Result<Self, RuntimeError> {
        let provider = Arc::new(FilesystemResourceProvider::new(base_path));
        let manifest_resource = provider.read_resource("manifest.toml").await?;
        let manifest = ManifestParser::parse_str(&manifest_resource.content)?;

        Ok(Self::new(manifest, provider))
    }

    /// Retourne l'identifiant canonique du module.
    pub fn id(&self) -> &ModuleId {
        &self.manifest.id
    }

    /// Retourne la version sémantique du module.
    pub fn version(&self) -> &semver::Version {
        &self.manifest.version
    }

    /// Retourne la référence au manifeste du module.
    pub fn manifest(&self) -> &ModuleManifest {
        &self.manifest
    }

    /// Retourne la référence au fournisseur de ressources.
    pub fn provider(&self) -> &Arc<dyn ResourceProvider> {
        &self.provider
    }

    /// Retourne l'implémentation Rust optionnelle du module.
    pub fn module_impl(&self) -> Option<&Arc<dyn LyxalModule>> {
        self.module_impl.as_ref()
    }
}
