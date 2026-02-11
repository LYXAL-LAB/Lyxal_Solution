//! XML Handling for DAV Protocol
//!
//! Uses `roxmltree` for fast, read-only parsing of incoming requests.
//! Uses string buffering for generating responses (to avoid heavy DOM overhead).

use crate::error::DavError;
use roxmltree::Document;

/// Parsed PROPFIND request properties
#[derive(Debug, Clone, Default)]
pub struct PropfindRequest {
    pub all_prop: bool,
    pub prop_names: bool, // <propname/> request
    pub props: Vec<String>,
}

/// Parse a raw XML body from a PROPFIND request
pub fn parse_propfind(body: &[u8]) -> Result<PropfindRequest, DavError> {
    if body.is_empty() {
        // Empty body implies allprop in WebDAV
        return Ok(PropfindRequest { all_prop: true, prop_names: false, props: vec![] });
    }

    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    
    let root = doc.root_element();
    // Verify namespace/local_name "propfind"
    if root.tag_name().name() != "propfind" {
        return Err(DavError::Internal("Root element must be propfind".into()));
    }

    let mut request = PropfindRequest { all_prop: false, prop_names: false, props: vec![] };

    for child in root.children() {
        match child.tag_name().name() {
            "allprop" => request.all_prop = true,
            "propname" => request.prop_names = true,
            "prop" => {
                for prop_node in child.children() {
                    if prop_node.is_element() {
                        request.props.push(prop_node.tag_name().name().to_string());
                    }
                }
            },
            _ => {}
        }
    }

    Ok(request)
}

/// Parse a raw XML body from a REPORT request (calendar-query)
pub fn parse_calendar_query(body: &[u8]) -> Result<crate::backend::CalendarQuery, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    
    // Naive traversal for VEVENT time-range
    // Structure: <calendar-query> <filter> <comp-filter name="VCALENDAR"> <comp-filter name="VEVENT"> <time-range start="..." end="..."/>
    
    let mut query = crate::backend::CalendarQuery { start: None, end: None };
    
    // Helper to find child by tag name ignoring namespace
    fn find_child<'a>(node: roxmltree::Node<'a, 'a>, tag: &str) -> Option<roxmltree::Node<'a, 'a>> {
        node.children().find(|n| n.is_element() && n.tag_name().name() == tag)
    }

    if let Some(filter) = find_child(root, "filter") {
        if let Some(comp_cal) = find_child(filter, "comp-filter") {
            // Should check attribute name="VCALENDAR" but optional?
            if let Some(comp_vec) = find_child(comp_cal, "comp-filter") {
                // Should check name="VEVENT"
                 if let Some(tr) = find_child(comp_vec, "time-range") {
                     if let Some(s) = tr.attribute("start") {
                         query.start = Some(s.to_string());
                     }
                     if let Some(e) = tr.attribute("end") {
                         query.end = Some(e.to_string());
                     }
                 }
            }
        }
    }
    
    Ok(query)
}

/// Parse free-busy-query request
pub fn parse_free_busy_query(body: &[u8]) -> Result<crate::backend::CalendarQuery, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    
    // Structure: <free-busy-query> <time-range start="..." end="..."/> </free-busy-query>
    
    let mut query = crate::backend::CalendarQuery { start: None, end: None };
    
    // Helper to find child by tag name ignoring namespace
    fn find_child<'a>(node: roxmltree::Node<'a, 'a>, tag: &str) -> Option<roxmltree::Node<'a, 'a>> {
        node.children().find(|n| n.is_element() && n.tag_name().name() == tag)
    }

    if let Some(tr) = find_child(root, "time-range") {
        if let Some(s) = tr.attribute("start") {
            query.start = Some(s.to_string());
        }
        if let Some(e) = tr.attribute("end") {
            query.end = Some(e.to_string());
        }
    }
    
    Ok(query)
}

