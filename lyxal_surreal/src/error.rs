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

            LyxalSurrealError::UnsupportedEndpoint { endpoint } => (
                StatusCode::BAD_REQUEST,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "CORE_UNSUPPORTED_ENDPOINT",
                        "message": format!("The endpoint scheme is not supported: {}", endpoint),
                        "label": "Protocole de connexion base de données non supporté",
                        "category": "validation",
                        "severity": "error",
                        "http_status": 400,
                        "retryable": false
                    }
                })),
            )
                .into_response(),

            LyxalSurrealError::MissingCredentials { endpoint } => (
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({
                    "ok": false,
                    "data": null,
                    "error": {
                        "code": "CORE_MISSING_CREDENTIALS",
                        "message": format!("Root credentials are required for remote endpoint: {}", endpoint),
                        "label": "Identifiants Root obligatoires pour le point de terminaison distant",
                        "category": "security",
                        "severity": "error",
                        "http_status": 401,
                        "retryable": false
                    }
                })),
            )
                .into_response(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_business_code() {
        let call_err = LyxalCallError::BusinessCode {
            code: "TEST_ERR",
            details: serde_json::json!({}),
        };
        let err = LyxalSurrealError::Call(call_err);
        assert!(err.is_business_code("TEST_ERR"));
        assert!(!err.is_business_code("OTHER_ERR"));

        let db_err = LyxalSurrealError::InvalidFunctionName { function: "foo" };
        assert!(!db_err.is_business_code("TEST_ERR"));
    }

    #[cfg(feature = "axum")]
    #[test]
    fn test_axum_into_response_mapping() {
        use axum::http::StatusCode;
        use axum::response::IntoResponse;

        // 1. Database error -> 500
        let db_err = LyxalSurrealError::Database(surrealdb::Error::Db(
            surrealdb::error::Db::Internal("db error".into()),
        ));
        let res = db_err.into_response();
        assert_eq!(res.status(), StatusCode::INTERNAL_SERVER_ERROR);

        // 2. Invalid function name -> 400
        let fn_err = LyxalSurrealError::InvalidFunctionName { function: "bad" };
        let res = fn_err.into_response();
        assert_eq!(res.status(), StatusCode::BAD_REQUEST);

        // 3. Unsupported endpoint -> 400
        let ep_err = LyxalSurrealError::UnsupportedEndpoint {
            endpoint: "ftp://localhost".into(),
        };
        let res = ep_err.into_response();
        assert_eq!(res.status(), StatusCode::BAD_REQUEST);

        // 4. Missing credentials -> 401
        let cred_err = LyxalSurrealError::MissingCredentials {
            endpoint: "ws://localhost:8000".into(),
        };
        let res = cred_err.into_response();
        assert_eq!(res.status(), StatusCode::UNAUTHORIZED);
    }
}
