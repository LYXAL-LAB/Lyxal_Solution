//! DELETE method handler for CalDAV
//!
//! Handles deleting resources (calendar objects)

use crate::DavContext;
use crate::error::DavError;

/// Handle DELETE request - remove a resource
pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    // 1. Check if resource exists (optional, but good for returning correct status)
    let exists = ctx.backend.get_resource(&ctx.path).await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?
        .is_some();

    if !exists {
        return Err(DavError::NotFound);
    }

    // 2. Delete the resource
    ctx.backend.delete_resource(&ctx.path).await
        .map_err(|e| DavError::Internal(format!("Delete error: {}", e)))?;

    // 3. Return success (204 No Content equivalent)
    Ok(format!("Deleted: {}", ctx.path))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind, CalendarQuery};
    use async_trait::async_trait;
    use std::sync::Arc;
    use std::collections::HashMap;

    struct MockBackend {
        has_resource: bool,
    }
    
    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> {
            if self.has_resource {
                Ok(Some(Resource {
                    path: "/test.ics".to_string(),
                    kind: ResourceKind::Object,
                    mime_type: "text/calendar".into(),
                    etag: "etag-123".into(),
                    content: None,
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
    async fn test_delete_existing() {
        let backend = Arc::new(MockBackend { has_resource: true });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            vec![],
            backend
        );

        let result = handle(ctx).await.expect("DELETE failed");
        assert!(result.contains("Deleted"));
    }

    #[tokio::test]
    async fn test_delete_not_found() {
        let backend = Arc::new(MockBackend { has_resource: false });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/missing.ics".to_string(),
            vec![],
            backend
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::NotFound)));
    }
}
