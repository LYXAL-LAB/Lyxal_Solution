use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde_json::{json, Value};
use reqwest::Client;

pub struct AmazonConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for AmazonConnector {
    fn id(&self) -> &str { "amazon" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "amazon".to_string(),
            target: "amazon".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Amazon"}),
            description: json!({"en": "Amazon Login"}),
            logo: "/logos/amazon.svg".to_string(),
            logo_dark: None,
            readme: "Amazon OAuth2 Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for AmazonConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://www.amazon.com/ap/oa?client_id={}&scope=profile&response_type=code&redirect_uri={}&state={}",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        let token_res = self.http_client
            .post("https://api.amazon.com/auth/o2/token")
            .form(&json!({
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirect_uri,
                "client_id": self.client_id,
                "client_secret": self.client_secret,
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: Value = token_res.json().await.map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;
        let access_token = token_data["access_token"].as_str().unwrap_or_default();

        let user_res: Value = self.http_client
            .get("https://api.amazon.com/user/profile")
            .header("Authorization", format!("Bearer {}", access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["user_id"].as_str().unwrap_or_default().to_string(),
            username: user_res["email"].as_str().map(|s| s.to_string()),
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: None,
            raw_data: user_res,
        })
    }
}
