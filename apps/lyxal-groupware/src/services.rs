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

use crate::config::{GroupwareConfig, SecretsConfig};
use crate::error::GroupwareError;
use async_trait::async_trait;
use lyxal_crypto::{EnvironmentKeyProvider, KeyId, ResolvedKey};
use lyxal_mail::{
    MailContent, MailError, MailHealthCheck, MailIngest, MailMaintenance, MailStore,
    MaintenanceReport,
};
use lyxal_runtime::health::ModuleHealthCheck;
use lyxal_runtime::lock::SurrealLeaderLeaseManager;
use lyxal_runtime::LyxalRuntime;
use lyxal_scheduler::models::{
    HealthParams, Overlap, ScheduleCreateParams, ScheduleSpec, SchedulerValue,
};
use lyxal_scheduler::{
    HandlerRegistry, RunContext, SchedulerClient, SchedulerEngine, SchedulerExecutorWorker,
    SchedulerHealthCheck, SchedulerLeaderWorker, SchedulerStore, TaskFailure, TaskHandler,
    TaskOutput,
};
use lyxal_secrets::{FileKeys, MasterKeys, SecretsHealthCheck, SecretsStore};
use lyxal_storage::{
    BackendConfig, Backends, ClamAvScanner, ContentScanner, ScannerConfig, StorageHealthCheck,
    StorageService, StorageStore,
};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::types::{Object, SurrealValue};
use surrealdb::Surreal;

/// Variable d'environnement de la clé maîtresse du coffre-fort.
const MASTER_KEY_VAR: &str = "LYXAL_GROUPWARE__SECRETS__MASTER_KEY";
/// Variable d'environnement de l'ancienne clé maîtresse, pendant une rotation.
const PREVIOUS_MASTER_KEY_VAR: &str = "LYXAL_GROUPWARE__SECRETS__PREVIOUS_MASTER_KEY";
/// Nom du support disque.
const DEFAULT_BACKEND: &str = "default";
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

/// Services du courrier rendus à l'hôte (et aux protocoles des lots suivants).
#[derive(Clone)]
pub struct MailHost {
    /// Appels typés sur la session système de l'hôte.
    pub system: MailStore,
    /// Dépôt des messages (seul chemin d'écriture d'un message).
    pub ingest: MailIngest,
    /// Lecture des messages, entière ou par plage.
    pub content: MailContent,
    /// Maintenance, exécutée par la tâche `mail.maintenance`.
    pub maintenance: MailMaintenance,
}

