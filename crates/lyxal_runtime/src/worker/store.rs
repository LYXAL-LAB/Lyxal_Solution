use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use crate::worker::descriptor::WorkerCriticality;
use crate::worker::id::WorkerId;
use crate::worker::metrics::WorkerMetrics;
use crate::worker::state::WorkerState;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use std::time::SystemTime;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Enregistrement persistant d'un worker dans `system_worker`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct WorkerStoreRow {
    pub node_id: String,
    pub worker_id: String,
    pub module_id: String,
    pub state: String,
    pub criticality: String,
    pub restart_count: i64,
    pub failure_count: i64,
    pub last_error: Option<String>,
    pub started_at: Option<i64>,
    pub stopped_at: Option<i64>,
    pub updated_at: Option<String>,
}

/// Contrat de persistance locale de l'état des workers supervisés.
#[async_trait]
pub trait WorkerStore: Send + Sync {
    /// Initialise le schéma ou les structures de persistance.
    async fn bootstrap(&self) -> Result<(), RuntimeError>;

    /// Enregistre ou met à jour l'état et les métriques d'un worker.
    async fn upsert_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
        module_id: &ModuleId,
        state: WorkerState,
        criticality: WorkerCriticality,
        metrics: &WorkerMetrics,
    ) -> Result<(), RuntimeError>;

    /// Récupère l'état persisté d'un worker pour un nœud donné.
    async fn get_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
    ) -> Result<Option<WorkerStoreRow>, RuntimeError>;

    /// Liste l'ensemble des workers persistés sur un nœud.
    async fn list_node_workers(
        &self,
        node_id: &NodeId,
    ) -> Result<Vec<WorkerStoreRow>, RuntimeError>;
}

/// Implémentation en mémoire volatile de `WorkerStore`.
pub struct MemoryWorkerStore {
    workers: Arc<RwLock<HashMap<(String, String), WorkerStoreRow>>>,
}

impl Default for MemoryWorkerStore {
    fn default() -> Self {
        Self::new()
    }
}

impl MemoryWorkerStore {
    /// Crée un nouveau store mémoire.
    pub fn new() -> Self {
        Self {
            workers: Arc::new(RwLock::new(HashMap::new())),
        }
    }
}

#[async_trait]
impl WorkerStore for MemoryWorkerStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn upsert_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
        module_id: &ModuleId,
        state: WorkerState,
        criticality: WorkerCriticality,
        metrics: &WorkerMetrics,
    ) -> Result<(), RuntimeError> {
        let key = (node_id.to_string(), worker_id.to_string());
        let row = WorkerStoreRow {
            node_id: node_id.to_string(),
            worker_id: worker_id.to_string(),
            module_id: module_id.to_string(),
            state: state.as_str().to_string(),
            criticality: format!("{:?}", criticality).to_lowercase(),
            restart_count: metrics.restart_count as i64,
            failure_count: metrics.failure_count as i64,
            last_error: metrics.last_error.clone(),
            started_at: metrics.started_at.map(|v| v as i64),
            stopped_at: metrics.stopped_at.map(|v| v as i64),
            updated_at: Some(
                SystemTime::now()
                    .duration_since(SystemTime::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs()
                    .to_string(),
            ),
        };

        let mut lock = self.workers.write().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryWorkerStore write lock poisoned".to_string(),
        })?;
        lock.insert(key, row);
        Ok(())
    }

    async fn get_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
    ) -> Result<Option<WorkerStoreRow>, RuntimeError> {
        let key = (node_id.to_string(), worker_id.to_string());
        let lock = self.workers.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryWorkerStore read lock poisoned".to_string(),
        })?;
        Ok(lock.get(&key).cloned())
    }

    async fn list_node_workers(
        &self,
        node_id: &NodeId,
    ) -> Result<Vec<WorkerStoreRow>, RuntimeError> {
        let node_str = node_id.to_string();
        let lock = self.workers.read().map_err(|_| RuntimeError::Internal {
            code: "RUNTIME_LOCK_POISONED",
            message: "MemoryWorkerStore read lock poisoned".to_string(),
        })?;
        Ok(lock
            .values()
            .filter(|r| r.node_id == node_str)
            .cloned()
            .collect())
    }
}

/// Implémentation SurrealDB de `WorkerStore`.
pub struct SurrealWorkerStore {
    client: Surreal<Any>,
}

impl SurrealWorkerStore {
    /// Crée un nouveau store adossé à SurrealDB.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    fn make_key_id(node_id: &NodeId, worker_id: &WorkerId) -> String {
        format!(
            "{}_{}",
            node_id.as_str().replace([':', '.', '-'], "_"),
            worker_id.as_str().replace([':', '.', '-'], "_")
        )
    }
}

