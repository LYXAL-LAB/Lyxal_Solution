use crate::timezone::{extract_vtimezones, parse_naive_or_utc};
use crate::{Component, IcalError, IcalObject, Property};
use chrono::{NaiveDate, NaiveDateTime};
use chrono_tz::Tz;
use std::collections::HashMap;

pub fn validate(obj: &IcalObject) -> Result<(), IcalError> {
    if obj.calendars.is_empty() {
        return Err(IcalError::ValidationError { reason: "VCALENDAR missing".into() });
    }
    let vtz = extract_vtimezones(obj);

    for cal in &obj.calendars {
        validate_vcalendar(cal, &vtz)?;
    }
    Ok(())
}

fn validate_vcalendar(cal: &crate::VCalendar, vtz: &HashMap<String, crate::timezone::VTimezoneDef>) -> Result<(), IcalError> {
    let has_version = cal.props.iter().find(|p| p.name == "VERSION");
    let has_prodid = cal.props.iter().find(|p| p.name == "PRODID");
    if has_version.is_none() {
        return Err(IcalError::ValidationError { reason: "VERSION missing".into() });
    }
    if let Some(v) = has_version {
        if v.value.trim() != "2.0" {
            return Err(IcalError::ValidationError { reason: "VERSION must be 2.0".into() });
        }
    }
    if has_prodid.is_none() {
        return Err(IcalError::ValidationError { reason: "PRODID missing".into() });
    }

    for comp in &cal.components {
        validate_component(comp, vtz)?;
    }
    Ok(())
}

fn validate_component(comp: &Component, vtz: &HashMap<String, crate::timezone::VTimezoneDef>) -> Result<(), IcalError> {
    match comp {
        Component::VEvent { props, subcomponents } => {
            validate_uid(props)?;
            let dtstart = require_dtstart(props)?;
            let dtend = find_prop(props, "DTEND");
            validate_tz_params(props, vtz)?;
            validate_dt_pair(&dtstart, dtend, vtz, true)?;
            validate_rrule(props)?;
            for sub in subcomponents {
                validate_component(sub, vtz)?;
            }
        }
        Component::VTodo { props, subcomponents } => {
            validate_uid(props)?;
            let dtstart = find_prop(props, "DTSTART");
            validate_tz_params(props, vtz)?;
            if let Some(ds) = dtstart {
                validate_dt_pair(&ds, find_prop(props, "DTEND"), vtz, false)?;
            }
            validate_rrule(props)?;
            for sub in subcomponents {
                validate_component(sub, vtz)?;
            }
        }
        Component::VJournal { props, subcomponents } => {
            validate_uid(props)?;
            let dtstart = require_dtstart(props)?;
            let dtend = find_prop(props, "DTEND");
            validate_tz_params(props, vtz)?;
            validate_dt_pair(&dtstart, dtend, vtz, false)?;
            validate_rrule(props)?;
            for sub in subcomponents {
                validate_component(sub, vtz)?;
            }
        }
        Component::VTimezone { subcomponents, .. } => {
            for sub in subcomponents {
                validate_component(sub, vtz)?;
            }
        }
        Component::VFreebusy { subcomponents, .. } | Component::Other { subcomponents, .. } => {
            for sub in subcomponents {
                validate_component(sub, vtz)?;
            }
        }
    }
    Ok(())
}

fn validate_uid(props: &[Property]) -> Result<(), IcalError> {
    if props.iter().any(|p| p.name == "UID") {
        Ok(())
    } else {
        Err(IcalError::ValidationError { reason: "UID missing".into() })
    }
}

fn require_dtstart(props: &[Property]) -> Result<&Property, IcalError> {
    find_prop(props, "DTSTART").ok_or_else(|| IcalError::ValidationError { reason: "DTSTART missing".into() })
}

fn find_prop<'a>(props: &'a [Property], name: &str) -> Option<&'a Property> {
    props.iter().find(|p| p.name == name)
}

fn validate_tz_params(props: &[Property], vtz: &HashMap<String, crate::timezone::VTimezoneDef>) -> Result<(), IcalError> {
    for p in props {
        if let Some(tzids) = p.params.get("TZID") {
            for tzid in tzids {
                if !is_known_tz(tzid, vtz) {
                    return Err(IcalError::ValidationError { reason: format!("Unknown TZID {}", tzid) });
                }
            }
        }
    }
    Ok(())
}

fn is_known_tz(tzid: &str, vtz: &HashMap<String, crate::timezone::VTimezoneDef>) -> bool {
    if vtz.contains_key(tzid) {
        return true;
    }
    tzid.parse::<Tz>().is_ok()
}

enum DtKind {
    Date(NaiveDate),
    DateTime(NaiveDateTime),
}

fn parse_dt(prop: &Property) -> Result<DtKind, IcalError> {
    if prop.value.len() == 8 && prop.value.chars().all(|c| c.is_ascii_digit()) {
        let date = NaiveDate::parse_from_str(&prop.value, "%Y%m%d").map_err(|_| IcalError::ValidationError { reason: "Invalid DATE".into() })?;
        return Ok(DtKind::Date(date));
    }
    let (ndt, _) = parse_naive_or_utc(&prop.value)?;
    Ok(DtKind::DateTime(ndt))
}

fn validate_dt_pair(dtstart: &Property, dtend: Option<&Property>, vtz: &HashMap<String, crate::timezone::VTimezoneDef>, dtend_required: bool) -> Result<(), IcalError> {
    let start_kind = parse_dt(dtstart)?;
    if let Some(dtend_prop) = dtend {
        let end_kind = parse_dt(dtend_prop)?;
        match (start_kind, end_kind) {
            (DtKind::Date(s), DtKind::Date(e)) => {
                if e < s {
                    return Err(IcalError::ValidationError { reason: "DTEND before DTSTART".into() });
                }
            }
            (DtKind::DateTime(s), DtKind::DateTime(e)) => {
                if e < s {
                    return Err(IcalError::ValidationError { reason: "DTEND before DTSTART".into() });
                }
            }
            _ => {
                return Err(IcalError::ValidationError { reason: "DTSTART/DTEND kind mismatch".into() });
            }
        }
    } else if dtend_required {
        // no-op: spec allows optional DTEND; not enforced here
    }

    // TZID presence already checked; ensure reference exists
    if let Some(tzids) = dtstart.params.get("TZID") {
        for tzid in tzids {
            if !is_known_tz(tzid, vtz) {
                return Err(IcalError::ValidationError { reason: format!("Unknown TZID {}", tzid) });
            }
        }
    }
    if let Some(dtend_prop) = dtend {
        if let Some(tzids) = dtend_prop.params.get("TZID") {
            for tzid in tzids {
                if !is_known_tz(tzid, vtz) {
                    return Err(IcalError::ValidationError { reason: format!("Unknown TZID {}", tzid) });
                }
            }
        }
    }

    Ok(())
}

fn validate_rrule(props: &[Property]) -> Result<(), IcalError> {
    if let Some(rrule) = props.iter().find(|p| p.name == "RRULE") {
        let upper = rrule.value.to_ascii_uppercase();
        if !upper.contains("FREQ=") {
            return Err(IcalError::ValidationError { reason: "RRULE missing FREQ".into() });
        }
    }
    Ok(())
}
