use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilityQuery {
    pub event_type_slug: String,
    pub date_from: String,
    pub date_to: String,
    pub time_zone: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilitySlotResponse {
    pub start_at: String,
    pub end_at: String,
    pub available_resource_ids: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilityResponse {
    pub slots: Vec<AvailabilitySlotResponse>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilityScheduleRule {
    pub day_of_week: u8,
    pub start_time: String,
    pub end_time: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilityScheduleResponse {
    pub id: String,
    pub name: String,
    pub time_zone: String,
    pub is_default: bool,
    pub rules: Vec<AvailabilityScheduleRule>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SaveAvailabilityScheduleRequest {
    pub name: String,
    pub time_zone: String,
    pub is_default: bool,
    pub rules: Vec<AvailabilityScheduleRule>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AvailabilityOverrideResponse {
    pub id: String,
    pub date: String,
    pub unavailable: bool,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SaveAvailabilityOverrideRequest {
    pub date: String,
    pub unavailable: bool,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteAvailabilityOverrideResponse {
    pub deleted: bool,
}
