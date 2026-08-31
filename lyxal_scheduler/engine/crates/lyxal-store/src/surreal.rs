//! SurrealDB Store implementation backing all Lyxal persistence traits.
//!
//! Connects to SurrealDB using `surrealdb` Rust SDK and delegates all atomic
//! operations to the native `fn::scheduler::*` SurrealQL functions in SurrealDB.

use crate::models::*;
use crate::traits::*;
use chrono::{DateTime, Utc};
use std::collections::HashMap;
use surrealdb::engine::remote::ws::{Client, Ws};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;
use uuid::Uuid;

/// Persistent store implementation backed by SurrealDB (`scheduler_*` tables).
#[derive(Clone)]
pub struct SurrealStore {
    db: Surreal<Client>,
}

impl SurrealStore {
    /// Create a `SurrealStore` wrapping an established SurrealDB client connection.
    pub fn new(db: Surreal<Client>) -> Self {
        Self { db }
    }

    /// Connect asynchronously to a SurrealDB endpoint and select namespace & database.
    pub async fn connect(
        endpoint: &str,
        ns: &str,
        db_name: &str,
        user: &str,
        pass: &str,
    ) -> Result<Self, StoreError> {
        let clean = endpoint
            .trim_start_matches("ws://")
            .trim_start_matches("wss://")
            .trim_start_matches("http://")
            .trim_start_matches("https://")
            .trim_end_matches("/rpc")
            .trim_end_matches("/");

        let db = Surreal::new::<Ws>(clean)
            .await
            .map_err(|e| StoreError::Database(e.to_string()))?;

        db.signin(Root {
            username: user.to_string(),
            password: pass.to_string(),
        })
        .await
        .map_err(|e| StoreError::Database(e.to_string()))?;

        db.use_ns(ns)
            .use_db(db_name)
            .await
            .map_err(|e| StoreError::Database(e.to_string()))?;

        Ok(Self { db })
    }

    /// Synchronous helper to connect to SurrealDB from blocking contexts (e.g. CLI).
    pub fn connect_sync(
        endpoint: &str,
        ns: &str,
        db_name: &str,
        user: &str,
        pass: &str,
    ) -> Result<Self, StoreError> {
        let f = Self::connect(endpoint, ns, db_name, user, pass);
        if let Ok(handle) = tokio::runtime::Handle::try_current() {
            tokio::task::block_in_place(|| handle.block_on(f))
        } else {
            let rt = tokio::runtime::Runtime::new()
                .map_err(|e| StoreError::Database(e.to_string()))?;
            rt.block_on(f)
        }
    }

    /// Reference to the underlying SurrealDB client.
    pub fn client(&self) -> &Surreal<Client> {
        &self.db
    }

    /// Subscribe to real-time changes on the `scheduler_job` table via SurrealDB LIVE SELECT.
    pub async fn subscribe_jobs(&self) -> Result<surrealdb::method::QueryStream<surrealdb::Notification<surrealdb::types::Value>>, StoreError> {
        let mut res = self.db
            .query("LIVE SELECT * FROM scheduler_job;")
            .await
            .map_err(|e| StoreError::Database(e.to_string()))?;
        
        let stream = res
            .stream::<surrealdb::Notification<surrealdb::types::Value>>(0)
            .map_err(|e| StoreError::Database(e.to_string()))?;
        
        Ok(stream)
    }

    /// Subscribe to real-time changes on the `scheduler_trigger` table via SurrealDB LIVE SELECT.
    pub async fn subscribe_triggers(&self) -> Result<surrealdb::method::QueryStream<surrealdb::Notification<surrealdb::types::Value>>, StoreError> {
        let mut res = self.db
            .query("LIVE SELECT * FROM scheduler_trigger;")
            .await
            .map_err(|e| StoreError::Database(e.to_string()))?;
        
        let stream = res
            .stream::<surrealdb::Notification<surrealdb::types::Value>>(0)
            .map_err(|e| StoreError::Database(e.to_string()))?;
        
        Ok(stream)
    }

