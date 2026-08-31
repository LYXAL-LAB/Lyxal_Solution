//! BookingActivity domain model for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingActivity {
    pub id: BookingRecordId,
    pub booking_id: BookingRecordId,
    pub action: String,
    pub actor_id: Option<BookingRecordId>,
    pub created_at: BookingDatetime,
}
