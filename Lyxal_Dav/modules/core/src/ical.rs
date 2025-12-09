//! iCalendar parsing and generation module
//!
//! Provides native iCal parsing capabilities without depending on SurrealDB types.
//! Uses `serde_json::Value` for flexible object representation.

use chrono::{DateTime, Utc, NaiveDateTime, NaiveDate};
use chrono_tz::Tz;
use rrule::RRuleSet;
use serde_json::{Value, Map, json};

/// Error type for iCal operations
#[derive(Debug, thiserror::Error)]
pub enum IcalError {
    #[error("Invalid date format: {0}")]
    InvalidDate(String),
    
    #[error("Parse error: {0}")]
    ParseError(String),
    
    #[error("Invalid input: {0}")]
    InvalidInput(String),
}

pub type Result<T> = std::result::Result<T, IcalError>;

/// Calculate iCalendar DURATION between two dates
/// Returns ISO8601 duration string (e.g., "P1DT2H30M")
pub fn duration(start: DateTime<Utc>, end: DateTime<Utc>) -> String {
    let diff = end.signed_duration_since(start);
    let days = diff.num_days();
    let hours = diff.num_hours() % 24;
    let minutes = diff.num_minutes() % 60;
    let seconds = diff.num_seconds() % 60;

    let mut dur = String::from("P");
    if days > 0 {
        dur.push_str(&format!("{}D", days));
    }
    if hours > 0 || minutes > 0 || seconds > 0 {
        dur.push('T');
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

    dur
}

/// Convert datetime to a specific timezone (returns RFC3339 string with offset)
pub fn timezone(dt: DateTime<Utc>, tzid: &str) -> Result<String> {
    let tz: Tz = tzid.parse()
        .map_err(|_| IcalError::InvalidInput(format!("Unknown timezone: {}", tzid)))?;
    
    let dt_tz = dt.with_timezone(&tz);
    Ok(dt_tz.to_rfc3339())
}

/// Expand RRULE into occurrences
/// Returns a vector of DateTime<Utc> representing each occurrence
pub fn occurrences(rrule_str: &str, start: DateTime<Utc>, limit: Option<DateTime<Utc>>) -> Result<Vec<DateTime<Utc>>> {
    let start_str = start.to_rfc3339();
    
    // Build full RRULE block
    let rrule_block = format!(
        "DTSTART:{}\nRRULE:{}", 
        start_str, 
        rrule_str.trim_start_matches("RRULE:")
    );

    // Parse with rrule crate
    let rrule_set: RRuleSet = rrule_block.parse()
        .map_err(|e| IcalError::ParseError(format!("Failed to parse RRULE: {}", e)))?;

    // Determine limit
    let limit_dt = limit.unwrap_or_else(|| start + chrono::Duration::days(365 * 2));

    // Generate occurrences (limit to 200)
    let rrule_results = rrule_set.all(200);

    let mut results = Vec::new();
    for date in rrule_results.dates {
        let date_str = date.to_rfc3339();
        if let Ok(parsed) = DateTime::parse_from_rfc3339(&date_str) {
            let utc_date: DateTime<Utc> = parsed.with_timezone(&Utc);
            if utc_date > limit_dt {
                break;
            }
            results.push(utc_date);
        }
    }

    Ok(results)
}

/// Parse iCalendar text and extract the first VEVENT's properties
/// Captures VTIMEZONE blocks and stores them in "vtimezone" property.
pub fn parse(ical_text: &str) -> Result<Value> {
    let mut result = Map::new();
    let mut in_vevent = false;
    let mut in_vtimezone = false;
    let mut vtimezone_acc = String::new();
    let mut has_vtimezone = false;
    
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
        
        if line == "BEGIN:VTIMEZONE" {
            in_vtimezone = true;
            has_vtimezone = true;
            vtimezone_acc.push_str(line);
            vtimezone_acc.push('\n');
            continue;
        }
        if line == "END:VTIMEZONE" {
            in_vtimezone = false;
            vtimezone_acc.push_str(line);
            vtimezone_acc.push('\n');
            continue;
        }
        
        if in_vtimezone {
            vtimezone_acc.push_str(line);
            vtimezone_acc.push('\n');
        } else if in_vevent {
            if let Some((key, value)) = parse_property(line) {
                result.insert(key.to_lowercase(), Value::String(value));
            }
        }
    }
    
    if has_vtimezone {
        result.insert("vtimezone".to_string(), Value::String(vtimezone_acc));
    }
    
    Ok(Value::Object(result))
}

/// Parse all VEVENT components from iCalendar text
pub fn events(ical_text: &str) -> Result<Vec<Value>> {
    let mut events = Vec::new();
    let mut current_event: Option<Map<String, Value>> = None;
    
    for line in ical_text.lines() {
        let line = line.trim();
        
        if line == "BEGIN:VEVENT" {
            current_event = Some(Map::new());
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
                event.insert(key.to_lowercase(), Value::String(value));
            }
        }
    }
    
    Ok(events)
}

/// Extract a specific property from iCalendar text
pub fn get(ical_text: &str, property: &str) -> Option<String> {
    let search = format!("{}:", property.to_uppercase());
    
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with(&search) {
            return Some(line[search.len()..].to_string());
        }
    }
    
    None
}

/// Check if iCalendar text contains a specific component type
pub fn has(ical_text: &str, component: &str) -> bool {
    let search = format!("BEGIN:{}", component.to_uppercase());
    ical_text.contains(&search)
}

/// Get the METHOD property from iCalendar (REQUEST, REPLY, CANCEL, etc.)
pub fn method(ical_text: &str) -> Option<String> {
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("METHOD:") {
            return Some(line[7..].to_string());
        }
    }
    None
}

