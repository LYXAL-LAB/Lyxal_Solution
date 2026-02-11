use crate::{DavContext, DavResponse, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus, SyncCollectionRequest};
use http::StatusCode;

pub async fn handle(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
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
        "free-busy-query" => {
            // D4.2: FreeBusy
            let query = xml::parse_free_busy_query(&ctx.body)?;
            let res = ctx.backend.free_busy_query(&ctx.path, query).await
                .map_err(|e| DavError::Internal(e.to_string()))?;
            
            // free-busy-query returns a specific VFREEBUSY object, wrapped in a DavResource
            // The response format is NOT a multistatus with properties, but a Calendar Data response usually?
            // Actually, RFC 4791 says the response is a VCALENDAR with VFREEBUSY component.
            // But typical REPORT response is Multistatus or raw calendar data?
            // "The response body for a successful REPORT request... MUST be a Multi-Status response... OR a VCALENDAR... depending on the report."
            // For `free-busy-query`, the response is a `caldav:calendar-data` containing the VFREEBUSY.
            // Wait, standard free-busy-query returns a VCALENDAR object directly in the body with Content-Type: text/calendar (or application/xml if wrapped, but usually raw).
            // RFC 4791 Section 7.10.1: "The response body for a successful free-busy-query REPORT request MUST contain a CALDAV:calendar-data XML element that contains the VFREEBUSY component..."
            // So it IS XML. <C:calendar-data> ... </C:calendar-data> inside MultiStatus?
            // No, the example shows just the VCALENDAR object?
            // Wait, re-reading 7.10.1: "The response body... MUST contain a CALDAV:calendar-data XML element... "
            // Ah, actually, usually it's wrapped in a response?
            // Let's check the example 7.10.2:
            // Response:
            // HTTP/1.1 200 OK
            // Content-Type: text/calendar
            // BEGIN:VCALENDAR...
            
            // SO it is NOT MultiStatus. It is raw text/calendar.
            
            if let Some(first) = res.first() {
                if let Some(content) = &first.content {
                    let text = String::from_utf8_lossy(content).to_string();
                    return Ok(DavResponse::ics(StatusCode::OK, text, None));
                }
            }
            return Ok(DavResponse::ics(StatusCode::OK, "BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VFREEBUSY\nEND:VFREEBUSY\nEND:VCALENDAR".into(), None));
        },
        "addressbook-query" => {
            let query = xml::parse_addressbook_query(&ctx.body)?;
            let res = ctx.backend.query_addressbook(&ctx.path, query).await
                .map_err(|e| DavError::Internal(e.to_string()))?;
            // PropfindRequest parsing not implemented for addressbook-query yet (defaults to allprop logic in loop)
            // But we can parse 'prop' from body if we want perfect compliance.
            // For D0.4.1, we assume allprop or similar defaults.
            // Actually, parse_addressbook_query only extracts filter.
            // We should ideally extract properties too.
            // But let's proceed with empty props (will trigger defaults or allprop if not careful).
            // Wait, if we return empty props request, the logic below:
            // if !req.all_prop && req.props.is_empty() ...
            // We need to parse prop.
            // Reusing parse_propfind on the body works if structure matches?
            // <addressbook-query> <prop> ... </prop> </addressbook-query>
            // parse_propfind expects root <propfind>.
            // I'll assume we return full objects for now as per "Retour <multistatus> avec : href, getetag, address-data (vCard complète)".
            
            // Hack: manually construct a request asking for address-data and etag
            let req = xml::PropfindRequest {
                all_prop: false,
                prop_names: false,
                props: vec!["getetag".into(), "address-data".into()],
            };
            (res, req)
        },
        "addressbook-multiget" => {
            let (hrefs, req) = xml::parse_addressbook_multiget(&ctx.body)?;
            let mut found = Vec::new();
            for href in hrefs {
                if let Ok(Some(res)) = ctx.backend.get_resource(&href).await {
                    found.push(res);
                } else {
                    found.push(crate::backend::Resource {
                        path: href,
                        kind: crate::backend::ResourceKind::Object,
                        mime_type: "".into(),
                        etag: "".into(),
                        content: None,
                        properties: std::collections::HashMap::new(),
                        sync_token: None,
                    });
                }
            }
            (found, req)
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
                        sync_token: None,
                    });
                }
            }
            (found, req)
        },
        "sync-collection" => {
            let SyncCollectionRequest { sync_token, limit, prop } = xml::parse_sync_collection(&ctx.body)?;
            if !ctx.backend.check_access(principal, &ctx.path, false).await.unwrap_or(false) {
                return Err(DavError::Forbidden);
            }
            let result = ctx.backend
                .sync_collection(&ctx.path, sync_token.as_deref(), limit)
                .await
                .map_err(|e| DavError::Internal(e.to_string()))?;

            // Transform SyncCollectionResult into resources
            let resources = result.resources;
            let req = prop;
            let sync_token = Some(result.sync_token);

            // Build multistatus with sync-token
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

            let token_str = sync_token.as_ref().map(|s| s.as_str());
            let mut resp = DavResponse::xml(StatusCode::MULTI_STATUS, generate_multistatus(token_str, xml_resources));
            resp.headers.insert("DAV".into(), "1, 2, calendar-access".into());
            return Ok(resp);
        }
        _ => return Err(DavError::Internal(format!("Unsupported REPORT type: {}", report_type)))
    };
        
    if !ctx.backend.check_access(principal, &ctx.path, false).await.unwrap_or(false) {
        return Err(DavError::Forbidden);
    }

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
                if let Some(content) = &res.content {
                     let text = String::from_utf8_lossy(content).to_string();
                     props.push(("C:calendar-data".to_string(), text));
                }
             }

            // Address Data (CardDAV)
             if req.all_prop || req.props.contains(&"address-data".to_string()) || req.props.contains(&"C:address-data".to_string()) {
                if let Some(content) = &res.content {
                     let text = String::from_utf8_lossy(content).to_string();
                     props.push(("C:address-data".to_string(), text));
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
    let mut resp = DavResponse::xml(StatusCode::MULTI_STATUS, generate_multistatus(None, xml_resources));
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
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>> {
            if path == "/calendar" {
                 Ok(vec![
                    Resource {
                        path: "/calendar/event1.ics".to_string(),
                        kind: ResourceKind::Object,
                        mime_type: "text/calendar".into(),
                        etag: "e1".into(),
                        content: Some("BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Test//\nBEGIN:VEVENT\nUID:one\nDTSTART:20250101T100000Z\nDTEND:20250101T110000Z\nEND:VEVENT\nEND:VCALENDAR".as_bytes().to_vec()),
                        properties: HashMap::new(),
                        sync_token: None,
                    },
                    Resource {
                        path: "/calendar/event2.ics".to_string(),
                        kind: ResourceKind::Object,
                        mime_type: "text/calendar".into(),
                        etag: "e2".into(),
                        content: Some("BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Test//\nBEGIN:VEVENT\nUID:two\nDTSTART:20250110T100000Z\nDTEND:20250110T110000Z\nEND:VEVENT\nEND:VCALENDAR".as_bytes().to_vec()),
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
        async fn free_busy_query(&self, _path: &str, query: crate::backend::CalendarQuery) -> anyhow::Result<Vec<Resource>> {
            // Mock response
            Ok(vec![Resource {
                path: "".into(),
                kind: ResourceKind::Object,
                mime_type: "text/calendar".into(),
                etag: "".into(),
                content: Some(format!("BEGIN:VCALENDAR\nBEGIN:VFREEBUSY\nDTSTART:{}\nDTEND:{}\nFREEBUSY:20250101T100000Z/PT1H\nEND:VFREEBUSY\nEND:VCALENDAR", query.start.unwrap_or_default(), query.end.unwrap_or_default()).into_bytes()),
                properties: HashMap::new(),
                sync_token: None,
            }])
        }
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
        
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        
        assert!(body.contains("/calendar/event1.ics"), "Should contain event1");
        assert!(!body.contains("/calendar/event2.ics"), "Should NOT contain event2");
    }

    struct MockSyncBackend {
        changes: Vec<Resource>,
        token: String,
    }

    #[async_trait]
    impl DavBackend for MockSyncBackend {
        async fn get_resource(&self, _path: &str) -> anyhow::Result<Option<Resource>> { Ok(None) }
        async fn list_collection(&self, _path: &str) -> anyhow::Result<Vec<Resource>> { Ok(vec![]) }
        async fn put_resource(&self, _path: &str, _data: &[u8], _mime: &str) -> anyhow::Result<String> { Ok("".into()) }
        async fn delete_resource(&self, _path: &str) -> anyhow::Result<()> { Ok(()) }
        async fn create_collection(&self, _path: &str, _kind: ResourceKind) -> anyhow::Result<()> { Ok(()) }
        async fn sync_collection(
            &self,
            _path: &str,
            _sync_token: Option<&str>,
            _limit: Option<usize>,
        ) -> anyhow::Result<crate::backend::SyncCollectionResult> {
            Ok(crate::backend::SyncCollectionResult {
                resources: self.changes.clone(),
                sync_token: self.token.clone(),
                partial: false,
            })
        }
    }

    #[tokio::test]
    async fn test_sync_collection_empty_token_unchanged() {
        let backend = Arc::new(MockSyncBackend { changes: vec![], token: "5".into() });
        let body = r#"
            <sync-collection xmlns="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
                <sync-token>5</sync-token>
                <sync-level>1</sync-level>
                <prop>
                    <getetag/>
                </prop>
            </sync-collection>
        "#;
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("<D:sync-token>5</D:sync-token>"));
        assert!(!body.contains("<D:response>"), "no changes expected");
    }

    #[tokio::test]
    async fn test_sync_collection_create_returns_href_and_etag() {
        let resource = Resource {
            path: "/calendar/new.ics".into(),
            kind: ResourceKind::Object,
            mime_type: "text/calendar".into(),
            etag: "e123".into(),
            content: Some("BEGIN:VCALENDAR\nEND:VCALENDAR".as_bytes().to_vec()),
            properties: HashMap::new(),
            sync_token: Some("6".into()),
        };
        let backend = Arc::new(MockSyncBackend { changes: vec![resource], token: "6".into() });
        let body = r#"
            <sync-collection xmlns="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
                <sync-token>5</sync-token>
                <sync-level>1</sync-level>
                <prop>
                    <getetag/>
                    <C:calendar-data/>
                </prop>
            </sync-collection>
        "#;
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("/calendar/new.ics"));
        assert!(body.contains("\"e123\""));
        assert!(body.contains("<C:calendar-data>BEGIN:VCALENDAR"));
    }

    #[tokio::test]
    async fn test_sync_collection_delete_returns_404() {
        let resource = Resource {
            path: "/calendar/old.ics".into(),
            kind: ResourceKind::Object,
            mime_type: "".into(), // triggers 404
            etag: "".into(),
            content: None,
            properties: HashMap::new(),
            sync_token: Some("7".into()),
        };
        let backend = Arc::new(MockSyncBackend { changes: vec![resource], token: "7".into() });
        let body = r#"
            <sync-collection xmlns="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
                <sync-token>6</sync-token>
                <sync-level>1</sync-level>
                <prop>
                    <getetag/>
                </prop>
            </sync-collection>
        "#;
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("/calendar/old.ics"));
        assert!(body.contains("404"));
    }

    #[tokio::test]
    async fn test_free_busy_query() {
        let backend = Arc::new(MockBackend);
        let body = r#"
            <C:free-busy-query xmlns:C="urn:ietf:params:xml:ns:caldav">
                <C:time-range start="20250101T000000Z" end="20250102T000000Z"/>
            </C:free-busy-query>
        "#;
        let ctx = DavContext::new("REPORT".into(), "/calendar".into(), body.as_bytes().to_vec(), HashMap::new(), backend, Some("user".into()));
        let resp = handle(ctx).await.unwrap();
        assert_eq!(resp.status, StatusCode::OK);
        assert_eq!(resp.headers.get("Content-Type").unwrap(), "text/calendar; charset=utf-8");
        let body = String::from_utf8(resp.body).unwrap();
        assert!(body.contains("BEGIN:VFREEBUSY"));
        assert!(body.contains("FREEBUSY:20250101T100000Z/PT1H"));
    }
}
