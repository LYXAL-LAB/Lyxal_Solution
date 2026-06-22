//! Response types for outbound connector HTTP calls.

use std::collections::HashMap;

use crate::lyxal_core_db::val::{Object, Value};

/// Represents the HTTP response received from a remote endpoint.
///
/// This struct captures the raw HTTP response and provides methods
/// to convert it into a Lyxal `Value` that can be returned to
/// the caller of `connector::call()`.
#[derive(Debug, Clone)]
pub struct ConnectorResponse {
    /// The HTTP status code returned by the remote server.
    pub status: u16,
    /// The response headers.
    pub headers: HashMap<String, String>,
    /// The response body, already converted to a Lyxal `Value`.
    pub body: Value,
}

impl ConnectorResponse {
    /// Converts this response into a structured Lyxal `Value` (Object)
    /// containing `status`, `headers`, and `body`.
    pub fn into_value(self) -> Value {
        let mut map = std::collections::BTreeMap::new();

        // Status
        map.insert(
            "status".to_string(),
            Value::from(self.status as i64),
        );

        // Headers as object
        let headers_obj: std::collections::BTreeMap<String, Value> = self
            .headers
            .into_iter()
            .map(|(k, v)| (k, Value::from(v)))
            .collect();
        map.insert("headers".to_string(), Value::Object(Object(headers_obj)));

        // Body
        map.insert("body".to_string(), self.body);

        Value::Object(Object(map))
    }
}
