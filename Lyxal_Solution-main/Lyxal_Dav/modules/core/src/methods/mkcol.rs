use crate::{DavContext, DavResponse};
use crate::backend::ResourceKind;
use crate::error::DavError;
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
	let principal = ctx.principal().ok_or(DavError::Unauthorized)?;

	// Already exists?
	if let Ok(Some(_)) = ctx.backend.get_resource(&ctx.path).await {
		return Err(DavError::MethodNotAllowed);
	}

	// Parent check + ACL
	if let Some(parent) = parent_path(&ctx.path) {
		if ctx.backend.get_resource(&parent).await.map_err(|e| DavError::Internal(e.to_string()))?.is_none() {
			return Err(DavError::NotFound);
		}
		if !ctx.backend.check_access(principal, &parent, true).await.unwrap_or(false) {
			return Err(DavError::Forbidden);
		}
	} else {
		return Err(DavError::Forbidden); // refuse créer à la racine absolue
	}

	ctx.backend
		.create_collection(&ctx.path, ResourceKind::Collection)
		.await
		.map_err(|e| DavError::Internal(format!("Backend error: {}", e)))?;

	Ok(DavResponse::empty(StatusCode::CREATED))
}

fn parent_path(path: &str) -> Option<String> {
	let trimmed = path.trim_end_matches('/');
	trimmed.rsplit_once('/').and_then(|(left, _)| {
		if left.is_empty() {
			None
		} else {
			Some(left.to_string())
		}
	})
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::backend::{DavBackend, Resource, ResourceKind};
	use async_trait::async_trait;
	use std::collections::HashMap;
	use std::sync::Arc;

	struct MockBackend {
		existing: Vec<String>,
		allow_write: bool,
		created: Arc<std::sync::Mutex<Vec<String>>>,
	}

	#[async_trait]
	impl DavBackend for MockBackend {
		async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
			if self.existing.contains(&path.to_string()) {
				return Ok(Some(Resource {
					path: path.to_string(),
					kind: if path.ends_with(".ics") { ResourceKind::Object } else { ResourceKind::Collection },
					mime_type: "text/plain".into(),
					etag: "e".into(),
					content: None,
					properties: HashMap::new(),
					sync_token: None,
				}));
			}
			Ok(None)
		}
		async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> {
			Ok(vec![])
		}
		async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> {
			Ok("e".into())
		}
		async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> {
			Ok(())
		}
		async fn create_collection(&self, path: &str, _kind: ResourceKind) -> anyhow::Result<()> {
			self.created.lock().unwrap().push(path.to_string());
			Ok(())
		}
		async fn check_access(&self, _principal: &str, _path: &str, write: bool) -> anyhow::Result<bool> {
			Ok(if write { self.allow_write } else { true })
		}
	}

	#[tokio::test]
	async fn test_mkcol_ok() {
		let backend = Arc::new(MockBackend {
			existing: vec!["/parent".into()],
			allow_write: true,
			created: Arc::new(std::sync::Mutex::new(vec![])),
		});
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"MKCOL".into(),
			"/parent/new".into(),
			vec![],
			headers,
			backend.clone(),
			Some("user".into()),
		);
		let resp = handle(ctx).await.unwrap();
		assert_eq!(resp.status, StatusCode::CREATED);
		assert!(backend.created.lock().unwrap().contains(&"/parent/new".to_string()));
	}

	#[tokio::test]
	async fn test_mkcol_existing() {
		let backend = Arc::new(MockBackend {
			existing: vec!["/parent".into(), "/parent/new".into()],
			allow_write: true,
			created: Arc::new(std::sync::Mutex::new(vec![])),
		});
		let ctx = DavContext::new(
			"MKCOL".into(),
			"/parent/new".into(),
			vec![],
			HashMap::new(),
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::MethodNotAllowed)));
	}

	#[tokio::test]
	async fn test_mkcol_forbidden() {
		let backend = Arc::new(MockBackend {
			existing: vec!["/parent".into()],
			allow_write: false,
			created: Arc::new(std::sync::Mutex::new(vec![])),
		});
		let ctx = DavContext::new(
			"MKCOL".into(),
			"/parent/new".into(),
			vec![],
			HashMap::new(),
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Forbidden)));
	}
}

