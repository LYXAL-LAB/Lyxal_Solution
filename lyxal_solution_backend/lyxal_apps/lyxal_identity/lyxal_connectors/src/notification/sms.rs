use crate::base::{
    Connector, ConnectorConfig, ConnectorMetadata, ConnectorResponse, ConnectorType,
};
use async_trait::async_trait;
use lyxal_core::error::CoreError;
use lyxal_core::Result;
use serde::{Deserialize, Serialize};

/// Configuration for SMS connectors (e.g., Twilio, AWS SNS, Vonage)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SmsConfig {
    pub provider: String,
    pub account_sid: Option<String>,
    pub auth_token: Option<String>,
    pub api_key: Option<String>,
    pub api_secret: Option<String>,
    pub from_number: String,
    pub region: Option<String>,
    pub endpoint: Option<String>,
}

#[async_trait]
pub trait SmsConnector: Connector {
    /// Send an SMS message to a specific recipient
    async fn send_sms(&self, to: &str, message: &str) -> Result<ConnectorResponse>;
}

/// A generic SMS connector that can be specialized for different providers
pub struct GenericSmsConnector {
    metadata: ConnectorMetadata,
    config: SmsConfig,
    client: reqwest::Client,
}

impl GenericSmsConnector {
    pub fn new(id: String, name: String, config: SmsConfig) -> Self {
        Self {
            metadata: ConnectorMetadata {
                id: id.clone(),
                target: "sms".to_string(),
                connector_type: ConnectorType::Sms,
                name: serde_json::json!({ "en": name }),
                description: serde_json::json!({ "en": format!("SMS Connector for {}", config.provider) }),
                logo: "https://static.lyxal.com/logos/sms.png".to_string(),
            },
            config,
            client: reqwest::Client::new(),
        }
    }
}

#[async_trait]
impl Connector for GenericSmsConnector {
    fn id(&self) -> &str {
        &self.metadata.id
    }

    fn connector_type(&self) -> ConnectorType {
        ConnectorType::Sms
    }

    fn metadata(&self) -> ConnectorMetadata {
        self.metadata.clone()
    }

    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        serde_json::from_value::<SmsConfig>(config.clone())
            .map(|_| ())
            .map_err(|e| CoreError::Validation(format!("Invalid SMS config: {}", e)))
    }

    async fn test_connection(&self) -> Result<bool> {
        // Implementation would depend on the provider's health check or balance API
        Ok(true)
    }
}

#[async_trait]
impl SmsConnector for GenericSmsConnector {
    async fn send_sms(&self, to: &str, message: &str) -> Result<ConnectorResponse> {
        match self.config.provider.as_str() {
            "twilio" => self.send_twilio(to, message).await,
            _ => Err(CoreError::Internal(anyhow::anyhow!(
                "Unsupported SMS provider: {}",
                self.config.provider
            ))),
        }
    }
}

impl GenericSmsConnector {
    async fn send_twilio(&self, to: &str, message: &str) -> Result<ConnectorResponse> {
        let sid = self.config.account_sid.as_ref().ok_or_else(|| {
            CoreError::Validation("Twilio Account SID missing".to_string())
        })?;
        let token = self.config.auth_token.as_ref().ok_or_else(|| {
            CoreError::Validation("Twilio Auth Token missing".to_string())
        })?;

        let url = format!(
            "https://api.twilio.com/2010-04-01/Accounts/{}/Messages.json",
            sid
        );

        let params = [
            ("To", to),
            ("From", &self.config.from_number),
            ("Body", message),
        ];

        let response = self
            .client
            .post(url)
            .basic_auth(sid, Some(token))
            .form(&params)
            .send()
            .await
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Failed to send Twilio request: {}", e)))?;

        if response.status().is_success() {
            Ok(ConnectorResponse {
                success: true,
                message: Some("SMS sent via Twilio".to_string()),
                data: None,
            })
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(CoreError::Internal(anyhow::anyhow!(
                "Twilio API error: {}",
                error_text
            )))
        }
    }
}

impl TryFrom<ConnectorConfig> for GenericSmsConnector {
    type Error = CoreError;

    fn try_from(config: ConnectorConfig) -> Result<Self> {
        let sms_config: SmsConfig = serde_json::from_value(config.settings)
            .map_err(|e| CoreError::Validation(format!("Invalid SMS config: {}", e)))?;

        Ok(Self::new(config.id, config.name, sms_config))
    }
}
