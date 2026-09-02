use lyxal_error::LyxalCallError;
use thiserror::Error;

/// Enumération typée des erreurs d'appel et d'exécution SurrealDB.
#[derive(Debug, Error)]
#[allow(clippy::large_enum_variant)]
pub enum LyxalSurrealError {
    #[error(transparent)]
    Call(#[from] LyxalCallError),

    #[error("SurrealDB error: {0}")]
    Database(#[from] surrealdb::Error),

    #[error("Invalid function name: {function}")]
    InvalidFunctionName { function: &'static str },

    #[error("Unsupported endpoint scheme for endpoint: {endpoint}")]
    UnsupportedEndpoint { endpoint: String },

    #[error("Missing Root credentials for remote endpoint: {endpoint}")]
    MissingCredentials { endpoint: String },
}

impl LyxalSurrealError {
    /// Teste si l'erreur sous-jacente correspond à un code métier spécifique.
    pub fn is_business_code(&self, target_code: &str) -> bool {
        match self {
            LyxalSurrealError::Call(call_err) => call_err.is_business_code(target_code),
            _ => false,
        }
    }
}

#[cfg(feature = "axum")]
impl axum::response::IntoResponse for LyxalSurrealError {
    fn into_response(self) -> axum::response::Response {
        use axum::http::StatusCode;
        use axum::Json;

        match self {
            LyxalSurrealError::Call(call_err) => call_err.into_response(),

            LyxalSurrealError::Database(_) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "CORE_DATABASE_ERROR",
                        "message": "A database error occurred",
                        "label": "Une erreur de base de données est survenue",
                        "category": "internal",
                        "severity": "error",
                        "http_status": 500,
                        "retryable": true
                    }
                })),
            )
                .into_response(),

            LyxalSurrealError::InvalidFunctionName { function: _ } => (
                StatusCode::BAD_REQUEST,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "CORE_INVALID_FUNCTION_NAME",
                        "message": "The function name provided is invalid",
                        "label": "Nom de fonction système invalide",
                        "category": "validation",
                        "severity": "error",
                        "http_status": 400,
                        "retryable": false
                    }
                })),
            )
                .into_response(),
        }
    }
}
