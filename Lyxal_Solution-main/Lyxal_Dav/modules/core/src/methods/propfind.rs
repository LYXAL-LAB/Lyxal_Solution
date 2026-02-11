use crate::{DavContext, DavResponse, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus};
use crate::backend::{ResourceKind, Principal};
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    // 1. Parse the request body (if any)
    let req = if ctx.body.is_empty() {
        // Empty body implies "allprop"
        xml::PropfindRequest { all_prop: true, prop_names: false, props: vec![] }
    } else {
        xml::parse_propfind(&ctx.body)?
    };

    let depth = ctx.header("depth").map(|s| s.as_str()).unwrap_or("infinity");

    // Principals handling
    if ctx.path.starts_with("/principals") {
        return handle_principals(&ctx, principal, &req, depth).await;
    }

    // ACL check (read)
    if !ctx.backend.check_access(principal, &ctx.path, false).await.unwrap_or(false) {
        return Err(DavError::Forbidden);
    }

	// 2. Fetch Resources
	let mut resources = Vec::new();

	// 2a. Fetch the root resource
	if let Some(root) = ctx.backend.get_resource(&ctx.path).await.map_err(|e| DavError::Internal(e.to_string()))? {
        // D4: ScheduleInbox/Outbox are collections
		let is_collection = matches!(root.kind, ResourceKind::Collection | ResourceKind::Calendar | ResourceKind::ScheduleInbox | ResourceKind::ScheduleOutbox);
		resources.push(root.clone());

		// 2b. Fetch children if Depth != "0" and it is a collection
		if depth != "0" && is_collection {
			use std::collections::VecDeque;
			let mut queue = VecDeque::new();
			queue.push_back(ctx.path.clone());
			while let Some(curr) = queue.pop_front() {
				let children = ctx.backend.list_collection(&curr).await.map_err(|e| DavError::Internal(e.to_string()))?;
				for child in children {
					// ACL read check per child
					if !ctx.backend.check_access(principal, &child.path, false).await.unwrap_or(false) {
						continue;
					}
					let is_coll = matches!(child.kind, ResourceKind::Collection | ResourceKind::Calendar | ResourceKind::ScheduleInbox | ResourceKind::ScheduleOutbox);
					resources.push(child.clone());
					if depth == "infinity" && is_coll {
						queue.push_back(child.path.clone());
					}
				}
				if depth == "1" {
					break;
				}
			}
		}
	} else {
		return Err(DavError::NotFound);
	}

    // 3. Build XML Responses
    let mut dav_resources = Vec::new();

    for res in resources {
        let mut properties = Vec::new();

        // 3a. Map Standard Properties
        if req.all_prop || req.props.contains(&"resourcetype".to_string()) {
            let type_str = match res.kind {
                ResourceKind::Collection => "<D:collection/>",
                ResourceKind::Calendar => "<D:collection/><C:calendar xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>",
                ResourceKind::ScheduleInbox => "<D:collection/><C:schedule-inbox xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>",
                ResourceKind::ScheduleOutbox => "<D:collection/><C:schedule-outbox xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>",
                _ => "",
            };
            properties.push(("D:resourcetype".to_string(), type_str.to_string()));
        }

        if req.all_prop || req.props.contains(&"getcontenttype".to_string()) {
            properties.push(("D:getcontenttype".to_string(), res.mime_type.clone()));
        }

        if req.all_prop || req.props.contains(&"getetag".to_string()) {
            properties.push(("D:getetag".to_string(), format!("\"{}\"", res.etag)));
        }

        if let Some(sync) = &res.sync_token {
            if req.all_prop || req.props.contains(&"sync-token".to_string()) || req.props.contains(&"D:sync-token".to_string()) {
                properties.push(("D:sync-token".to_string(), sync.clone()));
            }
        }

        // 3b. Map Custom Properties (stored in map)
        for (key, value) in &res.properties {
            // Check if requested? (Ignoring namespace for simple match for now)
            // Or if all_prop.
            // Property names in map should be full names like "D:displayname" or braced "{ns}name".
            // Our XML parser return simple names? `xml::parse_propfind` returns local names?
            // See `xml.rs` implementation.
            // Assuming `res.properties` keys are "matchable" to `req.props`.
            // For now, dump all if all_prop, or check containment.
            // Simple logic: key contains the requested prop name? precise match?
            // Let's dump all for all_prop, and check specific for named.
            // We'll simplify: we dump everything in `properties` if all_prop.
            if req.all_prop || req.props.iter().any(|p| key.ends_with(p)) {
                 properties.push((key.clone(), value.clone()));
            }
        }
        
        // 3c. Displayname fallback
        if (req.all_prop || req.props.contains(&"displayname".to_string())) && !res.properties.contains_key("D:displayname") {
             // Use basename of path
             let basename = res.path.split('/').last().unwrap_or(&res.path);
             properties.push(("D:displayname".to_string(), basename.to_string()));
        }

        dav_resources.push(DavResource {
            href: res.path,
            properties,
            status: "HTTP/1.1 200 OK".to_string(),
        });
    }

    // 4. Generate Response
    let mut resp = DavResponse::xml(StatusCode::MULTI_STATUS, generate_multistatus(None, dav_resources));
    resp.headers.insert("DAV".into(), "1, 2, calendar-access, calendar-schedule".into());
    Ok(resp)
}

