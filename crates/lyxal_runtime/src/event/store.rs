use crate::error::RuntimeError;
use crate::event::event::RuntimeEvent;
use crate::event::id::RuntimeEventId;
use crate::event::journal::RuntimeEventJournal;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::RuntimeEventPayload;
use crate::lock::node_id::NodeId;
use crate::store::dto::{EventAppendParams, EventListParams, EventRow};
use crate::store::surreal::store_error;
use crate::types::ModuleId;
use async_trait::async_trait;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Implémentation persistante du journal d'événements sur SurrealDB.
#[derive(Clone)]
pub struct SurrealRuntimeEventJournal {
    client: Surreal<Any>,
}

impl SurrealRuntimeEventJournal {
    /// Crée une nouvelle instance de journal connecté au client SurrealDB.
    pub fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Initialise la table `runtime_event_journal` et ses index.
    pub async fn bootstrap(&self) -> Result<(), RuntimeError> {
        crate::schema::install_runtime_schema(&self.client).await
    }

    fn row_to_event(row: EventRow) -> Result<RuntimeEvent, RuntimeError> {
        let kind: RuntimeEventKind = serde_json::from_value(serde_json::Value::String(row.kind))
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_DESERIALIZATION_FAILED",
                message: format!("Failed to deserialize RuntimeEventKind: {}", err),
            })?;

        let payload: RuntimeEventPayload =
            serde_json::from_value(row.payload).map_err(|err| RuntimeError::Internal {
                code: "EVENT_DESERIALIZATION_FAILED",
                message: format!("Failed to deserialize RuntimeEventPayload: {}", err),
            })?;

        Ok(RuntimeEvent {
            id: RuntimeEventId::new(row.event_id),
            sequence: row.sequence as u64,
            node_id: NodeId::new(row.node_id),
            timestamp_ms: row.timestamp as u64,
            kind,
            module_id: row.module_id.map(ModuleId::new),
            correlation_id: row.correlation_id,
            causation_id: row.causation_id.map(RuntimeEventId::new),
            payload,
        })
    }
}

impl lyxal_surreal::LyxalSurrealCall for SurrealRuntimeEventJournal {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

#[async_trait]
impl RuntimeEventJournal for SurrealRuntimeEventJournal {
    async fn append(&self, event: &RuntimeEvent) -> Result<(), RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        let payload =
            serde_json::to_value(&event.payload).map_err(|err| RuntimeError::StoreFailed {
                operation: "runtime_event_append",
                message: format!("Failed to serialize event payload: {err}"),
            })?;
        let to_i64 = |field: &str, v: u64| {
            i64::try_from(v).map_err(|_| RuntimeError::StoreFailed {
                operation: "runtime_event_append",
                message: format!("{field} hors bornes : {v}"),
            })
        };
        let params = EventAppendParams {
            event_id: event.id.to_string(),
            sequence: to_i64("sequence", event.sequence)?,
            node_id: event.node_id.to_string(),
            timestamp: to_i64("timestamp", event.timestamp_ms)?,
            kind: event.kind.as_str().to_string(),
            module_id: event.module_id.as_ref().map(|m| m.to_string()),
            correlation_id: event.correlation_id.clone(),
            causation_id: event.causation_id.as_ref().map(|c| c.to_string()),
            payload,
        };
        let _: EventRow = self
            .call_fn("runtime_event_append", params)
            .await
            .map_err(|e| store_error("runtime_event_append", e))?;
        Ok(())
    }

    async fn recent(&self, limit: usize) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        self.list(limit, None).await
    }

    async fn by_module(
        &self,
        module_id: &ModuleId,
        limit: usize,
    ) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        self.list(limit, Some(module_id.to_string())).await
    }
}

impl SurrealRuntimeEventJournal {
    async fn list(
        &self,
        limit: usize,
        module_id: Option<String>,
    ) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        use lyxal_surreal::LyxalSurrealCall;
        let limit = i64::try_from(limit).map_err(|_| RuntimeError::StoreFailed {
            operation: "runtime_event_list",
            message: format!("limit hors bornes : {limit}"),
        })?;
        let rows: Vec<EventRow> = self
            .call_fn("runtime_event_list", EventListParams { limit, module_id })
            .await
            .map_err(|e| store_error("runtime_event_list", e))?;
        rows.into_iter().map(Self::row_to_event).collect()
    }
}