/// Services des modules hébergés à compléter après leur installation.
pub struct HostedServices {
    /// Courrier.
    pub mail: MailHost,
    /// Sonde du courrier (base, supports, clés), composée avec celle des écoutes.
    pub mail_probe: Arc<dyn ModuleHealthCheck>,
    scheduler: SchedulerEngine,
    workers: u32,
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> GroupwareError {
    GroupwareError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Une clé lue par `EnvironmentKeyProvider` ; une clé sans identifiant ou invalide arrête le
/// démarrage.
fn load_key(
    var: &str,
    field: &str,
    id_field: &str,
    id: Option<&str>,
) -> Result<ResolvedKey, GroupwareError> {
    let id = id
        .ok_or_else(|| configuration_error(id_field, "obligatoire avec la clé"))
        .and_then(|id| KeyId::parse(id).map_err(|e| configuration_error(id_field, e)))?;
    EnvironmentKeyProvider::load(var, id).map_err(|e| configuration_error(field, e))
}

/// Trousseau maître du coffre-fort : clé active et, pendant une rotation, l'ancienne en lecture
/// seule. `None` sans clé.
pub fn master_keys(config: &SecretsConfig) -> Result<Option<MasterKeys>, GroupwareError> {
    if config.master_key.is_none() {
        if config.previous_master_key.is_some() {
            return Err(configuration_error(
                "secrets.previous_master_key",
                "fournie sans clé maîtresse active (secrets.master_key)",
            ));
        }
        return Ok(None);
    }
    let active = load_key(
        MASTER_KEY_VAR,
        "secrets.master_key",
        "secrets.master_key_id",
        config.master_key_id.as_deref(),
    )?;
    let previous = match &config.previous_master_key {
        None => None,
        Some(_) => Some(load_key(
            PREVIOUS_MASTER_KEY_VAR,
            "secrets.previous_master_key",
            "secrets.previous_master_key_id",
            config.previous_master_key_id.as_deref(),
        )?),
    };
    MasterKeys::from_keys(active, previous)
        .map(Some)
        .map_err(|e| configuration_error("secrets.master_key", e))
}

/// Supports de l'installation : le dossier disque (`default`) et les services S3 nommés.
fn backends(config: &GroupwareConfig) -> Result<Backends, GroupwareError> {
    let storage = &config.storage;
    let mut backends = Backends::new();
    if let Some(disk) = &storage.disk {
        backends = backends
            .with(
                DEFAULT_BACKEND,
                BackendConfig::Disk {
                    root: disk.root.clone(),
                },
            )
            .map_err(|error| configuration_error("storage.disk.root", error))?;
    }
    for (name, s3) in &storage.s3 {
        let secret = s3
            .secret_access_key
            .to_secret()
            .map_err(|_| configuration_error(&format!("storage.s3.{name}"), "clé refusée"))?;
        backends = backends
            .with(
                name,
                BackendConfig::S3 {
                    endpoint: s3.endpoint.clone(),
                    region: s3.region.clone(),
                    bucket: s3.bucket.clone(),
                    access_key_id: s3.access_key_id.clone(),
                    secret_access_key: secret,
                    path_style: s3.path_style,
                    allow_http: s3.allow_http,
                },
            )
            .map_err(|error| configuration_error(&format!("storage.s3.{name}"), error))?;
    }
    if backends.is_empty() {
        tracing::warn!(
            "aucun support de stockage : aucun message n'est déposé ni lu (LYXAL_GROUPWARE__STORAGE__DISK__ROOT ou LYXAL_GROUPWARE__STORAGE__S3__<NOM>__* requis)"
        );
    }
    Ok(backends)
}

/// Antivirus, s'il est configuré.
fn scanner(config: &GroupwareConfig) -> Option<Arc<dyn ContentScanner>> {
    let antivirus = config.storage.antivirus.as_ref()?;
    let address = match (&antivirus.address, &antivirus.socket) {
        (Some(address), _) => ScannerConfig::Tcp {
            address: address.clone(),
        },
        (None, Some(path)) => ScannerConfig::Socket { path: path.clone() },
        // Écarté par la validation de la configuration
        (None, None) => return None,
    };
    Some(Arc::new(ClamAvScanner::new(
        address,
        Duration::from_secs(antivirus.timeout_seconds),
    )))
}

/// Enregistre auprès du runtime, avant l'installation des modules : sondes du coffre-fort et du
/// stockage, planificateur élu et sa sonde, handler de la maintenance du courrier ; rend les
/// services du courrier et sa sonde (à composer avec celle des écoutes).
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &GroupwareConfig,
) -> Result<HostedServices, GroupwareError> {
    let master = master_keys(&config.secrets)?;
    match &master {
        Some(keys) => tracing::info!(
            master_key_id = %keys.active_id(),
            "coffre-fort : clé maîtresse chargée"
        ),
        None => tracing::warn!(
            "coffre-fort sans clé maîtresse : aucun message n'est déposé ni lu (LYXAL_GROUPWARE__SECRETS__MASTER_KEY et secrets.master_key_id requis, même clé que lyxal-server)"
        ),
    }
    let secrets_store = SecretsStore::new(client.clone());
    runtime
        .health_registry()
        .register_check(Arc::new(SecretsHealthCheck::new(
            secrets_store.clone(),
            master.clone(),
        )))?;

    let storage_store = StorageStore::new(client.clone());
    let backends = Arc::new(backends(config)?);
    let scanner = scanner(config);
    let mut storage_probe = StorageHealthCheck::new(storage_store.clone(), backends.clone());
    let mut storage = StorageService::new(storage_store.clone(), backends)
        .with_file_keys(FileKeys::new(secrets_store, master), storage_store);
    if let Some(scanner) = &scanner {
        storage_probe = storage_probe.with_scanner(scanner.clone());
        storage = storage.with_scanner(scanner.clone());
    }
    runtime
        .health_registry()
        .register_check(Arc::new(storage_probe))?;

    let system = MailStore::new(client.clone());
    let mail = MailHost {
        ingest: MailIngest::new(
            system.clone(),
            storage.clone(),
            config.mail.storage_backend.clone(),
        ),
        content: MailContent::new(storage.clone()),
        maintenance: MailMaintenance::new(system.clone(), MAINTENANCE_BATCH),
        system: system.clone(),
    };
    let mail_probe: Arc<dyn ModuleHealthCheck> = Arc::new(MailHealthCheck::new(system, storage));

    let scheduler = SchedulerEngine::new(
        SchedulerStore::new(client.clone()),
        HandlerRegistry::new(),
        runtime.node_id().clone(),
        runtime.host_id().clone(),
    );
    runtime.register_worker(Arc::new(SchedulerLeaderWorker::new(
        scheduler.clone(),
        SurrealLeaderLeaseManager::new(client.clone()),
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

    Ok(HostedServices {
        mail,
        mail_probe,
        scheduler,
        workers: config.scheduler.workers,
    })
}

fn install_error(detail: impl std::fmt::Display) -> GroupwareError {
    GroupwareError::ModuleInstall {
        module: crate::modules::HOST_ID.to_string(),
        message: format!("tâche de fond {MAIL_MAINTENANCE_TASK} : {detail}"),
    }
}

/// Après l'installation des modules : déclare la tâche de maintenance du courrier et sa
/// permission (`seeds/groupware_tasks.surql`), crée sa planification si elle est absente, puis un
/// exécuteur par file déclarée. Rejouable. `client` : session système de l'hôte.
pub async fn complete_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    services: &HostedServices,
) -> Result<(), GroupwareError> {
    crate::modules::install_host_seeds(client).await?;
    let mut spec = ScheduleSpec::new("UTC");
    spec.every = vec![MAIL_MAINTENANCE_EVERY.into()];
    spec.jitter = Some(JITTER.into());
    let mut params =
        ScheduleCreateParams::new(MAIL_MAINTENANCE_SCHEDULE, MAIL_MAINTENANCE_TASK, spec);
    params.overlap = Some(Overlap::Skip);
    match SchedulerClient::new(SchedulerStore::new(client.clone()))
        .schedule(params)
        .await
    {
        Ok(_) => tracing::info!(task = MAIL_MAINTENANCE_TASK, "tâche de fond planifiée"),
        Err(error) if error.is_code("SCHEDULER_SCHEDULE_EXISTS") => {}
        Err(error) => return Err(install_error(error.code())),
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
                    accounts,
                    messages,
                } = report;
                let mut result = Object::new();
                for (name, value) in [
                    ("expired", expired),
                    ("released", released),
                    ("tombstones", tombstones),
                    ("accounts", accounts),
                    ("messages", messages),
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

/// Échec rendu au planificateur : code et caractère « à réessayer » de l'erreur ; une panne
/// technique (base injoignable, réponse illisible) est toujours réessayée.
fn failure(error: &MailError) -> TaskFailure {
    TaskFailure {
        code: error.code(),
        message: error.to_string(),
        retryable: error.is_retryable() || !error.is_business(),
    }
}
