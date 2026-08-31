//! Recurrence expansion utilities for iCalendar events.

use chrono::NaiveDateTime;
use chrono_tz::Tz;

use crate::rrule::{collect_recurrence_exclusions, RecurrenceTimeBasis};
use crate::utils::{convert_event_to_tz, parse_ical_datetime};

/// Expand recurring events into (start, end) pairs within a time window.
/// Tuples are (start_at, end_at, rrule, raw_ical, timezone).
pub fn expand_recurring_into_busy(
    recurring: &[(String, String, String, Option<String>, Option<String>)],
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    host_tz: Tz,
) -> Vec<(NaiveDateTime, NaiveDateTime)> {
    let mut result = Vec::new();
    for (s, e, rrule_str, raw_ical, event_tz) in recurring {
        if let (Some(ev_start), Some(ev_end)) = (parse_ical_datetime(s), parse_ical_datetime(e)) {
            let master_ical = raw_ical.as_deref().unwrap_or("");
            let exclusions = collect_recurrence_exclusions(master_ical, &[]);

            let time_basis = match event_tz.as_deref() {
                Some(tz_str) => match tz_str.parse::<Tz>() {
                    Ok(tz) => RecurrenceTimeBasis::Zoned(tz),
                    Err(_) => RecurrenceTimeBasis::Floating,
                },
                None => RecurrenceTimeBasis::Floating,
            };

            // Expand RRULE in the event's own timezone basis (correct for DST)
            match crate::rrule::expand_rrule(
                ev_start,
                ev_end,
                rrule_str,
                &exclusions,
                window_start,
                window_end,
                time_basis,
            ) {
                Ok(occurrences) => {
                    for (os, oe) in occurrences {
                        let cs = match convert_event_to_tz(os, event_tz.as_deref(), host_tz) {
                            Ok(dt) => dt,
                            Err(err) => {
                                tracing::warn!(error = %err, "Failed to convert event start datetime");
                                os
                            }
                        };
                        let ce = match convert_event_to_tz(oe, event_tz.as_deref(), host_tz) {
                            Ok(dt) => dt,
                            Err(err) => {
                                tracing::warn!(error = %err, "Failed to convert event end datetime");
                                oe
                            }
                        };
                        result.push((cs, ce));
                    }
                }
                Err(error) => {
                    tracing::warn!(error = %error, "Failed to expand resource recurrence rule");
                }
            }
        }
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::NaiveDate;

    fn dt(y: i32, m: u32, d: u32, h: u32, mi: u32) -> NaiveDateTime {
        NaiveDate::from_ymd_opt(y, m, d)
            .unwrap()
            .and_hms_opt(h, mi, 0)
            .unwrap()
    }

    #[test]
    fn test_expand_recurring_empty() {
        let empty: Vec<(String, String, String, Option<String>, Option<String>)> = Vec::new();
        let window_start = NaiveDateTime::parse_from_str("2026-03-01 00:00:00", "%Y-%m-%d %H:%M:%S").unwrap();
        let window_end = NaiveDateTime::parse_from_str("2026-03-31 23:59:59", "%Y-%m-%d %H:%M:%S").unwrap();
        let busy = expand_recurring_into_busy(&empty, window_start, window_end, Tz::UTC);
        assert!(busy.is_empty());
    }

    #[test]
    fn expand_recurring_weekly_into_busy() {
        let recurring = vec![(
            "20260309T100000".to_string(), // Monday 10:00
            "20260309T110000".to_string(), // Monday 11:00
            "FREQ=WEEKLY;BYDAY=MO".to_string(),
            None,
            None,
        )];
        let window_start = dt(2026, 3, 9, 0, 0);
        let window_end = dt(2026, 3, 23, 23, 59);
        let busy = expand_recurring_into_busy(&recurring, window_start, window_end, Tz::UTC);
        // Should have 3 occurrences: Mar 9, 16, 23
        assert_eq!(busy.len(), 3);
        assert_eq!(busy[0].0, dt(2026, 3, 9, 10, 0));
        assert_eq!(busy[1].0, dt(2026, 3, 16, 10, 0));
        assert_eq!(busy[2].0, dt(2026, 3, 23, 10, 0));
    }

    #[test]
    fn expand_recurring_with_exdate() {
        let raw_ical = "BEGIN:VEVENT\nDTSTART:20260309T100000\nDTEND:20260309T110000\nRRULE:FREQ=WEEKLY;BYDAY=MO\nEXDATE:20260316T100000\nEND:VEVENT";
        let recurring = vec![(
            "20260309T100000".to_string(),
            "20260309T110000".to_string(),
            "FREQ=WEEKLY;BYDAY=MO".to_string(),
            Some(raw_ical.to_string()),
            None,
        )];
        let window_start = dt(2026, 3, 9, 0, 0);
        let window_end = dt(2026, 3, 23, 23, 59);
        let busy = expand_recurring_into_busy(&recurring, window_start, window_end, Tz::UTC);
        // Mar 16 excluded, so only Mar 9 and 23
        assert_eq!(busy.len(), 2);
        assert_eq!(busy[0].0, dt(2026, 3, 9, 10, 0));
        assert_eq!(busy[1].0, dt(2026, 3, 23, 10, 0));
    }
}
