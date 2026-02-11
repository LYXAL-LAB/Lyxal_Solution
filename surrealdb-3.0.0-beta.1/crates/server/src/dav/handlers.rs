//! DAV HTTP Method Handlers
//!
//! Implements WebDAV, CalDAV, and CardDAV protocol methods.

use super::context::DavContext;
use surrealdb_core::dav::{
    DavError, DavResource, DavResponse, Lock, ResourceKind,
    generate_lockdiscovery, generate_multistatus,
    parse_calendar_multiget, parse_calendar_query, parse_free_busy_query,
    parse_lockinfo, parse_propfind, parse_proppatch, parse_sync_collection,
};

// ═══════════════════════════════════════════════════════════════════
// OPTIONS
// ═══════════════════════════════════════════════════════════════════

/// Handle OPTIONS request - returns DAV capabilities
pub async fn handle_options(_ctx: DavContext) -> Result<DavResponse, DavError> {
    let mut resp = DavResponse::empty(200);
    resp.headers.insert(
        "Allow".into(),
        "OPTIONS, GET, PUT, DELETE, PROPFIND, REPORT, PROPPATCH, MKCALENDAR, MKCOL, MOVE, COPY, LOCK, UNLOCK".into(),
    );
    resp.headers.insert(
        "DAV".into(),
        "1, 2, 3, calendar-access, calendar-schedule, addressbook".into(),
    );
    Ok(resp)
}

// ═══════════════════════════════════════════════════════════════════
// PROPFIND
// ═══════════════════════════════════════════════════════════════════

/// Handle PROPFIND request - query resource properties
pub async fn handle_propfind(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    let req = if ctx.body.is_empty() {
        surrealdb_core::dav::PropfindRequest {
            all_prop: true,
            prop_names: false,
            props: vec![],
        }
    } else {
        parse_propfind(&ctx.body)?
    };

    let depth = ctx.depth();

    // ACL check (read)
    if !ctx.backend.check_access(principal, &ctx.path, false).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    // Fetch resources
    let mut resources = Vec::new();

    if let Some(root) = ctx.backend.get_resource(&ctx.path).await? {
        let is_collection = matches!(
            root.kind,
            ResourceKind::Collection
                | ResourceKind::Calendar
                | ResourceKind::AddressBook
                | ResourceKind::ScheduleInbox
                | ResourceKind::ScheduleOutbox
        );
        resources.push(root.clone());

        // Fetch children if Depth != "0" and it is a collection
        if depth != "0" && is_collection {
            let children = ctx.backend.list_collection(&ctx.path).await?;
            for child in children {
                if !ctx.backend.check_access(principal, &child.path, false).await.map_err(|e| DavError::Internal(e.to_string()))? {
                    continue;
                }
                resources.push(child);
            }
        }
    } else {
        return Err(DavError::NotFound);
    }

    // Build XML responses
    let dav_resources: Vec<DavResource> = resources
        .into_iter()
        .map(|res| build_propfind_resource(&res, &req))
        .collect();

    let mut resp = DavResponse::xml(207, generate_multistatus(None, dav_resources));
    resp.headers.insert("DAV".into(), "1, 2, calendar-access, calendar-schedule".into());
    Ok(resp)
}

