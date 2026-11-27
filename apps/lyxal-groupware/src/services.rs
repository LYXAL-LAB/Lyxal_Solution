// SPDX-License-Identifier: AGPL-3.0-only

//! Services des modules hébergés (décision M13 du lot 4) : coffre-fort (clé maîtresse et clés
//! des fichiers), supports de stockage et antivirus, planificateur (planificateur élu,
//! exécuteurs, registre des handlers), courrier (dépôt, lecture, maintenance) et leurs sondes.
//!
//! La maintenance de `lyxal_mail` est une tâche `handler` de `lyxal_scheduler`
//! (`mail.maintenance`, `seeds/groupware_tasks.surql`) : seul un nœud de cet hôte a son code, et
//! donc la réserve. Les tâches de `lyxal-server` (purge de `lyxal_auth`, nettoyage du stockage,
//! maintenance du coffre-fort) restent réservées par ses nœuds : sur une base partagée, ce sont
//! elles qui retirent les octets des fichiers supprimés du courrier et rescellent leurs clés.

use crate::config::{GroupwareConfig, ENV_PREFIX};
use crate::error::GroupwareError;
use async_trait::async_trait;
use lyxal_host::database::Database;
use lyxal_host::services::{master_keys, storage_backends, storage_scanner};
use lyxal_mail::auth::EmbeddedSuffixList;
use lyxal_mail::dkim::{DkimKeyCache, DkimProvisioner, ProvisionReport};
use lyxal_mail::dns::{HickoryResolver, MailResolver};
use lyxal_mail::net::MemoryBudget;
use lyxal_mail::outbound::{OutboundDispatcher, OutboundMetrics, OutboundServices};
use lyxal_mail::smtp::{BlockList, BlockRefreshWorker, SmtpInboundHandler, SmtpServices};
use lyxal_mail::submission::SubmissionHandler;
use lyxal_mail::{
    DeliveryPipeline, MailContent, MailError, MailHealthCheck, MailIngest, MailMaintenance,
    MailStore, MaintenanceReport, RequiredHost,
};
use lyxal_runtime::health::ModuleHealthCheck;
use lyxal_runtime::lock::SurrealLeaderLeaseManager;
use lyxal_runtime::presence::PresenceStore;
use lyxal_runtime::LyxalRuntime;
use lyxal_scheduler::models::{
    HealthParams, Overlap, ScheduleCreateParams, ScheduleSpec, SchedulerValue,
};
use lyxal_scheduler::{
    HandlerRegistry, RunContext, SchedulerClient, SchedulerEngine, SchedulerExecutorWorker,
    SchedulerHealthCheck, SchedulerLeaderWorker, SchedulerStore, TaskFailure, TaskHandler,
    TaskOutput,
};
use lyxal_secrets::{FileKeys, SecretsClient, SecretsHealthCheck, SecretsStore};
use lyxal_storage::models::EncryptedBucketExistsParams;
use lyxal_storage::{StorageHealthCheck, StorageService, StorageStore};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::types::{Object, SurrealValue};

/// Hôte qui exécute, sur la base partagée, le nettoyage du stockage et la maintenance du
/// coffre-fort (octets des messages effacés, rescellement des clés des fichiers).
pub const SERVER_HOST_ID: &str = "lyxal_server";
/// Éléments traités par paquet par la maintenance du courrier.
const MAINTENANCE_BATCH: u32 = 200;

/// Tâche de fond de l'hôte : maintenance de `lyxal_mail`.
pub const MAIL_MAINTENANCE_TASK: &str = "mail.maintenance";
/// Planification de l'installation de la maintenance du courrier.
pub const MAIL_MAINTENANCE_SCHEDULE: &str = "mail-maintenance";
/// Intervalle entre deux passages de la maintenance du courrier.
const MAIL_MAINTENANCE_EVERY: Duration = Duration::from_secs(600);
/// Décalage aléatoire maximal de chaque échéance.
const JITTER: Duration = Duration::from_secs(30);
/// Tâche de fond de l'hôte : clés DKIM des domaines (création, activation par le DNS).
pub const MAIL_DKIM_TASK: &str = "mail.dkim_provision";
/// Planification de l'installation de `mail.dkim_provision`.
pub const MAIL_DKIM_SCHEDULE: &str = "mail-dkim-provision";
/// Intervalle entre deux passages de `mail.dkim_provision`.
const MAIL_DKIM_EVERY: Duration = Duration::from_secs(600);

