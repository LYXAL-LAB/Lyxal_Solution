use crate::IcalError;

/// TODO: implement strict validation (required fields, component constraints, date coherence).
#[allow(dead_code)]
pub fn validate(_ics: &str) -> Result<(), IcalError> {
    Err(IcalError::ParseError { line: 0, reason: "validate not implemented".into() })
}

