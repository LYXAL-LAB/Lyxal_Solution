//! EventType domain model for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventType {
    pub id: BookingRecordId,
    pub account_id: BookingRecordId,
    pub slug: String,
    pub title: String,
    pub description: Option<String>,
    pub duration_min: i32,
    pub location_type: String,
    pub location_value: Option<String>,
    pub buffer_before: i32,
    pub buffer_after: i32,
    pub min_notice_min: i32,
    pub enabled: bool,
    pub created_at: BookingDatetime,
    pub group_id: Option<BookingRecordId>,
    pub created_by_user_id: Option<BookingRecordId>,
    pub is_private: bool,
    pub visibility: String,
    pub cancel_notice_min: Option<i32>,
    pub reschedule_notice_min: Option<i32>,
}
