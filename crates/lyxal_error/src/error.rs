use serde::{Deserialize, Serialize};
use serde_json::Value;
use surrealdb_types::SurrealValue;
use thiserror::Error;

/// Structure universelle représentant une erreur métier résolue et traduite par SurrealDB (`fn::error_resolve`).
///
/// Lue depuis SurrealDB via `SurrealValue` et renvoyée en JSON par l'API HTTP via `serde`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct LyxalError {
    pub code: String,
    pub message: String,
    pub label: String,
    pub description: Option<String>,
    pub resolution: Option<String>,
    pub category: String,
    pub severity: String,
    pub http_status: Option<u16>,
    pub retryable: bool,
    #[serde(default)]
    #[surreal(default)]
    pub documentation: Value,
    #[serde(default)]
    #[surreal(default)]
    pub metadata: Value,
    #[serde(default)]
    #[surreal(default)]
    pub details: Value,
}

/// Erreur d'appel d'une fonction SurrealQL Lyxal, indépendante du moteur de base de données.
#[derive(Debug, Error)]
pub enum LyxalCallError {
    /// Erreur métier renvoyée par `fn::error_result`, résolue et traduite par SurrealQL.
    #[error("{}: {}", .0.code, .0.label)]
    Business(LyxalError),

    /// Réponse qui ne respecte pas le contrat `{ ok, data, error }`
    /// (code `ERROR_INVALID_FUNCTION_RESPONSE`).
    #[error("Invalid result contract from function: {function}")]
    InvalidContract { function: &'static str },
}

impl LyxalCallError {
    /// Indique si l'erreur est l'erreur métier `target_code`.
    pub fn is_business_code(&self, target_code: &str) -> bool {
        matches!(self, LyxalCallError::Business(err) if err.code == target_code)
    }
}

#[cfg(feature = "axum")]
impl axum::response::IntoResponse for LyxalCallError {
    fn into_response(self) -> axum::response::Response {
        use axum::http::StatusCode;
        use axum::Json;

        match self {
            LyxalCallError::Business(error) => {
                let status = error
                    .http_status
                    .and_then(|val| StatusCode::from_u16(val).ok())
                    .unwrap_or(StatusCode::BAD_REQUEST);

                (
                    status,
                    Json(serde_json::json!({
                        "ok": false,
                        "data": null,
                        "error": error
                    })),
                )
                    .into_response()
            }

            LyxalCallError::InvalidContract { function: _ } => (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "ERROR_INVALID_FUNCTION_RESPONSE",
                        "message": "A database function returned a response that does not match the result contract",
                        "label": "Réponse système invalide",
                        "category": "internal",
                        "severity": "error",
                        "http_status": 500,
                        "retryable": false
                    }
                })),
            )
                .into_response(),
        }
    }
}
