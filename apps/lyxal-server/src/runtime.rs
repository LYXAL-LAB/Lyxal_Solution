//! Assemblage du runtime de Lyxal OS pour ce serveur : `LyxalRuntime` sur SurrealDB, modules
//! hébergés installés depuis leurs manifestes embarqués, puis démarrés ; runtime réduit à la
//! reprise d'une migration interrompue pour la ligne de commande (`recovery`).

use crate::{config::AppConfig, error::ServerError, modules};
use lyxal_event::EventWorkerConfig;
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{
    EventEngineConfig, LyxalRuntime, ModulePackage, RuntimeConfig, SurrealRuntimeStore,
};
use std::{sync::Arc, time::Duration};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Runtime démarré et services de l'hôte.
pub struct Started {
    pub runtime: Arc<LyxalRuntime>,
    /// Service de connexion (routes `/auth/*`), absent sans clé applicative ou `auth.public_url`.
    pub auth: Option<Arc<modules::auth::AuthHost>>,
    /// Supports et antivirus des fichiers (routes `/storage/*`).
    pub storage: crate::context::StorageHost,
    /// Coffre-fort des secrets : client des modules hébergés qui liront leurs secrets.
    pub secrets: modules::secrets::SecretsHost,
    /// Planificateur : registre des handlers des modules hébergés, files servies.
    pub scheduler: modules::scheduler::SchedulerHost,
    /// Notifications : session système et liens de désabonnement (routes `/notification/*`).
    pub notification: modules::notification::NotificationHost,
}

/// Construit le runtime, installe le noyau et les modules hébergés, puis les démarre.
pub async fn start(config: &AppConfig, client: &Surreal<Any>) -> Result<Started, ServerError> {
    start_with(config, client, Vec::new()).await
}

/// Runtime réduit à la reprise d'une migration interrompue (`LyxalRuntime::interrupted_migrations`
/// et `resolve_migration`), pour les commandes `runtime migrations` exécutées serveur arrêté.
///
/// Le socle (`lyxal_core`, `lyxal_error`, définitions `SERVER_*`, schéma et fonctions du runtime)
/// est réinstallé : c'est la première étape de tout démarrage, rejouable et sans lien avec les
/// modules hébergés, et elle garantit que les fonctions de reprise et les définitions d'erreurs
/// présentes en base sont celles de ce binaire. Aucun module hébergé n'est installé ni démarré :
/// la commande reste utilisable quand l'installation d'un module est refusée.
///
/// Comme un serveur, le processus reçoit un identifiant de nœud propre (`NodeId::generate`) :
/// il prend le bail d'installation comme un nœud distinct, refusé tant qu'un autre le détient.
pub async fn recovery(client: &Surreal<Any>) -> Result<LyxalRuntime, ServerError> {
    modules::install_foundation(client).await?;
    Ok(LyxalRuntime::new(RuntimeConfig::new()).with_client(client.clone()))
}

/// `start`, avec des packages ajoutés aux modules embarqués (modules d'essai des tests).
pub async fn start_with(
    config: &AppConfig,
    client: &Surreal<Any>,
    additional: Vec<ModulePackage>,
) -> Result<Started, ServerError> {
    modules::install_foundation(client).await?;

    let timeouts = &config.runtime;
    let runtime_config = RuntimeConfig::new()
        .with_install_timeout(Duration::from_secs(timeouts.module_install_timeout_seconds))
        .with_start_timeout(Duration::from_secs(timeouts.module_start_timeout_seconds))
        .with_stop_timeout(Duration::from_secs(timeouts.module_stop_timeout_seconds));
    let event_config = EventEngineConfig {
        // Le worker traite toutes les livraisons de la base de l'instance : les événements émis
        // par la base (`DEFINE EVENT`) ne connaissent pas l'instance hôte (contexte `default`),
        // et chaque instance a sa propre base (`database.namespace` / `database.database`).
        worker_config: EventWorkerConfig {
            instance_id: None,
            ..EventWorkerConfig::default()
        },
        // `lyxal_event` est installé comme les autres modules, depuis son manifeste.
        auto_init_schema: false,
        ..EventEngineConfig::default()
    };
    let runtime = LyxalRuntime::new(runtime_config)
        .with_event_config(event_config)
        .with_client(client.clone())
        .with_store(Arc::new(SurrealRuntimeStore::new(client.clone())))
        .with_installation_lease_manager(Arc::new(SurrealInstallationLeaseManager::new(
            client.clone(),
        )));

    let services = modules::register_services(&runtime, client, config).await?;

    let mut packages = modules::packages(client)?;
    packages.extend(additional);
    let report = runtime.install_packages(packages).await?;
    if let Some(failure) = report.failed.first() {
        return Err(ServerError::ModuleInstall {
            module: failure.module_id.to_string(),
            message: failure.error.to_string(),
        });
    }
    if let Some(skipped) = report.not_attempted.first() {
        return Err(ServerError::ModuleInstall {
            module: skipped.module_id.to_string(),
            message: format!(
                "non installé : la dépendance {} a échoué",
                skipped.failed_dependency
            ),
        });
    }
    tracing::info!(
        installed = ?report.installed,
        already_installed = ?report.already_installed,
        "modules installés"
    );

    modules::complete_services(&runtime, client, &services).await?;
    runtime.start_all().await?;
    Ok(Started {
        runtime: Arc::new(runtime),
        auth: services.auth,
        storage: services.storage,
        secrets: services.secrets,
        scheduler: services.scheduler,
        notification: services.notification,
    })
}
