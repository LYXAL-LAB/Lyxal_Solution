//! lyxal_ical_core
//!
//! Source of truth iCalendar engine (Rust-only).

pub mod parse;
pub mod stringify;
pub mod recur;
pub mod timezone;
pub mod validate;
pub mod error;
pub mod types;

pub use error::IcalError;
pub use types::{Component, IcalObject, Property, VCalendar};

/// Parse an iCalendar text into an internal representation.
pub fn parse(ics: &str) -> Result<IcalObject, IcalError> {
    parse::parse(ics)
}

/// Stringify an internal representation back to iCalendar text.
pub fn stringify(obj: &IcalObject) -> Result<String, IcalError> {
    stringify::stringify(obj)
}

/// Expand recurrences for a given rule and window.
pub fn occurrences(
    rrule: &str,
    dtstart: &str,
    tz: Option<&str>,
    range_start: &str,
    range_end: &str,
    exdates: &[&str],
    rdates: &[&str],
) -> Result<Vec<String>, IcalError> {
    recur::occurrences(rrule, dtstart, tz, range_start, range_end, exdates, rdates)
}

