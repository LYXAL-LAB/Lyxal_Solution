use crate::IcalError;

/// TODO: implement full recurrence expansion (RRULE/RDATE/EXDATE with timezones and range filtering).
pub fn occurrences(
    _rrule: &str,
    _dtstart: &str,
    _tz: Option<&str>,
    _range_start: &str,
    _range_end: &str,
    _exdates: &[&str],
    _rdates: &[&str],
) -> Result<Vec<String>, IcalError> {
    Err(IcalError::ParseError { line: 0, reason: "recurrence not implemented".into() })
}

