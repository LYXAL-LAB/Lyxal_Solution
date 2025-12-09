//! XML Handling for DAV Protocol
//!
//! Uses `roxmltree` for fast, read-only parsing of incoming requests.
//! Uses string buffering for generating responses (to avoid heavy DOM overhead).

use crate::error::DavError;
use roxmltree::Document;

/// Parsed PROPFIND request properties
#[derive(Debug)]
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

/// Detect the type of REPORT request
pub fn detect_report_type(body: &[u8]) -> Result<String, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    Ok(doc.root_element().tag_name().name().to_string())
}

/// Parse a raw XML body from a REPORT request (calendar-multiget)
pub fn parse_calendar_multiget(body: &[u8]) -> Result<Vec<String>, DavError> {
    let text = std::str::from_utf8(body).map_err(|e| DavError::Internal(e.to_string()))?;
    let doc = Document::parse(text)?;
    let root = doc.root_element();
    
    let mut hrefs = Vec::new();
    for child in root.children() {
        if child.is_element() && child.tag_name().name() == "href" {
             if let Some(text) = child.text() {
                 hrefs.push(text.to_string());
             }
        }
    }
    
    Ok(hrefs)
}

/// A DAV Resource to be included in the response
pub struct DavResource {
    pub href: String,
    pub properties: Vec<(String, String)>, // (Name, Value)
    pub status: String, // e.g. "HTTP/1.1 200 OK"
}

/// Generate a WebDAV multistatus XML response
pub fn generate_multistatus(resources: Vec<DavResource>) -> String {
    let mut xml = String::with_capacity(1024);
    xml.push_str("<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n");
    xml.push_str("<D:multistatus xmlns:D=\"DAV:\" xmlns:C=\"urn:ietf:params:xml:ns:caldav\" xmlns:CS=\"http://calendarserver.org/ns/\">\n");

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
