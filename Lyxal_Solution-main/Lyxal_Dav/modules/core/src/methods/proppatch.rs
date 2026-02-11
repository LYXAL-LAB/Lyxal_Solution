use crate::{DavContext, DavResponse, xml};
use crate::error::DavError;
use crate::xml::generate_multistatus;
use crate::methods::check_locked;
use http::StatusCode;

const PROTECTED_PROPS: &[&str] = &[
	"resourcetype",
	"getetag",
	"sync-token",
	"principal-url",
	"calendar-home-set",
];

fn is_protected(name: &str) -> bool {
	let lname = name.to_ascii_lowercase();
	let stripped = lname.split(':').last().unwrap_or(&lname);
	PROTECTED_PROPS
		.iter()
		.any(|p| stripped.eq(p.to_ascii_lowercase().as_str()))
}

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
	let principal = ctx.principal().ok_or(DavError::Unauthorized)?;

	// ACL
	if !ctx
		.backend
		.check_access(principal, &ctx.path, true)
		.await
		.unwrap_or(false)
	{
		return Err(DavError::Forbidden);
	}

    // Check Lock
    check_locked(&ctx, &ctx.path).await?;

	// Parse
	let ops = xml::parse_proppatch(&ctx.body)?;

	// Protected props rejection
	for (name, _) in ops.set_props.iter() {
		if is_protected(name) {
			return Err(DavError::Forbidden);
		}
	}
	for name in ops.remove_props.iter() {
		if is_protected(name) {
			return Err(DavError::Forbidden);
		}
	}

	// Apply
	ctx.backend
		.set_properties(&ctx.path, &ops.set_props)
		.await
		.map_err(|e| DavError::Internal(e.to_string()))?;
	ctx.backend
		.remove_properties(&ctx.path, &ops.remove_props)
		.await
		.map_err(|e| DavError::Internal(e.to_string()))?;

	// Minimal multistatus success
	let mut resp = DavResponse::xml(
		StatusCode::MULTI_STATUS,
		generate_multistatus(None, vec![crate::xml::DavResource {
			href: ctx.path,
			properties: Vec::new(),
			status: "HTTP/1.1 200 OK".into(),
		}]),
	);
	resp.headers.insert("DAV".into(), "1, 2, calendar-access".into());
	Ok(resp)
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
		props: std::sync::Mutex<HashMap<String, HashMap<String, String>>>,
		allow: bool,
		locks: Mutex<Vec<Lock>>,
	}

	#[async_trait]
	impl DavBackend for MockBackend {
		async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> {
			Ok(Some(Resource {
				path: "/cal".into(),
				kind: ResourceKind::Calendar,
				mime_type: "text/calendar".into(),
				etag: "e".into(),
				content: None,
				properties: HashMap::new(),
				sync_token: None,
			}))
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
		async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> {
			Ok(())
		}
		async fn check_access(&self, _principal: &str, _path: &str, write: bool) -> anyhow::Result<bool> {
			Ok(if write { self.allow } else { true })
		}
		async fn set_properties(&self, path: &str, props: &[(String, String)]) -> anyhow::Result<()> {
			let mut guard = self.props.lock().unwrap();
			let entry = guard.entry(path.to_string()).or_default();
			for (k, v) in props {
				entry.insert(k.clone(), v.clone());
			}
			Ok(())
		}
		async fn remove_properties(&self, path: &str, names: &[String]) -> anyhow::Result<()> {
			let mut guard = self.props.lock().unwrap();
			if let Some(entry) = guard.get_mut(path) {
				for n in names {
					entry.remove(n);
				}
			}
			Ok(())
		}
		async fn get_properties(&self, path: &str) -> anyhow::Result<HashMap<String, String>> {
			let guard = self.props.lock().unwrap();
			Ok(guard.get(path).cloned().unwrap_or_default())
		}
        async fn get_locks(&self, path: &str) -> anyhow::Result<Vec<Lock>> {
            let locks = self.locks.lock().unwrap();
            Ok(locks.iter().filter(|l| l.path == path).cloned().collect())
        }
	}

	fn build_body_set() -> Vec<u8> {
		r#"
		<D:propertyupdate xmlns:D="DAV:">
			<D:set>
				<D:prop>
					<custom:color xmlns:custom="http://example.com/">blue</custom:color>
				</D:prop>
			</D:set>
		</D:propertyupdate>
		"#
		.as_bytes()
		.to_vec()
	}

	fn build_body_remove() -> Vec<u8> {
		r#"
		<D:propertyupdate xmlns:D="DAV:">
			<D:remove>
				<D:prop>
					<custom:color xmlns:custom="http://example.com/"/>
				</D:prop>
			</D:remove>
		</D:propertyupdate>
		"#
		.as_bytes()
		.to_vec()
	}

	fn build_body_protected() -> Vec<u8> {
		r#"
		<D:propertyupdate xmlns:D="DAV:">
			<D:set>
				<D:prop>
					<D:getetag>abc</D:getetag>
				</D:prop>
			</D:set>
		</D:propertyupdate>
		"#
		.as_bytes()
		.to_vec()
	}

	#[tokio::test]
	async fn test_proppatch_set_ok() {
		let backend = Arc::new(MockBackend { allow: true, ..Default::default() });
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"PROPPATCH".into(),
			"/cal".into(),
			build_body_set(),
			headers,
			backend.clone(),
			Some("user".into()),
		);
		let resp = handle(ctx).await.unwrap();
		assert_eq!(resp.status, StatusCode::MULTI_STATUS);
		let stored = backend.get_properties("/cal").await.unwrap();
		assert_eq!(stored.get("color").cloned(), Some("blue".into()));
	}

	#[tokio::test]
	async fn test_proppatch_remove_ok() {
		let backend = Arc::new(MockBackend { allow: true, ..Default::default() });
		let _ = backend
			.set_properties("/cal", &[("custom:color".into(), "blue".into())])
			.await;
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"PROPPATCH".into(),
			"/cal".into(),
			build_body_remove(),
			headers,
			backend.clone(),
			Some("user".into()),
		);
		let resp = handle(ctx).await.unwrap();
		assert_eq!(resp.status, StatusCode::MULTI_STATUS);
		let stored = backend.get_properties("/cal").await.unwrap();
		assert!(stored.get("color").is_none());
	}

	#[tokio::test]
	async fn test_proppatch_forbidden_no_write() {
		let backend = Arc::new(MockBackend { allow: false, ..Default::default() });
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"PROPPATCH".into(),
			"/cal".into(),
			build_body_set(),
			headers,
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Forbidden)));
	}

	#[tokio::test]
	async fn test_proppatch_protected_rejected() {
		let backend = Arc::new(MockBackend { allow: true, ..Default::default() });
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"PROPPATCH".into(),
			"/cal".into(),
			build_body_protected(),
			headers,
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Forbidden)));
	}

    #[tokio::test]
	async fn test_proppatch_locked() {
		let backend = Arc::new(MockBackend { allow: true, ..Default::default() });
        backend.locks.lock().unwrap().push(Lock {
            path: "/cal".into(),
            token: "t".into(),
            principal: None,
            depth: "0".into(),
            timeout: 100,
            expires_at: chrono::Utc::now().timestamp() + 100,
            owner_info: None,
        });
		let headers = HashMap::new();
		let ctx = DavContext::new(
			"PROPPATCH".into(),
			"/cal".into(),
			build_body_set(),
			headers,
			backend,
			Some("user".into()),
		);
		let res = handle(ctx).await;
		assert!(matches!(res, Err(DavError::Locked)));
	}
}
