use crate::{DavContext, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus};

pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    let report_type = xml::detect_report_type(&ctx.body)?;
    
    let resources = match report_type.as_str() {
        "calendar-query" => {
            let query = xml::parse_calendar_query(&ctx.body)?;
            ctx.backend.query_collection(&ctx.path, query).await
                .map_err(|e| DavError::Internal(e.to_string()))?
        },
        "calendar-multiget" => {
            let hrefs = xml::parse_calendar_multiget(&ctx.body)?;
            let mut found = Vec::new();
            for href in hrefs {
                // Backend expects path relative to DAV root? 
                // Hrefs in XML are usually full paths or absolute relative.
                // Assuming backend.get_resource takes the path as stored.
                if let Ok(Some(res)) = ctx.backend.get_resource(&href).await {
                    found.push(res);
                } else {
                    // Logic for Not Found in MultiStatus? 
                    // Usually MultiStatus includes 404 block.
                    // For Phase 1 MVP, we ignore missing or return 404 block?
                    // Let's ignore for now or add a stub resource with 404 status.
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
            found
        },
        _ => return Err(DavError::Internal(format!("Unsupported REPORT type: {}", report_type)))
    };
        
    // 3. Transform to XML Response Resources
    let xml_resources: Vec<DavResource> = resources.into_iter().map(|res| {
        let mut props = Vec::new();
        let mut status = "HTTP/1.1 200 OK".to_string();
        
        if res.mime_type.is_empty() {
             status = "HTTP/1.1 404 Not Found".to_string();
        } else {
            // ETag
            props.push(("D:getetag".to_string(), format!("\"{}\"", res.etag)));
            
            // Calendar Data (if content is present)
            if let Some(content) = res.content {
                 let text = String::from_utf8_lossy(&content).to_string();
                 props.push(("C:calendar-data".to_string(), text));
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
