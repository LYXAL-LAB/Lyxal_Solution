//! iCalendar Recurrence Engine (Lyxal Booking RRULE Subset).
//!
//! Supports `DAILY`, `WEEKLY`, `MONTHLY` with `INTERVAL`, `COUNT`, `UNTIL`, `BYDAY`.
//! Rejects unsupported rule components (`BYMONTHDAY`, `BYSETPOS`, `YEARLY`, `WKST != MO`, duplicate parts, etc.) explicitly via `RRuleError`.

use chrono::{Datelike, Duration, LocalResult, NaiveDate, NaiveDateTime, TimeZone, Weekday};
use chrono_tz::Tz;
use thiserror::Error;

/// Recurrence Engine Error Types.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum RRuleError {
    #[error("Missing FREQ part")]
    MissingFrequency,

    #[error("Unsupported FREQ: {0}")]
    UnsupportedFrequency(String),

    #[error("Invalid INTERVAL (must be > 0)")]
    InvalidInterval,

    #[error("Invalid COUNT (must be > 0)")]
    InvalidCount,

    #[error("Invalid UNTIL date format: {0}")]
    InvalidUntil(String),

    #[error("Invalid BYDAY syntax: {0}")]
    InvalidByDay(String),

    #[error("Unsupported RRULE component: {0}")]
    UnsupportedRulePart(String),

    #[error("Duplicate RRULE component: {0}")]
    DuplicateRulePart(String),

    #[error("COUNT and UNTIL cannot be used together")]
    CountAndUntilConflict,

    #[error("Event end <= event start")]
    InvalidEventDuration,

    #[error("Invalid expansion window")]
    InvalidWindow,

    #[error("DTSTART weekday does not match specified BYDAY")]
    StartDoesNotMatchRule,

    #[error("UNTIL type is incompatible with DTSTART")]
    UntilTypeMismatch,

    #[error("Ambiguous local datetime: {0}")]
    AmbiguousLocalDateTime(NaiveDateTime),

    #[error("Nonexistent local datetime: {0}")]
    NonexistentLocalDateTime(NaiveDateTime),

    #[error("Scan limit exceeded ({0} periods)")]
    ExpansionScanLimitExceeded(usize),

    #[error("Returned limit exceeded ({0} items)")]
    ExpansionReturnedLimitExceeded(usize),
}

/// Time basis for recurrence evaluation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RecurrenceTimeBasis {
    Floating,
    Utc,
    Zoned(Tz),
}

/// Typed exclusion date/datetime entry.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum ExDate {
    Date(NaiveDate),
    DateTime(NaiveDateTime),
    Utc(chrono::DateTime<chrono::Utc>),
}

/// Parsed UNTIL representation.
#[derive(Debug, Clone, PartialEq, Eq)]
enum Until {
    Date(NaiveDate),
    Floating(NaiveDateTime),
    Utc(chrono::DateTime<chrono::Utc>),
}

