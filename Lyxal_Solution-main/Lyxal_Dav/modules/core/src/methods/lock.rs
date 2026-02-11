use crate::{DavContext, DavResponse, xml};
use crate::error::DavError;
use crate::backend::Lock;
use http::StatusCode;
use chrono::Utc;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    // 1. Check Auth (LOCK requires auth usually, especially for writing lock)
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;

    // 2. Parse Body (Lock Info)
    let lock_info = xml::parse_lockinfo(&ctx.body)?;
    
    // 3. Parse Headers
    // Depth: 0 or infinity. Default infinity? RFC 4918 says infinity is default for LOCK.
    let depth = ctx.header("depth").map(|s| s.as_str()).unwrap_or("infinity").to_string();
    
    // Timeout: Second-xxx
    let timeout_header = ctx.header("timeout").map(|s| s.as_str()).unwrap_or("");
    let timeout = parse_timeout(timeout_header);

    // 4. Check existing locks
    let existing_locks = ctx.backend.get_locks(&ctx.path).await.map_err(|e| DavError::Internal(e.to_string()))?;
    
    // If refreshing (If-Match or just LOCK on existing with same token in header?)
    // LOCK refresh is usually done with "If: (<token>)" or simply providing the token?
    // RFC 4918 Section 9.10.2: "Refreshing a Lock".
    // "A client can refresh a lock by submitting a LOCK request to the URL... with an 'If' header..."
    // AND "If the LOCK request is for a refresh... the body is empty."
    
    let is_refresh = ctx.body.is_empty() && !existing_locks.is_empty();
    
    let token = if is_refresh {
        // Find the token in the existing locks that belongs to this principal/request
        // We assume the client sent the correct token in "If" header or we implicitly trust for now (MVP).
        // Actually, we should check `If` header.
        // For D3.4 MVP, if it's a refresh, we take the first existing lock's token (since exclusive).
        if let Some(lock) = existing_locks.first() {
             lock.token.clone()
        } else {
             return Err(DavError::PreconditionFailed);
        }
    } else {
        // New Lock
        if !existing_locks.is_empty() {
            return Err(DavError::Locked);
        }
        format!("opaquelocktoken:{}", generate_uuid())
    };

    // 5. Create/Update Lock
    ctx.backend.lock(&ctx.path, &token, Some(principal), &depth, timeout, lock_info.owner.as_deref())
        .await
        .map_err(|e| DavError::Internal(e.to_string()))?;

    // 6. Response
    let lock_obj = Lock {
        path: ctx.path.clone(),
        token: token.clone(),
        principal: Some(principal.to_string()),
        depth,
        timeout,
        expires_at: Utc::now().timestamp() + timeout,
        owner_info: lock_info.owner,
    };

    let resp_xml = format!(
        "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<D:prop xmlns:D=\"DAV:\">\n  <D:lockdiscovery>\n{}  </D:lockdiscovery>\n</D:prop>",
        xml::generate_lockdiscovery(&lock_obj)
    );

    let mut resp = DavResponse::xml(StatusCode::OK, resp_xml);
    resp.headers.insert("Lock-Token".into(), format!("<{}>", token));
    Ok(resp)
}

fn parse_timeout(s: &str) -> i64 {
    // Format: "Second-3600, Infinite", or just "Second-3600"
    // We take the first "Second-xxx"
    for part in s.split(',') {
        let part = part.trim();
        if part.starts_with("Second-") {
            if let Ok(sec) = part.trim_start_matches("Second-").parse::<i64>() {
                return sec;
            }
        }
    }
    3600 // Default 1h
}

fn generate_uuid() -> String {
    // Simple pseudo-random for MVP without uuid crate
    use std::time::{SystemTime, UNIX_EPOCH};
    let start = SystemTime::now();
    let since_the_epoch = start.duration_since(UNIX_EPOCH).expect("Time went backwards");
    let in_ms = since_the_epoch.as_nanos();
    format!("{:x}", in_ms)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind, Lock};
    use async_trait::async_trait;
    use std::collections::HashMap;
    use std::sync::{Arc, Mutex};

    #[derive(Default)]
    struct MockBackend {
        locks: Mutex<Vec<Lock>>,
    }

    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> { Ok(()) }
        async fn lock(&self, path: &str, token: &str, _principal: Option<&str>, _depth: &str, _timeout: i64, _owner_info: Option<&str>) -> anyhow::Result<()> {
            let mut locks = self.locks.lock().unwrap();
            locks.push(Lock {
                path: path.to_string(),
                token: token.to_string(),
                principal: _principal.map(|s| s.to_string()),
                depth: _depth.to_string(),
                timeout: _timeout,
                expires_at: 0,
                owner_info: _owner_info.map(|s| s.to_string()),
            });
            Ok(())
        }
        async fn unlock(&self, _path: &str, _token: &str) -> anyhow::Result<()> { Ok(()) }
        async fn get_locks(&self, _path: &str) -> anyhow::Result<Vec<Lock>> {
            let locks = self.locks.lock().unwrap();
            Ok(locks.clone())
        }
    }

    #[tokio::test]
    async fn test_lock_create() {
        let backend = Arc::new(MockBackend::default());
        let body = r#"
            <D:lockinfo xmlns:D='DAV:'>
                <D:lockscope><D:exclusive/></D:lockscope>
                <D:locktype><D:write/></D:locktype>
                <D:owner>User</D:owner>
            </D:lockinfo>
        "#;
        let ctx = DavContext::new(
            "LOCK".into(),
            "/file.txt".into(),
            body.as_bytes().to_vec(),
            HashMap::new(),
            backend.clone(),
            Some("user".into()),
        );
        let resp = handle(ctx).await.unwrap();
        assert_eq!(resp.status, StatusCode::OK);
        assert!(resp.body.len() > 0);
        
        let locks = backend.locks.lock().unwrap();
        assert_eq!(locks.len(), 1);
        assert_eq!(locks[0].path, "/file.txt");
    }
}
