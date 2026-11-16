//! Heures calmes (décision B5) : un envoi non critique qui tombe dans une plage de l'abonné part à
//! la fin de la plage. Les plages sont exprimées dans le fuseau de l'abonné (sinon celui des
//! réglages, sinon UTC : choisi par `fn::notification_preference_resolve`) ; le calcul des dates
//! dans un fuseau se fait en Rust (`jiff`, base des fuseaux embarquée), comme celui de
//! `lyxal_scheduler`. Un changement d'heure est résolu de façon compatible (heure inexistante
//! avancée, heure ambiguë : la première).

use jiff::civil::Date;
use jiff::tz::TimeZone;
use jiff::{Timestamp, ToSpan};

use crate::models::{QuietHoursRule, QuietRange};

/// Plages enchaînées suivies au plus (une plage qui finit au début d'une autre prolonge le calme).
const MAX_CHAINED: usize = 16;

/// Fin des heures calmes en cours à `now`, ou `None` si l'envoi peut partir. Un fuseau inconnu est
/// lu comme UTC.
pub fn quiet_until(rule: &QuietHoursRule, now: Timestamp) -> Option<Timestamp> {
    let tz = TimeZone::get(&rule.timezone).unwrap_or(TimeZone::UTC);
    let mut probe = now;
    let mut until = None;
    for _ in 0..MAX_CHAINED {
        match window_end(&rule.ranges, &tz, probe) {
            Some(end) if end > probe => {
                until = Some(end);
                probe = end;
            }
            _ => break,
        }
    }
    until
}

/// Fin la plus tardive des plages qui contiennent `at` (plages commencées la veille ou le jour
/// même, dans le fuseau).
fn window_end(ranges: &[QuietRange], tz: &TimeZone, at: Timestamp) -> Option<Timestamp> {
    let today = at.to_zoned(tz.clone()).date();
    let yesterday = today.checked_sub(1.day()).ok()?;
    [yesterday, today]
        .into_iter()
        .flat_map(|day| ranges.iter().filter_map(move |range| span(range, day, tz)))
        .filter(|(start, end)| *start <= at && at < *end)
        .map(|(_, end)| end)
        .max()
}

/// Plage commencée le jour `day` (si c'est l'un de ses jours) : début et fin.
fn span(range: &QuietRange, day: Date, tz: &TimeZone) -> Option<(Timestamp, Timestamp)> {
    let weekday = i64::from(day.weekday().to_monday_one_offset());
    if !range.days.contains(&weekday) {
        return None;
    }
    let start = instant(day, range.start, tz)?;
    let end_day = if range.end > range.start {
        day
    } else {
        day.checked_add(1.day()).ok()?
    };
    let end = instant(end_day, range.end, tz)?;
    Some((start, end))
}

/// Instant d'une minute de la journée (0 à 1439) un jour donné, dans le fuseau.
fn instant(day: Date, minute: i64, tz: &TimeZone) -> Option<Timestamp> {
    if !(0..1440).contains(&minute) {
        return None;
    }
    let hour = i8::try_from(minute / 60).ok()?;
    let minute = i8::try_from(minute % 60).ok()?;
    day.at(hour, minute, 0, 0)
        .to_zoned(tz.clone())
        .ok()
        .map(|zoned| zoned.timestamp())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn rule(timezone: &str, ranges: Vec<QuietRange>) -> QuietHoursRule {
        QuietHoursRule {
            timezone: timezone.into(),
            ranges,
        }
    }

    fn range(days: &[i64], start: i64, end: i64) -> QuietRange {
        QuietRange {
            days: days.to_vec(),
            start,
            end,
        }
    }

    fn at(text: &str) -> Timestamp {
        text.parse().expect("instant")
    }

    const EVERY_DAY: [i64; 7] = [1, 2, 3, 4, 5, 6, 7];

    #[test]
    fn a_range_across_midnight_ends_the_next_morning_in_the_subscriber_zone() {
        // 22:00 → 07:00 à Montréal (UTC−5 en hiver)
        let night = rule("America/Montreal", vec![range(&EVERY_DAY, 1320, 420)]);
        // 23:30 locale (04:30 UTC le lendemain) : fin à 07:00 locale = 12:00 UTC
        assert_eq!(
            quiet_until(&night, at("2026-01-15T04:30:00Z")),
            Some(at("2026-01-15T12:00:00Z"))
        );
        // 02:00 locale, plage commencée la veille
        assert_eq!(
            quiet_until(&night, at("2026-01-15T07:00:00Z")),
            Some(at("2026-01-15T12:00:00Z"))
        );
        // 12:00 locale : pas de calme
        assert_eq!(quiet_until(&night, at("2026-01-15T17:00:00Z")), None);
        // Fin exclue
        assert_eq!(quiet_until(&night, at("2026-01-15T12:00:00Z")), None);
    }

    #[test]
    fn days_are_the_days_the_range_starts_on() {
        // Vendredi soir 20:00 → samedi 08:00, à Paris (UTC+1 en hiver)
        let weekend = rule("Europe/Paris", vec![range(&[5], 1200, 480)]);
        // Samedi 2026-01-17 06:00 locale : plage commencée vendredi
        assert_eq!(
            quiet_until(&weekend, at("2026-01-17T05:00:00Z")),
            Some(at("2026-01-17T07:00:00Z"))
        );
        // Samedi 21:00 : samedi n'ouvre pas de plage
        assert_eq!(quiet_until(&weekend, at("2026-01-17T20:00:00Z")), None);
    }

    #[test]
    fn chained_ranges_extend_the_quiet_period_and_utc_is_the_fallback() {
        let chained = rule(
            "Zone/Inconnue",
            vec![range(&EVERY_DAY, 0, 360), range(&EVERY_DAY, 360, 480)],
        );
        assert_eq!(
            quiet_until(&chained, at("2026-03-02T01:00:00Z")),
            Some(at("2026-03-02T08:00:00Z"))
        );
        // start == end : la journée entière
        let all_day = rule("UTC", vec![range(&[1], 600, 600)]);
        assert_eq!(
            quiet_until(&all_day, at("2026-03-02T12:00:00Z")),
            Some(at("2026-03-03T10:00:00Z"))
        );
    }

    #[test]
    fn a_daylight_saving_change_is_handled() {
        // Nuit du passage à l'heure d'été à Paris (29 mars 2026) : 01:00 → 04:00 locale
        let night = rule("Europe/Paris", vec![range(&EVERY_DAY, 60, 240)]);
        // 01:30 locale = 00:30 UTC ; fin à 04:00 locale (heure d'été) = 02:00 UTC
        assert_eq!(
            quiet_until(&night, at("2026-03-29T00:30:00Z")),
            Some(at("2026-03-29T02:00:00Z"))
        );
    }
}
