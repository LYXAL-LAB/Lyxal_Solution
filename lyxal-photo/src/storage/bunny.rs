use async_trait::async_trait;
use anyhow::{Result, anyhow};
use std::path::Path;
use reqwest::Client;
use super::StorageEngine;

pub struct BunnyConfig {
    pub storage_zone: String,
    pub api_key: String,
    pub region: String, // e.g. "de" for Germany, empty for NY
}

pub struct BunnyStorage {
    config: BunnyConfig,
    client: Client,
}

impl BunnyStorage {
    pub fn new(config: BunnyConfig) -> Self {
        Self {
            config,
            client: Client::new(),
        }
    }

    fn get_url(&self, path: &str) -> String {
        let base = if self.config.region.is_empty() {
            "storage.bunnycdn.com".to_string()
        } else {
            format!("{}.storage.bunnycdn.com", self.config.region)
        };
        format!("https://{}/{}/{}", base, self.config.storage_zone, path.trim_start_matches('/'))
    }
}

#[async_trait]
impl StorageEngine for BunnyStorage {
    async fn get_bytes(&self, storage_key: &str) -> Result<Vec<u8>> {
        let path = storage_key.strip_prefix("bunny://")
            .ok_or_else(|| anyhow!("Invalid Bunny storage key"))?;
        
        let url = self.get_url(path);
        let resp = self.client.get(url)
            .header("AccessKey", &self.config.api_key)
            .send()
            .await?;

        if resp.status().is_success() {
            Ok(resp.bytes().await?.to_vec())
        } else {
            Err(anyhow!("Bunny download failed: {}", resp.status()))
        }
    }

    async fn put_bytes(&self, path: &str, bytes: Vec<u8>, _mime: &str) -> Result<String> {
        let url = self.get_url(path);
        let resp = self.client.put(url)
            .header("AccessKey", &self.config.api_key)
            .body(bytes)
            .send()
            .await?;

        if resp.status().is_success() {
            Ok(format!("bunny://{}", path))
        } else {
            Err(anyhow!("Bunny upload failed: {}", resp.status()))
        }
    }

    async fn put_file(&self, path: &str, local_path: &Path, mime: &str) -> Result<String> {
        let bytes = tokio::fs::read(local_path).await?;
        self.put_bytes(path, bytes, mime).await
    }
}
