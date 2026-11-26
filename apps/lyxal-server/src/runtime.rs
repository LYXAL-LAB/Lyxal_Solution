//! Assemblage du runtime de Lyxal OS pour ce serveur : `LyxalRuntime` sur SurrealDB, modules
//! hébergés installés depuis leurs manifestes embarqués, puis démarrés ; runtime réduit à la
//! reprise d'une migration interrompue pour la ligne de commande (`recovery`).

use crate::{config::AppConfig, error::ServerError, modules};
use lyxal_host::database::Database;
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{
    EventEngineConfig, LyxalRuntime, ModuleId, ModulePackage, RuntimeConfig, SurrealRuntimeStore,
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
/// `database` : session système de l'hôte. Le runtime, ses baux, le moteur d'événements et
/// l'installation passent par sa connexion fixe ; les stores des modules reçoivent le pool.
pub async fn start(config: &AppConfig, database: &Database) -> Result<Started, ServerError> {
    start_with(config, database, Vec::new()).await
}

/// Runtime réduit à la reprise d'une migration interrompue (`LyxalRuntime::interrupted_migrations`
/// et `resolve_migration`), pour les commandes `runtime migrations` exécutées serveur arrêté.
///
/// Le socle (`lyxal_core`, `lyxal_error`, schéma et fonctions du runtime) est installé comme au
/// démarrage d'un serveur, sous le bail d'installation du socle, puis les définitions `SERVER_*` :
/// c'est la première étape de tout démarrage, rejouable et sans lien avec les modules hébergés,
/// et elle garantit que les fonctions de reprise et les définitions d'erreurs présentes en base
/// sont celles de ce binaire (une base qui porte déjà l'empreinte de ce socle n'est pas
/// réinstallée). Aucun module hébergé n'est installé ni démarré : la commande reste utilisable
/// quand l'installation d'un module est refusée.
///
/// Comme un serveur, le processus reçoit un identifiant de nœud propre (`NodeId::generate`) :
/// il prend le bail d'installation comme un nœud distinct, refusé tant qu'un autre le détient.
pub async fn recovery(client: &Surreal<Any>) -> Result<LyxalRuntime, ServerError> {
    let runtime = LyxalRuntime::new(RuntimeConfig::new(modules::host_id()?));
    let foundation = modules::install_foundation(client, runtime.node_id()).await?;
    Ok(runtime
        .with_foundation_checksum(foundation.checksum)
        .with_client(client.clone()))
}

/// `start`, avec des packages ajoutés aux modules embarqués (modules d'essai des tests).
pub async fn start_with(
    config: &AppConfig,
    database: &Database,
    additional: Vec<ModulePackage>,
) -> Result<Started, ServerError> {
    let client = database.fixed();
    let timeouts = &config.runtime;
    let host = modules::host_id()?;
    // Le chef des événements de cet hôte ne sert que les abonnements de `lyxal_server` (bail
    // `event_stream_lease:lyxal_server`). Le filtre `instance_id` reste vide : les événements
    // émis par la base (`DEFINE EVENT`) portent le contexte `default`.
    // `lyxal_event` est installé comme les autres modules, depuis son manifeste.
    let event_config = EventEngineConfig::new(&host).with_auto_init_schema(false);
    let runtime_config = RuntimeConfig::new(host)
        .with_install_timeout(Duration::from_secs(timeouts.module_install_timeout_seconds))
        .with_start_timeout(Duration::from_secs(timeouts.module_start_timeout_seconds))
        .with_stop_timeout(Duration::from_secs(timeouts.module_stop_timeout_seconds));
    let runtime = LyxalRuntime::new(runtime_config);
    let foundation = modules::install_foundation(client, runtime.node_id()).await?;
    let runtime = runtime
        .with_foundation_checksum(foundation.checksum)
        .with_event_config(event_config)
        .with_client(client.clone())
        .with_store(Arc::new(SurrealRuntimeStore::new(client.clone())))
        .with_installation_lease_manager(Arc::new(SurrealInstallationLeaseManager::new(
            client.clone(),
        )));

    // Sonde du socle, rattachée à `lyxal_core` : « dégradé » si un autre binaire l'a remplacé
    runtime.health_registry().register_check(Arc::new(
        runtime.foundation_health_check(ModuleId::new(lyxal_host::modules::FOUNDATION[0])),
    ))?;

    let services = modules::register_services(&runtime, database, config).await?;

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

    modules::complete_services(&runtime, database, &services).await?;
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
