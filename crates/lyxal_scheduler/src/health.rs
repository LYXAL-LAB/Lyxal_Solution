//! Sonde de santé de `lyxal_scheduler` : base joignable (`fn::scheduler_health`), au moins une
//! file servie par un exécuteur sur ce nœud, chaque file active servie par un nœud actif de cet
//! hôte ou d'un autre, aucune exécution réservable en attente depuis plus de 5 minutes au-delà de
//! sa date, et aucune tâche `handler` qu'aucun nœud actif ne sert avec une exécution en attente
//! depuis plus de 5 minutes (H4 : le message nomme la tâche et l'hôte absent ; l'exécution
//! attend, sans échec). Un handler absent de ce nœud mais servi par un autre est une simple
//! information. Le texte ne contient aucune donnée d'organisation.

use async_trait::async_trait;
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{ModuleContext, RuntimeError};
use lyxal_surreal::ToSql;
use std::time::Instant;

use crate::engine::SchedulerEngine;
use crate::error::SchedulerError;
use crate::models::{HealthParams, UnservedTask};
use crate::module::MODULE_ID;
use crate::spec::to_timestamp;

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
        // Une file n'est signalée que si aucun nœud actif, de cet hôte ou d'un autre, ne la sert
        let unserved: Vec<&str> = health
            .queues
            .iter()
            .filter(|q| !q.paused && !q.served && !served.contains(&q.name))
            .map(|q| q.name.as_str())
            .collect();
        let registered = self.engine.handlers().tasks();
        let elsewhere: Vec<&str> = health
            .handler_tasks
            .iter()
            .filter(|task| !registered.contains(task) && health.handlers_served.contains(task))
            .map(String::as_str)
            .collect();
        let mut problems = Vec::new();
        if served.is_empty() {
            problems.push("aucune file n'a d'exécuteur sur ce nœud".to_string());
        } else if !unserved.is_empty() {
            problems.push(format!(
                "files servies par aucun nœud actif : {}",
                unserved.join(", ")
            ));
        }
        if health.late > 0 {
            problems.push(format!(
                "{} exécution(s) en attente depuis plus de 5 min au-delà de leur date",
                health.late
            ));
        }
        // Tâches qui attendent un nœud qui a leur code (H4) : signalées, jamais mises en échec
        for task in &health.unserved_tasks {
            problems.push(unserved_task_message(task));
        }
        if problems.is_empty() {
            let mut message = format!(
                "{} file(s) servie(s), {} handler(s) inscrit(s)",
                served.len(),
                registered.len()
            );
            if !elsewhere.is_empty() {
                message.push_str(&format!(
                    " ; handlers servis par un autre nœud : {}",
                    elsewhere.join(", ")
                ));
            }
            return Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                elapsed(),
                Some(message),
            ));
        }
        Ok(HealthCheckResult::degraded(
            self.module_id.clone(),
            elapsed(),
            Some(problems.join(" ; ")),
        ))
    }
}

/// Message d'une tâche `handler` qu'aucun nœud actif ne sert : tâche, exécutions en attente,
/// date de la plus ancienne et hôte absent (dernier hôte qui la servait).
fn unserved_task_message(task: &UnservedTask) -> String {
    let oldest = to_timestamp("oldest", &task.oldest)
        .map(|at| at.to_string())
        .unwrap_or_else(|_| task.oldest.to_sql());
    let host = match &task.last_host {
        Some(host) => format!("hôte absent : {host}"),
        None => "aucun hôte ne l'a servie depuis un jour".to_string(),
    };
    format!(
        "tâche {} sans nœud actif qui a son handler : {} exécution(s) en attente depuis {oldest} ({host})",
        task.task, task.waiting
    )
}