async fn handle_principals(
    ctx: &DavContext,
    _principal: &str,
    req: &xml::PropfindRequest,
    depth: &str,
) -> Result<DavResponse, DavError> {
    let mut resources = Vec::new();

    let principals_path = if let Some(t) = &ctx.tenant {
        format!("/dav/{}/principals", t)
    } else {
        "/principals".to_string()
    };
    
    let is_root = ctx.path == principals_path || ctx.path == format!("{}/", principals_path);
    let is_sub = ctx.path.starts_with(&format!("{}/", principals_path));

    if is_root {
        let mut props = Vec::new();
        props.push(("D:resourcetype".to_string(), "<D:collection/>".to_string()));
        props.push(("D:displayname".to_string(), "Principals".to_string()));
        props.push(("D:principal-URL".to_string(), format!("<D:href>{}/</D:href>", principals_path)));
        resources.push(DavResource {
            href: format!("{}/", principals_path),
            properties: props,
            status: "HTTP/1.1 200 OK".to_string(),
        });

        if depth != "0" {
            let principals = ctx.backend.list_principals(ctx.tenant.as_deref()).await.map_err(|e| DavError::Internal(e.to_string()))?;
            for p in principals {
                resources.push(build_principal_resource(&p, req));
            }
        }
    } else if is_sub {
        let suffix = ctx.path.trim_end_matches('/');
        let prefix = format!("{}/", principals_path);
        let user = suffix.trim_start_matches(&prefix).to_string();
        let (user, proxy_kind) = if user.ends_with("/calendar-proxy-read") {
            (user.trim_end_matches("/calendar-proxy-read").to_string(), Some("read"))
        } else if user.ends_with("/calendar-proxy-write") {
            (user.trim_end_matches("/calendar-proxy-write").to_string(), Some("write"))
        } else {
            (user, None)
        };
        
        let Some(principal_data) = ctx.backend.get_principal(ctx.tenant.as_deref(), &user).await.map_err(|e| DavError::Internal(e.to_string()))? else {
            return Err(DavError::NotFound);
        };

        if let Some(kind) = proxy_kind {
            let mut props = Vec::new();
            props.push(("D:resourcetype".to_string(), "<D:principal/>".to_string()));
            props.push((
                "D:displayname".to_string(),
                format!("{} (calendar-proxy-{})", principal_data.displayname, kind),
            ));
            props.push((
                "D:principal-URL".to_string(),
                format!("<D:href>{}/{}/calendar-proxy-{}</D:href>", principals_path, principal_data.username, kind),
            ));
            props.push((
                "C:calendar-home-set".to_string(),
                format!("<D:href>{}</D:href>", principal_data.calendar_home),
            ));
            props.push((
                "D:alternate-URI-set".to_string(),
                principal_data
                    .alternate_uris
                    .iter()
                    .map(|u| format!("<D:href>{}</D:href>", u))
                    .collect::<Vec<_>>()
                    .join(""),
            ));
            resources.push(DavResource {
                href: format!("{}/{}/calendar-proxy-{}", principals_path, principal_data.username, kind),
                properties: props,
                status: "HTTP/1.1 200 OK".to_string(),
            });
        } else {
            resources.push(build_principal_resource(&principal_data, req));
        }
    }

    let mut resp = DavResponse::xml(StatusCode::MULTI_STATUS, generate_multistatus(None, resources));
    resp.headers.insert("DAV".into(), "1, 2, calendar-access, calendar-schedule".into());
    Ok(resp)
}

