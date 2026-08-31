//! SMTP Transport & Message delivery helpers.

use anyhow::Result;
use lettre::transport::smtp::authentication::Credentials;
use lettre::{AsyncSmtpTransport, AsyncTransport, Message, Tokio1Executor};
use super::config::{SmtpConfig, SmtpTlsMode};

pub(crate) fn build_smtp_transport(
    config: &SmtpConfig,
) -> Result<AsyncSmtpTransport<Tokio1Executor>> {
    let builder = match config.tls_mode {
        SmtpTlsMode::StartTls => AsyncSmtpTransport::<Tokio1Executor>::starttls_relay(&config.host)?,
        SmtpTlsMode::Tls => AsyncSmtpTransport::<Tokio1Executor>::relay(&config.host)?,
    };

    let transport = builder
        .port(config.port)
        .credentials(Credentials::new(
            config.username.clone(),
            config.password.as_str().to_string(),
        ))
        .build();

    Ok(transport)
}

pub(crate) async fn send_email(config: &SmtpConfig, message: Message) -> Result<()> {
    let transport = build_smtp_transport(config)?;
    transport.send(message).await?;
    Ok(())
}
