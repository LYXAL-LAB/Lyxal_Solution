use async_trait::async_trait;
use lyxal_core::Result;
use serde::{Deserialize, Serialize};

/// Defines the type of connector.
/// Inspired by Logto's connector classification.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum ConnectorType {
    Social,
    Sms,
    Email,
    Sso,
}

/// Metadata describing a connector.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectorMetadata {
    pub id: String,
    pub target: String,
    pub connector_type: ConnectorType,
    pub name: serde_json::Value, // Multi-language names (e.g., {"en": "...", "fr": "..."})
    pub description: serde_json::Value,
    pub logo: String,
}

/// The base trait for all Lyxal Connectors.
/// Every connector (Email, SMS, Social) must implement this trait.
#[async_trait]
pub trait Connector: Send + Sync {
    /// Returns the unique identifier of the connector implementation.
    fn id(&self) -> &str;

    /// Returns the functional type of the connector.
    fn connector_type(&self) -> ConnectorType;

    /// Returns the full metadata of the connector.
    fn metadata(&self) -> ConnectorMetadata;

    /// Validates a configuration blob against the connector's requirements.
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()>;

    /// Tests if the connector can successfully communicate with its provider.
    async fn test_connection(&self) -> Result<bool>;
}

/// Configuration structure for a specific connector instance saved in the database.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectorConfig {
    pub id: String,
    pub name: String,
    pub connector_id: String,
    pub connector_type: ConnectorType,
    pub settings: serde_json::Value,
    pub is_enabled: bool,
}

/// Standard response returned after a connector operation (e.g., sending an email).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectorResponse {
    pub success: bool,
    pub message: Option<String>,
    pub data: Option<serde_json::Value>,
}
