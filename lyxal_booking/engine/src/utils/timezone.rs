//! Timezone Conversion Utilities & Error Types.

use chrono::{LocalResult, NaiveDateTime, TimeZone};
use chrono_tz::Tz;
use thiserror::Error;

/// Timezone conversion error types.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum DateTimeConversionError {
    #[error("Unknown timezone: {0}")]
    InvalidTimezone(String),

    #[error("Ambiguous local datetime {datetime} in {timezone}")]
    AmbiguousLocalDateTime {
        datetime: NaiveDateTime,
        timezone: String,
    },

    #[error("Nonexistent local datetime {datetime} in {timezone}")]
    NonexistentLocalDateTime {
        datetime: NaiveDateTime,
        timezone: String,
    },
}

/// Convert a `NaiveDateTime` from an event's timezone to a target timezone.
///
/// - If `event_tz` is `None` (floating) → returns `Ok(dt)` as-is.
/// - If `event_tz` is invalid IANA string → returns `Err(DateTimeConversionError::InvalidTimezone)`.
/// - If local time is ambiguous/nonexistent due to DST → returns explicit error.
pub fn convert_event_to_tz(
    dt: NaiveDateTime,
    event_tz: Option<&str>,
    target_tz: Tz,
) -> Result<NaiveDateTime, DateTimeConversionError> {
    let etz: Tz = match event_tz {
        Some(tz_str) => match tz_str.parse::<Tz>() {
            Ok(tz) => tz,
            Err(_) => return Err(DateTimeConversionError::InvalidTimezone(tz_str.to_string())),
        },
        None => return Ok(dt),
    };

    match etz.from_local_datetime(&dt) {
        LocalResult::Single(zoned) => Ok(zoned.with_timezone(&target_tz).naive_local()),
        LocalResult::Ambiguous(_, _) => Err(DateTimeConversionError::AmbiguousLocalDateTime {
            datetime: dt,
            timezone: etz.to_string(),
        }),
        LocalResult::None => Err(DateTimeConversionError::NonexistentLocalDateTime {
            datetime: dt,
            timezone: etz.to_string(),
        }),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::NaiveDate;

    #[test]
    fn convert_ny_to_paris() {
        let dt = NaiveDate::from_ymd_opt(2026, 7, 15)
            .unwrap()
            .and_hms_opt(10, 0, 0)
            .unwrap();
        let paris: Tz = "Europe/Paris".parse().unwrap();
        let res = convert_event_to_tz(dt, Some("America/New_York"), paris).unwrap();
        assert_eq!(
            res,
            NaiveDate::from_ymd_opt(2026, 7, 15)
                .unwrap()
                .and_hms_opt(16, 0, 0)
                .unwrap()
        );
    }

    #[test]
    fn convert_invalid_tz_errors() {
        let dt = NaiveDate::from_ymd_opt(2026, 7, 15)
            .unwrap()
            .and_hms_opt(10, 0, 0)
            .unwrap();
        let paris: Tz = "Europe/Paris".parse().unwrap();
        let res = convert_event_to_tz(dt, Some("Invalid/Zone"), paris);
        assert_eq!(
            res,
            Err(DateTimeConversionError::InvalidTimezone("Invalid/Zone".to_string()))
        );
    }

    #[test]
    fn convert_nonexistent_dst_errors() {
        let dt = NaiveDate::from_ymd_opt(2026, 3, 29)
            .unwrap()
            .and_hms_opt(2, 30, 0)
            .unwrap();
        let paris: Tz = "Europe/Paris".parse().unwrap();
        let res = convert_event_to_tz(dt, Some("Europe/Paris"), paris);
        assert_eq!(
            res,
            Err(DateTimeConversionError::NonexistentLocalDateTime {
                datetime: dt,
                timezone: "Europe/Paris".to_string(),
            })
        );
    }
}