/// Services du courrier rendus à l'hôte (et aux protocoles des lots suivants).
#[derive(Clone)]
pub struct MailHost {
    /// Appels typés sur la session système de l'hôte.
    pub system: MailStore,
    /// Dépôt des messages (seul chemin d'écriture d'un message).
    pub ingest: MailIngest,
    /// Lecture des messages, entière ou par plage.
    pub content: MailContent,
    /// Stockage de l'hôte (session système, fichiers chiffrés) : contenus des envois déposés.
    pub storage: StorageService,
    /// Maintenance, exécutée par la tâche `mail.maintenance`.
    pub maintenance: MailMaintenance,
    /// Réception SMTP du nœud (écoutes `smtp`), si une écoute `smtp` est déclarée.
    pub smtp: Option<SmtpInboundHandler>,
    /// Dépôt authentifié du nœud (écoutes `submission`), si une écoute `submission` est déclarée.
    pub submission: Option<SubmissionHandler>,
    /// Liste de blocage du nœud, relue toutes les 30 s ; appliquée à l'acceptation de toutes
    /// les écoutes.
    pub blocks: BlockList,
    /// Mesures de l'envoi, si le worker d'envoi est actif (`outbound.enabled`).
    pub outbound: Option<Arc<OutboundMetrics>>,
}

/// Services des modules hébergés à compléter après leur installation.
pub struct HostedServices {
    /// Courrier.
    pub mail: MailHost,
    /// Sonde du courrier (base, supports, clés), composée avec celle des écoutes.
    pub mail_probe: Arc<dyn ModuleHealthCheck>,
    scheduler: SchedulerEngine,
    workers: u32,
    has_master_key: bool,
}

