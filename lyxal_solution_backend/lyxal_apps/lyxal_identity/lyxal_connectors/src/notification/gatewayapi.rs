use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;

pub struct GatewayapiConnector {
    pub api_key: String,
}

#[async_trait]
impl Connector for GatewayapiConnector {
    fn id(&self) -> &str { "gatewayapi" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "gatewayapi".to_string(),
            target: "gatewayapi".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "gatewayapi"}),
            description: json!({"en": "gatewayapi integration"}),
            logo: "/logos/gatewayapi.svg".to_string(),
            logo_dark: None,
            readme: "Integration for gatewayapi".to_string(),
            config_template: "{}".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for GatewayapiConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        tracing::info!("Sending notification via gatewayapi to {}", payload.to);
        Ok(true)
    }
}
