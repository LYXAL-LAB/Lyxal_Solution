//! Déclenchement de la publication à l'approbation d'un manifeste.
//!
//! L'événement `ingestion.manifest.approved` (émis par la base quand un manifeste passe à
//! `APPROVED`) est livré au moins une fois par `lyxal_event` ; la publication est idempotente
//! (journal d'exécution du manifeste, manifeste exécuté jamais republié).

use async_trait::async_trait;
use lyxal_event::{Handler, HandlerContext, HandlerRegistry, LyxalEventError};
use lyxal_runtime::{EventConsumerModule, RuntimeError};
use std::sync::Arc;

use super::controlled_publisher::ControlledPublisher;
use crate::events::ManifestApprovedEvent;

/// Nom de l'abonnement persistant de la publication.
pub const PUBLICATION_SUBSCRIPTION: &str = "ingestion_manifest_publication";
/// Nom du handler de publication.
pub const PUBLICATION_HANDLER: &str = "ingestion.manifest_publisher";
/// Module consommateur.
pub const PUBLICATION_MODULE: &str = "lyxal_pipeline_ingestion";

/// Publie le manifeste approuvé désigné par l'événement.
pub struct ManifestApprovedHandler {
    publisher: Arc<ControlledPublisher>,
}

impl ManifestApprovedHandler {
    pub fn new(publisher: Arc<ControlledPublisher>) -> Self {
        Self { publisher }
    }
}

#[async_trait]
impl Handler<ManifestApprovedEvent> for ManifestApprovedHandler {
    async fn handle(
        &self,
        event: ManifestApprovedEvent,
        ctx: &HandlerContext,
    ) -> Result<(), LyxalEventError> {
        self.publisher
            .publish_manifest(&event.manifest_ref)
            .await
            .map(|_| ())
            .map_err(|err| LyxalEventError::HandlerFailed {
                event_id: ctx.event_id.0,
                event_type: "ingestion.manifest.approved".to_string(),
                error: format!("{} : {err}", err.code()),
                // Une panne de base est rejouée ; un manifeste non publiable (état, sceau)
                // part en lettre morte.
                terminal: !err.info().retryable,
            })
    }
}

/// Consommateur d'événements du pipeline : publication des manifestes approuvés.
pub struct PublicationConsumer {
    publisher: Arc<ControlledPublisher>,
}

impl PublicationConsumer {
    pub fn new(publisher: Arc<ControlledPublisher>) -> Self {
        Self { publisher }
    }
}

impl EventConsumerModule for PublicationConsumer {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry
            .register::<ManifestApprovedEvent, _>(ManifestApprovedHandler::new(
                self.publisher.clone(),
            ))
            .map_err(|e| RuntimeError::EventEngineError {
                message: e.to_string(),
            })?;
        Ok(())
    }
}
