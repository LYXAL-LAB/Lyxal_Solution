use serde_json::Value;
use surrealdb_types::SurrealValue;

/// Paramètres de création d'une définition d'erreur canonique (`fn::error_definition_create`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionCreateParams {
    pub code: String,
    pub message: String,
    pub module: Option<String>,
    pub domain: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    pub http_status: Option<u16>,
    pub retryable: Option<bool>,
    pub log_occurrence: Option<bool>,
    pub translations: Option<Value>,
    pub documentation: Option<Value>,
    pub metadata: Option<Value>,
    pub enabled: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de consultation d'une définition d'erreur (`fn::error_definition_get`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionGetParams {
    pub code: String,
    pub language: Option<String>,
}

/// Paramètres de liste des définitions d'erreurs (`fn::error_definition_list`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionListParams {
    pub module: Option<String>,
    pub domain: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    pub enabled_only: Option<bool>,
    pub limit: Option<u32>,
    pub start: Option<u32>,
}

/// Paramètres de mise à jour d'une définition d'erreur (`fn::error_definition_update`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionUpdateParams {
    pub code: String,
    pub message: Option<String>,
    pub category: Option<String>,
    pub severity: Option<String>,
    pub http_status: Option<u16>,
    pub retryable: Option<bool>,
    pub log_occurrence: Option<bool>,
    pub translations: Option<Value>,
    pub documentation: Option<Value>,
    pub metadata: Option<Value>,
    pub active: Option<bool>,
    pub enabled: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de désactivation d'une définition d'erreur (`fn::error_definition_disable`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorDefinitionDisableParams {
    pub code: String,
    pub language: Option<String>,
}

/// Paramètres de création d'une règle de correspondance d'erreur externe (`fn::error_mapping_create`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingCreateParams {
    pub provider: String,
    pub match_type: String,
    pub target_code: String,
    pub service: Option<String>,
    pub external_code: Option<String>,
    pub http_status: Option<u16>,
    pub external_http_status: Option<u16>,
    pub priority: Option<u32>,
    pub description: Option<String>,
    pub retryable_override: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de consultation d'un mapping d'erreur (`fn::error_mapping_get`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingGetParams {
    pub mapping_id: String,
    pub language: Option<String>,
}

/// Paramètres de liste des mappings d'erreurs (`fn::error_mapping_list`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingListParams {
    pub provider: Option<String>,
    pub service: Option<String>,
    pub enabled_only: Option<bool>,
    pub limit: Option<u32>,
    pub start: Option<u32>,
}

/// Paramètres de mise à jour d'un mapping d'erreur (`fn::error_mapping_update`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingUpdateParams {
    pub mapping_id: String,
    pub target_code: Option<String>,
    pub match_type: Option<String>,
    pub service: Option<String>,
    pub external_code: Option<String>,
    pub http_status: Option<u16>,
    pub external_http_status: Option<u16>,
    pub priority: Option<u32>,
    pub description: Option<String>,
    pub retryable_override: Option<bool>,
    pub active: Option<bool>,
    pub enabled: Option<bool>,
    pub language: Option<String>,
}

/// Paramètres de désactivation d'un mapping d'erreur (`fn::error_mapping_disable`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMappingDisableParams {
    pub mapping_id: String,
    pub language: Option<String>,
}

/// Paramètres de journalisation d'une occurrence d'erreur (`fn::error_log`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorLogParams {
    pub code: String,
    pub source_module: Option<String>,
    pub operation: Option<String>,
    pub source: Option<String>,
    pub actor: Option<String>,
    pub technical_message: Option<String>,
    pub context: Option<Value>,
    pub trace_id: Option<String>,
    pub correlation_id: Option<String>,
    pub environment: Option<String>,
    pub severity: Option<String>,
    pub language: Option<String>,
}

/// Paramètres de consultation d'une occurrence d'erreur (`fn::error_occurrence_get`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrenceGetParams {
    pub occurrence_id: String,
    pub language: Option<String>,
}

/// Paramètres de liste des occurrences d'erreurs (`fn::error_occurrence_list`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrenceListParams {
    pub code: Option<String>,
    pub source_module: Option<String>,
    pub limit: Option<u32>,
}

/// Paramètres de purge des occurrences d'erreurs (`fn::error_occurrence_purge_before`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorOccurrencePurgeParams {
    pub before_date: String,
    pub language: Option<String>,
}

/// Paramètres de résolution d'une correspondance externe (`fn::error_map_external`).
#[derive(Debug, Clone, Default, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct ErrorMapExternalParams {
    pub provider: String,
    pub external_code: Option<String>,
    pub http_status: Option<u16>,
    pub language: Option<String>,
}
