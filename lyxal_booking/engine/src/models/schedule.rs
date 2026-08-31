//! Schedule, Rules, Overrides, and TimeOff domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingSchedule {
    pub id: BookingRecordId,
    pub account_id: BookingRecordId,
    pub name: String,
    pub timezone: String,
    pub is_default: bool,
    pub created_at: BookingDatetime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingScheduleRule {
    pub id: BookingRecordId,
    pub schedule_id: BookingRecordId,
    pub day_of_week: i32,
    pub start_time: String,
    pub end_time: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingScheduleOverride {
    pub id: BookingRecordId,
    pub schedule_id: BookingRecordId,
    pub date: String,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
    pub is_blocked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingTimeOff {
    pub id: BookingRecordId,
    pub account_id: BookingRecordId,
    pub start_at: BookingDatetime,
    pub end_at: BookingDatetime,
    pub reason: Option<String>,
    pub status: String,
    pub created_at: BookingDatetime,
}