/// Parse addressbook-query request
pub fn parse_addressbook_query(body: &[u8]) -> Result<crate::backend::AddressBookQuery, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    
    // Structure: <addressbook-query> <filter> <prop-filter name="..."> ...
    
    let mut query = crate::backend::AddressBookQuery { 
        filter: crate::backend::Filter { prop_filters: vec![] } 
    };
    
    // Helper to find child by tag name ignoring namespace
    fn find_child<'a>(node: roxmltree::Node<'a, 'a>, tag: &str) -> Option<roxmltree::Node<'a, 'a>> {
        node.children().find(|n| n.is_element() && n.tag_name().name() == tag)
    }

    if let Some(filter_node) = find_child(root, "filter") {
        for child in filter_node.children() {
            if !child.is_element() { continue; }
            if child.tag_name().name() == "prop-filter" {
                let name = child.attribute("name").unwrap_or("").to_string();
                let mut text_match = None;
                let mut is_not_defined = false;
                
                if let Some(tm_node) = find_child(child, "text-match") {
                    let value = tm_node.text().unwrap_or("").to_string();
                    let negate_condition = tm_node.attribute("negate-condition").map(|s| s == "yes").unwrap_or(false);
                    let collation = tm_node.attribute("collation").unwrap_or("i;ascii-casemap").to_string();
                    let match_type = tm_node.attribute("match-type").unwrap_or("contains").to_string();
                    
                    text_match = Some(crate::backend::TextMatch {
                        value,
                        negate_condition,
                        collation,
                        match_type,
                    });
                }
                
                if find_child(child, "is-not-defined").is_some() {
                    is_not_defined = true;
                }
                
                query.filter.prop_filters.push(crate::backend::PropFilter {
                    name,
                    text_match,
                    is_not_defined,
                });
            }
        }
    }
    
    Ok(query)
}

/// Detect the type of REPORT request
pub fn detect_report_type(body: &[u8]) -> Result<String, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    Ok(doc.root_element().tag_name().name().to_string())
}

/// Parse a raw XML body from a REPORT request (calendar-multiget)
pub fn parse_calendar_multiget(body: &[u8]) -> Result<(Vec<String>, PropfindRequest), DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    
    let mut hrefs = Vec::new();
    let mut request = PropfindRequest { all_prop: false, prop_names: false, props: vec![] };

    for child in root.children() {
        if !child.is_element() { continue; }
        
        match child.tag_name().name() {
            "href" => {
                if let Some(text) = child.text() {
                    hrefs.push(text.to_string());
                }
            },
            "allprop" => request.all_prop = true,
            "propname" => request.prop_names = true,
            "prop" => {
                for prop_node in child.children() {
                    if prop_node.is_element() {
                        request.props.push(prop_node.tag_name().name().to_string());
                    }
                }
            },
            _ => {}
        }
    }
    
    Ok((hrefs, request))
}

/// Parse a raw XML body from a REPORT request (addressbook-multiget)
pub fn parse_addressbook_multiget(body: &[u8]) -> Result<(Vec<String>, PropfindRequest), DavError> {
    parse_calendar_multiget(body) // Structure is identical: hrefs + prop
}

#[derive(Debug, Clone, Default)]
pub struct PropPatchRequest {
	pub set_props: Vec<(String, String)>,
	pub remove_props: Vec<String>,
}

fn tag_name_with_prefix(node: roxmltree::Node<'_, '_>) -> String {
	node.tag_name().name().to_string()
}

/// Parse PROPPATCH body (set/remove)
pub fn parse_proppatch(body: &[u8]) -> Result<PropPatchRequest, DavError> {
	if body.is_empty() {
		return Err(DavError::BadRequest("Empty PROPPATCH body".into()));
	}
	let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
	let doc = Document::parse(text)?;
	let root = doc.root_element();
	if root.tag_name().name() != "propertyupdate" {
		return Err(DavError::BadRequest("Root element must be propertyupdate".into()));
	}

	let mut req = PropPatchRequest::default();
	for child in root.children().filter(|n| n.is_element()) {
		match child.tag_name().name() {
			"set" => {
				if let Some(prop_node) = child.children().find(|n| n.is_element() && n.tag_name().name() == "prop") {
					for p in prop_node.children().filter(|n| n.is_element()) {
						let name = tag_name_with_prefix(p);
						let val = p.text().unwrap_or("").to_string();
						req.set_props.push((name, val));
					}
				}
			}
			"remove" => {
				if let Some(prop_node) = child.children().find(|n| n.is_element() && n.tag_name().name() == "prop") {
					for p in prop_node.children().filter(|n| n.is_element()) {
						let name = tag_name_with_prefix(p);
						req.remove_props.push(name);
					}
				}
			}
			_ => {}
		}
	}

	Ok(req)
}

/// Parsed sync-collection request.
#[derive(Debug, Clone, Default)]
pub struct SyncCollectionRequest {
    pub sync_token: Option<String>,
    pub limit: Option<usize>,
    pub prop: PropfindRequest,
}