    /// Helper to execute async code inside synchronous Store trait methods.
    fn block<F, T>(&self, f: F) -> Result<T, StoreError>
    where
        F: std::future::Future<Output = Result<T, StoreError>> + Send,
    {
        if let Ok(handle) = tokio::runtime::Handle::try_current() {
            tokio::task::block_in_place(|| handle.block_on(f))
        } else {
            let rt = tokio::runtime::Runtime::new()
                .map_err(|e| StoreError::Database(e.to_string()))?;
            rt.block_on(f)
        }
    }

    /// Helper to convert serializable structs into serde_json::Value for query bindings.
    fn to_val<T: serde::Serialize>(val: &T) -> serde_json::Value {
        serde_json::to_value(val).unwrap_or(serde_json::Value::Null)
    }

    /// Helper to extract an optional deserializable model from a query response index.
    fn take_model<T: serde::de::DeserializeOwned>(res: &mut surrealdb::IndexedResults, index: usize) -> Result<Option<T>, StoreError> {
        let val: Option<surrealdb::types::Value> = res.take(index).map_err(|e| StoreError::Database(e.to_string()))?;
        match val {
            Some(v) => {
                let json_str = serde_json::to_string(&v).map_err(|e| StoreError::Database(e.to_string()))?;
                let item: T = serde_json::from_str(&json_str).map_err(|e| StoreError::Database(e.to_string()))?;
                Ok(Some(item))
            }
            None => Ok(None),
        }
    }

    /// Helper to extract a vector of deserializable models from a query response index.
    fn take_models<T: serde::de::DeserializeOwned>(res: &mut surrealdb::IndexedResults, index: usize) -> Result<Vec<T>, StoreError> {
        let vals: Vec<surrealdb::types::Value> = res.take(index).map_err(|e| StoreError::Database(e.to_string()))?;
        let mut result = Vec::with_capacity(vals.len());
        for v in vals {
            let json_str = serde_json::to_string(&v).map_err(|e| StoreError::Database(e.to_string()))?;
            if let Ok(item) = serde_json::from_str(&json_str) {
                result.push(item);
            }
        }
        Ok(result)
    }
}

