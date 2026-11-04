//! Module `lyxal_pipeline_ingestion` : implémentation `LyxalModule`, worker supervisé et sonde de
//! santé, enregistrés auprès du runtime.

use crate::error::ServerError;
use lyxal_event::{EventContext, EventPublisher};
use lyxal_pipeline_ingestion::{
    IngestionHealthCheck, IngestionStore, IngestionWorker, PipelineIngestionModule,
};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = "lyxal_pipeline_ingestion";

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(PipelineIngestionModule::new())
}

pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    context: &EventContext,
) -> Result<(), ServerError> {
    let store = IngestionStore::new(client.clone());
    let event_store = runtime.event_store().ok_or(ServerError::Runtime(
        lyxal_runtime::RuntimeError::StoreMissing {
            component: "event_store",
        },
    ))?;
    let publisher = EventPublisher::new(event_store.clone(), MODULE_ID, context.clone());
    runtime.register_worker(Arc::new(
        IngestionWorker::new(store.clone()).with_publisher(publisher),
    ))?;
    runtime
        .health_registry()
        .register_check(Arc::new(IngestionHealthCheck::with_store(store)))?;
    Ok(())
}
