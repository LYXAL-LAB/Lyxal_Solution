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
}

impl IngestionHealthCheck {
    /// Construit une sonde de santé autonome (mode hors store)
    pub fn new() -> Self {
        Self {
            module_id: ModuleId::new("lyxal_pipeline_ingestion"),
            store: None,
        }
    }

    /// Construit une sonde de santé connectée au store SurrealDB
    pub fn with_store(store: IngestionStore) -> Self {
        Self {
            module_id: ModuleId::new("lyxal_pipeline_ingestion"),
            store: Some(store),
        }
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
