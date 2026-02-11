//! PDF Form field filling

use super::model::{PdfButtonState, PdfError, PdfFormValue};
use lopdf::{Document, Object, Dictionary, StringFormat};

/// Writes a value to a form field
pub fn fill_form_field(
    doc: &mut Document,
    field_name: &str,
    value: PdfFormValue,
) -> Result<(), PdfError> {
    let field_ids = find_fields_by_name(doc, field_name)?;
    if field_ids.is_empty() {
        return Err(PdfError::FieldNotFound(field_name.to_string()));
    }

    for id in field_ids {
        if let Ok(dict) = doc.get_dictionary_mut(id) {
            apply_value_to_dict(dict, &value)?;
        }
    }

    Ok(())
}

fn find_fields_by_name(doc: &Document, name: &str) -> Result<Vec<lopdf::ObjectId>, PdfError> {
    let mut found_ids = Vec::new();
    
    let catalog = doc.trailer.get(b"Root")
        .map_err(|e| PdfError::DocumentError(e))?;
    let catalog_id = match catalog {
        Object::Reference(id) => *id,
        _ => return Err(PdfError::Internal("Root is not a reference".to_string())),
    };
    let catalog_dict = doc.get_dictionary(catalog_id)
        .map_err(|e| PdfError::DocumentError(e))?;
        
    let acroform = match catalog_dict.get(b"AcroForm") {
        Ok(Object::Reference(id)) => doc.get_dictionary(*id).ok(),
        Ok(Object::Dictionary(d)) => Some(d),
        _ => None,
    };

    let fields_array = match acroform {
        Some(dict) => match dict.get(b"Fields") {
            Ok(Object::Array(arr)) => arr,
            _ => return Ok(Vec::new()),
        },
        None => return Ok(Vec::new()),
    };

    for field_ref in fields_array {
        if let Object::Reference(id) = field_ref {
            recursive_find_field(doc, *id, "", name, &mut found_ids)?;
        }
    }

    Ok(found_ids)
}

fn recursive_find_field(
    doc: &Document,
    id: lopdf::ObjectId,
    parent_name: &str,
    target_name: &str,
    results: &mut Vec<lopdf::ObjectId>,
) -> Result<(), PdfError> {
    let dict = doc.get_dictionary(id).map_err(PdfError::DocumentError)?;
    
    let local_name = dict.get(b"T")
        .ok()
        .and_then(|o| o.as_str().ok())
        .map(|s| String::from_utf8_lossy(s).into_owned())
        .unwrap_or_default();

    let full_name = if parent_name.is_empty() {
        local_name.clone()
    } else if local_name.is_empty() {
        parent_name.to_string()
    } else {
        format!("{}.{}", parent_name, local_name)
    };

    if full_name == target_name {
        results.push(id);
    }
    
    if target_name.starts_with(&full_name) || full_name.is_empty() {
         if let Ok(Object::Array(kids)) = dict.get(b"Kids") {
            for kid in kids {
                if let Object::Reference(kid_id) = kid {
                    recursive_find_field(doc, *kid_id, &full_name, target_name, results)?;
                }
            }
        }
    }
    
    Ok(())
}

fn apply_value_to_dict(dict: &mut Dictionary, value: &PdfFormValue) -> Result<(), PdfError> {
    dict.remove(b"AP");
    
    match value {
        PdfFormValue::Text(s) => {
             dict.set("V", Object::String(s.as_bytes().to_vec(), StringFormat::Literal));
        },
        PdfFormValue::Button(state) => {
            match state {
                PdfButtonState::On(opt_name) => {
                    let name = Object::Name(opt_name.as_bytes().to_vec());
                    dict.set("V", name.clone());
                    dict.set("AS", name);
                },
                PdfButtonState::Off => {
                    let off = Object::Name(b"Off".to_vec());
                    dict.set("V", off.clone());
                    dict.set("AS", off);
                }
            }
        }
    }
    Ok(())
}
