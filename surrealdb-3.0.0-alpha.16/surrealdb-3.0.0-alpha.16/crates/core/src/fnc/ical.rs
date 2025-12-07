//! iCalendar parsing functions for SurrealDB
//! Provides native iCal parsing capabilities within SurrealQL

use anyhow::Result;
use chrono::{DateTime, Utc};
use rrule::RRuleSet;
use chrono_tz::Tz;

use crate::val::{Value, Object, Array};

/// Calculate iCalendar DURATION between two dates
/// Usage: ical::duration(dtstart, dtend)
pub fn duration((start, end): (Value, Value)) -> Result<Value> {
    let start = match start {
        Value::Datetime(d) => d.0,
        _ => return Ok(Value::None),
    };
    let end = match end {
        Value::Datetime(d) => d.0,
        _ => return Ok(Value::None),
    };

    let diff = end.signed_duration_since(start);
    // Simple ISO8601 duration generation (simplified)
    // Format: P[nD]T[nH][nM][nS]
    let days = diff.num_days();
    let hours = diff.num_hours() % 24;
    let minutes = diff.num_minutes() % 60;
    let seconds = diff.num_seconds() % 60;

    let mut dur = String::from("P");
    if days > 0 {
        dur.push_str(&format!("{}D", days));
    }
    if hours > 0 || minutes > 0 || seconds > 0 {
        dur.push_str("T");
        if hours > 0 {
            dur.push_str(&format!("{}H", hours));
        }
        if minutes > 0 {
            dur.push_str(&format!("{}M", minutes));
        }
        if seconds > 0 {
            dur.push_str(&format!("{}S", seconds));
        }
    }
    if dur == "P" {
        dur = "PT0S".to_string();
    }

    Ok(Value::from(dur))
}

/// Convert datetime to a specific timezone (returns RFC3339 string with offset)
/// Usage: ical::timezone(datetime, "Europe/Paris")
pub fn timezone((val, tzid): (Value, String)) -> Result<Value> {
    let dt = match val {
        Value::Datetime(d) => d.0,
        _ => return Ok(Value::None),
    };
    
    // Bridge: We rely on chrono-tz parsing the TZID string
    let tz: Tz = match tzid.parse() {
        Ok(t) => t,
        Err(_) => return Ok(Value::None),
    };

    // We can use with_timezone here safely if Tz is compatible-ish or if we just want string output
    // The issue before was passing this into rrule. Formatting *should* be fine if chrono version matches enough for trait bound.
    // If this fails compiling, we'll need a different bridge, but usually formatting is safer.
    let dt_tz = dt.with_timezone(&tz);
    Ok(Value::from(dt_tz.to_rfc3339()))
}

/// Expand RRULE into occurrences
/// Usage: ical::occurrences("FREQ=DAILY;COUNT=5", start_date, limit_date?)
pub fn occurrences((rrule_str, start, limit): (String, Value, Value)) -> Result<Value> {
    let start_dt = match start {
        Value::Datetime(d) => d.0,
        _ => return Err(anyhow::anyhow!("Invalid start date")),
    };

    // BRIDGE STRATEGY:
    // 1. Convert Start Date to String (RFC3339) 
    //    We force UTC string first to be safe, or keep offset if native.
    //    RRule parser reads string.
    let start_str = start_dt.to_rfc3339();
    
    // 2. Build full RRULE block
    //    RRuleSet::parse() works best with "DTSTART:...\nRRULE:..."
    let rrule_block = format!("DTSTART:{}\nRRULE:{}", start_str, rrule_str.trim_start_matches("RRULE:"));

    // 3. Parse with rrule crate
    let rrule_set: RRuleSet = rrule_block
        .parse()
        .map_err(|e| anyhow::anyhow!("Failed to parse RRULE: {}", e))?;

    // 4. Determine limit (until)
    //    Note: rrule limit is on generation count or until date in rule.
    //    We also accept an optional 'limit' argument (until date).
    let limit_dt = match limit {
        Value::Datetime(d) => d.0,
        _ => start_dt + chrono::Duration::days(365 * 2),
    };

    // 5. Generate occurrences
    //    We rely on .all(limit) which returns Vec<DateTime<Tz>> (rrule's chrono version)
    //    This is where the type mismatch happens if we tried to use the iterator directly with Surreal types.
    //    But we only need to READ the dates.
    let rrule_results = rrule_set.all(200);

    let mut results = Array::default();
    for date in rrule_results.dates {
         // BRIDGE: Convert rrule's DateTime -> String (RFC3339) -> Surreal Value
         // rrule's DateTime implements Display (= RFC3339 usually)
         let date_str = date.to_rfc3339();
         
         // Parse string back to SurrealDB compatible DateTime (using crate::val check or just generic parse)
         // Since we trust rrule output, we can use DateTime::parse_from_rfc3339
         if let Ok(parsed) = DateTime::parse_from_rfc3339(&date_str) {
             let utc_date: DateTime<Utc> = parsed.with_timezone(&Utc);
             if utc_date > limit_dt {
                 break;
             }
             results.push(Value::from(utc_date));
         }
    }

    Ok(Value::Array(results))
}

