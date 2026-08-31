use serde::{Deserialize, Serialize};
use serde_json::Value;
use thiserror::Error;

/// Structure universelle représentant une erreur métier résolue et traduite par SurrealDB (`fn::error_resolve`).
#[derive(Debug, Clone, Serialize, Deserialize)]
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
    pub documentation: Value,
    pub metadata: Value,

    #[serde(default)]
    pub details: Value,
}

/// Enumération typée des erreurs d'appel métier indépendantes du moteur de base de données.
#[derive(Debug, Error)]
pub enum LyxalCallError {
    #[error("{}: {}", .0.code, .0.label)]
    Business(LyxalError),

    #[error("Business error code: {code}")]
    BusinessCode {
        code: &'static str,
        details: Value,
    },

    #[error("Invalid result contract from function: {function}")]
    InvalidContract { function: &'static str },
}

impl LyxalCallError {
    /// Constructeur générique d'erreur métier par code canonique (ex: "BOOKING_AUTH_INVALID_CREDENTIALS").
    pub fn business_code(code: &'static str, details: Value) -> Self {
        Self::BusinessCode { code, details }
    }

    /// Teste si l'erreur correspond à un code métier spécifique de manière robuste.
    pub fn is_business_code(&self, target_code: &str) -> bool {
        match self {
            LyxalCallError::Business(err) => err.code == target_code,
            LyxalCallError::BusinessCode { code, .. } => *code == target_code,
            _ => false,
        }
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

            LyxalCallError::BusinessCode { code, details } => (
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": code,
                        "message": "Authentication failed",
                        "label": "Échec d'authentification",
                        "category": "authentication",
                        "severity": "error",
                        "http_status": 401,
                        "retryable": false,
                        "details": details
                    }
                })),
            )
                .into_response(),

            LyxalCallError::InvalidContract { function: _ } => (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "CORE_INVALID_FUNCTION_RESPONSE",
                        "message": "Invalid response contract from SurrealQL function",
                        "label": "Une erreur de réponse système est survenue",
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
