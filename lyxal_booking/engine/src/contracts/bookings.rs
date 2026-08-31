use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingResponse {
    pub id: String,
    pub event_type_id: String,
    pub start_at: String,
    pub end_at: String,
    pub status: String,
    pub assigned_resource_id: Option<String>,
    pub meeting_url: Option<String>,
    pub notification_status: Option<String>,
    pub calendar_sync_status: Option<String>,
    pub guest_name: String,
    pub guest_email: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateBookingRequest {
    pub event_type_slug: String,
    pub start_time: String,
    pub guest_name: String,
    pub guest_email: String,
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CancelBookingRequest {
    pub reason: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CancelBookingResponse {
    pub cancelled: bool,
    pub booking_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RescheduleBookingRequest {
    pub expected_start_at: String,
    pub expected_end_at: String,
    pub new_start_at: String,
    pub new_end_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicTokenInfoResponse {
    pub action: String,
    pub booking_id: String,
    pub guest_name: String,
    pub guest_email: String,
    pub start_at: String,
    pub end_at: String,
    pub event_type_title: String,
    pub expires_at: String,
    pub is_valid: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicCancelBookingRequest {
    pub reason: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicRescheduleBookingRequest {
    pub expected_start_at: String,
    pub expected_end_at: String,
    pub new_start_at: String,
    pub new_end_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClaimBookingRequest {
    pub token: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClaimBookingResponse {
    pub booking_id: String,
    pub claimed_by_user_id: String,
    pub claimed: bool,
    pub claimed_at: Option<String>,
}

