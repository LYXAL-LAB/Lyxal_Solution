use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use reqwest::Client;

pub struct PostmarkConnector {
    pub server_token: String,
    pub from_email: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for PostmarkConnector {
    fn id(&self) -> &str { "postmark" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "postmark".to_string(),
            target: "postmark".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "Postmark"}),
            description: json!({"en": "Send emails via Postmark"}),
            logo: "/logos/postmark.svg".to_string(),
            logo_dark: None,
            readme: "Postmark Email Integration".to_string(),
            config_template: "{\"serverToken\": \"\", \"fromEmail\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        if config["serverToken"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Postmark Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for PostmarkConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let res = self.http_client
            .post("https://api.postmarkapp.com/email")
            .header("X-Postmark-Server-Token", &self.server_token)
            .json(&json!({
                "From": self.from_email,
                "To": payload.to,
                "Subject": payload.subject,
                "TextBody": payload.body
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Postmark error: {}", err)))
        }
    }
}
