//! Exécuteur d'une file (W2, W3) : réserve les exécutions disponibles dans la limite des places
//! du nœud, exécute chacune dans une tâche tenue par le worker (`JoinSet`, jamais de tâche
//! libre), interroge la file chaque seconde quand elle est vide et aussitôt après chaque fin
//! sinon. À l'arrêt : plus de réservation, annulation transmise aux tentatives en cours,
//! attente bornée (30 s), puis abandon (le bail expire et la reprise s'en charge).

use async_trait::async_trait;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::time::Duration;
use tokio::task::JoinSet;

use super::attempt::{run_attempt, AttemptOutcome};
use super::{SchedulerEngine, DEFAULT_WORKERS, MAX_WORKERS};
use crate::error::SchedulerError;
use crate::models::RunClaimParams;
use crate::module::MODULE_ID;

/// Rythme d'un exécuteur ; les valeurs par défaut sont celles de W2, réduites dans les tests.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ExecutorTiming {
    /// Attente entre deux interrogations d'une file vide (1 s).
    pub poll: Duration,
    /// Battement au plus tard toutes les `max_heartbeat` (30 s), et à mi-bail s'il est plus
    /// court : prolonge le bail et apprend l'annulation demandée.
    pub max_heartbeat: Duration,
    /// Attente des tentatives en cours à l'arrêt du nœud (30 s), avant abandon.
    pub shutdown_grace: Duration,
    /// Délai maximal dépassé : temps laissé au handler annulé pour rendre la main (5 s) avant
    /// que le moteur cesse de l'attendre ; l'échec `SCHEDULER_RUN_TIMEOUT` est enregistré dans
    /// tous les cas.
    pub cancel_grace: Duration,
}

impl Default for ExecutorTiming {
    fn default() -> Self {
        Self {
            poll: Duration::from_secs(1),
            max_heartbeat: Duration::from_secs(30),
            shutdown_grace: Duration::from_secs(30),
            cancel_grace: Duration::from_secs(5),
        }
    }
}

/// Exécuteur des tâches d'une file sur ce nœud.
pub struct SchedulerExecutorWorker {
    descriptor: WorkerDescriptor,
    engine: SchedulerEngine,
    queue: String,
    slots: usize,
    timing: ExecutorTiming,
}

impl SchedulerExecutorWorker {
    /// Exécuteur de la file `queue`, au plus `slots` tentatives à la fois sur ce nœud (W3 :
    /// borné de 1 à 64).
    pub fn new(
        engine: SchedulerEngine,
        queue: impl Into<String>,
        slots: u32,
    ) -> Result<Self, RuntimeError> {
        Self::with_timing(engine, queue, slots, ExecutorTiming::default())
    }

