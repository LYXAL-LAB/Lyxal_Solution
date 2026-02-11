//! PDF Outlines, Bookmarks, Attachments, Destinations, and Structure Tree extraction
//!
//! This module extracts:
//! - Bookmarks (Table of Contents / Outlines)
//! - Embedded file attachments
//! - Named destinations for internal navigation
//! - Structure tree for tagged PDFs

use lopdf::{Document, Object, ObjectId, Dictionary};
use std::collections::HashMap;

use super::model::{
    PdfBookmark, PdfAttachment, PdfNamedDestination, PdfDestinationType,
    PdfStructureTree, PdfStructureElement, PdfStructureType,
};

// ============================================================================
// BOOKMARKS / TABLE DES MATIÈRES
// ============================================================================

/// Parse all bookmarks (outlines) from the document
pub fn parse_bookmarks(doc: &Document) -> Vec<PdfBookmark> {
    let mut bookmarks = Vec::new();
    
    // Get Outlines dictionary from catalog
    let catalog = match doc.catalog() {
        Ok(c) => c,
        Err(_) => return bookmarks,
    };
    
    let outlines_ref = match catalog.get(b"Outlines") {
        Ok(Object::Reference(r)) => *r,
        _ => return bookmarks,
    };
    
    let outlines_dict = match doc.get_dictionary(outlines_ref) {
        Ok(d) => d,
        Err(_) => return bookmarks,
    };
    
    // Get first outline item
    let first_ref = match outlines_dict.get(b"First") {
        Ok(Object::Reference(r)) => *r,
        _ => return bookmarks,
    };
    
    // Build page index map for resolving destinations
    let page_map = build_page_map(doc);
    
    // Parse outline tree recursively
    parse_outline_item(doc, first_ref, &page_map, 0, &mut bookmarks);
    
    bookmarks
}

fn parse_outline_item(
    doc: &Document,
    item_id: ObjectId,
    page_map: &HashMap<ObjectId, usize>,
    level: usize,
    output: &mut Vec<PdfBookmark>,
) {
    let item_dict = match doc.get_dictionary(item_id) {
        Ok(d) => d,
        Err(_) => return,
    };
    
    // Get title
    let title = item_dict.get(b"Title")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s))
        .unwrap_or_default();
    
    // Parse destination
    let (page_index, y_position, named_dest) = parse_destination(doc, item_dict, page_map);
    
    // Check for URI action
    let uri = parse_uri_action(doc, item_dict);
    
    // Check open/closed state
    let count = item_dict.get(b"Count")
        .ok()
        .and_then(|o| o.as_i64().ok())
        .unwrap_or(0);
    let is_open = count > 0;
    
    // Parse children
    let mut children = Vec::new();
    if let Ok(Object::Reference(first_child)) = item_dict.get(b"First") {
        parse_outline_item(doc, *first_child, page_map, level + 1, &mut children);
    }
    
    let bookmark = PdfBookmark {
        title,
        page_index,
        y_position,
        named_dest,
        uri,
        children,
        level,
        is_open,
    };
    
    output.push(bookmark);
    
    // Parse next sibling
    if let Ok(Object::Reference(next)) = item_dict.get(b"Next") {
        parse_outline_item(doc, *next, page_map, level, output);
    }
}

fn parse_destination(
    doc: &Document,
    item_dict: &Dictionary,
    page_map: &HashMap<ObjectId, usize>,
) -> (Option<usize>, Option<f32>, Option<String>) {
    // Try direct Dest
    if let Ok(dest) = item_dict.get(b"Dest") {
        return resolve_destination(doc, dest, page_map);
    }
    
    // Try Action with GoTo
    if let Ok(Object::Reference(action_ref)) = item_dict.get(b"A") {
        if let Ok(action_dict) = doc.get_dictionary(*action_ref) {
            if let Ok(Object::Name(s)) = action_dict.get(b"S") {
                if s == b"GoTo" {
                    if let Ok(dest) = action_dict.get(b"D") {
                        return resolve_destination(doc, dest, page_map);
                    }
                }
            }
        }
    } else if let Ok(Object::Dictionary(action_dict)) = item_dict.get(b"A") {
        if let Ok(Object::Name(s)) = action_dict.get(b"S") {
            if s == b"GoTo" {
                if let Ok(dest) = action_dict.get(b"D") {
                    return resolve_destination(doc, dest, page_map);
                }
            }
        }
    }
    
    (None, None, None)
}

