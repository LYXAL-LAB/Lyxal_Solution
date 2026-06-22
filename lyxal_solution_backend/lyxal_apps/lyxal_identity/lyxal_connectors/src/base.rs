use async_trait::async_trait;
use lyxal_core::Result;
use serde::{Deserialize, Serialize};

/// 1:1 Mapping of Logto Connector Types
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum ConnectorType {
    Social,
    Sms,
    Email,
    Sso,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ConnectorMetadata {
    pub id: String,
    pub target: String,
    pub connector_type: ConnectorType,
    pub name: serde_json::Value,
    pub description: serde_json::Value,
    pub logo: String,
    pub logo_dark: Option<String>, // Added for Logto parity
    pub readme: String,
    pub config_template: String,
}

#[async_trait]
pub trait Connector: Send + Sync {
    fn id(&self) -> &str;
    fn connector_type(&self) -> ConnectorType;
    fn metadata(&self) -> ConnectorMetadata;
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()>;
    async fn test_connection(&self) -> Result<bool>;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ConnectorConfig {
    pub id: String,
    pub name: String,
    pub connector_id: String,
    pub connector_type: ConnectorType,
    pub sync_profile: bool,
    pub settings: serde_json::Value,
}
