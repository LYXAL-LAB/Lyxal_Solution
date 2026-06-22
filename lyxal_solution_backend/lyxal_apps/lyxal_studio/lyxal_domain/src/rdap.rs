use serde::Deserialize;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use url::Url;

#[derive(Deserialize)]
struct DNSList {
    services: Vec<(Vec<String>, Vec<String>)>,
}

pub struct CloudflareChecker {
    dns_cache: Arc<RwLock<HashMap<String, String>>>,
}

impl CloudflareChecker {
    pub fn new() -> Self {
        Self {
            dns_cache: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    async fn fetch_dns_list(&self) -> Option<DNSList> {
        reqwest::get("https://data.iana.org/rdap/dns.json")
            .await
            .ok()?
            .json::<DNSList>()
            .await
            .ok()
    }

    pub async fn is_using_cloudflare(&self, domain: &str) -> Result<bool, String> {
        let tld = Url::parse(&format!("https://{}", domain))
            .map_err(|e| e.to_string())?
            .host_str()
            .ok_or("Invalid host")?
            .split('.')
            .last()
            .ok_or("No TLD found")?
            .to_string();

        let mut cache = self.dns_cache.write().await;
        if cache.is_empty() {
            if let Some(dns) = self.fetch_dns_list().await {
                for (domains, servers) in dns.services {
                    if let Some(server) = servers.first() {
                        for d in domains {
                            cache.insert(d, server.clone());
                        }
                    }
                }
            }
        }

        let server = cache.get(&tld).ok_or("RDAP server not found for TLD")?;
        let url = format!("{}domain/{}", server, domain);
        
        let response = reqwest::get(&url).await.map_err(|e| e.to_string())?;
        if response.status().is_success() {
            let body = response.text().await.map_err(|e| e.to_string())?;
            Ok(body.to_lowercase().contains(".ns.cloudflare.com"))
        } else {
            Ok(false)
        }
    }
}

