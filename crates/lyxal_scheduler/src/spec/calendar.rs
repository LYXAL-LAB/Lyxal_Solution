//! Calendriers d'exceptions : règles lues depuis `scheduler_calendar.rules` (forme contrôlée
//! par `fn::scheduler_calendar_rules_check`) et évaluées sur l'heure locale du fuseau de la
//! planification.
//!
//! Une date est permise quand, pour **chaque** calendrier, **toutes** ses règles d'inclusion
//! correspondent et **aucune** de ses règles d'exclusion ne correspond (modèle Croniq). Dans une
//! règle, il suffit qu'une des valeurs corresponde.
//!
//! * `dates` : `AAAA-MM-JJ` ; `annual` : `MM-JJ` (un `02-29` ne vaut que les années bissextiles) ;
//! * `weekdays` : 1 (lundi) à 7 (dimanche) ; `monthdays` : 1 à 31 (un jour absent du mois ne
//!   correspond pas) ;
//! * `time_range` : `HH:MM-HH:MM`, début inclus, fin exclue ; une fin avant ou égale au début
//!   passe minuit (`22:00-06:00` ; `00:00-00:00` couvre la journée).

use jiff::civil::{Date, DateTime, Time};
use lyxal_surreal::Value;
use std::collections::BTreeSet;
use surrealdb::types::Number;

use crate::error::{SpecError, SpecReason};
use crate::models::{CalendarRule, RuleKind, RuleMode};

const MINUTES_PER_DAY: u16 = 24 * 60;

#[derive(Debug, Clone, PartialEq, Eq)]
enum Matcher {
    Dates(BTreeSet<Date>),
    Annual(BTreeSet<(i8, i8)>),
    Weekdays(BTreeSet<i8>),
    Monthdays(BTreeSet<i8>),
    /// Plages en minutes depuis minuit : (début inclus, fin exclue), fin > début après
    /// découpage des plages qui passent minuit.
    TimeRange(Vec<(u16, u16)>),
}

impl Matcher {
    fn is_time_level(&self) -> bool {
        matches!(self, Self::TimeRange(_))
    }

    fn matches(&self, local: DateTime) -> bool {
        match self {
            Self::Dates(dates) => dates.contains(&local.date()),
            Self::Annual(days) => days.contains(&(local.month(), local.day())),
            Self::Weekdays(days) => days.contains(&local.weekday().to_monday_one_offset()),
            Self::Monthdays(days) => days.contains(&local.day()),
            Self::TimeRange(ranges) => {
                let minute = minute_of_day(local.time());
                ranges.iter().any(|&(start, end)| start <= minute && minute < end)
            }
        }
    }

    /// Bornes des plages horaires (minutes depuis minuit).
    fn boundaries(&self) -> Vec<u16> {
        match self {
            Self::TimeRange(ranges) => ranges.iter().flat_map(|&(s, e)| [s, e]).collect(),
            _ => Vec::new(),
        }
    }
}

fn minute_of_day(time: Time) -> u16 {
    // Heure et minute toujours dans leurs bornes : aucune perte.
    (time.hour() as u16) * 60 + time.minute() as u16
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct Rule {
    mode: RuleMode,
    matcher: Matcher,
}

/// Règles d'un ensemble de calendriers, prêtes à l'évaluation.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct CalendarSet {
    calendars: Vec<Vec<Rule>>,
}

fn invalid(rule: &str, message: impl Into<String>) -> SpecError {
    SpecError::new(rule, SpecReason::CalendarRule, message)
}

fn as_text<'a>(rule: &str, value: &'a Value) -> Result<&'a str, SpecError> {
    match value {
        Value::String(text) => Ok(text),
        _ => Err(invalid(rule, "texte attendu")),
    }
}

fn as_int(rule: &str, value: &Value, min: i64, max: i64) -> Result<i8, SpecError> {
    match value {
        Value::Number(Number::Int(n)) if (min..=max).contains(n) => {
            i8::try_from(*n).map_err(|_| invalid(rule, "entier hors bornes"))
        }
        _ => Err(invalid(rule, format!("entier de {min} à {max} attendu"))),
    }
}

fn parse_hhmm(rule: &str, text: &str) -> Result<u16, SpecError> {
    let (h, m) = text
        .split_once(':')
        .ok_or_else(|| invalid(rule, "heure HH:MM attendue"))?;
    let hour: u16 = h.parse().map_err(|_| invalid(rule, "heure HH:MM attendue"))?;
    let minute: u16 = m.parse().map_err(|_| invalid(rule, "heure HH:MM attendue"))?;
    if h.len() != 2 || m.len() != 2 || hour > 23 || minute > 59 {
        return Err(invalid(rule, "heure HH:MM attendue (00:00 à 23:59)"));
    }
    Ok(hour * 60 + minute)
}

