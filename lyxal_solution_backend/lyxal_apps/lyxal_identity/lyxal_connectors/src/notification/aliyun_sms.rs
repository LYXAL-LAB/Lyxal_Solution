use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use reqwest::Client;

pub struct AliyunSmsConnector {
    pub access_key_id: String,
    pub access_key_secret: String,
    pub sign_name: String,
    pub template_code: String,
    pub http_client: Client,
}

#[async_trait]
impl Connector for AliyunSmsConnector {
    fn id(&self) -> &str { "aliyun_sms" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Sms }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "aliyun_sms".to_string(),
            target: "aliyun_sms".to_string(),
            connector_type: ConnectorType::Sms,
            name: json!({"en": "Aliyun SMS"}),
            description: json!({"en": "Send SMS via Aliyun"}),
            logo: "/logos/aliyun_sms.svg".to_string(),
            logo_dark: None,
            readme: "Aliyun SMS Integration".to_string(),
            config_template: "{\"accessKeyId\": \"\", \"accessKeySecret\": \"\", \"signName\": \"\", \"templateCode\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, _config: &serde_json::Value) -> Result<()> { Ok(()) }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for AliyunSmsConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let res = self.http_client
            .get("https://dysmsapi.aliyuncs.com/")
            .query(&[
                ("Action", "SendSms"),
                ("SignName", &self.sign_name),
                ("TemplateCode", &self.template_code),
                ("PhoneNumbers", &payload.to),
                ("TemplateParam", &json!({"code": payload.body}).to_string()),
                ("AccessKeyId", &self.access_key_id),
            ])
            .send()
            .await
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        Ok(res.status().is_success())
    }
}
