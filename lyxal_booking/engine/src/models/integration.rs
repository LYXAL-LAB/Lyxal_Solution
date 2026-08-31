//! BookingSyncLog domain model for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingSyncLog {
    pub id: BookingRecordId,
    pub source_id: BookingRecordId,
    pub status: String,
    pub message: Option<String>,
    pub synced_at: BookingDatetime,
}
