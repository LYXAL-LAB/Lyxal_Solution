use crate::error::RuntimeError;
use crate::worker::context::WorkerContext;
use crate::worker::descriptor::WorkerDescriptor;
use async_trait::async_trait;

/// Contrat officiel que tout service d'arrière-plan de module Lyxal doit implémenter.
#[async_trait]
pub trait LyxalWorker: Send + Sync + 'static {
    /// Retourne le descripteur statique du worker.
    fn descriptor(&self) -> &WorkerDescriptor;

    /// Exécute la logique de traitement du worker en boucle ou au long cours.
    ///
    /// Le worker doit surveiller régulièrement `ctx.cancellation.cancelled()` ou l'intégrer
    /// dans un `tokio::select!` pour libérer promptement ses ressources lors d'un arrêt gracieux.
    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError>;
}
