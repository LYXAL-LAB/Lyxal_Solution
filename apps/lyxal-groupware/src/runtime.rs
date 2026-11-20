// SPDX-License-Identifier: AGPL-3.0-only

//! Assemblage du runtime de l'hôte : `LyxalRuntime` de l'hôte `lyxal_groupware` sur la base
//! partagée, socle sous bail, moteur d'événements de l'hôte (sans abonnement au lot 3), écoutes
//! inscrites comme workers de `lyxal_mail`, modules installés depuis leurs manifestes embarqués,
//! puis démarrés.

use crate::config::GroupwareConfig;
use crate::error::GroupwareError;
use crate::modules;
use crate::net::bind::BoundListener;
use crate::net::certificates::Certificates;
use crate::net::MailNet;
use lyxal_mail::net::{MailProtocol, SessionHandler, UnavailableHandler};
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{
    EventEngineConfig, LyxalRuntime, ModuleId, RuntimeConfig, SurrealRuntimeStore,
};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Runtime démarré et écoutes de l'hôte.
pub struct Started {
    pub runtime: Arc<LyxalRuntime>,
    pub mail: MailNet,
}

/// Session de chaque protocole au lot 3 : aucun protocole n'existe encore, chaque port répond
/// par un refus poli « service indisponible » (décision G3).
pub fn unavailable(protocol: MailProtocol) -> Arc<dyn SessionHandler> {
    Arc::new(UnavailableHandler::new(protocol))
}

/// Construit le runtime, installe le socle et les modules hébergés, inscrit les écoutes
/// `listeners` (déjà liées, servies avec les certificats `certificates`), puis démarre le tout.
pub async fn start(
    config: &GroupwareConfig,
    client: &Surreal<Any>,
    listeners: Vec<BoundListener>,
    certificates: Option<Arc<Certificates>>,
) -> Result<Started, GroupwareError> {
    start_with(config, client, listeners, certificates, &unavailable).await
}

/// `start`, avec la session de chaque protocole donnée par `handler_for` (protocoles d'essai
/// des tests).
pub async fn start_with(
    config: &GroupwareConfig,
    client: &Surreal<Any>,
    listeners: Vec<BoundListener>,
    certificates: Option<Arc<Certificates>>,
    handler_for: &dyn Fn(MailProtocol) -> Arc<dyn SessionHandler>,
) -> Result<Started, GroupwareError> {
    let timeouts = &config.runtime;
    let host = modules::host_id()?;
    // Chef des événements propre à cet hôte (bail `event_stream_lease:lyxal_groupware`), sans
    // abonnement au lot 3 (décision G4). `lyxal_event` est installé depuis son manifeste.
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

    // Écoutes : un worker par écoute, la relecture des certificats et la sonde de `lyxal_mail`
    let mail = MailNet::new(config, listeners, certificates, handler_for)?;
    for worker in mail.workers()? {
        runtime.register_worker(worker)?;
    }
    runtime
        .health_registry()
        .register_check(Arc::new(mail.health_check()))?;

    let report = runtime.install_packages(modules::packages()?).await?;
    if let Some(failure) = report.failed.first() {
        return Err(GroupwareError::ModuleInstall {
            module: failure.module_id.to_string(),
            message: failure.error.to_string(),
        });
    }
    if let Some(skipped) = report.not_attempted.first() {
        return Err(GroupwareError::ModuleInstall {
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
    Ok(Started {
        runtime: Arc::new(runtime),
        mail,
    })
}
