use crate::base::{
    Connector, ConnectorConfig, ConnectorMetadata, ConnectorResponse, ConnectorType,
};
use async_trait::async_trait;
use lyxal_core::error::CoreError;
use lyxal_core::Result;
use oauth2::basic::BasicClient;
use oauth2::{AuthUrl, ClientId, ClientSecret, RedirectUrl, TokenUrl};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// Configuration for OAuth2/Social Login providers
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OAuth2Config {
    pub provider_name: String, // e.g., "google", "github", "discord"
    pub client_id: String,
    pub client_secret: String,
    pub auth_url: String,
    pub token_url: String,
    pub redirect_uri: String,
    pub scopes: Vec<String>,
    pub user_info_url: Option<String>,
}

#[async_trait]
pub trait OAuth2Connector: Connector {
    /// Generate the authorization URL for the user to visit
    fn get_authorization_url(&self) -> (String, String);

    /// Exchange the authorization code for an access token
    async fn exchange_code(&self, code: String) -> Result<ConnectorResponse>;

    /// Fetch user information using the access token
    async fn fetch_user_info(&self, access_token: &str) -> Result<serde_json::Value>;
}

/// A generic OAuth2 connector that can be configured for various providers
pub struct GenericOAuth2Connector {
    metadata: ConnectorMetadata,
    config: OAuth2Config,
    client: Arc<BasicClient>,
    http_client: reqwest::Client,
}

impl GenericOAuth2Connector {
    pub fn new(id: String, name: String, config: OAuth2Config) -> Result<Self> {
        let auth_url = AuthUrl::new(config.auth_url.clone())
            .map_err(|e| CoreError::Validation(format!("Invalid Auth URL: {}", e)))?;
        let token_url = TokenUrl::new(config.token_url.clone())
            .map_err(|e| CoreError::Validation(format!("Invalid Token URL: {}", e)))?;
        let redirect_url = RedirectUrl::new(config.redirect_uri.clone())
            .map_err(|e| CoreError::Validation(format!("Invalid Redirect URL: {}", e)))?;

        let client = BasicClient::new(
            ClientId::new(config.client_id.clone()),
            Some(ClientSecret::new(config.client_secret.clone())),
            auth_url,
            Some(token_url),
        )
        .set_redirect_uri(redirect_url);

        let metadata = ConnectorMetadata {
            id: id.clone(),
            target: "social".to_string(),
            connector_type: ConnectorType::Social,
            name: serde_json::json!({ "en": name.clone() }),
            description: serde_json::json!({
                "en": format!("OAuth2 Connector for {}", config.provider_name)
            }),
            logo: "".to_string(),
        };

        Ok(Self {
            metadata,
            config,
            client: Arc::new(client),
            http_client: reqwest::Client::new(),
        })
    }
}

#[async_trait]
impl Connector for GenericOAuth2Connector {
    fn id(&self) -> &str {
        &self.metadata.id
    }

    fn connector_type(&self) -> ConnectorType {
        ConnectorType::Social
    }

    fn metadata(&self) -> ConnectorMetadata {
        self.metadata.clone()
    }

    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        serde_json::from_value::<OAuth2Config>(config.clone())
            .map(|_| ())
            .map_err(|e| CoreError::Validation(format!("Invalid OAuth2 config: {}", e)))
    }

    async fn test_connection(&self) -> Result<bool> {
        // For OAuth2, we usually just validate that the URLs are reachable
        Ok(true)
    }
}

#[async_trait]
impl OAuth2Connector for GenericOAuth2Connector {
    fn get_authorization_url(&self) -> (String, String) {
        let mut request = self.client.authorize_url(oauth2::CsrfToken::new_random);

        for scope in &self.config.scopes {
            request = request.add_scope(oauth2::Scope::new(scope.clone()));
        }

        let (url, csrf_token) = request.url();
        (url.to_string(), csrf_token.secret().to_string())
    }

    async fn exchange_code(&self, code: String) -> Result<ConnectorResponse> {
        use oauth2::AuthorizationCode;
        use oauth2::TokenResponse;

        let token_result = self
            .client
            .exchange_code(AuthorizationCode::new(code))
            .request_async(oauth2::reqwest::async_http_client)
            .await
            .map_err(|e| CoreError::Unauthorized(format!("OAuth2 token exchange failed: {}", e)))?;

        let access_token = token_result.access_token().secret();

        Ok(ConnectorResponse {
            success: true,
            message: Some("Token exchanged successfully".to_string()),
            data: Some(serde_json::json!({
                "access_token": access_token,
                "token_type": "Bearer",
                "expires_in": token_result.expires_in().map(|d| d.as_secs()),
                "refresh_token": token_result.refresh_token().map(|t| t.secret()),
            })),
        })
    }

    async fn fetch_user_info(&self, access_token: &str) -> Result<serde_json::Value> {
        let url = self.config.user_info_url.as_ref().ok_or_else(|| {
            CoreError::Validation("User info URL not configured for this provider".to_string())
        })?;

        let response = self
            .http_client
            .get(url)
            .bearer_auth(access_token)
            .send()
            .await
            .map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to fetch user info: {}", e))
            })?;

        if response.status().is_success() {
            let user_info = response.json::<serde_json::Value>().await.map_err(|e| {
                CoreError::Internal(anyhow::anyhow!("Failed to parse user info: {}", e))
            })?;
            Ok(user_info)
        } else {
            let error = response.text().await.unwrap_or_default();
            Err(CoreError::Unauthorized(format!(
                "Provider returned error: {}",
                error
            )))
        }
    }
}

impl TryFrom<ConnectorConfig> for GenericOAuth2Connector {
    type Error = CoreError;

    fn try_from(config: ConnectorConfig) -> Result<Self> {
        let oauth_config: OAuth2Config = serde_json::from_value(config.settings)
            .map_err(|e| CoreError::Validation(format!("Invalid OAuth2 config: {}", e)))?;

        Self::new(config.id, config.name, oauth_config)
    }
}

