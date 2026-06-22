use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct GenericOidcConnector {
    pub client_id: String,
    pub client_secret: String,
    pub issuer: String,
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct OidcTokenResponse {
    access_token: String,
    id_token: String,
}

#[async_trait]
impl Connector for GenericOidcConnector {
    fn id(&self) -> &str { "oidc" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "oidc".to_string(),
            target: "oidc".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "OIDC", "fr": "OIDC"}),
            description: json!({"en": "Generic OpenID Connect", "fr": "OpenID Connect Générique"}),
            logo: "/logos/oidc.svg".to_string(),
            logo_dark: None,
            readme: "Generic OIDC Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"clientSecret\": \"\", \"issuer\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["clientSecret"].is_null() || config["issuer"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing OIDC Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for GenericOidcConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        // In a real scenario, we would fetch /.well-known/openid-configuration from self.issuer
        let url = format!(
            "{}/authorize?client_id={}&redirect_uri={}&response_type=code&scope=openid%20profile%20email&state={}",
            self.issuer, self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // 1. Token Exchange
        let token_res = self.http_client
            .post(format!("{}/token", self.issuer))
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

        let token_data: OidcTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // 2. UserInfo call
        let user_res: Value = self.http_client
            .get(format!("{}/userinfo", self.issuer))
            .header("Authorization", format!("Bearer {}", token_data.access_token))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(SocialUserInfo {
            id: user_res["sub"].as_str().unwrap_or_default().to_string(),
            username: user_res["preferred_username"].as_str().map(|s| s.to_string()),
            email: user_res["email"].as_str().map(|s| s.to_string()),
            name: user_res["name"].as_str().map(|s| s.to_string()),
            avatar: user_res["picture"].as_str().map(|s| s.to_string()),
            raw_data: user_res,
        })
    }
}
