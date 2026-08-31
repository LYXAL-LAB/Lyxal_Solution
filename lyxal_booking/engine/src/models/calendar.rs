//! CalDAV Sources, Calendars, and Events domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CaldavSource {
    pub id: BookingRecordId,
    pub account_id: BookingRecordId,
    pub name: String,
    pub url: String,
    pub username: String,
    pub password_configured: bool,
    pub oauth_configured: bool,
    pub last_synced: Option<BookingDatetime>,
    pub sync_token: Option<String>,
    pub enabled: bool,
    pub created_at: BookingDatetime,
    pub auth_type: String,
    pub oauth2_provider: Option<String>,
    pub token_expires_at: Option<BookingDatetime>,
}

#[derive(Clone, Deserialize)]
pub(crate) struct StoredCaldavSecrets {
    pub password_enc: Option<String>,
    pub access_token_enc: Option<String>,
    pub refresh_token_enc: Option<String>,
}

impl std::fmt::Debug for StoredCaldavSecrets {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("StoredCaldavSecrets([REDACTED])")
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Calendar {
    pub id: BookingRecordId,
    pub source_id: BookingRecordId,
    pub href: String,
    pub display_name: Option<String>,
    pub color: Option<String>,
    pub ctag: Option<String>,
    pub is_busy: bool,
    pub created_at: BookingDatetime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    pub id: BookingRecordId,
    pub calendar_id: BookingRecordId,
    pub uid: String,
    pub etag: Option<String>,
    pub summary: Option<String>,
    pub description: Option<String>,
    pub location: Option<String>,
    pub start_at: BookingDatetime,
    pub end_at: BookingDatetime,
    pub all_day: bool,
    pub timezone: Option<String>,
    pub rrule: Option<String>,
    pub status: Option<String>,
    pub raw_ical: Option<String>,
    pub synced_at: BookingDatetime,
}
