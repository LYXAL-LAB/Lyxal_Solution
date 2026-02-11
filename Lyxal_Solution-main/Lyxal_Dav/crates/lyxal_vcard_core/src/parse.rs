use crate::error::VCardError;
use crate::types::{VCard, Property};
use std::collections::HashMap;

pub fn parse(input: &str) -> Result<VCard, VCardError> {
    let mut lines = Vec::new();
    let mut current_line = String::new();
    
    for raw_line in input.lines() {
        if raw_line.is_empty() { continue; }
        if raw_line.starts_with(' ') || raw_line.starts_with('\t') {
            current_line.push_str(&raw_line[1..]);
        } else {
            if !current_line.is_empty() {
                lines.push(current_line);
            }
            current_line = raw_line.to_string();
        }
    }
    if !current_line.is_empty() {
        lines.push(current_line);
    }
    
    let mut vcard = VCard::new();
    let mut in_vcard = false;
    
    for line in lines {
        if line.trim().eq_ignore_ascii_case("BEGIN:VCARD") {
            in_vcard = true;
            continue;
        }
        if line.trim().eq_ignore_ascii_case("END:VCARD") {
            // in_vcard = false;
            break;
        }
        if !in_vcard { continue; }
        
        let prop = parse_line(&line)?;
        vcard.properties.push(prop);
    }
    
    Ok(vcard)
}

fn parse_line(line: &str) -> Result<Property, VCardError> {
    let (name_part, value) = line.split_once(':')
        .ok_or_else(|| VCardError::ParseError(format!("Missing colon in line: {}", line)))?;
        
    let (group, full_name) = if let Some((g, n)) = name_part.split_once('.') {
        (Some(g.to_string()), n)
    } else {
        (None, name_part)
    };
    
    let mut parts = full_name.split(';');
    let name = parts.next().unwrap_or("").to_string();
    if name.is_empty() {
         return Err(VCardError::ParseError("Empty property name".into()));
    }
    
    let mut params = HashMap::new();
    for param_str in parts {
        if let Some((k, v)) = param_str.split_once('=') {
            let values: Vec<String> = v.split(',').map(|s| s.to_string()).collect();
            params.insert(k.to_uppercase(), values);
        } else {
             params.insert(param_str.to_uppercase(), vec![]);
        }
    }
    
    Ok(Property {
        group,
        name: name.to_uppercase(),
        params,
        value: value.to_string(),
    })
}

