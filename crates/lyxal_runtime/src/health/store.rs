use crate::error::RuntimeError;
use crate::health::check::HealthCheckResult;
use crate::health::snapshot::HealthSnapshot;
use crate::health::status::HealthStatus;
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_surreal::SurrealValue;
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

#[derive(Debug, SurrealValue)]
struct SystemHealthRow {
    pub node_id: String,
    pub module_id: String,
    pub status: String,
    pub latency_ms: Option<u64>,
    pub message: Option<String>,
    pub checked_at: Option<lyxal_surreal::Datetime>,
    pub updated_at: Option<lyxal_surreal::Datetime>,
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

#[async_trait]
impl HealthStore for SurrealHealthStore {
    async fn record_health_snapshot(
        &self,
        node_id: &NodeId,
        snapshot: &HealthSnapshot,
    ) -> Result<(), RuntimeError> {
        for (module_id, res) in &snapshot.modules {
            let key = format!(
                "{}_{}",
                node_id.as_str().replace([':', '.', '-'], "_"),
                module_id.as_str().replace([':', '.', '-'], "_")
            );

            let query = r#"
                UPSERT ONLY type::record('runtime_health', $key) SET
                    node_id = $node_id,
                    module_id = $module_id,
                    status = $status,
                    latency_ms = $latency_ms,
                    message = $message,
                    checked_at = time::now(),
                    updated_at = time::now();
            "#;

            let db_res = self
                .client
                .query(query)
                .bind(("key", key))
                .bind(("node_id", node_id.to_string()))
                .bind(("module_id", module_id.to_string()))
                .bind(("status", res.status.as_str().to_string()))
                .bind(("latency_ms", res.latency_ms))
                .bind(("message", res.message.clone()))
                .await
                .map_err(|err| RuntimeError::Internal {
                    code: "RUNTIME_HEALTH_PERSISTENCE_FAILED",
                    message: format!(
                        "Failed to persist health for module '{}' on node '{}': {}",
                        module_id, node_id, err
                    ),
                })?;

            db_res.check().map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_HEALTH_PERSISTENCE_FAILED",
                message: format!(
                    "Check failed on persisting health for module '{}': {}",
                    module_id, err
                ),
            })?;
        }

        Ok(())
    }

    async fn get_node_health(
        &self,
        node_id: &NodeId,
    ) -> Result<Option<HealthSnapshot>, RuntimeError> {
        let query = "SELECT * FROM runtime_health WHERE node_id = $node_id ORDER BY module_id ASC;";

        let mut res = self
            .client
            .query(query)
            .bind(("node_id", node_id.to_string()))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "RUNTIME_HEALTH_QUERY_FAILED",
                message: format!("Failed to query health for node '{}': {}", node_id, err),
            })?;

        let rows: Vec<SystemHealthRow> = res.take(0).map_err(|err| RuntimeError::Internal {
            code: "RUNTIME_HEALTH_DATA_INVALID",
            message: format!("Failed to deserialize runtime_health rows: {}", err),
        })?;

        if rows.is_empty() {
            return Ok(None);
        }

        let mut results = Vec::new();
        for r in rows {
            let status = match r.status.as_str() {
                "healthy" => HealthStatus::Healthy,
                "degraded" => HealthStatus::Degraded,
                "unhealthy" => HealthStatus::Unhealthy,
                "unknown" => HealthStatus::Unknown,
                _ => HealthStatus::NotApplicable,
            };

            let checked_at_str = r
                .checked_at
                .map(|d| d.to_string())
                .unwrap_or_else(crate::health::check::chrono_now_string);

            results.push(HealthCheckResult {
                module_id: ModuleId::new(r.module_id),
                status,
                checked_at: checked_at_str,
                latency_ms: r.latency_ms,
                message: r.message,
            });
        }

        Ok(Some(HealthSnapshot::new(results)))
    }
}
