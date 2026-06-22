use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;
use thiserror::Error;

/// Core error type for the Lyxal Identity system.
/// This error type is designed to be shared across all modules
/// and provides a standard way to handle and display errors.
#[derive(Debug, Error)]
pub enum CoreError {
    #[error("Internal server error")]
    Internal(#[from] anyhow::Error),

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Entity not found: {0}")]
    NotFound(String),

    #[error("Unauthorized: {0}")]
    Unauthorized(String),

    #[error("Forbidden: {0}")]
    Forbidden(String),

    #[error("Validation error: {0}")]
    Validation(String),

    #[error("Conflict: {0}")]
    Conflict(String),

    #[error("External service error: {0}")]
    ExternalService(String),

    #[error("Authentication error: {0}")]
    Auth(String),

    #[error("Configuration error: {0}")]
    Configuration(String),
}

/// Implementation of IntoResponse for Axum to automatically
/// convert CoreError into a HTTP response.
impl IntoResponse for CoreError {
    fn into_response(self) -> Response {
        let (status, error_code, message) = match self {
            CoreError::Internal(ref e) => {
                tracing::error!("Internal Server Error: {:?}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "internal_server_error",
                    self.to_string(),
                )
            }
            CoreError::Database(ref e) => {
                tracing::error!("Database Error: {:?}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "database_error",
                    "A database error occurred".to_string(),
                )
            }
            CoreError::NotFound(msg) => (StatusCode::NOT_FOUND, "not_found", msg),
            CoreError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, "unauthorized", msg),
            CoreError::Forbidden(msg) => (StatusCode::FORBIDDEN, "forbidden", msg),
            CoreError::Validation(msg) => (StatusCode::BAD_REQUEST, "validation_failed", msg),
            CoreError::Conflict(msg) => (StatusCode::CONFLICT, "conflict", msg),
            CoreError::Auth(msg) => (StatusCode::UNAUTHORIZED, "authentication_failed", msg),
            CoreError::Configuration(msg) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "configuration_error",
                msg,
            ),
            CoreError::ExternalService(msg) => {
                (StatusCode::BAD_GATEWAY, "external_service_error", msg)
            }
        };

        let body = Json(json!({
            "error": error_code,
            "message": message,
        }));

        (status, body).into_response()
    }
}

/// Generic alias for Result with CoreError
pub type Result<T> = std::result::Result<T, CoreError>;
