//! Modules hébergés par le serveur : manifestes et fichiers SurrealQL embarqués à la compilation
//! (`build.rs`), implémentations `LyxalModule` et services propres à chaque module.

pub mod auth;
mod i18n;
#[cfg(feature = "module-ingestion")]
mod ingestion;
mod notification;
pub mod secrets;
mod storage;

use crate::config::AppConfig;
use crate::error::ServerError;
use async_trait::async_trait;
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
    ManifestParser::parse_str(module.manifest).map_err(|source| ServerError::ModuleInstall {
        module: module.id.to_string(),
        message: source.to_string(),
    })
}

/// Manifeste de l'hôte et ses définitions d'erreurs `SERVER_*`.
const SERVER_MODULE: EmbeddedModule = EmbeddedModule {
    id: "lyxal_server",
    manifest: include_str!("../../manifest.toml"),
    files: &[(
        "error/server.surql",
        include_str!("../../error/server.surql"),
    )],
};

/// Installe `lyxal_core`, `lyxal_error`, les définitions d'erreurs de l'hôte, puis le schéma du
/// runtime. Rejouable.
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
    manifests.push((
        manifest(&SERVER_MODULE)?,
        EmbeddedResourceProvider::new(SERVER_MODULE.files),
    ));
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
    if id == auth::MODULE_ID {
        return Ok(auth::module());
    }
    if id == i18n::MODULE_ID {
        return Ok(i18n::module());
    }
    if id == notification::MODULE_ID {
        return Ok(notification::module());
    }
    if id == storage::MODULE_ID {
        return Ok(storage::module());
    }
    if id == secrets::MODULE_ID {
        return Ok(secrets::module());
    }
    #[cfg(feature = "module-ingestion")]
    if id == ingestion::MODULE_ID {
        return Ok(ingestion::module());
    }
    Ok(Arc::new(ManifestModule {
        descriptor: manifest.to_descriptor()?,
    }))
}

/// Services des modules hébergés à compléter après leur installation.
pub struct HostedServices {
    /// Service de connexion (routes `/auth/*`), si la configuration le permet.
    pub auth: Option<Arc<auth::AuthHost>>,
    /// Supports et antivirus des fichiers (routes `/storage/*`).
    pub storage: crate::context::StorageHost,
    /// Coffre-fort des secrets : client des modules hébergés qui liront leurs secrets.
    pub secrets: secrets::SecretsHost,
    #[cfg(feature = "module-ingestion")]
    publication: bool,
    /// Envoi des notifications configuré (clé applicative et relais SMTP).
    notification_delivery: bool,
}

/// Enregistre auprès du runtime les workers, consommateurs d'événements et sondes de santé des
/// modules hébergés (avant leur installation et le démarrage du runtime).
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
) -> Result<HostedServices, ServerError> {
    let crypto = crate::crypto::application_crypto(&config.crypto)?;
    let auth = auth::register_services(runtime, client, config, crypto.clone())?;
    i18n::register_services(runtime, client)?;
    let storage = storage::register_services(runtime, client, config)?;
    let secrets = secrets::register_services(runtime, client, config)?;
    let notification_delivery =
        notification::register_services(runtime, client, config, crypto).await?;
    #[cfg(feature = "module-ingestion")]
    {
        let publication =
            ingestion::register_services(runtime, client, auth.as_ref(), &storage).await?;
        Ok(HostedServices {
            auth,
            storage,
            secrets,
            publication,
            notification_delivery,
        })
    }
    #[cfg(not(feature = "module-ingestion"))]
    Ok(HostedServices {
        auth,
        storage,
        secrets,
        notification_delivery,
    })
}

/// Configuration qui dépend des modules installés (clés, accès, abonnements), avant le
/// démarrage.
pub async fn complete_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    services: &HostedServices,
) -> Result<(), ServerError> {
    #[cfg(not(feature = "module-ingestion"))]
    let _ = client;
    auth::complete_services(services.auth.as_ref()).await?;
    #[cfg(feature = "module-ingestion")]
    {
        ingestion::ensure_source_bucket(client).await?;
        ingestion::reconcile_publication(runtime, services.publication).await?;
    }
    notification::reconcile_subscriptions(runtime, services.notification_delivery).await?;
    Ok(())
}
