//! Request types for outbound connector HTTP calls.

use std::collections::HashMap;

use crate::lyxal_core_db::catalog::ApiMethod;

/// Represents an outbound HTTP request built from a connector definition.
///
/// This struct is constructed by the invocation logic from the combination
/// of the `ConnectorDefinition`, the endpoint being called, and the user-provided
/// parameters. It is then passed to `execute_request` for actual HTTP execution.
#[derive(Debug, Clone)]
pub struct ConnectorRequest {
    /// The fully resolved URL (base_url + interpolated path).
    pub url: String,
    /// The HTTP method to use (GET, POST, PUT, PATCH, DELETE, TRACE).
    pub method: ApiMethod,
    /// Merged headers: connector defaults + auth headers.
    pub headers: HashMap<String, String>,
    /// Optional JSON body (for POST, PUT, PATCH methods).
    pub body: Option<serde_json::Value>,
    /// Timeout in milliseconds, from the endpoint's TIMEOUT clause.
    pub timeout_ms: Option<u64>,
}