    /// Exécuteur au rythme `timing` (tests).
    pub fn with_timing(
        engine: SchedulerEngine,
        queue: impl Into<String>,
        slots: u32,
        timing: ExecutorTiming,
    ) -> Result<Self, RuntimeError> {
        let queue = queue.into();
        let module_id = ModuleId::new(MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, format!("executor_{queue}"))?,
            module_id,
            format!("Lyxal Scheduler Executor ({queue})"),
        );
        descriptor.description = Some(format!(
            "Réservation et exécution des tâches de la file {queue} : handlers Rust, fonctions SurrealQL des modules, publications différées ; battement du bail, délai maximal, annulation"
        ));
        descriptor.criticality = WorkerCriticality::Required;
        // Les tentatives en cours ont `shutdown_grace` pour finir ; le superviseur attend un peu
        // plus avant d'arrêter le worker de force
        descriptor.shutdown_timeout = timing.shutdown_grace + Duration::from_secs(5);
        let slots =
            usize::try_from(slots.clamp(1, MAX_WORKERS)).unwrap_or(DEFAULT_WORKERS as usize);
        Ok(Self {
            descriptor,
            engine,
            queue,
            slots,
            timing,
        })
    }

    /// File servie.
    pub fn queue(&self) -> &str {
        &self.queue
    }

    /// Réserve au plus `limit` exécutions et les confie à `tasks` ; nombre réservé.
    async fn claim(
        &self,
        limit: usize,
        tasks: &mut JoinSet<AttemptOutcome>,
        stop: &CancellationToken,
    ) -> Result<usize, SchedulerError> {
        let claimed = self
            .engine
            .store()
            .run_claim(RunClaimParams {
                queue: self.queue.clone(),
                node: self.engine.node().to_string(),
                host: self.engine.host().to_string(),
                limit: Some(i64::try_from(limit).unwrap_or(1)),
                handlers: self.engine.handlers().tasks(),
                language: None,
            })
            .await?;
        let count = claimed.items.len();
        for run in claimed.items {
            tracing::debug!(queue = %self.queue, run = %run.id.to_sql(), task = %run.target, attempt = run.attempt, "exécution réservée");
            let engine = self.engine.clone();
            let timing = self.timing;
            let stop = stop.clone();
            tasks.spawn(async move { run_attempt(&engine, &timing, run, &stop).await });
        }
        Ok(count)
    }

    /// Journal d'une tentative terminée.
    fn record(&self, joined: Result<AttemptOutcome, tokio::task::JoinError>) {
        match joined {
            Ok(AttemptOutcome::Completed) => {}
            Ok(AttemptOutcome::Failed(code)) => {
                tracing::info!(queue = %self.queue, code = %code, "tentative terminée en échec")
            }
            Ok(AttemptOutcome::LeaseLost) => {}
            Ok(AttemptOutcome::FinishRefused(code)) => {
                tracing::warn!(queue = %self.queue, code = %code, "fin de tentative non enregistrée")
            }
            Err(error) => {
                tracing::error!(queue = %self.queue, error = %error, "tentative interrompue (panique ou abandon) : le bail expirera et la reprise s'en chargera")
            }
        }
    }
}

#[async_trait]
impl LyxalWorker for SchedulerExecutorWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let _serving = self.engine.executors().serve(&self.queue);
        let stop = ctx.cancellation.clone();
        let mut tasks: JoinSet<AttemptOutcome> = JoinSet::new();
        while !stop.is_cancelled() {
            while let Some(joined) = tasks.try_join_next() {
                self.record(joined);
            }
            let free = self.slots.saturating_sub(tasks.len());
            let mut claimed = 0;
            if free > 0 {
                match self.claim(free, &mut tasks, &stop).await {
                    Ok(count) => claimed = count,
                    Err(error) => {
                        tracing::warn!(queue = %self.queue, code = %error.code(), error = %error, "réservation impossible")
                    }
                }
            }
            // File vide (moins que les places libres) : prochaine interrogation dans `poll`, ou
            // aussitôt qu'une tentative se termine ; places pleines : à la prochaine fin
            let full = free == 0 || claimed == free;
            tokio::select! {
                _ = stop.cancelled() => break,
                joined = tasks.join_next(), if !tasks.is_empty() => {
                    if let Some(joined) = joined {
                        self.record(joined);
                    }
                }
                _ = tokio::time::sleep(self.timing.poll), if !full || tasks.is_empty() => {}
            }
        }

        // Arrêt : plus de réservation ; les tentatives ont reçu l'annulation (jeton enfant)
        if !tasks.is_empty() {
            tracing::info!(queue = %self.queue, running = tasks.len(), "arrêt : attente des tentatives en cours");
            let drained = tokio::time::timeout(self.timing.shutdown_grace, async {
                while let Some(joined) = tasks.join_next().await {
                    self.record(joined);
                }
            })
            .await;
            if drained.is_err() {
                tracing::warn!(queue = %self.queue, abandoned = tasks.len(), "arrêt : tentatives abandonnées, leur bail expirera et la reprise s'en chargera");
                tasks.abort_all();
                while tasks.join_next().await.is_some() {}
            }
        }
        Ok(())
    }
}
