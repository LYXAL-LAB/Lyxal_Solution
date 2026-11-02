//! Contrats Rust des fonctions SurrealQL publiques de `lyxal_error`.
//!
//! Chaque `*Params` reprend exactement les champs acceptés par la fonction
//! `fn::error_*` correspondante (tout autre champ est refusé avec
//! `ERROR_INVALID_INPUT`). Un champ `None` est transmis comme `NONE` et vaut
//! « non fourni ». Les types de résultat décrivent la donnée renvoyée dans
//! `fn::result_ok(...)`.

use serde_json::Value;
use surrealdb_types::{Datetime, RecordId, SurrealValue};

// ---------------------------------------------------------------------------
// Paramètres : définitions d'erreurs
// ---------------------------------------------------------------------------

/// Paramètres de `fn::error_definition_create`.
///
/// `code` doit commencer par `UPPER(module)_` (sinon
/// `ERROR_DEFINITION_CODE_PREFIX_MISMATCH`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionCreateParams {
    pub code: String,
    pub module: String,
    pub message: String,
    pub domain: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    pub http_status: Option<u16>,
    pub translations: Option<Value>,
    pub default_language: Option<String>,
    pub retryable: Option<bool>,
    pub log_occurrence: Option<bool>,
    pub documentation: Option<Value>,
    pub metadata: Option<Value>,
    pub enabled: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_definition_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionGetParams {
    pub code: String,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_definition_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionListParams {
    pub module: Option<String>,
    pub domain: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    /// Défaut `true` : seules les définitions actives sont listées.
    pub enabled_only: Option<bool>,
    /// 1 à 500, défaut 50.
    pub limit: Option<u32>,
    /// Défaut 0.
    pub start: Option<u32>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_definition_update` : seuls les champs fournis sont modifiés.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionUpdateParams {
    pub code: String,
    pub message: Option<String>,
    pub domain: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    pub http_status: Option<u16>,
    pub translations: Option<Value>,
    pub default_language: Option<String>,
    pub retryable: Option<bool>,
    pub log_occurrence: Option<bool>,
    pub documentation: Option<Value>,
    pub metadata: Option<Value>,
    pub enabled: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_definition_disable`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionDisableParams {
    pub code: String,
    pub language: Option<String>,
}

// ---------------------------------------------------------------------------
// Paramètres : correspondances d'erreurs externes
// ---------------------------------------------------------------------------

/// Paramètres de `fn::error_mapping_create`.
///
/// `matcher` : `exact` (défaut), `prefix`, `contains` ou `http_status`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingCreateParams {
    pub provider: String,
    pub external_code: String,
    pub definition_code: String,
    pub service: Option<String>,
    pub matcher: Option<String>,
    pub priority: Option<u32>,
    pub external_http_status: Option<u16>,
    pub description: Option<String>,
    pub retryable_override: Option<bool>,
    pub metadata: Option<Value>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_mapping_get`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingGetParams {
    pub mapping_id: RecordId,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_mapping_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingListParams {
    pub provider: Option<String>,
    pub service: Option<String>,
    /// Défaut `true`.
    pub enabled_only: Option<bool>,
    /// 1 à 500, défaut 50.
    pub limit: Option<u32>,
    /// Défaut 0.
    pub start: Option<u32>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_mapping_update` : seuls les champs fournis sont modifiés.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingUpdateParams {
    pub mapping_id: RecordId,
    pub service: Option<String>,
    pub matcher: Option<String>,
    pub definition_code: Option<String>,
    pub priority: Option<u32>,
    pub external_http_status: Option<u16>,
    pub description: Option<String>,
    pub retryable_override: Option<bool>,
    pub enabled: Option<bool>,
    pub metadata: Option<Value>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_mapping_disable`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingDisableParams {
    pub mapping_id: RecordId,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_map_external`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMapExternalParams {
    pub provider: String,
    pub external_code: String,
    pub service: Option<String>,
    pub http_status: Option<u16>,
    pub language: Option<String>,
}

// ---------------------------------------------------------------------------
// Paramètres : occurrences
// ---------------------------------------------------------------------------

/// Paramètres de `fn::error_log`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorLogParams {
    pub code: String,
    pub source_module: String,
    pub operation: Option<String>,
    pub source: Option<RecordId>,
    pub actor: Option<RecordId>,
    pub technical_message: Option<String>,
    pub context: Option<Value>,
    pub request_id: Option<String>,
    pub trace_id: Option<String>,
    pub correlation_id: Option<String>,
    pub fingerprint: Option<String>,
    /// Défaut `production`.
    pub environment: Option<String>,
    pub severity: Option<String>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_occurrence_get`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrenceGetParams {
    pub occurrence_id: RecordId,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_occurrence_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrenceListParams {
    pub code: Option<String>,
    pub source_module: Option<String>,
    /// 1 à 500, défaut 50.
    pub limit: Option<u32>,
    /// Défaut 0.
    pub start: Option<u32>,
    pub language: Option<String>,
}

/// Paramètres de `fn::error_occurrence_purge_before`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrencePurgeParams {
    pub before_date: Datetime,
    pub language: Option<String>,
}

// ---------------------------------------------------------------------------
// Résultats
// ---------------------------------------------------------------------------

/// Définition d'erreur canonique (table `error_definition`).
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinition {
    pub id: RecordId,
    pub code: String,
    pub module: String,
    pub domain: Option<String>,
    pub category: String,
    pub severity: String,
    pub message: String,
    pub translations: Value,
    pub default_language: String,
    pub http_status: Option<u16>,
    pub retryable: bool,
    pub log_occurrence: bool,
    pub enabled: bool,
    pub documentation: Value,
    pub metadata: Value,
    pub version: i64,
    pub created_at: Datetime,
    pub updated_at: Datetime,
}

/// Correspondance d'erreur externe (table `error_external_mapping`).
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMapping {
    pub id: RecordId,
    pub provider: String,
    pub service: Option<String>,
    pub external_code: String,
    pub description: Option<String>,
    pub matcher: String,
    pub definition: RecordId,
    pub priority: i64,
    pub external_http_status: Option<u16>,
    pub retryable_override: Option<bool>,
    pub enabled: bool,
    pub metadata: Value,
    pub created_at: Datetime,
    pub updated_at: Datetime,
}

/// Occurrence d'erreur journalisée (table `error_occurrence`).
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrence {
    pub id: RecordId,
    pub definition: Option<RecordId>,
    pub code: String,
    pub source_module: String,
    pub operation: Option<String>,
    pub source: Option<RecordId>,
    pub actor: Option<RecordId>,
    pub request_id: Option<String>,
    pub trace_id: Option<String>,
    pub correlation_id: Option<String>,
    pub technical_message: Option<String>,
    pub context: Value,
    pub fingerprint: Option<String>,
    pub environment: String,
    pub severity: String,
    pub occurrence_count: i64,
    pub occurred_at: Datetime,
}

/// Résultat de `fn::error_map_external` lorsqu'une correspondance est trouvée
/// (`fn::result_ok(NONE)` sinon, d'où `Option<ErrorExternalMatch>`).
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorExternalMatch {
    pub mapping: RecordId,
    pub definition: RecordId,
    pub definition_code: String,
    pub retryable_override: Option<bool>,
}

/// Résultat de `fn::error_definition_disable` et `fn::error_mapping_disable`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct DisableResult {
    pub id: RecordId,
    pub disabled: bool,
}

/// Résultat de `fn::error_occurrence_purge_before`.
#[derive(Debug, Clone, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct PurgeResult {
    pub before: Datetime,
    pub count: i64,
}
