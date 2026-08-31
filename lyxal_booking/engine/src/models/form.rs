//! BookingQuestion and BookingAnswer domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingQuestion {
    pub id: BookingRecordId,
    pub event_type_id: BookingRecordId,
    pub label: String,
    pub type_kind: String,
    pub required: bool,
    pub position: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingAnswer {
    pub id: BookingRecordId,
    pub booking_id: BookingRecordId,
    pub question_id: BookingRecordId,
    pub value: String,
}
