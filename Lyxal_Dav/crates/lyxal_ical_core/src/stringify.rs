use crate::{IcalError, IcalObject};

/// TODO: implement canonical stringify (stable ordering/casing, no data loss).
pub fn stringify(_obj: &IcalObject) -> Result<String, IcalError> {
    Err(IcalError::ParseError { line: 0, reason: "stringify not implemented".into() })
}