fn build_propfind_resource(
    res: &surrealdb_core::dav::Resource,
    req: &surrealdb_core::dav::PropfindRequest,
) -> DavResource {
    let mut properties = Vec::new();

    // Resource type
    if req.all_prop || req.props.contains(&"resourcetype".to_string()) {
        let type_str = match res.kind {
            ResourceKind::Collection => "<D:collection/>",
            ResourceKind::Calendar => {
                "<D:collection/><C:calendar xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>"
            }
            ResourceKind::AddressBook => {
                "<D:collection/><CR:addressbook xmlns:CR=\"urn:ietf:params:xml:ns:carddav\"/>"
            }
            ResourceKind::ScheduleInbox => {
                "<D:collection/><C:schedule-inbox xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>"
            }
            ResourceKind::ScheduleOutbox => {
                "<D:collection/><C:schedule-outbox xmlns:C=\"urn:ietf:params:xml:ns:caldav\"/>"
            }
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
        if req.all_prop || req.props.contains(&"sync-token".to_string()) {
            properties.push(("D:sync-token".to_string(), sync.clone()));
        }
    }

    // Custom properties
    for (key, value) in &res.properties {
        if req.all_prop || req.props.iter().any(|p| key.ends_with(p)) {
            properties.push((key.clone(), value.clone()));
        }
    }

    // Displayname fallback
    if (req.all_prop || req.props.contains(&"displayname".to_string()))
        && !res.properties.contains_key("D:displayname")
    {
        let basename = res.path.split('/').last().unwrap_or(&res.path);
        properties.push(("D:displayname".to_string(), basename.to_string()));
    }

    DavResource {
        href: res.path.clone(),
        properties,
        status: "HTTP/1.1 200 OK".to_string(),
    }
}

// ═══════════════════════════════════════════════════════════════════
// GET
// ═══════════════════════════════════════════════════════════════════

/// Handle GET request - retrieve resource content
pub async fn handle_get(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, false).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    let resource = ctx.backend.get_resource(&ctx.path).await?;
    let Some(res) = resource else {
        return Err(DavError::NotFound);
    };

    let content = res.content.ok_or(DavError::Internal("Missing resource content".into()))?;
    let content_str = String::from_utf8(content).map_err(|e| DavError::Internal(e.to_string()))?;

    let mut resp = DavResponse::ics(200, content_str, Some(res.etag.clone()));
    if !res.mime_type.is_empty() {
        resp.headers.insert("Content-Type".into(), res.mime_type);
    }
    Ok(resp)
}

// ═══════════════════════════════════════════════════════════════════
// PUT
// ═══════════════════════════════════════════════════════════════════

/// Handle PUT request - create or update resource
pub async fn handle_put(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    // Check locks
    check_locked(&ctx).await?;

    // Check preconditions
    let existing = ctx.backend.get_resource(&ctx.path).await?;
    
    if let Some(if_match) = ctx.header("if-match") {
        if existing.is_none() {
            return Err(DavError::PreconditionFailed);
        }
        let current_etag = existing.as_ref().map(|r| r.etag.as_str()).unwrap_or("");
        if !if_match.contains(current_etag) && !if_match.contains("*") {
            return Err(DavError::PreconditionFailed);
        }
    }

    if let Some(if_none_match) = ctx.header("if-none-match") {
        if existing.is_some() && if_none_match.contains("*") {
            return Err(DavError::PreconditionFailed);
        }
    }

    // Determine MIME type
    let mime = ctx
        .header("content-type")
        .map(|s| s.as_str())
        .unwrap_or("text/calendar; charset=utf-8");

    // Store resource
    let etag = ctx.backend.put_resource(&ctx.path, &ctx.body, mime).await?;

    let status = if existing.is_some() { 204 } else { 201 };

    let mut resp = DavResponse::empty(status);
    resp.headers.insert("ETag".into(), format!("\"{}\"", etag));
    Ok(resp)
}

// ═══════════════════════════════════════════════════════════════════
// DELETE
// ═══════════════════════════════════════════════════════════════════

/// Handle DELETE request - remove resource
pub async fn handle_delete(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    check_locked(&ctx).await?;

    ctx.backend.delete_resource(&ctx.path).await?;

    Ok(DavResponse::empty(204))
}

// ═══════════════════════════════════════════════════════════════════
// MKCOL / MKCALENDAR
// ═══════════════════════════════════════════════════════════════════

/// Handle MKCOL request - create collection
pub async fn handle_mkcol(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    ctx.backend.create_collection(&ctx.path, ResourceKind::Collection).await?;

    Ok(DavResponse::empty(201))
}

