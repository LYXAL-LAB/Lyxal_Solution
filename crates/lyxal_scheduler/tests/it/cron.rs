//! Expressions cron : jeux de cas repris de `croner`, Quartz (syntaxe `?`, `L`, `W`, `#`,
//! secondes, années ; jours de la semaine numérotés comme Vixie) et Croniq ; U1 et U2.

use crate::helpers::{cron_spec, first, reason};
use lyxal_scheduler::SpecReason;

const UTC: &str = "UTC";

#[test]
fn last_day_of_month() {
    assert_eq!(
        first(UTC, &["0 0 L * *"], "2026-01-15T00:00:00"),
        "2026-01-31T00:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 0 L * *"], "2026-02-01T00:00:00"),
        "2026-02-28T00:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 0 L 2 *"], "2028-02-01T00:00:00"),
        "2028-02-29T00:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 0 L * *"], "2026-04-02T00:00:00"),
        "2026-04-30T00:00:00+00:00"
    );
}

#[test]
fn last_weekday_of_month_5l() {
    // Dernier vendredi de janvier 2026 : le 30 ; de février : le 27.
    assert_eq!(
        first(UTC, &["0 12 * * 5L"], "2026-01-01T00:00:00"),
        "2026-01-30T12:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 12 * * FRIL"], "2026-02-01T00:00:00"),
        "2026-02-27T12:00:00+00:00"
    );
}

#[test]
fn nearest_weekday_15w() {
    // 15 février 2026 : dimanche → lundi 16 ; 15 août 2026 : samedi → vendredi 14 ;
    // 15 janvier 2026 : jeudi → le jour même.
    assert_eq!(
        first(UTC, &["0 9 15W * *"], "2026-02-01T00:00:00"),
        "2026-02-16T09:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 9 15W * *"], "2026-08-01T00:00:00"),
        "2026-08-14T09:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 9 15W * *"], "2026-01-01T00:00:00"),
        "2026-01-15T09:00:00+00:00"
    );
    // 1er février 2026 (dimanche) : le jour ouvré le plus proche reste dans le mois (lundi 2).
    assert_eq!(
        first(UTC, &["0 9 1W * *"], "2026-01-31T00:00:00"),
        "2026-02-02T09:00:00+00:00"
    );
}

#[test]
fn last_working_day_lw() {
    // 31 janvier 2026 : samedi → vendredi 30 ; 31 mai 2026 : dimanche → vendredi 29.
    assert_eq!(
        first(UTC, &["0 9 LW * *"], "2026-01-01T00:00:00"),
        "2026-01-30T09:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 9 LW * *"], "2026-05-01T00:00:00"),
        "2026-05-29T09:00:00+00:00"
    );
}

#[test]
fn nth_weekday_hash() {
    // Troisième samedi de janvier 2026 : le 17 ; deuxième lundi de mars 2026 : le 9.
    assert_eq!(
        first(UTC, &["0 10 * * 6#3"], "2026-01-01T00:00:00"),
        "2026-01-17T10:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 10 * * MON#2"], "2026-03-01T00:00:00"),
        "2026-03-09T10:00:00+00:00"
    );
    // Cinquième vendredi : seulement les mois qui en ont cinq (janvier 2026 : le 30).
    assert_eq!(
        first(UTC, &["0 10 * * 5#5"], "2026-01-01T00:00:00"),
        "2026-01-30T10:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 10 * * 5#5"], "2026-02-01T00:00:00"),
        "2026-05-29T10:00:00+00:00"
    );
}

#[test]
fn aliases() {
    let after = "2026-01-01T10:00:00"; // jeudi
    assert_eq!(first(UTC, &["@hourly"], after), "2026-01-01T11:00:00+00:00");
    assert_eq!(first(UTC, &["@daily"], after), "2026-01-02T00:00:00+00:00");
    assert_eq!(first(UTC, &["@weekly"], after), "2026-01-04T00:00:00+00:00");
    assert_eq!(
        first(UTC, &["@monthly"], after),
        "2026-02-01T00:00:00+00:00"
    );
    assert_eq!(first(UTC, &["@yearly"], after), "2027-01-01T00:00:00+00:00");
    assert_eq!(
        first(UTC, &["@annually"], after),
        "2027-01-01T00:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 8 * JAN-MAR MON-FRI"], after),
        "2026-01-02T08:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 8 * * sun"], after),
        "2026-01-04T08:00:00+00:00"
    );
}

