//! Team, TeamMember, TeamInvite, and Group domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Team {
    pub id: BookingRecordId,
    pub name: String,
    pub slug: String,
    pub created_at: BookingDatetime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TeamMember {
    pub id: BookingRecordId,
    pub team_id: BookingRecordId,
    pub account_id: BookingRecordId,
    pub role: String,
    pub created_at: BookingDatetime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: BookingRecordId,
    pub name: String,
    pub source: String,
    pub oidc_id: Option<String>,
    pub created_at: BookingDatetime,
    pub slug: Option<String>,
}
