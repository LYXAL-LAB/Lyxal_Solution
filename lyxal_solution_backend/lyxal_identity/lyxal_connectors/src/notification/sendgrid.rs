use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::{json, Value};
use reqwest::Client;

pub struct SendgridConnector {
    pub api_key: String,
    pub from_email: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for SendgridConnector {
    fn id(&self) -> &str { "sendgrid" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "sendgrid".to_string(),
            target: "sendgrid".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "SendGrid"}),
            description: json!({"en": "Send emails via SendGrid"}),
            logo: "/logos/sendgrid.svg".to_string(),
            logo_dark: None,
            readme: "SendGrid Email Integration".to_string(),
            config_template: "{\"apiKey\": \"\", \"fromEmail\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["apiKey"].is_null() || config["fromEmail"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing SendGrid Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for SendgridConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let res = self.http_client
            .post("https://api.sendgrid.com/v3/mail/send")
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&json!({
                "personalizations": [{
                    "to": [{"email": payload.to}]
                }],
                "from": {"email": self.from_email},
                "subject": payload.subject,
                "content": [{
                    "type": "text/plain",
                    "value": payload.body
                }]
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err_text = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("SendGrid error: {}", err_text)))
        }
    }
}
