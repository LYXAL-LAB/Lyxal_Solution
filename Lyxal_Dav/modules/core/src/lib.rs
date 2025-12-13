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

use http::StatusCode;
use std::collections::HashMap;

/// Main entry point for processing a DAV request
/// This struct simulates the "Context" of a DAV transaction
pub struct DavContext {
    pub method: String,
    pub path: String,
    pub body: Vec<u8>,
    pub headers: HashMap<String, String>,
    pub backend: std::sync::Arc<dyn crate::backend::DavBackend>,
    // In the future: User/Auth info
}

impl DavContext {
    pub fn new(method: String, path: String, body: Vec<u8>, headers: HashMap<String, String>, backend: std::sync::Arc<dyn crate::backend::DavBackend>) -> Self {
        Self { method, path, body, headers, backend }
    }

    pub fn header(&self, name: &str) -> Option<&String> {
        let lower = name.to_ascii_lowercase();
        self.headers
            .iter()
            .find(|(k, _)| k.to_ascii_lowercase() == lower)
            .map(|(_, v)| v)
    }
}

use crate::error::DavError;

/// Canonical DAV response returned by handlers
pub struct DavResponse {
    pub status: StatusCode,
    pub headers: HashMap<String, String>,
    pub body: Vec<u8>,
}

impl DavResponse {
    pub fn empty(status: StatusCode) -> Self {
        Self { status, headers: HashMap::new(), body: Vec::new() }
    }

    pub fn xml(status: StatusCode, xml: String) -> Self {
        let mut headers = HashMap::new();
        headers.insert("Content-Type".to_string(), "application/xml; charset=utf-8".to_string());
        Self { status, headers, body: xml.into_bytes() }
    }

    pub fn ics(status: StatusCode, ics: String, etag: Option<String>) -> Self {
        let mut headers = HashMap::new();
        headers.insert("Content-Type".to_string(), "text/calendar; charset=utf-8".to_string());
        if let Some(tag) = etag {
            headers.insert("ETag".to_string(), format!("\"{}\"", tag));
        }
        Self { status, headers, body: ics.into_bytes() }
    }
}

/// Process a DAV request and return a DAV response
pub async fn process(ctx: DavContext) -> Result<DavResponse, DavError> {
    match ctx.method.as_str() {
        "PROPFIND" => methods::propfind::handle(ctx).await,
        "REPORT" => methods::report::handle(ctx).await,
        "PUT" => methods::put::handle(ctx).await,
        "GET" => methods::get::handle(ctx).await,
        "DELETE" => methods::delete::handle(ctx).await,
        "MKCALENDAR" => methods::mkcalendar::handle(ctx).await,
        "OPTIONS" => {
            let mut resp = DavResponse::empty(StatusCode::OK);
            resp.headers.insert("Allow".into(), "OPTIONS, GET, PUT, DELETE, PROPFIND, REPORT, MKCALENDAR".into());
            resp.headers.insert("DAV".into(), "1, 2, calendar-access".into());
            Ok(resp)
        },
        _ => Err(DavError::MethodNotAllowed),
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
                     sync_token: None,
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
        let body = String::from_utf8(result.body).unwrap();
        println!("Result: {}", body);

        assert!(body.contains("<D:href>/calendars/user/home</D:href>"));
        assert!(body.contains("<D:displayname>Native Calendar</D:displayname>"));
        assert!(body.contains("<D:collection/>"));
        assert!(body.contains("<C:calendar"));
    }
}
