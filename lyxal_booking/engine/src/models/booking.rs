//! Booking & BookingInvite domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Booking {
    pub id: BookingRecordId,
    pub event_type_id: BookingRecordId,
    pub uid: String,
    pub guest_name: String,
    pub guest_email: String,
    pub guest_timezone: String,
    pub notes: Option<String>,
    pub start_at: BookingDatetime,
    pub end_at: BookingDatetime,
    pub status: String,
    pub cancel_token: String,
    pub reschedule_token: String,
    pub created_at: BookingDatetime,
    pub assigned_account: Option<BookingRecordId>,
    pub host: Option<BookingRecordId>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingInvite {
    pub id: BookingRecordId,
    pub event_type_id: BookingRecordId,
    pub token: String,
    pub guest_name: String,
    pub guest_email: String,
    pub message: Option<String>,
    pub expires_at: Option<BookingDatetime>,
    pub max_uses: i32,
    pub used_count: i32,
    pub created_by_user_id: BookingRecordId,
    pub created_at: BookingDatetime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingSummary {
    pub id: BookingRecordId,
    pub guest_name: String,
    pub start_at: BookingDatetime,
    pub status: String,
}