/// Internal parsed RRULE representation.
struct RRule {
    freq: Freq,
    interval: u32,
    until: Option<Until>,
    count: Option<u32>,
    by_day: Vec<ByDay>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Freq {
    Daily,
    Weekly,
    Monthly,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct ByDay {
    weekday: Weekday,
    nth: Option<i32>, // e.g. 2 for "2nd Monday", -1 for "last Friday", None for "all"
}

const MAX_PERIODS_SCANNED: usize = 100_000;
const MAX_OCCURRENCES_RETURNED: usize = 10_000;

pub use crate::utils::unfold_ical;

/// Parse compact iCalendar UTC string like "20260315T093000Z".
pub fn parse_ical_utc(value: &str) -> Option<chrono::DateTime<chrono::Utc>> {
    let raw = value.strip_suffix('Z')?;
    let naive = NaiveDateTime::parse_from_str(raw, "%Y%m%dT%H%M%S").ok()?;
    Some(naive.and_utc())
}

/// Convert local occurrence datetime to UTC for UNTIL / UTC EXDATE comparison.
fn occurrence_to_utc(
    occurrence: NaiveDateTime,
    basis: RecurrenceTimeBasis,
) -> Result<chrono::DateTime<chrono::Utc>, RRuleError> {
    match basis {
        RecurrenceTimeBasis::Utc => Ok(occurrence.and_utc()),
        RecurrenceTimeBasis::Zoned(tz) => match tz.from_local_datetime(&occurrence) {
            LocalResult::Single(value) => Ok(value.with_timezone(&chrono::Utc)),
            LocalResult::Ambiguous(_, _) => {
                Err(RRuleError::AmbiguousLocalDateTime(occurrence))
            }
            LocalResult::None => Err(RRuleError::NonexistentLocalDateTime(occurrence)),
        },
        RecurrenceTimeBasis::Floating => Err(RRuleError::UntilTypeMismatch),
    }
}

/// Systematically validate local occurrence datetime for zoned time bases.
fn validate_occurrence_time(
    occurrence: NaiveDateTime,
    basis: RecurrenceTimeBasis,
) -> Result<(), RRuleError> {
    if let RecurrenceTimeBasis::Zoned(_) = basis {
        occurrence_to_utc(occurrence, basis)?;
    }
    Ok(())
}

/// Collect exclusions (`EXDATE` and `RECURRENCE-ID`) from master & override VEVENTs.
/// Note: EXDATEs with explicit per-property TZID parameters assume the event's `RecurrenceTimeBasis`.
pub fn collect_recurrence_exclusions(
    master_raw_ical: &str,
    overrides_raw_ical: &[&str],
) -> Vec<ExDate> {
    let mut exclusions = Vec::new();
    let unfolded_master = unfold_ical(master_raw_ical);

    // Extract EXDATEs from master VEVENT
    for line in unfolded_master.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("EXDATE") {
            if let Some(colon) = trimmed.find(':') {
                let values = &trimmed[colon + 1..];
                for val in values.split(',') {
                    let v = val.trim();
                    if v.len() == 8 && v.chars().all(|c| c.is_ascii_digit()) {
                        if let Ok(d) = NaiveDate::parse_from_str(v, "%Y%m%d") {
                            exclusions.push(ExDate::Date(d));
                        }
                    } else if v.ends_with('Z') {
                        if let Some(utc_dt) = parse_ical_utc(v) {
                            exclusions.push(ExDate::Utc(utc_dt));
                        }
                    } else if let Some(dt) = crate::utils::parse_ical_datetime(v) {
                        exclusions.push(ExDate::DateTime(dt));
                    }
                }
            }
        }
    }

    // Extract RECURRENCE-ID from overrides
    for override_ical in overrides_raw_ical {
        let unfolded_override = unfold_ical(override_ical);
        for line in unfolded_override.lines() {
            let trimmed = line.trim();
            if trimmed.starts_with("RECURRENCE-ID") {
                if let Some(colon) = trimmed.find(':') {
                    let v = trimmed[colon + 1..].trim();
                    if v.len() == 8 && v.chars().all(|c| c.is_ascii_digit()) {
                        if let Ok(d) = NaiveDate::parse_from_str(v, "%Y%m%d") {
                            exclusions.push(ExDate::Date(d));
                        }
                    } else if v.ends_with('Z') {
                        if let Some(utc_dt) = parse_ical_utc(v) {
                            exclusions.push(ExDate::Utc(utc_dt));
                        }
                    } else if let Some(dt) = crate::utils::parse_ical_datetime(v) {
                        exclusions.push(ExDate::DateTime(dt));
                    }
                }
            }
        }
    }

    // Clean allocation-free sorting & deduplication
    exclusions.sort();
    exclusions.dedup();
    exclusions
}

/// Expand a recurring event into occurrences within `[window_start, window_end)`.
pub fn expand_rrule(
    event_start: NaiveDateTime,
    event_end: NaiveDateTime,
    rrule_str: &str,
    exclusions: &[ExDate],
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    time_basis: RecurrenceTimeBasis,
) -> Result<Vec<(NaiveDateTime, NaiveDateTime)>, RRuleError> {
    if window_end <= window_start {
        return Err(RRuleError::InvalidWindow);
    }
    if event_end <= event_start {
        return Err(RRuleError::InvalidEventDuration);
    }

    let rrule = parse_rrule(rrule_str, time_basis)?;
    let event_duration = event_end - event_start;

    /// Lyxal strictness rule:
    /// DTSTART must match the supported BYDAY pattern.
    if !rrule.by_day.is_empty() {
        match rrule.freq {
            Freq::Weekly => {
                let matches_byday = rrule
                    .by_day
                    .iter()
                    .any(|bd| bd.weekday == event_start.weekday());
                if !matches_byday {
                    return Err(RRuleError::StartDoesNotMatchRule);
                }
            }
            Freq::Monthly => {
                let occurrences_first_month = generate_monthly_occurrences(
                    event_start.year(),
                    event_start.month(),
                    event_start.day(),
                    &rrule.by_day,
                );
                if !occurrences_first_month.contains(&event_start.date()) {
                    return Err(RRuleError::StartDoesNotMatchRule);
                }
            }
            _ => {}
        }
    }

    let mut results = Vec::new();
    let mut scanned_count = 0usize;
    let mut count_total = 0u32;

    match rrule.freq {
        Freq::Daily => {
            let mut current_date = event_start.date();

            // Fast-forward for series without COUNT
            if rrule.count.is_none() && window_start.date() > event_start.date() {
                let days_diff = (window_start.date() - event_start.date()).num_days();
                let interval_days = rrule.interval as i64;
                let skipped_intervals = days_diff / interval_days;
                if skipped_intervals > 0 {
                    current_date = event_start.date() + Duration::days(skipped_intervals * interval_days);
                }
            }

            loop {
                scanned_count += 1;
                if scanned_count > MAX_PERIODS_SCANNED {
                    return Err(RRuleError::ExpansionScanLimitExceeded(MAX_PERIODS_SCANNED));
                }

                let occ_start = current_date.and_time(event_start.time());
                validate_occurrence_time(occ_start, time_basis)?;

                let occ_end = occ_start + event_duration;

                if is_until_exceeded(occ_start, rrule.until.as_ref(), time_basis)? {
                    break;
                }
                if occ_start >= window_end {
                    break;
                }

                count_total += 1;
                if let Some(count) = rrule.count {
                    if count_total > count {
                        break;
                    }
                }

                if !is_excluded(occ_start, exclusions, time_basis)? && occ_end > window_start {
                    results.push((occ_start, occ_end));
                    if results.len() > MAX_OCCURRENCES_RETURNED {
                        return Err(RRuleError::ExpansionReturnedLimitExceeded(MAX_OCCURRENCES_RETURNED));
                    }
                }

                current_date += Duration::days(rrule.interval as i64);
            }
        }
        Freq::Weekly => {
            let mut weekdays: Vec<Weekday> = if rrule.by_day.is_empty() {
                vec![event_start.weekday()]
            } else {
                rrule.by_day.iter().map(|bd| bd.weekday).collect()
            };
            weekdays.sort_by_key(|w| w.num_days_from_monday());
            weekdays.dedup();

            let event_week_start = week_start(event_start.date());
            let mut current_week = event_week_start;

            // Fast-forward for weekly series without COUNT
            if rrule.count.is_none() && window_start.date() > event_start.date() {
                let weeks_diff = (window_start.date() - event_week_start).num_weeks();
                let interval_weeks = rrule.interval as i64;
                let skipped_intervals = weeks_diff / interval_weeks;
                if skipped_intervals > 0 {
                    current_week = event_week_start + Duration::weeks(skipped_intervals * interval_weeks);
                }
            }

            loop {
                scanned_count += 1;
                if scanned_count > MAX_PERIODS_SCANNED {
                    return Err(RRuleError::ExpansionScanLimitExceeded(MAX_PERIODS_SCANNED));
                }

                for &wd in &weekdays {
                    let day = current_week + Duration::days(weekday_offset(wd));
                    let occ_start = day.and_time(event_start.time());

                    if occ_start < event_start {
                        continue;
                    }

                    validate_occurrence_time(occ_start, time_basis)?;
                    let occ_end = occ_start + event_duration;

                    if is_until_exceeded(occ_start, rrule.until.as_ref(), time_basis)? {
                        return Ok(results);
                    }
                    if occ_start >= window_end {
                        return Ok(results);
                    }

                    count_total += 1;
                    if let Some(count) = rrule.count {
                        if count_total > count {
                            return Ok(results);
                        }
                    }

                    if occ_end > window_start && !is_excluded(occ_start, exclusions, time_basis)? {
                        results.push((occ_start, occ_end));
                        if results.len() > MAX_OCCURRENCES_RETURNED {
                            return Err(RRuleError::ExpansionReturnedLimitExceeded(MAX_OCCURRENCES_RETURNED));
                        }
                    }
                }

                current_week += Duration::weeks(rrule.interval as i64);
            }
        }
        Freq::Monthly => {
            let mut year = event_start.year();
            let mut month = event_start.month();

            loop {
                scanned_count += 1;
                if scanned_count > MAX_PERIODS_SCANNED {
                    return Err(RRuleError::ExpansionScanLimitExceeded(MAX_PERIODS_SCANNED));
                }

                let occurrences_this_month = generate_monthly_occurrences(
                    year,
                    month,
                    event_start.day(),
                    &rrule.by_day,
                );

                for day in occurrences_this_month {
                    let occ_start = day.and_time(event_start.time());

                    if occ_start < event_start {
                        continue;
                    }

                    validate_occurrence_time(occ_start, time_basis)?;
                    let occ_end = occ_start + event_duration;

                    if is_until_exceeded(occ_start, rrule.until.as_ref(), time_basis)? {
                        return Ok(results);
                    }
                    if occ_start >= window_end {
                        return Ok(results);
                    }

                    count_total += 1;
                    if let Some(count) = rrule.count {
                        if count_total > count {
                            return Ok(results);
                        }
                    }

                    if occ_end > window_start && !is_excluded(occ_start, exclusions, time_basis)? {
                        results.push((occ_start, occ_end));
                        if results.len() > MAX_OCCURRENCES_RETURNED {
                            return Err(RRuleError::ExpansionReturnedLimitExceeded(MAX_OCCURRENCES_RETURNED));
                        }
                    }
                }

                month += rrule.interval;
                while month > 12 {
                    month -= 12;
                    year += 1;
                }
            }
        }
    }

    Ok(results)
}

fn parse_rrule(s: &str, time_basis: RecurrenceTimeBasis) -> Result<RRule, RRuleError> {
    let unfolded = unfold_ical(s);
    let mut freq = None;
    let mut interval = 1u32;
    let mut until = None;
    let mut count = None;
    let mut by_day = Vec::new();

    let mut seen_freq = false;
    let mut seen_interval = false;
    let mut seen_until = false;
    let mut seen_count = false;
    let mut seen_by_day = false;
    let mut seen_wkst = false;

    for part in unfolded.split(';') {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }

        if let Some(val) = part.strip_prefix("FREQ=") {
            if seen_freq {
                return Err(RRuleError::DuplicateRulePart("FREQ".to_string()));
            }
            seen_freq = true;
            freq = match val {
                "DAILY" => Some(Freq::Daily),
                "WEEKLY" => Some(Freq::Weekly),
                "MONTHLY" => Some(Freq::Monthly),
                other => return Err(RRuleError::UnsupportedFrequency(other.to_string())),
            };
        } else if let Some(val) = part.strip_prefix("INTERVAL=") {
            if seen_interval {
                return Err(RRuleError::DuplicateRulePart("INTERVAL".to_string()));
            }
            seen_interval = true;
            interval = match val.parse::<u32>() {
                Ok(v) if v > 0 => v,
                _ => return Err(RRuleError::InvalidInterval),
            };
        } else if let Some(val) = part.strip_prefix("UNTIL=") {
            if seen_until {
                return Err(RRuleError::DuplicateRulePart("UNTIL".to_string()));
            }
            seen_until = true;
            until = Some(parse_until(val, time_basis)?);
        } else if let Some(val) = part.strip_prefix("COUNT=") {
            if seen_count {
                return Err(RRuleError::DuplicateRulePart("COUNT".to_string()));
            }
            seen_count = true;
            count = match val.parse::<u32>() {
                Ok(v) if v > 0 => Some(v),
                _ => return Err(RRuleError::InvalidCount),
            };
        } else if let Some(val) = part.strip_prefix("BYDAY=") {
            if seen_by_day {
                return Err(RRuleError::DuplicateRulePart("BYDAY".to_string()));
            }
            seen_by_day = true;

            for day_str in val.split(',') {
                let bd = parse_byday(day_str.trim())?;
                by_day.push(bd);
            }
        } else if let Some(val) = part.strip_prefix("WKST=") {
            if seen_wkst {
                return Err(RRuleError::DuplicateRulePart("WKST".to_string()));
            }
            seen_wkst = true;
            if val != "MO" {
                return Err(RRuleError::UnsupportedRulePart(format!("WKST={}", val)));
            }
        } else {
            let key = part.split('=').next().unwrap_or(part);
            return Err(RRuleError::UnsupportedRulePart(key.to_string()));
        }
    }

