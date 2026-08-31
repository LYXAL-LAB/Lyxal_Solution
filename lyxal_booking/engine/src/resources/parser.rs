//! Pure iCalendar VEVENT parsing for resource feeds.

use uuid::Uuid;

use crate::utils::{extract_vevent_field, extract_vevent_tzid, parse_ical_datetime, split_vevents};
use super::model::ResourceEventInput;

/// Parse ISO 8601 / iCalendar DURATION strings like "P2D", "PT30M", "PT1H30M", "PT1H".
pub fn parse_ical_duration(value: &str) -> Option<chrono::Duration> {
    let value = value.trim();
    if !value.starts_with('P') {
        return None;
    }

    let mut days = 0_i64;
    let mut hours = 0_i64;
    let mut minutes = 0_i64;
    let mut number = String::new();
    let mut in_time = false;

    for ch in value[1..].chars() {
        match ch {
            'T' => in_time = true,
            '0'..='9' => number.push(ch),
            'D' => {
                days = number.parse().ok()?;
                number.clear();
            }
            'H' if in_time => {
                hours = number.parse().ok()?;
                number.clear();
            }
            'M' if in_time => {
                minutes = number.parse().ok()?;
                number.clear();
            }
            _ => return None,
        }
    }

    Some(
        chrono::Duration::days(days)
            + chrono::Duration::hours(hours)
            + chrono::Duration::minutes(minutes),
    )
}

/// Parse raw VEVENT string into a `ResourceEventInput` struct.
/// Applies the explicit DTEND / DURATION resolution policy:
/// - DTEND present -> raw_end_at = Some(DTEND)
/// - DTEND absent + DURATION present -> derive end time via parse_ical_duration
/// - DTEND & DURATION absent -> default 1h for timed (+1 hour), 1 day for all_day (+1 day)
pub fn parse_resource_event(vevent: &str) -> Option<ResourceEventInput> {
    let raw_start_at = extract_vevent_field(vevent, "DTSTART")?;
    if raw_start_at.is_empty() {
        return None;
    }

    let uid = extract_vevent_field(vevent, "UID").unwrap_or_else(|| Uuid::new_v4().to_string());
    let summary = extract_vevent_field(vevent, "SUMMARY");
    let status = extract_vevent_field(vevent, "STATUS");
    let rrule = extract_vevent_field(vevent, "RRULE");
    let recurrence_id = extract_vevent_field(vevent, "RECURRENCE-ID");
    let transp = extract_vevent_field(vevent, "TRANSP");
    let timezone = extract_vevent_tzid(vevent, "DTSTART");

    let all_day = raw_start_at.len() == 8 && raw_start_at.chars().all(|c| c.is_ascii_digit());

    let raw_dtend = extract_vevent_field(vevent, "DTEND");
    let raw_duration = extract_vevent_field(vevent, "DURATION");

    let start_at_dt = parse_ical_datetime(&raw_start_at)
        .map(|naive| surrealdb::sql::Datetime::from(naive.and_utc()));

    let (raw_end_at, end_at_dt) = match (raw_dtend, raw_duration) {
        (Some(dtend), _) if !dtend.trim().is_empty() => {
            let dt = parse_ical_datetime(&dtend)
                .map(|naive| surrealdb::sql::Datetime::from(naive.and_utc()));
            (Some(dtend), dt)
        }
        (_, Some(dur_str)) if !dur_str.trim().is_empty() => {
            let start_naive = parse_ical_datetime(&raw_start_at);
            let dur = parse_ical_duration(&dur_str).unwrap_or_else(|| {
                if all_day {
                    chrono::Duration::days(1)
                } else {
                    chrono::Duration::hours(1)
                }
            });
            let end_naive = start_naive.map(|s| s + dur);
            let end_raw = if all_day {
                end_naive.map(|e| e.format("%Y%m%d").to_string())
            } else {
                end_naive.map(|e| e.format("%Y%m%dT%H%M%SZ").to_string())
            };
            let dt = end_naive.map(|n| surrealdb::sql::Datetime::from(n.and_utc()));
            (end_raw, dt)
        }
        _ => {
            // Both DTEND and DURATION missing: calculate real +1 day for all_day, +1 hour for timed
            let start_naive = parse_ical_datetime(&raw_start_at);
            let add_dur = if all_day {
                chrono::Duration::days(1)
            } else {
                chrono::Duration::hours(1)
            };
            let end_naive = start_naive.map(|s| s + add_dur);
            let end_raw = if all_day {
                start_naive.map(|s| (s + chrono::Duration::days(1)).format("%Y%m%d").to_string())
            } else {
                end_naive.map(|e| e.format("%Y%m%dT%H%M%SZ").to_string())
            };
            let dt = end_naive.map(|n| surrealdb::sql::Datetime::from(n.and_utc()));
            (end_raw, dt)
        }
    };

    Some(ResourceEventInput {
        uid,
        recurrence_id,
        summary,
        start_at: start_at_dt,
        end_at: end_at_dt,
        raw_start_at,
        raw_end_at,
        all_day,
        timezone,
        rrule,
        raw_ical: vevent.to_string(),
        status,
        transp,
    })
}

