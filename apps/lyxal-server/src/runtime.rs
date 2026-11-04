//! Assemblage du runtime de Lyxal OS pour ce serveur : `LyxalRuntime` sur SurrealDB, modules
//! hébergés installés depuis leurs manifestes embarqués, puis démarrés.

use crate::{config::AppConfig, error::ServerError, modules};
use lyxal_event::{EventContext, EventWorkerConfig};
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{EventEngineConfig, LyxalRuntime, RuntimeConfig, SurrealRuntimeStore};
use std::{sync::Arc, time::Duration};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Construit le runtime, installe le noyau et les modules hébergés, puis les démarre.
pub async fn start(
    config: &AppConfig,
    client: &Surreal<Any>,
) -> Result<Arc<LyxalRuntime>, ServerError> {
    modules::install_foundation(client).await?;

    let timeouts = &config.runtime;
    let runtime_config = RuntimeConfig::new()
        .with_install_timeout(Duration::from_secs(timeouts.module_install_timeout_seconds))
        .with_start_timeout(Duration::from_secs(timeouts.module_start_timeout_seconds))
        .with_stop_timeout(Duration::from_secs(timeouts.module_stop_timeout_seconds));
    let event_config = EventEngineConfig {
        worker_config: EventWorkerConfig {
            instance_id: Some(config.application.instance_id.clone()),
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

    let event_context = EventContext::new(
        config.application.instance_id.clone(),
        config.database.namespace.clone(),
        config.database.database.clone(),
    );
    modules::register_services(&runtime, client, &event_context)?;

    let report = runtime.install_packages(modules::packages()?).await?;
    if let Some(failure) = report.failed.first() {
        return Err(ServerError::Module {
            module: failure.module_id.to_string(),
            message: failure.error.to_string(),
        });
    }
    if let Some(skipped) = report.not_attempted.first() {
        return Err(ServerError::Module {
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

    runtime.start_all().await?;
    Ok(Arc::new(runtime))
}
