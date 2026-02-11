//! DAV Request Context
//!
//! Wraps HTTP request information for DAV handlers.

use std::collections::HashMap;
use std::sync::Arc;
use surrealdb_core::dav::DavBackend;

/// Context for a DAV request
pub struct DavContext {
    /// HTTP method (PROPFIND, PUT, GET, etc.)
    pub method: String,
    /// Request path
    pub path: String,
    /// Request body
    pub body: Vec<u8>,
    /// Request headers
    pub headers: HashMap<String, String>,
    /// Backend for storage operations
    pub backend: Arc<dyn DavBackend>,
    /// Authenticated principal username
    pub principal: Option<String>,
    /// Tenant/realm ID extracted from path
    pub realm: Option<String>,
}

impl DavContext {
    /// Create a new DAV context
    pub fn new(
        method: String,
        path: String,
        body: Vec<u8>,
        headers: HashMap<String, String>,
        backend: Arc<dyn DavBackend>,
        principal: Option<String>,
    ) -> Self {
        // Extract realm from path: /dav/{realm}/... or /realms/{realm}/dav/...
        let realm = extract_realm_from_path(&path);
        Self {
            method,
            path,
            body,
            headers,
            backend,
            principal,
            realm,
        }
    }

    /// Get a header value (case-insensitive)
    pub fn header(&self, name: &str) -> Option<&String> {
        let lower = name.to_ascii_lowercase();
        self.headers
            .iter()
            .find(|(k, _)| k.to_ascii_lowercase() == lower)
            .map(|(_, v)| v)
    }

    /// Get the authenticated principal
    pub fn principal(&self) -> Option<&str> {
        self.principal.as_deref()
    }

    /// Get the Depth header value
    pub fn depth(&self) -> &str {
        self.header("depth").map(|s| s.as_str()).unwrap_or("infinity")
    }
}

/// Extract realm ID from path
fn extract_realm_from_path(path: &str) -> Option<String> {
    let parts: Vec<&str> = path.split('/').collect();
    
    // Pattern 1: /dav/{realm}/...
    if parts.len() >= 3 && parts.get(1) == Some(&"dav") {
        return parts.get(2).map(|s| s.to_string());
    }
    
    // Pattern 2: /realms/{realm}/dav/...
    if parts.len() >= 4 && parts.get(1) == Some(&"realms") {
        return parts.get(2).map(|s| s.to_string());
    }
    
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_realm_dav_pattern() {
        assert_eq!(
            extract_realm_from_path("/dav/tenant1/calendars/user/home"),
            Some("tenant1".to_string())
        );
    }

    #[test]
    fn test_extract_realm_realms_pattern() {
        assert_eq!(
            extract_realm_from_path("/realms/realm123/dav/calendars/user"),
            Some("realm123".to_string())
        );
    }

    #[test]
    fn test_extract_realm_none() {
        assert_eq!(extract_realm_from_path("/calendars/user/home"), None);
    }
}
