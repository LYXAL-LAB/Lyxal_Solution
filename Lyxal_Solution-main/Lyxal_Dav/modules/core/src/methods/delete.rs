//! DELETE method handler for CalDAV
//!
//! Handles deleting resources (calendar objects)

use crate::{DavContext, DavResponse};
use crate::error::DavError;
use crate::methods::check_locked;
use http::StatusCode;

fn split_etags(value: &str) -> Vec<String> {
    value
        .split(',')
        .map(|v| v.trim().trim_matches('"').to_string())
        .collect()
}

/// Handle DELETE request - remove a resource
pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    if !ctx.backend.check_access(principal, &ctx.path, true).await.unwrap_or(false) {
        return Err(DavError::Forbidden);
    }

    // Check Lock
    check_locked(&ctx, &ctx.path).await?;

    let resource = ctx
        .backend
        .get_resource(&ctx.path)
        .await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

    let Some(res) = resource else {
        return Err(DavError::NotFound);
    };

    let current_etag = res.etag;

    if let Some(if_match) = ctx.header("if-match") {
        let tags = split_etags(if_match);
        if !tags.iter().any(|t| t == "*" || t == &current_etag) {
            return Err(DavError::PreconditionFailed);
        }
    }

    if let Some(if_none_match) = ctx.header("if-none-match") {
        let tags = split_etags(if_none_match);
        if tags.iter().any(|t| t == "*" || t == &current_etag) {
            return Err(DavError::PreconditionFailed);
        }
    }

    ctx.backend
        .delete_resource(&ctx.path)
        .await
        .map_err(|e| DavError::Internal(format!("Delete error: {}", e)))?;

    Ok(DavResponse::empty(StatusCode::NO_CONTENT))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind, Lock};
    use async_trait::async_trait;
    use std::sync::{Arc, Mutex};
    use std::collections::HashMap;

    struct MockBackend {
        has_resource: bool,
        allow_write: bool,
        locks: Mutex<Vec<Lock>>,
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
        async fn check_access(&self, _principal: &str, _path: &str, write: bool) -> anyhow::Result<bool> {
            Ok(if write { self.allow_write } else { true })
        }
        async fn get_locks(&self, path: &str) -> anyhow::Result<Vec<Lock>> {
            let locks = self.locks.lock().unwrap();
            Ok(locks.iter().filter(|l| l.path == path).cloned().collect())
        }
    }

    #[tokio::test]
    async fn test_delete_existing() {
        let backend = Arc::new(MockBackend { has_resource: true, allow_write: true, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );

        let result = handle(ctx).await.expect("DELETE failed");
        assert_eq!(result.status, StatusCode::NO_CONTENT);
    }

    #[tokio::test]
    async fn test_delete_not_found() {
        let backend = Arc::new(MockBackend { has_resource: false, allow_write: true, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/missing.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::NotFound)));
    }

    #[tokio::test]
    async fn test_delete_forbidden_when_no_write_access() {
        let backend = Arc::new(MockBackend { has_resource: true, allow_write: false, locks: Mutex::new(vec![]) });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Forbidden)));
    }

    #[tokio::test]
    async fn test_delete_locked() {
        let backend = Arc::new(MockBackend { 
            has_resource: true, 
            allow_write: true, 
            locks: Mutex::new(vec![Lock {
                path: "/calendars/user/home/test.ics".into(),
                token: "token".into(),
                principal: None,
                depth: "0".into(),
                timeout: 100,
                expires_at: chrono::Utc::now().timestamp() + 100,
                owner_info: None,
            }]) 
        });
        let ctx = DavContext::new(
            "DELETE".to_string(),
            "/calendars/user/home/test.ics".to_string(),
            vec![],
            std::collections::HashMap::new(),
            backend,
            Some("user".into())
        );
        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Locked)));
    }
}
