//! Modules hébergés par le serveur : manifestes et fichiers SurrealQL embarqués à la compilation
//! (`build.rs`), implémentations `LyxalModule` et services propres à chaque module.

pub mod auth;
mod i18n;
#[cfg(feature = "module-ingestion")]
mod ingestion;
pub mod notification;
pub mod notification_feed;
pub mod scheduler;
pub mod secrets;
mod storage;
pub mod tasks;

use crate::config::AppConfig;
use crate::error::ServerError;
use async_trait::async_trait;
use lyxal_runtime::manifest::ManifestParser;
use lyxal_runtime::resource::{EmbeddedResourceProvider, ResourceProvider};
use lyxal_runtime::{
    FoundationInstallation, HostId, LyxalModule, LyxalRuntime, ModuleContext, ModuleDescriptor,
    ModuleManifest, ModulePackage, NodeId, RuntimeError,
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

/// Modules du socle, installés avant le runtime, dont il a besoin pour sa propre persistance.
pub const FOUNDATION: [&str; 2] = ["lyxal_core", "lyxal_error"];

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

/// Nom de l'hôte : le rôle de ce binaire, le même pour toutes ses copies, égal à l'`id` de son
/// manifeste. Constante du code, non réglable par configuration.
pub const HOST_ID: &str = "lyxal_server";

/// Hôte de ce binaire pour le runtime.
pub fn host_id() -> Result<HostId, ServerError> {
    Ok(HostId::new(HOST_ID)?)
}

/// Manifeste de l'hôte, ses définitions d'erreurs `SERVER_*` et ses seeds (droit d'administration
/// de l'installation, tâches de fond confiées à `lyxal_scheduler`).
const SERVER_MODULE: EmbeddedModule = EmbeddedModule {
    id: HOST_ID,
    manifest: include_str!("../../manifest.toml"),
    files: &[
        (
            "error/server.surql",
            include_str!("../../error/server.surql"),
        ),
        (
            "seeds/server_permissions.surql",
            include_str!("../../seeds/server_permissions.surql"),
        ),
        (
            "seeds/server_tasks.surql",
            include_str!("../../seeds/server_tasks.surql"),
        ),
    ],
};

/// Manifeste de l'hôte limité à ses seeds (`seeds`), ou sans eux : ses définitions d'erreurs
/// s'installent juste après le socle, ses seeds après les modules hébergés dont ils ont besoin.
fn server_manifest(seeds: bool) -> Result<ModuleManifest, ServerError> {
    let mut manifest = manifest(&SERVER_MODULE)?;
    if seeds {
        manifest.resources.error_definitions.clear();
    } else {
        manifest.resources.seeds.clear();
    }
    Ok(manifest)
}

/// Installe les seeds de l'hôte (droit d'administration de l'installation, tâches de fond et
/// leurs permissions), après l'installation des modules hébergés. Rejouable.
pub async fn install_host_seeds(client: &Surreal<Any>) -> Result<(), ServerError> {
    lyxal_runtime::schema::install_resources(
        client,
        &server_manifest(true)?,
        &EmbeddedResourceProvider::new(SERVER_MODULE.files),
    )
    .await?;
    Ok(())
}

/// Installe le socle (`lyxal_core`, `lyxal_error`, schéma du runtime) sous le bail d'installation
/// du socle, au nom du nœud `node`, puis les définitions d'erreurs de l'hôte. Rejouable.
///
/// Le socle est commun à tous les hôtes d'une même base : son empreinte ne couvre pas les
/// définitions `SERVER_*`, propres à ce binaire et installées à part.
pub async fn install_foundation(
    client: &Surreal<Any>,
    node: &NodeId,
) -> Result<FoundationInstallation, ServerError> {
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
    let foundation =
        lyxal_runtime::schema::install_foundation(client, &host_id()?, node, &batch).await?;
    lyxal_runtime::schema::install_resources(
        client,
        &server_manifest(false)?,
        &EmbeddedResourceProvider::new(SERVER_MODULE.files),
    )
    .await?;
    Ok(foundation)
}

/// Packages de tous les modules hébergés, avec leur implémentation `LyxalModule` (sur la session
/// système de l'hôte `client` pour ceux dont l'installation écrit en base).
pub fn packages(client: &Surreal<Any>) -> Result<Vec<ModulePackage>, ServerError> {
    EMBEDDED_MODULES
        .iter()
        .map(|module| {
            let manifest = manifest(module)?;
            let implementation = implementation(module.id, &manifest, client)?;
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
    client: &Surreal<Any>,
) -> Result<Arc<dyn LyxalModule>, ServerError> {
    if id == auth::MODULE_ID {
        return Ok(auth::module());
    }
    if id == i18n::MODULE_ID {
        return Ok(i18n::module());
    }
    if id == notification::MODULE_ID {
        return Ok(notification::module(client));
    }
    if id == storage::MODULE_ID {
        return Ok(storage::module());
    }
    if id == secrets::MODULE_ID {
        return Ok(secrets::module());
    }
    if id == scheduler::MODULE_ID {
        return Ok(scheduler::module());
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
    /// Planificateur : registre des handlers ouvert aux modules hébergés, exécuteurs par file.
    pub scheduler: scheduler::SchedulerHost,
    /// Notifications : session système et liens de désabonnement (routes `/notification/*`).
    pub notification: notification::NotificationHost,
    #[cfg(feature = "module-ingestion")]
    publication: bool,
    /// Envoi des notifications configuré (clé applicative et clé maîtresse du coffre-fort).
    notification_delivery: bool,
}

/// Enregistre auprès du runtime les workers, consommateurs d'événements et sondes de santé des
/// modules hébergés, et inscrit les handlers des tâches de fond de l'hôte au planificateur (avant
/// leur installation et le démarrage du runtime).
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
    let scheduler = scheduler::register_services(runtime, client, config)?;
    tasks::register_handlers(
        &mut scheduler.handlers(),
        auth::purge(client),
        storage::cleanup(client, &storage),
        secrets.maintenance(),
    )?;
    let notification =
        notification::register_services(runtime, client, config, crypto, &secrets).await?;
    #[cfg(feature = "module-ingestion")]
    {
        let publication =
            ingestion::register_services(runtime, client, auth.as_ref(), &storage).await?;
        Ok(HostedServices {
            auth,
            storage,
            secrets,
            scheduler,
            notification: notification.host,
            publication,
            notification_delivery: notification.delivery,
        })
    }
    #[cfg(not(feature = "module-ingestion"))]
    Ok(HostedServices {
        auth,
        storage,
        secrets,
        scheduler,
        notification: notification.host,
        notification_delivery: notification.delivery,
    })
}

/// Configuration qui dépend des modules installés (clés, accès, tâches de fond et leurs
/// planifications, abonnements), avant le démarrage.
pub async fn complete_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    services: &HostedServices,
) -> Result<(), ServerError> {
    auth::complete_services(services.auth.as_ref()).await?;
    tasks::install(client, &services.scheduler).await?;
    scheduler::register_executors(runtime, &services.scheduler).await?;
    #[cfg(feature = "module-ingestion")]
    {
        ingestion::ensure_source_bucket(client).await?;
        ingestion::reconcile_publication(runtime, services.publication).await?;
    }
    notification::reconcile_subscriptions(runtime, services.notification_delivery).await?;
    Ok(())
}
