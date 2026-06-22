use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use lyxal_core::Result;
use reqwest::Client;
use hmac::{Hmac, Mac};
use sha2::Sha256;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WebhookPayload {
    pub event: String,
    pub created_at: i64,
    pub payload: Value,
}

pub struct WebhookService {
    pub http_client: Client,
}

impl WebhookService {
    pub fn new() -> Self {
        Self { http_client: Client::new() }
    }

    pub async fn trigger(&self, url: &str, secret: &str, event: &str, data: Value) -> Result<()> {
        let payload = WebhookPayload {
            event: event.to_string(),
            created_at: chrono::Utc::now().timestamp_millis(),
            payload: data,
        };

        let body = serde_json::to_string(&payload).unwrap();
        
        // Sign payload for security (Logto parity)
        let mut mac = Hmac::<Sha256>::new_from_slice(secret.as_bytes())
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;
        mac.update(body.as_bytes());
        let signature = hex::encode(mac.finalize().into_bytes());

        let _ = self.http_client
            .post(url)
            .header("X-Logto-Signature-256", signature)
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(())
    }
}
