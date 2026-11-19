//! Paramètres et résultats des fonctions SurrealQL `fn::runtime_*`, champ pour champ identiques
//! au SurrealQL. Un champ `None` vaut « non fourni ».

use lyxal_surreal::{Datetime, SurrealValue};
use surrealdb::types::Duration;

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
    /// Script de la migration (chemin déclaré au manifeste).
    pub script: Option<String>,
    /// Nœud qui écrit cet état ; sous bail, le détenteur du bail.
    pub node_id: Option<String>,
    /// Clé du bail sous lequel la migration est exécutée (garde de bail), sinon `None`.
    pub lease_key: Option<String>,
    pub generation: Option<i64>,
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
    #[surreal(default)]
    pub script: Option<String>,
    #[surreal(default)]
    pub node_id: Option<String>,
}

/// `fn::runtime_migration_resolve`, avec le bail d'installation sous lequel la décision est
/// prise.
#[derive(Debug, Clone, SurrealValue)]
pub(crate) struct MigrationResolveCallParams {
    pub module: String,
    pub migration: String,
    pub action: String,
    pub reason: String,
    pub actor: String,
    pub node_id: String,
    pub generation: i64,
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

// ---------------------------------------------------------------------------
// Présence des nœuds et socle installé
// ---------------------------------------------------------------------------

/// `fn::runtime_node_upsert`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RuntimeNodeUpsertParams {
    pub node_id: String,
    pub host: String,
    /// Modules enregistrés dans le runtime du nœud.
    pub modules: Vec<String>,
    /// Empreinte du socle embarqué par le binaire du nœud.
    pub foundation_checksum: Option<String>,
}

/// `fn::runtime_node_remove`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RuntimeNodeRemoveParams {
    pub node_id: String,
}

/// Résultat de `fn::runtime_node_remove`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct RuntimeNodeRemoved {
    pub node_id: String,
    /// Faux si aucune ligne de présence n'a été supprimée.
    pub removed: bool,
    /// Lignes `runtime_worker` supprimées.
    pub workers: i64,
    /// Lignes `runtime_health` supprimées.
    pub health: i64,
}

/// `fn::runtime_node_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RuntimeNodeListParams {
    /// Âge maximal du dernier battement d'un nœud vivant (30 s si absent).
    pub alive_within: Option<Duration>,
}

/// `fn::runtime_node_purge`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RuntimeNodePurgeParams {
    /// Âge du dernier battement au-delà duquel un nœud est purgé (7 jours si absent).
    pub older_than: Option<Duration>,
}

/// Résultat de `fn::runtime_node_purge` : lignes supprimées.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct RuntimeNodePurged {
    pub nodes: i64,
    pub workers: i64,
    pub health: i64,
}

/// Présence d'un nœud telle que stockée (`runtime_node`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RuntimeNode {
    pub node_id: String,
    pub host: String,
    pub modules: Vec<String>,
    #[surreal(default)]
    pub foundation_checksum: Option<String>,
    pub started_at: Datetime,
    pub seen_at: Datetime,
    /// Dernier battement assez récent (renseigné par `fn::runtime_node_list` seulement).
    #[surreal(default)]
    pub alive: Option<bool>,
}

/// `fn::runtime_foundation_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RuntimeFoundationRecordParams {
    pub checksum: String,
    pub host: String,
    pub node_id: String,
    /// Génération du bail d'installation « foundation » détenu par le nœud.
    pub generation: i64,
}

/// `fn::runtime_foundation_clear`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RuntimeFoundationClearParams {
    pub node_id: String,
    /// Génération du bail d'installation « foundation » détenu par le nœud.
    pub generation: i64,
}

/// Résultat de `fn::runtime_foundation_clear`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RuntimeFoundationCleared {
    /// Faux si aucune empreinte n'était enregistrée.
    pub cleared: bool,
}

/// Socle installé tel que stocké (`runtime_foundation:current`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RuntimeFoundation {
    pub checksum: String,
    pub host: String,
    pub node_id: String,
    pub installed_at: Datetime,
}
