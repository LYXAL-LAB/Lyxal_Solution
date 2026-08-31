//! Utility functions for Lyxal Booking (iCalendar, Timezone, Markdown, CLI).

pub mod cli;
pub mod ical;
pub mod markdown;
pub mod ssrf;
pub mod timezone;

pub use cli::{prompt, prompt_from, prompt_password};
pub use ical::{
    extract_vevent_field, extract_vevent_tzid, parse_ical_datetime, parse_ical_naive_datetime,
    split_vevents, unfold_ical, IcalParseError,
};
pub use markdown::{is_safe_link, render_inline_markdown};
pub use ssrf::{build_ssrf_safe_client, validate_outbound_url, SsrfValidationError};
pub use timezone::{convert_event_to_tz, DateTimeConversionError};
