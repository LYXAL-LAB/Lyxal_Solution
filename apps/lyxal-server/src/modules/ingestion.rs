//! Module `lyxal_pipeline_ingestion` : implémentation `LyxalModule`, worker supervisé et sonde de
//! santé, enregistrés auprès du runtime.

use crate::context::StorageHost;
use crate::error::ServerError;
use crate::modules::auth::AuthHost;
use async_trait::async_trait;
use lyxal_crypto::SecretString;
use lyxal_event::EventSubscription;
use lyxal_pipeline_ingestion::error::{IngestionError, IngestionResult};
use lyxal_pipeline_ingestion::publisher::{
    CatalogueTokenIssuer, CATALOGUE_SYNC_CLIENT_ID, PUBLICATION_HANDLER, PUBLICATION_MODULE,
    PUBLICATION_SUBSCRIPTION,
};
use lyxal_pipeline_ingestion::{
    ControlledPublisher, IngestionHealthCheck, IngestionStore, IngestionWorker,
    PipelineIngestionModule, PublicationConsumer, SOURCE_BUCKET,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_storage::models::BucketCreateParams;
use lyxal_storage::{StorageService, StorageStore};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = "lyxal_pipeline_ingestion";

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(PipelineIngestionModule::new())
}

/// Tentatives de livraison de l'événement d'approbation avant lettre morte.
const PUBLICATION_MAX_ATTEMPTS: u32 = 10;

/// Jetons du compte de service `lyxal-catalogue-sync` (rôle `catalogue_sync`), ouverts par la
/// session système de l'hôte, sans secret : un jeton frais par publication.
struct AuthCatalogueTokenIssuer {
    host: Arc<AuthHost>,
}

#[async_trait]
impl CatalogueTokenIssuer for AuthCatalogueTokenIssuer {
    async fn issue(&self) -> IngestionResult<SecretString> {
        self.host
            .access
            .internal_service_token(CATALOGUE_SYNC_CLIENT_ID)
            .await
            .map(|issued| issued.access_token)
            .map_err(|error| {
                IngestionError::Validation(format!(
                    "session du compte de synchronisation : {} ({error})",
                    error.code()
                ))
            })
    }
}

/// Worker, sonde de santé et, si le service de connexion `lyxal_auth` est configuré,
/// consommateur de `ingestion.manifest.approved` qui publie les manifestes approuvés vers le
/// catalogue. Retourne `true` si la publication est active.
pub async fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    auth: Option<&Arc<AuthHost>>,
    storage: &StorageHost,
) -> Result<bool, ServerError> {
    let store = IngestionStore::new(client.clone());
    // Fichiers sources des lots lus dans lyxal_storage, sous la session système de l'hôte
    let sources = StorageService::new(StorageStore::new(client.clone()), storage.backends.clone());
    let source_storage = sources.is_configured();
    if !source_storage {
        tracing::warn!(
            "ingestion en attente : stockage des fichiers sources non configuré (LYXAL__STORAGE__DISK__ROOT)"
        );
    }
    runtime.register_worker(Arc::new(IngestionWorker::new(store.clone(), sources)?))?;

    let publication = match auth {
        Some(host) => {
            let issuer = AuthCatalogueTokenIssuer { host: host.clone() };
            let publisher = ControlledPublisher::new(client.clone(), Arc::new(issuer));
            runtime
                .register_event_consumer(Arc::new(PublicationConsumer::new(Arc::new(publisher))))
                .await;
            true
        }
        None => {
            tracing::warn!(
                "publication vers le catalogue désactivée : service de connexion lyxal_auth non configuré (clé applicative ou auth.public_url absente)"
            );
            false
        }
    };

    runtime.health_registry().register_check(Arc::new(
        IngestionHealthCheck::with_store(store)
            .with_publication(publication)
            .with_source_storage(source_storage),
    ))?;
    Ok(publication)
}

/// Après l'installation des modules : bucket de l'installation qui conserve les fichiers sources
/// des lots, créé s'il n'existe pas (rejouable).
pub async fn ensure_source_bucket(client: &Surreal<Any>) -> Result<(), ServerError> {
    let created = StorageStore::new(client.clone())
        .bucket_create(BucketCreateParams::named(None, SOURCE_BUCKET))
        .await;
    match created {
        Ok(_) => {
            tracing::info!(bucket = SOURCE_BUCKET, "bucket des fichiers sources créé");
            Ok(())
        }
        Err(error) if error.is_business_code("STORAGE_BUCKET_EXISTS") => Ok(()),
        Err(error) => Err(ServerError::ModuleInstall {
            module: MODULE_ID.to_string(),
            message: format!("bucket {SOURCE_BUCKET} non créé : {error}"),
        }),
    }
}

/// Après l'installation des modules : abonnement de la publication à
/// `ingestion.manifest.approved`, actif avec le service de connexion `lyxal_auth`, suspendu sans
/// lui : les approbations attendent alors en file au lieu d'épuiser leurs essais sans publisher,
/// et reprennent quand le service est configuré.
pub async fn reconcile_publication(
    runtime: &LyxalRuntime,
    publication: bool,
) -> Result<(), ServerError> {
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
            is_active: publication,
            max_attempts: PUBLICATION_MAX_ATTEMPTS,
            created_at: None,
        })
        .await
        .map_err(|error| ServerError::Database {
            message: format!("abonnement {PUBLICATION_SUBSCRIPTION} : {error}"),
        })?;
    Ok(())
}
