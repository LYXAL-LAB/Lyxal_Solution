//! Webhook types and definitions

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Webhook payload passed to handlers
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebhookPayload {
    /// The webhook path that was called
    pub path: String,
    /// HTTP method used
    pub method: String,
    /// Parsed body content
    pub body: serde_json::Value,
    /// Selected headers (non-sensitive)
    pub headers: HashMap<String, String>,
    /// Timestamp of receipt
    pub received_at: chrono::DateTime<chrono::Utc>,
    /// Webhook name from definition
    pub webhook_name: String,
    /// Namespace
    pub namespace: String,
    /// Database
    pub database: String,
}

/// Result of webhook dispatch
#[derive(Debug, Clone)]
pub enum DispatchResult {
    /// Handler executed successfully
    Success {
        /// Handler return value (if any)
        result: Option<serde_json::Value>,
    },
    /// Webhook was rejected (signature invalid, disabled, etc.)
    Rejected {
        /// Reason for rejection
        reason: String,
        /// HTTP status code to return
        status_code: u16,
    },
    /// Handler execution failed
    Failed {
        /// Error message
        error: String,
    },
}

impl DispatchResult {
    /// Create a success result
    pub fn success(result: Option<serde_json::Value>) -> Self {
        Self::Success { result }
    }

    /// Create a rejected result
    pub fn rejected(reason: impl Into<String>, status_code: u16) -> Self {
        Self::Rejected {
            reason: reason.into(),
            status_code,
        }
    }

    /// Create a failed result
    pub fn failed(error: impl Into<String>) -> Self {
        Self::Failed {
            error: error.into(),
        }
    }

    /// Check if the result is successful
    pub fn is_success(&self) -> bool {
        matches!(self, Self::Success { .. })
    }

    /// Get the HTTP status code for this result
    pub fn status_code(&self) -> u16 {
        match self {
            Self::Success { .. } => 200,
            Self::Rejected { status_code, .. } => *status_code,
            Self::Failed { .. } => 500,
        }
    }
}

/// Verification mode for webhook signatures
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum WebhookVerifyMode {
    /// No verification required
    None,
    /// HMAC-SHA256 verification
    Hmac,
    /// Stripe-Signature verification
    Stripe,
    /// RSA signature verification
    Rsa,
    /// Custom verification (extensible)
    Custom(String),
}

impl Default for WebhookVerifyMode {
    fn default() -> Self {
        Self::None
    }
}

/// Content type for webhook payload parsing
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, Default)]
pub enum WebhookContentType {
    /// JSON payload (default)
    #[default]
    Json,
    /// Raw text/bytes
    Raw,
    /// Form-urlencoded
    Form,
    /// Binary data
    Binary,
}

/// Handler type for webhook execution
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum WebhookHandlerType {
    /// Call a function: fn::namespace::function
    Function(String),
    /// Trigger an event: DEFINE EVENT
    Event(String),
}

/// Persistent webhook definition (stored in catalogue)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebhookDefinition {
    /// Unique name
    pub name: String,
    /// Path pattern to match
    pub path: String,
    /// HTTP method (GET, POST, etc.)
    pub method: String,
    /// Verification mode
    pub verify: WebhookVerifyMode,
    /// Secret expression (evaluated at runtime)
    pub secret: Option<String>,
    /// Content type for parsing
    pub content_type: WebhookContentType,
    /// Handler to execute
    pub handler: WebhookHandlerType,
    /// Whether the webhook is enabled
    pub enabled: bool,
    /// Optional comment
    pub comment: Option<String>,
    /// Namespace scope
    pub namespace: String,
    /// Database scope
    pub database: String,
}

impl WebhookDefinition {
    /// Create a new webhook definition
    pub fn new(
        name: impl Into<String>,
        path: impl Into<String>,
        handler: WebhookHandlerType,
        namespace: impl Into<String>,
        database: impl Into<String>,
    ) -> Self {
        Self {
            name: name.into(),
            path: path.into(),
            method: "POST".to_string(),
            verify: WebhookVerifyMode::None,
            secret: None,
            content_type: WebhookContentType::Json,
            handler,
            enabled: true,
            comment: None,
            namespace: namespace.into(),
            database: database.into(),
        }
    }

    /// Generate a unique key for registry lookup
    pub fn registry_key(&self) -> String {
        format!("{}:{}:{}:{}", self.namespace, self.database, self.method, self.path)
    }
}
