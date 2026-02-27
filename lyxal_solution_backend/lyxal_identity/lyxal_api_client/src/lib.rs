//! Lyxal API Client
//! 
//! This crate provides a Rust SDK for the Lyxal Identity Management API,
//! maintaining 1:1 parity with Logto's official management SDKs.

use serde::{Deserialize, Serialize};
use reqwest::{Client, header};
use std::time::{SystemTime, UNIX_EPOCH};

/// Response structure for OAuth2 Token endpoint.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TokenResponse {
    pub access_token: String,
    pub expires_in: u64,
    pub token_type: String,
    pub scope: Option<String>,
}

/// Configuration for the Management Client.
#[derive(Debug, Clone)]
pub struct ManagementClientConfig {
    /// The base URL of your Lyxal Identity server (e.g., https://auth.lyxal.com)
    pub base_url: String,
    /// The Client ID of your Machine-to-Machine application
    pub client_id: String,
    /// The Client Secret of your Machine-to-Machine application
    pub client_secret: String,
    /// The API Resource Indicator (Audience) for the Management API
    pub api_indicator: String,
}

/// The main client for interacting with the Lyxal Management API.
/// 
/// It automatically handles token retrieval, caching, and renewal using
/// the Client Credentials grant flow.
pub struct ManagementClient {
    config: ManagementClientConfig,
    http_client: Client,
    cached_token: tokio::sync::RwLock<Option<(String, u64)>>,
}

impl ManagementClient {
    /// Creates a new instance of the Management Client.
    pub fn new(config: ManagementClientConfig) -> Self {
        Self {
            config,
            http_client: Client::new(),
            cached_token: tokio::sync::RwLock::new(None),
        }
    }

    /// Retrieves an active access token, fetching a new one if the cache is expired.
    /// 
    /// Follows Logto's logic with a 60-second buffer before actual expiration.
    pub async fn get_access_token(&self) -> Result<String, String> {
        {
            let cache = self.cached_token.read().await;
            if let Some((token, expiry)) = &*cache {
                let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
                if now < *expiry - 60 {
                    return Ok(token.clone());
                }
            }
        }

        let url = format!("{}/oidc/token", self.config.base_url);
        let params = [
            ("grant_type", "client_credentials"),
            ("client_id", &self.config.client_id),
            ("client_secret", &self.config.client_secret),
            ("resource", &self.config.api_indicator),
        ];

        let response = self.http_client
            .post(&url)
            .form(&params)
            .send()
            .await
            .map_err(|e| e.to_string())?;

        if !response.status().is_success() {
            return Err(format!("Failed to fetch token: {}", response.status()));
        }

        let token_data: TokenResponse = response.json().await.map_err(|e| e.to_string())?;
        let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
        
        let mut cache = self.cached_token.write().await;
        *cache = Some((token_data.access_token.clone(), now + token_data.expires_in));

        Ok(token_data.access_token)
    }

    /// Generic wrapper for authenticated API requests.
    async fn request<T: for<'de> Deserialize<'de>>(
        &self, 
        method: reqwest::Method, 
        path: &str, 
        body: Option<serde_json::Value>
    ) -> Result<T, String> {
        let token = self.get_access_token().await?;
        let url = format!("{}/api{}", self.config.base_url, path);

        let mut req = self.http_client
            .request(method, &url)
            .header(header::AUTHORIZATION, format!("Bearer {}", token))
            .header(header::CONTENT_TYPE, "application/json");

        if let Some(b) = body {
            req = req.json(&b);
        }

        let response = req.send().await.map_err(|e| e.to_string())?;
        
        if !response.status().is_success() {
            return Err(format!("API Error: {}", response.status()));
        }

        response.json().await.map_err(|e| e.to_string())
    }

    /// Fetches a list of users from the server.
    pub async fn get_users(&self) -> Result<serde_json::Value, String> {
        self.request(reqwest::Method::GET, "/users", None).await
    }

    /// Creates a new user in the system.
    pub async fn create_user(&self, user_data: serde_json::Value) -> Result<serde_json::Value, String> {
        self.request(reqwest::Method::POST, "/users", Some(user_data)).await
    }

    /// Fetches all registered applications.
    pub async fn get_applications(&self) -> Result<serde_json::Value, String> {
        self.request(reqwest::Method::GET, "/applications", None).await
    }
}
