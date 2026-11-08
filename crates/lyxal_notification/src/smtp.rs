//! Envoi SMTP (`lettre`, TLS rustls) et classement des échecs.
//!
//! Classement (plan V1-a) : connexion, délai dépassé ou réponse 4xx → `transient` ; 550, 551 ou
//! 553 → `recipient_rejected` (adresse supprimée) ; autre 5xx ou message refusé avant l'envoi →
//! `permanent`. La signature DKIM est faite par le relais (décision N4).

use async_trait::async_trait;
use lettre::message::{Mailbox, MultiPart};
use lettre::transport::smtp::authentication::Credentials;
use lettre::transport::smtp::extension::ClientId;
use lettre::{Address, AsyncSmtpTransport, AsyncTransport, Message, Tokio1Executor};
use lyxal_crypto::SecretString;
use std::net::IpAddr;
use std::time::Duration;

use crate::error::{NotificationError, NotificationResult};
use crate::models::FailureClass;
use crate::render::RenderedEmail;

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
    /// Valeur de configuration : `tls`, `starttls` ou `local_plain`.
    pub fn parse(value: &str) -> NotificationResult<Self> {
        match value {
            "tls" => Ok(Self::Tls),
            "starttls" => Ok(Self::StartTls),
            "local_plain" => Ok(Self::LocalPlain),
            _ => Err(NotificationError::Configuration(
                "smtp.security : tls, starttls ou local_plain attendu".to_string(),
            )),
        }
    }
}

/// Configuration SMTP de l'hôte (un seul serveur pour l'installation avant `lyxal_secrets`).
pub struct SmtpSettings {
    /// Hôte du relais.
    pub host: String,
    /// Port.
    pub port: u16,
    /// Sécurité de la connexion.
    pub security: SmtpSecurity,
    /// Identifiant de connexion.
    pub username: Option<String>,
    /// Mot de passe (jamais journalisé).
    pub password: Option<SecretString>,
    /// Adresse d'expédition.
    pub from_address: String,
    /// Nom d'expéditeur par défaut (les réglages du locataire priment).
    pub from_name: Option<String>,
    /// Délai maximal d'une commande SMTP.
    pub timeout: Duration,
}

impl std::fmt::Debug for SmtpSettings {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SmtpSettings")
            .field("host", &self.host)
            .field("port", &self.port)
            .field("security", &self.security)
            .field("username", &self.username)
            .field("password", &self.password.as_ref().map(|_| "[REDACTED]"))
            .field("from_address", &self.from_address)
            .finish_non_exhaustive()
    }
}

/// Message prêt à partir.
#[derive(Debug)]
pub struct OutgoingEmail {
    /// Destinataire.
    pub to: String,
    /// Nom du destinataire.
    pub to_name: Option<String>,
    /// Nom d'expéditeur (réglages du locataire, sinon configuration).
    pub from_name: Option<String>,
    /// Adresse de réponse.
    pub reply_to: Option<String>,
    /// Message rendu.
    pub content: RenderedEmail,
}

/// Envoi accepté par le relais.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Delivered {
    /// `Message-ID` du message.
    pub message_id: String,
    /// Code de réponse SMTP.
    pub code: u16,
}

/// Échec d'envoi classé.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SendFailure {
    /// Classe.
    pub class: FailureClass,
    /// Code (SMTP à trois chiffres, ou `NOTIFICATION_*`).
    pub code: String,
    /// Détail court, sans contenu du message.
    pub detail: String,
}

/// Transport d'e-mails (SMTP en production, transport de test dans les tests).
#[async_trait]
pub trait EmailTransport: Send + Sync {
    /// Envoie un message.
    async fn send(&self, email: OutgoingEmail) -> Result<Delivered, SendFailure>;
    /// Vérifie la connexion au relais (sonde de santé).
    async fn check(&self) -> Result<(), String>;
}

/// Classe d'un code de réponse SMTP négatif.
pub fn classify_smtp_code(code: u16) -> FailureClass {
    match code {
        550 | 551 | 553 => FailureClass::RecipientRejected,
        400..=499 => FailureClass::Transient,
        _ => FailureClass::Permanent,
    }
}

/// Transport SMTP `lettre` (connexions réutilisées) ; à construire dans le runtime Tokio de
/// l'hôte (le groupe de connexions s'y rattache).
pub struct SmtpTransport {
    transport: AsyncSmtpTransport<Tokio1Executor>,
    from: Address,
    from_name: Option<String>,
    domain: String,
}