/// Handle MKCALENDAR request - create calendar collection
pub async fn handle_mkcalendar(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    ctx.backend.create_collection(&ctx.path, ResourceKind::Calendar).await?;
    ctx.backend.ensure_calendar_owner(&ctx.path, principal).await?;

    Ok(DavResponse::empty(201))
}

// ═══════════════════════════════════════════════════════════════════
// MOVE / COPY
// ═══════════════════════════════════════════════════════════════════

/// Handle MOVE request
pub async fn handle_move(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    let destination = ctx
        .header("destination")
        .ok_or(DavError::BadRequest("Missing Destination header".into()))?;
    
    let overwrite = ctx.header("overwrite").map(|s| s != "F").unwrap_or(true);

    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    check_locked(&ctx).await?;

    ctx.backend.move_path(&ctx.path, destination, overwrite).await?;

    Ok(DavResponse::empty(201))
}

/// Handle COPY request
pub async fn handle_copy(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    let destination = ctx
        .header("destination")
        .ok_or(DavError::BadRequest("Missing Destination header".into()))?;
    
    let overwrite = ctx.header("overwrite").map(|s| s != "F").unwrap_or(true);

    if !ctx.backend.check_access(principal, &ctx.path, false).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    ctx.backend.copy_path(&ctx.path, destination, overwrite).await?;

    Ok(DavResponse::empty(201))
}

// ═══════════════════════════════════════════════════════════════════
// LOCK / UNLOCK
// ═══════════════════════════════════════════════════════════════════

/// Handle LOCK request
pub async fn handle_lock(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    let lock_info = parse_lockinfo(&ctx.body)?;
    let depth = ctx.depth();
    let timeout: i64 = ctx
        .header("timeout")
        .and_then(|s| s.strip_prefix("Second-"))
        .and_then(|s| s.parse().ok())
        .unwrap_or(3600);

    let token = format!("opaquelocktoken:{}", uuid::Uuid::new_v4());

    ctx.backend
        .lock(&ctx.path, &token, Some(principal), depth, timeout, lock_info.owner.as_deref())
        .await?;

    let lock = Lock {
        path: ctx.path.clone(),
        token: token.clone(),
        principal: Some(principal.to_string()),
        depth: depth.to_string(),
        timeout,
        expires_at: chrono::Utc::now().timestamp() + timeout,
        owner_info: lock_info.owner,
    };

    let lock_xml = generate_lockdiscovery(&lock);
    let xml = format!(
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<D:prop xmlns:D=\"DAV:\">\n<D:lockdiscovery>{}</D:lockdiscovery>\n</D:prop>",
        lock_xml
    );

    let mut resp = DavResponse::xml(200, xml);
    resp.headers.insert("Lock-Token".into(), format!("<{}>", token));
    Ok(resp)
}

/// Handle UNLOCK request
pub async fn handle_unlock(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    let token = ctx
        .header("lock-token")
        .ok_or(DavError::BadRequest("Missing Lock-Token header".into()))?
        .trim_matches(|c| c == '<' || c == '>')
        .to_string();

    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    ctx.backend.unlock(&ctx.path, &token).await?;

    Ok(DavResponse::empty(204))
}

// ═══════════════════════════════════════════════════════════════════
// PROPPATCH
// ═══════════════════════════════════════════════════════════════════

/// Handle PROPPATCH request - modify properties
pub async fn handle_proppatch(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, true).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    let req = parse_proppatch(&ctx.body)?;

    if !req.set_props.is_empty() {
        ctx.backend.set_properties(&ctx.path, &req.set_props).await?;
    }

    if !req.remove_props.is_empty() {
        ctx.backend.remove_properties(&ctx.path, &req.remove_props).await?;
    }

    // Build response
    let mut properties = Vec::new();
    for (name, _) in &req.set_props {
        properties.push((name.clone(), String::new()));
    }
    for name in &req.remove_props {
        properties.push((name.clone(), String::new()));
    }

    let dav_resource = DavResource {
        href: ctx.path.clone(),
        properties,
        status: "HTTP/1.1 200 OK".to_string(),
    };

    Ok(DavResponse::xml(207, generate_multistatus(None, vec![dav_resource])))
}

