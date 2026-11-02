use lyxal_error::LyxalCallError;
use thiserror::Error;

/// Erreurs de connexion et d'appel SurrealDB.
#[derive(Debug, Error)]
#[allow(clippy::large_enum_variant)]
pub enum LyxalSurrealError {
    /// Erreur métier ou contrat non respecté, portée par `lyxal_error`.
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

    #[error("Connection to SurrealDB timed out: {endpoint}")]
    ConnectTimeout { endpoint: String },
}

/// Description d'une erreur de transport, identique à sa définition dans
/// `error/error_definitions.surql`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TransportErrorInfo {
    pub code: &'static str,
    pub category: &'static str,
    pub http_status: u16,
    pub retryable: bool,
    pub message: &'static str,
    pub label: &'static str,
}

const fn internal(
    code: &'static str,
    message: &'static str,
    label: &'static str,
) -> TransportErrorInfo {
    TransportErrorInfo {
        code,
        category: "internal",
        http_status: 500,
        retryable: false,
        message,
        label,
    }
}

impl LyxalSurrealError {
    /// Indique si l'erreur est l'erreur métier `target_code`.
    pub fn is_business_code(&self, target_code: &str) -> bool {
        match self {
            LyxalSurrealError::Call(call_err) => call_err.is_business_code(target_code),
            _ => false,
        }
    }

    /// Code et attributs d'une erreur de transport ; `None` pour `Call`, dont le code est
    /// porté par `lyxal_error`.
    pub fn transport_info(&self) -> Option<TransportErrorInfo> {
        Some(match self {
            LyxalSurrealError::Call(_) => return None,
            LyxalSurrealError::Database(_) => internal(
                "SURREAL_DATABASE_ERROR",
                "A database error occurred",
                "Erreur de base de données",
            ),
            LyxalSurrealError::InvalidFunctionName { .. } => internal(
                "SURREAL_INVALID_FUNCTION_NAME",
                "A SurrealQL function name was refused before execution",
                "Nom de fonction refusé",
            ),
            LyxalSurrealError::UnsupportedEndpoint { .. } => internal(
                "SURREAL_UNSUPPORTED_ENDPOINT",
                "The database endpoint scheme is not supported",
                "Adresse de base de données non prise en charge",
            ),
            LyxalSurrealError::MissingCredentials { .. } => internal(
                "SURREAL_MISSING_CREDENTIALS",
                "Root credentials are required for a remote database endpoint",
                "Identifiants de base de données manquants",
            ),
            LyxalSurrealError::ConnectTimeout { .. } => TransportErrorInfo {
                code: "SURREAL_CONNECT_TIMEOUT",
                category: "timeout",
                http_status: 503,
                retryable: true,
                message: "Connection to the database timed out",
                label: "Délai de connexion à la base de données dépassé",
            },
        })
    }
}

