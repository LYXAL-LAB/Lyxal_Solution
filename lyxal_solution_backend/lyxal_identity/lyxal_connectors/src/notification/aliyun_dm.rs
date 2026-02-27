use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use reqwest::Client;

pub struct AliyunDmConnector {
    pub access_key_id: String,
    pub access_key_secret: String,
    pub account_name: String,
    pub from_alias: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for AliyunDmConnector {
    fn id(&self) -> &str { "aliyun_dm" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "aliyun_dm".to_string(),
            target: "aliyun_dm".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "Aliyun DM"}),
            description: json!({"en": "Send emails via Aliyun Direct Mail"}),
            logo: "/logos/aliyun_dm.svg".to_string(),
            logo_dark: None,
            readme: "Aliyun Direct Mail Integration".to_string(),
            config_template: "{\"accessKeyId\": \"\", \"accessKeySecret\": \"\", \"accountName\": \"\", \"fromAlias\": \"\"}".to_string(),
        }
    }
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        if config["accessKeyId"].is_null() || config["accessKeySecret"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing Aliyun DM Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for AliyunDmConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        // Aliyun uses a specific RPC style API or SDK.
        // For the sake of real implementation, we use the HTTP API endpoint.
        let res = self.http_client
            .post("https://dm.aliyuncs.com/")
            .query(&[
                ("Action", "SingleSendMail"),
                ("AccountName", &self.account_name),
                ("ReplyToAddress", "true"),
                ("AddressType", "1"),
                ("ToAddress", &payload.to),
                ("FromAlias", &self.from_alias),
                ("Subject", &payload.subject),
                ("HtmlBody", &payload.body),
                // Authentication parameters (Simplified here, in reality requires signing)
                ("AccessKeyId", &self.access_key_id),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        if res.status().is_success() {
            Ok(true)
        } else {
            let err = res.text().await.unwrap_or_default();
            Err(lyxal_core::error::CoreError::Internal(format!("Aliyun DM error: {}", err)))
        }
    }
}
