//! # Lyxal DAV Core
//!
//! Native implementation of CalDAV and CardDAV protocols.
//! Designed for zero-copy parsing and direct database integration.
//!
//! This crate is the Rust implementation of the DAV protocol layer.
//! It can be tested standalone with mock backends before integration.
//!
//! ## Usage
//! ```rust,ignore
//! use lyxal_dav_core::{DavContext, process};
//! use lyxal_dav_core::backend::DavBackend;
//! use std::sync::Arc;
//!
//! // Implement DavBackend for your storage
//! let backend: Arc<dyn DavBackend> = /* your implementation */;
//! let ctx = DavContext::new("PROPFIND".into(), "/calendars/user".into(), vec![], backend);
//! let response = process(ctx).await?;
//! ```

pub mod error;
pub mod xml;
pub mod backend;
pub mod methods;
pub mod ical;

/// Main entry point for processing a DAV request
/// This struct simulates the "Context" of a DAV transaction
pub struct DavContext {
    pub method: String,
    pub path: String,
    pub body: Vec<u8>,
    pub headers: std::collections::HashMap<String, String>,
    pub backend: std::sync::Arc<dyn crate::backend::DavBackend>,
    // In the future: User/Auth info
}

impl DavContext {
    pub fn new(method: String, path: String, body: Vec<u8>, headers: std::collections::HashMap<String, String>, backend: std::sync::Arc<dyn crate::backend::DavBackend>) -> Self {
        Self { method, path, body, headers, backend }
    }
}

use crate::error::DavError;

/// Process a DAV request and return a DAV response
pub async fn process(ctx: DavContext) -> Result<String, DavError> {
    match ctx.method.as_str() {
        "PROPFIND" => methods::propfind::handle(ctx).await,
        "REPORT" => methods::report::handle(ctx).await,
        "PUT" => methods::put::handle(ctx).await,
        "GET" => methods::get::handle(ctx).await,
        "DELETE" => methods::delete::handle(ctx).await,
        "MKCALENDAR" => methods::mkcalendar::handle(ctx).await,
        "OPTIONS" => Ok("Allow: OPTIONS, GET, PUT, DELETE, PROPFIND, REPORT, MKCALENDAR".to_string()),
        _ => Ok(format!("Method {} not implemented yet", ctx.method)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    use crate::backend::{DavBackend, Resource};
    use async_trait::async_trait;

    struct MockBackend;
    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
             if path == "/calendars/user/home" {
                 Ok(Some(Resource {
                     path: path.to_string(),
                     kind: crate::backend::ResourceKind::Calendar, 
                     mime_type: "text/calendar".into(),
                     etag: "root".into(),
                     content: None,
                     properties: std::collections::HashMap::from([
                         ("D:displayname".to_string(), "Native Calendar".to_string())
                     ]),
                 }))
             } else {
                 Ok(None)
             }
        }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: crate::backend::ResourceKind) -> anyhow::Result<()> { Ok(()) }
    }

    #[tokio::test]
    async fn test_propfind_basic() {
        let body = r#"
            <D:propfind xmlns:D="DAV:">
                <D:prop>
                    <D:displayname/>
                    <D:resourcetype/>
                </D:prop>
            </D:propfind>
        "#;

        let backend = std::sync::Arc::new(MockBackend);
        let ctx = DavContext::new(
            "PROPFIND".to_string(), 
            "/calendars/user/home".to_string(), 
            body.as_bytes().to_vec(),
            std::collections::HashMap::new(),
            backend
        );

        let result = process(ctx).await.expect("Process failed");
        
        println!("Result: {}", result);

        assert!(result.contains("<D:href>/calendars/user/home</D:href>"));
        assert!(result.contains("<D:displayname>Native Calendar</D:displayname>"));
        assert!(result.contains("<D:collection/>"));
        assert!(result.contains("<C:calendar"));
    }
}
