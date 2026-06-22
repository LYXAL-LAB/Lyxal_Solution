use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct FacebookConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct FacebookTokenResponse {
    access_token: String,
}

#[async_trait]
impl Connector for FacebookConnector {
    fn id(&self) -> &str { "facebook" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "facebook".to_string(),
            target: "facebook".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Facebook"}),
            description: json!({"en": "Facebook Login"}),
            logo: "/logos/facebook.svg".to_string(),
            logo_dark: None,
            readme: "Facebook OAuth2 Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Facebook Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for FacebookConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://www.facebook.com/v12.0/dialog/oauth?client_id={}&redirect_uri={}&state={}&scope=email,public_profile",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        let token_res = self.http_client
            .get("https://graph.facebook.com/v12.0/oauth/access_token")
            .query(&[
                ("client_id", &self.client_id),
                ("client_secret", &self.client_secret),
                ("redirect_uri", &redirect_uri.to_string()),
                ("code", &code.to_string()),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: FacebookTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let user_res: Value = self.http_client
            .get("https://graph.facebook.com/me")
            .query(&[
                ("fields", "id,name,email,picture"),
                ("access_token", &token_data.access_token),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["id"].as_str().unwrap_or_default().to_string(),
            username: None,
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: user_res["picture"]["data"]["url"].as_str().map(|s| s.to_string()),
            raw_data: user_res,
        })
    }
}
