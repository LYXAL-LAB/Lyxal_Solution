use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct XConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct XTokenResponse {
    access_token: String,
}

#[async_trait]
impl Connector for XConnector {
    fn id(&self) -> &str { "x" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "x".to_string(),
            target: "x".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "X (Twitter)"}),
            description: json!({"en": "X Login"}),
            logo: "/logos/x.svg".to_string(),
            logo_dark: None,
            readme: "X OAuth2 Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\"}".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing X Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for XConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://twitter.com/i/oauth2/authorize?client_id={}&redirect_uri={}&response_type=code&scope=users.read%20tweet.read&state={}&code_challenge=challenge&code_challenge_method=plain",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Exchange code for access token
        let token_res = self.http_client
            .post("https://api.twitter.com/2/oauth2/token")
            .basic_auth(&self.client_id, Some(&self.client_secret))
            .form(&json!({
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirect_uri,
                "code_verifier": "challenge",
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: XTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user info
        let user_res: Value = self.http_client
            .get("https://api.twitter.com/2/users/me")
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let data = &user_res["data"];
        Ok(SocialUserInfo {
            id: data["id"].as_str().unwrap_or_default().to_string(),
            username: data["username"].as_str().map(|s| s.to_string()),
            email: None, // X requires special permissions for email
            name: data["name"].as_str().map(|s| s.to_string()),
            avatar: None,
            raw_data: user_res,
        })
    }
}
