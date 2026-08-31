use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateCalendarSourceRequest {
    pub name: String,
    pub provider_type: String,
    pub auth_type: String,
    pub server_url: Option<String>,
    pub username: Option<String>,
    pub secret: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarSourceResponse {
    pub id: String,
    pub name: String,
    pub provider_type: String,
    pub auth_type: String,
    pub server_url: Option<String>,
    pub username: Option<String>,
    pub active: bool,
    pub status: String,
    pub last_synced_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteCalendarSourceResponse {
    pub deleted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncCalendarSourceResponse {
    pub source_id: String,
    pub synced_events_count: usize,
    pub success: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SetWriteCalendarRequest {
    pub calendar_href: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SetWriteCalendarResponse {
    pub source_id: String,
    pub write_calendar_href: String,
    pub updated: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GoogleOAuthConnectResponse {
    pub auth_url: String,
}
