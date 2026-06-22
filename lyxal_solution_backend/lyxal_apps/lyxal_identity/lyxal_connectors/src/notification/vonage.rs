use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use reqwest::Client;

pub struct VonageConnector {
    pub api_key: String,
    pub api_secret: String,
    pub from_number: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for VonageConnector {
    fn id(&self) -> &str { "vonage" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Sms }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "vonage".to_string(),
            target: "vonage".to_string(),
            connector_type: ConnectorType::Sms,
            name: json!({"en": "Vonage SMS"}),
            description: json!({"en": "Send SMS via Vonage (Nexmo)"}),
            logo: "/logos/vonage.svg".to_string(),
            logo_dark: None,
            readme: "Vonage SMS Integration".to_string(),
            config_template: "{\"apiKey\": \"\", \"apiSecret\": \"\", \"fromNumber\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        if config["apiKey"].is_null() || config["apiSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Vonage Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for VonageConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let res = self.http_client
            .post("https://rest.nexmo.com/sms/json")
            .form(&json!({
                "api_key": self.api_key,
                "api_secret": self.api_secret,
                "to": payload.to,
                "from": self.from_number,
                "text": payload.body
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Vonage error: {}", err)))
        }
    }
}
