//! Intervalles (U3), bornes, date unique, exclusions, décalage aléatoire (U5), dates manquées,
//! prévision, écart minimal (U1), échéance future, limite d'essais (U4).

use crate::helpers::{cron_spec, dt, dur, next_n, parse, parse_err, reason, spec_of, ts};
use jiff::SignedDuration;
use lyxal_scheduler::spec::{draw_jitter, MAX_FIRE_TIMES};
use lyxal_scheduler::{CalendarSet, Spec, SpecReason};

#[test]
fn every_anchored_on_creation_or_start_u3() {
    // Sans début : depuis la création (1er janvier 2026 à 0 h UTC), première échéance un
    // intervalle après.
    let mut spec = spec_of("UTC");
    spec.every = vec![dur(6 * 3600)];
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2025-12-01T00:00:00Z"), 2),
        ["2026-01-01T06:00:00+00:00", "2026-01-01T12:00:00+00:00"]
    );
    assert_eq!(
        next_n(&parsed, ts("2026-01-03T13:00:00Z"), 1),
        ["2026-01-03T18:00:00+00:00"]
    );
    // Avec début : première échéance au début, puis tous les intervalles.
    spec.start_at = Some(dt("2026-01-10T03:15:00Z"));
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:00:00Z"), 2),
        ["2026-01-10T03:15:00+00:00", "2026-01-10T09:15:00+00:00"]
    );
}

#[test]
fn every_ignores_daylight_saving_u3() {
    // Toutes les 6 h en durée réelle à travers le passage à l'heure d'été de Paris.
    let mut spec = spec_of("Europe/Paris");
    spec.every = vec![dur(6 * 3600)];
    spec.start_at = Some(dt("2026-03-28T22:00:00Z"));
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-03-28T00:00:00Z"), 3),
        [
            "2026-03-28T23:00:00+01:00",
            "2026-03-29T06:00:00+02:00",
            "2026-03-29T12:00:00+02:00"
        ]
    );
}

#[test]
fn every_shorter_than_a_minute_refused_u1() {
    let mut spec = spec_of("UTC");
    spec.every = vec![dur(30)];
    let err = parse_err(&spec);
    assert_eq!(
        (err.rule.as_str(), err.reason),
        ("every[0]", SpecReason::MinInterval)
    );
}

#[test]
fn smallest_gap_between_rules_u1() {
    // Deux expressions à 30 s d'écart : refusées à l'écriture.
    let spec = parse(&cron_spec("UTC", &["0 9 * * *", "30 0 9 * * *"]));
    assert_eq!(
        spec.validate(ts("2026-01-01T00:00:00Z"))
            .expect_err("U1")
            .reason,
        SpecReason::MinInterval
    );
    // Expression et intervalle : 1 min d'écart au moins, accepté.
    let mut ok = cron_spec("UTC", &["0 9 * * *"]);
    ok.every = vec![dur(3600)];
    ok.start_at = Some(dt("2026-01-01T00:01:00Z"));
    parse(&ok)
        .validate(ts("2026-01-01T00:00:00Z"))
        .expect("écart d'une minute");
}

#[test]
fn bounds_start_and_end() {
    let mut spec = cron_spec("UTC", &["0 9 * * *"]);
    spec.start_at = Some(dt("2026-02-01T09:00:00Z"));
    spec.end_at = Some(dt("2026-02-03T09:00:00Z"));
    let parsed = parse(&spec);
    // Début et fin inclus ; rien après la fin.
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:00:00Z"), 5),
        [
            "2026-02-01T09:00:00+00:00",
            "2026-02-02T09:00:00+00:00",
            "2026-02-03T09:00:00+00:00"
        ]
    );
    assert_eq!(
        parsed
            .next_after(ts("2026-02-03T09:00:00Z"))
            .expect("calcul"),
        None
    );
    // Fin avant le début.
    spec.end_at = Some(dt("2026-01-01T00:00:00Z"));
    assert_eq!(reason(&spec), SpecReason::Range);
    // Aucune règle.
    assert_eq!(reason(&spec_of("UTC")), SpecReason::Range);
}

