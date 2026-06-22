use async_trait::async_trait;
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use crate::notification::{NotificationConnector, NotificationPayload};
use lyxal_core::Result;
use serde_json::json;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, SmtpTransport, Transport};

pub struct SmtpConnector {
    pub host: String,
    pub port: u16,
    pub username: Option<String>,
    pub password: Option<String>,
    pub from_email: String,
}

#[async_trait]
impl Connector for SmtpConnector {
    fn id(&self) -> &str { "smtp" }
    fn connector_type(&self) -> ConnectorType { ConnectorType::Email }
    fn metadata(&self) -> ConnectorMetadata {
        ConnectorMetadata {
            id: "smtp".to_string(),
            target: "smtp".to_string(),
            connector_type: ConnectorType::Email,
            name: json!({"en": "SMTP", "fr": "SMTP"}),
            description: json!({"en": "Send emails via SMTP", "fr": "Envoi d'emails via SMTP"}),
            logo: "/logos/smtp.svg".to_string(),
            logo_dark: None,
            readme: "SMTP Notification Integration".to_string(),
            config_template: "{\"host\": \"\", \"port\": 587, \"username\": \"\", \"password\": \"\", \"fromEmail\": \"\" }".to_string(),
        }
    }
    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        if config["host"].is_null() || config["fromEmail"].is_null() {
            return Err(lyxal_core::error::CoreError::Internal("Missing SMTP Config".to_string()));
        }
        Ok(())
    }
    async fn test_connection(&self) -> Result<bool> { Ok(true) }
}

#[async_trait]
impl NotificationConnector for SmtpConnector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool> {
        let email = Message::builder()
            .from(self.from_email.parse().map_err(|e| lyxal_core::error::CoreError::Internal(format!("Invalid from email: {}", e)))?)
            .to(payload.to.parse().map_err(|e| lyxal_core::error::CoreError::Internal(format!("Invalid recipient email: {}", e)))?)
            .subject(payload.subject)
            .body(payload.body)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?;

        let mut mailer_builder = SmtpTransport::relay(&self.host)
            .map_err(|e| lyxal_core::error::CoreError::Internal(e.to_string()))?
            .port(self.port);

        if let (Some(user), Some(pass)) = (&self.username, &self.password) {
            mailer_builder = mailer_builder.credentials(Credentials::new(user.clone(), pass.clone()));
        }

        let mailer = mailer_builder.build();
        
        match mailer.send(&email) {
            Ok(_) => Ok(true),
            Err(e) => Err(lyxal_core::error::CoreError::Internal(e.to_string())),
        }
    }
}
