//! Fournisseur `smtp` : relais SMTP d'une intégration (`lettre`, TLS rustls), identifiants lus
//! du coffre-fort.
//!
//! Classement : connexion, délai dépassé ou réponse 4xx → `transient` ; 550, 551 ou 553 →
//! `recipient_rejected` (adresse supprimée) ; autre 5xx ou message refusé avant l'envoi →
//! `permanent`. La signature DKIM est faite par le relais (décision N4). Le relais en clair
//! (`local_plain`) n'est permis que sur la boucle locale (et, en base, pour l'installation).

use async_trait::async_trait;
use lettre::message::header::{HeaderName, HeaderValue};
use lettre::message::{Mailbox, MultiPart};
use lettre::transport::smtp::authentication::Credentials as SmtpCredentials;
use lettre::transport::smtp::extension::ClientId;
use lettre::{Address, AsyncSmtpTransport, AsyncTransport, Message, Tokio1Executor};
use std::net::IpAddr;
use std::time::Duration;

use super::{
    missing, normalize_message_id, unsubscribe_header, Credentials, EmailMessage, EmailProvider,
    ProviderError, ProviderReceipt,
};
use crate::models::{FailureClass, IntegrationSettings};

/// En-tête du lien de désabonnement (RFC 2369).
const LIST_UNSUBSCRIBE: HeaderName = HeaderName::new_from_ascii_str("List-Unsubscribe");
/// En-tête du désabonnement en un clic (RFC 8058).
const LIST_UNSUBSCRIBE_POST: HeaderName = HeaderName::new_from_ascii_str("List-Unsubscribe-Post");

/// Sécurité de la connexion SMTP.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SmtpSecurity {
    /// TLS implicite (port 465 en général).
    Tls,
    /// STARTTLS obligatoire (port 587 en général).
    StartTls,
    /// Sans chiffrement : refusé hors de la boucle locale (relais local, tests).
    LocalPlain,
}

impl SmtpSecurity {
    /// Valeur du réglage : `tls`, `starttls` ou `local_plain`.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "tls" => Some(Self::Tls),
            "starttls" => Some(Self::StartTls),
            "local_plain" => Some(Self::LocalPlain),
            _ => None,
        }
    }
}

/// Classe d'un code de réponse SMTP négatif.
pub fn classify_smtp_code(code: u16) -> FailureClass {
    match code {
        550 | 551 | 553 => FailureClass::RecipientRejected,
        400..=499 => FailureClass::Transient,
        _ => FailureClass::Permanent,
    }
}

/// Relais SMTP d'une intégration : une connexion par envoi, délai par commande borné.
pub struct SmtpProvider {
    timeout: Duration,
}

impl SmtpProvider {
    /// Fournisseur SMTP avec un délai par commande.
    pub fn new(timeout: Duration) -> Self {
        Self { timeout }
    }

    fn transport(
        &self,
        settings: &IntegrationSettings,
        credentials: &Credentials,
        domain: &str,
    ) -> Result<AsyncSmtpTransport<Tokio1Executor>, ProviderError> {
        let host = settings.host.as_deref().ok_or_else(|| missing("host"))?;
        let port = settings
            .port
            .and_then(|port| u16::try_from(port).ok())
            .ok_or_else(|| missing("port"))?;
        let security = settings
            .security
            .as_deref()
            .and_then(SmtpSecurity::parse)
            .ok_or_else(|| missing("security"))?;
        let invalid_host = || ProviderError::configuration("hôte SMTP invalide");
        let builder = match security {
            SmtpSecurity::Tls => {
                AsyncSmtpTransport::<Tokio1Executor>::relay(host).map_err(|_| invalid_host())?
            }
            SmtpSecurity::StartTls => AsyncSmtpTransport::<Tokio1Executor>::starttls_relay(host)
                .map_err(|_| invalid_host())?,
            SmtpSecurity::LocalPlain => {
                let loopback =
                    host == "localhost" || host.parse::<IpAddr>().is_ok_and(|ip| ip.is_loopback());
                if !loopback {
                    return Err(ProviderError::configuration(
                        "local_plain : réservé à un relais de la boucle locale",
                    ));
                }
                AsyncSmtpTransport::<Tokio1Executor>::builder_dangerous(host)
            }
        };
        let mut builder = builder
            .port(port)
            .timeout(Some(self.timeout))
            .hello_name(ClientId::Domain(domain.to_string()));
        match credentials {
            Credentials::Login { username, password } => {
                builder = builder.credentials(SmtpCredentials::new(
                    username.expose_secret().to_string(),
                    password.expose_secret().to_string(),
                ));
            }
            Credentials::None => {}
            Credentials::ApiKey(_) => {
                return Err(ProviderError::secret(
                    "identifiant et mot de passe SMTP attendus",
                ))
            }
        }
        Ok(builder.build())
    }