impl SmtpTransport {
    /// Transport construit depuis la configuration de l'hôte.
    pub fn new(settings: SmtpSettings) -> NotificationResult<Self> {
        let configuration = |message: &str| NotificationError::Configuration(message.to_string());
        let from: Address = settings
            .from_address
            .parse()
            .map_err(|_| configuration("smtp.from_address : adresse invalide"))?;
        let domain = from.domain().to_string();
        let builder = match settings.security {
            SmtpSecurity::Tls => AsyncSmtpTransport::<Tokio1Executor>::relay(&settings.host)
                .map_err(|_| configuration("smtp.host : hôte invalide"))?,
            SmtpSecurity::StartTls => {
                AsyncSmtpTransport::<Tokio1Executor>::starttls_relay(&settings.host)
                    .map_err(|_| configuration("smtp.host : hôte invalide"))?
            }
            SmtpSecurity::LocalPlain => {
                let loopback = settings.host == "localhost"
                    || settings.host.parse::<IpAddr>().is_ok_and(|ip| ip.is_loopback());
                if !loopback {
                    return Err(configuration(
                        "smtp.security local_plain : réservé à un relais de la boucle locale",
                    ));
                }
                AsyncSmtpTransport::<Tokio1Executor>::builder_dangerous(settings.host.clone())
            }
        };
        let mut builder = builder
            .port(settings.port)
            .timeout(Some(settings.timeout))
            .hello_name(ClientId::Domain(domain.clone()));
        match (settings.username, settings.password) {
            (Some(user), Some(password)) => {
                builder = builder
                    .credentials(Credentials::new(user, password.expose_secret().to_string()));
            }
            (None, None) => {}
            _ => {
                return Err(configuration(
                    "smtp.username et smtp.password : fournis ensemble ou pas du tout",
                ))
            }
        }
        Ok(Self {
            transport: builder.build(),
            from,
            from_name: settings.from_name,
            domain,
        })
    }

    fn message(&self, email: OutgoingEmail, message_id: &str) -> Result<Message, SendFailure> {
        let invalid = |what: &str| SendFailure {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_SMTP_PERMANENT".to_string(),
            detail: format!("{what} invalide"),
        };
        let to: Address = email.to.parse().map_err(|_| SendFailure {
            class: FailureClass::RecipientRejected,
            code: "NOTIFICATION_SMTP_RECIPIENT_REJECTED".to_string(),
            detail: "adresse du destinataire invalide".to_string(),
        })?;
        let mut builder = Message::builder()
            .message_id(Some(message_id.to_string()))
            .from(Mailbox::new(
                email.from_name.or_else(|| self.from_name.clone()),
                self.from.clone(),
            ))
            .to(Mailbox::new(email.to_name, to))
            .subject(email.content.subject.clone());
        if let Some(reply_to) = email.reply_to {
            let address: Address = reply_to.parse().map_err(|_| invalid("adresse de réponse"))?;
            builder = builder.reply_to(Mailbox::new(None, address));
        }
        builder
            .multipart(MultiPart::alternative_plain_html(
                email.content.text.clone(),
                email.content.html.clone(),
            ))
            .map_err(|_| invalid("message"))
    }
}

#[async_trait]
impl EmailTransport for SmtpTransport {
    async fn send(&self, email: OutgoingEmail) -> Result<Delivered, SendFailure> {
        let message_id = format!("<{}@{}>", uuid::Uuid::now_v7().simple(), self.domain);
        let message = self.message(email, &message_id)?;
        match self.transport.send(message).await {
            Ok(response) => Ok(Delivered {
                message_id,
                code: response.code().to_string().parse().unwrap_or(250),
            }),
            Err(error) => Err(classify_error(&error)),
        }
    }

    async fn check(&self) -> Result<(), String> {
        match self.transport.test_connection().await {
            Ok(true) => Ok(()),
            Ok(false) => Err("le relais SMTP ne répond pas".to_string()),
            Err(error) => Err(classify_error(&error).detail),
        }
    }
}

/// Classe d'une erreur `lettre`.
fn classify_error(error: &lettre::transport::smtp::Error) -> SendFailure {
    match error.status() {
        Some(status) => {
            let code: u16 = status.to_string().parse().unwrap_or(554);
            let class = classify_smtp_code(code);
            SendFailure {
                class,
                code: code.to_string(),
                detail: format!("réponse SMTP {code}"),
            }
        }
        None if error.is_client() => SendFailure {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_SMTP_PERMANENT".to_string(),
            detail: "message refusé par le client SMTP".to_string(),
        },
        None => SendFailure {
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
        let settings = |host: &str| SmtpSettings {
            host: host.to_string(),
            port: 25,
            security: SmtpSecurity::LocalPlain,
            username: None,
            password: None,
            from_address: "noreply@lyxal.test".to_string(),
            from_name: None,
            timeout: Duration::from_secs(5),
        };
        assert!(SmtpTransport::new(settings("127.0.0.1")).is_ok());
        assert!(SmtpTransport::new(settings("localhost")).is_ok());
        assert!(SmtpTransport::new(settings("smtp.exemple.fr")).is_err());
    }

    #[test]
    fn settings_debug_redacts_password() {
        let settings = SmtpSettings {
            host: "smtp.exemple.fr".to_string(),
            port: 587,
            security: SmtpSecurity::StartTls,
            username: Some("u".to_string()),
            password: Some(SecretString::new("motdepasse-secret".to_string()).expect("secret")),
            from_address: "noreply@lyxal.test".to_string(),
            from_name: None,
            timeout: Duration::from_secs(5),
        };
        assert!(!format!("{settings:?}").contains("motdepasse-secret"));
    }
}
