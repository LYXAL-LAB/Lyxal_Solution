//! Calcul des dates d'une planification : lecture et contrôle des règles (`Spec::parse`,
//! `Spec::validate`), prochaine date (`Spec::next_after`), dates manquées entre deux instants
//! (`Spec::fire_times_between`), prévision (`Spec::forecast`) et décalage aléatoire
//! (`Spec::max_jitter`, `draw_jitter`). Fonctions pures, sans base ni horloge : l'instant de
//! référence est toujours un paramètre.
//!
//! Prochaine date après `t` : la plus petite parmi les expressions `cron` (fuseau de la
//! planification), les intervalles `every` (durée réelle depuis `start_at`, sinon depuis la
//! création, U3) et la date unique `at` ; une date qui correspond à une expression
//! `exclude_cron` ou refusée par un calendrier est écartée ; dans `[start_at, end_at]` ; rien
//! après `end_at`. Une recherche qui écarte des dates pendant plus de 5 ans ou 10 000 essais
//! s'arrête en erreur `no_future_fire` (U4).

mod calendar;
mod cron;
mod next;

pub use calendar::CalendarSet;
pub use cron::CronRule;
pub use next::{draw_jitter, FireTimes};

use jiff::tz::TimeZone;
use jiff::{SignedDuration, Timestamp};

use crate::error::{SpecError, SpecReason};
use crate::models::{SchedulerDatetime, SchedulerDuration, ScheduleSpec};

/// Écart minimal entre deux échéances d'une planification (U1).
pub const MIN_GAP: SignedDuration = SignedDuration::from_secs(60);
/// Décalage aléatoire maximal (U5).
pub const MAX_JITTER: SignedDuration = SignedDuration::from_secs(3600);
/// Durée maximale de la recherche d'une date, en années (U4).
pub const SEARCH_YEARS: i64 = 5;
/// Nombre maximal de dates écartées pendant une recherche (U4).
pub const SEARCH_TRIES: usize = 10_000;
/// Nombre maximal de dates manquées rendues par un appel (`fire_times_between`).
pub const MAX_FIRE_TIMES: usize = 1000;
/// Nombre maximal de dates d'une prévision.
pub const MAX_FORECAST: usize = 100;
/// Nombre de dates examinées pour mesurer le plus petit écart (U1, U5).
pub const GAP_SAMPLE: usize = 200;

/// Règles de dates d'une planification, lues et prêtes au calcul.
#[derive(Debug, Clone)]
pub struct Spec {
    pub(crate) crons: Vec<CronRule>,
    pub(crate) every: Vec<SignedDuration>,
    pub(crate) at: Option<Timestamp>,
    pub(crate) excludes: Vec<CronRule>,
    pub(crate) tz: TimeZone,
    pub(crate) start_at: Option<Timestamp>,
    pub(crate) end_at: Option<Timestamp>,
    pub(crate) jitter: Option<SignedDuration>,
    /// Ancre des intervalles : `start_at`, sinon la création (U3).
    pub(crate) anchor: Timestamp,
    /// Premier multiple de l'intervalle : 0 depuis `start_at` (première échéance au début),
    /// 1 depuis la création (première échéance un intervalle après).
    pub(crate) first_step: i128,
    pub(crate) calendars: CalendarSet,
}

/// Instant `jiff` d'un horodatage SurrealDB.
pub fn to_timestamp(rule: &str, value: &SchedulerDatetime) -> Result<Timestamp, SpecError> {
    let nanos = i32::try_from(value.timestamp_subsec_nanos())
        .map_err(|e| SpecError::new(rule, SpecReason::OutOfRange, e.to_string()))?;
    Timestamp::new(value.timestamp(), nanos)
        .map_err(|e| SpecError::new(rule, SpecReason::OutOfRange, e.to_string()))
}

/// Horodatage SurrealDB d'un instant `jiff`.
pub fn to_datetime(value: Timestamp) -> Result<SchedulerDatetime, SpecError> {
    let nanos = u32::try_from(value.subsec_nanosecond())
        .map_err(|e| SpecError::new("datetime", SpecReason::OutOfRange, e.to_string()))?;
    SchedulerDatetime::from_timestamp(value.as_second(), nanos).ok_or_else(|| {
        SpecError::new(
            "datetime",
            SpecReason::OutOfRange,
            "date hors de l'intervalle de SurrealDB",
        )
    })
}

