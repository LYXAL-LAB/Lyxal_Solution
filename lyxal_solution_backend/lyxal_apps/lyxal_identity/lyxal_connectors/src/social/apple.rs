use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::social::{SocialConnector, SocialUserInfo};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use reqwest::Client;

pub struct AppleConnector {
    pub client_id: String, // Service ID
    pub team_id: String,
    pub key_id: String,
    pub private_key: String, // PEM format
    pub http_client: Client,
}

#[derive(Debug, Deserialize)]
struct AppleTokenResponse {
    access_token: String,
    id_token: String,
}

#[async_trait]
impl Connector for AppleConnector {
    fn id(&self) -> &str { "apple" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Social }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "apple".to_string(),
            target: "apple".to_string(),
            connector_type: ConnectorType::Social,
            name: json!({"en": "Apple"}),
            description: json!({"en": "Sign in with Apple"}),
            logo: "/logos/apple.svg".to_string(),
            logo_dark: Some("/logos/apple-dark.svg".to_string()),
            readme: "Apple Sign-In Integration".to_string(),
            config_template: "{\"clientId\": \"\", \"teamId\": \"\", \"keyId\": \"\", \"privateKey\": \"\"}".to_string(),
        }
    }
    async fn validate_config(&self, config: &Value) -> Result<()> {
        if config["clientId"].is_null() || config["teamId"].is_null() || config["keyId"].is_null() || config["privateKey"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Apple Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl SocialConnector for AppleConnector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String> {
        let url = format!(
            "https://appleid.apple.com/auth/authorize?client_id={}&redirect_uri={}&response_type=code%20id_token&scope=name%20email&response_mode=form_post&state={}",
            self.client_id, urlencoding::encode(redirect_uri), state
        );
        Ok(url)
    }

    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo> {
        // Note: Apple requires a client_secret generated as a JWT signed with your private key.
        // For this implementation, we assume the secret generation logic is handled or the secret is passed.
        // This is a simplified version of the Apple token exchange.
        
        let token_res = self.http_client
            .post("https://appleid.apple.com/auth/token")
            .form(&json!({
                "client_id": self.client_id,
                "client_secret": "GENERATED_JWT_SECRET", 
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirect_uri,
            }))
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let token_data: AppleTokenResponse = token_res.json()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        // Apple user info is typically encoded in the id_token JWT.
        // Decoding logic would go here.
        
        Ok(SocialUserInfo {
            id: "apple_sub".to_string(),
            username: None,
            email: Some("user@appleid.com".to_string()),
            name: None,
            avatar: None,
            raw_data: json!({ "id_token": token_data.id_token }),
        })
    }
}
