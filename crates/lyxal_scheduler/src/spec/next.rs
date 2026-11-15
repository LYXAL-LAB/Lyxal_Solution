//! Prochaine date, dates entre deux instants, prévision, contrôle des écarts et décalage
//! aléatoire.

use jiff::tz::AmbiguousOffset;
use jiff::{SignedDuration, Span, Timestamp, Zoned};
use rand_core::{OsRng, RngCore};

use super::calendar::Verdict;
use super::cron::CronNext;
use super::{
    Spec, GAP_SAMPLE, MAX_FIRE_TIMES, MAX_FORECAST, MAX_JITTER, MIN_GAP, SEARCH_TRIES, SEARCH_YEARS,
};
use crate::error::{SpecError, SpecReason};

/// Dates d'échéance entre deux instants, dans l'ordre.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FireTimes {
    /// Dates trouvées (au plus la limite demandée, 1000 au plus).
    pub times: Vec<Timestamp>,
    /// Vrai si d'autres dates suivent dans l'intervalle : reprendre après la dernière.
    pub truncated: bool,
}

fn no_future_fire(message: impl Into<String>) -> SpecError {
    SpecError::new("spec", SpecReason::NoFutureFire, message)
}

fn out_of_range(rule: &str, error: impl std::fmt::Display) -> SpecError {
    SpecError::new(rule, SpecReason::OutOfRange, error.to_string())
}

/// Prochain multiple de l'intervalle `step` depuis `anchor` (à partir du multiple `first`),
/// strictement après `after` ; `None` au-delà de la dernière date représentable (an 9999) :
/// l'intervalle ne donne alors plus de date, ce qui n'est pas une erreur.
fn every_next(
    anchor: Timestamp,
    first: i128,
    step: SignedDuration,
    after: Timestamp,
) -> Option<Timestamp> {
    let step = step.as_nanos();
    if step <= 0 {
        return None;
    }
    let delta = after.as_nanosecond() - anchor.as_nanosecond();
    let k = if delta < first * step {
        first
    } else {
        delta.div_euclid(step) + 1
    };
    let at = anchor.as_nanosecond().checked_add(k.checked_mul(step)?)?;
    Timestamp::from_nanosecond(at).ok()
}

impl Spec {
    /// Plus petite date candidate strictement après `after`, avant exclusions et calendriers.
    fn candidate_after(&self, after: Timestamp) -> Result<Option<Timestamp>, SpecError> {
        let mut best: Option<Timestamp> = None;
        let mut keep = |t: Timestamp| {
            if best.is_none_or(|b| t < b) {
                best = Some(t);
            }
        };
        for (i, rule) in self.crons.iter().enumerate() {
            if let CronNext::At(t) = rule.next_after(&format!("cron[{i}]"), after, &self.tz)? {
                keep(t);
            }
        }
        for step in &self.every {
            if let Some(t) = every_next(self.anchor, self.first_step, *step, after) {
                keep(t);
            }
        }
        if let Some(at) = self.at.filter(|&at| at > after) {
            keep(at);
        }
        Ok(best)
    }

    /// Instant à partir duquel reprendre la recherche si la date `at` est écartée (exclusion
    /// ou calendrier) ; `None` si elle est permise.
    fn blocked(&self, at: Timestamp) -> Result<Option<Timestamp>, SpecError> {
        for (i, rule) in self.excludes.iter().enumerate() {
            if rule.matches(&format!("exclude_cron[{i}]"), at, &self.tz)? {
                return Ok(Some(at));
            }
        }
        if self.calendars.is_empty() {
            return Ok(None);
        }
        let local = at.to_zoned(self.tz.clone()).datetime();
        match self.calendars.verdict(local) {
            Verdict::Allowed => Ok(None),
            Verdict::BlockedUntil(resume) => {
                // Reprise juste avant l'heure locale de reprise (recherche strictement après) ;
                // jamais en arrière, même dans une heure répétée. Une heure de reprise qui tombe
                // dans le saut de printemps est lue avec le décalage d'après le saut, ce qui donne
                // un instant **avant** le saut : la recherche reprend au plus tard à la bascule et
                // ne saute aucune date permise juste après elle.
                let ambiguous = self.tz.to_ambiguous_zoned(resume);
                let zoned = match ambiguous.offset() {
                    AmbiguousOffset::Gap { .. } => ambiguous.earlier(),
                    _ => ambiguous.compatible(),
                };
                let resume = zoned
                    .ok()
                    .and_then(|z| {
                        z.timestamp()
                            .checked_sub(SignedDuration::from_nanos(1))
                            .ok()
                    })
                    .filter(|&r| r > at)
                    .unwrap_or(at);
                Ok(Some(resume))
            }
        }
    }

    /// Recherche de la prochaine date permise strictement après `after`, au plus tard à
    /// `until` (et à `end_at`).
    fn search(
        &self,
        after: Timestamp,
        until: Option<Timestamp>,
    ) -> Result<Option<Timestamp>, SpecError> {
        let begin = match self.start_at {
            Some(start) => {
                let before_start = start
                    .checked_sub(SignedDuration::from_nanos(1))
                    .map_err(|e| out_of_range("start_at", e))?;
                after.max(before_start)
            }
            None => after,
        };
        let horizon = begin
            .to_zoned(self.tz.clone())
            .checked_add(Span::new().years(SEARCH_YEARS))
            .map(|z| z.timestamp())
            .unwrap_or(Timestamp::MAX);
        let limit = match (self.end_at, until) {
            (Some(a), Some(b)) => Some(a.min(b)),
            (a, b) => a.or(b),
        };
        let mut cursor = begin;
        let mut tries = 0usize;
        loop {
            let Some(candidate) = self.candidate_after(cursor)? else {
                return Ok(None);
            };
            if limit.is_some_and(|l| candidate > l) {
                return Ok(None);
            }
            if candidate > horizon {
                return Err(no_future_fire(format!(
                    "aucune date permise dans les {SEARCH_YEARS} ans qui suivent {begin}"
                )));
            }
            match self.blocked(candidate)? {
                None => return Ok(Some(candidate)),
                Some(resume) => {
                    tries += 1;
                    if tries >= SEARCH_TRIES {
                        return Err(no_future_fire(format!(
                            "{SEARCH_TRIES} dates écartées sans date permise après {begin}"
                        )));
                    }
                    cursor = resume;
                }
            }
        }
    }