/// Parse iCalendar text and extract the first VEVENT's properties
/// Usage: ical::parse("BEGIN:VCALENDAR...")
pub fn parse((ical_text,): (String,)) -> Result<Value> {
    let mut result = Object::default();
    let mut in_vevent = false;
    
    for line in ical_text.lines() {
        let line = line.trim();
        
        if line == "BEGIN:VEVENT" {
            in_vevent = true;
            continue;
        }
        if line == "END:VEVENT" {
            in_vevent = false;
            continue;
        }
        
        if in_vevent {
            if let Some((key, value)) = parse_property(line) {
                result.insert(key.to_lowercase(), Value::from(value));
            }
        }
    }
    
    Ok(Value::Object(result))
}

/// Parse all VEVENT components from iCalendar text
/// Usage: ical::events("BEGIN:VCALENDAR...")
pub fn events((ical_text,): (String,)) -> Result<Value> {
    let mut events = Array::default();
    let mut current_event: Option<Object> = None;
    
    for line in ical_text.lines() {
        let line = line.trim();
        
        if line == "BEGIN:VEVENT" {
            current_event = Some(Object::default());
            continue;
        }
        if line == "END:VEVENT" {
            if let Some(event) = current_event.take() {
                events.push(Value::Object(event));
            }
            continue;
        }
        
        if let Some(ref mut event) = current_event {
            if let Some((key, value)) = parse_property(line) {
                event.insert(key.to_lowercase(), Value::from(value));
            }
        }
    }
    
    Ok(Value::Array(events))
}

/// Extract a specific property from iCalendar text
/// Usage: ical::get("BEGIN:VCALENDAR...", "SUMMARY")
pub fn get((ical_text, property): (String, String)) -> Result<Value> {
    let search = format!("{}:", property.to_uppercase());
    
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with(&search) {
            return Ok(Value::from(&line[search.len()..]));
        }
    }
    
    Ok(Value::None)
}

/// Check if iCalendar text contains a specific component type
/// Usage: ical::has("BEGIN:VCALENDAR...", "VEVENT")
pub fn has((ical_text, component): (String, String)) -> Result<Value> {
    let search = format!("BEGIN:{}", component.to_uppercase());
    Ok(Value::from(ical_text.contains(&search)))
}

/// Get the METHOD property from iCalendar (REQUEST, REPLY, CANCEL, etc.)
/// Usage: ical::method("BEGIN:VCALENDAR...")
pub fn method((ical_text,): (String,)) -> Result<Value> {
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("METHOD:") {
            return Ok(Value::from(&line[7..]));
        }
    }
    Ok(Value::None)
}

/// Extract all ATTENDEEs from a VEVENT
/// Usage: ical::attendees("BEGIN:VCALENDAR...")
pub fn attendees((ical_text,): (String,)) -> Result<Value> {
    let mut result = Array::default();
    
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("ATTENDEE") {
            // Parse ATTENDEE;PARAM=value:mailto:email
            if let Some(mailto_idx) = line.find("mailto:") {
                let email = &line[mailto_idx + 7..];
                result.push(Value::from(email));
            }
        }
    }
    
    Ok(Value::Array(result))
}

/// Extract the ORGANIZER from a VEVENT
/// Usage: ical::organizer("BEGIN:VCALENDAR...")
pub fn organizer((ical_text,): (String,)) -> Result<Value> {
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("ORGANIZER") {
            if let Some(mailto_idx) = line.find("mailto:") {
                return Ok(Value::from(&line[mailto_idx + 7..]));
            }
        }
    }
    Ok(Value::None)
}