    fn message(
        settings: &IntegrationSettings,
        email: &EmailMessage,
        message_id: &str,
    ) -> Result<Message, ProviderError> {
        let from: Address = settings
            .from_address
            .parse()
            .map_err(|_| ProviderError::configuration("adresse d'expédition invalide"))?;
        let to: Address = email.to.parse().map_err(|_| ProviderError {
            class: FailureClass::RecipientRejected,
            code: "NOTIFICATION_SMTP_RECIPIENT_REJECTED".to_string(),
            detail: "adresse du destinataire invalide".to_string(),
        })?;
        let mut builder = Message::builder()
            .message_id(Some(message_id.to_string()))
            .from(Mailbox::new(settings.from_name.clone(), from))
            .to(Mailbox::new(email.to_name.clone(), to))
            .subject(email.content.subject.clone());
        if let Some(reply_to) = &settings.reply_to {
            let address: Address = reply_to
                .parse()
                .map_err(|_| ProviderError::configuration("adresse de réponse invalide"))?;
            builder = builder.reply_to(Mailbox::new(None, address));
        }
        if let Some(url) = &email.list_unsubscribe {
            let url = unsubscribe_header(url)?;
            builder = builder
                .raw_header(HeaderValue::new(LIST_UNSUBSCRIBE, format!("<{url}>")))
                .raw_header(HeaderValue::new(
                    LIST_UNSUBSCRIBE_POST,
                    "List-Unsubscribe=One-Click".to_string(),
                ));
        }
        builder
            .multipart(MultiPart::alternative_plain_html(
                email.content.text.clone(),
                email.content.html.clone(),
            ))
            .map_err(|_| ProviderError::configuration("message invalide"))
    }
}

#[async_trait]
impl EmailProvider for SmtpProvider {
    async fn send(
        &self,
        settings: &IntegrationSettings,
        email: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let domain = settings
            .from_address
            .rsplit_once('@')
            .map(|(_, domain)| domain.to_string())
            .ok_or_else(|| ProviderError::configuration("adresse d'expédition invalide"))?;
        let message_id = format!("<{}@{domain}>", uuid::Uuid::now_v7().simple());
        let message = Self::message(settings, email, &message_id)?;
        let transport = self.transport(settings, credentials, &domain)?;
        match transport.send(message).await {
            Ok(response) => Ok(ProviderReceipt {
                message_id: normalize_message_id(&message_id),
                code: response.code().to_string().parse().unwrap_or(250),
            }),
            Err(error) => Err(classify_error(&error)),
        }
    }
}

/// Classe d'une erreur `lettre`.
fn classify_error(error: &lettre::transport::smtp::Error) -> ProviderError {
    match error.status() {
        Some(status) => {
            let code: u16 = status.to_string().parse().unwrap_or(554);
            ProviderError {
                class: classify_smtp_code(code),
                code: code.to_string(),
                detail: format!("réponse SMTP {code}"),
            }
        }
        None if error.is_client() => ProviderError {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_SMTP_PERMANENT".to_string(),
            detail: "message refusé par le client SMTP".to_string(),
        },
        None => ProviderError {
            class: FailureClass::Transient,
            code: "NOTIFICATION_SMTP_TRANSIENT".to_string(),
            detail: if error.is_timeout() {
                "délai SMTP dépassé".to_string()
            } else {
                "connexion au relais SMTP impossible".to_string()
            },
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::render::RenderedEmail;

    #[test]
    fn smtp_codes_are_classified() {
        assert_eq!(classify_smtp_code(421), FailureClass::Transient);
        assert_eq!(classify_smtp_code(452), FailureClass::Transient);
        for code in [550, 551, 553] {
            assert_eq!(classify_smtp_code(code), FailureClass::RecipientRejected);
        }
        assert_eq!(classify_smtp_code(552), FailureClass::Permanent);
        assert_eq!(classify_smtp_code(554), FailureClass::Permanent);
    }

    #[tokio::test]
    async fn plain_smtp_is_limited_to_loopback() {
        let settings = |host: &str| IntegrationSettings {
            from_address: "noreply@lyxal.test".to_string(),
            host: Some(host.to_string()),
            port: Some(25),
            security: Some("local_plain".to_string()),
            ..IntegrationSettings::default()
        };
        let provider = SmtpProvider::new(Duration::from_secs(5));
        assert!(provider
            .transport(&settings("127.0.0.1"), &Credentials::None, "lyxal.test")
            .is_ok());
        assert!(provider
            .transport(&settings("localhost"), &Credentials::None, "lyxal.test")
            .is_ok());
        let refused = provider
            .send(
                &settings("smtp.exemple.fr"),
                &EmailMessage {
                    to: "a@exemple.fr".into(),
                    to_name: None,
                    list_unsubscribe: None,
                    content: RenderedEmail {
                        subject: "s".into(),
                        html: "h".into(),
                        text: "t".into(),
                    },
                },
                &Credentials::None,
            )
            .await
            .expect_err("relais en clair hors de la boucle locale");
        assert_eq!(refused.code, "NOTIFICATION_CONFIGURATION_INVALID");
    }
}