fn resolve_destination(
    doc: &Document,
    dest: &Object,
    page_map: &HashMap<ObjectId, usize>,
) -> (Option<usize>, Option<f32>, Option<String>) {
    match dest {
        Object::Array(arr) => {
            // Direct destination array: [page /XYZ left top zoom]
            if let Some(page_obj) = arr.first() {
                let page_index = match page_obj {
                    Object::Reference(r) => page_map.get(r).copied(),
                    _ => None,
                };
                
                // Get Y position if /XYZ
                let y_pos = if arr.len() >= 4 {
                    arr.get(3).and_then(|o| match o {
                        Object::Integer(i) => Some(*i as f32),
                        Object::Real(r) => Some(*r),
                        _ => None,
                    })
                } else {
                    None
                };
                
                return (page_index, y_pos, None);
            }
        }
        Object::String(s, _) | Object::Name(s) => {
            // Named destination
            let name = String::from_utf8_lossy(s).to_string();
            return (None, None, Some(name));
        }
        Object::Reference(r) => {
            // Resolve reference
            if let Ok(obj) = doc.get_object(*r) {
                return resolve_destination(doc, obj, page_map);
            }
        }
        _ => {}
    }
    
    (None, None, None)
}

fn parse_uri_action(doc: &Document, item_dict: &Dictionary) -> Option<String> {
    let action = match item_dict.get(b"A") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok()?,
        Ok(Object::Dictionary(d)) => d,
        _ => return None,
    };
    
    let action_type = action.get(b"S").ok()?.as_name().ok()?;
    if action_type != b"URI" {
        return None;
    }
    
    action.get(b"URI")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| String::from_utf8_lossy(s).to_string())
}

// ============================================================================
// PIÈCES JOINTES (ATTACHMENTS)
// ============================================================================

/// Parse all embedded file attachments
pub fn parse_attachments(doc: &Document) -> Vec<PdfAttachment> {
    let mut attachments = Vec::new();
    
    // Get Names dictionary from catalog
    let catalog = match doc.catalog() {
        Ok(c) => c,
        Err(_) => return attachments,
    };
    
    let names_dict = match get_names_dict(doc, catalog) {
        Some(d) => d,
        None => return attachments,
    };
    
    // Get EmbeddedFiles name tree
    let ef_tree = match names_dict.get(b"EmbeddedFiles") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok(),
        Ok(Object::Dictionary(d)) => Some(d),
        _ => None,
    };
    
    if let Some(tree) = ef_tree {
        parse_name_tree(doc, tree, &mut |name, obj| {
            if let Some(attachment) = parse_file_spec(doc, obj, &name) {
                attachments.push(attachment);
            }
        });
    }
    
    attachments
}

fn get_names_dict<'a>(doc: &'a Document, catalog: &'a Dictionary) -> Option<&'a Dictionary> {
    match catalog.get(b"Names") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok(),
        Ok(Object::Dictionary(d)) => Some(d),
        _ => None,
    }
}

fn parse_name_tree<F>(doc: &Document, tree: &Dictionary, callback: &mut F)
where
    F: FnMut(String, &Object),
{
    // Check for Names array (leaf node)
    if let Ok(Object::Array(names)) = tree.get(b"Names") {
        let mut i = 0;
        while i + 1 < names.len() {
            let name = match &names[i] {
                Object::String(s, _) => String::from_utf8_lossy(s).to_string(),
                _ => { i += 2; continue; }
            };
            callback(name, &names[i + 1]);
            i += 2;
        }
    }
    
    // Check for Kids array (intermediate node)
    if let Ok(Object::Array(kids)) = tree.get(b"Kids") {
        for kid in kids {
            if let Object::Reference(r) = kid {
                if let Ok(kid_dict) = doc.get_dictionary(*r) {
                    parse_name_tree(doc, kid_dict, callback);
                }
            }
        }
    }
}