/// Durée `jiff` d'une durée SurrealDB.
pub fn to_signed_duration(
    rule: &str,
    value: &SchedulerDuration,
) -> Result<SignedDuration, SpecError> {
    SignedDuration::try_from(value.into_inner())
        .map_err(|e| SpecError::new(rule, SpecReason::OutOfRange, e.to_string()))
}

/// Durée SurrealDB d'une durée `jiff` positive ou nulle.
pub fn to_duration(value: SignedDuration) -> Result<SchedulerDuration, SpecError> {
    std::time::Duration::try_from(value)
        .map(SchedulerDuration::from_std)
        .map_err(|e| SpecError::new("duration", SpecReason::OutOfRange, e.to_string()))
}

impl Spec {
    /// Lit les règles `spec` d'une planification créée à `created_at`, avec les règles de ses
    /// calendriers : syntaxe des expressions, fuseau IANA, intervalles d'au moins une minute
    /// (U1), décalage d'une heure au plus (U5), début avant la fin.
    pub fn parse(
        spec: &ScheduleSpec,
        created_at: Timestamp,
        calendars: CalendarSet,
    ) -> Result<Self, SpecError> {
        let tz = TimeZone::get(&spec.timezone).map_err(|e| {
            SpecError::new("timezone", SpecReason::Timezone, format!("{}: {e}", spec.timezone))
        })?;
        let crons = spec
            .cron
            .iter()
            .enumerate()
            .map(|(i, expr)| CronRule::parse(&format!("cron[{i}]"), expr))
            .collect::<Result<Vec<_>, _>>()?;
        let excludes = spec
            .exclude_cron
            .iter()
            .enumerate()
            .map(|(i, expr)| CronRule::parse(&format!("exclude_cron[{i}]"), expr))
            .collect::<Result<Vec<_>, _>>()?;
        let every = spec
            .every
            .iter()
            .enumerate()
            .map(|(i, step)| {
                let rule = format!("every[{i}]");
                let step = to_signed_duration(&rule, step)?;
                if step < MIN_GAP {
                    return Err(SpecError::new(
                        rule,
                        SpecReason::MinInterval,
                        "intervalle de moins d'une minute",
                    ));
                }
                Ok(step)
            })
            .collect::<Result<Vec<_>, _>>()?;
        let at = spec.at.as_ref().map(|v| to_timestamp("at", v)).transpose()?;
        let start_at = spec
            .start_at
            .as_ref()
            .map(|v| to_timestamp("start_at", v))
            .transpose()?;
        let end_at = spec
            .end_at
            .as_ref()
            .map(|v| to_timestamp("end_at", v))
            .transpose()?;
        let jitter = spec
            .jitter
            .as_ref()
            .map(|v| to_signed_duration("jitter", v))
            .transpose()?;
        if crons.is_empty() && every.is_empty() && at.is_none() {
            return Err(SpecError::new(
                "spec",
                SpecReason::Range,
                "au moins une expression cron, un intervalle ou une date unique",
            ));
        }
        if let (Some(start), Some(end)) = (start_at, end_at) {
            if end <= start {
                return Err(SpecError::new("end_at", SpecReason::Range, "fin avant le début"));
            }
        }
        if jitter.is_some_and(|j| j > MAX_JITTER) {
            return Err(SpecError::new("jitter", SpecReason::Jitter, "décalage de plus d'une heure"));
        }
        Ok(Self {
            crons,
            every,
            at,
            excludes,
            tz,
            start_at,
            end_at,
            jitter,
            anchor: start_at.unwrap_or(created_at),
            first_step: if start_at.is_some() { 0 } else { 1 },
            calendars,
        })
    }

    /// Fuseau horaire des expressions cron et des calendriers.
    pub fn time_zone(&self) -> &TimeZone {
        &self.tz
    }
}
