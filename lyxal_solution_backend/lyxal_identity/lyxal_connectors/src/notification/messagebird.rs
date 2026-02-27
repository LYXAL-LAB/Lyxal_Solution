use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;

pub struct MessagebirdConnector {
    pub api_key: String,
}

#[async_trait]
impl Connector for MessagebirdConnector {
    fn id(&self) -> &str { "messagebird" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "messagebird".to_string(),
            target: "messagebird".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "messagebird"}),
            description: json!({"en": "messagebird integration"}),
            logo: "/logos/messagebird.svg".to_string(),
            logo_dark: None,
            readme: "Integration for messagebird".to_string(),
            config_template: "{}".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for MessagebirdConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        tracing::info!("Sending notification via messagebird to {}", payload.to);
        Ok(true)
    }
}
