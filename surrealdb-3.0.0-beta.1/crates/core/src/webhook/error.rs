//! Webhook error types

use thiserror::Error;

/// Result type for webhook operations
pub type Result<T> = std::result::Result<T, WebhookError>;

/// Errors that can occur during webhook processing
#[derive(Debug, Error)]
pub enum WebhookError {
    /// Webhook definition not found
    #[error("Webhook not found: {path}")]
    NotFound { path: String },

    /// Webhook is disabled
    #[error("Webhook is disabled: {name}")]
    Disabled { name: String },

    /// Signature verification failed
    #[error("Signature verification failed: {reason}")]
    SignatureInvalid { reason: String },

    /// Signature has expired (replay protection)
    #[error("Signature expired: timestamp too old")]
    SignatureExpired,

    /// Missing required header for verification
    #[error("Missing required header: {header}")]
    MissingHeader { header: String },

    /// Secret not configured or not found
    #[error("Secret not configured for webhook: {name}")]
    SecretNotConfigured { name: String },

    /// Payload parsing failed
    #[error("Failed to parse payload: {reason}")]
    PayloadParseError { reason: String },

    /// Handler execution failed
    #[error("Handler execution failed: {reason}")]
    HandlerError { reason: String },

    /// Database/transaction error
    #[error("Database error: {0}")]
    DatabaseError(String),

    /// Internal error
    #[error("Internal error: {0}")]
    Internal(String),
}

impl WebhookError {
    /// Returns the appropriate HTTP status code for this error
    pub fn status_code(&self) -> u16 {
        match self {
            Self::NotFound { .. } => 404,
            Self::Disabled { .. } => 503,
            Self::SignatureInvalid { .. } => 401,
            Self::SignatureExpired => 401,
            Self::MissingHeader { .. } => 400,
            Self::SecretNotConfigured { .. } => 500,
            Self::PayloadParseError { .. } => 400,
            Self::HandlerError { .. } => 500,
            Self::DatabaseError(_) => 500,
            Self::Internal(_) => 500,
        }
    }

    /// Returns whether this error should be logged as a security event
    pub fn is_security_event(&self) -> bool {
        matches!(
            self,
            Self::SignatureInvalid { .. } | Self::SignatureExpired | Self::MissingHeader { .. }
        )
    }
}
