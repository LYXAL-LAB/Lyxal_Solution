use crate::{Component, IcalError, IcalObject, Property, VCalendar};
use std::collections::HashMap;

pub fn parse(ics: &str) -> Result<IcalObject, IcalError> {
    let unfolded = unfold_lines(ics);
    let mut calendars = Vec::new();
    let mut stack: Vec<PartialComponent> = Vec::new();

    for (idx, line) in unfolded.iter().enumerate() {
        let line_no = idx + 1;
        let trimmed = line.trim_end();
        if trimmed.is_empty() {
            continue;
        }

        // BEGIN / END handling
        if let Some(rest) = trimmed.strip_prefix("BEGIN:") {
            let name = rest.trim().to_ascii_uppercase();
            if stack.is_empty() && name != "VCALENDAR" {
                return Err(IcalError::ParseError { line: line_no, reason: "Root must be VCALENDAR".into() });
            }
            stack.push(PartialComponent::new(name));
            continue;
        }
        if let Some(rest) = trimmed.strip_prefix("END:") {
            let end_name = rest.trim().to_ascii_uppercase();
            let Some(finished) = stack.pop() else {
                return Err(IcalError::UnexpectedEnd(end_name));
            };
            if finished.name != end_name {
                return Err(IcalError::MismatchedEnd { expected: finished.name, found: end_name });
            }

            let component = finished.into_component();
            if let Some(parent) = stack.last_mut() {
                parent.children.push(component);
            } else if let Component::Other { name, props, subcomponents } = component {
                // root end; must be VCALENDAR
                if name != "VCALENDAR" {
                    return Err(IcalError::MissingCalendar);
                }
                calendars.push(VCalendar::new(props, subcomponents));
            }
            continue;
        }

        // Regular property line
        if let Some(current) = stack.last_mut() {
            let prop = parse_property(trimmed, line_no)?;
            current.props.push(prop);
        } else {
            return Err(IcalError::MissingCalendar);
        }
    }

    if !stack.is_empty() {
        let open = stack.last().unwrap().name.clone();
        return Err(IcalError::UnexpectedEof { open_component: open });
    }

    if calendars.is_empty() {
        return Err(IcalError::MissingCalendar);
    }

    Ok(IcalObject::new(calendars))
}

fn unfold_lines(ics: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut current = String::new();

    for raw_line in ics.replace("\r\n", "\n").replace('\r', "\n").split('\n') {
        if raw_line.starts_with(' ') || raw_line.starts_with('\t') {
            current.push_str(raw_line.trim_start());
        } else {
            if !current.is_empty() {
                out.push(current);
            }
            current = raw_line.to_string();
        }
    }
    if !current.is_empty() {
        out.push(current);
    }
    out
}

fn parse_property(line: &str, line_no: usize) -> Result<Property, IcalError> {
    let mut parts = line.splitn(2, ':');
    let before = parts.next().ok_or(IcalError::InvalidLine)?;
    let value = parts.next().ok_or(IcalError::InvalidLine)?;

    let mut name_and_params = before.split(';');
    let name = name_and_params
        .next()
        .ok_or(IcalError::InvalidLine)?
        .trim()
        .to_string();

    let mut params: HashMap<String, Vec<String>> = HashMap::new();
    for param in name_and_params {
        if param.trim().is_empty() {
            continue;
        }
        let mut kv = param.splitn(2, '=');
        let key = kv.next().unwrap().trim().to_ascii_uppercase();
        let raw_val = kv
            .next()
            .ok_or(IcalError::ParseError { line: line_no, reason: format!("Missing '=' in param {}", key) })?;
        let parsed_vals = parse_param_values(raw_val);
        params.entry(key).or_default().extend(parsed_vals);
    }

    Ok(Property {
        name: name.to_ascii_uppercase(),
        params,
        value: value.to_string(),
    })
}

fn parse_param_values(raw: &str) -> Vec<String> {
    let mut vals = Vec::new();
    let mut current = String::new();
    let mut in_quote = false;
    for ch in raw.chars() {
        match ch {
            '"' => {
                in_quote = !in_quote;
            }
            ',' if !in_quote => {
                vals.push(current.clone());
                current.clear();
            }
            _ => current.push(ch),
        }
    }
    if !current.is_empty() || raw.ends_with(',') {
        vals.push(current);
    }
    vals
}

struct PartialComponent {
    name: String,
    props: Vec<Property>,
    children: Vec<Component>,
}

impl PartialComponent {
    fn new(name: String) -> Self {
        Self {
            name: name.to_ascii_uppercase(),
            props: Vec::new(),
            children: Vec::new(),
        }
    }

    fn into_component(mut self) -> Component {
        let props = std::mem::take(&mut self.props);
        let children = std::mem::take(&mut self.children);
        match self.name.as_str() {
            "VEVENT" => Component::VEvent { props, subcomponents: children },
            "VTODO" => Component::VTodo { props, subcomponents: children },
            "VJOURNAL" => Component::VJournal { props, subcomponents: children },
            "VFREEBUSY" => Component::VFreebusy { props, subcomponents: children },
            "VTIMEZONE" => Component::VTimezone { props, subcomponents: children },
            "VCALENDAR" => Component::Other { name: "VCALENDAR".into(), props, subcomponents: children },
            other => Component::Other { name: other.to_string(), props, subcomponents: children },
        }
    }
}

