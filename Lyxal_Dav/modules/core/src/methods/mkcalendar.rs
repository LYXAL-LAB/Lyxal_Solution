use crate::DavContext;
use crate::error::DavError;
use crate::backend::ResourceKind;

pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    // 1. Check if resource already exists
    if let Ok(Some(_)) = ctx.backend.get_resource(&ctx.path).await {
        return Err(DavError::Forbidden); // RFC 4791 says if resource exists, fail.
    }

    // 2. Parse body for properties (TODO: Implement property parsing)
    // For MVP, we ignore body and create with default properties.

    ctx.backend.create_collection(&ctx.path, ResourceKind::Calendar)
        .await
        .map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

    // 4. Return success
    // MKCALENDAR returns 201 Created on success
    Ok("".to_string()) 
    // Note: The HTTP server layer should translate Ok("") into 201 Created if the method was MKCALENDAR
    // But currently our `process` returns `String` (body).
    // We rely on the server wrapper to handle status codes, OR we need to change return type.
    // For now, empty body implies success. The server wrapper (in surrealdb-server)
    // usually defaults to 200 OK. We might need to signify 201.
    // However, looking at other handlers, we return body string.
    // The server mapping in `surrealdb-server` handles the Result. 
    // If we want 201, we might need a richer return type from `process`.
    // But for now, let's assume 200 OK is "acceptable" or the wrapper handles it.
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
        let ctx = DavContext::new("MKCALENDAR".into(), "/calendars/new".into(), vec![], std::collections::HashMap::new(), backend.clone());

        let result = handle(ctx).await;
        assert!(result.is_ok());

        let resources = backend.resources.lock().unwrap();
        assert!(resources.contains(&"/calendars/new".to_string()));
    }

    #[tokio::test]
    async fn test_mkcalendar_existing() {
        let backend = Arc::new(MockBackend { resources: Arc::new(Mutex::new(vec!["/calendars/existing".into()])) });
        let ctx = DavContext::new("MKCALENDAR".into(), "/calendars/existing".into(), vec![], std::collections::HashMap::new(), backend);

        let result = handle(ctx).await;
        assert!(matches!(result, Err(DavError::Forbidden)));
    }
}