    let freq = freq.ok_or(RRuleError::MissingFrequency)?;

    // Reject COUNT + UNTIL conflict
    if count.is_some() && until.is_some() {
        return Err(RRuleError::CountAndUntilConflict);
    }

    // Reject unsupported BYDAY combinations
    if freq == Freq::Daily && !by_day.is_empty() {
        return Err(RRuleError::UnsupportedRulePart("BYDAY with DAILY".to_string()));
    }

    if freq == Freq::Weekly && by_day.iter().any(|bd| bd.nth.is_some()) {
        return Err(RRuleError::InvalidByDay(
            "Numeric BYDAY is unsupported with WEEKLY".to_string(),
        ));
    }

    Ok(RRule {
        freq,
        interval,
        until,
        count,
        by_day,
    })
}

fn parse_until(val: &str, time_basis: RecurrenceTimeBasis) -> Result<Until, RRuleError> {
    let trimmed = val.trim();
    if trimmed.ends_with('Z') {
        match time_basis {
            RecurrenceTimeBasis::Utc | RecurrenceTimeBasis::Zoned(_) => {
                let utc_dt = parse_ical_utc(trimmed)
                    .ok_or_else(|| RRuleError::InvalidUntil(val.to_string()))?;
                Ok(Until::Utc(utc_dt))
            }
            RecurrenceTimeBasis::Floating => Err(RRuleError::UntilTypeMismatch),
        }
    } else if trimmed.contains('T') {
        match time_basis {
            RecurrenceTimeBasis::Floating => {
                let naive = NaiveDateTime::parse_from_str(trimmed, "%Y%m%dT%H%M%S")
                    .map_err(|_| RRuleError::InvalidUntil(val.to_string()))?;
                Ok(Until::Floating(naive))
            }
            RecurrenceTimeBasis::Utc | RecurrenceTimeBasis::Zoned(_) => {
                Err(RRuleError::UntilTypeMismatch)
            }
        }
    } else {
        let date = NaiveDate::parse_from_str(trimmed, "%Y%m%d")
            .map_err(|_| RRuleError::InvalidUntil(val.to_string()))?;
        Ok(Until::Date(date))
    }
}

