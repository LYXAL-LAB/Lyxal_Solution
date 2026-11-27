// SPDX-License-Identifier: AGPL-3.0-only

//! Dates des avis (`date-time` de la RFC 5322 §3.3, champs `Arrival-Date`, `Last-Attempt-Date`,
//! `Will-Retry-Until` de la RFC 3464). Lecture par `mail-parser` (même lecteur que le champ
//! `Date` des messages), écriture ici.

use mail_parser::DateTime;
use time::OffsetDateTime;

use crate::mime::to_offset_date_time;

const WEEKDAYS: [&str; 7] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const MONTHS: [&str; 12] = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

/// Écrit une date : `Fri, 27 Nov 2026 10:00:00 +0100` (secondes entières, décalage de la date).
pub fn format_date(date: OffsetDateTime) -> String {
    let weekday = WEEKDAYS
        .get(usize::from(date.weekday().number_days_from_monday()))
        .copied()
        .unwrap_or("Mon");
    let month = MONTHS
        .get(usize::from(u8::from(date.month())).saturating_sub(1))
        .copied()
        .unwrap_or("Jan");
    let offset = date.offset();
    let total_minutes =
        i32::from(offset.whole_hours()) * 60 + i32::from(offset.minutes_past_hour());
    let sign = if total_minutes < 0 { '-' } else { '+' };
    let total_minutes = total_minutes.unsigned_abs();
    format!(
        "{weekday}, {} {month} {:04} {:02}:{:02}:{:02} {sign}{:02}{:02}",
        date.day(),
        date.year(),
        date.hour(),
        date.minute(),
        date.second(),
        total_minutes / 60,
        total_minutes % 60,
    )
}

/// Lit une date ; `None` si elle est illisible ou n'existe pas au calendrier.
pub fn parse_date(value: &str) -> Option<OffsetDateTime> {
    to_offset_date_time(&DateTime::parse_rfc822(value.trim())?)
}

#[cfg(test)]
mod tests {
    use super::*;
    use time::macros::datetime;

    #[test]
    fn round_trip() {
        for date in [
            datetime!(2026-11-27 10:00:00 +01:00),
            datetime!(2000-02-29 23:59:59 -08:00),
            datetime!(2026-01-01 00:00:00 UTC),
            datetime!(2026-06-15 12:34:56 +05:30),
        ] {
            let written = format_date(date);
            assert_eq!(parse_date(&written), Some(date), "{written}");
        }
        assert_eq!(
            format_date(datetime!(2026-11-27 10:00:00 +01:00)),
            "Fri, 27 Nov 2026 10:00:00 +0100"
        );
        assert_eq!(parse_date("pas une date"), None);
    }
}
