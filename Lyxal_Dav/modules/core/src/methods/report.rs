use crate::{DavContext, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus};

pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    let report_type = xml::detect_report_type(&ctx.body)?;
    
    // Determine resources and the property request
    let (resources, req) = match report_type.as_str() {
        "calendar-query" => {
            let query = xml::parse_calendar_query(&ctx.body)?;
            let res = ctx.backend.query_collection(&ctx.path, query).await
                .map_err(|e| DavError::Internal(e.to_string()))?;
            
            // For calendar-query, we default to all properties if not parsed
            // TODO: Update parse_calendar_query to return properties too
            (res, xml::PropfindRequest { all_prop: true, prop_names: false, props: vec![] })
        },
        "calendar-multiget" => {
            let (hrefs, req) = xml::parse_calendar_multiget(&ctx.body)?;
            let mut found = Vec::new();
            for href in hrefs {
                // Backend expects path
                if let Ok(Some(res)) = ctx.backend.get_resource(&href).await {
                    found.push(res);
                } else {
                    // Stub for generic 404
                    found.push(crate::backend::Resource {
                        path: href,
                        kind: crate::backend::ResourceKind::Object,
                        mime_type: "".into(),
                        etag: "".into(),
                        content: None,
                        properties: std::collections::HashMap::new(),
                    });
                }
            }
            (found, req)
        },
        _ => return Err(DavError::Internal(format!("Unsupported REPORT type: {}", report_type)))
    };
        
    // 3. Transform to XML Response Resources with Property Filtering
    let xml_resources: Vec<DavResource> = resources.into_iter().map(|res| {
        let mut props = Vec::new();
        let mut status = "HTTP/1.1 200 OK".to_string();
        
        if res.mime_type.is_empty() {
             status = "HTTP/1.1 404 Not Found".to_string();
        } else {
            // ETag
             if req.all_prop || req.props.contains(&"getetag".to_string()) || req.props.contains(&"D:getetag".to_string()) {
                props.push(("D:getetag".to_string(), format!("\"{}\"", res.etag)));
             }
            
            // Calendar Data
             if req.all_prop || req.props.contains(&"calendar-data".to_string()) || req.props.contains(&"C:calendar-data".to_string()) {
                if let Some(content) = res.content {
                     let text = String::from_utf8_lossy(&content).to_string();
                     props.push(("C:calendar-data".to_string(), text));
                }
             }

             // Other properties
             for (key, value) in &res.properties {
                if req.all_prop || req.props.iter().any(|p| key.ends_with(p)) {
                     props.push((key.clone(), value.clone()));
                }
             }
        }
        
        DavResource {
            href: res.path,
            properties: props,
            status,
        }
    }).collect();
    
    // 4. Generate MultiStatus
    Ok(generate_multistatus(xml_resources))
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
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>> {
            if path == "/calendar" {
                 Ok(vec![
                    Resource {
                        path: "/calendar/event1.ics".to_string(),
                        kind: ResourceKind::Object,
                        mime_type: "text/calendar".into(),
                        etag: "e1".into(),
                        content: Some("BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250101T100000Z\nDURATION:PT1H\nEND:VEVENT\nEND:VCALENDAR".as_bytes().to_vec()),
                        properties: HashMap::new(),
                    },
                    Resource {
                        path: "/calendar/event2.ics".to_string(),
                        kind: ResourceKind::Object,
                        mime_type: "text/calendar".into(),
                        etag: "e2".into(),
                        content: Some("BEGIN:VCALENDAR\nBEGIN:VEVENT\nDTSTART:20250110T100000Z\nDURATION:PT1H\nEND:VEVENT\nEND:VCALENDAR".as_bytes().to_vec()),
                        properties: HashMap::new(),
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
    async fn test_report_calendar_query_timerange() {
        let backend = Arc::new(MockBackend);
        // Query for 2025-01-01 (should match event1, not event2)
        let body = r#"
            <C:calendar-query xmlns:C="urn:ietf:params:xml:ns:caldav">
                <C:filter>
                    <C:comp-filter name="VCALENDAR">
                        <C:comp-filter name="VEVENT">
                            <C:time-range start="20250101T000000Z" end="20250102T000000Z"/>
                        </C:comp-filter>
                    </C:comp-filter>
                </C:filter>
            </C:calendar-query>
        "#;
        
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend);
        let resp = handle(ctx).await.unwrap();
        
        assert!(resp.contains("/calendar/event1.ics"), "Should contain event1");
        assert!(!resp.contains("/calendar/event2.ics"), "Should NOT contain event2");
    }
}
