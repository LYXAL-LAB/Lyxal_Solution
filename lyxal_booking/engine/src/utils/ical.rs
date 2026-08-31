//! iCalendar Parsing & Unfolding Utilities.

use chrono::{NaiveDate, NaiveDateTime};
use thiserror::Error;

/// iCalendar parsing error types.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum IcalParseError {
    #[error("Unclosed VEVENT block in iCalendar stream")]
    UnclosedEvent,

    #[error("Nested VEVENT block detected")]
    NestedEvent,

    #[error("Unexpected END:VEVENT without matching BEGIN:VEVENT")]
    UnexpectedEventEnd,
}

/// Unfold iCalendar line continuations (CRLF/LF + space/tab).
pub fn unfold_ical(input: &str) -> String {
    let normalized = input.replace("\r\n", "\n");
    let mut output = String::with_capacity(normalized.len());

    for line in normalized.split('\n') {
        if line.starts_with(' ') || line.starts_with('\t') {
            output.push_str(&line[1..]);
        } else {
            if !output.is_empty() {
                output.push('\n');
            }
            output.push_str(line);
        }
    }

    output
}

/// Parse an iCal datetime string into a `NaiveDateTime`.
///
/// Accepts the four shapes calrs sees in the wild:
/// - compact `YYYYMMDDTHHMMSS`
/// - ISO `YYYY-MM-DDTHH:MM:SS`
/// - date-only `YYYYMMDD` / `YYYY-MM-DD` (returns 00:00:00)
///
/// A trailing `Z` (UTC marker) is stripped before parsing — the caller is
/// expected to carry the timezone separately.
pub fn parse_ical_naive_datetime(s: &str) -> Option<NaiveDateTime> {
    let s = s.strip_suffix('Z').unwrap_or(s);
    NaiveDateTime::parse_from_str(s, "%Y%m%dT%H%M%S")
        .ok()
        .or_else(|| NaiveDateTime::parse_from_str(s, "%Y-%m-%dT%H:%M:%S").ok())
        .or_else(|| {
            NaiveDate::parse_from_str(s, "%Y%m%d")
                .ok()
                .and_then(|d| d.and_hms_opt(0, 0, 0))
        })
        .or_else(|| {
            NaiveDate::parse_from_str(s, "%Y-%m-%d")
                .ok()
                .and_then(|d| d.and_hms_opt(0, 0, 0))
        })
}

#[deprecated(
    note = "Use parse_ical_naive_datetime; this function intentionally discards timezone semantics"
)]
pub fn parse_ical_datetime(s: &str) -> Option<NaiveDateTime> {
    parse_ical_naive_datetime(s)
}

/// Split an iCal blob into individual VEVENT blocks using a state machine.
pub fn split_vevents(ical: &str) -> Result<Vec<String>, IcalParseError> {
    let unfolded = unfold_ical(ical);
    let mut events = Vec::new();
    let mut current: Option<Vec<&str>> = None;

    for line in unfolded.lines() {
        let marker = line.trim();
        if marker == "BEGIN:VEVENT" || marker.starts_with("BEGIN:VEVENT;") {
            if current.is_some() {
                return Err(IcalParseError::NestedEvent);
            }
            current = Some(vec![line]);
        } else if marker == "END:VEVENT" || marker.starts_with("END:VEVENT;") {
            let mut block = current.take().ok_or(IcalParseError::UnexpectedEventEnd)?;
            block.push(line);
            events.push(block.join("\n"));
        } else if let Some(block) = current.as_mut() {
            block.push(line);
        }
    }

    if current.is_some() {
        return Err(IcalParseError::UnclosedEvent);
    }

    Ok(events)
}

/// Check if a line matches a property name with exact boundary and ASCII case insensitivity.
fn property_matches(line: &str, field: &str) -> bool {
    if line.len() < field.len() {
        return false;
    }

    let (name, rest) = line.split_at(field.len());
    name.eq_ignore_ascii_case(field)
        && matches!(rest.as_bytes().first(), Some(b';' | b':'))
}

/// Extract a field value from a single VEVENT block.
pub fn extract_vevent_field(vevent: &str, field: &str) -> Option<String> {
    let unfolded = unfold_ical(vevent);
    for line in unfolded.lines() {
        if !property_matches(line, field) {
            continue;
        }

        let rest = &line[field.len()..];
        let colon_pos = rest.find(':')?;
        let value = rest[colon_pos + 1..].trim().to_string();
        if !value.is_empty() {
            return Some(value);
        }
    }
    None
}

/// Extract the TZID from a DTSTART or DTEND line in a VEVENT block.
pub fn extract_vevent_tzid(vevent: &str, field: &str) -> Option<String> {
    let unfolded = unfold_ical(vevent);
    for line in unfolded.lines() {
        if !property_matches(line, field) {
            continue;
        }
        let rest = &line[field.len()..];

        // Check for VALUE=DATE (all-day) — case insensitive
        let upper_rest = rest.to_ascii_uppercase();
        if upper_rest.contains("VALUE=DATE") {
            return None;
        }

        // Check for TZID= parameter
        if let Some(tzid_pos) = upper_rest.find("TZID=") {
            let after_tzid = &rest[tzid_pos + 5..];
            let end = after_tzid.find([':', ';']).unwrap_or(after_tzid.len());
            let tz = after_tzid[..end].trim();
            if !tz.is_empty() {
                return Some(tz.to_string());
            }
        }

        // Check for trailing Z (UTC)
        if let Some(colon_pos) = rest.find(':') {
            let value = rest[colon_pos + 1..].trim();
            if value.ends_with('Z') || value.ends_with('z') {
                return Some("UTC".to_string());
            }
        }

        return None;
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_single_vevent() {
        let ical = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nUID:abc\nEND:VEVENT\nEND:VCALENDAR";
        let blocks = split_vevents(ical).unwrap();
        assert_eq!(blocks.len(), 1);
        assert!(blocks[0].starts_with("BEGIN:VEVENT"));
        assert!(blocks[0].ends_with("END:VEVENT"));
    }

    #[test]
    fn split_no_vevent_returns_empty() {
        let ical = "BEGIN:VCALENDAR\nEND:VCALENDAR";
        let blocks = split_vevents(ical).unwrap();
        assert!(blocks.is_empty());
    }

    #[test]
    fn split_unclosed_and_nested_vevent_errors() {
        let unclosed = "BEGIN:VCALENDAR\nBEGIN:VEVENT\nUID:abc\n";
        assert_eq!(split_vevents(unclosed), Err(IcalParseError::UnclosedEvent));

        let nested = "BEGIN:VEVENT\nBEGIN:VEVENT\nEND:VEVENT\nEND:VEVENT";
        assert_eq!(split_vevents(nested), Err(IcalParseError::NestedEvent));

        let unexpected = "END:VEVENT";
        assert_eq!(split_vevents(unexpected), Err(IcalParseError::UnexpectedEventEnd));
    }

    #[test]
    fn extract_field_exact_boundary_and_case_insensitive() {
        let vevent = "BEGIN:VEVENT\nDTSTART-EXTRA:incorrect\ndtstart;TZID=Europe/Paris:20260310T100000\nEND:VEVENT";
        assert_eq!(
            extract_vevent_field(vevent, "DTSTART"),
            Some("20260310T100000".to_string())
        );
        assert_eq!(
            extract_vevent_tzid(vevent, "dtstart"),
            Some("Europe/Paris".to_string())
        );
    }
}