#[test]
fn seconds_and_years() {
    assert_eq!(
        first(UTC, &["30 15 10 * * *"], "2026-01-01T10:15:00"),
        "2026-01-01T10:15:30+00:00"
    );
    // Année : 7 champs (avec 6, le premier champ est celui des secondes).
    assert_eq!(
        first(UTC, &["0 0 0 1 1 * 2028"], "2026-01-01T10:00:00"),
        "2028-01-01T00:00:00+00:00"
    );
    assert_eq!(
        reason(&cron_spec(UTC, &["0 0 1 1 * 2028"])),
        SpecReason::CronSyntax
    );
    assert_eq!(
        first(UTC, &["0 0 0 1 1 * 2027"], "2026-01-01T10:00:00"),
        "2027-01-01T00:00:00+00:00"
    );
    // Année passée : plus aucune échéance.
    assert_eq!(
        first(UTC, &["0 0 0 1 1 * 2020"], "2026-01-01T10:00:00"),
        "aucune"
    );
}

#[test]
fn february_29() {
    assert_eq!(
        first(UTC, &["0 0 29 2 *"], "2026-01-01T00:00:00"),
        "2028-02-29T00:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 0 29 2 *"], "2028-02-29T00:00:00"),
        "2032-02-29T00:00:00+00:00"
    );
}

#[test]
fn day_of_month_or_day_of_week_u2() {
    // Jour du mois OU jour de la semaine (Vixie, POSIX) : les lundis et le 1er du mois.
    let spec = crate::helpers::parse(&cron_spec(UTC, &["0 9 1 * MON"]));
    let got = crate::helpers::next_n(&spec, crate::helpers::ts("2026-01-26T10:00:00Z"), 3);
    assert_eq!(
        got,
        [
            "2026-02-01T09:00:00+00:00", // dimanche 1er
            "2026-02-02T09:00:00+00:00", // lundi
            "2026-02-09T09:00:00+00:00",
        ]
    );
    // `?` de Quartz accepté (jour non précisé).
    assert_eq!(
        first(UTC, &["0 0 9 ? * MON"], "2026-01-01T10:00:00"),
        "2026-01-05T09:00:00+00:00"
    );
    assert_eq!(
        first(UTC, &["0 0 9 15 * ?"], "2026-01-01T10:00:00"),
        "2026-01-15T09:00:00+00:00"
    );
    // Joker sur le jour du mois : le jour de la semaine seul compte.
    assert_eq!(
        first(UTC, &["0 9 * * 1"], "2026-01-01T10:00:00"),
        "2026-01-05T09:00:00+00:00"
    );
}

#[test]
fn invalid_expressions() {
    for expr in [
        "",
        "61 * * * *",
        "* * *",
        "0 0 32 * *",
        "0 24 * * *",
        "0 0 * 13 *",
        "0 0 * * 8",
        "a b c d e",
        "0 0 * * MON#6",
        "0 0 0 1 1 * 2027 x",
        "@every_minute",
        // U2 : le préfixe `+` (jour du mois ET jour de la semaine) est refusé
        "0 9 1 * +MON",
    ] {
        assert_eq!(
            reason(&cron_spec(UTC, &[expr])),
            SpecReason::CronSyntax,
            "{expr:?}"
        );
    }
    // Exclusion illisible : même refus, règle nommée.
    let mut spec = cron_spec(UTC, &["0 9 * * *"]);
    spec.exclude_cron = vec!["0 0 * *".to_string()];
    let err = crate::helpers::parse_err(&spec);
    assert_eq!(
        (err.rule.as_str(), err.reason),
        ("exclude_cron[0]", SpecReason::CronSyntax)
    );
}

#[test]
fn several_seconds_per_minute_refused_u1() {
    for expr in ["*/30 * * * * *", "0,30 * * * * *", "* * * * * *"] {
        assert_eq!(
            reason(&cron_spec(UTC, &[expr])),
            SpecReason::MinInterval,
            "{expr:?}"
        );
    }
    // Une seule valeur de secondes : accepté, une minute au moins entre deux échéances.
    let spec = crate::helpers::parse(&cron_spec(UTC, &["15 * * * * *"]));
    let got = crate::helpers::next_n(&spec, crate::helpers::ts("2026-01-01T00:00:00Z"), 2);
    assert_eq!(
        got,
        ["2026-01-01T00:00:15+00:00", "2026-01-01T00:01:15+00:00"]
    );
}

#[test]
fn timezone_of_the_schedule() {
    assert_eq!(
        first("Europe/Paris", &["0 9 * * *"], "2026-01-01T10:00:00"),
        "2026-01-02T09:00:00+01:00"
    );
    assert_eq!(
        first("Asia/Kolkata", &["0 9 * * *"], "2026-01-01T08:00:00"),
        "2026-01-01T09:00:00+05:30"
    );
    assert_eq!(
        reason(&cron_spec("Europe/Atlantis", &["0 9 * * *"])),
        SpecReason::Timezone
    );
    assert_eq!(reason(&cron_spec("", &["0 9 * * *"])), SpecReason::Timezone);
}
