pub mod propfind;
pub mod report;
pub mod put;
pub mod get;
pub mod delete;
pub mod mkcalendar;
pub mod proppatch;
pub mod mkcol;
pub mod r#move;
pub mod copy;
pub mod lock;
pub mod unlock;

pub async fn check_locked(ctx: &crate::DavContext, path: &str) -> Result<(), crate::error::DavError> {
    let locks = ctx.backend.get_locks(path).await.map_err(|e| crate::error::DavError::Internal(e.to_string()))?;
    if locks.is_empty() {
        return Ok(());
    }
    
    // Check If header
    // Header format: (<urn:uuid:xxxx>)
    let if_header = ctx.header("If").cloned().unwrap_or_default();
    
    for lock in locks {
        if lock.expires_at < chrono::Utc::now().timestamp() {
            continue;
        }
        // If locked, we MUST have the token in If header
        // Simple check: does If header contain the token?
        if !if_header.contains(&lock.token) {
             return Err(crate::error::DavError::Locked);
        }
    }
    Ok(())
}
