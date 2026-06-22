use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct GithubConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct GithubTokenResponse {
    access_token: String,
}

#[async_trait]
impl Connector for GithubConnector {
    fn id(&self) -> &str { "github" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "github".to_string(),
            target: "github".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "GITHUB"}),
            description: json!({"en": "github login"}),
            logo: "/logos/github.svg".to_string(),
            logo_dark: None,
            readme: "Login with github".to_string(),
            config_template: "{}".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for GithubConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://github.com/login/oauth/authorize?client_id={}&redirect_uri={}&state={}&scope=user:email",
            self.client_id, redirect_uri, state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, _redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Exchange code for access token
        let token_res = self.http_client
            .post("https://github.com/login/oauth/access_token")
            .header("Accept", "application/json")
            .form(&json!({
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "code": code,
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: GithubTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user profile
        let user_res: Value = self.http_client
            .get("https://api.github.com/user")
            .header("Authorization", format!("token {}", token_data.access_token))
            .header("User-Agent", "lyxal-identity")
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["id"].to_string(),
            username: user_res["login"].as_str().map(|s| s.to_string()),
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: user_res["avatar_url"].as_str().map(|s| s.to_string()),
            raw_data: user_res,
        })
    }
}
