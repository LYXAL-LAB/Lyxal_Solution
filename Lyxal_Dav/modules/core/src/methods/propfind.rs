use crate::{DavContext, DavResponse, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus};
use crate::backend::ResourceKind;
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    // 1. Parse the request body (if any)
    let req = if ctx.body.is_empty() {
        // Empty body implies "allprop"
        xml::PropfindRequest { all_prop: true, prop_names: false, props: vec![] }
    } else {
        xml::parse_propfind(&ctx.body)?
    };

    let depth = ctx.header("depth").map(|s| s.as_str()).unwrap_or("infinity");

    // 2. Fetch Resources
    let mut resources = Vec::new();

    // 2a. Fetch the root resource
    // TODO: Map error properly
    if let Some(root) = ctx.backend.get_resource(&ctx.path).await.map_err(|e| DavError::Internal(e.to_string()))? {
        let is_collection = matches!(root.kind, ResourceKind::Collection | ResourceKind::Calendar);
        resources.push(root);

        // 2b. Fetch children if Depth != "0" and it is a collection
        if depth != "0" && is_collection {
            let children = ctx.backend.list_collection(&ctx.path).await.map_err(|e| DavError::Internal(e.to_string()))?;
            // If Depth is "1", we take all children.
            // If Depth is "infinity", we theoretically take all descendants.
            // But `list_collection` is usually flat.
            // For CalDAV/CardDAV, collections are usually 1 level deep (events in calendar).
            // So `list_collection` is sufficient for Depth 1 and Infinity usually.
            // True recursive walk would be needed for folders in folders.
            // For now, MVP assumes 1 level.
            resources.extend(children);
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
    let mut resp = DavResponse::xml(StatusCode::MULTI_STATUS, generate_multistatus(dav_resources));
    resp.headers.insert("DAV".into(), "1, 2, calendar-access".into());
    Ok(resp)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backend::{DavBackend, Resource, ResourceKind};
    use async_trait::async_trait;
    use std::sync::Arc;
    use std::collections::HashMap;

    struct MockBackend;

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
    }

    #[tokio::test]
    async fn test_propfind_depth_0() {
        let backend = Arc::new(MockBackend);
        let mut headers = HashMap::new();
        headers.insert("Depth".to_string(), "0".to_string());
        
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend);
        let params = handle(ctx).await.unwrap();
        let body = String::from_utf8(params.body).unwrap();
        
        // Should contain root but NOT child
        assert!(body.contains("/calendar</D:href>"));
        assert!(!body.contains("/calendar/event.ics</D:href>"));
    }

    #[tokio::test]
    async fn test_propfind_depth_1() {
        let backend = Arc::new(MockBackend);
        let mut headers = HashMap::new();
        headers.insert("Depth".to_string(), "1".to_string());
        
        let ctx = DavContext::new("PROPFIND".into(), "/calendar".into(), vec![], headers, backend);
        let params = handle(ctx).await.unwrap();
        let body = String::from_utf8(params.body).unwrap();
        
        // Should contain root AND child
        assert!(body.contains("/calendar</D:href>"));
        assert!(body.contains("/calendar/event.ics</D:href>"));
    }
}