fn parse_file_spec(doc: &Document, obj: &Object, filename: &str) -> Option<PdfAttachment> {
    let file_spec = match obj {
        Object::Reference(r) => doc.get_dictionary(*r).ok()?,
        Object::Dictionary(d) => d,
        _ => return None,
    };
    
    // Get embedded file stream
    let ef_dict = match file_spec.get(b"EF") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok()?,
        Ok(Object::Dictionary(d)) => d,
        _ => return None,
    };
    
    // Prefer /UF (Unicode filename) then /F
    let stream_ref = ef_dict.get(b"UF")
        .or_else(|_| ef_dict.get(b"F"))
        .ok()?
        .as_reference()
        .ok()?;
    
    let stream = doc.get_object(stream_ref).ok()?;
    let stream_obj = match stream {
        Object::Stream(s) => s,
        _ => return None,
    };
    
    // Decode stream - try to decompress if filtered
    let decoded_data = stream_obj.decompressed_content().ok()
        .unwrap_or_else(|| stream_obj.content.clone());
    
    let stream_dict = &stream_obj.dict;
    
    // Get file metadata
    let description = file_spec.get(b"Desc")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    let mime_type = stream_dict.get(b"Subtype")
        .ok()
        .and_then(|o| o.as_name().ok())
        .map(|s| String::from_utf8_lossy(s).to_string());
    
    // Get params dictionary for dates/size
    let params = stream_dict.get(b"Params")
        .ok()
        .and_then(|o| match o {
            Object::Dictionary(d) => Some(d),
            Object::Reference(r) => doc.get_dictionary(*r).ok(),
            _ => None,
        });
    
    let (creation_date, modification_date, checksum) = if let Some(p) = params {
        (
            p.get(b"CreationDate").ok().and_then(|o| o.as_str().ok()).map(|s| decode_pdf_string(s)),
            p.get(b"ModDate").ok().and_then(|o| o.as_str().ok()).map(|s| decode_pdf_string(s)),
            p.get(b"CheckSum").ok().and_then(|o| o.as_str().ok()).map(|s| hex::encode(s)),
        )
    } else {
        (None, None, None)
    };
    
    Some(PdfAttachment {
        filename: filename.to_string(),
        description,
        mime_type,
        creation_date,
        modification_date,
        size: decoded_data.len(),
        data: decoded_data,
        checksum,
    })
}

// ============================================================================
// DESTINATIONS NOMMÉES
// ============================================================================

/// Parse all named destinations
pub fn parse_named_destinations(doc: &Document) -> Vec<PdfNamedDestination> {
    let mut destinations = Vec::new();
    let page_map = build_page_map(doc);
    
    let catalog = match doc.catalog() {
        Ok(c) => c,
        Err(_) => return destinations,
    };
    
    // Try Names/Dests name tree (PDF 1.2+)
    if let Some(names_dict) = get_names_dict(doc, catalog) {
        if let Ok(dests_tree) = names_dict.get(b"Dests") {
            let tree = match dests_tree {
                Object::Reference(r) => doc.get_dictionary(*r).ok(),
                Object::Dictionary(d) => Some(d),
                _ => None,
            };
            
            if let Some(tree) = tree {
                parse_name_tree(doc, tree, &mut |name, obj| {
                    if let Some(dest) = parse_destination_object(doc, &name, obj, &page_map) {
                        destinations.push(dest);
                    }
                });
            }
        }
    }
    
    // Try Dests dictionary (legacy PDF 1.1)
    if let Ok(Object::Reference(dests_ref)) = catalog.get(b"Dests") {
        if let Ok(dests_dict) = doc.get_dictionary(*dests_ref) {
            for (name_bytes, value) in dests_dict.iter() {
                let name = String::from_utf8_lossy(name_bytes).to_string();
                if let Some(dest) = parse_destination_object(doc, &name, value, &page_map) {
                    destinations.push(dest);
                }
            }
        }
    }
    
    destinations
}

fn parse_destination_object(
    doc: &Document,
    name: &str,
    obj: &Object,
    page_map: &HashMap<ObjectId, usize>,
) -> Option<PdfNamedDestination> {
    let arr = match obj {
        Object::Array(a) => a.clone(),
        Object::Reference(r) => {
            match doc.get_object(*r).ok()? {
                Object::Array(a) => a.clone(),
                Object::Dictionary(d) => {
                    // Destination dictionary with /D key
                    d.get(b"D").ok()?.as_array().ok()?.clone()
                }
                _ => return None,
            }
        }
        Object::Dictionary(d) => {
            d.get(b"D").ok()?.as_array().ok()?.clone()
        }
        _ => return None,
    };
    
    if arr.is_empty() {
        return None;
    }
    
    // First element is page reference
    let page_index = match &arr[0] {
        Object::Reference(r) => page_map.get(r).copied()?,
        Object::Integer(i) => *i as usize,
        _ => return None,
    };
    
    // Second element is destination type
    let dest_type_name = arr.get(1)?.as_name().ok()?;
    
    let (dest_type, left, top, right, bottom, zoom) = match dest_type_name {
        b"XYZ" => (
            PdfDestinationType::XYZ,
            get_coord(&arr, 2),
            get_coord(&arr, 3),
            None,
            None,
            get_coord(&arr, 4),
        ),
        b"Fit" => (PdfDestinationType::Fit, None, None, None, None, None),
        b"FitH" => (PdfDestinationType::FitH, None, get_coord(&arr, 2), None, None, None),
        b"FitV" => (PdfDestinationType::FitV, get_coord(&arr, 2), None, None, None, None),
        b"FitR" => (
            PdfDestinationType::FitR,
            get_coord(&arr, 2),
            get_coord(&arr, 5),
            get_coord(&arr, 4),
            get_coord(&arr, 3),
            None,
        ),
        b"FitB" => (PdfDestinationType::FitB, None, None, None, None, None),
        b"FitBH" => (PdfDestinationType::FitBH, None, get_coord(&arr, 2), None, None, None),
        b"FitBV" => (PdfDestinationType::FitBV, get_coord(&arr, 2), None, None, None, None),
        _ => return None,
    };
    
    Some(PdfNamedDestination {
        name: name.to_string(),
        page_index,
        dest_type,
        left,
        top,
        right,
        bottom,
        zoom,
    })
}