/// Parse sync-collection REPORT body (CalDAV incremental sync).
pub fn parse_sync_collection(body: &[u8]) -> Result<SyncCollectionRequest, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();

    if root.tag_name().name() != "sync-collection" {
        return Err(DavError::Internal("Root element must be sync-collection".into()));
    }

    let mut req = SyncCollectionRequest {
        sync_token: None,
        limit: None,
        prop: PropfindRequest { all_prop: false, prop_names: false, props: vec![] },
    };

    for child in root.children() {
        if !child.is_element() {
            continue;
        }
        match child.tag_name().name() {
            "sync-token" => {
                if let Some(t) = child.text() {
                    req.sync_token = Some(t.to_string());
                }
            }
            "limit" => {
                for l in child.children().filter(|n| n.is_element()) {
                    if l.tag_name().name() == "nresults" {
                        if let Some(t) = l.text() {
                            if let Ok(v) = t.trim().parse::<usize>() {
                                req.limit = Some(v);
                            }
                        }
                    }
                }
            }
            "prop" => {
                for prop_node in child.children() {
                    if prop_node.is_element() {
                        req.prop.props.push(prop_node.tag_name().name().to_string());
                    }
                }
            }
            "allprop" => req.prop.all_prop = true,
            "propname" => req.prop.prop_names = true,
            _ => {}
        }
    }

    // Si aucune prop demandée, on considère allprop par défaut (calendars, compat Apple)
    if !req.prop.all_prop && req.prop.props.is_empty() && !req.prop.prop_names {
        req.prop.all_prop = true;
    }

    Ok(req)
}

/// Parse LOCK request info
#[derive(Debug, Clone, Default)]
pub struct LockInfo {
    pub owner: Option<String>,
}

pub fn parse_lockinfo(body: &[u8]) -> Result<LockInfo, DavError> {
    if body.is_empty() {
        return Ok(LockInfo::default());
    }
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    // root should be lockinfo, but some clients might send something else? RFC 4918 says lockinfo.
    
    let mut info = LockInfo::default();
    
    if let Some(owner) = root.children().find(|n| n.is_element() && n.tag_name().name() == "owner") {
        // preserve XML structure of owner
        // roxmltree doesn't easily give back the raw XML of a node range.
        // We might just take text content if simple, or reconstruct.
        // For Apple/Finder compatibility, they might send <href>...</href>.
        // We'll reconstruct a simple XML string of children.
        let mut owner_xml = String::new();
        for child in owner.children() {
            if child.is_element() {
                // Very naive reconstruction
                let name = child.tag_name().name();
                let text = child.text().unwrap_or("");
                owner_xml.push_str(&format!("<D:{}>{}</D:{}>", name, text, name));
            } else if child.is_text() {
                owner_xml.push_str(child.text().unwrap_or(""));
            }
        }
        info.owner = Some(owner_xml);
    }
    
    Ok(info)
}

/// A DAV Resource to be included in the response
pub struct DavResource {
    pub href: String,
    pub properties: Vec<(String, String)>, // (Name, Value)
    pub status: String, // e.g. "HTTP/1.1 200 OK"
}

/// Generate a WebDAV multistatus XML response (optionally with sync-token)
pub fn generate_multistatus(sync_token: Option<&str>, resources: Vec<DavResource>) -> String {
    let mut xml = String::with_capacity(1024);
    xml.push_str("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n");
    xml.push_str("<D:multistatus xmlns:D=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\" xmlns:CS=\"http://calendarserver.org/ns/\">\n");

    if let Some(token) = sync_token {
        xml.push_str(&format!("  <D:sync-token>{}</D:sync-token>\n", token));
    }

    for res in resources {
        xml.push_str("  <D:response>\n");
        xml.push_str(&format!("    <D:href>{}</D:href>\n", res.href));
        
        xml.push_str("    <D:propstat>\n");
        xml.push_str("      <D:prop>\n");
        
        for (name, value) in res.properties {
            if value.is_empty() {
                xml.push_str(&format!("        <{0}/>\n", name));
            } else {
                xml.push_str(&format!("        <{0}>{1}</{0}>\n", name, value));
            }
        }
        
        xml.push_str("      </D:prop>\n");
        xml.push_str(&format!("      <D:status>{}</D:status>\n", res.status));
        xml.push_str("    </D:propstat>\n");
        xml.push_str("  </D:response>\n");
    }

    xml.push_str("</D:multistatus>");
    xml
}

pub fn generate_lockdiscovery(lock: &crate::backend::Lock) -> String {
    let mut xml = String::new();
    xml.push_str("<D:activelock>\n");
    xml.push_str("  <D:locktype><D:write/></D:locktype>\n");
    xml.push_str("  <D:lockscope><D:exclusive/></D:lockscope>\n");
    xml.push_str(&format!("  <D:depth>{}</D:depth>\n", lock.depth));
    if let Some(owner) = &lock.owner_info {
        xml.push_str(&format!("  <D:owner>{}</D:owner>\n", owner));
    }
    xml.push_str(&format!("  <D:timeout>Second-{}</D:timeout>\n", lock.timeout));
    xml.push_str(&format!("  <D:locktoken><D:href>{}</D:href></D:locktoken>\n", lock.token));
    xml.push_str("  <D:lockroot><D:href/></D:lockroot>\n"); // optional
    xml.push_str("</D:activelock>\n");
    xml
}
