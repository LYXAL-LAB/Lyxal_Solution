//! Module `lyxal_scheduler` : implémentation `LyxalModule`, planificateur élu (bail `leader` du
//! runtime), un exécuteur par file, sonde de santé et registre des handlers.
//!
//! Tout le moteur tourne sur la session système de l'hôte (T2). Les modules hébergés qui
//! déclarent des tâches `handler` inscrivent leur code dans le registre rendu par
//! [`register_services`] (`SchedulerHost::handlers`), avant le démarrage du runtime ; aucun module
//! ne le fait encore (S8). Places par file et par nœud : `LYXAL__SCHEDULER__WORKERS` (W3).

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_runtime::lock::SurrealLeaderLeaseManager;
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_scheduler::models::HealthParams;
use lyxal_scheduler::{
    HandlerRegistry, SchedulerClient, SchedulerEngine, SchedulerExecutorWorker,
    SchedulerHealthCheck, SchedulerLeaderWorker, SchedulerModule, SchedulerStore,
};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_scheduler::MODULE_ID;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(SchedulerModule::new())
}

/// Ce que l'hôte garde du planificateur : le moteur (session système, registre des handlers,
/// files servies) et les places de chaque exécuteur.
#[derive(Clone)]
pub struct SchedulerHost {
    engine: SchedulerEngine,
    workers: u32,
}

impl SchedulerHost {
    /// Registre des handlers, ouvert aux modules hébergés : une copie inscrit dans le même
    /// registre que celui des exécuteurs.
    pub fn handlers(&self) -> HandlerRegistry {
        self.engine.handlers().clone()
    }

    /// Client du planificateur au nom d'un appelant (sa session SurrealDB).
    pub fn client(&self, caller: SchedulerStore) -> SchedulerClient {
        SchedulerClient::new(caller)
    }

    /// Files servies par un exécuteur sur ce nœud.
    pub fn served_queues(&self) -> Vec<String> {
        self.engine.executors().queues()
    }
}

/// Planificateur et sonde, enregistrés avant l'installation ; les exécuteurs le sont après
/// (`register_executors`), une fois les files connues.
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
) -> Result<SchedulerHost, ServerError> {
    let engine = SchedulerEngine::new(
        SchedulerStore::new(client.clone()),
        HandlerRegistry::new(),
        runtime.node_id().clone(),
    );
    runtime.register_worker(Arc::new(SchedulerLeaderWorker::new(
        engine.clone(),
        SurrealLeaderLeaseManager::new(client.clone()),
    )?))?;
    runtime
        .health_registry()
        .register_check(Arc::new(SchedulerHealthCheck::new(engine.clone())))?;
    Ok(SchedulerHost {
        engine,
        workers: config.scheduler.workers,
    })
}

/// Un exécuteur par file déclarée (seeds des modules installés), avant le démarrage.
pub async fn register_executors(
    runtime: &LyxalRuntime,
    host: &SchedulerHost,
) -> Result<(), ServerError> {
    let state = host
        .engine
        .store()
        .health(HealthParams::default())
        .await
        .map_err(|error| ServerError::ModuleInstall {
            module: MODULE_ID.to_string(),
            message: format!("files du planificateur illisibles : {error}"),
        })?;
    for queue in state.queues {
        let name = queue.name;
        runtime.register_worker(Arc::new(SchedulerExecutorWorker::new(
            host.engine.clone(),
            name.clone(),
            host.workers,
        )?))?;
        tracing::info!(queue = %name, workers = host.workers, "exécuteur du planificateur enregistré");
    }
    Ok(())
}
