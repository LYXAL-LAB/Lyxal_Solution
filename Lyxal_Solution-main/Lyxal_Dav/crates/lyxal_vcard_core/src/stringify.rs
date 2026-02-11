use crate::types::VCard;

pub fn to_string(vcard: &VCard) -> String {
    let mut out = String::new();
    out.push_str("BEGIN:VCARD\r\n");
    
    for prop in &vcard.properties {
        let mut line = String::new();
        if let Some(g) = &prop.group {
            line.push_str(g);
            line.push('.');
        }
        line.push_str(&prop.name);
        
        // Params should be sorted for determinism? 
        // HashMap iteration is random. We should probably sort if we want canonical output.
        // But for now, simple iteration.
        let mut sorted_params: Vec<_> = prop.params.iter().collect();
        sorted_params.sort_by_key(|(k, _)| *k);
        
        for (k, vals) in sorted_params {
            line.push(';');
            line.push_str(k);
            if !vals.is_empty() {
                line.push('=');
                line.push_str(&vals.join(","));
            }
        }
        
        line.push(':');
        line.push_str(&prop.value);
        
        out.push_str(&fold_line(&line));
        out.push_str("\r\n");
    }
    
    out.push_str("END:VCARD\r\n");
    out
}

fn fold_line(line: &str) -> String {
    if line.len() <= 75 {
        return line.to_string();
    }
    let mut out = String::new();
    let mut current_len = 0;
    
    // Naive byte folding vs char folding. RFC says octets.
    // But we are in UTF-8 strings.
    // Safe approach: split on chars, check utf8 byte len.
    
    for c in line.chars() {
        let len = c.len_utf8();
        if current_len + len > 75 {
            out.push_str("\r\n ");
            current_len = 1; // Count the space
        }
        out.push(c);
        current_len += len;
    }
    out
}

