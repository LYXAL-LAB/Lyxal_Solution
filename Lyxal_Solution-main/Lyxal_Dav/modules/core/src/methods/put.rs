//! PUT method handler for CalDAV
//!
//! Handles creating and updating resources (calendar objects)

use crate::{DavContext, DavResponse};
use crate::error::DavError;
use crate::methods::check_locked;
use lyxal_ical_core::{parse as ical_parse, validate as ical_validate};
use http::StatusCode;

fn split_etags(value: &str) -> Vec<String> {
    value
        .split(',')
        .map(|v| v.trim().trim_matches('"').to_string())
        .collect()
}

/// Handle PUT request - create or update a resource
pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    if !ctx.backend.check_access(principal, &ctx.path, true).await.unwrap_or(false) {
        return Err(DavError::Forbidden);
    }

    // Check Lock
    check_locked(&ctx, &ctx.path).await?;

    // Fetch existing for preconditions/status
    let existing = ctx
        .backend
        .get_resource(&ctx.path)
        .await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;
    let current_etag = existing.as_ref().map(|r| r.etag.clone());

    // Preconditions
    if let Some(if_match) = ctx.header("if-match") {
        if existing.is_none() {
            return Err(DavError::PreconditionFailed);
        }
        let tags = split_etags(if_match);
        if let Some(etag) = &current_etag {
            if !tags.iter().any(|t| t == "*" || t == etag) {
                return Err(DavError::PreconditionFailed);
            }
        } else {
            return Err(DavError::PreconditionFailed);
        }
    }

    if let Some(if_none_match) = ctx.header("if-none-match") {
        let tags = split_etags(if_none_match);
        if existing.is_some() && tags.iter().any(|t| t == "*") {
            return Err(DavError::PreconditionFailed);
        }
        if let Some(etag) = &current_etag {
            if tags.iter().any(|t| t == etag) {
                return Err(DavError::PreconditionFailed);
            }
        }
    }

    // 1. Parse + Validate ICS content
    let ical_text = String::from_utf8(ctx.body.clone())
        .map_err(|e| DavError::BadRequest(format!("Invalid UTF-8: {}", e)))?;
    
    let parsed = ical_parse(&ical_text)
        .map_err(|e| DavError::BadRequest(format!("ICS parse error: {}", e)))?;
    ical_validate(&parsed)
        .map_err(|e| DavError::BadRequest(format!("ICS validation error: {}", e)))?;

    // 2. Determine MIME type
    let mime = "text/calendar; charset=utf-8";
    
    // 3. Store the resource via backend
    let etag = ctx.backend.put_resource(&ctx.path, ctx.body.as_slice(), mime).await
        .map_err(|e| DavError::Internal(format!("Storage error: {}", e)))?;

    let status = if existing.is_some() {
        StatusCode::NO_CONTENT
    } else {
        StatusCode::CREATED
    };

    let mut resp = DavResponse::empty(status);
    resp.headers.insert("ETag".into(), format!("\"{}\"", etag));
    resp.headers.insert("Content-Type".into(), "text/plain; charset=utf-8".into());
    resp.body = Vec::new();
    Ok(resp)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, Lock};
    use async_trait::async_trait;
    use std::sync::{Arc, Mutex};

    struct MockBackend {
        allow_write: bool,
        locks: Mutex<Vec<Lock>>,
    }
    
    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { 
            Ok("etag-123".into()) 
        }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: crate::backend::ResourceKind) -> anyhow::Result<()> { Ok(()) }
        async fn check_access(&self, principal: &str, _path: &str, write: bool) -> anyhow::Result<bool> {
            if principal == "proxy-read" && write {
                return Ok(false);
            }
            Ok(if write { self.allow_write } else { true })
        }
        async fn get_locks(&self, path: &str) -> anyhow::Result<Vec<Lock>> {
            let locks = self.locks.lock().unwrap();
            Ok(locks.iter().filter(|l| l.path == path).cloned().collect())
        }
    }

    #[tokio::test]
    async fn test_put_basic() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//
BEGIN:VEVENT
UID:test-put-123
SUMMARY:Test Event
DTSTART:20250101T100000Z
END:VEVENT
END:VCALENDAR"#;

        let backend = Arc::new(MockBackend { allow_write: true, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );

        let result = handle(ctx).await.expect("PUT failed");
        assert_eq!(result.status, StatusCode::CREATED);
        assert!(result.headers.get("ETag").is_some());
    }

    #[tokio::test]
    async fn test_put_forbidden_when_no_write_access() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//
BEGIN:VEVENT
UID:test-put-123
SUMMARY:Test Event
DTSTART:20250101T100000Z
END:VEVENT
END:VCALENDAR"#;

        let backend = Arc::new(MockBackend { allow_write: false, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Forbidden)));
    }

    #[tokio::test]
    async fn test_put_forbidden_for_proxy_read() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//
BEGIN:VEVENT
UID:test-put-123
SUMMARY:Test Event
DTSTART:20250101T100000Z
END:VEVENT
END:VCALENDAR"#;

        let backend = Arc::new(MockBackend { allow_write: true, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            std::collections::HashMap::new(),
            backend,
            Some("proxy-read".into())
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Forbidden)));
    }

    #[tokio::test]
    async fn test_put_locked_error() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//
BEGIN:VEVENT
UID:1
DTSTART:20250101T120000Z
END:VEVENT
END:VCALENDAR"#;
        let backend = Arc::new(MockBackend { 
            allow_write: true, 
            locks: Mutex::new(vec![Lock {
                path: "/calendars/user/home/test.ics".into(),
                token: "opaquelocktoken:abc".into(),
                principal: Some("other".into()),
                depth: "0".into(),
                timeout: 3600,
                expires_at: chrono::Utc::now().timestamp() + 3600,
                owner_info: None,
            }])
        });
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );
        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Locked)));
    }

    #[tokio::test]
    async fn test_put_locked_with_token_ok() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Test//
BEGIN:VEVENT
UID:1
DTSTART:20250101T120000Z
END:VEVENT
END:VCALENDAR"#;
        let backend = Arc::new(MockBackend { 
            allow_write: true, 
            locks: Mutex::new(vec![Lock {
                path: "/calendars/user/home/test.ics".into(),
                token: "opaquelocktoken:abc".into(),
                principal: Some("user".into()),
                depth: "0".into(),
                timeout: 3600,
                expires_at: chrono::Utc::now().timestamp() + 3600,
                owner_info: None,
            }])
        });
        let mut headers = std::collections::HashMap::new();
        headers.insert("If".into(), "(<opaquelocktoken:abc>)".into());
        let ctx = DavContext::new(
            "PUT".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            ical.as_bytes().to_vec(),
            headers,
            backend,
            Some("user".into())
        );
        let result = handle(ctx).await;
        if let Err(e) = &result {
            println!("PUT error: {:?}", e);
        }
        assert!(result.is_ok());
    }
}
