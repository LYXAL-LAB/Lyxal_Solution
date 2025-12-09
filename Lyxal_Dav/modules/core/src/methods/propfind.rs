use crate::{DavContext, xml};
use crate::error::DavError;
use crate::xml::{DavResource, generate_multistatus};

pub async fn handle(ctx: DavContext) -> Result<String, DavError> {
    // 1. Parse the request body to see what properties are requested
    let req = xml::parse_propfind(&ctx.body)?;
    
    // 2. Fetch Data (This is where the DB Bridge will hook in)
    // For specific Phase 4 completion, we simulate retrieval of the requested resource
    // TODO: Connect this to SurrealDB `crates/core` via a trait or callback
    
    let mut properties = Vec::new();

    // Default properties for a collection/calendar
    if req.all_prop || req.props.contains(&"resourcetype".to_string()) {
        properties.push(("D:resourcetype".to_string(), "<D:collection/><C:calendar/>".to_string()));
    }
    if req.all_prop || req.props.contains(&"displayname".to_string()) {
        properties.push(("D:displayname".to_string(), "Native Calendar".to_string()));
    }
    if req.all_prop || req.props.contains(&"getcontenttype".to_string()) {
        properties.push(("D:getcontenttype".to_string(), "text/calendar; charset=utf-8; component=VEVENT".to_string()));
    }
    // CTag is critical for syncing
    if req.all_prop || req.props.contains(&"getctag".to_string()) {
        properties.push(("CS:getctag".to_string(), "\"123456789\"".to_string())); // Simulated CTag
    }

    // 3. Build Resource Object
    let resource = DavResource {
        href: ctx.path,
        properties,
        status: "HTTP/1.1 200 OK".to_string(),
    };

    // 4. Generate Response
    Ok(generate_multistatus(vec![resource]))
}
