//! GET method handler for CalDAV
//!
//! Handles retrieving resources (calendar objects as .ics)

use crate::{DavContext, DavResponse};
use crate::error::DavError;
use crate::ical;
use http::StatusCode;

fn split_etags(value: &str) -> Vec<String> {
    value
        .split(',')
        .map(|v| v.trim().trim_matches('"').to_string())
        .collect()
}

/// Handle GET request - retrieve a resource as ICS
pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let resource = ctx
        .backend
        .get_resource(&ctx.path)
        .await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

    let Some(res) = resource else {
        return Err(DavError::NotFound);
    };

    let current_etag = res.etag.clone();

    // Preconditions: If-Match / If-None-Match
    if let Some(if_match) = ctx.header("if-match") {
        let tags = split_etags(if_match);
        if !tags.iter().any(|t| t == "*" || t == &current_etag) {
            return Err(DavError::PreconditionFailed);
        }
    }

    if let Some(if_none_match) = ctx.header("if-none-match") {
        let tags = split_etags(if_none_match);
        if tags.iter().any(|t| t == "*" || t == &current_etag) {
            let mut resp = DavResponse::empty(StatusCode::NOT_MODIFIED);
            resp.headers.insert("ETag".into(), format!("\"{}\"", current_etag));
            return Ok(resp);
        }
    }

    let ical_str = if let Some(content) = res.content {
        String::from_utf8(content).map_err(|e| DavError::Internal(format!("Invalid UTF-8: {}", e)))?
    } else {
        let properties_json = serde_json::to_value(&res.properties)
            .map_err(|e| DavError::Internal(format!("JSON error: {}", e)))?;
        ical::stringify(&properties_json)
            .map_err(|e| DavError::Internal(format!("Stringify error: {}", e)))?
    };

    let mut resp = DavResponse::ics(StatusCode::OK, ical_str, Some(current_etag));
    if !res.mime_type.is_empty() {
        resp.headers
            .insert("Content-Type".into(), res.mime_type.clone());
    }
    Ok(resp)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind, CalendarQuery};
    use async_trait::async_trait;
    use std::sync::Arc;
    use std::collections::HashMap;

    struct MockBackend;
    
    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
            if path.contains("exists") {
                Ok(Some(Resource {
                    path: path.to_string(),
                    kind: ResourceKind::Object,
                    mime_type: "text/calendar".into(),
                    etag: "etag-123".into(),
                    content: Some(b"BEGIN:VCALENDAR\nVERSION:2.0\nEND:VCALENDAR".to_vec()),
                    properties: HashMap::new(),
                    sync_token: None,
                }))
            } else {
                Ok(None)
            }
        }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { 
            Ok("etag-123".into()) 
        }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: crate::backend::ResourceKind) -> anyhow::Result<()> { Ok(()) }
    }

    #[tokio::test]
    async fn test_get_existing() {
        let backend = Arc::new(MockBackend);
        let ctx = DavContext::new(
            "GET".to_string(),
            "/calendars/user/home/exists.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend
        );

        let result = handle(ctx).await.expect("GET failed");
        let body = String::from_utf8(result.body).unwrap();
        assert!(body.contains("BEGIN:VCALENDAR"));
    }

    #[tokio::test]
    async fn test_get_not_found() {
        let backend = Arc::new(MockBackend);
        let ctx = DavContext::new(
            "GET".to_string(),
            "/calendars/user/home/missing.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::NotFound)));
    }
}
