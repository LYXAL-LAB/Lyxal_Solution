use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::store::dto::{NodeParams, WorkerGetParams, WorkerUpsertParams};
use crate::store::surreal::store_error;
use crate::types::ModuleId;
use crate::worker::descriptor::WorkerCriticality;
use crate::worker::id::WorkerId;
use crate::worker::metrics::WorkerMetrics;
use crate::worker::state::WorkerState;
use async_trait::async_trait;
use lyxal_surreal::SurrealValue;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Enregistrement persistant d'un worker dans `runtime_worker`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, SurrealValue)]
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
    pub updated_at: Option<lyxal_surreal::Datetime>,
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
            updated_at: Some(lyxal_surreal::Datetime::now()),
        };

        let mut lock = self
            .workers
            .write()
            .map_err(|_| RuntimeError::LockPoisoned {
                context: "MemoryWorkerStore write lock poisoned",
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
        let lock = self
            .workers
            .read()
            .map_err(|_| RuntimeError::LockPoisoned {
                context: "MemoryWorkerStore read lock poisoned",
            })?;
        Ok(lock.get(&key).cloned())
    }

    async fn list_node_workers(
        &self,
        node_id: &NodeId,
    ) -> Result<Vec<WorkerStoreRow>, RuntimeError> {
        let node_str = node_id.to_string();
        let lock = self
            .workers
            .read()
            .map_err(|_| RuntimeError::LockPoisoned {
                context: "MemoryWorkerStore read lock poisoned",
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
}

#[async_trait]
impl WorkerStore for SurrealWorkerStore {
    async fn bootstrap(&self) -> Result<(), RuntimeError> {
        crate::schema::install_runtime_schema(&self.client).await
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
        use lyxal_surreal::LyxalSurrealCall;
        let to_i64 = |field: &str, v: u64| {
            i64::try_from(v).map_err(|_| RuntimeError::WorkerStoreFailed {
                worker: worker_id.to_string(),
                message: format!("{field} hors bornes : {v}"),
            })
        };
        let params = WorkerUpsertParams {
            node_id: node_id.to_string(),
            worker_id: worker_id.to_string(),
            module_id: module_id.to_string(),
            state: state.as_str().to_string(),
            criticality: match criticality {
                WorkerCriticality::Required => "required",
                WorkerCriticality::Optional => "optional",
            }
            .to_string(),
            restart_count: to_i64("restart_count", metrics.restart_count)?,
            failure_count: to_i64("failure_count", metrics.failure_count)?,
            last_error: metrics.last_error.clone(),
            started_at: metrics
                .started_at
                .map(|v| to_i64("started_at", v))
                .transpose()?,
            stopped_at: metrics
                .stopped_at
                .map(|v| to_i64("stopped_at", v))
                .transpose()?,
        };
        let _: WorkerStoreRow = self
            .call_fn("runtime_worker_upsert", params)
            .await
            .map_err(|e| RuntimeError::WorkerStoreFailed {
                worker: worker_id.to_string(),
                message: e.to_string(),
            })?;
        Ok(())
    }

    async fn get_worker(
        &self,
        node_id: &NodeId,
        worker_id: &WorkerId,
    ) -> Result<Option<WorkerStoreRow>, RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        self.call_fn(
            "runtime_worker_get",
            WorkerGetParams {
                node_id: node_id.to_string(),
                worker_id: worker_id.to_string(),
            },
        )
        .await
        .map_err(|e| RuntimeError::WorkerStoreFailed {
            worker: worker_id.to_string(),
            message: e.to_string(),
        })
    }

    async fn list_node_workers(
        &self,
        node_id: &NodeId,
    ) -> Result<Vec<WorkerStoreRow>, RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        self.call_fn(
            "runtime_worker_list",
            NodeParams {
                node_id: node_id.to_string(),
            },
        )
        .await
        .map_err(|e| store_error("runtime_worker_list", e))
    }
}

impl lyxal_surreal::LyxalSurrealCall for SurrealWorkerStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}
