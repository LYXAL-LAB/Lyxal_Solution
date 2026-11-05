//! Module `lyxal_pipeline_ingestion` : implémentation `LyxalModule`, worker supervisé et sonde de
//! santé, enregistrés auprès du runtime.

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_event::{EventContext, EventPublisher, EventSubscription};
use lyxal_pipeline_ingestion::publisher::{
    PUBLICATION_HANDLER, PUBLICATION_MODULE, PUBLICATION_SUBSCRIPTION,
};
use lyxal_pipeline_ingestion::{
    CatalogueSyncKey, ControlledPublisher, HmacCatalogueTokenIssuer, IngestionHealthCheck,
    IngestionStore, IngestionWorker, PipelineIngestionModule, PublicationConsumer,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = "lyxal_pipeline_ingestion";

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(PipelineIngestionModule::new())
}

/// Accès JWT de l'agent de synchronisation du catalogue, défini par l'hôte.
pub const CATALOGUE_SYNC_ACCESS: &str = "lyxal_catalogue_sync";
/// Durée de validité d'un jeton de publication.
const CATALOGUE_SYNC_TOKEN_TTL: Duration = Duration::from_secs(300);
/// Tentatives de livraison de l'événement d'approbation avant lettre morte.
const PUBLICATION_MAX_ATTEMPTS: u32 = 10;

/// Publication activée : clé à installer dans l'accès JWT après l'installation des modules.
pub struct PublicationSetup {
    key: CatalogueSyncKey,
}

fn configuration_error(error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("catalogue_sync.signing_key : {error}"),
    }
}

/// Worker, sonde de santé et, si la clé de signature est fournie, consommateur de
/// `ingestion.manifest.approved` qui publie les manifestes approuvés vers le catalogue.
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    context: &EventContext,
    config: &AppConfig,
) -> Result<Option<PublicationSetup>, ServerError> {
    let store = IngestionStore::new(client.clone());
    let event_store = runtime.event_store().ok_or(ServerError::Runtime(
        lyxal_runtime::RuntimeError::StoreMissing {
            component: "event_store",
        },
    ))?;
    let events = || EventPublisher::new(event_store.clone(), MODULE_ID, context.clone());
    runtime.register_worker(Arc::new(
        IngestionWorker::new(store.clone())?.with_publisher(events()),
    ))?;

    let setup = match &config.catalogue_sync.signing_key {
        Some(secret) => {
            let key = CatalogueSyncKey::parse(secret.to_secret()?).map_err(configuration_error)?;
            let issuer = HmacCatalogueTokenIssuer::new(
                &key,
                config.database.namespace.clone(),
                config.database.database.clone(),
                CATALOGUE_SYNC_ACCESS,
                CATALOGUE_SYNC_TOKEN_TTL,
            )
            .map_err(configuration_error)?;
            let publisher = ControlledPublisher::new(client.clone(), Arc::new(issuer))
                .with_event_publisher(events());
            runtime
                .register_event_consumer(Arc::new(PublicationConsumer::new(Arc::new(publisher))))
                .await;
            Some(PublicationSetup { key })
        }
        None => {
            tracing::warn!(
                "publication vers le catalogue désactivée : LYXAL__CATALOGUE_SYNC__SIGNING_KEY absente"
            );
            None
        }
    };

    runtime.health_registry().register_check(Arc::new(
        IngestionHealthCheck::with_store(store).with_publication(setup.is_some()),
    ))?;
    Ok(setup)
}

/// Après l'installation des modules : accès JWT de l'agent de synchronisation (clé de la
/// configuration) et abonnement de la publication à `ingestion.manifest.approved`.
pub async fn enable_publication(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    setup: &PublicationSetup,
) -> Result<(), ServerError> {
    // La clé est contrôlée par `CatalogueSyncKey::parse` (32 caractères A-Z a-z 0-9 _ -) :
    // aucun caractère à échapper dans la définition.
    client
        .query(format!(
            "DEFINE ACCESS OVERWRITE {CATALOGUE_SYNC_ACCESS} ON DATABASE TYPE JWT ALGORITHM HS256 KEY '{}' DURATION FOR SESSION 15m;",
            setup.key.expose_secret()
        ))
        .await
        .and_then(|response| response.check())
        .map_err(|error| ServerError::Database {
            message: format!("accès {CATALOGUE_SYNC_ACCESS} : {error}"),
        })?;

    let event_store = runtime.event_store().ok_or(ServerError::Runtime(
        lyxal_runtime::RuntimeError::StoreMissing {
            component: "event_store",
        },
    ))?;
    event_store
        .register_subscription(&EventSubscription {
            id: None,
            name: PUBLICATION_SUBSCRIPTION.to_string(),
            target_module: PUBLICATION_MODULE.to_string(),
            event_pattern: "ingestion.manifest.approved".to_string(),
            handler_name: PUBLICATION_HANDLER.to_string(),
            is_active: true,
            max_attempts: PUBLICATION_MAX_ATTEMPTS,
            created_at: None,
        })
        .await
        .map_err(|error| ServerError::Database {
            message: format!("abonnement {PUBLICATION_SUBSCRIPTION} : {error}"),
        })?;
    Ok(())
}
