use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use reqwest::Client;

pub struct MailchimpConnector {
    pub api_key: String,
    pub from_email: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for MailchimpConnector {
    fn id(&self) -> &str { "mailchimp" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "mailchimp".to_string(),
            target: "mailchimp".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "Mailchimp Transactional"}),
            description: json!({"en": "Send emails via Mailchimp Mandrill"}),
            logo: "/logos/mailchimp.svg".to_string(),
            logo_dark: None,
            readme: "Mailchimp Transactional Email Integration".to_string(),
            config_template: "{\"apiKey\": \"\", \"fromEmail\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        if config["apiKey"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Mailchimp Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for MailchimpConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let res = self.http_client
            .post("https://mandrillapp.com/api/1.0/messages/send.json")
            .json(&json!({
                "key": self.api_key,
                "message": {
                    "from_email": self.from_email,
                    "to": [{"email": payload.to, "type": "to"}],
                    "subject": payload.subject,
                    "text": payload.body
                }
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Mailchimp error: {}", err)))
        }
    }
}
