//! PDF Forms (AcroForm) parsing

use super::model::{PdfFormField, PdfFormFieldType, PdfButtonState};
use crate::parser::pdf::common::PdfBBox;
use lopdf::{Document, Object};
use std::collections::HashMap;

pub fn parse_acroform(doc: &Document) -> Vec<PdfFormField> {
    let mut fields = Vec::new();

    let catalog = match doc.trailer.get(b"Root") {
        Ok(Object::Reference(ref_id)) => match doc.get_object(*ref_id) {
            Ok(Object::Dictionary(dict)) => dict,
            _ => return fields,
        },
        Ok(Object::Dictionary(dict)) => dict,
        _ => return fields,
    };

    let acroform = match catalog.get(b"AcroForm") {
        Ok(Object::Reference(ref_id)) => match doc.get_object(*ref_id) {
            Ok(Object::Dictionary(dict)) => dict,
            _ => return fields,
        },
        Ok(Object::Dictionary(dict)) => dict,
        _ => return fields,
    };

    let page_map = build_page_map(doc);

    if let Ok(Object::Array(root_fields)) = acroform.get(b"Fields") {
        for field_ref in root_fields {
            parse_field_recursive(doc, field_ref, "", &page_map, &mut fields);
        }
    }

    fields
}

fn build_page_map(doc: &Document) -> HashMap<(u32, u16), usize> {
    let mut map = HashMap::new();
    for (page_num, page_id) in doc.get_pages() {
        map.insert(page_id, (page_num - 1) as usize);
    }
    map
}

fn parse_field_recursive(
    doc: &Document,
    obj_ref: &Object,
    parent_name: &str,
    page_map: &HashMap<(u32, u16), usize>,
    out: &mut Vec<PdfFormField>,
) {
    let (obj, _obj_id) = match obj_ref {
        Object::Reference(id) => match doc.get_object(*id) {
            Ok(o) => (o, Some(*id)),
            Err(_) => return,
        },
        o => (o, None),
    };

    let dict = match obj {
        Object::Dictionary(d) => d,
        _ => return,
    };

    let partial_name = dict
        .get(b"T")
        .ok()
        .and_then(|o| text_from_object(o))
        .unwrap_or_default();

    let full_name = if parent_name.is_empty() {
        partial_name
    } else if partial_name.is_empty() {
        parent_name.to_string()
    } else {
        format!("{}.{}", parent_name, partial_name)
    };

    let field_type_name = dict
        .get(b"FT")
        .ok()
        .and_then(|o| o.as_name().ok())
        .map(|n| String::from_utf8_lossy(n).into_owned());

    let value = dict.get(b"V").ok().and_then(|o| text_from_object(o));
    let flags = dict.get(b"Ff").ok().and_then(|o| o.as_i64().ok()).map(|i| i as u32);
    let rect = dict.get(b"Rect").ok().and_then(|o| parse_rect(o));
    let page_index = dict
        .get(b"P")
        .ok()
        .and_then(|o| o.as_reference().ok())
        .and_then(|id| page_map.get(&id).cloned());

    if let Some(ft) = field_type_name {
        let ftype = match ft.as_str() {
            "Tx" => PdfFormFieldType::Text,
            "Btn" => PdfFormFieldType::Button,
            "Ch" => PdfFormFieldType::Choice,
            "Sig" => PdfFormFieldType::Signature,
            s => PdfFormFieldType::Other(s.to_string()),
        };

        let mut button_state = None;
        let mut options = None;

        if matches!(ftype, PdfFormFieldType::Button) {
            let is_pushbutton = flags.map(|f| (f & 65536) != 0).unwrap_or(false);
            
            if let Ok(as_name) = dict.get(b"AS").and_then(|o| o.as_name()) {
                if as_name == b"Off" {
                    button_state = Some(PdfButtonState::Off);
                } else {
                    button_state = Some(PdfButtonState::On(String::from_utf8_lossy(as_name).into_owned()));
                }
            } else if let Some(v_str) = &value {
                if v_str == "Off" {
                    button_state = Some(PdfButtonState::Off);
                } else {
                    button_state = Some(PdfButtonState::On(v_str.clone()));
                }
            } else {
                 if !is_pushbutton {
                     button_state = Some(PdfButtonState::Off);
                 }
            }
            
            if let Ok(ap) = dict.get(b"AP").and_then(|o| o.as_dict()) {
                if let Ok(n) = ap.get(b"N").and_then(|o| o.as_dict()) {
                    let opts: Vec<String> = n.iter()
                        .map(|(k, _)| String::from_utf8_lossy(k).into_owned())
                        .filter(|k| k != "Off")
                        .collect();
                    if !opts.is_empty() {
                        options = Some(opts);
                    }
                }
            }
        }

        out.push(PdfFormField {
            name: full_name.clone(),
            field_type: ftype,
            value,
            rect,
            page_index,
            flags,
            button_state,
            options,
        });
    }

    if let Ok(Object::Array(kids)) = dict.get(b"Kids") {
        for kid in kids {
            parse_field_recursive(doc, kid, &full_name, page_map, out);
        }
    }
}

fn text_from_object(obj: &Object) -> Option<String> {
    match obj {
        Object::String(bytes, _) => Some(String::from_utf8_lossy(bytes).into_owned()),
        Object::Name(bytes) => Some(String::from_utf8_lossy(bytes).into_owned()),
        _ => None,
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

fn as_f32(obj: &Object) -> f32 {
    match obj {
        Object::Integer(i) => *i as f32,
        Object::Real(r) => *r as f32,
        _ => 0.0,
    }
}