fn parse_byday(s: &str) -> Result<ByDay, RRuleError> {
    let (nth, code) = if s.len() >= 3 {
        let split_at = s.len() - 2;
        let num_part = &s[..split_at];
        let code_part = &s[split_at..];
        let n: i32 = num_part
            .parse()
            .map_err(|_| RRuleError::InvalidByDay(s.to_string()))?;

        if n == 0 || !(-5..=5).contains(&n) {
            return Err(RRuleError::InvalidByDay(s.to_string()));
        }

        (Some(n), code_part)
    } else {
        (None, s)
    };

    let weekday = match code {
        "MO" => Weekday::Mon,
        "TU" => Weekday::Tue,
        "WE" => Weekday::Wed,
        "TH" => Weekday::Thu,
        "FR" => Weekday::Fri,
        "SA" => Weekday::Sat,
        "SU" => Weekday::Sun,
        _ => return Err(RRuleError::InvalidByDay(s.to_string())),
    };

    Ok(ByDay { weekday, nth })
}

fn is_until_exceeded(
    occ_start: NaiveDateTime,
    until: Option<&Until>,
    basis: RecurrenceTimeBasis,
) -> Result<bool, RRuleError> {
    let u = match until {
        Some(u) => u,
        None => return Ok(false),
    };

    match u {
        Until::Date(d) => Ok(occ_start.date() > *d),
        Until::Floating(f) => Ok(occ_start > *f),
        Until::Utc(utc_until) => {
            let occ_utc = occurrence_to_utc(occ_start, basis)?;
            Ok(occ_utc > *utc_until)
        }
    }
}

