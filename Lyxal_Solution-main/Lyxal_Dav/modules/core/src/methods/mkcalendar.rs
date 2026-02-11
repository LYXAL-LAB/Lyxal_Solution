use crate::{DavContext, DavResponse};
use crate::error::DavError;
use crate::backend::ResourceKind;
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    // 1. Check if resource already exists
    if let Ok(Some(_)) = ctx.backend.get_resource(&ctx.path).await {
        return Err(DavError::Forbidden); // RFC 4791 says if resource exists, fail.
    }

    // 2. Parse body for properties (TODO: Implement property parsing)
    // For MVP, we ignore body and create with default properties.

    ctx.backend.create_collection(&ctx.path, ResourceKind::Calendar)
        .await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

    ctx.backend.ensure_calendar_owner(&ctx.path, principal)
        .await
        .map_err(|e| DavError::Internal(format!("Ownership error: {}", e)))?;

    Ok(DavResponse::empty(StatusCode::CREATED))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource};
    use async_trait::async_trait;
    use std::sync::{Arc, Mutex};

    struct MockBackend {
        resources: Arc<Mutex<Vec<String>>>,
    }

    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
            let resources = self.resources.lock().unwrap();
            if resources.contains(&path.to_string()) {
                Ok(Some(Resource {
                    path: path.to_string(),
                    kind: ResourceKind::Calendar,
                    mime_type: "text/calendar".into(),
                    etag: "123".into(),
                    content: None,
                    properties: std::collections::HashMap::new(),
                    sync_token: None,
                }))
            } else {
                Ok(None)
            }
        }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, path: &str, kind: ResourceKind) -> anyhow::Result<()> {
            assert_eq!(kind, ResourceKind::Calendar);
            self.resources.lock().unwrap().push(path.to_string());
            Ok(())
        }
    }

    #[tokio::test]
    async fn test_mkcalendar_basic() {
        let backend = Arc::new(MockBackend { resources: Arc::new(Mutex::new(vec![])) });
        let ctx = DavContext::new("MKCALENDAR".into(), "/calendars/new".into(), vec![], std::collections::HashMap::new(), backend.clone(), Some("user".into()));

        let result = handle(ctx).await.unwrap();
        assert_eq!(result.status, StatusCode::CREATED);

        let resources = backend.resources.lock().unwrap();
        assert!(resources.contains(&"/calendars/new".to_string()));
    }

    #[tokio::test]
    async fn test_mkcalendar_existing() {
        let backend = Arc::new(MockBackend { resources: Arc::new(Mutex::new(vec!["/calendars/existing".into()])) });
        let ctx = DavContext::new("MKCALENDAR".into(), "/calendars/existing".into(), vec![], std::collections::HashMap::new(), backend, Some("user".into()));

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Forbidden)));
    }
}
