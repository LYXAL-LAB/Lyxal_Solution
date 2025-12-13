#[derive(Debug, thiserror::Error, PartialEq, Eq)]
pub enum IcalError {
    #[error("Invalid line")]
    InvalidLine,
    #[error("Missing VCALENDAR")]
    MissingCalendar,
    #[error("Unexpected END for component {0}")]
    UnexpectedEnd(String),
    #[error("Mismatched END. Expected {expected}, found {found}")]
    MismatchedEnd { expected: String, found: String },
    #[error("Parse error at line {line}: {reason}")]
    ParseError { line: usize, reason: String },
    #[error("Unsupported component {0}")]
    UnsupportedComponent(String),
}

