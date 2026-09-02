use crate::error::RuntimeError;
use crate::types::ModuleId;
use crate::worker::context::WorkerContext;
use crate::worker::definition::LyxalWorker;
use crate::worker::descriptor::{WorkerCriticality, WorkerDescriptor};
use crate::worker::id::WorkerId;
use crate::worker::restart::{RestartPolicy, WorkerRestartBackoff};
use async_trait::async_trait;
use lyxal_event::EventWorker;
use std::sync::Arc;
use std::time::Duration;

/// Adaptateur encapsulant `EventWorker` de `lyxal_event` sous le contrat officiel `LyxalWorker`.
///
/// Cela permet au `WorkerSupervisor` du runtime de gérer directement :
/// - Le cycle de vie supervisé (démarrage, pause, arrêt gracieux) ;
/// - L'annulation coopérative via `CancellationToken` ;
/// - La politique de redémarrage après crash ;
/// - Les métriques et statuts de santé (`HealthEngine`).
pub struct EventWorkerService {
    descriptor: WorkerDescriptor,
    inner: Arc<EventWorker>,
}

impl EventWorkerService {
    /// Crée un nouvel adaptateur pour le worker d'événements.
    #[must_use]
    pub fn new(inner: Arc<EventWorker>, shutdown_timeout: Duration) -> Self {
        let module_id = ModuleId::new("lyxal_event");
        let id = WorkerId::new(&module_id, "event_worker").expect("valid worker id");
        let mut descriptor = WorkerDescriptor::new(id, module_id, "Lyxal Event Worker")
            .with_description("Consommateur et dispatcheur asynchrone d'événements Lyxal OS")
            .with_criticality(WorkerCriticality::Required)
            .with_shutdown_timeout(shutdown_timeout);
        descriptor.restart_policy = RestartPolicy::Always {
            max_retries: None,
            backoff: WorkerRestartBackoff::default(),
        };

        Self { descriptor, inner }
    }

    /// Retourne une référence vers le worker d'événements interne.
    #[must_use]
    pub fn inner(&self) -> &Arc<EventWorker> {
        &self.inner
    }
}

#[async_trait]
impl LyxalWorker for EventWorkerService {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.inner
            .run(ctx.cancellation)
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_WORKER_EXECUTION_FAILED",
                message: format!("Event worker encountered fatal error: {err}"),
            })
    }
}
