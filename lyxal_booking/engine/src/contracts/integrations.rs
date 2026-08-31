use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetWebhookParams<'a> {
    pub user_id: &'a str,
    pub webhook_id: RecordId,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ListWebhooksParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateWebhookParams<'a> {
    pub user_id: &'a str,
    pub name: &'a str,
    pub target_url: &'a str,
    pub events: Vec<String>,
    pub encrypted_secret: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteWebhookParams<'a> {
    pub user_id: &'a str,
    pub webhook_id: RecordId,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebhookResponse {
    pub id: String,
    pub name: String,
    pub target_url: String,
    pub events: Vec<String>,
    pub active: bool,
    pub secret_configured: bool,
    pub last_triggered_at: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateWebhookRequest {
    pub name: String,
    pub target_url: String,
    pub events: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateWebhookResponse {
    pub webhook: WebhookResponse,
    pub signing_secret: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteWebhookResponse {
    pub deleted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestWebhookResponse {
    pub delivered: bool,
    pub status_code: Option<u16>,
    pub duration_ms: u64,
    pub error_code: Option<String>,
}
