use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct MicrosoftConnector {
    pub client_id: String,
    pub client_secret: String,
    pub tenant: String, // "common", "organizations", "consumers" or specific tenant ID
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct MicrosoftTokenResponse {
    access_token: String,
}

#[async_trait]
impl Connector for MicrosoftConnector {
    fn id(&self) -> &str { "microsoft" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "microsoft".to_string(),
            target: "microsoft".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Microsoft"}),
            description: json!({"en": "Microsoft Login"}),
            logo: "/logos/microsoft.svg".to_string(),
            logo_dark: None,
            readme: "Microsoft OAuth2 (Azure AD) Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\", \"tenant\": \"common\"}".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Microsoft Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for MicrosoftConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://login.microsoftonline.com/{}/oauth2/v2.0/authorize?client_id={}&redirect_uri={}&response_type=code&scope=openid%20profile%20email%20User.Read&state={}",
            self.tenant, self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Exchange code for access token
        let token_res = self.http_client
            .post(format!("https://login.microsoftonline.com/{}/oauth2/v2.0/token", self.tenant))
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

        let token_data: MicrosoftTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. Get user info (Microsoft Graph)
        let user_res: Value = self.http_client
            .get("https://graph.microsoft.com/v1.0/me")
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["id"].as_str().unwrap_or_default().to_string(),
            username: user_res["userPrincipalName"].as_str().map(|s| s.to_string()),
            email: user_res["mail"].as_str().or(user_res["userPrincipalName"].as_str()).map(|s| s.to_string()),
            name: user_res["displayName"].as_str().map(|s| s.to_string()),
            avatar: None, // Avatar requires separate Graph API call for photo
            raw_data: user_res,
        })
    }
}