// ═══════════════════════════════════════════════════════════════════
// REPORT
// ═══════════════════════════════════════════════════════════════════

/// Handle REPORT request - various query operations
pub async fn handle_report(ctx: DavContext) -> Result<DavResponse, DavError> {
    let principal = ctx.principal().ok_or(DavError::Unauthorized)?;
    
    if !ctx.backend.check_access(principal, &ctx.path, false).await.map_err(|e| DavError::Internal(e.to_string()))? {
        return Err(DavError::Forbidden);
    }

    let report_type = surrealdb_core::dav::xml::detect_report_type(&ctx.body)?;

    match report_type.as_str() {
        "calendar-query" => handle_calendar_query(&ctx).await,
        "calendar-multiget" => handle_calendar_multiget(&ctx).await,
        "sync-collection" => handle_sync_collection(&ctx).await,
        "free-busy-query" => handle_free_busy_query(&ctx).await,
        "addressbook-query" => handle_addressbook_query(&ctx).await,
        "addressbook-multiget" => handle_addressbook_multiget(&ctx).await,
        _ => Err(DavError::BadRequest(format!("Unknown report type: {}", report_type))),
    }
}

async fn handle_calendar_query(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let query = parse_calendar_query(&ctx.body)?;
    let resources = ctx.backend.query_collection(&ctx.path, query).await?;

    let dav_resources: Vec<DavResource> = resources
        .into_iter()
        .map(|r| DavResource {
            href: r.path,
            properties: vec![
                ("D:getetag".to_string(), format!("\"{}\"", r.etag)),
                (
                    "C:calendar-data".to_string(),
                    r.content
                        .map(|c| String::from_utf8_lossy(&c).to_string())
                        .unwrap_or_default(),
                ),
            ],
            status: "HTTP/1.1 200 OK".to_string(),
        })
        .collect();

    Ok(DavResponse::xml(207, generate_multistatus(None, dav_resources)))
}

async fn handle_calendar_multiget(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let (hrefs, _prop_req) = parse_calendar_multiget(&ctx.body)?;
    
    let mut dav_resources = Vec::new();
    for href in hrefs {
        if let Some(res) = ctx.backend.get_resource(&href).await? {
            dav_resources.push(DavResource {
                href: res.path,
                properties: vec![
                    ("D:getetag".to_string(), format!("\"{}\"", res.etag)),
                    (
                        "C:calendar-data".to_string(),
                        res.content
                            .map(|c| String::from_utf8_lossy(&c).to_string())
                            .unwrap_or_default(),
                    ),
                ],
                status: "HTTP/1.1 200 OK".to_string(),
            });
        } else {
            dav_resources.push(DavResource {
                href,
                properties: vec![],
                status: "HTTP/1.1 404 Not Found".to_string(),
            });
        }
    }

    Ok(DavResponse::xml(207, generate_multistatus(None, dav_resources)))
}

async fn handle_sync_collection(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let req = parse_sync_collection(&ctx.body)?;
    let result = ctx
        .backend
        .sync_collection(&ctx.path, req.sync_token.as_deref(), req.limit)
        .await?;

    let dav_resources: Vec<DavResource> = result
        .resources
        .into_iter()
        .map(|r| DavResource {
            href: r.path,
            properties: vec![("D:getetag".to_string(), format!("\"{}\"", r.etag))],
            status: "HTTP/1.1 200 OK".to_string(),
        })
        .collect();

    Ok(DavResponse::xml(
        207,
        generate_multistatus(Some(&result.sync_token), dav_resources),
    ))
}

