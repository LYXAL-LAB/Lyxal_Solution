use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::{json, Value};
use reqwest::Client;

pub struct MailgunConnector {
    pub api_key: String,
    pub domain: String,
    pub from_email: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for MailgunConnector {
    fn id(&self) -> &str { "mailgun" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "mailgun".to_string(),
            target: "mailgun".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "Mailgun"}),
            description: json!({"en": "Send emails via Mailgun"}),
            logo: "/logos/mailgun.svg".to_string(),
            logo_dark: None,
            readme: "Mailgun Email Integration".to_string(),
            config_template: "{\"apiKey\": \"\", \"domain\": \"\", \"fromEmail\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["apiKey"].is_null() || config["domain"].is_null() || config["fromEmail"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Mailgun Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for MailgunConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let url = format!("https://api.mailgun.net/v3/{}/messages", self.domain);
        
        let res = self.http_client
            .post(&url)
            .basic_auth("api", Some(&self.api_key))
            .form(&[
                ("from", &self.from_email),
                ("to", &payload.to),
                ("subject", &payload.subject),
                ("text", &payload.body),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err_text = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Mailgun error: {}", err_text)))
        }
    }
}
