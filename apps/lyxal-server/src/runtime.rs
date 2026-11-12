//! Assemblage du runtime de Lyxal OS pour ce serveur : `LyxalRuntime` sur SurrealDB, modules
//! hébergés installés depuis leurs manifestes embarqués, puis démarrés.

use crate::{config::AppConfig, error::ServerError, modules};
use lyxal_event::EventWorkerConfig;
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{EventEngineConfig, LyxalRuntime, RuntimeConfig, SurrealRuntimeStore};
use std::{sync::Arc, time::Duration};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Runtime démarré et services de l'hôte.
pub struct Started {
    pub runtime: Arc<LyxalRuntime>,
    /// Service de connexion (routes `/auth/*`), absent sans clé applicative ou `auth.public_url`.
    pub auth: Option<Arc<modules::auth::AuthHost>>,
    /// Supports des fichiers (routes `/storage/*`).
    pub storage: Arc<lyxal_storage::Backends>,
}

/// Construit le runtime, installe le noyau et les modules hébergés, puis les démarre.
pub async fn start(config: &AppConfig, client: &Surreal<Any>) -> Result<Started, ServerError> {
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

    let report = runtime.install_packages(modules::packages()?).await?;
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

    modules::complete_services(&runtime, &services).await?;
    runtime.start_all().await?;
    Ok(Started {
        runtime: Arc::new(runtime),
        auth: services.auth,
        storage: services.storage,
    })
}