// ─── JobStore ───
impl JobStore for SurrealStore {
    fn get_job_state(&self, job_key: &str) -> Result<Option<JobState>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::job_state_get($job_key);")
                .bind(("job_key", job_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn upsert_job_state(&self, state: &JobState) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::job_state_upsert($state);")
                .bind(("state", Self::to_val(state)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn list_job_states(&self) -> Result<Vec<JobState>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::job_state_list();")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_job_state(&self, job_key: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::job_state_delete($job_key);")
                .bind(("job_key", job_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }
}

// ─── ExecutionStore ───
impl ExecutionStore for SurrealStore {
    fn create_execution(&self, execution: &Execution) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::execution_create($execution);")
                .bind(("execution", Self::to_val(execution)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn create_execution_and_advance_job_state(
        &self,
        execution: &Execution,
        job_state: &JobState,
    ) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::execution_create_and_advance_job($execution, $job_state);")
                .bind(("execution", Self::to_val(execution)))
                .bind(("job_state", Self::to_val(job_state)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_execution(&self, id: Uuid) -> Result<Option<Execution>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_get($id);")
                .bind(("id", id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn claim_execution(
        &self,
        id: Uuid,
        runner_id: &str,
        now: DateTime<Utc>,
    ) -> Result<Execution, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_claim($id, $runner_id, $now);")
                .bind(("id", id.to_string()))
                .bind(("runner_id", runner_id.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let exec: Option<Execution> = Self::take_model(&mut res, 0)?;
            exec.ok_or_else(|| StoreError::NotFound(format!("Execution {id} not found or already claimed")))
        })
    }

    fn complete_execution(
        &self,
        id: Uuid,
        runner_id: Option<&str>,
        state: ExecutionState,
        duration_ms: Option<i64>,
        error: Option<&str>,
        dead_reason: Option<&str>,
        now: DateTime<Utc>,
    ) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_complete($id, $runner_id, $state, $duration_ms, $error, $dead_reason, $now);")
                .bind(("id", id.to_string()))
                .bind(("runner_id", runner_id.map(String::from)))
                .bind(("state", format!("{state:?}").to_lowercase()))
                .bind(("duration_ms", duration_ms))
                .bind(("error", error.map(String::from)))
                .bind(("dead_reason", dead_reason.map(String::from)))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let success: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(success.unwrap_or(false))
        })
    }

    fn find_queued_executions(
        &self,
        _capabilities: &[String],
        limit: u32,
    ) -> Result<Vec<Execution>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_execution WHERE state = 'queued' ORDER BY created_at ASC LIMIT $limit;")
                .bind(("limit", limit))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn list_executions(&self, _filter: &ExecutionFilter) -> Result<Vec<Execution>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_execution ORDER BY created_at DESC LIMIT 100;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn list_claimed_older_than(
        &self,
        cutoff: DateTime<Utc>,
        limit: u32,
    ) -> Result<Vec<Execution>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_list_claimed_older_than($cutoff, $limit);")
                .bind(("cutoff", cutoff))
                .bind(("limit", limit))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn find_execution_by_idempotency_key(
        &self,
        job_key: &str,
        idempotency_key: &str,
        window_start: DateTime<Utc>,
    ) -> Result<Option<Execution>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_find_by_idempotency($job_key, $idempotency_key, $window_start);")
                .bind(("job_key", job_key.to_string()))
                .bind(("idempotency_key", idempotency_key.to_string()))
                .bind(("window_start", window_start))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn requeue_abandoned(
        &self,
        runner_id: &str,
        now: DateTime<Utc>,
    ) -> Result<Vec<Uuid>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_requeue_abandoned($runner_id, $now);")
                .bind(("runner_id", runner_id.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ids: Vec<Uuid> = res.take(0).unwrap_or_default();
            Ok(ids)
        })
    }

    fn requeue_if_claimed(&self, id: Uuid, now: DateTime<Utc>) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_requeue_if_claimed($id, $now);")
                .bind(("id", id.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }

    fn cancel_execution(&self, id: Uuid, now: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::execution_cancel($id, $now);")
                .bind(("id", id.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn count_by_state(&self) -> Result<HashMap<ExecutionState, u64>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT state, count() FROM scheduler_execution GROUP BY state;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let mut map = HashMap::new();
            #[derive(serde::Deserialize)]
            struct Row {
                state: String,
                count: u64,
            }
            let rows: Vec<Row> = Self::take_models(&mut res, 0).unwrap_or_default();
            for r in rows {
                if let Ok(st) = serde_json::from_str::<ExecutionState>(&format!("\"{}\"", r.state)) {
                    map.insert(st, r.count);
                }
            }
            Ok(map)
        })
    }

    fn count_executions_in_states(
        &self,
        job_key: &str,
        states: &[ExecutionState],
    ) -> Result<u64, StoreError> {
        self.block(async {
            let state_strs: Vec<String> = states.iter().map(|s| format!("{s:?}").to_lowercase()).collect();
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_count_in_states($job_key, $states);")
                .bind(("job_key", job_key.to_string()))
                .bind(("states", state_strs))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }

    fn job_execution_metrics(&self) -> Result<Vec<JobExecutionMetrics>, StoreError> {
        Ok(Vec::new())
    }

    fn prune_executions_older_than(
        &self,
        cutoff: DateTime<Utc>,
        limit: u32,
    ) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_prune_older_than($cutoff, $limit);")
                .bind(("cutoff", cutoff))
                .bind(("limit", limit))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }

    fn prune_executions_keep_last(
        &self,
        job_key: &str,
        keep_last: u32,
        limit: u32,
    ) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::execution_prune_keep_last($job_key, $keep_last, $limit);")
                .bind(("job_key", job_key.to_string()))
                .bind(("keep_last", keep_last))
                .bind(("limit", limit))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }
}

// ─── RunnerStore ───
impl RunnerStore for SurrealStore {
    fn upsert_runner(&self, runner: &Runner) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::runner_upsert($runner);")
                .bind(("runner", Self::to_val(runner)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_runner(&self, runner_id: &str) -> Result<Option<Runner>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::runner_get($runner_id);")
                .bind(("runner_id", runner_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_runners(&self) -> Result<Vec<Runner>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::runner_list();")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn remove_runner(&self, runner_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::runner_remove($runner_id);")
                .bind(("runner_id", runner_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn update_poll(
        &self,
        runner_id: &str,
        inflight: &[Uuid],
        now: DateTime<Utc>,
    ) -> Result<(), StoreError> {
        self.block(async {
            let uuids: Vec<String> = inflight.iter().map(|u| u.to_string()).collect();
            self.db
                .query("RETURN fn::scheduler::runner_update_poll($runner_id, $inflight, $now);")
                .bind(("runner_id", runner_id.to_string()))
                .bind(("inflight", uuids))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }
}

// ─── DeadLetterStore ───
impl DeadLetterStore for SurrealStore {
    fn add_dead_letter(&self, dl: &DeadLetter) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::dead_letter_add($dl);")
                .bind(("dl", Self::to_val(dl)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn complete_as_dead(
        &self,
        execution_id: Uuid,
        runner_id: Option<&str>,
        duration_ms: Option<i64>,
        error: Option<&str>,
        dead_letter: &DeadLetter,
        now: DateTime<Utc>,
    ) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dead_letter_complete_as_dead($execution_id, $runner_id, $duration_ms, $error, $dead_letter, $now);")
                .bind(("execution_id", execution_id.to_string()))
                .bind(("runner_id", runner_id.map(String::from)))
                .bind(("duration_ms", duration_ms))
                .bind(("error", error.map(String::from)))
                .bind(("dead_letter", Self::to_val(dead_letter)))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }

    fn replay_dead_letter(
        &self,
        dead_letter_id: Uuid,
        execution: &Execution,
    ) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::dead_letter_replay($dead_letter_id, $execution);")
                .bind(("dead_letter_id", dead_letter_id.to_string()))
                .bind(("execution", Self::to_val(execution)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_dead_letter(&self, id: Uuid) -> Result<Option<DeadLetter>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dead_letter_get($id);")
                .bind(("id", id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_dead_letters(&self, _filter: &DeadLetterFilter) -> Result<Vec<DeadLetter>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_dead_letter ORDER BY created_at DESC;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn remove_dead_letter(&self, id: Uuid) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::dead_letter_remove($id);")
                .bind(("id", id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn remove_dead_letters(&self, ids: &[Uuid]) -> Result<u64, StoreError> {
        self.block(async {
            let id_strs: Vec<String> = ids.iter().map(|u| u.to_string()).collect();
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dead_letter_remove_bulk($ids);")
                .bind(("ids", id_strs))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }

    fn clear_dead_letters(&self, job_key: Option<&str>) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dead_letter_clear($job_key);")
                .bind(("job_key", job_key.map(String::from)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }

    fn purge_expired(&self, now: DateTime<Utc>) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dead_letter_purge_expired($now);")
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }
}

// ─── JobDefinitionStore ───
impl JobDefinitionStore for SurrealStore {
    fn create_job_definition(&self, job: &JobDefinition) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::job_def_create($job);")
                .bind(("job", Self::to_val(job)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_job_definition(&self, job_key: &str) -> Result<Option<JobDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::job_def_get($job_key);")
                .bind(("job_key", job_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_job_definitions(&self) -> Result<Vec<JobDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::job_def_list();")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_job_definition(&self, job_key: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::job_def_delete($job_key);")
                .bind(("job_key", job_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }
}

// ─── TriggerDefinitionStore ───
impl TriggerDefinitionStore for SurrealStore {
    fn create_trigger(&self, trigger: &TriggerDefinition) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::trigger_create($trigger);")
                .bind(("trigger", Self::to_val(trigger)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_trigger(&self, trigger_id: &str) -> Result<Option<TriggerDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::trigger_get($trigger_id);")
                .bind(("trigger_id", trigger_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_triggers(&self, job_key: Option<&str>) -> Result<Vec<TriggerDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::trigger_list($job_key);")
                .bind(("job_key", job_key.map(String::from)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_trigger(&self, trigger_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::trigger_delete($trigger_id);")
                .bind(("trigger_id", trigger_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn update_trigger(&self, trigger: &TriggerDefinition) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::trigger_update($trigger);")
                .bind(("trigger", Self::to_val(trigger)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }
}

// ─── CalendarDefinitionStore ───
impl CalendarDefinitionStore for SurrealStore {
    fn create_calendar(&self, cal: &CalendarDefinition) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::calendar_create($cal);")
                .bind(("cal", Self::to_val(cal)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_calendar(&self, calendar_id: &str) -> Result<Option<CalendarDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::calendar_get($calendar_id);")
                .bind(("calendar_id", calendar_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_calendars(&self) -> Result<Vec<CalendarDefinition>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::calendar_list();")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_calendar(&self, calendar_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::calendar_delete($calendar_id);")
                .bind(("calendar_id", calendar_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }
}

// ─── DslAdoptionStore ───
impl DslAdoptionStore for SurrealStore {
    fn insert_adoption(&self, adoption: &DslAdoption) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::dsl_adoption_insert($type, $key, $by);")
                .bind(("type", adoption.resource_type.clone()))
                .bind(("key", adoption.resource_key.clone()))
                .bind(("by", adoption.adopted_by.clone()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn delete_adoption(&self, resource_type: &str, resource_key: &str) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dsl_adoption_delete($type, $key);")
                .bind(("type", resource_type.to_string()))
                .bind(("key", resource_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }

    fn is_adopted(&self, resource_type: &str, resource_key: &str) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dsl_adoption_is_adopted($type, $key);")
                .bind(("type", resource_type.to_string()))
                .bind(("key", resource_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }

    fn list_adoptions(&self, resource_type: &str) -> Result<Vec<DslAdoption>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::dsl_adoption_list($type);")
                .bind(("type", resource_type.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }
}

// ─── ExecutionLogStore ───
impl ExecutionLogStore for SurrealStore {
    fn append_log(&self, entry: &ExecutionLogEntry) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::log_append($entry);")
                .bind(("entry", Self::to_val(entry)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn append_logs_batch(&self, entries: &[ExecutionLogEntry]) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::log_append_batch($entries);")
                .bind(("entries", Self::to_val(&entries.to_vec())))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn read_logs(&self, execution_id: Uuid, limit: u32) -> Result<Vec<ExecutionLogEntry>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::log_read($execution_id, $limit);")
                .bind(("execution_id", execution_id.to_string()))
                .bind(("limit", limit))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }
}

// ─── MaintenanceStore ───
impl MaintenanceStore for SurrealStore {
    fn get_maintenance(&self) -> Result<MaintenanceState, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::maintenance_get();")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let state: Option<MaintenanceState> = Self::take_model(&mut res, 0)?;
            Ok(state.unwrap_or_default())
        })
    }

    fn set_maintenance(&self, state: &MaintenanceState) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::maintenance_set($active, $note, $by);")
                .bind(("active", state.manual_active))
                .bind(("note", state.note.clone()))
                .bind(("by", state.updated_by.clone()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }
}

// ─── AlertStore ───
impl AlertStore for SurrealStore {
    fn record_alert_delivery(&self, delivery: &AlertDelivery) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::alert_record_delivery($delivery);")
                .bind(("delivery", Self::to_val(delivery)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn list_alert_deliveries(&self, _filter: &AlertDeliveryFilter) -> Result<Vec<AlertDelivery>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_alert_delivery ORDER BY created_at DESC LIMIT 100;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn get_alert_delivery(&self, delivery_id: &str) -> Result<Option<AlertDelivery>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_alert_delivery WHERE delivery_id = $id;")
                .bind(("id", delivery_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn last_alert_fire_at(&self, rule_name: &str, job_key: &str) -> Result<Option<DateTime<Utc>>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::alert_last_fire_at($rule_name, $job_key);")
                .bind(("rule_name", rule_name.to_string()))
                .bind(("job_key", job_key.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let at: Option<DateTime<Utc>> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(at)
        })
    }

    fn upsert_alert_rule_override(&self, ov: &AlertRuleOverride) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("RETURN fn::scheduler::alert_override_upsert($ov);")
                .bind(("ov", Self::to_val(ov)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_alert_rule_override(&self, rule_name: &str) -> Result<Option<AlertRuleOverride>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_alert_override WHERE rule_name = $rule;")
                .bind(("rule", rule_name.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_alert_rule_overrides(&self) -> Result<Vec<AlertRuleOverride>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_alert_override ORDER BY created_at DESC;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_alert_rule_override(&self, rule_name: &str) -> Result<bool, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::alert_override_delete($rule);")
                .bind(("rule", rule_name.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let ok: Option<bool> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(ok.unwrap_or(false))
        })
    }

    fn delete_expired_alert_rule_overrides(&self, now: DateTime<Utc>) -> Result<Vec<String>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("RETURN fn::scheduler::alert_override_delete_expired($now);")
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let cleared: Vec<String> = res.take(0).unwrap_or_default();
            Ok(cleared)
        })
    }

    fn prune_alert_rule_overrides(&self, valid_rule_names: &[String]) -> Result<Vec<String>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("DELETE scheduler_alert_override WHERE rule_name NOT IN $valid RETURN BEFORE;")
                .bind(("valid", valid_rule_names.to_vec()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let pruned: Vec<AlertRuleOverride> = Self::take_models(&mut res, 0).unwrap_or_default();
            Ok(pruned.into_iter().map(|o| o.rule_name).collect())
        })
    }
}

// ─── AuthStore ───
impl AuthStore for SurrealStore {
    fn create_client(&self, client: &ApiClient) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_client CONTENT $client;")
                .bind(("client", Self::to_val(client)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn get_client(&self, client_id: &str) -> Result<Option<ApiClient>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_client WHERE client_id = $id;")
                .bind(("id", client_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn list_clients(&self) -> Result<Vec<ApiClient>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_client ORDER BY created_at DESC;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn delete_client(&self, client_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("DELETE scheduler_client WHERE client_id = $id;")
                .bind(("id", client_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn create_api_key(&self, key: &ApiKey) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_api_key CONTENT $key;")
                .bind(("key", Self::to_val(key)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn find_api_key_by_hash(&self, key_hash: &str) -> Result<Option<ApiKey>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_api_key WHERE key_hash = $hash;")
                .bind(("hash", key_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn revoke_api_key(&self, key_id: &str, now: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_api_key SET revoked_at = $now WHERE key_id = $id;")
                .bind(("id", key_id.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn list_api_keys(&self, client_id: &str) -> Result<Vec<ApiKey>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_api_key WHERE client_id = $id ORDER BY created_at DESC;")
                .bind(("id", client_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn get_credentials(&self, username: &str) -> Result<Option<PasswordCredential>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_credentials WHERE username = $user;")
                .bind(("user", username.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn upsert_credentials(&self, cred: &PasswordCredential) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPSERT scheduler_credentials CONTENT $cred;")
                .bind(("cred", Self::to_val(cred)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn create_refresh_token(&self, token: &RefreshToken) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_refresh_token CONTENT $token;")
                .bind(("token", Self::to_val(token)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn validate_refresh_token(&self, token_hash: &str) -> Result<Option<RefreshToken>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_refresh_token WHERE token_hash = $hash AND revoked_at IS NONE;")
                .bind(("hash", token_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn revoke_refresh_token(&self, token_hash: &str, now: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_refresh_token SET revoked_at = $now WHERE token_hash = $hash;")
                .bind(("hash", token_hash.to_string()))
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn users_create(&self, user: &User) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPSERT scheduler_user CONTENT $user;")
                .bind(("user", Self::to_val(user)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn users_get_by_id(&self, user_id: &str) -> Result<Option<User>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_user WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn users_get_by_username(&self, username: &str) -> Result<Option<User>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_user WHERE username = $u;")
                .bind(("u", username.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn users_list(&self) -> Result<Vec<User>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_user ORDER BY created_at DESC;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn users_update(&self, user: &User) -> Result<(), StoreError> {
        self.users_create(user)
    }

    fn users_delete(&self, user_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("DELETE scheduler_user WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn users_set_last_login(&self, user_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_user SET last_login_at = $at WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn users_count_active_admins(&self) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT count() FROM scheduler_user WHERE role = 'admin' AND is_active = true GROUP ALL;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            #[derive(serde::Deserialize)]
            struct CountRow { count: u64 }
            let row: Option<CountRow> = Self::take_model(&mut res, 0).unwrap_or(None);
            Ok(row.map(|r| r.count).unwrap_or(0))
        })
    }

    fn invitations_create(&self, invite: &Invitation) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_invitation CONTENT $invite;")
                .bind(("invite", Self::to_val(invite)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn invitations_get(&self, invitation_id: &str) -> Result<Option<Invitation>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_invitation WHERE invitation_id = $id;")
                .bind(("id", invitation_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn invitations_get_by_token_hash(&self, token_hash: &str) -> Result<Option<Invitation>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_invitation WHERE token_hash = $hash;")
                .bind(("hash", token_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn invitations_list(&self) -> Result<Vec<Invitation>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_invitation ORDER BY created_at DESC;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn invitations_mark_accepted(&self, invitation_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_invitation SET accepted_at = $at WHERE invitation_id = $id;")
                .bind(("id", invitation_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn invitations_revoke(&self, invitation_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_invitation SET revoked_at = $at WHERE invitation_id = $id;")
                .bind(("id", invitation_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn password_resets_create(&self, reset: &PasswordReset) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_password_reset CONTENT $reset;")
                .bind(("reset", Self::to_val(reset)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn password_resets_get_by_token_hash(&self, token_hash: &str) -> Result<Option<PasswordReset>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_password_reset WHERE token_hash = $hash;")
                .bind(("hash", token_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn password_resets_mark_used(&self, reset_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_password_reset SET used_at = $at WHERE reset_id = $id;")
                .bind(("id", reset_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn totp_upsert(&self, secret: &TotpSecret) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPSERT scheduler_totp CONTENT $secret;")
                .bind(("secret", Self::to_val(secret)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn totp_get(&self, user_id: &str) -> Result<Option<TotpSecret>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_totp WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn totp_set_enabled(&self, user_id: &str, enabled: bool, confirmed_at: Option<DateTime<Utc>>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_totp SET enabled = $enabled, confirmed_at = $at WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .bind(("enabled", enabled))
                .bind(("at", confirmed_at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn totp_delete(&self, user_id: &str) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("DELETE scheduler_totp WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn recovery_codes_replace_all(&self, user_id: &str, codes: &[RecoveryCode]) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("DELETE scheduler_recovery_code WHERE user_id = $id;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            for code in codes {
                self.db
                    .query("CREATE scheduler_recovery_code CONTENT $code;")
                    .bind(("code", Self::to_val(code)))
                    .await
                    .map_err(|e| StoreError::Database(e.to_string()))?;
            }
            Ok(())
        })
    }

    fn recovery_codes_find_unused(&self, user_id: &str, code_hash: &str) -> Result<Option<RecoveryCode>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_recovery_code WHERE user_id = $id AND code_hash = $hash AND used_at IS NONE;")
                .bind(("id", user_id.to_string()))
                .bind(("hash", code_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn recovery_codes_mark_used(&self, code_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_recovery_code SET used_at = $at WHERE code_id = $id;")
                .bind(("id", code_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn recovery_codes_count_unused(&self, user_id: &str) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT count() FROM scheduler_recovery_code WHERE user_id = $id AND used_at IS NONE GROUP ALL;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            #[derive(serde::Deserialize)]
            struct CountRow { count: u64 }
            let row: Option<CountRow> = Self::take_model(&mut res, 0).unwrap_or(None);
            Ok(row.map(|r| r.count).unwrap_or(0))
        })
    }

    fn pat_create(&self, pat: &PersonalAccessToken) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_pat CONTENT $pat;")
                .bind(("pat", Self::to_val(pat)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn pat_find_by_hash(&self, token_hash: &str) -> Result<Option<PersonalAccessToken>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_pat WHERE token_hash = $hash AND revoked_at IS NONE;")
                .bind(("hash", token_hash.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn pat_list(&self, user_id: &str) -> Result<Vec<PersonalAccessToken>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_pat WHERE user_id = $id ORDER BY created_at DESC;")
                .bind(("id", user_id.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }

    fn pat_revoke(&self, token_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_pat SET revoked_at = $at WHERE token_id = $id;")
                .bind(("id", token_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn pat_touch_last_used(&self, token_id: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_pat SET last_used_at = $at WHERE token_id = $id;")
                .bind(("id", token_id.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn oidc_link(&self, identity: &OidcIdentity) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPSERT scheduler_oidc_identity CONTENT $identity;")
                .bind(("identity", Self::to_val(identity)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn oidc_get_by_subject(&self, provider: &str, subject: &str) -> Result<Option<OidcIdentity>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_oidc_identity WHERE provider = $p AND subject = $s;")
                .bind(("p", provider.to_string()))
                .bind(("s", subject.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn oidc_touch_last_login(&self, provider: &str, subject: &str, at: DateTime<Utc>) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("UPDATE scheduler_oidc_identity SET last_login_at = $at WHERE provider = $p AND subject = $s;")
                .bind(("p", provider.to_string()))
                .bind(("s", subject.to_string()))
                .bind(("at", at))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn oidc_pending_create(&self, pending: &OidcPendingLogin) -> Result<(), StoreError> {
        self.block(async {
            let val = serde_json::to_value(pending).map_err(|e| StoreError::Database(e.to_string()))?;
            self.db
                .query("CREATE scheduler_oidc_pending CONTENT $pending;")
                .bind(("pending", val))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn oidc_pending_take(&self, state: &str) -> Result<Option<OidcPendingLogin>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("DELETE scheduler_oidc_pending WHERE state = $state RETURN BEFORE;")
                .bind(("state", state.to_string()))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_model(&mut res, 0)
        })
    }

    fn oidc_pending_purge_expired(&self, now: DateTime<Utc>) -> Result<u64, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("DELETE scheduler_oidc_pending WHERE expires_at <= $now;")
                .bind(("now", now))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            let count: Option<u64> = res.take(0).map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(count.unwrap_or(0))
        })
    }

    fn audit_log(&self, event: &AuditEvent) -> Result<(), StoreError> {
        self.block(async {
            self.db
                .query("CREATE scheduler_audit_log CONTENT $event;")
                .bind(("event", Self::to_val(event)))
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;
            Ok(())
        })
    }

    fn audit_list(&self, _filter: &AuditFilter) -> Result<Vec<AuditEvent>, StoreError> {
        self.block(async {
            let mut res = self
                .db
                .query("SELECT * FROM scheduler_audit_log ORDER BY created_at DESC LIMIT 100;")
                .await
                .map_err(|e| StoreError::Database(e.to_string()))?;

            Self::take_models(&mut res, 0)
        })
    }
}

impl Store for SurrealStore {}