fn get_coord(arr: &[Object], index: usize) -> Option<f32> {
    arr.get(index).and_then(|o| match o {
        Object::Integer(i) => Some(*i as f32),
        Object::Real(r) => Some(*r),
        Object::Null => None,
        _ => None,
    })
}

// ============================================================================
// STRUCTURE TREE (PDF BALISÉ)
// ============================================================================

/// Parse the document structure tree (tagged PDF)
pub fn parse_structure_tree(doc: &Document) -> Option<PdfStructureTree> {
    let catalog = doc.catalog().ok()?;
    
    let struct_tree_root = match catalog.get(b"StructTreeRoot") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok()?,
        Ok(Object::Dictionary(d)) => d,
        _ => return None,
    };
    
    // Parse role map
    let role_map = parse_role_map(doc, struct_tree_root);
    
    // Parse structure elements
    let children = parse_struct_kids(doc, struct_tree_root);
    
    Some(PdfStructureTree { children, role_map })
}

fn parse_role_map(doc: &Document, tree_root: &Dictionary) -> Vec<(String, String)> {
    let mut mappings = Vec::new();
    
    let role_map = match tree_root.get(b"RoleMap") {
        Ok(Object::Reference(r)) => doc.get_dictionary(*r).ok(),
        Ok(Object::Dictionary(d)) => Some(d),
        _ => return mappings,
    };
    
    if let Some(rm) = role_map {
        for (key, value) in rm.iter() {
            let custom_role = String::from_utf8_lossy(key).to_string();
            let standard_role = match value {
                Object::Name(n) => String::from_utf8_lossy(n).to_string(),
                _ => continue,
            };
            mappings.push((custom_role, standard_role));
        }
    }
    
    mappings
}

fn parse_struct_kids(doc: &Document, parent: &Dictionary) -> Vec<PdfStructureElement> {
    let mut elements = Vec::new();
    
    let kids = match parent.get(b"K") {
        Ok(Object::Array(arr)) => arr.clone(),
        Ok(Object::Reference(r)) => {
            if let Ok(elem) = parse_struct_element(doc, *r) {
                return vec![elem];
            }
            return elements;
        }
        Ok(Object::Integer(_)) => return elements, // MCIDs, skip
        _ => return elements,
    };
    
    for kid in kids {
        match kid {
            Object::Reference(r) => {
                if let Ok(elem) = parse_struct_element(doc, r) {
                    elements.push(elem);
                }
            }
            Object::Dictionary(d) => {
                // Inline structure element
                if let Some(elem) = parse_struct_dict(doc, &d) {
                    elements.push(elem);
                }
            }
            _ => {} // MCID or other, skip
        }
    }
    
    elements
}

fn parse_struct_element(doc: &Document, id: ObjectId) -> Result<PdfStructureElement, ()> {
    let dict = doc.get_dictionary(id).map_err(|_| ())?;
    parse_struct_dict(doc, dict).ok_or(())
}

fn parse_struct_dict(doc: &Document, dict: &Dictionary) -> Option<PdfStructureElement> {
    // Get structure type
    let type_name = dict.get(b"S").ok()?.as_name().ok()?;
    let struct_type = parse_struct_type(type_name);
    
    // Get optional attributes
    let title = dict.get(b"T")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    let alt_text = dict.get(b"Alt")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    let actual_text = dict.get(b"ActualText")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    let lang = dict.get(b"Lang")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    let id = dict.get(b"ID")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| decode_pdf_string(s));
    
    // Parse attributes
    let attributes = parse_struct_attributes(doc, dict);
    
    // Parse children
    let children = parse_struct_kids(doc, dict);
    
    // Get page indices (from Pg reference)
    let page_indices = Vec::new(); // TODO: collect from MCID references
    
    Some(PdfStructureElement {
        struct_type,
        title,
        alt_text,
        lang,
        id,
        actual_text,
        page_indices,
        children,
        attributes,
    })
}