/// Enregistre auprès du runtime, avant l'installation des modules : sondes du coffre-fort et du
/// stockage, planificateur élu et sa sonde, handler de la maintenance du courrier ; rend les
/// services du courrier et sa sonde (à composer avec celle des écoutes). Les stores de la
/// session système reçoivent le pool `database` ; le bail du planificateur et la présence des
/// nœuds prennent sa connexion fixe.
pub fn register_services(
    runtime: &LyxalRuntime,
    database: &Database,
    config: &GroupwareConfig,
    budget: &MemoryBudget,
) -> Result<HostedServices, GroupwareError> {
    let master = master_keys(&config.secrets, ENV_PREFIX)?;
    match &master {
        Some(keys) => tracing::info!(
            master_key_id = %keys.active_id(),
            "coffre-fort : clé maîtresse chargée"
        ),
        None => tracing::warn!(
            "coffre-fort sans clé maîtresse : aucun message n'est déposé ni lu (LYXAL_GROUPWARE__SECRETS__MASTER_KEY et secrets.master_key_id requis, même clé que lyxal-server)"
        ),
    }
    let secrets_store = SecretsStore::new(database.clone());
    runtime
        .health_registry()
        .register_check(Arc::new(SecretsHealthCheck::new(
            secrets_store.clone(),
            master.clone(),
        )))?;
    // Clés DKIM et identifiants du relais : coffre-fort, consommateur lyxal_mail
    let mail_secrets = master.as_ref().map(|keys| {
        SecretsClient::new(
            secrets_store.clone(),
            Some(keys.clone()),
            lyxal_mail::MODULE_ID,
        )
    });

    let storage_store = StorageStore::new(database.clone());
    let backends = Arc::new(storage_backends(&config.storage)?);
    if backends.is_empty() {
        tracing::warn!(
            "aucun support de stockage : aucun message n'est déposé ni lu (LYXAL_GROUPWARE__STORAGE__DISK__ROOT ou LYXAL_GROUPWARE__STORAGE__S3__<NOM>__* requis)"
        );
    }
    let scanner = storage_scanner(&config.storage);
    let mut storage_probe = StorageHealthCheck::new(storage_store.clone(), backends.clone());
    let has_master_key = master.is_some();
    // Clés « fichiers » ouvertes gardées 60 s (lectures des messages, décision S13) ; aucun
    // antivirus sur les écritures du stockage : le message est analysé une fois, en tête de la
    // chaîne de remise (décision S9)
    let storage = StorageService::new(storage_store.clone(), backends).with_file_keys(
        FileKeys::new(secrets_store.clone(), master).with_cache(),
        storage_store,
    );
    if let Some(scanner) = &scanner {
        storage_probe = storage_probe.with_scanner(scanner.clone());
    }
    runtime
        .health_registry()
        .register_check(Arc::new(storage_probe))?;

    let system = MailStore::new(database.clone());
    let ingest = MailIngest::new(
        system.clone(),
        storage.clone(),
        config.mail.storage_backend.clone(),
    );
    let blocks = BlockList::new();
    let mut probe = MailHealthCheck::new(system.clone(), storage.clone()).with_required_host(
        RequiredHost::new(PresenceStore::new(database.fixed().clone()), SERVER_HOST_ID),
    );
    // Résolveur DNS du nœud, partagé par la réception, l'envoi et les clés DKIM : construit
    // seulement si ce nœud reçoit (écoute smtp) ou envoie (outbound.enabled)
    let resolver: Option<Arc<dyn MailResolver>> =
        if config.has_smtp_listener() || config.outbound.enabled {
            let dns = config.dns.dns_config()?;
            Some(Arc::new(HickoryResolver::new(&dns).map_err(|error| {
                GroupwareError::DnsUnavailable {
                    message: error.to_string(),
                }
            })?))
        } else {
            None
        };
    // Chaîne de remise du lot 5 : réception, route locale et avis de l'envoi
    let mut pipeline = DeliveryPipeline::new(ingest.clone());
    if let Some(scanner) = &scanner {
        pipeline = pipeline.with_scanner(scanner.clone());
    }
    let smtp = match (config.smtp.smtp_config(), &resolver) {
        (Some(smtp_config), Some(resolver)) if config.has_smtp_listener() => {
            let resolver = resolver.clone();
            if let Some(scanner) = &scanner {
                probe = probe.with_scanner(scanner.clone());
            }
            probe = probe.with_dns_probe(resolver.clone(), smtp_config.hostname.clone());
            let handler = SmtpInboundHandler::new(
                smtp_config,
                SmtpServices {
                    store: system.clone(),
                    resolver,
                    pipeline: pipeline.clone(),
                    budget: budget.clone(),
                    blocks: blocks.clone(),
                },
            )
            .map_err(|error| GroupwareError::Configuration {
                message: error.to_string(),
            })?;
            runtime.register_worker(Arc::new(BlockRefreshWorker::new(
                blocks.clone(),
                system.clone(),
            )?))?;
            Some(handler)
        }
        _ => None,
    };
    let submission = crate::submission::submission_handler(
        config,
        database,
        &ingest,
        scanner.clone(),
        budget,
        &blocks,
    )?;
    // Envoi (lot 6) : worker du nœud, TLS côté client de l'hôte, sonde
    let outbound = match (&config.smtp.hostname, &resolver) {
        (Some(hostname), Some(resolver)) if config.outbound.enabled => {
            let log_domains = config.observability.log_recipient_domain
                == crate::config::LogRecipientDomain::Full;
            let outbound_config = config.outbound.outbound_config(
                hostname,
                runtime.node_id().as_ref(),
                log_domains,
            )?;
            let worker = OutboundDispatcher::new(
                outbound_config,
                OutboundServices {
                    store: system.clone(),
                    storage: storage.clone(),
                    resolver: resolver.clone(),
                    tls: Some(Arc::new(crate::net::tls::HostTlsConnector::new()?)),
                    secrets: mail_secrets.clone(),
                    pipeline: pipeline.clone(),
                    organizational: Arc::new(EmbeddedSuffixList),
                    keys: Arc::new(DkimKeyCache::new()),
                },
            )?;
            let metrics = worker.metrics();
            runtime.register_worker(Arc::new(worker))?;
            probe = probe.with_outbound(metrics.clone());
            tracing::info!("envoi du courrier actif sur ce nœud (worker lyxal_mail:mail.outbound)");
            Some(metrics)
        }
        _ => None,
    };
    let mail = MailHost {
        submission,
        ingest,
        content: MailContent::new(storage.clone()),
        storage,
        maintenance: MailMaintenance::new(system.clone(), MAINTENANCE_BATCH),
        system: system.clone(),
        smtp,
        blocks,
        outbound,
    };
    // `lyxal-server` doit tourner sur la même base : sans lui, les octets des messages effacés et
    // le rescellement des clés attendent (sonde « dégradé » après 10 minutes sans nœud vivant)
    let mail_probe: Arc<dyn ModuleHealthCheck> = Arc::new(probe);

    let scheduler = SchedulerEngine::new(
        SchedulerStore::new(database.clone()),
        HandlerRegistry::new(),
        runtime.node_id().clone(),
        runtime.host_id().clone(),
    );
    runtime.register_worker(Arc::new(SchedulerLeaderWorker::new(
        scheduler.clone(),
        // Bail du planificateur : connexion fixe, comme les autres baux du runtime
        SurrealLeaderLeaseManager::new(database.fixed().clone()),
    )?))?;
    runtime
        .health_registry()
        .register_check(Arc::new(SchedulerHealthCheck::new(scheduler.clone())))?;
    let mut handlers = scheduler.handlers().clone();
    handlers
        .register(Arc::new(MailMaintenanceHandler {
            maintenance: mail.maintenance.clone(),
        }))
        .map_err(|error| install_error(error.code()))?;
    handlers
        .register(Arc::new(DkimProvisionHandler {
            provisioner: mail_secrets.zip(resolver).map(|(secrets, resolver)| {
                DkimProvisioner::new(system, secrets_store, secrets, resolver, MAINTENANCE_BATCH)
            }),
        }))
        .map_err(|error| install_error(error.code()))?;

    Ok(HostedServices {
        mail,
        mail_probe,
        scheduler,
        workers: config.scheduler.workers,
        has_master_key,
    })
}

