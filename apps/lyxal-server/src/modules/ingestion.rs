//! Adaptateur hôte officiel pour le module `lyxal_pipeline_ingestion`.
//!
//! Raccorde le module d'ingestion industrielle au serveur hôte `lyxal_server`
//! conformément au contrat [`LyxalModule`] de l'hôte.

use crate::{
    error::ServerError,
    modules::{LyxalModule, ModuleContext, ModuleDescriptor, ModuleId},
};
use axum::Router;
use lyxal_pipeline_ingestion::IngestionStore;
use std::sync::Arc;
use tokio::sync::Mutex;

/// Module hôte pour l'ingestion industrielle des catalogues fabricants.
pub struct IngestionServerModule {
    descriptor: ModuleDescriptor,
    store: Arc<Mutex<Option<IngestionStore>>>,
}

impl IngestionServerModule {
    /// Crée une nouvelle instance de l'adaptateur hôte d'ingestion.
    pub fn new() -> Self {
        let id = ModuleId::new("lyxal-pipeline-ingestion")
            .unwrap_or_else(|error| panic!("identifiant interne invalide : {error}"));

        Self {
            descriptor: ModuleDescriptor {
                id,
                name: "Lyxal Pipeline Ingestion".into(),
                version: "0.1.0".into(),
                api_version: 1,
                description: "Moteur d'ingestion, normalisation et qualification des catalogues fabricants".into(),
                dependencies: vec![
                    ModuleId::new("lyxal-system").unwrap_or_else(|e| panic!("id system invalide: {e}")),
                ],
                required: false,
            },
            store: Arc::new(Mutex::new(None)),
        }
    }
}

impl Default for IngestionServerModule {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait::async_trait]
impl LyxalModule for IngestionServerModule {
    fn descriptor(&self) -> ModuleDescriptor {
        self.descriptor.clone()
    }

    async fn install(&self, context: &ModuleContext) -> Result<(), ServerError> {
        let store = IngestionStore::new(context.database.as_ref().clone());
        store
            .init_schema()
            .await
            .map_err(|e| ServerError::Runtime(format!("Échec de l'initialisation du schéma ingestion: {e}")))?;

        let mut lock = self.store.lock().await;
        *lock = Some(store);
        Ok(())
    }

    async fn start(&self, context: &ModuleContext) -> Result<(), ServerError> {
        let mut lock = self.store.lock().await;
        if lock.is_none() {
            let store = IngestionStore::new(context.database.as_ref().clone());
            *lock = Some(store);
        }
        tracing::info!("Module Lyxal Pipeline Ingestion démarré sur l'hôte lyxal_server");
        Ok(())
    }

    async fn stop(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        tracing::info!("Arrêt du module Lyxal Pipeline Ingestion sur l'hôte");
        let mut lock = self.store.lock().await;
        *lock = None;
        Ok(())
    }

    async fn health(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        let lock = self.store.lock().await;
        if let Some(ref store) = *lock {
            store
                .get_dashboard_metrics(None)
                .await
                .map_err(|e| ServerError::Runtime(format!("Sonde ingestion dégradée: {e}")))?;
        }
        Ok(())
    }

    fn router(&self) -> Router {
        // Zéro route métier HTTP : la console consomme exclusivement les fonctions SurrealQL
        Router::new()
    }
}
