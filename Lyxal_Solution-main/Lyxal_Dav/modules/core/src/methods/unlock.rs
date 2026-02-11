use crate::{DavContext, DavResponse};
use crate::error::DavError;
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let _principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    let token_header = ctx.header("Lock-Token").ok_or(DavError::BadRequest("Missing Lock-Token header".into()))?;
    let token = token_header.trim_matches(|c| c == '<' || c == '>');
    
    match ctx.backend.unlock(&ctx.path, token).await {
        Ok(_) => Ok(DavResponse::empty(StatusCode::NO_CONTENT)),
        Err(_) => Err(DavError::Conflict),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind};
    use async_trait::async_trait;
    use std::collections::HashMap;
    use std::sync::{Arc, Mutex};

    #[derive(Default)]
    struct MockBackend {
        unlocked: Arc<Mutex<bool>>,
    }

    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> { Ok(()) }
        async fn unlock(&self, _path: &str, _token: &str) -> anyhow::Result<()> {
            *self.unlocked.lock().unwrap() = true;
            Ok(())
        }
    }

    #[tokio::test]
    async fn test_unlock_ok() {
        let backend = Arc::new(MockBackend::default());
        let mut headers = HashMap::new();
        headers.insert("Lock-Token".into(), "<opaquelocktoken:123>".into());
        
        let ctx = DavContext::new(
            "UNLOCK".into(),
            "/file.txt".into(),
            vec![],
            headers,
            backend.clone(),
            Some("user".into()),
        );
        let resp = handle(ctx).await.unwrap();
        assert_eq!(resp.status, StatusCode::NO_CONTENT);
        assert!(*backend.unlocked.lock().unwrap());
    }
}

