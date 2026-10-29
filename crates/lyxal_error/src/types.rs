use serde::{Deserialize, Serialize};
use serde_json::Value;

/// Paramètres de création d'une définition d'erreur canonique (`fn::error_definition_create`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorDefinitionCreateParams {
    pub code: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub module: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub domain: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub severity: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub retryable: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub log_occurrence: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub translations: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub documentation: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub metadata: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none", alias = "active")]
    pub enabled: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de consultation d'une définition d'erreur (`fn::error_definition_get`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorDefinitionGetParams {
    pub code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de liste des définitions d'erreurs (`fn::error_definition_list`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorDefinitionListParams {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub module: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub domain: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub severity: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub enabled_only: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub limit: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub start: Option<u32>,
}

/// Paramètres de mise à jour d'une définition d'erreur (`fn::error_definition_update`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorDefinitionUpdateParams {
    pub code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub message: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub category: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub severity: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub retryable: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub log_occurrence: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub translations: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub documentation: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub metadata: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub active: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub enabled: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de désactivation d'une définition d'erreur (`fn::error_definition_disable`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorDefinitionDisableParams {
    pub code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de création d'une règle de correspondance d'erreur externe (`fn::error_mapping_create`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMappingCreateParams {
    pub provider: String,
    #[serde(alias = "matcher")]
    pub match_type: String,
    #[serde(alias = "definition_id", alias = "definition")]
    pub target_code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub service: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub external_code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub external_http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub priority: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub retryable_override: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de consultation d'un mapping d'erreur (`fn::error_mapping_get`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMappingGetParams {
    pub mapping_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de liste des mappings d'erreurs (`fn::error_mapping_list`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMappingListParams {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub provider: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub service: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub enabled_only: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub limit: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub start: Option<u32>,
}

/// Paramètres de mise à jour d'un mapping d'erreur (`fn::error_mapping_update`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMappingUpdateParams {
    pub mapping_id: String,
    #[serde(skip_serializing_if = "Option::is_none", alias = "definition_id", alias = "definition")]
    pub target_code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none", alias = "matcher")]
    pub match_type: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub service: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub external_code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub external_http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub priority: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub retryable_override: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub active: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub enabled: Option<bool>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de désactivation d'un mapping d'erreur (`fn::error_mapping_disable`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMappingDisableParams {
    pub mapping_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de journalisation d'une occurrence d'erreur (`fn::error_log`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorLogParams {
    pub code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source_module: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub operation: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub actor: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub technical_message: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub context: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub trace_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub correlation_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub environment: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub severity: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de consultation d'une occurrence d'erreur (`fn::error_occurrence_get`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorOccurrenceGetParams {
    pub occurrence_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de liste des occurrences d'erreurs (`fn::error_occurrence_list`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorOccurrenceListParams {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub source_module: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub limit: Option<u32>,
}

/// Paramètres de purge des occurrences d'erreurs (`fn::error_occurrence_purge_before`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorOccurrencePurgeParams {
    pub before_date: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}

/// Paramètres de résolution d'une correspondance externe (`fn::error_map_external`).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorMapExternalParams {
    pub provider: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub external_code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub http_status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub language: Option<String>,
}
