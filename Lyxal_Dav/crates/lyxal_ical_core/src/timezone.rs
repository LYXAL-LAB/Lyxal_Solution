use crate::IcalError;

/// TODO: implement VTIMEZONE handling, IANA fallback, floating time semantics.
#[allow(dead_code)]
pub fn resolve_timezone(_tzid: &str) -> Result<(), IcalError> {
    Err(IcalError::ParseError { line: 0, reason: "timezone resolution not implemented".into() })
}

