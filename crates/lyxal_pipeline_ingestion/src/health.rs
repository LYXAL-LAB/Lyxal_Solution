//! Contrôles de santé et observabilité industrielle pour Lyxal Pipeline Ingestion.
//!
//! Conforme au contrat officiel `lyxal_runtime::health::ModuleHealthCheck` (AGENTS.md § 5.8.4).

use async_trait::async_trait;
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{ModuleContext, RuntimeError};

use crate::storage::store::IngestionStore;

/// Sonde de santé officielle pour le pipeline d'ingestion Lyxal OS.
pub struct IngestionHealthCheck {
    module_id: ModuleId,
    store: Option<IngestionStore>,
    publication_enabled: bool,
    source_storage: bool,
}

impl IngestionHealthCheck {
    /// Construit une sonde de santé autonome (mode hors store)
    pub fn new() -> Self {
        Self {
            module_id: ModuleId::new("lyxal_pipeline_ingestion"),
            store: None,
            publication_enabled: true,
            source_storage: true,
        }
    }

    /// Construit une sonde de santé connectée au store SurrealDB
    pub fn with_store(store: IngestionStore) -> Self {
        Self {
            module_id: ModuleId::new("lyxal_pipeline_ingestion"),
            store: Some(store),
            publication_enabled: true,
            source_storage: true,
        }
    }

    /// Publication vers le catalogue active ou non (clé de signature fournie à l'hôte) ; sans
    /// publication, la sonde est dégradée.
    pub fn with_publication(mut self, enabled: bool) -> Self {
        self.publication_enabled = enabled;
        self
    }
}

impl IngestionHealthCheck {
    /// Stockage des fichiers sources configuré ou non (un support `lyxal_storage` au moins) ;
    /// sans lui, aucun lot n'est traité et la sonde est dégradée.
    pub fn with_source_storage(mut self, configured: bool) -> Self {
        self.source_storage = configured;
        self
    }
}

impl Default for IngestionHealthCheck {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl ModuleHealthCheck for IngestionHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    /// Exécute l'évaluation de santé du module d'ingestion.
    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let start = std::time::Instant::now();
        if let Some(store) = &self.store {
            match store.get_dashboard_metrics(None).await {
                Ok(_metrics) if !self.source_storage => Ok(HealthCheckResult::degraded(
                    self.module_id.clone(),
                    start.elapsed().as_millis() as u64,
                    Some(
                        "Aucun lot traité : stockage des fichiers sources non configuré (LYXAL__STORAGE__DISK__ROOT)"
                            .to_string(),
                    ),
                )),
                Ok(_metrics) if !self.publication_enabled => Ok(HealthCheckResult::degraded(
                    self.module_id.clone(),
                    start.elapsed().as_millis() as u64,
                    Some(
                        "Publication vers le catalogue désactivée : clé de signature du jeton de service absente (LYXAL__CATALOGUE_SYNC__SIGNING_KEY)"
                            .to_string(),
                    ),
                )),
                Ok(_metrics) => {
                    let latency = start.elapsed().as_millis() as u64;
                    Ok(HealthCheckResult::healthy(
                        self.module_id.clone(),
                        latency,
                        Some("Pipeline ingestion engine and SurrealDB healthy".to_string()),
                    ))
                }
                Err(e) => {
                    let latency = start.elapsed().as_millis() as u64;
                    Ok(HealthCheckResult::degraded(
                        self.module_id.clone(),
                        latency,
                        Some(format!("Pipeline database query degraded: {e}")),
                    ))
                }
            }
        } else {
            Ok(HealthCheckResult::healthy(
                self.module_id.clone(),
                0,
                Some("Pipeline ingestion module healthy (standalone)".to_string()),
            ))
        }
    }
}
