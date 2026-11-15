//! Façade du planificateur pour les autres modules : différer ou lancer une exécution, créer
//! une planification (règles de dates contrôlées avant l'écriture), annuler une exécution. Les
//! appels se font au nom de l'appelant (sa session SurrealDB) ; les droits, la permission propre
//! de la tâche et les arguments sont contrôlés par les fonctions SurrealQL. Aucune table n'est
//! touchée directement.

use crate::error::SchedulerResult;
use crate::models::{Run, RunCancelParams, RunEnqueueParams, Schedule, ScheduleCreateParams};
use crate::service::SchedulerService;
use crate::store::SchedulerStore;

/// Client du planificateur pour un module.
#[derive(Clone)]
pub struct SchedulerClient {
    service: SchedulerService,
}

impl SchedulerClient {
    /// Client sur le store `store` (session de l'appelant).
    pub fn new(store: SchedulerStore) -> Self {
        Self {
            service: SchedulerService::new(store),
        }
    }

    /// Exécution différée (`run_at`, `delay`) ou immédiate d'une tâche
    /// (`fn::scheduler_run_enqueue`), avec unicité si la tâche la déclare.
    pub async fn enqueue(&self, params: RunEnqueueParams) -> SchedulerResult<Run> {
        Ok(self.service.store().run_enqueue(params).await?)
    }

    /// Planification créée après le contrôle de ses règles de dates
    /// (`SchedulerService::schedule_create`).
    pub async fn schedule(&self, params: ScheduleCreateParams) -> SchedulerResult<Schedule> {
        self.service.schedule_create(params).await
    }

    /// Exécution annulée, ou annulation demandée si elle tourne (`fn::scheduler_run_cancel`).
    pub async fn cancel(&self, params: RunCancelParams) -> SchedulerResult<Run> {
        Ok(self.service.store().run_cancel(params).await?)
    }
}
