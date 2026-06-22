use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct SlackConnector {
    pub client_id: String,
    pub client_secret: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct SlackTokenResponse {
    access_token: String,
    authed_user: SlackAuthedUser,
}

#[derive(Debug, Deserialize)]
struct SlackAuthedUser {
    id: String,
}

#[async_trait]
impl Connector for SlackConnector {
    fn id(&self) -> &str { "slack" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "slack".to_string(),
            target: "slack".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Slack"}),
            description: json!({"en": "Slack Login"}),
            logo: "/logos/slack.svg".to_string(),
            logo_dark: None,
            readme: "Slack Sign-In Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Slack Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for SlackConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://slack.com/oauth/v2/authorize?client_id={}&user_scope=openid%20profile%20email&redirect_uri={}&state={}",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Exchange code for token
        let token_res = self.http_client
            .post("https://slack.com/api/oauth.v2.access")
            .form(&json!({
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "code": code,
                "redirect_uri": redirect_uri,
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: SlackTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user info (openid.connect.userInfo)
        let user_res: Value = self.http_client
            .get("https://slack.com/api/openid.connect.userInfo")
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: token_data.authed_user.id,
            username: user_res["email"].as_str().map(|s| s.to_string()),
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: user_res["picture"].as_str().map(|s| s.to_string()),
            raw_data: user_res,
        })
    }
}
