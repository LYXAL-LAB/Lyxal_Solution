use crate::error::RuntimeError;
use crate::types::ModuleId;
use crate::worker::context::WorkerContext;
use crate::worker::definition::LyxalWorker;
use crate::worker::descriptor::{WorkerCriticality, WorkerDescriptor};
use crate::worker::id::WorkerId;
use crate::worker::restart::{RestartPolicy, WorkerRestartBackoff};
use async_trait::async_trait;
use lyxal_event::GarbageCollector;
use std::sync::Arc;
use std::time::Duration;

/// Adaptateur encapsulant `GarbageCollector` de `lyxal_event` sous le contrat officiel `LyxalWorker`.
pub struct EventGarbageCollectorService {
    descriptor: WorkerDescriptor,
    inner: Arc<GarbageCollector>,
}

impl EventGarbageCollectorService {
    /// Crée un nouvel adaptateur pour le ramasse-miettes d'événements.
    #[must_use]
    pub fn new(inner: Arc<GarbageCollector>, shutdown_timeout: Duration) -> Self {
        let module_id = ModuleId::new("lyxal_event");
        let id = WorkerId::new(&module_id, "event_gc").expect("valid worker id");
        let mut descriptor = WorkerDescriptor::new(id, module_id, "Lyxal Event Garbage Collector")
            .with_description("Purge périodique des événements archivés et livraisons finalisées")
            .with_criticality(WorkerCriticality::Optional)
            .with_shutdown_timeout(shutdown_timeout);
        descriptor.restart_policy = RestartPolicy::Always {
            max_retries: None,
            backoff: WorkerRestartBackoff::default(),
        };

        Self { descriptor, inner }
    }

    /// Retourne une référence vers le Garbage Collector interne.
    #[must_use]
    pub fn inner(&self) -> &Arc<GarbageCollector> {
        &self.inner
    }
}

#[async_trait]
impl LyxalWorker for EventGarbageCollectorService {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        self.inner
            .run(ctx.cancellation)
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_GC_EXECUTION_FAILED",
                message: format!("Event garbage collector encountered error: {err}"),
            })
    }
}
