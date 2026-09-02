use super::context::HandlerContext;
use super::event::Event;
use super::handler::Handler;
use crate::error::LyxalEventError;
use crate::models::LyxalEventEnvelope;
use std::future::Future;
use std::marker::PhantomData;
use std::pin::Pin;
use std::sync::Arc;

/// Type d'alias pour les futures boxed et send retournées par les handlers effacés.
pub type BoxFuture<'a, T> = Pin<Box<dyn Future<Output = T> + Send + 'a>>;

/// Trait d'effacement de type permettant de stocker des handlers hétérogènes dans un registre.
pub trait ErasedHandler: Send + Sync + 'static {
    /// Type d'événement géré par ce handler.
    fn event_type(&self) -> &'static str;

    /// Décode l'enveloppe et délègue au handler fortement typé sous-jacent.
    fn handle<'a>(
        &'a self,
        envelope: &'a LyxalEventEnvelope,
        ctx: &'a HandlerContext,
    ) -> BoxFuture<'a, Result<(), LyxalEventError>>;
}

/// Adaptateur transformant un `Handler<E>` typé en `ErasedHandler`.
pub struct TypedHandler<E, H>
where
    E: Event,
    H: Handler<E>,
{
    handler: Arc<H>,
    _marker: PhantomData<fn() -> E>,
}

impl<E, H> TypedHandler<E, H>
where
    E: Event,
    H: Handler<E>,
{
    /// Enveloppe un nouveau handler dans l'adaptateur typé.
    #[must_use]
    pub fn new(handler: H) -> Self {
        Self {
            handler: Arc::new(handler),
            _marker: PhantomData,
        }
    }

    /// Enveloppe un handler partagé derrière un Arc.
    #[must_use]
    pub fn shared(handler: Arc<H>) -> Self {
        Self {
            handler,
            _marker: PhantomData,
        }
    }
}

impl<E, H> ErasedHandler for TypedHandler<E, H>
where
    E: Event,
    H: Handler<E>,
{
    fn event_type(&self) -> &'static str {
        E::EVENT_TYPE
    }

    fn handle<'a>(
        &'a self,
        envelope: &'a LyxalEventEnvelope,
        ctx: &'a HandlerContext,
    ) -> BoxFuture<'a, Result<(), LyxalEventError>> {
        Box::pin(async move {
            let event: E = envelope.decode()?;
            self.handler.handle(event, ctx).await
        })
    }
}