/// Réponse `{ ok: false, data: null, error }`. Une erreur de transport ne divulgue ni l'adresse
/// de la base ni le détail SurrealDB au client : ils restent dans les journaux du serveur.
#[cfg(feature = "axum")]
impl axum::response::IntoResponse for LyxalSurrealError {
    fn into_response(self) -> axum::response::Response {
        use axum::http::StatusCode;
        use axum::Json;

        if let LyxalSurrealError::Call(call_err) = self {
            return call_err.into_response();
        }
        let Some(info) = self.transport_info() else {
            return StatusCode::INTERNAL_SERVER_ERROR.into_response();
        };
        let status =
            StatusCode::from_u16(info.http_status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
        (
            status,
            Json(serde_json::json!({
                "ok": false,
                "data": null,
                "error": {
                    "code": info.code,
                    "message": info.message,
                    "label": info.label,
                    "category": info.category,
                    "severity": "error",
                    "http_status": info.http_status,
                    "retryable": info.retryable
                }
            })),
        )
            .into_response()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn business_error(code: &str) -> LyxalCallError {
        LyxalCallError::Business(lyxal_error::LyxalError {
            code: code.into(),
            message: "Test error".into(),
            label: "Erreur de test".into(),
            description: None,
            resolution: None,
            category: "business".into(),
            severity: "error".into(),
            http_status: Some(409),
            retryable: false,
            documentation: serde_json::json!({}),
            metadata: serde_json::json!({}),
            details: serde_json::json!({}),
        })
    }

    /// Une variante de chaque erreur de transport.
    fn transport_errors() -> Vec<LyxalSurrealError> {
        vec![
            LyxalSurrealError::Database(surrealdb::Error::internal("db error".into())),
            LyxalSurrealError::InvalidFunctionName { function: "bad" },
            LyxalSurrealError::UnsupportedEndpoint {
                endpoint: "ftp://localhost".into(),
            },
            LyxalSurrealError::MissingCredentials {
                endpoint: "ws://localhost:8000".into(),
            },
            LyxalSurrealError::ConnectTimeout {
                endpoint: "ws://localhost:8000".into(),
            },
        ]
    }

    #[test]
    fn test_is_business_code() {
        let err = LyxalSurrealError::Call(business_error("TEST_ERR"));
        assert!(err.is_business_code("TEST_ERR"));
        assert!(!err.is_business_code("OTHER_ERR"));

        let db_err = LyxalSurrealError::InvalidFunctionName { function: "foo" };
        assert!(!db_err.is_business_code("TEST_ERR"));
    }

    /// Chaque code émis existe dans `error/error_definitions.surql`, avec la même catégorie,
    /// le même statut HTTP et le même caractère réessayable.
    #[test]
    fn test_transport_codes_match_master_data() {
        let definitions = include_str!("../error/error_definitions.surql");
        for err in transport_errors() {
            let info = err.transport_info().expect("erreur de transport");
            assert!(info.code.starts_with("SURREAL_"), "{}", info.code);
            let start = definitions
                .find(&format!("CREATE error_definition:{} CONTENT", info.code))
                .unwrap_or_else(|| panic!("{} absent des définitions", info.code));
            let block = &definitions[start..];
            let block = &block[..block.find(") END;").expect("fin de bloc")];
            assert!(block.contains(&format!("code: \"{}\"", info.code)));
            assert!(block.contains(&format!("category: \"{}\"", info.category)));
            assert!(block.contains(&format!("http_status: {}", info.http_status)));
            assert!(block.contains(&format!("retryable: {}", info.retryable)));
            assert!(block.contains(&format!("message: \"{}\"", info.message)));
            assert!(block.contains(&format!("label: \"{}\"", info.label)));
        }
        assert!(LyxalSurrealError::Call(business_error("X"))
            .transport_info()
            .is_none());
    }

    #[cfg(feature = "axum")]
    #[tokio::test]
    async fn test_axum_into_response_mapping() {
        use axum::body::to_bytes;
        use axum::response::IntoResponse;

        for err in transport_errors() {
            let info = err.transport_info().expect("erreur de transport");
            let res = err.into_response();
            assert_eq!(res.status().as_u16(), info.http_status);
            let body = to_bytes(res.into_body(), usize::MAX).await.expect("corps");
            let json: serde_json::Value = serde_json::from_slice(&body).expect("JSON");
            assert_eq!(json["ok"], false);
            assert!(json["data"].is_null());
            assert_eq!(json["error"]["code"], info.code);
            assert_eq!(json["error"]["category"], info.category);
            assert_eq!(json["error"]["retryable"], info.retryable);
            let text = json.to_string();
            assert!(!text.contains("localhost"), "adresse divulguée : {text}");
        }

        // Une erreur métier garde le statut et le code résolus par lyxal_error
        let res = LyxalSurrealError::Call(business_error("BOOKING_SLOT_TAKEN")).into_response();
        assert_eq!(res.status().as_u16(), 409);
        let body = to_bytes(res.into_body(), usize::MAX).await.expect("corps");
        let json: serde_json::Value = serde_json::from_slice(&body).expect("JSON");
        assert_eq!(json["error"]["code"], "BOOKING_SLOT_TAKEN");

        // Une réponse hors contrat donne ERROR_INVALID_FUNCTION_RESPONSE
        let res = LyxalSurrealError::Call(LyxalCallError::InvalidContract { function: "f" })
            .into_response();
        assert_eq!(res.status().as_u16(), 500);
        let body = to_bytes(res.into_body(), usize::MAX).await.expect("corps");
        let json: serde_json::Value = serde_json::from_slice(&body).expect("JSON");
        assert_eq!(json["error"]["code"], "ERROR_INVALID_FUNCTION_RESPONSE");
    }
}
