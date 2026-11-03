//! Paramètres et résultats des fonctions SurrealQL `fn::runtime_*`, champ pour champ identiques
//! au SurrealQL. Un champ `None` vaut « non fourni ».

use lyxal_surreal::{Datetime, SurrealValue};

/// Paramètres d'une fonction de liste sans critère.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ListParams {
    pub language: Option<String>,
}

// ---------------------------------------------------------------------------
// Modules
// ---------------------------------------------------------------------------

/// `fn::runtime_module_upsert`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ModuleUpsertParams {
    pub module_id: String,
    pub name: String,
    pub description: Option<String>,
}

/// `fn::runtime_module_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ModuleGetParams {
    pub module_id: String,
}

/// Module tel que stocké.
#[derive(Debug, Clone, SurrealValue)]
pub struct ModuleRow {
    pub module_id: String,
    pub name: String,
    #[surreal(default)]
    pub description: Option<String>,
    #[surreal(default)]
    pub created_at: Option<Datetime>,
    #[surreal(default)]
    pub updated_at: Option<Datetime>,
}

// ---------------------------------------------------------------------------
// Releases
// ---------------------------------------------------------------------------

/// `fn::runtime_release_register`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReleaseRegisterParams {
    pub module_id: String,
    pub version: String,
    pub manifest_version: i64,
    pub status: String,
    pub description: Option<String>,
    pub checksum: Option<String>,
    pub installation_phase: Option<String>,
}

/// `fn::runtime_release_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReleaseGetParams {
    pub module_id: String,
    pub version: String,
}

/// `fn::runtime_release_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReleaseListParams {
    pub module_id: String,
}

/// `fn::runtime_release_status_update`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReleaseStatusUpdateParams {
    pub module_id: String,
    pub version: String,
    pub status: String,
    pub phase: Option<String>,
}

/// Release telle que stockée.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReleaseRow {
    pub module_id: String,
    pub version: String,
    pub manifest_version: i64,
    pub status: String,
    #[surreal(default)]
    pub description: Option<String>,
    #[surreal(default)]
    pub checksum: Option<String>,
    #[surreal(default)]
    pub installation_phase: Option<String>,
    #[surreal(default)]
    pub created_at: Option<Datetime>,
    #[surreal(default)]
    pub installed_at: Option<Datetime>,
    #[surreal(default)]
    pub updated_at: Option<Datetime>,
}

// ---------------------------------------------------------------------------
// Migrations
// ---------------------------------------------------------------------------

/// `fn::runtime_migration_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationRecordParams {
    pub module_id: String,
    pub migration_id: String,
    pub module_version: String,
    pub checksum: String,
    pub status: String,
    pub applied_at: i64,
    pub duration_ms: i64,
    pub error: Option<String>,
}

/// `fn::runtime_migration_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationGetParams {
    pub module_id: String,
    pub migration_id: String,
}

/// `fn::runtime_migration_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationListParams {
    pub module_id: String,
}

/// Migration telle que stockée.
#[derive(Debug, Clone, SurrealValue)]
pub struct MigrationRow {
    pub module_id: String,
    pub migration_id: String,
    pub module_version: String,
    pub checksum: String,
    pub status: String,
    pub applied_at: i64,
    pub duration_ms: i64,
    #[surreal(default)]
    pub error: Option<String>,
}

// ---------------------------------------------------------------------------
// Santé
// ---------------------------------------------------------------------------

/// `fn::runtime_health_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct HealthRecordParams {
    pub node_id: String,
    pub module_id: String,
    pub status: String,
    pub latency_ms: Option<i64>,
    pub message: Option<String>,
}

/// `fn::runtime_health_list`, `fn::runtime_worker_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct NodeParams {
    pub node_id: String,
}

/// État de santé tel que stocké.
#[derive(Debug, Clone, SurrealValue)]
pub struct HealthRow {
    pub node_id: String,
    pub module_id: String,
    pub status: String,
    #[surreal(default)]
    pub latency_ms: Option<i64>,
    #[surreal(default)]
    pub message: Option<String>,
    pub checked_at: Datetime,
}

// ---------------------------------------------------------------------------
// Workers
// ---------------------------------------------------------------------------

/// `fn::runtime_worker_upsert`.
#[derive(Debug, Clone, SurrealValue)]
pub struct WorkerUpsertParams {
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
}

/// `fn::runtime_worker_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct WorkerGetParams {
    pub node_id: String,
    pub worker_id: String,
}

// ---------------------------------------------------------------------------
// Journal des événements techniques
// ---------------------------------------------------------------------------

/// `fn::runtime_event_append`.
#[derive(Debug, Clone, SurrealValue)]
pub struct EventAppendParams {
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

/// `fn::runtime_event_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct EventListParams {
    pub limit: i64,
    pub module_id: Option<String>,
}

/// Événement tel que journalisé.
#[derive(Debug, Clone, SurrealValue)]
pub struct EventRow {
    pub event_id: String,
    pub sequence: i64,
    pub node_id: String,
    pub timestamp: i64,
    pub kind: String,
    #[surreal(default)]
    pub module_id: Option<String>,
    #[surreal(default)]
    pub correlation_id: Option<String>,
    #[surreal(default)]
    pub causation_id: Option<String>,
    pub payload: serde_json::Value,
}
