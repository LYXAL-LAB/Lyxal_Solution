use crate::{Component, IcalError, IcalObject, Property, VCalendar};
/// Stringify an IcalObject into canonical RFC5545 text.
pub fn stringify(obj: &IcalObject) -> Result<String, IcalError> {
    let mut out = String::new();
    for cal in &obj.calendars {
        emit_calendar(cal, &mut out)?;
    }
    Ok(out)
}

fn emit_calendar(cal: &VCalendar, out: &mut String) -> Result<(), IcalError> {
    out.push_str("BEGIN:VCALENDAR\r\n");

    let mut props = cal.props.clone();
    props.sort_by(|a, b| a.name.cmp(&b.name)); // stable alphabetical for VCALENDAR
    for p in props {
        emit_property(&p, out)?;
    }

    for comp in &cal.components {
        emit_component(comp, out)?;
    }

    out.push_str("END:VCALENDAR\r\n");
    Ok(())
}

fn emit_component(comp: &Component, out: &mut String) -> Result<(), IcalError> {
    let (name, props, subs) = match comp {
        Component::VEvent { props, subcomponents } => ("VEVENT", props, subcomponents),
        Component::VTodo { props, subcomponents } => ("VTODO", props, subcomponents),
        Component::VJournal { props, subcomponents } => ("VJOURNAL", props, subcomponents),
        Component::VFreebusy { props, subcomponents } => ("VFREEBUSY", props, subcomponents),
        Component::VTimezone { props, subcomponents } => ("VTIMEZONE", props, subcomponents),
        Component::Other { name, props, subcomponents } => (name.as_str(), props, subcomponents),
    };

    out.push_str(&format!("BEGIN:{}\r\n", name));

    for p in props {
        emit_property(p, out)?;
    }

    for child in subs {
        emit_component(child, out)?;
    }

    out.push_str(&format!("END:{}\r\n", name));
    Ok(())
}

fn emit_property(prop: &Property, out: &mut String) -> Result<(), IcalError> {
    let mut line = String::new();
    line.push_str(&prop.name.to_ascii_uppercase());

    // Params: sort keys for determinism, uppercase keys
    let mut keys: Vec<&String> = prop.params.keys().collect();
    keys.sort();
    for key in keys {
        line.push(';');
        line.push_str(&key.to_ascii_uppercase());
        line.push('=');
        let vals = prop.params.get(key).unwrap();
        let joined = vals
            .iter()
            .map(|v| serialize_param_value(v))
            .collect::<Vec<_>>()
            .join(",");
        line.push_str(&joined);
    }

    line.push(':');
    line.push_str(&escape_value(&prop.value));

    let folded = fold_line(&line);
    out.push_str(&folded);
    out.push_str("\r\n");
    Ok(())
}

fn serialize_param_value(v: &str) -> String {
    if v.contains([':', ';', ',', ' ']) {
        format!("\"{}\"", v)
    } else {
        v.to_string()
    }
}

fn escape_value(v: &str) -> String {
    let mut out = String::new();
    for ch in v.chars() {
        match ch {
            '\\' => out.push_str("\\\\"),
            ';' => out.push_str("\\;"),
            ',' => out.push_str("\\,"),
            '\n' => out.push_str("\\n"),
            _ => out.push(ch),
        }
    }
    out
}

fn fold_line(line: &str) -> String {
    const LIMIT: usize = 75;
    let mut parts = Vec::new();
    let mut current = String::new();
    let mut current_len = 0usize;

    for ch in line.chars() {
        let clen = ch.len_utf8();
        if current_len + clen > LIMIT && !current.is_empty() {
            parts.push(current);
            current = String::new();
            current_len = 0;
        }
        current.push(ch);
        current_len += clen;
    }
    if !current.is_empty() {
        parts.push(current);
    }

    if parts.is_empty() {
        return String::new();
    }

    let mut result = String::new();
    for (i, part) in parts.iter().enumerate() {
        if i == 0 {
            result.push_str(part);
        } else {
            result.push_str("\r\n ");
            result.push_str(part);
        }
    }
    result
}

#[cfg(test)]
mod tests_util {
    use super::fold_line;

    #[test]
    fn fold_line_respects_utf8() {
        let s = "SUMMARY:é".repeat(10); // will force folding
        let folded = fold_line(&s);
        for part in folded.split("\r\n ") {
            assert!(part.len() <= 75);
            assert!(part.is_char_boundary(part.len()));
        }
    }
}