fn is_excluded(
    occ_start: NaiveDateTime,
    exclusions: &[ExDate],
    basis: RecurrenceTimeBasis,
) -> Result<bool, RRuleError> {
    for exclusion in exclusions {
        let matches = match exclusion {
            ExDate::Date(d) => *d == occ_start.date(),
            ExDate::DateTime(dt) => *dt == occ_start,
            ExDate::Utc(utc_ex) => occurrence_to_utc(occ_start, basis)? == *utc_ex,
        };

        if matches {
            return Ok(true);
        }
    }

    Ok(false)
}

fn generate_monthly_occurrences(
    year: i32,
    month: u32,
    event_day: u32,
    by_day: &[ByDay],
) -> Vec<NaiveDate> {
    if by_day.is_empty() {
        return NaiveDate::from_ymd_opt(year, month, event_day)
            .into_iter()
            .collect();
    }

    let mut dates = Vec::new();
    for bd in by_day {
        match bd.nth {
            Some(n) => {
                if let Some(d) = nth_weekday_of_month(year, month, bd.weekday, n) {
                    dates.push(d);
                }
            }
            None => {
                dates.extend(all_weekdays_of_month(year, month, bd.weekday));
            }
        }
    }

    dates.sort();
    dates.dedup();
    dates
}

fn all_weekdays_of_month(year: i32, month: u32, weekday: Weekday) -> Vec<NaiveDate> {
    let mut dates = Vec::new();
    let mut day = 1;
    while let Some(d) = NaiveDate::from_ymd_opt(year, month, day) {
        if d.weekday() == weekday {
            dates.push(d);
        }
        day += 1;
    }
    dates
}

