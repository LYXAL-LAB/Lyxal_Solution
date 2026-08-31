//! Timezone conversion and display helpers for emails.

use chrono::NaiveDateTime;
use chrono_tz::Tz;

/// Convert date + start/end times from a guest timezone to UTC ICS format (YYYYMMDDTHHMMSSZ).
/// Falls back to floating time (no Z) if timezone parsing fails.
pub(crate) fn convert_to_utc(
    date: &str,
    start_time: &str,
    end_time: &str,
    timezone: &str,
) -> (String, String) {
    let fallback_start = format!(
        "{}T{}00",
        date.replace('-', ""),
        start_time.replace(':', "")
    );
    let fallback_end = format!("{}T{}00", date.replace('-', ""), end_time.replace(':', ""));

    let tz: Tz = match timezone.parse() {
        Ok(t) => t,
        Err(_) => return (fallback_start, fallback_end),
    };

    let start_naive = match NaiveDateTime::parse_from_str(
        &format!("{} {}:00", date, start_time),
        "%Y-%m-%d %H:%M:%S",
    ) {
        Ok(dt) => dt,
        Err(_) => return (fallback_start, fallback_end),
    };
    let end_naive = match NaiveDateTime::parse_from_str(
        &format!("{} {}:00", date, end_time),
        "%Y-%m-%d %H:%M:%S",
    ) {
        Ok(dt) => dt,
        Err(_) => return (fallback_start, fallback_end),
    };

    use chrono::TimeZone;
    let start_utc = match tz.from_local_datetime(&start_naive).earliest() {
        Some(dt) => dt.with_timezone(&chrono::Utc),
        None => return (fallback_start, fallback_end),
    };
    let end_utc = match tz.from_local_datetime(&end_naive).earliest() {
        Some(dt) => dt.with_timezone(&chrono::Utc),
        None => return (fallback_start, fallback_end),
    };

    (
        start_utc.format("%Y%m%dT%H%M%SZ").to_string(),
        end_utc.format("%Y%m%dT%H%M%SZ").to_string(),
    )
}

/// Convert a (date, start_time, end_time) tuple from `from_tz` into `to_tz`,
/// returning the wall-clock equivalents.
pub(crate) fn convert_time_between_tz(
    date: &str,
    start_time: &str,
    end_time: &str,
    from_tz: &str,
    to_tz: &str,
) -> Option<(String, String, String)> {
    use chrono::TimeZone;

    let from: Tz = from_tz.parse().ok()?;
    let to: Tz = to_tz.parse().ok()?;

    let start_naive =
        NaiveDateTime::parse_from_str(&format!("{} {}:00", date, start_time), "%Y-%m-%d %H:%M:%S")
            .ok()?;
    let end_naive =
        NaiveDateTime::parse_from_str(&format!("{} {}:00", date, end_time), "%Y-%m-%d %H:%M:%S")
            .ok()?;

    let start_target = from
        .from_local_datetime(&start_naive)
        .earliest()?
        .with_timezone(&to);
    let end_target = from
        .from_local_datetime(&end_naive)
        .earliest()?
        .with_timezone(&to);

    Some((
        start_target.format("%Y-%m-%d").to_string(),
        start_target.format("%H:%M").to_string(),
        end_target.format("%H:%M").to_string(),
    ))
}

/// Build the date + time strings to display in a host-targeted email.
pub fn host_time_display(
    date: &str,
    start_time: &str,
    end_time: &str,
    guest_timezone: &str,
    host_timezone: &str,
) -> (String, String) {
    if !host_timezone.is_empty() && host_timezone != guest_timezone {
        if let Some((host_date, host_start, host_end)) =
            convert_time_between_tz(date, start_time, end_time, guest_timezone, host_timezone)
        {
            return (
                host_date,
                format!("{} \u{2013} {} ({})", host_start, host_end, host_timezone),
            );
        }
    }

    let tz_label = if !guest_timezone.is_empty() {
        guest_timezone
    } else if !host_timezone.is_empty() {
        host_timezone
    } else {
        ""
    };

    let time_display = if tz_label.is_empty() {
        format!("{} \u{2013} {}", start_time, end_time)
    } else {
        format!("{} \u{2013} {} ({})", start_time, end_time, tz_label)
    };

    (date.to_string(), time_display)
}
