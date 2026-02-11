//! PDF Annotations parsing

use super::model::{PdfAnnotation, PdfAnnotationType};
use crate::parser::pdf::common::PdfBBox;
use lopdf::{Document, Object};
use std::collections::HashMap;

pub fn parse_annotations(doc: &Document) -> Vec<PdfAnnotation> {
    let mut annotations = Vec::new();
    let page_map = build_page_map(doc);

    for (page_num, page_id) in doc.get_pages() {
        let page_index = (page_num - 1) as usize;
        
        let page_dict = match doc.get_object(page_id) {
            Ok(Object::Dictionary(d)) => d,
            _ => continue,
        };

        if let Ok(Object::Array(annots_ref)) = page_dict.get(b"Annots") {
            for annot_obj in annots_ref {
                let annot_dict = match resolve_object(doc, annot_obj) {
                    Ok(Object::Dictionary(d)) => d,
                    _ => continue,
                };

                let subtype = match annot_dict.get(b"Subtype").and_then(|o| o.as_name()) {
                    Ok(b"Link") => PdfAnnotationType::Link,
                    Ok(b"Text") => PdfAnnotationType::Text,
                    Ok(b"Highlight") => PdfAnnotationType::Highlight,
                    Ok(b"Underline") => PdfAnnotationType::Underline,
                    _ => continue,
                };

                let rect = match annot_dict.get(b"Rect") {
                    Ok(obj) => parse_rect(obj),
                    Err(_) => continue,
                };
                
                let rect = match rect {
                    Some(r) => r,
                    None => continue,
                };

                let mut contents = None;
                let mut target = None;
                let mut quads = None;

                match subtype {
                    PdfAnnotationType::Link => {
                        if let Ok(Object::Dictionary(action)) = annot_dict.get(b"A").and_then(|o| resolve_object(doc, o)) {
                            let s = action.get(b"S").and_then(|o| o.as_name()).unwrap_or(b"");
                            if s == b"URI" {
                                if let Ok(obj) = action.get(b"URI") {
                                    if let Ok(uri) = text_from_object(obj) {
                                        target = Some(uri);
                                    }
                                }
                            } else if s == b"GoTo" {
                                if let Ok(d) = action.get(b"D") {
                                    target = resolve_destination(doc, d, &page_map);
                                }
                            }
                        } else if let Ok(dest) = annot_dict.get(b"Dest") {
                             target = resolve_destination(doc, dest, &page_map);
                        }
                    },
                    PdfAnnotationType::Text => {
                        if let Ok(obj) = annot_dict.get(b"Contents") {
                             if let Ok(c) = text_from_object(obj) {
                                 contents = Some(c);
                             }
                        }
                    },
                    PdfAnnotationType::Highlight | PdfAnnotationType::Underline => {
                         if let Ok(qp) = annot_dict.get(b"QuadPoints") {
                             quads = parse_quadpoints(qp);
                         }
                    }
                }

                annotations.push(PdfAnnotation {
                    annot_type: subtype,
                    rect,
                    contents,
                    target,
                    quads,
                    page_index,
                });
            }
        }
    }

    annotations
}

fn build_page_map(doc: &Document) -> HashMap<(u32, u16), usize> {
    let mut map = HashMap::new();
    for (page_num, page_id) in doc.get_pages() {
        map.insert(page_id, (page_num - 1) as usize);
    }
    map
}

fn resolve_object<'a>(doc: &'a Document, obj: &'a Object) -> Result<&'a Object, lopdf::Error> {
    match obj {
        Object::Reference(id) => doc.get_object(*id),
        _ => Ok(obj),
    }
}

fn resolve_destination(doc: &Document, dest_obj: &Object, page_map: &HashMap<(u32, u16), usize>) -> Option<String> {
    let resolved = resolve_object(doc, dest_obj).ok()?;
    
    match resolved {
        Object::String(bytes, _) | Object::Name(bytes) => {
             Some(String::from_utf8_lossy(bytes).into_owned())
        },
        Object::Array(arr) => {
             if let Some(Object::Reference(page_ref)) = arr.get(0) {
                  if let Some(idx) = page_map.get(page_ref) {
                      return Some(format!("Page {}", idx + 1));
                  }
             }
             None
        },
        _ => None
    }
}

fn parse_rect(obj: &Object) -> Option<PdfBBox> {
    let arr = obj.as_array().ok()?;
    if arr.len() < 4 {
        return None;
    }
    let x1 = as_f32(&arr[0]);
    let y1 = as_f32(&arr[1]);
    let x2 = as_f32(&arr[2]);
    let y2 = as_f32(&arr[3]);

    Some(PdfBBox {
        min_x: x1.min(x2),
        min_y: y1.min(y2),
        max_x: x1.max(x2),
        max_y: y1.max(y2),
    })
}

fn parse_quadpoints(obj: &Object) -> Option<Vec<PdfBBox>> {
    let arr = obj.as_array().ok()?;
    if arr.is_empty() || arr.len() % 8 != 0 {
        return None;
    }
    
    let mut quads = Vec::new();
    for chunk in arr.chunks(8) {
        let mut min_x = f32::INFINITY;
        let mut min_y = f32::INFINITY;
        let mut max_x = f32::NEG_INFINITY;
        let mut max_y = f32::NEG_INFINITY;
        
        for i in 0..4 {
            let x = as_f32(&chunk[i*2]);
            let y = as_f32(&chunk[i*2+1]);
            
            if x < min_x { min_x = x; }
            if x > max_x { max_x = x; }
            if y < min_y { min_y = y; }
            if y > max_y { max_y = y; }
        }
        
        quads.push(PdfBBox {
            min_x,
            min_y,
            max_x,
            max_y,
        });
    }
    
    Some(quads)
}

fn as_f32(obj: &Object) -> f32 {
    match obj {
        Object::Integer(i) => *i as f32,
        Object::Real(r) => *r as f32,
        _ => 0.0,
    }
}

fn text_from_object(obj: &Object) -> Result<String, ()> {
    match obj {
        Object::String(bytes, _) => Ok(String::from_utf8_lossy(bytes).into_owned()),
        Object::Name(bytes) => Ok(String::from_utf8_lossy(bytes).into_owned()),
        _ => Err(()),
    }
}