fn nth_weekday_of_month(year: i32, month: u32, weekday: Weekday, nth: i32) -> Option<NaiveDate> {
    let all = all_weekdays_of_month(year, month, weekday);
    if all.is_empty() {
        return None;
    }

    if nth > 0 {
        let idx = (nth - 1) as usize;
        all.get(idx).copied()
    } else if nth < 0 {
        let index = all.len() as i32 + nth;
        if index < 0 {
            None
        } else {
            all.get(index as usize).copied()
        }
    } else {
        None
    }
}

fn week_start(d: NaiveDate) -> NaiveDate {
    let offset = d.weekday().num_days_from_monday();
    d - Duration::days(offset as i64)
}

fn weekday_offset(w: Weekday) -> i64 {
    w.num_days_from_monday() as i64
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn zoned_daily_recurrence_rejects_nonexistent_dst_occurrence() {
        let tz: Tz = "Europe/Paris".parse().unwrap();
        // 2026-03-29 02:30:00 does not exist in Europe/Paris
        let start = NaiveDate::from_ymd_opt(2026, 3, 28)
            .unwrap()
            .and_hms_opt(2, 30, 0)
            .unwrap();

        let result = expand_rrule(
            start,
            start + Duration::hours(1),
            "FREQ=DAILY;COUNT=3",
            &[],
            start,
            start + Duration::days(4),
            RecurrenceTimeBasis::Zoned(tz),
        );

        let invalid = NaiveDate::from_ymd_opt(2026, 3, 29)
            .unwrap()
            .and_hms_opt(2, 30, 0)
            .unwrap();

        assert_eq!(
            result,
            Err(RRuleError::NonexistentLocalDateTime(invalid))
        );
    }

    #[test]
    fn test_utc_exdate_excludes_zoned_occurrence() {
        let tz: Tz = "Europe/Paris".parse().unwrap();
        // 10:30 Paris in March (UTC+1) is 09:30 UTC
        let start = NaiveDate::from_ymd_opt(2026, 3, 15)
            .unwrap()
            .and_hms_opt(10, 30, 0)
            .unwrap();
        let end = start + Duration::hours(1);
        let win_start = start - Duration::days(1);
        let win_end = start + Duration::days(5);

        let utc_ex = parse_ical_utc("20260315T093000Z").unwrap();
        let exclusions = vec![ExDate::Utc(utc_ex)];

        let res = expand_rrule(
            start,
            end,
            "FREQ=DAILY",
            &exclusions,
            win_start,
            win_end,
            RecurrenceTimeBasis::Zoned(tz),
        )
        .unwrap();

        // 2026-03-15 (10:30 Paris = 09:30 UTC) is excluded!
        assert!(!res.iter().any(|(s, _)| *s == start));
        assert!(res.iter().any(|(s, _)| s.date() == NaiveDate::from_ymd_opt(2026, 3, 16).unwrap()));
    }

    #[test]
    fn test_utc_recurrence_id_collected_as_utc() {
        let master = "BEGIN:VEVENT\r\nUID:xyz\r\nRRULE:FREQ=DAILY\r\nEXDATE:20260315T093000Z\r\nEND:VEVENT";
        let overrides = vec!["BEGIN:VEVENT\r\nUID:xyz\r\nRECURRENCE-ID:20260316T093000Z\r\nEND:VEVENT"];

        let exclusions = collect_recurrence_exclusions(master, &overrides);
        assert_eq!(exclusions.len(), 2);
        assert!(matches!(exclusions[0], ExDate::Utc(_)));
        assert!(matches!(exclusions[1], ExDate::Utc(_)));
    }

    #[test]
    fn test_monthly_without_byday_uses_dtstart_day() {
        let start = NaiveDate::from_ymd_opt(2026, 1, 15)
            .unwrap()
            .and_hms_opt(9, 0, 0)
            .unwrap();
        let end = start + Duration::hours(1);
        let win_start = start;
        let win_end = NaiveDate::from_ymd_opt(2026, 4, 1)
            .unwrap()
            .and_hms_opt(0, 0, 0)
            .unwrap();

        let res = expand_rrule(
            start,
            end,
            "FREQ=MONTHLY",
            &[],
            win_start,
            win_end,
            RecurrenceTimeBasis::Utc,
        )
        .unwrap();

        assert_eq!(res.len(), 3);
        assert_eq!(res[0].0.date(), NaiveDate::from_ymd_opt(2026, 1, 15).unwrap());
        assert_eq!(res[1].0.date(), NaiveDate::from_ymd_opt(2026, 2, 15).unwrap());
        assert_eq!(res[2].0.date(), NaiveDate::from_ymd_opt(2026, 3, 15).unwrap());
    }

    #[test]
    fn test_unfold_ical() {
        let folded = "EXDATE:20260309T100000,\r\n 20260316T100000,\r\n\t20260323T100000";
        let unfolded = unfold_ical(folded);
        assert_eq!(
            unfolded,
            "EXDATE:20260309T100000,20260316T100000,20260323T100000"
        );
    }
}