/// Après l'installation des modules, avant tout démarrage : sans clé maîtresse du coffre-fort,
/// refuse de démarrer (`GROUPWARE_MASTER_KEY_MISSING`) si un bucket chiffré existe dans la base
/// (`fn::storage_encrypted_bucket_exists`, session système) : ses fichiers ne pourraient être ni
/// écrits ni lus. Une base sans bucket chiffré démarre sans clé (sonde « dégradé »).
pub async fn require_master_key(
    database: &Database,
    services: &HostedServices,
) -> Result<(), GroupwareError> {
    if services.has_master_key {
        return Ok(());
    }
    let found = StorageStore::new(database.clone())
        .encrypted_bucket_exists(EncryptedBucketExistsParams::default())
        .await
        .map_err(|error| GroupwareError::ModuleInstall {
            module: lyxal_storage::MODULE_ID.to_string(),
            message: format!("buckets chiffrés illisibles : {error}"),
        })?;
    if found.exists {
        return Err(GroupwareError::MasterKeyMissing);
    }
    Ok(())
}

fn install_error(detail: impl std::fmt::Display) -> GroupwareError {
    GroupwareError::ModuleInstall {
        module: crate::modules::HOST_ID.to_string(),
        message: format!("tâche de fond {MAIL_MAINTENANCE_TASK} : {detail}"),
    }
}

