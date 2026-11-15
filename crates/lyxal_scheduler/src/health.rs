//! Sonde de santé de `lyxal_scheduler` : base joignable (`fn::scheduler_health`), chaque file
//! active servie par un exécuteur sur ce nœud, aucune exécution réservable en attente depuis plus
//! de 5 minutes au-delà de sa date, et un handler inscrit pour chaque tâche `handler` active.
//! Le texte ne contient aucune donnée d'organisation.

use async_trait::async_trait;
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{ModuleContext, RuntimeError};
use std::time::Instant;

use crate::engine::SchedulerEngine;
use crate::error::SchedulerError;
use crate::models::HealthParams;
use crate::module::MODULE_ID;

/// Sonde de santé du planificateur.
pub struct SchedulerHealthCheck {
    module_id: ModuleId,
    engine: SchedulerEngine,
}

impl SchedulerHealthCheck {
    /// Sonde du moteur `engine` (session système, handlers, files servies du nœud).
    pub fn new(engine: SchedulerEngine) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            engine,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for SchedulerHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let elapsed = || u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        let health = match self.engine.store().health(HealthParams::default()).await {
            Ok(health) => health,
            Err(error) => {
                let error = SchedulerError::from(error);
                return Ok(HealthCheckResult::unhealthy(
                    self.module_id.clone(),
                    Some(elapsed()),
                    Some(format!("état du moteur illisible : {}", error.code())),
                ));
            }
        };
        let served = self.engine.executors().queues();
        let unserved: Vec<&str> = health
            .queues
            .iter()
            .filter(|q| !q.paused && !served.contains(&q.name))
            .map(|q| q.name.as_str())
            .collect();
        let registered = self.engine.handlers().tasks();
        let missing: Vec<&str> = health
            .handler_tasks
            .iter()
            .filter(|task| !registered.contains(task))
            .map(String::as_str)
            .collect();
        let mut problems = Vec::new();
        if served.is_empty() {
            problems.push("aucune file n'a d'exécuteur sur ce nœud".to_string());
        } else if !unserved.is_empty() {
            problems.push(format!("files sans exécuteur : {}", unserved.join(", ")));
        }
        if health.late > 0 {
            problems.push(format!(
                "{} exécution(s) en attente depuis plus de 5 min au-delà de leur date",
                health.late
            ));
        }
        if !missing.is_empty() {
            problems.push(format!(
                "tâches handler actives sans handler inscrit : {}",
                missing.join(", ")
            ));
        }
        if problems.is_empty() {
            return Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                elapsed(),
                Some(format!(
                    "{} file(s) servie(s), {} handler(s) inscrit(s)",
                    served.len(),
                    registered.len()
                )),
            ));
        }
        Ok(HealthCheckResult::degraded(
            self.module_id.clone(),
            elapsed(),
            Some(problems.join(" ; ")),
        ))
    }
}
