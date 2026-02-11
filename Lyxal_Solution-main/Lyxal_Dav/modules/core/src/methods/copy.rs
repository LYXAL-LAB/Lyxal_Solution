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

	// ACL: read source + write dest parent
	if !ctx.backend.check_access(principal, &ctx.path, false).await.unwrap_or(false) {
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
    // Copy doesn't modify source, so no lock check on source needed?
    // RFC 4918 says: "If a source resource is locked... the COPY method is NOT affected."
    // Unless we delete source (MOVE). But COPY is read-only on source.
    // So we ONLY check dest lock.
    check_locked(&ctx, &dest).await?;

	let dest_exists = ctx.backend.get_resource(&dest).await.map_err(|e| DavError::Internal(e.to_string()))?.is_some();

	if !overwrite {
		if dest_exists {
			return Err(DavError::PreconditionFailed);
		}
	}

	ctx.backend
		.copy_path(&ctx.path, &dest, overwrite)
		.await
		.map_err(|e| DavError::Internal(e.to_string()))?;

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
		allow_write: bool,
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
			Ok(if write { self.allow_write } else { true })
		}
		async fn copy_path(&self, src: &str, dst: &str, _overwrite: bool) -> anyhow::Result<()> {
			let mut lock = self.resources.lock().unwrap();
			if let Some(res) = lock.get(src) {
				let mut new_res = res.clone();
				new_res.path = dst.to_string();
				new_res.etag = format!("{}-copy", res.etag);
				lock.insert(dst.to_string(), new_res);
				return Ok(());
			}
			Err(anyhow::anyhow!("not found"))
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

	fn resource(path: &str) -> Resource {
		Resource {
			path: path.into(),
			kind: ResourceKind::Object,
			mime_type: "text".into(),
			etag: "e1".into(),
			content: None,
			properties: HashMap::new(),
			sync_token: None,
		}
	}

	#[tokio::test]
	async fn test_copy_ok_created() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([("/a/file.ics".into(), resource("/a/file.ics"))])),
			allow_write: true,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"COPY".into(),
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
	async fn test_copy_precondition_overwrite_false() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([
				("/a/file.ics".into(), resource("/a/file.ics")),
				("/b/file.ics".into(), resource("/b/file.ics")),
			])),
			allow_write: true,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"COPY".into(),
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
	async fn test_copy_forbidden() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::new()),
			allow_write: false,
            locks: Mutex::new(vec![]),
		});
		let ctx = DavContext::new(
			"COPY".into(),
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
	async fn test_copy_locked_dest() {
		let backend = Arc::new(MockBackend {
			resources: Mutex::new(HashMap::from([("/a/file.ics".into(), resource("/a/file.ics"))])),
			allow_write: true,
            locks: Mutex::new(vec![Lock {
                path: "/b/file.ics".into(),
                token: "t".into(),
                principal: None,
                depth: "0".into(),
                timeout: 100,
                expires_at: chrono::Utc::now().timestamp() + 100,
                owner_info: None,
            }]),
		});
		let ctx = DavContext::new(
			"COPY".into(),
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
