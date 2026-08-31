use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde::Serialize;
use thiserror::Error;
use uuid::Uuid;

#[derive(Debug, Error)]
pub enum ServerError {
    #[error("erreur de configuration : {0}")]
    Configuration(String),

    #[error("erreur de base de données : {0}")]
    Database(String),

    #[error("erreur du runtime : {0}")]
    Runtime(String),

    #[error("erreur du module `{module}` : {message}")]
    Module { module: String, message: String },

    #[error("erreur HTTP : {0}")]
    Http(String),

    #[error("arrêt du serveur : {0}")]
    Shutdown(String),

    #[error("erreur interne : {0}")]
    Internal(String),
}

impl ServerError {
    pub fn code(&self) -> &'static str {
        match self {
            Self::Configuration(_) => "LYXAL_CONFIGURATION_ERROR",
            Self::Database(_) => "LYXAL_DATABASE_ERROR",
            Self::Runtime(_) => "LYXAL_RUNTIME_ERROR",
            Self::Module { .. } => "LYXAL_MODULE_ERROR",
            Self::Http(_) => "LYXAL_HTTP_ERROR",
            Self::Shutdown(_) => "LYXAL_SHUTDOWN_ERROR",
            Self::Internal(_) => "LYXAL_INTERNAL_ERROR",
        }
    }

    fn status(&self) -> StatusCode {
        match self {
            Self::Configuration(_) => StatusCode::INTERNAL_SERVER_ERROR,
            Self::Database(_) => StatusCode::SERVICE_UNAVAILABLE,
            Self::Runtime(_) | Self::Module { .. } => StatusCode::SERVICE_UNAVAILABLE,
            Self::Http(_) => StatusCode::BAD_REQUEST,
            Self::Shutdown(_) | Self::Internal(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

#[derive(Debug, Serialize)]
struct ErrorEnvelope {
    error: ErrorBody,
}

#[derive(Debug, Serialize)]
struct ErrorBody {
    code: &'static str,
    message: String,
    trace_id: String,
}

impl IntoResponse for ServerError {
    fn into_response(self) -> Response {
        let status = self.status();
        let body = ErrorEnvelope {
            error: ErrorBody {
                code: self.code(),
                message: self.to_string(),
                trace_id: Uuid::new_v4().to_string(),
            },
        };
        (status, Json(body)).into_response()
    }
}

impl From<std::io::Error> for ServerError {
    fn from(value: std::io::Error) -> Self {
        Self::Internal(value.to_string())
    }
}
