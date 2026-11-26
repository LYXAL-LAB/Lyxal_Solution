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
use lyxal_host::database::Database;
use lyxal_host::modules::{manifest, EmbeddedModule, ManifestModule};
use lyxal_runtime::resource::EmbeddedResourceProvider;
use lyxal_runtime::{
    FoundationInstallation, HostId, LyxalModule, LyxalRuntime, ModuleManifest, ModulePackage,
    NodeId,
};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

include!(concat!(env!("OUT_DIR"), "/embedded_modules.rs"));

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

/// Installe les seeds de l'hôte (droit d'administration de l'installation, tâches de fond et
/// leurs permissions), après l'installation des modules hébergés. Rejouable.
pub async fn install_host_seeds(client: &Surreal<Any>) -> Result<(), ServerError> {
    Ok(lyxal_host::modules::install_host_seeds(client, &SERVER_MODULE).await?)
}

/// Installe le socle (`lyxal_core`, `lyxal_error`, schéma du runtime) sous le bail d'installation
/// du socle, au nom du nœud `node`, puis les définitions d'erreurs `SERVER_*`. Rejouable.
///
/// Le socle est commun à tous les hôtes d'une même base : son empreinte ne couvre pas les
/// définitions `SERVER_*`, propres à ce binaire et installées à part.
pub async fn install_foundation(
    client: &Surreal<Any>,
    node: &NodeId,
) -> Result<FoundationInstallation, ServerError> {
    Ok(lyxal_host::modules::install_foundation(
        client,
        &host_id()?,
        node,
        EMBEDDED_MODULES,
        &SERVER_MODULE,
    )
    .await?)
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
    Ok(Arc::new(ManifestModule::new(manifest)?))
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
/// leur installation et le démarrage du runtime). Les stores de la session système reçoivent
/// le pool `database` ; les baux, la requête `LIVE` du fil et la session de l'agent de
/// synchronisation prennent sa connexion fixe.
pub async fn register_services(
    runtime: &LyxalRuntime,
    database: &Database,
    config: &AppConfig,
) -> Result<HostedServices, ServerError> {
    let crypto = crate::crypto::application_crypto(&config.crypto)?;
    let auth = auth::register_services(runtime, database, config, crypto.clone())?;
    i18n::register_services(runtime, database)?;
    let secrets = secrets::register_services(runtime, database, config)?;
    let storage = storage::register_services(runtime, database, config, secrets.file_keys())?;
    let scheduler = scheduler::register_services(runtime, database, config)?;
    tasks::register_handlers(
        &mut scheduler.handlers(),
        auth::purge(database),
        storage::cleanup(database, &storage),
        secrets.maintenance(),
    )?;
    let notification =
        notification::register_services(runtime, database, config, crypto, &secrets).await?;
    #[cfg(feature = "module-ingestion")]
    {
        let publication =
            ingestion::register_services(runtime, database, auth.as_ref(), &storage).await?;
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
    database: &Database,
    services: &HostedServices,
) -> Result<(), ServerError> {
    auth::complete_services(services.auth.as_ref()).await?;
    tasks::install(database, &services.scheduler).await?;
    scheduler::register_executors(runtime, &services.scheduler).await?;
    #[cfg(feature = "module-ingestion")]
    {
        ingestion::ensure_source_bucket(database).await?;
        ingestion::reconcile_publication(runtime, services.publication).await?;
    }
    notification::reconcile_subscriptions(runtime, services.notification_delivery).await?;
    Ok(())
}
