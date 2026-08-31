use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetEventTypeParams<'a> {
    pub user_id: &'a str,
    pub slug: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ListEventTypesParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateEventTypeParams<'a> {
    pub user_id: &'a str,
    pub title: &'a str,
    pub slug: &'a str,
    pub duration_minutes: u32,
    pub description: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateEventTypeParams<'a> {
    pub user_id: &'a str,
    pub current_slug: &'a str,
    pub title: Option<&'a str>,
    pub new_slug: Option<&'a str>,
    pub duration_minutes: Option<u32>,
    pub description: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteEventTypeParams<'a> {
    pub user_id: &'a str,
    pub slug: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventTypeResponse {
    pub id: String,
    pub title: String,
    pub slug: String,
    pub duration_minutes: u32,
    pub description: Option<String>,
    pub before_buffer_minutes: u32,
    pub after_buffer_minutes: u32,
    pub location_type: String,
    pub scheduling_type: String,
    pub resource_ids: Vec<String>,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateEventTypeRequest {
    pub title: String,
    pub slug: String,
    pub duration_minutes: u32,
    pub description: Option<String>,
    pub before_buffer_minutes: Option<u32>,
    pub after_buffer_minutes: Option<u32>,
    pub location_type: Option<String>,
    pub scheduling_type: Option<String>,
    pub resource_ids: Option<Vec<String>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateEventTypeRequest {
    pub title: Option<String>,
    pub slug: Option<String>,
    pub duration_minutes: Option<u32>,
    pub description: Option<String>,
    pub before_buffer_minutes: Option<u32>,
    pub after_buffer_minutes: Option<u32>,
    pub location_type: Option<String>,
    pub scheduling_type: Option<String>,
    pub resource_ids: Option<Vec<String>>,
    pub active: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventTypeResourcesRequest {
    pub resource_ids: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventTypeResourcesResponse {
    pub event_type_id: String,
    pub resource_ids: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToggleEventTypeResponse {
    pub event_type_id: String,
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteEventTypeResponse {
    pub deleted: bool,
}
