//! Construct a [`CalendarProvider`] from a `caldav_sources` row.
//!
//! Centralising the dispatch here keeps the rest of the codebase ignorant of
//! which protocol a source uses. Add a new back-end by extending the match in
//! `build_provider`.

use std::str::FromStr;
use anyhow::{bail, Result};

use super::CalendarProvider;

/// Provider type stored in `caldav_sources.provider_type`.
pub mod kinds {
    pub const CALDAV: &str = "caldav";
    pub const EWS: &str = "ews";
}

/// Strongly-typed calendar provider enum.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum CalendarProviderKind {
    Caldav,
    Ews,
}

impl CalendarProviderKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Caldav => kinds::CALDAV,
            Self::Ews => kinds::EWS,
        }
    }

    pub fn label(&self) -> &'static str {
        match self {
            Self::Caldav => "CalDAV",
            Self::Ews => "Microsoft Exchange (EWS)",
        }
    }
}

impl FromStr for CalendarProviderKind {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim().to_ascii_lowercase().as_str() {
            kinds::CALDAV => Ok(Self::Caldav),
            kinds::EWS => Ok(Self::Ews),
            other => bail!("Unknown calendar provider type: '{}'", other),
        }
    }
}

impl TryFrom<&str> for CalendarProviderKind {
    type Error = anyhow::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        value.parse()
    }
}

/// Build a provider client for the given source row.
pub fn build_provider(
    provider_type: &str,
    url: &str,
    username: &str,
    password: &str,
) -> Result<Box<dyn CalendarProvider>> {
    let kind: CalendarProviderKind = provider_type.try_into()?;
    match kind {
        CalendarProviderKind::Caldav => Ok(Box::new(super::caldav::CaldavProvider::new(
            url, username, password,
        )?)),
        CalendarProviderKind::Ews => Ok(Box::new(crate::ews::EwsProvider::new(
            url, username, password,
        )?)),
    }
}

/// Validate a URL based on the provider type.
pub fn validate_url(provider_type: &str, url: &str) -> Result<()> {
    let kind: CalendarProviderKind = provider_type.try_into()?;
    match kind {
        CalendarProviderKind::Caldav | CalendarProviderKind::Ews => crate::caldav::validate_caldav_url(url),
    }
}

/// Human-readable label for UI listings.
pub fn label(provider_type: &str) -> &'static str {
    match provider_type.parse::<CalendarProviderKind>() {
        Ok(kind) => kind.label(),
        Err(_) => "Unknown",
    }
}
