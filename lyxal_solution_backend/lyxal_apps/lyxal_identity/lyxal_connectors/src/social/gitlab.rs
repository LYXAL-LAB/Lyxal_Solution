use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct GitlabConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
    pub base_url: Option<String>, // For self-hosted GitLab
}

#[derive(Debug, Deserialize)]
struct GitlabTokenResponse {
    access_token: String,
}

#[async_trait]
impl Connector for GitlabConnector {
    fn id(&self) -> &str { "gitlab" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "gitlab".to_string(),
            target: "gitlab".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "GitLab"}),
            description: json!({"en": "GitLab Login"}),
            logo: "/logos/gitlab.svg".to_string(),
            logo_dark: None,
            readme: "GitLab OAuth2 Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\", \"baseUrl\": \"https://gitlab.com\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing GitLab Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for GitlabConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let base = self.base_url.as_deref().unwrap_or("https://gitlab.com");
        let url = format!(
            "{}/oauth/authorize?client_id={}&redirect_uri={}&response_type=code&state={}&scope=read_user%20openid%20profile%20email",
            base, self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        let base = self.base_url.as_deref().unwrap_or("https://gitlab.com");
        
        // 1. Exchange code for token
        let token_res = self.http_client
            .post(format!("{}/oauth/token", base))
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

        let token_data: GitlabTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user info
        let user_res: Value = self.http_client
            .get(format!("{}/api/v4/user", base))
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["id"].to_string(),
            username: user_res["username"].as_str().map(|s| s.to_string()),
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: user_res["avatar_url"].as_str().map(|s| s.to_string()),
            raw_data: user_res,
        })
    }
}