    /// Prochaine échéance strictement après `after` ; `None` s'il n'y en a plus (fin atteinte,
    /// date unique passée). Erreur `no_future_fire` au-delà de 5 ans ou de 10 000 dates écartées
    /// (U4).
    pub fn next_after(&self, after: Timestamp) -> Result<Option<Timestamp>, SpecError> {
        self.search(after, None)
    }

    /// Échéances dans `]from, to]`, dans l'ordre : au plus `limit` dates (1000 au plus), et
    /// `truncated` si d'autres suivent (reprendre après la dernière rendue). Sert aux dates
    /// manquées (le lot 1 applique ensuite le rattrapage) et au rejeu d'une période.
    pub fn fire_times_between(
        &self,
        from: Timestamp,
        to: Timestamp,
        limit: usize,
    ) -> Result<FireTimes, SpecError> {
        let limit = limit.clamp(1, MAX_FIRE_TIMES);
        let mut times = Vec::new();
        let mut cursor = from;
        while let Some(t) = self.search(cursor, Some(to))? {
            if times.len() == limit {
                return Ok(FireTimes {
                    times,
                    truncated: true,
                });
            }
            times.push(t);
            cursor = t;
        }
        Ok(FireTimes {
            times,
            truncated: false,
        })
    }

    /// Prévision : les `count` prochaines échéances (100 au plus) après `after`, avec leur heure
    /// locale dans le fuseau de la planification.
    pub fn forecast(&self, after: Timestamp, count: usize) -> Result<Vec<Zoned>, SpecError> {
        let count = count.min(MAX_FORECAST);
        let mut out = Vec::with_capacity(count);
        let mut cursor = after;
        while out.len() < count {
            let Some(t) = self.next_after(cursor)? else {
                break;
            };
            out.push(t.to_zoned(self.tz.clone()));
            cursor = t;
        }
        Ok(out)
    }

    /// Plus petit écart entre deux échéances consécutives parmi les `GAP_SAMPLE` premières après
    /// `after` (`None` : moins de deux échéances).
    pub fn smallest_gap(&self, after: Timestamp) -> Result<Option<SignedDuration>, SpecError> {
        let mut gap: Option<SignedDuration> = None;
        let mut previous: Option<Timestamp> = None;
        let mut cursor = after;
        for _ in 0..GAP_SAMPLE {
            let Some(t) = self.next_after(cursor)? else {
                break;
            };
            if let Some(p) = previous {
                let d = t.duration_since(p);
                if gap.is_none_or(|g| d < g) {
                    gap = Some(d);
                }
            }
            previous = Some(t);
            cursor = t;
        }
        Ok(gap)
    }

    /// Décalage aléatoire maximal effectif (U5) : `jitter`, borné à une heure et à la moitié du
    /// plus petit écart entre deux échéances après `after` ; zéro sans `jitter`.
    pub fn max_jitter(&self, after: Timestamp) -> Result<SignedDuration, SpecError> {
        let Some(jitter) = self.jitter else {
            return Ok(SignedDuration::ZERO);
        };
        let mut bound = jitter.min(MAX_JITTER);
        if let Some(gap) = self.smallest_gap(after)? {
            bound = bound.min(gap / 2);
        }
        Ok(bound)
    }

    /// Contrôle à l'écriture, à l'instant `now` : au moins une échéance future, au moins une
    /// minute entre deux échéances (U1), décalage d'au plus la moitié du plus petit écart (U5).
    pub fn validate(&self, now: Timestamp) -> Result<(), SpecError> {
        if self.next_after(now)?.is_none() {
            return Err(no_future_fire("aucune échéance future"));
        }
        let Some(gap) = self.smallest_gap(now)? else {
            return Ok(());
        };
        if gap < MIN_GAP {
            return Err(SpecError::new(
                "spec",
                SpecReason::MinInterval,
                format!("deux échéances à {gap:#} d'écart, moins d'une minute"),
            ));
        }
        if let Some(jitter) = self.jitter {
            if jitter > gap / 2 {
                return Err(SpecError::new(
                    "jitter",
                    SpecReason::Jitter,
                    format!("décalage de plus de la moitié du plus petit écart ({gap:#})"),
                ));
            }
        }
        Ok(())
    }
}

/// Décalage tiré par le générateur du système (`OsRng`) entre zéro et `max` inclus (U5) ; la
/// date prévue reste l'identité de l'exécution, seule la date de disponibilité est décalée.
pub fn draw_jitter(max: SignedDuration) -> Result<SignedDuration, rand_core::Error> {
    let span = max.as_nanos();
    if span <= 0 {
        return Ok(SignedDuration::ZERO);
    }
    let mut bytes = [0u8; 16];
    OsRng.try_fill_bytes(&mut bytes)?;
    let draw = u128::from_le_bytes(bytes) % (span as u128 + 1);
    // `draw` ≤ `span` ≤ i128::MAX : conversion exacte.
    Ok(SignedDuration::from_nanos_i128(draw as i128))
}