#[test]
fn single_date_at() {
    let mut spec = spec_of("UTC");
    spec.at = Some(dt("2026-05-01T08:00:00Z"));
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:00:00Z"), 3),
        ["2026-05-01T08:00:00+00:00"]
    );
    assert_eq!(
        parsed
            .next_after(ts("2026-05-01T08:00:00Z"))
            .expect("calcul"),
        None
    );
    // Date passée : aucune échéance future, refusée à l'écriture.
    assert_eq!(
        parsed
            .validate(ts("2026-06-01T00:00:00Z"))
            .expect_err("passée")
            .reason,
        SpecReason::NoFutureFire
    );
    // Avec une expression cron : la plus proche des deux.
    spec.cron = vec!["0 9 1 * *".to_string()];
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-04-15T00:00:00Z"), 3),
        [
            "2026-05-01T08:00:00+00:00",
            "2026-05-01T09:00:00+00:00",
            "2026-06-01T09:00:00+00:00"
        ]
    );
}

#[test]
fn exclude_cron_minute_and_second_precision() {
    // Jours ouvrés seulement.
    let mut spec = cron_spec("UTC", &["0 9 * * *"]);
    spec.exclude_cron = vec!["* * * * SAT,SUN".to_string()];
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-01-02T10:00:00Z"), 1),
        ["2026-01-05T09:00:00+00:00"]
    );
    // Exclusion sans secondes : toute la minute (intervalle à la 30e seconde).
    let mut spec = spec_of("UTC");
    spec.every = vec![dur(3600)];
    spec.start_at = Some(dt("2026-01-01T00:00:30Z"));
    spec.exclude_cron = vec!["0 1 * * *".to_string()];
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:30:00Z"), 1),
        ["2026-01-01T02:00:30+00:00"]
    );
    // Exclusion avec secondes : seulement cette seconde.
    spec.exclude_cron = vec!["0 0 1 * * *".to_string()];
    let parsed = parse(&spec);
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:30:00Z"), 1),
        ["2026-01-01T01:00:30+00:00"]
    );
}

#[test]
fn exclusion_of_every_date_stops_after_10000_tries_u4() {
    let mut spec = cron_spec("UTC", &["* * * * *"]);
    spec.exclude_cron = vec!["* * * * *".to_string()];
    let err = parse(&spec)
        .next_after(ts("2026-01-01T00:00:00Z"))
        .expect_err("U4");
    assert_eq!(err.reason, SpecReason::NoFutureFire);
    assert!(err.message.contains("10000"), "{}", err.message);
    // Expression dont la prochaine date est à plus de 5 ans.
    let err = parse(&cron_spec("UTC", &["0 0 0 1 1 * 2040"]))
        .next_after(ts("2026-01-01T00:00:00Z"))
        .expect_err("U4");
    assert_eq!(err.reason, SpecReason::NoFutureFire);
    // Date impossible : aucune échéance, refusée à l'écriture.
    let impossible = parse(&cron_spec("UTC", &["0 0 30 2 *"]));
    assert_eq!(
        impossible
            .next_after(ts("2026-01-01T00:00:00Z"))
            .expect("calcul"),
        None
    );
    assert_eq!(
        impossible
            .validate(ts("2026-01-01T00:00:00Z"))
            .expect_err("jamais")
            .reason,
        SpecReason::NoFutureFire
    );
}

#[test]
fn jitter_bounds_u5() {
    // Plus d'une heure : refusé.
    let mut spec = cron_spec("UTC", &["0 */6 * * *"]);
    spec.jitter = Some(dur(3601));
    assert_eq!(reason(&spec), SpecReason::Jitter);
    // Plus de la moitié du plus petit écart (toutes les 10 min) : refusé à l'écriture.
    let mut spec = cron_spec("UTC", &["*/10 * * * *"]);
    spec.jitter = Some(dur(301));
    let parsed = parse(&spec);
    assert_eq!(
        parsed
            .validate(ts("2026-01-01T00:00:00Z"))
            .expect_err("U5")
            .reason,
        SpecReason::Jitter
    );
    spec.jitter = Some(dur(300));
    let parsed = parse(&spec);
    parsed
        .validate(ts("2026-01-01T00:00:00Z"))
        .expect("moitié de l'écart");
    assert_eq!(
        parsed
            .max_jitter(ts("2026-01-01T00:00:00Z"))
            .expect("borne"),
        SignedDuration::from_secs(300)
    );
    // Toutes les 6 h avec 1 h : borne d'une heure.
    let mut spec = cron_spec("UTC", &["0 */6 * * *"]);
    spec.jitter = Some(dur(3600));
    assert_eq!(
        parse(&spec)
            .max_jitter(ts("2026-01-01T00:00:00Z"))
            .expect("borne"),
        SignedDuration::from_secs(3600)
    );
    // Sans décalage : zéro.
    assert_eq!(
        parse(&cron_spec("UTC", &["0 9 * * *"]))
            .max_jitter(ts("2026-01-01T00:00:00Z"))
            .expect("borne"),
        SignedDuration::ZERO
    );
}