fn build_principal_resource(p: &Principal, req: &xml::PropfindRequest) -> DavResource {
    let mut properties = Vec::new();
    if req.all_prop || req.props.contains(&"resourcetype".to_string()) {
        properties.push(("D:resourcetype".to_string(), "<D:principal/>".to_string()));
    }
    if req.all_prop || req.props.contains(&"displayname".to_string()) || req.props.contains(&"D:displayname".to_string()) {
        properties.push(("D:displayname".to_string(), p.displayname.clone()));
    }
    properties.push((
        "D:principal-URL".to_string(),
        format!("<D:href>{}</D:href>", p.principal_url),
    ));
    properties.push((
        "C:calendar-home-set".to_string(),
        format!("<D:href>{}</D:href>", p.calendar_home),
    ));
    if let Some(inbox) = &p.schedule_inbox_url {
        properties.push((
            "C:schedule-inbox-URL".to_string(),
            format!("<D:href>{}</D:href>", inbox),
        ));
    }
    if let Some(outbox) = &p.schedule_outbox_url {
        properties.push((
            "C:schedule-outbox-URL".to_string(),
            format!("<D:href>{}</D:href>", outbox),
        ));
    }

    if let Some(email) = &p.email {
        properties.push((
            "C:calendar-user-address-set".to_string(),
            format!("<D:href>{}</D:href>", email),
        ));
        properties.push((
            "D:alternate-URI-set".to_string(),
            format!("<D:href>{}</D:href>", email),
        ));
    } else if !p.alternate_uris.is_empty() {
        properties.push((
            "D:alternate-URI-set".to_string(),
            p.alternate_uris
                .iter()
                .map(|u| format!("<D:href>{}</D:href>", u))
                .collect::<Vec<_>>()
                .join(""),
        ));
    }
    DavResource {
        href: p.principal_url.clone(),
        properties,
        status: "HTTP/1.1 200 OK".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind};
    use async_trait::async_trait;
    use std::sync::Arc;
    use std::collections::HashMap;

    struct MockBackend {
        allow: bool,
    }

    #[async_trait]
    impl DavBackend for MockBackend {
        async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
            if path == "/calendar" {
                Ok(Some(Resource {
                    path: "/calendar".to_string(),
                    kind: ResourceKind::Calendar,
                    mime_type: "".into(),
                    etag: "root".into(),
                    content: None,
                    properties: HashMap::from([("D:displayname".to_string(), "My Cal".to_string())]),
                    sync_token: None,
                }))
            } else if path == "/calendar/event.ics" {
                 Ok(Some(Resource {
                    path: "/calendar/event.ics".to_string(),
                    kind: ResourceKind::Object,
                    mime_type: "text/calendar".into(),
                    etag: "child".into(),
                    content: None,
                    properties: HashMap::new(),
                    sync_token: None,
                }))
            } else if path == "/inbox" {
                Ok(Some(Resource {
                    path: "/inbox".to_string(),
                    kind: ResourceKind::ScheduleInbox,
                    mime_type: "".into(),
                    etag: "".into(),
                    content: None,
                    properties: HashMap::new(),
                    sync_token: None,
                }))
            } else {
                Ok(None)
            }
        }
        async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>> {
            if path == "/calendar" {
                 Ok(vec![
                    Resource {
                        path: "/calendar/event.ics".to_string(),
                        kind: ResourceKind::Object,
                        mime_type: "text/calendar".into(),
                        etag: "child".into(),
                        content: None,
                        properties: HashMap::new(),
                        sync_token: None,
                    }
                 ])
            } else {
                Ok(vec![])
            }
        }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> { Ok(()) }
        async fn check_access(&self, _principal: &str, _path: &str, _write: bool) -> anyhow::Result<bool> {
            Ok(self.allow)
        }
        async fn get_principal(&self, user: &str) -> anyhow::Result<Option<crate::backend::Principal>> {
            Ok(Some(crate::backend::Principal {
                username: user.to_string(),
                displayname: format!("User {}", user),
                email: Some(format!("mailto:{user}@example.com")),
                calendar_home: "/calendar/".into(),
                principal_url: format!("/principals/{user}/"),
                alternate_uris: vec![],
            }))
        }
        async fn list_principals(&self) -> anyhow::Result<Vec<crate::backend::Principal>> {
            Ok(vec![crate::backend::Principal {
                username: "user".into(),
                displayname: "User user".into(),
                email: Some("mailto:user@example.com".into()),
                calendar_home: "/calendar/".into(),
                principal_url: "/principals/user/".into(),
                alternate_uris: vec![],
            }])
        }
    }

    #[tokio::test]
    async fn test_propfind_depth_0() {
        let backend = Arc::new(MockBackend { allow: true });
        let mut headers = HashMap::new();
        headers.insert("Depth".to_string(), "0".to_string());
        
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend, Some("user".into()));
        let params = handle(ctx).await.unwrap();
        let body = String::from_utf8(params.body).unwrap();
        
        // Should contain root but NOT child
        assert!(body.contains("/calendar</D:href>"));
        assert!(!body.contains("/calendar/event.ics</D:href>"));
    }

    #[tokio::test]
    async fn test_propfind_depth_1() {
        let backend = Arc::new(MockBackend { allow: true });
        let mut headers = HashMap::new();
        headers.insert("Depth".to_string(), "1".to_string());
        
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend, Some("user".into()));
        let params = handle(ctx).await.unwrap();
        let body = String::from_utf8(params.body).unwrap();
        
        // Should contain root AND child
        assert!(body.contains("/calendar</D:href>"));
        assert!(body.contains("/calendar/event.ics</D:href>"));
    }

    #[tokio::test]
    async fn test_propfind_unauthorized() {
        let backend = Arc::new(MockBackend { allow: true });
        let headers = HashMap::new();
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend, None);
        let res = handle(ctx).await;
        assert!(matches!(res, Err(DavError::Unauthorized)));
    }

    #[tokio::test]
    async fn test_propfind_forbidden() {
        let backend = Arc::new(MockBackend { allow: false });
        let headers = HashMap::new();
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend, Some("user".into()));
        let res = handle(ctx).await;
        assert!(matches!(res, Err(DavError::Forbidden)));
    }

    #[tokio::test]
    async fn test_principal_home_set_present() {
        let backend = Arc::new(MockBackend { allow: true });
        let headers = HashMap::new();
        let ctx = DavContext::new("PROPFIND".into(), "/principals/user/".into(), vec![], headers, backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("<C:calendar-home-set><D:href>/calendar/</D:href></C:calendar-home-set>"));
        // Check new scheduling props
        assert!(body.contains("schedule-inbox-URL"));
        assert!(body.contains("schedule-outbox-URL"));
    }

    #[tokio::test]
    async fn test_propfind_inbox() {
        let backend = Arc::new(MockBackend { allow: true });
        let headers = HashMap::new();
        let ctx = DavContext::new("PROPFIND".into(), "/inbox".into(), vec![], headers, backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("<C:schedule-inbox"));
    }
}
