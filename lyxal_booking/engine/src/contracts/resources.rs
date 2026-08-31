use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceParams {
    pub resource_id: RecordId,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateResourceParams<'a> {
    pub name: &'a str,
    pub resource_type: &'a str,
    pub capacity: Option<i32>,
    pub location: Option<&'a str>,
    pub description: Option<&'a str>,
    pub feed_url: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateResourceParams<'a> {
    pub resource_id: RecordId,
    pub name: &'a str,
    pub resource_type: &'a str,
    pub capacity: Option<i32>,
    pub location: Option<&'a str>,
    pub description: Option<&'a str>,
    pub feed_url: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceResponse {
    pub id: String,
    pub name: String,
    pub resource_type: String,
    pub capacity: Option<i32>,
    pub location: Option<String>,
    pub description: Option<String>,
    pub feed_url: Option<String>,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateResourceRequest {
    pub name: String,
    pub resource_type: String,
    pub capacity: Option<i32>,
    pub location: Option<String>,
    pub description: Option<String>,
    pub feed_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateResourceRequest {
    pub name: String,
    pub resource_type: String,
    pub capacity: Option<i32>,
    pub location: Option<String>,
    pub description: Option<String>,
    pub feed_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteResourceResponse {
    pub deleted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncResourceResponse {
    pub resource_id: String,
    pub synchronized_events: usize,
}
