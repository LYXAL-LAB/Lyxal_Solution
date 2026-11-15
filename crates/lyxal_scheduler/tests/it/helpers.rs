//! Outils des tests du calcul des dates.

use jiff::civil::DateTime;
use jiff::tz::TimeZone;
use jiff::{SignedDuration, Timestamp};
use lyxal_scheduler::models::{CalendarRule, RuleKind, RuleMode, ScheduleSpec, SchedulerValue};
use lyxal_scheduler::spec::{to_datetime, to_duration};
use lyxal_scheduler::{CalendarSet, Spec, SpecError, SpecReason};

/// Création des planifications de test.
pub fn created() -> Timestamp {
    ts("2026-01-01T00:00:00Z")
}

pub fn ts(text: &str) -> Timestamp {
    text.parse().expect("instant")
}

/// Instant de l'heure locale `local` (`2026-03-29T01:50:00`) dans le fuseau `tz` ; une heure
/// répétée prend le premier passage.
pub fn at_local(tz: &str, local: &str) -> Timestamp {
    let dt: DateTime = local.parse().expect("heure locale");
    TimeZone::get(tz)
        .expect("fuseau")
        .to_ambiguous_zoned(dt)
        .earlier()
        .expect("heure")
        .timestamp()
}

pub fn spec_of(tz: &str) -> ScheduleSpec {
    ScheduleSpec::new(tz)
}

pub fn cron_spec(tz: &str, exprs: &[&str]) -> ScheduleSpec {
    let mut spec = ScheduleSpec::new(tz);
    spec.cron = exprs.iter().map(|e| e.to_string()).collect();
    spec
}

pub fn parse(spec: &ScheduleSpec) -> Spec {
    Spec::parse(spec, created(), CalendarSet::empty()).expect("règles lues")
}

pub fn parse_with(spec: &ScheduleSpec, calendars: &[&[CalendarRule]]) -> Spec {
    Spec::parse(
        spec,
        created(),
        CalendarSet::parse(calendars).expect("calendriers"),
    )
    .expect("règles lues")
}

pub fn parse_err(spec: &ScheduleSpec) -> SpecError {
    Spec::parse(spec, created(), CalendarSet::empty()).expect_err("règles refusées")
}

pub fn reason(spec: &ScheduleSpec) -> SpecReason {
    parse_err(spec).reason
}

/// Échéances suivantes, en heure locale avec décalage (`2026-03-29T03:00:00+02:00`).
pub fn next_n(spec: &Spec, after: Timestamp, n: usize) -> Vec<String> {
    let mut out = Vec::new();
    let mut cursor = after;
    for _ in 0..n {
        let Some(t) = spec.next_after(cursor).expect("calcul") else {
            break;
        };
        let z = t.to_zoned(spec.time_zone().clone());
        out.push(z.strftime("%Y-%m-%dT%H:%M:%S%:z").to_string());
        cursor = t;
    }
    out
}

/// Première échéance après l'heure locale `after` du fuseau de `tz`.
pub fn first(tz: &str, exprs: &[&str], after: &str) -> String {
    let spec = parse(&cron_spec(tz, exprs));
    next_n(&spec, at_local(tz, after), 1)
        .pop()
        .unwrap_or_else(|| "aucune".to_string())
}

pub fn dt(text: &str) -> lyxal_scheduler::models::SchedulerDatetime {
    to_datetime(ts(text)).expect("date")
}

pub fn dur(secs: i64) -> lyxal_scheduler::models::SchedulerDuration {
    to_duration(SignedDuration::from_secs(secs)).expect("durée")
}

pub fn rule(mode: RuleMode, kind: RuleKind, values: Vec<SchedulerValue>) -> CalendarRule {
    CalendarRule { mode, kind, values }
}

pub fn text(v: &str) -> SchedulerValue {
    SchedulerValue::String(v.to_string())
}

pub fn int(v: i64) -> SchedulerValue {
    SchedulerValue::from_t(v)
}
