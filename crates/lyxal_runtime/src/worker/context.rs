use crate::context::ModuleContext;
use crate::types::ModuleId;
use crate::worker::id::WorkerId;
pub use tokio_util::sync::CancellationToken;

/// Contexte d'exécution contrôlé fourni à chaque worker par le `WorkerSupervisor`.
#[derive(Clone)]
pub struct WorkerContext {
    /// Identifiant du module propriétaire.
    pub module_id: ModuleId,
    /// Identifiant unique du worker.
    pub worker_id: WorkerId,
    /// Contexte d'exécution du module.
    pub module_context: ModuleContext,
    /// Jeton d'annulation asynchrone pour la coopération au graceful shutdown.
    pub cancellation: CancellationToken,
}

impl WorkerContext {
    /// Crée un nouveau contexte de worker.
    pub fn new(
        module_id: ModuleId,
        worker_id: WorkerId,
        module_context: ModuleContext,
        cancellation: CancellationToken,
    ) -> Self {
        Self {
            module_id,
            worker_id,
            module_context,
            cancellation,
        }
    }

    /// Indique si l'annulation a été demandée par le Runtime.
    pub fn is_cancelled(&self) -> bool {
        self.cancellation.is_cancelled()
    }
}