fn parse_matcher(rule: &str, kind: RuleKind, values: &[Value]) -> Result<Matcher, SpecError> {
    if values.is_empty() {
        return Err(invalid(rule, "au moins une valeur attendue"));
    }
    Ok(match kind {
        RuleKind::Dates => Matcher::Dates(
            values
                .iter()
                .map(|v| {
                    let text = as_text(rule, v)?;
                    if text.len() != 10 {
                        return Err(invalid(rule, "date AAAA-MM-JJ attendue"));
                    }
                    text.parse::<Date>()
                        .map_err(|e| invalid(rule, format!("date impossible : {e}")))
                })
                .collect::<Result<_, _>>()?,
        ),
        RuleKind::Annual => Matcher::Annual(
            values
                .iter()
                .map(|v| {
                    let text = as_text(rule, v)?;
                    let (m, d) = text
                        .split_once('-')
                        .ok_or_else(|| invalid(rule, "date MM-JJ attendue"))?;
                    let month: i8 = m.parse().map_err(|_| invalid(rule, "date MM-JJ attendue"))?;
                    let day: i8 = d.parse().map_err(|_| invalid(rule, "date MM-JJ attendue"))?;
                    // Année bissextile de référence : le 29 février est possible.
                    Date::new(2024, month, day)
                        .map_err(|e| invalid(rule, format!("date impossible : {e}")))?;
                    Ok((month, day))
                })
                .collect::<Result<_, _>>()?,
        ),
        RuleKind::Weekdays => Matcher::Weekdays(
            values
                .iter()
                .map(|v| as_int(rule, v, 1, 7))
                .collect::<Result<_, _>>()?,
        ),
        RuleKind::Monthdays => Matcher::Monthdays(
            values
                .iter()
                .map(|v| as_int(rule, v, 1, 31))
                .collect::<Result<_, _>>()?,
        ),
        RuleKind::TimeRange => {
            let mut ranges = Vec::new();
            for value in values {
                let text = as_text(rule, value)?;
                let (start, end) = text
                    .split_once('-')
                    .ok_or_else(|| invalid(rule, "plage HH:MM-HH:MM attendue"))?;
                let (start, end) = (parse_hhmm(rule, start)?, parse_hhmm(rule, end)?);
                if end > start {
                    ranges.push((start, end));
                } else {
                    // Passage de minuit : du début à minuit, puis de minuit à la fin.
                    ranges.push((start, MINUTES_PER_DAY));
                    if end > 0 {
                        ranges.push((0, end));
                    }
                }
            }
            Matcher::TimeRange(ranges)
        }
    })
}

/// Décision du calendrier pour une heure locale.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum Verdict {
    /// Date permise.
    Allowed,
    /// Date refusée ; aucune date permise avant cette heure locale (reprise de la recherche).
    BlockedUntil(DateTime),
}

impl CalendarSet {
    /// Ensemble vide : toute date est permise.
    pub fn empty() -> Self {
        Self::default()
    }

    /// Lit les règles de chaque calendrier (`calendars[i]` : règles du i-ème calendrier).
    pub fn parse(calendars: &[&[CalendarRule]]) -> Result<Self, SpecError> {
        let calendars = calendars
            .iter()
            .enumerate()
            .map(|(c, rules)| {
                rules
                    .iter()
                    .enumerate()
                    .map(|(r, rule)| {
                        let name = format!("calendars[{c}].rules[{r}]");
                        Ok(Rule {
                            mode: rule.mode,
                            matcher: parse_matcher(&name, rule.kind, &rule.values)?,
                        })
                    })
                    .collect::<Result<Vec<_>, SpecError>>()
            })
            .collect::<Result<Vec<_>, SpecError>>()?;
        Ok(Self { calendars })
    }

    /// Vrai si aucun calendrier n'est donné.
    pub fn is_empty(&self) -> bool {
        self.calendars.iter().all(Vec::is_empty)
    }

    /// Vrai si l'heure locale `local` est permise par tous les calendriers.
    pub fn allows(&self, local: DateTime) -> bool {
        matches!(self.verdict(local), Verdict::Allowed)
    }

    /// Décision pour l'heure locale `local`, avec l'heure locale de reprise de la recherche
    /// quand elle est refusée : le lendemain à minuit si une règle de date refuse, sinon la
    /// prochaine borne de plage horaire de la journée.
    pub(crate) fn verdict(&self, local: DateTime) -> Verdict {
        let mut date_blocked = false;
        let mut time_blocked = false;
        for rule in self.calendars.iter().flatten() {
            let hit = rule.matcher.matches(local);
            let refused = match rule.mode {
                RuleMode::Include => !hit,
                RuleMode::Exclude => hit,
            };
            if refused {
                if rule.matcher.is_time_level() {
                    time_blocked = true;
                } else {
                    date_blocked = true;
                }
            }
        }
        if !date_blocked && !time_blocked {
            return Verdict::Allowed;
        }
        let next_day = local
            .date()
            .tomorrow()
            .map(|d| d.to_datetime(Time::midnight()))
            .unwrap_or(DateTime::MAX);
        if date_blocked {
            return Verdict::BlockedUntil(next_day);
        }
        let now = minute_of_day(local.time());
        let boundary = self
            .calendars
            .iter()
            .flatten()
            .flat_map(|rule| rule.matcher.boundaries())
            .filter(|&b| b > now && b < MINUTES_PER_DAY)
            .min();
        let resume = boundary
            .and_then(|b| Time::new((b / 60) as i8, (b % 60) as i8, 0, 0).ok())
            .map(|time| local.date().to_datetime(time))
            .unwrap_or(next_day);
        Verdict::BlockedUntil(resume)
    }
}
