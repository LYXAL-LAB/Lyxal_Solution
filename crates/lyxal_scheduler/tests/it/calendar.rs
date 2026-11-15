//! Calendriers d'exceptions : chaque sorte de règle en inclusion et en exclusion, plusieurs
//! calendriers, règles fausses, calendrier qui exclut tout (U4).

use crate::helpers::{cron_spec, int, next_n, parse_with, rule, text, ts};
use lyxal_scheduler::models::{RuleKind, RuleMode};
use lyxal_scheduler::{CalendarSet, Spec, SpecReason};

use RuleKind::{Annual, Dates, Monthdays, TimeRange, Weekdays};
use RuleMode::{Exclude, Include};

fn daily_nine() -> lyxal_scheduler::models::ScheduleSpec {
    cron_spec("UTC", &["0 9 * * *"])
}

#[test]
fn weekdays_include_and_exclude() {
    // Vendredi 2 janvier 2026, puis lundi 5 : le week-end est sauté.
    let working = [rule(Include, Weekdays, (1..=5).map(int).collect())];
    let spec = parse_with(&daily_nine(), &[&working[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-02T00:00:00Z"), 2),
        ["2026-01-02T09:00:00+00:00", "2026-01-05T09:00:00+00:00"]
    );
    let no_weekend = [rule(Exclude, Weekdays, vec![int(6), int(7)])];
    let spec = parse_with(&daily_nine(), &[&no_weekend[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-02T10:00:00Z"), 1),
        ["2026-01-05T09:00:00+00:00"]
    );
}

#[test]
fn dates_include_and_exclude() {
    let holidays = [rule(
        Exclude,
        Dates,
        vec![text("2026-01-02"), text("2026-01-03")],
    )];
    let spec = parse_with(&daily_nine(), &[&holidays[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-01T10:00:00Z"), 1),
        ["2026-01-04T09:00:00+00:00"]
    );
    let only = [rule(
        Include,
        Dates,
        vec![text("2026-03-10"), text("2026-01-20")],
    )];
    let spec = parse_with(&daily_nine(), &[&only[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-01T00:00:00Z"), 2),
        ["2026-01-20T09:00:00+00:00", "2026-03-10T09:00:00+00:00"]
    );
    // Après la dernière date incluse : aucune date permise dans les 5 ans (U4).
    assert_eq!(
        spec.next_after(ts("2026-03-10T09:00:00Z"))
            .expect_err("U4")
            .reason,
        SpecReason::NoFutureFire
    );
}

#[test]
fn annual_include_and_exclude() {
    let feasts = [rule(Exclude, Annual, vec![text("12-25"), text("01-01")])];
    let spec = parse_with(&daily_nine(), &[&feasts[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-12-24T10:00:00Z"), 2),
        ["2026-12-26T09:00:00+00:00", "2026-12-27T09:00:00+00:00"]
    );
    assert_eq!(
        next_n(&spec, ts("2026-12-31T10:00:00Z"), 1),
        ["2027-01-02T09:00:00+00:00"]
    );
    // 29 février : seulement les années bissextiles.
    let leap = [rule(Include, Annual, vec![text("02-29")])];
    let spec = parse_with(&daily_nine(), &[&leap[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-01T00:00:00Z"), 1),
        ["2028-02-29T09:00:00+00:00"]
    );
}

#[test]
fn monthdays_include_and_exclude() {
    let paydays = [rule(Include, Monthdays, vec![int(1), int(15), int(31)])];
    let spec = parse_with(&daily_nine(), &[&paydays[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-16T00:00:00Z"), 4),
        [
            "2026-01-31T09:00:00+00:00",
            "2026-02-01T09:00:00+00:00",
            "2026-02-15T09:00:00+00:00",
            "2026-03-01T09:00:00+00:00"
        ]
    );
    let not_first = [rule(Exclude, Monthdays, vec![int(1)])];
    let spec = parse_with(&daily_nine(), &[&not_first[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-31T10:00:00Z"), 1),
        ["2026-02-02T09:00:00+00:00"]
    );
}

#[test]
fn time_range_include_exclude_and_midnight() {
    let mut hourly = cron_spec("UTC", &["0 * * * *"]);
    hourly.cron = vec!["0 * * * *".to_string()];
    let office = [rule(
        Include,
        TimeRange,
        vec![text("09:00-12:00"), text("14:00-16:00")],
    )];
    let spec = parse_with(&hourly, &[&office[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-05T00:00:00Z"), 6),
        [
            "2026-01-05T09:00:00+00:00",
            "2026-01-05T10:00:00+00:00",
            "2026-01-05T11:00:00+00:00",
            "2026-01-05T14:00:00+00:00",
            "2026-01-05T15:00:00+00:00",
            "2026-01-06T09:00:00+00:00"
        ]
    );
    let night = [rule(Exclude, TimeRange, vec![text("22:00-06:00")])];
    let spec = parse_with(&hourly, &[&night[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-05T20:30:00Z"), 2),
        ["2026-01-05T21:00:00+00:00", "2026-01-06T06:00:00+00:00"]
    );
    let all_day = [rule(Include, TimeRange, vec![text("00:00-00:00")])];
    let spec = parse_with(&hourly, &[&all_day[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-05T20:30:00Z"), 1),
        ["2026-01-05T21:00:00+00:00"]
    );
}

#[test]
fn calendar_reads_local_time_of_the_schedule() {
    // 23 h 30 à Paris le vendredi = 22 h 30 UTC : la règle « samedi exclu » ne s'applique pas.
    let spec_paris = cron_spec("Europe/Paris", &["30 23 * * *"]);
    let no_saturday = [rule(Exclude, Weekdays, vec![int(6)])];
    let spec = parse_with(&spec_paris, &[&no_saturday[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-02T00:00:00Z"), 2),
        ["2026-01-02T23:30:00+01:00", "2026-01-04T23:30:00+01:00"]
    );
}

#[test]
fn every_calendar_must_allow() {
    let working = [rule(Include, Weekdays, (1..=5).map(int).collect())];
    let holidays = [rule(Exclude, Dates, vec![text("2026-01-05")])];
    let spec = parse_with(&daily_nine(), &[&working[..], &holidays[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-02T10:00:00Z"), 1),
        ["2026-01-06T09:00:00+00:00"]
    );
    // Dans un calendrier, toutes les inclusions : lundi ET entre 10 h et 11 h.
    let both = [
        rule(Include, Weekdays, vec![int(1)]),
        rule(Include, TimeRange, vec![text("10:00-11:00")]),
    ];
    let mut every_half_hour = cron_spec("UTC", &["*/30 * * * *"]);
    every_half_hour.timezone = "UTC".to_string();
    let spec = parse_with(&every_half_hour, &[&both[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-01-02T00:00:00Z"), 3),
        [
            "2026-01-05T10:00:00+00:00",
            "2026-01-05T10:30:00+00:00",
            "2026-01-12T10:00:00+00:00"
        ]
    );
}

#[test]
fn invalid_rules_refused() {
    for (kind, value) in [
        (Dates, text("2026-02-30")),
        (Dates, text("2026-1-05")),
        (Annual, text("02-30")),
        (Annual, text("13-01")),
        (TimeRange, text("25:00-26:00")),
        (TimeRange, text("09:00")),
        (Weekdays, int(0)),
        (Weekdays, text("lundi")),
        (Monthdays, int(32)),
    ] {
        let rules = [rule(Include, kind, vec![value.clone()])];
        let err = CalendarSet::parse(&[&rules[..]]).expect_err("règle refusée");
        assert_eq!(
            (err.rule.as_str(), err.reason),
            ("calendars[0].rules[0]", SpecReason::CalendarRule),
            "{kind:?} {value:?}"
        );
    }
}

#[test]
fn calendar_that_excludes_everything_stops_u4() {
    // Inclusion d'une date passée : aucune date permise dans les 5 ans (U4).
    let past = [rule(Include, Dates, vec![text("2020-01-01")])];
    let spec = parse_with(&daily_nine(), &[&past[..]]);
    let err = spec.next_after(ts("2026-01-01T00:00:00Z")).expect_err("U4");
    assert_eq!(err.reason, SpecReason::NoFutureFire);
    // Inclusion et exclusion du même jour.
    let never = [
        rule(Include, Weekdays, vec![int(1)]),
        rule(Exclude, Weekdays, vec![int(1)]),
    ];
    let spec = parse_with(&cron_spec("UTC", &["* * * * *"]), &[&never[..]]);
    let err = spec.next_after(ts("2026-01-01T00:00:00Z")).expect_err("U4");
    assert_eq!(err.reason, SpecReason::NoFutureFire);
    // Validation à l'écriture : même refus.
    let spec = Spec::parse(
        &daily_nine(),
        ts("2026-01-01T00:00:00Z"),
        CalendarSet::parse(&[&never[..]]).expect("calendrier"),
    )
    .expect("règles lues");
    assert_eq!(
        spec.validate(ts("2026-01-01T00:00:00Z"))
            .expect_err("U4")
            .reason,
        SpecReason::NoFutureFire
    );
}

#[test]
fn time_range_starting_inside_the_spring_gap_skips_nothing() {
    // Paris, 29 mars 2026 : 02:00 → 03:00. Plage 02:30-04:00, échéance chaque minute : la
    // première date permise est 03:00+02:00 (la bascule), pas 03:30 (début de plage déplacé
    // du temps du saut).
    let every_minute = cron_spec("Europe/Paris", &["* * * * *"]);
    let night = [rule(Include, TimeRange, vec![text("02:30-04:00")])];
    let spec = parse_with(&every_minute, &[&night[..]]);
    assert_eq!(
        next_n(&spec, ts("2026-03-29T00:58:00Z"), 3),
        [
            "2026-03-29T03:00:00+02:00",
            "2026-03-29T03:01:00+02:00",
            "2026-03-29T03:02:00+02:00"
        ]
    );
}
