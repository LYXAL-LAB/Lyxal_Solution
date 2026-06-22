use reqwest::{Client, ClientBuilder, header};
use std::time::Duration;

pub struct ApiClient {
    inner: Client,
}

impl ApiClient {
    pub fn new(token: Option<&str>) -> Self {
        let mut headers = header::HeaderMap::new();
        if let Some(t) = token {
            headers.insert("Authorization", header::HeaderValue::from_str(t).unwrap());
        }
        let client = ClientBuilder::new()
            .default_headers(headers)
            .timeout(Duration::from_secs(30))
            .build()
            .unwrap();
        Self { inner: client }
    }

    // Portage de la logique fetch wrapper
    pub async fn get(&self, url: &str) -> Result<serde_json::Value, reqwest::Error> {
        self.inner.get(url).send().await?.json().await
    }
}

