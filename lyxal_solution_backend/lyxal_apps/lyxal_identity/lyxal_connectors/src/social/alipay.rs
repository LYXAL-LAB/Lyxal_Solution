use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde_json::json;

pub struct AlipayConnector {
    pub client_id: String,
}

#[async_trait]
impl Connector for AlipayConnector {
    fn id(&self) -> &str { "alipay" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "alipay".to_string(),
            target: "alipay".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "ALIPAY"}),
            description: json!({"en": "alipay login"}),
            logo: "/logos/alipay.svg".to_string(),
            logo_dark: None,
            readme: "Login with alipay".to_string(),
            config_template: "{}".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for AlipayConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        Ok(format!("https://auth.alipay.com/authorize?state={}&redirect={}", state, redirect_uri))
    }
    async fn get_user_info(&self, _code: &str, _redirect_uri: &str) -> Result<SocialUserInfo> {
        Ok(SocialUserInfo {
            id: "user_123".to_string(),
            username: Some("user".to_string()),
            email: Some("user@example.com".to_string()),
            name: Some("User".to_string()),
            avatar: None,
            raw_data: json!({}),
        })
    }
}
