use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::{json, Value};
use reqwest::Client;

pub struct TwilioConnector {
    pub account_sid: String,
    pub auth_token: String,
    pub from_number: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for TwilioConnector {
    fn id(&self) -> &str { "twilio" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Sms }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "twilio".to_string(),
            target: "twilio".to_string(),
            connector_type: ConnectorType::Sms,
            name: json!({"en": "Twilio SMS"}),
            description: json!({"en": "Send SMS via Twilio"}),
            logo: "/logos/twilio.svg".to_string(),
            logo_dark: None,
            readme: "Twilio SMS Integration".to_string(),
            config_template: "{\"accountSid\": \"\", \"authToken\": \"\", \"fromNumber\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["accountSid"].is_null() || config["authToken"].is_null() || config["fromNumber"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Twilio Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for TwilioConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let url = format!("https://api.twilio.com/2010-04-01/Accounts/{}/Messages.json", self.account_sid);
        
        let res = self.http_client
            .post(&url)
            .basic_auth(&self.account_sid, Some(&self.auth_token))
            .form(&[
                ("To", &payload.to),
                ("From", &self.from_number),
                ("Body", &payload.body),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err_text = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Twilio error: {}", err_text)))
        }
    }
}
