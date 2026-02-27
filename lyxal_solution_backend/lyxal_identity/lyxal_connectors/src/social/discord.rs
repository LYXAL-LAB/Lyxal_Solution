use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct DiscordConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct DiscordTokenResponse {
    access_token: String,
    token_type: String,
}

#[async_trait]
impl Connector for DiscordConnector {
    fn id(&self) -> &str { "discord" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "discord".to_string(),
            target: "discord".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Discord"}),
            description: json!({"en": "Discord Login"}),
            logo: "/logos/discord.svg".to_string(),
            logo_dark: None,
            readme: "Discord OAuth2 Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\"}".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Discord Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for DiscordConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://discord.com/api/oauth2/authorize?client_id={}&redirect_uri={}&response_type=code&scope=identify%20email&state={}",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Exchange code for access token
        let token_res = self.http_client
            .post("https://discord.com/api/oauth2/token")
            .form(&json!({
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirect_uri,
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: DiscordTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user info
        let user_res: Value = self.http_client
            .get("https://discord.com/api/users/@me")
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let id = user_res["id"].as_str().unwrap_or_default().to_string();
        let username = user_res["username"].as_str().map(|s| s.to_string());
        let email = user_res["email"].as_str().map(|s| s.to_string());
        let avatar_hash = user_res["avatar"].as_str();
        let avatar = avatar_hash.map(|h| format!("https://cdn.discordapp.com/avatars/{}/{}.png", id, h));

        Ok(SocialUserInfo {
            id,
            username,
            email,
            name: user_res["global_name"].as_str().or(user_res["username"].as_str()).map(|s| s.to_string()),
            avatar,
            raw_data: user_res,
        })
    }
}
