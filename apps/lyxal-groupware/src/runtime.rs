// SPDX-License-Identifier: AGPL-3.0-only

//! Assemblage du runtime de l'hôte : `LyxalRuntime` de l'hôte `lyxal_groupware` sur la base
//! partagée, socle sous bail, moteur d'événements de l'hôte (sans abonnement), services des
//! modules hébergés (coffre-fort, stockage, planificateur, courrier) et leurs sondes, écoutes
//! inscrites comme workers de `lyxal_mail`, modules installés depuis leurs manifestes embarqués,
//! refus de démarrer sans clé maîtresse si un bucket chiffré existe, tâche de maintenance du
//! courrier et exécuteurs du planificateur, puis démarrage.

use crate::config::GroupwareConfig;
use crate::error::GroupwareError;
use crate::modules;
use crate::net::bind::BoundListener;
use crate::net::certificates::Certificates;
use crate::net::MailNet;
use crate::services::{self, MailHost};
use lyxal_host::database::Database;
use lyxal_mail::net::{MailProtocol, MemoryBudget, SessionHandler, UnavailableHandler};
use lyxal_runtime::lock::SurrealInstallationLeaseManager;
use lyxal_runtime::{
    EventEngineConfig, LyxalRuntime, ModuleId, RuntimeConfig, SurrealRuntimeStore,
};
use std::sync::Arc;
use std::time::Duration;

/// Runtime démarré, écoutes de l'hôte et services du courrier.
pub struct Started {
    pub runtime: Arc<LyxalRuntime>,
    pub mail: MailNet,
    /// Dépôt, lecture et maintenance des messages (session système de l'hôte).
    pub services: MailHost,
}

/// Session d'un protocole qui n'existe pas encore (`imap`, `pop3`, `managesieve`) : refus poli
/// « service indisponible » (décision G3).
pub fn unavailable(protocol: MailProtocol) -> Arc<dyn SessionHandler> {
    Arc::new(UnavailableHandler::new(protocol))
}

/// Session de chaque protocole : réception SMTP (lot 5) pour `smtp`, dépôt authentifié (lot 6)
/// pour `submission`, refus poli pour les autres.
fn hosted(services: &MailHost, protocol: MailProtocol) -> Arc<dyn SessionHandler> {
    match (protocol, &services.smtp, &services.submission) {
        (MailProtocol::Smtp, Some(smtp), _) => Arc::new(smtp.clone()),
        (MailProtocol::Submission, _, Some(submission)) => Arc::new(submission.clone()),
        _ => unavailable(protocol),
    }
}

/// Construit le runtime, installe le socle et les modules hébergés, inscrit les écoutes
/// `listeners` (déjà liées, servies avec les certificats `certificates`), puis démarre le tout.
/// `database` : session système de l'hôte ; les stores des modules reçoivent le pool.
pub async fn start(
    config: &GroupwareConfig,
    database: &Database,
    listeners: Vec<BoundListener>,
    certificates: Option<Arc<Certificates>>,
) -> Result<Started, GroupwareError> {
    start_inner(config, database, listeners, certificates, None).await
}

/// `start`, avec la session de chaque protocole donnée par `handler_for` (protocoles d'essai
/// des tests).
pub async fn start_with(
    config: &GroupwareConfig,
    database: &Database,
    listeners: Vec<BoundListener>,
    certificates: Option<Arc<Certificates>>,
    handler_for: &dyn Fn(MailProtocol) -> Arc<dyn SessionHandler>,
) -> Result<Started, GroupwareError> {
    start_inner(config, database, listeners, certificates, Some(handler_for)).await
}

async fn start_inner(
    config: &GroupwareConfig,
    database: &Database,
    listeners: Vec<BoundListener>,
    certificates: Option<Arc<Certificates>>,
    handler_for: Option<&dyn Fn(MailProtocol) -> Arc<dyn SessionHandler>>,
) -> Result<Started, GroupwareError> {
    // Runtime, baux, moteur d'événements et installation : connexion fixe de la session système
    let client = database.fixed();
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

    // Services des modules hébergés : coffre-fort, stockage, planificateur, courrier
    // Budget mémoire des connexions, partagé par l'acceptation et la réception SMTP
    let budget = MemoryBudget::new(config.limits.memory_budget_bytes);
    let services = services::register_services(&runtime, database, config, &budget)?;

    // Écoutes : un worker par écoute, la relecture des certificats et la sonde de `lyxal_mail`
    // (service du courrier, puis écoutes)
    let mail = match handler_for {
        Some(handler_for) => MailNet::with_shared(
            config,
            listeners,
            certificates,
            budget,
            services.mail.blocks.clone(),
            handler_for,
        )?,
        None => MailNet::with_shared(
            config,
            listeners,
            certificates,
            budget,
            services.mail.blocks.clone(),
            &|protocol| hosted(&services.mail, protocol),
        )?,
    }
    .with_smtp_metrics(services.mail.smtp.clone())
    .with_submission_metrics(services.mail.submission.clone());
    for worker in mail.workers()? {
        runtime.register_worker(worker)?;
    }
    runtime.health_registry().register_check(Arc::new(
        mail.health_check()
            .with_service_probe(services.mail_probe.clone()),
    ))?;

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

    // Sans clé maîtresse, un bucket chiffré existant arrête tout : rien n'est démarré, les
    // écoutes liées sont refermées avec `mail`
    services::require_master_key(database, &services).await?;
    services::complete_services(&runtime, database, &services).await?;
    runtime.start_all().await?;
    Ok(Started {
        runtime: Arc::new(runtime),
        mail,
        services: services.mail,
    })
}
