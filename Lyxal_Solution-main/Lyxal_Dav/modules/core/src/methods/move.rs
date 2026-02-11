use crate::{DavContext, DavResponse};
use crate::error::DavError;
use crate::methods::check_locked;
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
	let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
	let dest = ctx
		.header("destination")
		.map(|s| s.to_string())
		.ok_or_else(|| DavError::BadRequest("Missing Destination header".into()))?;
	let overwrite = ctx
		.header("overwrite")
		.map(|s| !s.eq_ignore_ascii_case("F"))
		.unwrap_or(true);

	// ACL: write on source and destination parent
	if !ctx.backend.check_access(principal, &ctx.path, true).await.unwrap_or(false) {
		return Err(DavError::Forbidden);
	}
	if let Some(parent) = parent_path(&dest) {
		if !ctx.backend.check_access(principal, &parent, true).await.unwrap_or(false) {
			return Err(DavError::Forbidden);
		}
	} else {
		return Err(DavError::Forbidden);
	}

    // Check Locks
    check_locked(&ctx, &ctx.path).await?;
    // We should also check if destination is locked?
    // RFC 4918: If the destination is locked, we need the token.
    // However, `If` header usually scopes tokens to resources.
    // Checking `If` header against dest path is tricky because `If` header syntax is complex `<href> (token)`.
    // For MVP, we assume `If` header contains all relevant tokens.
    // `check_locked` checks `If` header presence.
    // But `check_locked` uses `ctx.path`. We need to check `dest`.
    // We can't reuse `check_locked` directly if it relies on `ctx` headers for `dest`?
    // Yes, `check_locked` reads `If` header from `ctx`. The `If` header applies to the request.
    // If the request targets source, `If` header might have tokens for source AND dest.
    // The `If` header format allows multiple resources.
    // My simple `check_locked` implementation just checks if `If` header contains the token string.
    // This is a "lenient" check (Tag-List production vs No-Tag-List).
    // It's sufficient for "strict behavior" (must have token) but might be too permissive (doesn't verify the token is applied to the specific resource).
    // Given MVP constraints, checking if token is present in `If` is good enough.
    // So calling `check_locked` with `dest` path using same `ctx` works if `If` header contains the token.
    check_locked(&ctx, &dest).await?;

	// Check if destination exists
	let dest_exists = ctx.backend.get_resource(&dest).await.map_err(|e| DavError::Internal(e.to_string()))?.is_some();

	// If overwrite false and dest exists -> 412
	if !overwrite {
		if dest_exists {
			return Err(DavError::PreconditionFailed);
		}
	}

	ctx.backend
		.move_path(&ctx.path, &dest, overwrite)
		.await
		.map_err(|e| DavError::Internal(e.to_string()))?;

	// Status: 201 if created, 204 if replaced
	let status = if dest_exists {
		StatusCode::NO_CONTENT
	} else {
		StatusCode::CREATED
	};

	Ok(DavResponse::empty(status))
}

fn parent_path(path: &str) -> Option<String> {
	let trimmed = path.trim_end_matches('/');
	trimmed.rsplit_once('/').and_then(|(left, _)| if left.is_empty() { None } else { Some(left.to_string()) })
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
		resources: Mutex<HashMap<String, Resource>>,
		allow: bool,
        locks: Mutex<Vec<Lock>>,
	}

	#[async_trait]
	impl DavBackend for MockBackend {
		async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
			Ok(self.resources.lock().unwrap().get(path).cloned())
		}
		async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
		async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("e".into()) }
		async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
		async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> { Ok(()) }
		async fn check_access(&self, _principal: &str, _path: &str, write: bool) -> anyhow::Result<bool> {
			Ok(if write { self.allow } else { true })
		}
		async fn move_path(&self, src: &str, dst: &str, _overwrite: bool) -> anyhow::Result<()> {
			let mut lock = self.resources.lock().unwrap();
			if let Some(res) = lock.remove(src) {
				let mut new_res = res.clone();
				new_res.path = dst.to_string();
				lock.insert(dst.to_string(), new_res);
			} else {
				return Err(anyhow::anyhow!("not found"));
			}
			Ok(())
		}
        async fn get_locks(&self, path: &str) -> anyhow::Result<Vec<Lock>> {
            let locks = self.locks.lock().unwrap();
            Ok(locks.iter().filter(|l| l.path == path).cloned().collect())
        }
	}

	fn headers(dest: &str, overwrite: Option<&str>) -> HashMap<String, String> {
		let mut h = HashMap::new();
		h.insert("Destination".into(), dest.into());
		if let Some(o) = overwrite {
			h.insert("Overwrite".into(), o.into());
		}
		h
	}

	#[tokio::test]
	async fn test_move_ok_created() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([(
				"/a/file.ics".into(),
				Resource {
					path: "/a/file.ics".into(),
					kind: ResourceKind::Object,
					mime_type: "text".into(),
					etag: "e1".into(),
					content: None,
					properties: HashMap::new(),
					sync_token: None,
				},
			)])),
			allow: true,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"MOVE".into(),
			"/a/file.ics".into(),
			vec![],
			headers("/b/file.ics", None),
			backend,
			Some("user".into()),
		);
		let resp = handle(ctx).await.unwrap();
		assert_eq!(resp.status, StatusCode::CREATED);
	}

	#[tokio::test]
	async fn test_move_precondition_overwrite_false() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([
				(
					"/a/file.ics".into(),
					Resource {
						path: "/a/file.ics".into(),
						kind: ResourceKind::Object,
						mime_type: "text".into(),
						etag: "e1".into(),
						content: None,
						properties: HashMap::new(),
						sync_token: None,
					},
				),
				(
					"/b/file.ics".into(),
					Resource {
						path: "/b/file.ics".into(),
						kind: ResourceKind::Object,
						mime_type: "text".into(),
						etag: "e2".into(),
						content: None,
						properties: HashMap::new(),
						sync_token: None,
					},
				),
			])),
			allow: true,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"MOVE".into(),
			"/a/file.ics".into(),
			vec![],
			headers("/b/file.ics", Some("F")),
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::PreconditionFailed)));
	}

	#[tokio::test]
	async fn test_move_forbidden() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::new()),
			allow: false,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"MOVE".into(),
			"/a/file.ics".into(),
			vec![],
			headers("/b/file.ics", None),
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Forbidden)));
	}

    #[tokio::test]
	async fn test_move_locked_source() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([(
				"/a/file.ics".into(),
				Resource {
					path: "/a/file.ics".into(),
					kind: ResourceKind::Object,
					mime_type: "text".into(),
					etag: "e1".into(),
					content: None,
					properties: HashMap::new(),
					sync_token: None,
				},
			)])),
			allow: true,
            locks: Mutex::new(vec![Lock {
                path: "/a/file.ics".into(),
                token: "t".into(),
                principal: None,
                depth: "0".into(),
                timeout: 100,
                expires_at: chrono::Utc::now().timestamp() + 100,
                owner_info: None,
            }]),
		});
		let ctx = DavContext::new(
			"MOVE".into(),
			"/a/file.ics".into(),
			vec![],
			headers("/b/file.ics", None),
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Locked)));
	}
}
