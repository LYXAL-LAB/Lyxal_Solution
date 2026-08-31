use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use crate::contracts::errors::ApiErrorBody;

#[derive(Debug)]
pub enum WebError {
    Unauthorized(String),
    Forbidden(String),
    NotFound(String),
    BadRequest(String),
    Conflict(String),
    Internal(String),
    Surreal(lyxal_surreal::LyxalSurrealError),
}

impl From<lyxal_surreal::LyxalSurrealError> for WebError {
    fn from(err: lyxal_surreal::LyxalSurrealError) -> Self {
        WebError::Surreal(err)
    }
}

impl IntoResponse for WebError {
    fn into_response(self) -> Response {
        let (status, code, message) = match self {
            WebError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, "UNAUTHORIZED", msg),
            WebError::Forbidden(msg) => (StatusCode::FORBIDDEN, "FORBIDDEN", msg),
            WebError::NotFound(msg) => (StatusCode::NOT_FOUND, "NOT_FOUND", msg),
            WebError::BadRequest(msg) => (StatusCode::BAD_REQUEST, "BAD_REQUEST", msg),
            WebError::Conflict(msg) => (StatusCode::CONFLICT, "CONFLICT", msg),
            WebError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", msg),
            WebError::Surreal(_err) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "DATABASE_ERROR",
                "An internal database error occurred.".to_string(),
            ),
        };

        let body = ApiErrorBody {
            code: code.to_string(),
            message,
            details: None,
            request_id: None,
        };

        (status, axum::Json(body)).into_response()
    }
}