#[test]
fn draw_jitter_stays_within_bounds_u5() {
    let max = SignedDuration::from_secs(90);
    let draws: Vec<SignedDuration> = (0..1000)
        .map(|_| draw_jitter(max).expect("tirage"))
        .collect();
    assert!(draws
        .iter()
        .all(|d| *d >= SignedDuration::ZERO && *d <= max));
    // Tirages répartis : pas tous identiques.
    assert!(draws.iter().any(|d| *d != draws[0]));
    assert_eq!(
        draw_jitter(SignedDuration::ZERO).expect("tirage"),
        SignedDuration::ZERO
    );
}

#[test]
fn missed_fire_times_between_two_instants() {
    let parsed = parse(&cron_spec("UTC", &["*/10 * * * *"]));
    // ]from, to] : début exclu, fin incluse.
    let got = parsed
        .fire_times_between(ts("2026-01-01T00:00:00Z"), ts("2026-01-01T01:00:00Z"), 1000)
        .expect("calcul");
    assert_eq!(got.times.len(), 6);
    assert_eq!(got.times[0], ts("2026-01-01T00:10:00Z"));
    assert_eq!(got.times[5], ts("2026-01-01T01:00:00Z"));
    assert!(!got.truncated);
    // Limite de 1000 : reprise après la dernière date rendue.
    let parsed = parse(&cron_spec("UTC", &["* * * * *"]));
    let from = ts("2026-01-01T00:00:00Z");
    let to = ts("2026-01-03T00:00:00Z");
    let first = parsed.fire_times_between(from, to, 5000).expect("calcul");
    assert_eq!(first.times.len(), MAX_FIRE_TIMES);
    assert!(first.truncated);
    let last = *first.times.last().expect("dernière");
    let second = parsed.fire_times_between(last, to, 5000).expect("calcul");
    assert_eq!(
        (second.times.len(), second.truncated),
        (MAX_FIRE_TIMES, true)
    );
    let last = *second.times.last().expect("dernière");
    let rest = parsed.fire_times_between(last, to, 5000).expect("calcul");
    assert_eq!(rest.times.len(), 2 * 24 * 60 - 2 * MAX_FIRE_TIMES);
    assert!(!rest.truncated);
    assert_eq!(rest.times.last(), Some(&to));
    // Limite plus petite demandée.
    let few = parsed.fire_times_between(from, to, 3).expect("calcul");
    assert_eq!((few.times.len(), few.truncated), (3, true));
    // Rien dans l'intervalle.
    let none = parse(&cron_spec("UTC", &["0 9 * * *"]))
        .fire_times_between(ts("2026-01-01T10:00:00Z"), ts("2026-01-01T12:00:00Z"), 10)
        .expect("calcul");
    assert_eq!((none.times.len(), none.truncated), (0, false));
}

#[test]
fn forecast_with_local_time() {
    let parsed = parse(&cron_spec("Europe/Paris", &["30 2 * * *"]));
    let got = parsed
        .forecast(ts("2026-03-27T12:00:00Z"), 3)
        .expect("prévision");
    let shown: Vec<String> = got.iter().map(|z| z.to_string()).collect();
    assert_eq!(
        shown,
        [
            "2026-03-28T02:30:00+01:00[Europe/Paris]",
            "2026-03-29T03:00:00+02:00[Europe/Paris]",
            "2026-03-30T02:30:00+02:00[Europe/Paris]"
        ]
    );
    // 100 au plus.
    let many = parse(&cron_spec("UTC", &["* * * * *"]))
        .forecast(ts("2026-01-01T00:00:00Z"), 500)
        .expect("prévision");
    assert_eq!(many.len(), 100);
    // Moins de dates qu'il n'en est demandé : celles qui restent.
    let mut once = spec_of("UTC");
    once.at = Some(dt("2026-05-01T08:00:00Z"));
    assert_eq!(
        parse(&once)
            .forecast(ts("2026-01-01T00:00:00Z"), 5)
            .expect("prévision")
            .len(),
        1
    );
}

#[test]
fn anchor_is_the_creation_when_given() {
    let mut spec = spec_of("UTC");
    spec.every = vec![dur(3600)];
    let parsed =
        Spec::parse(&spec, ts("2026-01-01T00:20:00Z"), CalendarSet::empty()).expect("règles lues");
    assert_eq!(
        next_n(&parsed, ts("2026-01-01T00:00:00Z"), 2),
        ["2026-01-01T01:20:00+00:00", "2026-01-01T02:20:00+00:00"]
    );
}
