use super::context::HandlerContext;
use super::event::Event;
use crate::error::LyxalEventError;
use async_trait::async_trait;

/// Contrat asynchrone fortement typé pour le traitement d'un événement `E`.
#[async_trait]
pub trait Handler<E: Event>: Send + Sync + 'static {
    /// Traite l'événement typé avec le contexte d'exécution fourni.
    async fn handle(&self, event: E, ctx: &HandlerContext) -> Result<(), LyxalEventError>;
}
