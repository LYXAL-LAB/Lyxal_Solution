//! PUT method handler for CalDAV
//!
//! Handles creating and updating resources (calendar objects)

use crate::DavContext;
use crate::error::DavError;
use crate::ical;

/// Handle PUT request - create or update a resource
pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    // 1. Parse the ICS content
    let ical_text = String::from_utf8(ctx.body.clone())
        .map_err(|e| DavError::Internal(format!("Invalid UTF-8: {}", e)))?;
    
    let parsed = ical::parse(&ical_text)
        .map_err(|e| DavError::Internal(format!("ICS parse error: {}", e)))?;

    // 2. Determine MIME type
    let mime = "text/calendar; charset=utf-8";
    
    // 3. Store the resource via backend
    let etag = ctx.backend.put_resource(&ctx.path, ctx.body.as_slice(), mime).await
        .map_err(|e| DavError::Internal(format!("Storage error: {}", e)))?;

    // 4. Return success response with ETag
    // CalDAV PUT returns 201 Created or 204 No Content
    // The ETag is typically returned in the response header, not body
    // For our text-based response, we return the ETag
    
    Ok(format!("Created: {} (ETag: {})", ctx.path, etag))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, CalendarQuery};
    use async_trait::async_trait;
    use std::sync::Arc;

    struct MockBackend;
    
    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { 
            Ok("etag-123".into()) 
        }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
    }

    #[tokio::test]
    async fn test_put_basic() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:test-put-123
SUMMARY:Test Event
DTSTART:20250101T100000Z
END:VEVENT
END:VCALENDAR"#;

        let backend = Arc::new(MockBackend);
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            backend
        );

        let result = handle(ctx).await.expect("PUT failed");
        assert!(result.contains("Created"));
        assert!(result.contains("etag-123"));
    }
}