/// Split full VCALENDAR body into individual VEVENT strings.
pub fn parse_calendar_events(body: &str) -> Vec<ResourceEventInput> {
    if !body.contains("BEGIN:VEVENT") {
        return Vec::new();
    }
    match split_vevents(body) {
        Ok(events) => events
            .into_iter()
            .filter_map(|vevent| parse_resource_event(&vevent))
            .collect(),
        Err(err) => {
            tracing::warn!(error = %err, "Failed to split VEVENT blocks from calendar body");
            Vec::new()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_ical_duration() {
        assert_eq!(parse_ical_duration("PT30M"), Some(chrono::Duration::minutes(30)));
        assert_eq!(parse_ical_duration("PT1H"), Some(chrono::Duration::hours(1)));
        assert_eq!(
            parse_ical_duration("PT1H30M"),
            Some(chrono::Duration::hours(1) + chrono::Duration::minutes(30))
        );
        assert_eq!(parse_ical_duration("P2D"), Some(chrono::Duration::days(2)));
    }

    #[test]
    fn test_parse_resource_event_duration_pt30m() {
        let vevent = "BEGIN:VEVENT\r\nUID:123\r\nDTSTART:20260730T090000Z\r\nDURATION:PT30M\r\nEND:VEVENT\r\n";
        let parsed = parse_resource_event(vevent).unwrap();
        assert_eq!(parsed.raw_start_at, "20260730T090000Z");
        assert_eq!(parsed.raw_end_at.as_deref(), Some("20260730T093000Z"));
    }

    #[test]
    fn test_parse_resource_event_duration_p2d() {
        let vevent = "BEGIN:VEVENT\r\nUID:124\r\nDTSTART:20260730\r\nDURATION:P2D\r\nEND:VEVENT\r\n";
        let parsed = parse_resource_event(vevent).unwrap();
        assert!(parsed.all_day);
        assert_eq!(parsed.raw_start_at, "20260730");
        assert_eq!(parsed.raw_end_at.as_deref(), Some("20260801"));
    }

    #[test]
    fn test_parse_resource_event_missing_dtend_timed() {
        let vevent = "BEGIN:VEVENT\r\nUID:125\r\nDTSTART:20260730T090000Z\r\nEND:VEVENT\r\n";
        let parsed = parse_resource_event(vevent).unwrap();
        assert_eq!(parsed.raw_start_at, "20260730T090000Z");
        assert_eq!(parsed.raw_end_at.as_deref(), Some("20260730T100000Z"));
    }

    #[test]
    fn test_parse_resource_event_missing_dtend_allday() {
        let vevent = "BEGIN:VEVENT\r\nUID:126\r\nDTSTART:20260730\r\nEND:VEVENT\r\n";
        let parsed = parse_resource_event(vevent).unwrap();
        assert!(parsed.all_day);
        assert_eq!(parsed.raw_start_at, "20260730");
        assert_eq!(parsed.raw_end_at.as_deref(), Some("20260731"));
    }
}