/// Après l'installation des modules : déclare la tâche de maintenance du courrier et sa
/// permission (`seeds/groupware_tasks.surql`), crée sa planification si elle est absente, puis un
/// exécuteur par file déclarée. Rejouable. `database` : session système de l'hôte (seeds
/// installés sur sa connexion fixe).
pub async fn complete_services(
    runtime: &LyxalRuntime,
    database: &Database,
    services: &HostedServices,
) -> Result<(), GroupwareError> {
    crate::modules::install_host_seeds(database.fixed()).await?;
    let mut spec = ScheduleSpec::new("UTC");
    spec.every = vec![MAIL_MAINTENANCE_EVERY.into()];
    spec.jitter = Some(JITTER.into());
    let mut params =
        ScheduleCreateParams::new(MAIL_MAINTENANCE_SCHEDULE, MAIL_MAINTENANCE_TASK, spec);
    params.overlap = Some(Overlap::Skip);
    let client = SchedulerClient::new(SchedulerStore::new(database.clone()));
    let mut dkim_spec = ScheduleSpec::new("UTC");
    dkim_spec.every = vec![MAIL_DKIM_EVERY.into()];
    dkim_spec.jitter = Some(JITTER.into());
    let mut dkim = ScheduleCreateParams::new(MAIL_DKIM_SCHEDULE, MAIL_DKIM_TASK, dkim_spec);
    dkim.overlap = Some(Overlap::Skip);
    for (task, params) in [(MAIL_MAINTENANCE_TASK, params), (MAIL_DKIM_TASK, dkim)] {
        match client.schedule(params).await {
            Ok(_) => tracing::info!(task, "tâche de fond planifiée"),
            Err(error) if error.is_code("SCHEDULER_SCHEDULE_EXISTS") => {}
            Err(error) => return Err(install_error(error.code())),
        }
    }
    let state = services
        .scheduler
        .store()
        .health(HealthParams::default())
        .await
        .map_err(|error| GroupwareError::ModuleInstall {
            module: lyxal_scheduler::MODULE_ID.to_string(),
            message: format!("files du planificateur illisibles : {error}"),
        })?;
    for queue in state.queues {
        runtime.register_worker(Arc::new(SchedulerExecutorWorker::new(
            services.scheduler.clone(),
            queue.name.clone(),
            services.workers,
        )?))?;
        tracing::info!(queue = %queue.name, workers = services.workers, "exécuteur du planificateur enregistré");
    }
    Ok(())
}

fn count(value: u64) -> i64 {
    i64::try_from(value).unwrap_or(i64::MAX)
}

/// Handler de la tâche `mail.maintenance` : un passage de la maintenance du courrier.
struct MailMaintenanceHandler {
    maintenance: MailMaintenance,
}

#[async_trait]
impl TaskHandler for MailMaintenanceHandler {
    fn task(&self) -> &str {
        MAIL_MAINTENANCE_TASK
    }

    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        match self.maintenance.run(&ctx.cancellation).await {
            Ok(report) => {
                let MaintenanceReport {
                    expired,
                    released,
                    tombstones,
                    deliveries,
                    accounts,
                    messages,
                    submissions,
                    queue_contents,
                    queue_records,
                } = report;
                let mut result = Object::new();
                for (name, value) in [
                    ("expired", expired),
                    ("released", released),
                    ("tombstones", tombstones),
                    ("deliveries", deliveries),
                    ("accounts", accounts),
                    ("messages", messages),
                    ("submissions", submissions),
                    ("queue_contents", queue_contents),
                    ("queue_records", queue_records),
                ] {
                    result.insert(name, count(value).into_value());
                }
                if ctx.cancellation.is_cancelled() {
                    result.insert("interrupted", true.into_value());
                }
                Ok(TaskOutput::with_result(SchedulerValue::Object(result)))
            }
            Err(error) => Err(failure(&error)),
        }
    }
}

/// Handler de la tâche `mail.dkim_provision` : clés DKIM des domaines actifs (RSA 2 048 bits et
/// Ed25519), rangées dans le coffre-fort, puis activées quand le DNS montre l'enregistrement.
/// Sans clé maîtresse, rien n'est fait (aucune clé ne pourrait être rangée).
struct DkimProvisionHandler {
    provisioner: Option<DkimProvisioner>,
}

#[async_trait]
impl TaskHandler for DkimProvisionHandler {
    fn task(&self) -> &str {
        MAIL_DKIM_TASK
    }

    async fn run(&self, _ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        let mut result = Object::new();
        let Some(provisioner) = &self.provisioner else {
            result.insert("skipped", "master_key_missing".to_string().into_value());
            return Ok(TaskOutput::with_result(SchedulerValue::Object(result)));
        };
        let ProvisionReport {
            created,
            activated,
            pending,
            failed,
        } = provisioner.run().await.map_err(|error| failure(&error))?;
        for (name, value) in [
            ("created", created),
            ("activated", activated),
            ("pending", pending),
            ("failed", failed),
        ] {
            result.insert(name, count(value).into_value());
        }
        Ok(TaskOutput::with_result(SchedulerValue::Object(result)))
    }
}

/// Échec rendu au planificateur : code et caractère « à réessayer » de l'erreur ; une panne
/// technique (base injoignable, réponse illisible) est toujours réessayée.
fn failure(error: &MailError) -> TaskFailure {
    TaskFailure {
        code: error.code(),
        message: error.to_string(),
        retryable: error.is_retryable() || !error.is_business(),
    }
}