#[async_trait]
impl WorkerStore for SurrealWorkerStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        let query = r#"
            DEFINE TABLE OVERWRITE system_worker SCHEMAFULL;
            DEFINE FIELD OVERWRITE node_id ON TABLE system_worker TYPE string;
            DEFINE FIELD OVERWRITE worker_id ON TABLE system_worker TYPE string;
            DEFINE FIELD OVERWRITE module_id ON TABLE system_worker TYPE string;
            DEFINE FIELD OVERWRITE state ON TABLE system_worker TYPE string;
            DEFINE FIELD OVERWRITE criticality ON TABLE system_worker TYPE string;
            DEFINE FIELD OVERWRITE restart_count ON TABLE system_worker TYPE int;
            DEFINE FIELD OVERWRITE failure_count ON TABLE system_worker TYPE int;
            DEFINE FIELD OVERWRITE last_error ON TABLE system_worker TYPE option<string>;
            DEFINE FIELD OVERWRITE started_at ON TABLE system_worker TYPE option<int>;
            DEFINE FIELD OVERWRITE stopped_at ON TABLE system_worker TYPE option<int>;
            DEFINE FIELD OVERWRITE updated_at ON TABLE system_worker TYPE datetime DEFAULT time::now();
            DEFINE INDEX OVERWRITE idx_system_worker_unique ON TABLE system_worker COLUMNS node_id, worker_id UNIQUE;
        "#;

        let res =
            self.client
                .query(query)
                .await
                .map_err(|err| RuntimeError::WorkerStoreFailed {
                    worker: "system_worker".to_string(),
                    message: format!("Failed to bootstrap system_worker schema: {}", err),
                })?;

        res.check().map_err(|err| RuntimeError::WorkerStoreFailed {
            worker: "system_worker".to_string(),
            message: format!("Failed to check bootstrap system_worker schema: {}", err),
        })?;

        Ok(())
    }

    async fn upsert_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
        module_id: &ModuleId,
        state: WorkerState,
        criticality: WorkerCriticality,
        metrics: &WorkerMetrics,
    ) -> Result<(), RuntimeError> {
        let key_id = Self::make_key_id(node_id, worker_id);
        let crit_str = format!("{:?}", criticality).to_lowercase();

        let query = r#"
            UPSERT type::thing('system_worker', $key_id) SET
                node_id = $node_id,
                worker_id = $worker_id,
                module_id = $module_id,
                state = $state,
                criticality = $criticality,
                restart_count = $restart_count,
                failure_count = $failure_count,
                last_error = $last_error,
                started_at = $started_at,
                stopped_at = $stopped_at,
                updated_at = time::now();
        "#;

        let res = self
            .client
            .query(query)
            .bind(("key_id", key_id))
            .bind(("node_id", node_id.to_string()))
            .bind(("worker_id", worker_id.to_string()))
            .bind(("module_id", module_id.to_string()))
            .bind(("state", state.as_str().to_string()))
            .bind(("criticality", crit_str))
            .bind(("restart_count", metrics.restart_count as i64))
            .bind(("failure_count", metrics.failure_count as i64))
            .bind(("last_error", metrics.last_error.clone()))
            .bind(("started_at", metrics.started_at.map(|v| v as i64)))
            .bind(("stopped_at", metrics.stopped_at.map(|v| v as i64)))
            .await
            .map_err(|err| RuntimeError::WorkerStoreFailed {
                worker: worker_id.to_string(),
                message: format!("Failed to dispatch upsert worker: {}", err),
            })?;

        res.check().map_err(|err| RuntimeError::WorkerStoreFailed {
            worker: worker_id.to_string(),
            message: format!("Failed to check upsert worker: {}", err),
        })?;

        Ok(())
    }

    async fn get_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
    ) -> Result<Option<WorkerStoreRow>, RuntimeError> {
        let key_id = Self::make_key_id(node_id, worker_id);
        let query = "SELECT * FROM type::thing('system_worker', $key_id);";

        let mut res = self
            .client
            .query(query)
            .bind(("key_id", key_id))
            .await
            .map_err(|err| RuntimeError::WorkerStoreFailed {
                worker: worker_id.to_string(),
                message: format!("Failed to dispatch get worker: {}", err),
            })?;

        let rows: Vec<WorkerStoreRow> = res.take(0).unwrap_or_default();
        Ok(rows.into_iter().next())
    }

    async fn list_node_workers(
        &self,
        node_id: &NodeId,
    ) -> Result<Vec<WorkerStoreRow>, RuntimeError> {
        let query = "SELECT * FROM system_worker WHERE node_id = $node_id ORDER BY worker_id ASC;";

        let mut res = self
            .client
            .query(query)
            .bind(("node_id", node_id.to_string()))
            .await
            .map_err(|err| RuntimeError::WorkerStoreFailed {
                worker: "system_worker".to_string(),
                message: format!("Failed to dispatch list node workers: {}", err),
            })?;

        let rows: Vec<WorkerStoreRow> = res.take(0).unwrap_or_default();
        Ok(rows)
    }
}