/// Convert a SurrealDB Value (Object or Array) into an iCalendar string
/// Usage: ical::stringify({ summary: "Meeting", dtstart: "..." })
pub fn stringify((value,): (Value,)) -> Result<Value> {
    let mut output = String::from("BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Lyxal_Solution//EN\n");

    let events = match value {
        Value::Array(arr) => arr.into_iter().collect::<Vec<_>>(),
        obj @ Value::Object(_) => vec![obj],
        _ => return Err(crate::err::Error::InvalidArguments {
            name: "value".into(),
            message: "Expected Object or Array for ical::stringify".into(),
        }.into()),
    };

    if events.is_empty() {
        output.push_str("END:VCALENDAR");
        return Ok(Value::from(output));
    }

    for event_val in events {
        if let Value::Object(event) = event_val {
            output.push_str("BEGIN:VEVENT\n");

            // Conversion helper for iCal values
            let to_ical_val = |v: &Value| -> String {
                match v {
                    Value::String(s) => s.to_string(),
                    Value::Datetime(d) => d.0.format("%Y%m%dT%H%M%SZ").to_string(),
                    _ => v.to_string()
                }
            };

            // Helper closure to append if exists
            let mut append = |key: &str, prop: &str| {
                if let Some(val) = event.get(key) {
                    if val != &Value::None {
                         output.push_str(&format!("{}:{}\n", prop, to_ical_val(val)));
                    }
                }
            };

            // Core fields
            append("uid", "UID");
            append("summary", "SUMMARY");
            append("dtstart", "DTSTART");
            append("dtend", "DTEND");
            append("description", "DESCRIPTION");
            append("location", "LOCATION");
            append("organizer", "ORGANIZER");
            
            // Recurrence
            append("rrule", "RRULE");
            append("recurrence_id", "RECURRENCE-ID");

            // Status & Synchronization
            append("status", "STATUS");
            append("transp", "TRANSP");
            append("sequence", "SEQUENCE");
            
            // Metadata & Timestamp
            append("created", "CREATED");
            append("last_modified", "LAST-MODIFIED");
            append("dtstamp", "DTSTAMP");
            
            // Other
            append("class", "CLASS");
            append("url", "URL");
            append("priority", "PRIORITY");

            // Function to handle array fields
            let mut append_array = |key: &str, prop: &str| {
                if let Some(Value::Array(arr)) = event.get(key) {
                    for item in arr.iter() {
                         output.push_str(&format!("{}:{}\n", prop, to_ical_val(item)));
                    }
                }
            };

            append_array("attendees", "ATTENDEE");
            append_array("exdate", "EXDATE");
            append_array("categories", "CATEGORIES");
            append_array("attach", "ATTACH");

            output.push_str("END:VEVENT\n");
        }
    }

    output.push_str("END:VCALENDAR");
    Ok(Value::from(output))
}

// Helper function to parse a property line
fn parse_property(line: &str) -> Option<(String, String)> {
    // Handle properties with parameters: DTSTART;TZID=Europe/Paris:20250106T140000
    // or simple properties: SUMMARY:My Event
    
    let colon_idx = line.find(':')?;
    let key_part = &line[..colon_idx];
    let value = &line[colon_idx + 1..];
    
    // Extract just the property name (before any ; parameters)
    let key = if let Some(semi_idx) = key_part.find(';') {
        &key_part[..semi_idx]
    } else {
        key_part
    };
    
    Some((key.to_string(), value.to_string()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::str::FromStr;

    #[test]
    fn test_parse() {
        let ical = r#"BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
UID:test-123
SUMMARY:Meeting
DTSTART:20250106T140000Z
END:VEVENT
END:VCALENDAR"#;
        
        let result = parse((ical.to_string(),)).unwrap();
        assert!(matches!(result, Value::Object(_)));
    }

    #[test]
    fn test_method() {
        let ical = "BEGIN:VCALENDAR\nMETHOD:REQUEST\nEND:VCALENDAR";
        let result = method((ical.to_string(),)).unwrap();
        assert_eq!(result, Value::from("REQUEST"));
    }

    #[test]
    fn test_stringify() {
        let mut event = std::collections::BTreeMap::new();
        event.insert("summary".into(), Value::from("Test Stringify"));
        event.insert("uid".into(), Value::from("uid-123"));
        event.insert("dtstart".into(), Value::from("20250101T000000Z"));
        
        let val = Value::from(event);
        let res = stringify((val,)).unwrap();
        let ical = res.to_string();
        
        assert!(ical.contains("BEGIN:VCALENDAR"));
        assert!(ical.contains("SUMMARY:Test Stringify"));
        assert!(ical.contains("UID:uid-123"));
        assert!(ical.contains("DTSTART:20250101T000000Z"));
        assert!(ical.contains("END:VCALENDAR"));
    }

    #[test]
    fn test_occurrences() {
        // Daily for 3 days starting 2024-01-01
        let rrule = "FREQ=DAILY;COUNT=3";
        let start = Value::from(Datetime::from_str("2024-01-01T10:00:00Z").unwrap());
        let limit = Value::None;

        let result = occurrences((rrule.to_string(), start, limit)).unwrap();
        
        if let Value::Array(arr) = result {
            assert_eq!(arr.len(), 3);
            // Check first date
            let d1 = &arr[0];
            assert_eq!(d1.to_string(), "2024-01-01T10:00:00Z");
            // Check last date
            let d3 = &arr[2];
            assert_eq!(d3.to_string(), "2024-01-03T10:00:00Z");
        } else {
            panic!("Expected array result");
        }
    }
}
