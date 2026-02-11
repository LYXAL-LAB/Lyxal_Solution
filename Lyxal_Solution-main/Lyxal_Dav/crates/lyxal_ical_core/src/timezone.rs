use crate::{Component, IcalError, IcalObject, Property};
use chrono::{NaiveDateTime, TimeZone, Utc};
use chrono_tz::Tz;
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TimeSpec {
    Utc,
    LocalTz(String),
    Floating,
}

pub type TzId = String;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TransitionRule {
    pub dtstart: String,
    pub offset_from: i32, // seconds
    pub offset_to: i32,   // seconds
    pub rrule: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct VTimezoneDef {
    pub tzid: TzId,
    pub rules: Vec<TransitionRule>,
}

/// Extrait les définitions VTIMEZONE d'un IcalObject.
pub fn extract_vtimezones(obj: &IcalObject) -> HashMap<TzId, VTimezoneDef> {
    let mut map = HashMap::new();
    for cal in &obj.calendars {
        for comp in &cal.components {
            if let Component::VTimezone { props, subcomponents } = comp {
                let tzid = props.iter().find(|p| p.name == "TZID").map(|p| p.value.clone());
                if let Some(tzid_val) = tzid {
                    let mut rules = Vec::new();
                    for sub in subcomponents {
                        if let Component::Other { name, props: sub_props, .. } = sub {
                            let up = name.to_ascii_uppercase();
                            if up == "STANDARD" || up == "DAYLIGHT" {
                                if let Some(rule) = parse_transition_rule(sub_props) {
                                    rules.push(rule);
                                }
                            }
                        }
                    }
                    map.insert(tzid_val.clone(), VTimezoneDef { tzid: tzid_val, rules });
                }
            }
        }
    }
    map
}

fn parse_transition_rule(props: &[Property]) -> Option<TransitionRule> {
    let dtstart = props.iter().find(|p| p.name == "DTSTART")?.value.clone();
    let offset_from = props.iter().find(|p| p.name == "TZOFFSETFROM")?.value.clone();
    let offset_to = props.iter().find(|p| p.name == "TZOFFSETTO")?.value.clone();
    let rrule = props.iter().find(|p| p.name == "RRULE").map(|p| p.value.clone());
    Some(TransitionRule {
        dtstart,
        offset_from: parse_offset(&offset_from)?,
        offset_to: parse_offset(&offset_to)?,
        rrule,
    })
}

fn parse_offset(s: &str) -> Option<i32> {
    // Format +HHMM / -HHMM
    if s.len() != 5 {
        return None;
    }
    let sign = if &s[0..1] == "-" { -1 } else { 1 };
    let hh: i32 = s[1..3].parse().ok()?;
    let mm: i32 = s[3..5].parse().ok()?;
    Some(sign * (hh * 3600 + mm * 60))
}

/// Résout une TZID en offset seconds pour une date locale donnée, à partir d'un VTIMEZONE custom.
pub fn resolve_custom_offset(
    tzid: &str,
    local_dt: &NaiveDateTime,
    vtz: &HashMap<TzId, VTimezoneDef>,
) -> Option<i32> {
    let def = vtz.get(tzid)?;
    let mut candidates: Vec<(NaiveDateTime, i32)> = Vec::new();
    for rule in &def.rules {
        if let Ok(dt) = parse_naive(&rule.dtstart) {
            if dt <= *local_dt {
                candidates.push((dt, rule.offset_to));
            }
        }
    }
    // pick latest dtstart <= local_dt
    candidates.sort_by_key(|(dt, _)| *dt);
    candidates.last().map(|(_, off)| *off)
}

pub fn parse_naive(s: &str) -> Result<NaiveDateTime, IcalError> {
    NaiveDateTime::parse_from_str(s, "%Y%m%dT%H%M%S")
        .map_err(|_| IcalError::ParseError { line: 0, reason: format!("Invalid naive datetime {}", s) })
}

pub fn parse_naive_or_utc(s: &str) -> Result<(NaiveDateTime, bool), IcalError> {
    if s.ends_with('Z') {
        // Essaye RFC3339, sinon format compact iCal.
        if let Ok(dt) = chrono::DateTime::parse_from_rfc3339(s) {
            return Ok((dt.naive_utc(), true));
        }
        let trimmed = &s[..s.len() - 1];
        let dt = NaiveDateTime::parse_from_str(trimmed, "%Y%m%dT%H%M%S")
            .map_err(|_| IcalError::ParseError { line: 0, reason: format!("Invalid datetime {}", s) })?;
        return Ok((dt, true));
    } else {
        let dt = parse_naive(s)?;
        Ok((dt, false))
    }
}

pub fn tz_fallback(tzid: &str, dt: &NaiveDateTime) -> Option<chrono::DateTime<Utc>> {
    if let Ok(tz) = tzid.parse::<Tz>() {
        if let Some(loc) = tz.from_local_datetime(dt).single() {
            let utc: chrono::DateTime<Utc> = loc.with_timezone(&Utc);
            return Some(utc);
        }
    }
    None
}

/// Convertit une datetime locale + tzid (custom ou IANA) en UTC.
pub fn local_to_utc_with_tzid(
    tzid: &str,
    naive: &NaiveDateTime,
    vtz: &HashMap<TzId, VTimezoneDef>,
) -> Result<chrono::DateTime<Utc>, IcalError> {
    if let Some(off) = resolve_custom_offset(tzid, naive, vtz) {
        let dt = chrono::DateTime::<Utc>::from_naive_utc_and_offset(*naive - chrono::Duration::seconds(off as i64), Utc);
        return Ok(dt);
    }
    if let Some(dt) = tz_fallback(tzid, naive) {
        return Ok(dt);
    }
    Err(IcalError::ParseError { line: 0, reason: format!("Unknown TZID {}", tzid) })
}

