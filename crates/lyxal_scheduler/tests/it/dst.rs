//! Changement d'heure (S5, règle d'Oban et de `croner`) : heure inexistante → juste après le
//! saut ; heure répétée → une seule exécution pour une heure fixe, les deux passages pour un
//! joker ou un pas. Europe/Paris (29 mars et 25 octobre 2026) et America/New_York (8 mars et
//! 1er novembre 2026).

use crate::helpers::{at_local, cron_spec, next_n, parse};

const PARIS: &str = "Europe/Paris";
const NEW_YORK: &str = "America/New_York";

fn run(tz: &str, expr: &str, after: &str, n: usize) -> Vec<String> {
    next_n(&parse(&cron_spec(tz, &[expr])), at_local(tz, after), n)
}

#[test]
fn paris_spring_fixed_time_runs_just_after_the_jump() {
    assert_eq!(
        run(PARIS, "30 2 * * *", "2026-03-28T12:00:00", 3),
        [
            "2026-03-29T03:00:00+02:00",
            "2026-03-30T02:30:00+02:00",
            "2026-03-31T02:30:00+02:00"
        ]
    );
    // Heure fixe à la minute pile du saut.
    assert_eq!(
        run(PARIS, "0 2 * * *", "2026-03-28T12:00:00", 1),
        ["2026-03-29T03:00:00+02:00"]
    );
}

#[test]
fn paris_spring_wildcard_and_step_skip_the_missing_hour() {
    assert_eq!(
        run(PARIS, "*/15 * * * *", "2026-03-29T01:40:00", 3),
        [
            "2026-03-29T01:45:00+01:00",
            "2026-03-29T03:00:00+02:00",
            "2026-03-29T03:15:00+02:00"
        ]
    );
    // Toutes les minutes de 2 h : aucune ce jour-là, la suivante le lendemain.
    assert_eq!(
        run(PARIS, "* 2 * * *", "2026-03-29T01:00:00", 1),
        ["2026-03-30T02:00:00+02:00"]
    );
}

#[test]
fn paris_autumn_fixed_time_runs_once() {
    assert_eq!(
        run(PARIS, "30 2 * * *", "2026-10-24T12:00:00", 2),
        ["2026-10-25T02:30:00+02:00", "2026-10-26T02:30:00+01:00"]
    );
}

#[test]
fn paris_autumn_wildcard_and_step_run_on_both_passes() {
    assert_eq!(
        run(PARIS, "*/30 * * * *", "2026-10-25T01:45:00", 5),
        [
            "2026-10-25T02:00:00+02:00",
            "2026-10-25T02:30:00+02:00",
            "2026-10-25T02:00:00+01:00",
            "2026-10-25T02:30:00+01:00",
            "2026-10-25T03:00:00+01:00"
        ]
    );
    assert_eq!(
        run(PARIS, "0 * * * *", "2026-10-25T01:30:00", 3),
        [
            "2026-10-25T02:00:00+02:00",
            "2026-10-25T02:00:00+01:00",
            "2026-10-25T03:00:00+01:00"
        ]
    );
}

#[test]
fn new_york_spring_fixed_time_runs_just_after_the_jump() {
    assert_eq!(
        run(NEW_YORK, "30 2 * * *", "2026-03-07T12:00:00", 2),
        ["2026-03-08T03:00:00-04:00", "2026-03-09T02:30:00-04:00"]
    );
    assert_eq!(
        run(NEW_YORK, "*/20 * * * *", "2026-03-08T01:30:00", 3),
        [
            "2026-03-08T01:40:00-05:00",
            "2026-03-08T03:00:00-04:00",
            "2026-03-08T03:20:00-04:00"
        ]
    );
}

#[test]
fn new_york_autumn_fixed_once_wildcard_twice() {
    assert_eq!(
        run(NEW_YORK, "30 1 * * *", "2026-10-31T12:00:00", 2),
        ["2026-11-01T01:30:00-04:00", "2026-11-02T01:30:00-05:00"]
    );
    assert_eq!(
        run(NEW_YORK, "*/30 * * * *", "2026-11-01T00:45:00", 5),
        [
            "2026-11-01T01:00:00-04:00",
            "2026-11-01T01:30:00-04:00",
            "2026-11-01T01:00:00-05:00",
            "2026-11-01T01:30:00-05:00",
            "2026-11-01T02:00:00-05:00"
        ]
    );
}

#[test]
fn search_from_the_second_pass_does_not_go_back() {
    // Depuis le second passage de 2 h 10 (heure d'hiver), l'heure fixe de 2 h 30 a déjà eu lieu
    // au premier passage : prochaine le lendemain.
    let tz = jiff::tz::TimeZone::get(PARIS).expect("fuseau");
    let second_pass = tz
        .to_ambiguous_zoned("2026-10-25T02:10:00".parse().expect("heure"))
        .later()
        .expect("second passage")
        .timestamp();
    let spec = parse(&cron_spec(PARIS, &["30 2 * * *"]));
    assert_eq!(next_n(&spec, second_pass, 1), ["2026-10-26T02:30:00+01:00"]);
    let spec = parse(&cron_spec(PARIS, &["*/30 * * * *"]));
    assert_eq!(next_n(&spec, second_pass, 1), ["2026-10-25T02:30:00+01:00"]);
}
