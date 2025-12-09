//! GET method handler for CalDAV
//!
//! Handles retrieving resources (calendar objects as .ics)

use crate::DavContext;
use crate::error::DavError;
use crate::ical;

/// Handle GET request - retrieve a resource as ICS
pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    // 1. Fetch the resource from backend
    let resource = ctx.backend.get_resource(&ctx.path).await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

    match resource {
        Some(res) => {
            // 2. If content is available, return it
            if let Some(content) = res.content {
                let ical_str = String::from_utf8(content)
                    .map_err(|e| DavError::Internal(format!("Invalid UTF-8: {}", e)))?;
                Ok(ical_str)
            } else {
                // 3. If no content but properties exist, stringify them
                // This would be the case for a database-backed store
                // where we reconstruct ICS from stored properties
                let properties_json = serde_json::to_value(&res.properties)
                    .map_err(|e| DavError::Internal(format!("JSON error: {}", e)))?;
                
                let ical_str = ical::stringify(&properties_json)
                    .map_err(|e| DavError::Internal(format!("Stringify error: {}", e)))?;
                
                Ok(ical_str)
            }
        }
        None => Err(DavError::NotFound),
    }
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
    }

    #[tokio::test]
    async fn test_get_existing() {
        let backend = Arc::new(MockBackend);
        let ctx = DavContext::new(
            "GET".to_string(),
            "/calendars/user/home/exists.ics".to_string(),
            vec![],
            backend
        );

        let result = handle(ctx).await.expect("GET failed");
        assert!(result.contains("BEGIN:VCALENDAR"));
    }

    #[tokio::test]
    async fn test_get_not_found() {
        let backend = Arc::new(MockBackend);
        let ctx = DavContext::new(
            "GET".to_string(),
            "/calendars/user/home/missing.ics".to_string(),
            vec![],
            backend
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::NotFound)));
    }
}
