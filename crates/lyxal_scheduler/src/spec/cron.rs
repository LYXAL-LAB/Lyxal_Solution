//! Expressions cron (`croner`) : lecture, prochaine date dans un fuseau, correspondance d'une
//! date (exclusions), et règle de changement d'heure (S5).
//!
//! Syntaxe : 5 à 7 champs (`[secondes] minutes heures jour-du-mois mois jour-de-semaine
//! [année]`), alias `@yearly`, `@annually`, `@monthly`, `@weekly`, `@daily`, `@hourly`, noms
//! `JAN`-`DEC` et `SUN`-`SAT`, `L`, `W`, `LW`, `#`, `?` (Quartz). Jours de la semaine de 0 à 7
//! (0 et 7 : dimanche, comme Vixie cron et POSIX ; pas la numérotation 1 à 7 de Quartz). Jour du
//! mois **ou** jour de la semaine quand les deux sont restreints (U2).
//!
//! Changement d'heure (règle d'Oban et de `croner`, conforme à OCPS) : une heure fixe qui tombe
//! dans le saut de printemps s'exécute au premier instant qui suit le saut ; une heure fixe
//! répétée à l'automne s'exécute une fois (premier passage) ; un joker ou un pas s'exécute à
//! chaque passage réel (les deux passages d'une heure répétée, aucun dans le saut).

use croner::errors::CronError;
use croner::parser::{CronParser, Seconds, Year};
use croner::Cron;
use jiff::tz::TimeZone;
use jiff::{SignedDuration, Timestamp};

use crate::error::{SpecError, SpecReason};

/// Expression cron lue, avec son texte d'origine.
#[derive(Debug, Clone)]
pub struct CronRule {
    source: String,
    cron: Cron,
    /// L'expression précise les secondes (6 ou 7 champs) ; sinon la correspondance d'une date
    /// (exclusions) se fait à la minute.
    with_seconds: bool,
}

/// Résultat de la recherche d'une prochaine date par `croner`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum CronNext {
    /// Prochaine date.
    At(Timestamp),
    /// L'expression ne donne plus aucune date (année passée, date impossible).
    Exhausted,
}

fn parser() -> CronParser {
    CronParser::builder()
        .seconds(Seconds::Optional)
        .year(Year::Optional)
        .dom_and_dow(false)
        .alternative_weekdays(false)
        .sloppy_ranges(false)
        .build()
}

fn describe(error: &CronError) -> String {
    match error {
        CronError::EmptyPattern => "expression vide".to_string(),
        CronError::InvalidDate => "date invalide".to_string(),
        CronError::InvalidTime => "heure invalide".to_string(),
        CronError::TimeSearchLimitExceeded => "aucune date trouvée".to_string(),
        CronError::InvalidPattern(text)
        | CronError::IllegalCharacters(text)
        | CronError::ComponentError(text) => text.clone(),
    }
}

impl CronRule {
    /// Lit l'expression `source` ; `rule` nomme la règle dans l'erreur (`cron[0]`).
    ///
    /// Refuse une expression illisible et une expression à plusieurs valeurs de secondes, qui
    /// donnerait deux échéances dans la même minute (U1 : au moins une minute d'écart).
    pub fn parse(rule: &str, source: &str) -> Result<Self, SpecError> {
        let cron = parser()
            .parse(source)
            .map_err(|e| SpecError::new(rule, SpecReason::CronSyntax, describe(&e)))?;
        let fields = source.split_whitespace().count();
        let with_seconds = !source.trim_start().starts_with('@') && fields >= 6;
        if cron.pattern.seconds.values().len() != 1 {
            return Err(SpecError::new(
                rule,
                SpecReason::MinInterval,
                "plusieurs échéances dans la même minute : une seule valeur de secondes permise",
            ));
        }
        Ok(Self {
            source: source.to_string(),
            cron,
            with_seconds,
        })
    }

    /// Texte d'origine de l'expression.
    pub fn source(&self) -> &str {
        &self.source
    }

    /// Prochaine date strictement après `after`, lue dans le fuseau `tz` (règle de changement
    /// d'heure de `croner`).
    pub(crate) fn next_after(
        &self,
        rule: &str,
        after: Timestamp,
        tz: &TimeZone,
    ) -> Result<CronNext, SpecError> {
        match self.cron.find_next_occurrence(&after.to_zoned(tz.clone()), false) {
            Ok(next) => Ok(CronNext::At(next.timestamp())),
            Err(CronError::TimeSearchLimitExceeded) => Ok(CronNext::Exhausted),
            Err(error) => Err(SpecError::new(
                rule,
                SpecReason::OutOfRange,
                describe(&error),
            )),
        }
    }

    /// Vrai si la date `at`, lue dans le fuseau `tz`, correspond à l'expression ; à la minute
    /// près pour une expression sans secondes.
    pub(crate) fn matches(&self, rule: &str, at: Timestamp, tz: &TimeZone) -> Result<bool, SpecError> {
        let zoned = at.to_zoned(tz.clone());
        let probe = if self.with_seconds {
            zoned
        } else {
            let into_minute = SignedDuration::new(
                i64::from(zoned.second()),
                zoned.subsec_nanosecond(),
            );
            at.checked_sub(into_minute)
                .map_err(|e| SpecError::new(rule, SpecReason::OutOfRange, e.to_string()))?
                .to_zoned(tz.clone())
        };
        self.cron
            .is_time_matching(&probe)
            .map_err(|e| SpecError::new(rule, SpecReason::OutOfRange, describe(&e)))
    }
}
