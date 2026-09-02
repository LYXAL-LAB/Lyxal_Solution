use crate::error::RuntimeError;
use crate::event::event::RuntimeEvent;
use crate::event::id::RuntimeEventId;
use crate::event::journal::RuntimeEventJournal;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::RuntimeEventPayload;
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Structure de désérialisation interne d'une ligne de la table `system_runtime_event`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemRuntimeEventRow {
    pub event_id: String,
    pub sequence: i64,
    pub node_id: String,
    pub timestamp: i64,
    pub kind: String,
    pub module_id: Option<String>,
    pub correlation_id: Option<String>,
    pub causation_id: Option<String>,
    pub payload: serde_json::Value,
}

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

    /// Initialise la table `system_runtime_event` et ses index.
    pub async fn bootstrap(&self) -> Result<(), RuntimeError> {
        let query = r#"
            DEFINE TABLE OVERWRITE system_runtime_event SCHEMAFULL;
            DEFINE FIELD OVERWRITE event_id ON TABLE system_runtime_event TYPE string;
            DEFINE FIELD OVERWRITE sequence ON TABLE system_runtime_event TYPE int;
            DEFINE FIELD OVERWRITE node_id ON TABLE system_runtime_event TYPE string;
            DEFINE FIELD OVERWRITE timestamp ON TABLE system_runtime_event TYPE int;
            DEFINE FIELD OVERWRITE kind ON TABLE system_runtime_event TYPE string;
            DEFINE FIELD OVERWRITE module_id ON TABLE system_runtime_event TYPE option<string>;
            DEFINE FIELD OVERWRITE correlation_id ON TABLE system_runtime_event TYPE option<string>;
            DEFINE FIELD OVERWRITE causation_id ON TABLE system_runtime_event TYPE option<string>;
            DEFINE FIELD OVERWRITE payload ON TABLE system_runtime_event FLEXIBLE TYPE object;
            DEFINE FIELD OVERWRITE created_at ON TABLE system_runtime_event TYPE datetime DEFAULT time::now();

            DEFINE INDEX OVERWRITE idx_system_runtime_event_id ON TABLE system_runtime_event COLUMNS event_id UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_runtime_event_node_seq ON TABLE system_runtime_event COLUMNS node_id, sequence UNIQUE;
            DEFINE INDEX OVERWRITE idx_system_runtime_event_module ON TABLE system_runtime_event COLUMNS module_id;
            DEFINE INDEX OVERWRITE idx_system_runtime_event_kind ON TABLE system_runtime_event COLUMNS kind;
            DEFINE INDEX OVERWRITE idx_system_runtime_event_timestamp ON TABLE system_runtime_event COLUMNS timestamp;
        "#;

        let res = self
            .client
            .query(query)
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_BOOTSTRAP_FAILED",
                message: format!("Failed to bootstrap system_runtime_event table: {}", err),
            })?;

        res.check().map_err(|err| RuntimeError::Internal {
            code: "EVENT_JOURNAL_BOOTSTRAP_FAILED",
            message: format!(
                "Failed to check bootstrap system_runtime_event table: {}",
                err
            ),
        })?;

        Ok(())
    }

    fn make_key_id(node_id: &NodeId, sequence: u64) -> String {
        format!(
            "{}_{:012}",
            node_id.as_str().replace([':', '.', '-'], "_"),
            sequence
        )
    }

    fn row_to_event(row: SystemRuntimeEventRow) -> Result<RuntimeEvent, RuntimeError> {
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

#[async_trait]
impl RuntimeEventJournal for SurrealRuntimeEventJournal {
    async fn append(&self, event: &RuntimeEvent) -> Result<(), RuntimeError> {
        let key_id = Self::make_key_id(&event.node_id, event.sequence);
        let payload_val =
            serde_json::to_value(&event.payload).map_err(|err| RuntimeError::Internal {
                code: "EVENT_SERIALIZATION_FAILED",
                message: format!("Failed to serialize event payload: {}", err),
            })?;

        let query = r#"
            UPSERT type::thing('system_runtime_event', $key_id) SET
                event_id = $event_id,
                sequence = $sequence,
                node_id = $node_id,
                timestamp = $timestamp,
                kind = $kind,
                module_id = $module_id,
                correlation_id = $correlation_id,
                causation_id = $causation_id,
                payload = $payload,
                created_at = time::now();
        "#;

        let res = self
            .client
            .query(query)
            .bind(("key_id", key_id))
            .bind(("event_id", event.id.to_string()))
            .bind(("sequence", event.sequence as i64))
            .bind(("node_id", event.node_id.to_string()))
            .bind(("timestamp", event.timestamp_ms as i64))
            .bind(("kind", event.kind.as_str().to_string()))
            .bind(("module_id", event.module_id.as_ref().map(|m| m.to_string())))
            .bind(("correlation_id", event.correlation_id.clone()))
            .bind((
                "causation_id",
                event.causation_id.as_ref().map(|c| c.to_string()),
            ))
            .bind(("payload", payload_val))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_APPEND_FAILED",
                message: format!("Failed to append event to journal: {}", err),
            })?;

        res.check().map_err(|err| RuntimeError::Internal {
            code: "EVENT_JOURNAL_APPEND_FAILED",
            message: format!("Failed to check append event to journal: {}", err),
        })?;

        Ok(())
    }

    async fn recent(&self, limit: usize) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        let query = "SELECT * FROM system_runtime_event ORDER BY sequence DESC LIMIT $limit;";

        let mut res = self
            .client
            .query(query)
            .bind(("limit", limit as i64))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_QUERY_FAILED",
                message: format!("Failed to query recent events from journal: {}", err),
            })?;

        let rows: Vec<SystemRuntimeEventRow> =
            res.take(0).map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_QUERY_FAILED",
                message: format!("Failed to extract event rows: {}", err),
            })?;

        rows.into_iter().map(Self::row_to_event).collect()
    }

    async fn by_module(
        &self,
        module_id: &ModuleId,
        limit: usize,
    ) -> Result<Vec<RuntimeEvent>, RuntimeError> {
        let query = "SELECT * FROM system_runtime_event WHERE module_id = $module_id ORDER BY sequence DESC LIMIT $limit;";

        let mut res = self
            .client
            .query(query)
            .bind(("module_id", module_id.to_string()))
            .bind(("limit", limit as i64))
            .await
            .map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_QUERY_FAILED",
                message: format!(
                    "Failed to query events for module '{}' from journal: {}",
                    module_id, err
                ),
            })?;

        let rows: Vec<SystemRuntimeEventRow> =
            res.take(0).map_err(|err| RuntimeError::Internal {
                code: "EVENT_JOURNAL_QUERY_FAILED",
                message: format!("Failed to extract module event rows: {}", err),
            })?;

        rows.into_iter().map(Self::row_to_event).collect()
    }
}
