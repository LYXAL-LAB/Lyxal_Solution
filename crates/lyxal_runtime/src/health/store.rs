use crate::error::RuntimeError;
use crate::health::check::HealthCheckResult;
use crate::health::snapshot::HealthSnapshot;
use crate::health::status::HealthStatus;
use crate::lock::node_id::NodeId;
use crate::store::dto::{HealthRecordParams, HealthRow, NodeParams};
use crate::store::surreal::store_error;
use crate::types::ModuleId;
use async_trait::async_trait;
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Abstraction de persistance pour l'état de santé instantané des modules du nœud.
#[async_trait]
pub trait HealthStore: Send + Sync {
    /// Enregistre l'état de santé courant des modules pour un nœud donné.
    async fn record_health_snapshot(
        &self,
        node_id: &NodeId,
        snapshot: &HealthSnapshot,
    ) -> Result<(), RuntimeError>;

    /// Récupère l'état de santé courant d'un nœud donné.
    async fn get_node_health(
        &self,
        node_id: &NodeId,
    ) -> Result<Option<HealthSnapshot>, RuntimeError>;
}

/// Implémentation en mémoire de `HealthStore` pour tests unitaires.
#[derive(Default, Clone)]
pub struct MemoryHealthStore {
    data: Arc<RwLock<HashMap<NodeId, HealthSnapshot>>>,
}

impl MemoryHealthStore {
    /// Crée un store de santé en mémoire.
    pub fn new() -> Self {
        Self {
            data: Arc::new(RwLock::new(HashMap::new())),
        }
    }
}

#[async_trait]
impl HealthStore for MemoryHealthStore {
    async fn record_health_snapshot(
        &self,
        node_id: &NodeId,
        snapshot: &HealthSnapshot,
    ) -> Result<(), RuntimeError> {
        let mut map = self.data.write().map_err(|_| RuntimeError::Internal {
            code: "MEMORY_HEALTH_STORE_POISONED",
            message: "MemoryHealthStore write lock was poisoned".to_string(),
        })?;
        map.insert(node_id.clone(), snapshot.clone());
        Ok(())
    }

    async fn get_node_health(
        &self,
        node_id: &NodeId,
    ) -> Result<Option<HealthSnapshot>, RuntimeError> {
        let map = self.data.read().map_err(|_| RuntimeError::Internal {
            code: "MEMORY_HEALTH_STORE_POISONED",
            message: "MemoryHealthStore read lock was poisoned".to_string(),
        })?;
        Ok(map.get(node_id).cloned())
    }
}

/// Implémentation SurrealDB officielle de `HealthStore`.
#[derive(Clone)]
pub struct SurrealHealthStore {
    client: Surreal<Any>,
}

impl SurrealHealthStore {
    /// Construit un `SurrealHealthStore` avec un client SurrealDB connecté.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Initialise le schéma de la table `runtime_health` de manière idempotente.
    pub async fn bootstrap(&self) -> Result<(), RuntimeError> {
        crate::schema::install_runtime_schema(&self.client).await
    }
}

impl lyxal_surreal::LyxalSurrealCall for SurrealHealthStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

fn health_status(value: &str) -> Result<HealthStatus, RuntimeError> {
    Ok(match value {
        "healthy" => HealthStatus::Healthy,
        "degraded" => HealthStatus::Degraded,
        "unhealthy" => HealthStatus::Unhealthy,
        "unknown" => HealthStatus::Unknown,
        "not_applicable" => HealthStatus::NotApplicable,
        other => {
            return Err(RuntimeError::StoreFailed {
                operation: "runtime_health",
                message: format!("statut de santé inconnu : {other}"),
            })
        }
    })
}

#[async_trait]
impl HealthStore for SurrealHealthStore {
    async fn record_health_snapshot(
        &self,
        node_id: &NodeId,
        snapshot: &HealthSnapshot,
    ) -> Result<(), RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        for (module_id, res) in &snapshot.modules {
            let latency_ms = res
                .latency_ms
                .map(|v| {
                    i64::try_from(v).map_err(|_| RuntimeError::StoreFailed {
                        operation: "runtime_health_record",
                        message: format!("latency_ms hors bornes : {v}"),
                    })
                })
                .transpose()?;
            let _: HealthRow = self
                .call_fn(
                    "runtime_health_record",
                    HealthRecordParams {
                        node_id: node_id.to_string(),
                        module_id: module_id.to_string(),
                        status: res.status.as_str().to_string(),
                        latency_ms,
                        message: res.message.clone(),
                    },
                )
                .await
                .map_err(|e| store_error("runtime_health_record", e))?;
        }
        Ok(())
    }

    async fn get_node_health(
        &self,
        node_id: &NodeId,
    ) -> Result<Option<HealthSnapshot>, RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        let rows: Vec<HealthRow> = self
            .call_fn(
                "runtime_health_list",
                NodeParams {
                    node_id: node_id.to_string(),
                },
            )
            .await
            .map_err(|e| store_error("runtime_health_list", e))?;
        if rows.is_empty() {
            return Ok(None);
        }
        let mut results = Vec::with_capacity(rows.len());
        for row in rows {
            results.push(HealthCheckResult {
                module_id: ModuleId::new(row.module_id),
                status: health_status(&row.status)?,
                checked_at: row.checked_at.to_string(),
                latency_ms: row
                    .latency_ms
                    .map(|v| {
                        u64::try_from(v).map_err(|_| RuntimeError::StoreFailed {
                            operation: "runtime_health_list",
                            message: format!("latency_ms négatif : {v}"),
                        })
                    })
                    .transpose()?,
                message: row.message,
            });
        }
        Ok(Some(HealthSnapshot::new(results)))
    }
}