async fn handle_free_busy_query(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let query = parse_free_busy_query(&ctx.body)?;
    let resources = ctx.backend.free_busy_query(&ctx.path, query).await?;

    if let Some(res) = resources.first() {
        if let Some(content) = &res.content {
            let ics = String::from_utf8_lossy(content).to_string();
            return Ok(DavResponse::ics(200, ics, None));
        }
    }

    Ok(DavResponse::empty(204))
}

async fn handle_addressbook_query(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let query = surrealdb_core::dav::xml::parse_addressbook_query(&ctx.body)?;
    let resources = ctx.backend.query_addressbook(&ctx.path, query).await?;

    let dav_resources: Vec<DavResource> = resources
        .into_iter()
        .map(|r| DavResource {
            href: r.path,
            properties: vec![
                ("D:getetag".to_string(), format!("\"{}\"", r.etag)),
                (
                    "CR:address-data".to_string(),
                    r.content
                        .map(|c| String::from_utf8_lossy(&c).to_string())
                        .unwrap_or_default(),
                ),
            ],
            status: "HTTP/1.1 200 OK".to_string(),
        })
        .collect();

    Ok(DavResponse::xml(207, generate_multistatus(None, dav_resources)))
}

async fn handle_addressbook_multiget(ctx: &DavContext) -> Result<DavResponse, DavError> {
    let (hrefs, _prop_req) = surrealdb_core::dav::xml::parse_addressbook_multiget(&ctx.body)?;
    
    let mut dav_resources = Vec::new();
    for href in hrefs {
        if let Some(res) = ctx.backend.get_resource(&href).await? {
            dav_resources.push(DavResource {
                href: res.path,
                properties: vec![
                    ("D:getetag".to_string(), format!("\"{}\"", res.etag)),
                    (
                        "CR:address-data".to_string(),
                        res.content
                            .map(|c| String::from_utf8_lossy(&c).to_string())
                            .unwrap_or_default(),
                    ),
                ],
                status: "HTTP/1.1 200 OK".to_string(),
            });
        } else {
            dav_resources.push(DavResource {
                href,
                properties: vec![],
                status: "HTTP/1.1 404 Not Found".to_string(),
            });
        }
    }

    Ok(DavResponse::xml(207, generate_multistatus(None, dav_resources)))
}

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

/// Check if resource is locked and request has valid token
async fn check_locked(ctx: &DavContext) -> Result<(), DavError> {
    let locks = ctx
        .backend
        .get_locks(&ctx.path)
        .await
        .map_err(|e| DavError::Internal(e.to_string()))?;

    if locks.is_empty() {
        return Ok(());
    }

    let if_header = ctx.header("If").cloned().unwrap_or_default();
    let now = chrono::Utc::now().timestamp();

    for lock in locks {
        if lock.expires_at < now {
            continue;
        }
        if !if_header.contains(&lock.token) {
            return Err(DavError::Locked);
        }
    }

    Ok(())
}

/// Process a DAV request and dispatch to appropriate handler
pub async fn process(ctx: DavContext) -> Result<DavResponse, DavError> {
    match ctx.method.as_str() {
        "OPTIONS" => handle_options(ctx).await,
        "PROPFIND" => handle_propfind(ctx).await,
        "PROPPATCH" => handle_proppatch(ctx).await,
        "GET" => handle_get(ctx).await,
        "PUT" => handle_put(ctx).await,
        "DELETE" => handle_delete(ctx).await,
        "MKCOL" => handle_mkcol(ctx).await,
        "MKCALENDAR" => handle_mkcalendar(ctx).await,
        "MOVE" => handle_move(ctx).await,
        "COPY" => handle_copy(ctx).await,
        "LOCK" => handle_lock(ctx).await,
        "UNLOCK" => handle_unlock(ctx).await,
        "REPORT" => handle_report(ctx).await,
        _ => Err(DavError::MethodNotAllowed),
    }
}