/// Extract all ATTENDEEs from a VEVENT
pub fn attendees(ical_text: &str) -> Vec<String> {
    let mut result = Vec::new();
    
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("ATTENDEE") {
            // Parse ATTENDEE;PARAM=value:mailto:email
            if let Some(mailto_idx) = line.find("mailto:") {
                let email = &line[mailto_idx + 7..];
                result.push(email.to_string());
            }
        }
    }
    
    result
}

/// Extract the ORGANIZER from a VEVENT
pub fn organizer(ical_text: &str) -> Option<String> {
    for line in ical_text.lines() {
        let line = line.trim();
        if line.starts_with("ORGANIZER") {
            if let Some(mailto_idx) = line.find("mailto:") {
                return Some(line[mailto_idx + 7..].to_string());
            }
        }
    }
    None
}

/// Convert a JSON Value (Object or Array) into an iCalendar string
pub fn stringify(value: &Value) -> Result<String> {
    let mut output = String::from("BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Lyxal_Solution//EN\n");

    // VTIMEZONE Support
    if let Value::Object(ref obj) = value {
        if let Some(Value::String(vtz_str)) = obj.get("vtimezone") {
            output.push_str(vtz_str);
        }
    }

    let events: Vec<&Value> = match value {
        Value::Array(arr) => arr.iter().collect(),
        obj @ Value::Object(_) => vec![obj],
        _ => return Err(IcalError::InvalidInput("Expected Object or Array for stringify".into())),
    };

    if events.is_empty() {
        output.push_str("END:VCALENDAR");
        return Ok(output);
    }

    for event_val in events {
        if let Value::Object(event) = event_val {
            output.push_str("BEGIN:VEVENT\n");

            // Conversion helper for iCal values
            let to_ical_val = |v: &Value| -> String {
                match v {
                    Value::String(s) => s.clone(),
                    _ => v.to_string().trim_matches('"').to_string()
                }
            };

            // Helper closure to append if exists
            let mut append = |key: &str, prop: &str| {
                if let Some(val) = event.get(key) {
                    if !val.is_null() {
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
                    for item in arr {
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
    Ok(output)
}

/// Parse a date string in iCal format to DateTime<Utc>
pub fn parse_date(s: &str) -> Result<DateTime<Utc>> {
    let s_clean = s.trim();
    
    // Try RFC3339 first
    if let Ok(dt) = DateTime::parse_from_rfc3339(s_clean) {
        return Ok(dt.with_timezone(&Utc));
    }
    
    // Try basic iCal format: YYYYMMDDTHHMMSS[Z]
    let is_utc = s_clean.ends_with('Z');
    let date_part = if is_utc { &s_clean[..s_clean.len()-1] } else { s_clean };
    
    if date_part.len() == 15 && date_part.chars().nth(8) == Some('T') {
        // YYYYMMDDTHHMMSS
        if let Ok(naive) = NaiveDateTime::parse_from_str(date_part, "%Y%m%dT%H%M%S") {
            return Ok(DateTime::from_naive_utc_and_offset(naive, Utc));
        }
    }
    
    // Handle DATE only (YYYYMMDD) - All day events
    if date_part.len() == 8 {
        if let Ok(naive_date) = NaiveDate::parse_from_str(date_part, "%Y%m%d") {
            if let Some(naive_dt) = naive_date.and_hms_opt(0, 0, 0) {
                return Ok(DateTime::from_naive_utc_and_offset(naive_dt, Utc));
            }
        }
    }
    
    Err(IcalError::InvalidDate(s.to_string()))
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
    use chrono::Datelike;

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
        
        let result = parse(ical).unwrap();
        assert!(result.is_object());
        assert_eq!(result["uid"], "test-123");
        assert_eq!(result["summary"], "Meeting");
    }

    #[test]
    fn test_method() {
        let ical = "BEGIN:VCALENDAR\nMETHOD:REQUEST\nEND:VCALENDAR";
        let result = method(ical);
        assert_eq!(result, Some("REQUEST".to_string()));
    }

    #[test]
    fn test_stringify() {
        let event = json!({
            "summary": "Test Stringify",
            "uid": "uid-123",
            "dtstart": "20250101T000000Z"
        });
        
        let ical = stringify(&event).unwrap();
        
        assert!(ical.contains("BEGIN:VCALENDAR"));
        assert!(ical.contains("SUMMARY:Test Stringify"));
        assert!(ical.contains("UID:uid-123"));
        assert!(ical.contains("DTSTART:20250101T000000Z"));
        assert!(ical.contains("END:VCALENDAR"));
    }

    #[test]
    fn test_parse_date() {
        // RFC3339
        let dt = parse_date("2024-01-01T10:00:00Z").unwrap();
        assert_eq!(dt.year(), 2024);
        
        // iCal format
        let dt2 = parse_date("20240101T100000Z").unwrap();
        assert_eq!(dt2.year(), 2024);
        
        // Date only
        let dt3 = parse_date("20240101").unwrap();
        assert_eq!(dt3.year(), 2024);
    }
    
    #[test]
    fn test_events() {
        let ical = r#"BEGIN:VCALENDAR
BEGIN:VEVENT
UID:event1
SUMMARY:First
END:VEVENT
BEGIN:VEVENT
UID:event2
SUMMARY:Second
END:VEVENT
END:VCALENDAR"#;
        
        let result = events(ical).unwrap();
        assert_eq!(result.len(), 2);
        assert_eq!(result[0]["uid"], "event1");
        assert_eq!(result[1]["uid"], "event2");
    }
}
