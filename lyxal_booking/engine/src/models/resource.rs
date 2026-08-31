//! Resource and ResourceAllocation domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Resource {
    pub id: BookingRecordId,
    pub name: String,
    pub feed_url: String,
    pub caldav_url: Option<String>,
    pub caldav_username: Option<String>,
    pub caldav_password_configured: bool,
    pub last_synced_at: Option<BookingDatetime>,
    pub created_at: BookingDatetime,
}

#[derive(Clone, Deserialize)]
pub(crate) struct StoredResourceSecrets {
    pub caldav_password_enc: Option<String>,
}

impl std::fmt::Debug for StoredResourceSecrets {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("StoredResourceSecrets([REDACTED])")
    }
}