fn parse_struct_type(name: &[u8]) -> PdfStructureType {
    match name {
        b"Document" => PdfStructureType::Document,
        b"Part" => PdfStructureType::Part,
        b"Art" => PdfStructureType::Art,
        b"Sect" => PdfStructureType::Sect,
        b"Div" => PdfStructureType::Div,
        b"H" => PdfStructureType::H,
        b"H1" => PdfStructureType::H1,
        b"H2" => PdfStructureType::H2,
        b"H3" => PdfStructureType::H3,
        b"H4" => PdfStructureType::H4,
        b"H5" => PdfStructureType::H5,
        b"H6" => PdfStructureType::H6,
        b"P" => PdfStructureType::P,
        b"L" => PdfStructureType::L,
        b"LI" => PdfStructureType::LI,
        b"Lbl" => PdfStructureType::Lbl,
        b"LBody" => PdfStructureType::LBody,
        b"Table" => PdfStructureType::Table,
        b"TR" => PdfStructureType::TR,
        b"TH" => PdfStructureType::TH,
        b"TD" => PdfStructureType::TD,
        b"THead" => PdfStructureType::THead,
        b"TBody" => PdfStructureType::TBody,
        b"TFoot" => PdfStructureType::TFoot,
        b"Span" => PdfStructureType::Span,
        b"Quote" => PdfStructureType::Quote,
        b"Note" => PdfStructureType::Note,
        b"Reference" => PdfStructureType::Reference,
        b"BibEntry" => PdfStructureType::BibEntry,
        b"Code" => PdfStructureType::Code,
        b"Figure" => PdfStructureType::Figure,
        b"Formula" => PdfStructureType::Formula,
        b"Form" => PdfStructureType::Form,
        b"Link" => PdfStructureType::Link,
        b"Annot" => PdfStructureType::Annot,
        b"Ruby" => PdfStructureType::Ruby,
        b"Warichu" => PdfStructureType::Warichu,
        other => PdfStructureType::Other(String::from_utf8_lossy(other).to_string()),
    }
}

fn parse_struct_attributes(doc: &Document, dict: &Dictionary) -> Vec<(String, String)> {
    let mut attrs = Vec::new();
    
    let attr_obj = match dict.get(b"A") {
        Ok(obj) => obj,
        Err(_) => return attrs,
    };
    
    let attr_dicts: Vec<&Dictionary> = match attr_obj {
        Object::Dictionary(d) => vec![d],
        Object::Array(arr) => arr.iter()
            .filter_map(|o| match o {
                Object::Dictionary(d) => Some(d),
                Object::Reference(r) => doc.get_dictionary(*r).ok(),
                _ => None,
            })
            .collect(),
        Object::Reference(r) => {
            if let Ok(d) = doc.get_dictionary(*r) {
                vec![d]
            } else {
                vec![]
            }
        }
        _ => vec![],
    };
    
    for attr_dict in attr_dicts {
        for (key, value) in attr_dict.iter() {
            let key_str = String::from_utf8_lossy(key).to_string();
            if key_str == "O" { continue; } // Skip owner
            
            let value_str = match value {
                Object::String(s, _) => decode_pdf_string(s),
                Object::Name(n) => String::from_utf8_lossy(n).to_string(),
                Object::Integer(i) => i.to_string(),
                Object::Real(r) => r.to_string(),
                Object::Boolean(b) => b.to_string(),
                _ => continue,
            };
            
            attrs.push((key_str, value_str));
        }
    }
    
    attrs
}

// ============================================================================
// UTILITAIRES
// ============================================================================

fn build_page_map(doc: &Document) -> HashMap<ObjectId, usize> {
    let mut map = HashMap::new();
    for (page_num, page_id) in doc.get_pages() {
        map.insert(page_id, (page_num - 1) as usize);
    }
    map
}

fn decode_pdf_string(bytes: &[u8]) -> String {
    // Check for UTF-16 BOM
    if bytes.len() >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF {
        // UTF-16 BE
        let u16_chars: Vec<u16> = bytes[2..]
            .chunks(2)
            .filter_map(|chunk| {
                if chunk.len() == 2 {
                    Some(u16::from_be_bytes([chunk[0], chunk[1]]))
                } else {
                    None
                }
            })
            .collect();
        String::from_utf16_lossy(&u16_chars)
    } else {
        // PDFDocEncoding or ASCII
        String::from_utf8_lossy(bytes).to_string()
    }
}
