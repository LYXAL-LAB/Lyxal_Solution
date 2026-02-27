use async_trait::async_trait;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{Message, AsyncSmtpTransport, Tokio1Executor, AsyncTransport};
use lyxal_core::{CoreError, Result};
use serde::{Deserialize, Serialize};
use crate::base::{Connector, ConnectorMetadata, ConnectorType, ConnectorResponse};

/// Configuration for the SMTP Email Connector
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SmtpConfig {
    pub host: String,
    pub port: u16,
    pub username: Option<String>,
    pub password: Option<String>,
    pub from_email: String,
    pub from_name: Option<String>,
    pub use_tls: bool,
}

/// Trait specific to Email Connectors
#[async_trait]
pub trait EmailConnector: Connector {
    /// Sends an email using the connector
    async fn send_email(
        &self,
        to: &str,
        subject: &str,
        body: &str,
    ) -> Result<ConnectorResponse>;
}

/// SMTP Implementation of the Email Connector
pub struct SmtpConnector {
    metadata: ConnectorMetadata,
    config: SmtpConfig,
}

impl SmtpConnector {
    pub fn new(config: SmtpConfig) -> Self {
        let metadata = ConnectorMetadata {
            id: "smtp-connector".to_string(),
            target: "email".to_string(),
            connector_type: ConnectorType::Email,
            name: serde_json::json!({ "en": "SMTP Email", "fr": "Email SMTP" }),
            description: serde_json::json!({
                "en": "Send emails via SMTP server",
                "fr": "Envoyer des emails via un serveur SMTP"
            }),
            logo: "https://static.lyxal.com/logos/smtp.png".to_string(),
        };

        Self { metadata, config }
    }

    fn build_transport(&self) -> Result<AsyncSmtpTransport<Tokio1Executor>> {
        let transport_builder = if self.config.use_tls {
            AsyncSmtpTransport::<Tokio1Executor>::relay(&self.config.host)
                .map_err(|e| CoreError::Internal(anyhow::anyhow!("SMTP relay build failed: {}", e)))?
        } else {
            AsyncSmtpTransport::<Tokio1Executor>::builder_dangerous(&self.config.host)
        };

        let mut transport_builder = transport_builder.port(self.config.port);

        if let (Some(user), Some(pass)) = (&self.config.username, &self.config.password) {
            let credentials = Credentials::new(user.clone(), pass.clone());
            transport_builder = transport_builder.credentials(credentials);
        }

        Ok(transport_builder.build())
    }
}

#[async_trait]
impl Connector for SmtpConnector {
    fn id(&self) -> &str {
        &self.metadata.id
    }

    fn connector_type(&self) -> ConnectorType {
        ConnectorType::Email
    }

    fn metadata(&self) -> ConnectorMetadata {
        self.metadata.clone()
    }

    async fn validate_config(&self, config: &serde_json::Value) -> Result<()> {
        serde_json::from_value::<SmtpConfig>(config.clone())
            .map(|_| ())
            .map_err(|e| CoreError::Validation(format!("Invalid SMTP config: {}", e)))
    }

    async fn test_connection(&self) -> Result<bool> {
        let transport = self.build_transport()?;
        match transport.test_connection().await {
            Ok(result) => Ok(result),
            Err(e) => Err(CoreError::Internal(anyhow::anyhow!("SMTP connection test failed: {}", e))),
        }
    }
}

#[async_trait]
impl EmailConnector for SmtpConnector {
    async fn send_email(
        &self,
        to: &str,
        subject: &str,
        body: &str,
    ) -> Result<ConnectorResponse> {
        let from = if let Some(name) = &self.config.from_name {
            format!("{} <{}>", name, self.config.from_email)
        } else {
            self.config.from_email.clone()
        };

        let email = Message::builder()
            .from(from.parse().map_err(|_| CoreError::Validation("Invalid from email".into()))?)
            .to(to.parse().map_err(|_| CoreError::Validation("Invalid to email".into()))?)
            .subject(subject)
            .header(lettre::message::header::ContentType::TEXT_HTML)
            .body(body.to_string())
            .map_err(|e| CoreError::Internal(anyhow::anyhow!("Email message build failed: {}", e)))?;

        let transport = self.build_transport()?;

        match transport.send(email).await {
            Ok(_) => Ok(ConnectorResponse {
                success: true,
                message: Some("Email sent successfully".into()),
                data: None,
            }),
            Err(e) => Ok(ConnectorResponse {
                success: false,
                message: Some(format!("Failed to send email: {}", e)),
                data: None,
            }),
        }
    }
}
