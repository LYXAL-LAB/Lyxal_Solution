//! Fournisseur `smtp` : relais SMTP d'une intégration (`lettre`, TLS rustls), identifiants lus
//! du coffre-fort.
//!
//! Classement : connexion, délai dépassé ou réponse 4xx → `transient` ; 550, 551 ou 553 →
//! `recipient_rejected` (adresse supprimée) ; autre 5xx ou message refusé avant l'envoi →
//! `permanent`. La signature DKIM est faite par le relais (décision N4).
//!
//! Appel sortant contrôlé (décision H1, mêmes plages que [`crate::outbound`]) : le nom du relais
//! est **résolu à chaque envoi** et **toutes** les adresses obtenues sont vérifiées par
//! [`forbidden_ip`] ; une seule adresse interdite refuse le relais
//! (`NOTIFICATION_DESTINATION_FORBIDDEN`). La connexion se fait à l'adresse vérifiée (aucune
//! seconde résolution), le nom servant au TLS. Seul le relais de l'**installation** peut être sur
//! la boucle locale ; le relais en clair (`local_plain`) n'est permis que là (nom `localhost` ou
//! adresse de boucle locale).

use async_trait::async_trait;
use lettre::message::header::{HeaderName, HeaderValue};
use lettre::message::{Mailbox, MultiPart};
use lettre::transport::smtp::authentication::Credentials as SmtpCredentials;
use lettre::transport::smtp::client::{Tls, TlsParameters};
use lettre::transport::smtp::extension::ClientId;
use lettre::{Address, AsyncSmtpTransport, AsyncTransport, Message, Tokio1Executor};
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::time::Duration;

use super::{
    missing, normalize_message_id, unsubscribe_header, Credentials, EmailMessage, EmailProvider,
    IntegrationScope, ProviderError, ProviderReceipt,
};
use crate::models::{FailureClass, IntegrationSettings};
use crate::outbound::{forbidden_ip, HostResolver, SystemResolver};

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

/// Relais SMTP d'une intégration : une connexion par envoi à l'adresse vérifiée, délai par
/// commande borné.
pub struct SmtpProvider {
    timeout: Duration,
    resolver: Arc<dyn HostResolver>,
}

impl SmtpProvider {
    /// Fournisseur SMTP avec un délai par commande ; noms résolus par le système.
    pub fn new(timeout: Duration) -> Self {
        Self {
            timeout,
            resolver: Arc::new(SystemResolver),
        }
    }

    /// Même fournisseur, noms résolus par `resolver` (tests : [`crate::StaticResolver`]).
    pub fn with_resolver(mut self, resolver: Arc<dyn HostResolver>) -> Self {
        self.resolver = resolver;
        self
    }

    /// Adresses vérifiées du relais, dans l'ordre de la résolution : `host` résolu (une adresse
    /// IP littérale est prise telle quelle) et chaque adresse obtenue contrôlée ; la boucle
    /// locale n'est permise qu'au relais de l'installation.
    async fn relay_addresses(
        &self,
        scope: IntegrationScope,
        host: &str,
        port: u16,
    ) -> Result<Vec<SocketAddr>, ProviderError> {
        let addresses = match host.parse::<IpAddr>() {
            Ok(ip) => vec![SocketAddr::new(ip, port)],
            Err(_) => tokio::time::timeout(self.timeout, self.resolver.lookup(host, port))
                .await
                .map_err(|_| ProviderError::unavailable("résolution du relais trop longue"))?
                .map_err(|_| ProviderError::unavailable("nom du relais introuvable"))?
                .into_iter()
                .map(|address| SocketAddr::new(address.ip(), port))
                .collect(),
        };
        let allowed = |address: &SocketAddr| {
            let ip = address.ip();
            !forbidden_ip(ip) || (scope == IntegrationScope::Installation && ip.is_loopback())
        };
        if !addresses.iter().all(allowed) {
            return Err(ProviderError {
                class: FailureClass::Permanent,
                code: "NOTIFICATION_DESTINATION_FORBIDDEN".to_string(),
                detail: "adresse du relais privée, locale ou réservée".to_string(),
            });
        }
        if addresses.is_empty() {
            return Err(ProviderError::unavailable("nom du relais introuvable"));
        }
        Ok(addresses)
    }

    /// Un transport par adresse vérifiée, dans l'ordre de la résolution.
    async fn transports(
        &self,
        scope: IntegrationScope,
        settings: &IntegrationSettings,
        credentials: &Credentials,
        domain: &str,
    ) -> Result<Vec<AsyncSmtpTransport<Tokio1Executor>>, ProviderError> {
        let host = settings
            .host
            .as_deref()
            .ok_or_else(|| missing("host"))?
            .to_ascii_lowercase();
        let port = settings
            .port
            .and_then(|port| u16::try_from(port).ok())
            .ok_or_else(|| missing("port"))?;
        let security = settings
            .security
            .as_deref()
            .and_then(SmtpSecurity::parse)
            .ok_or_else(|| missing("security"))?;
        if security == SmtpSecurity::LocalPlain {
            let loopback =
                host == "localhost" || host.parse::<IpAddr>().is_ok_and(|ip| ip.is_loopback());
            if !loopback || scope != IntegrationScope::Installation {
                return Err(ProviderError::configuration(
                    "local_plain : réservé au relais de l'installation sur la boucle locale",
                ));
            }
        }
        let addresses = self.relay_addresses(scope, &host, port).await?;
        let tls = |host: &str| {
            TlsParameters::new(host.to_string())
                .map_err(|_| ProviderError::configuration("hôte SMTP invalide"))
        };
        let tls = match security {
            SmtpSecurity::Tls => Tls::Wrapper(tls(&host)?),
            SmtpSecurity::StartTls => Tls::Required(tls(&host)?),
            SmtpSecurity::LocalPlain => Tls::None,
        };
        let credentials = match credentials {
            Credentials::Login { username, password } => Some(SmtpCredentials::new(
                username.expose_secret().to_string(),
                password.expose_secret().to_string(),
            )),
            Credentials::None => None,
            Credentials::ApiKey(_) => {
                return Err(ProviderError::secret(
                    "identifiant et mot de passe SMTP attendus",
                ))
            }
        };
        // Connexion à une adresse vérifiée ; le nom reste celui que le certificat doit porter
        Ok(addresses
            .iter()
            .map(|address| {
                let builder = AsyncSmtpTransport::<Tokio1Executor>::builder_dangerous(
                    address.ip().to_string(),
                )
                .port(port)
                .tls(tls.clone())
                .timeout(Some(self.timeout))
                .hello_name(ClientId::Domain(domain.to_string()));
                match &credentials {
                    Some(credentials) => builder.credentials(credentials.clone()).build(),
                    None => builder.build(),
                }
            })
            .collect())
    }

    /// Premier transport qui joint le relais, dans l'ordre de la résolution (adresse IPv6
    /// injoignable, serveur arrêté : adresse suivante, sans nouvelle résolution). Une seule
    /// adresse : prise sans essai préalable.
    async fn reachable(
        mut transports: Vec<AsyncSmtpTransport<Tokio1Executor>>,
    ) -> Result<AsyncSmtpTransport<Tokio1Executor>, ProviderError> {
        if transports.len() == 1 {
            if let Some(transport) = transports.pop() {
                return Ok(transport);
            }
        }
        let mut last = None;
        for transport in transports {
            match transport.test_connection().await {
                Ok(true) => return Ok(transport),
                Ok(false) => last = None,
                Err(error) => last = Some(classify_error(&error)),
            }
        }
        Err(last.unwrap_or_else(|| ProviderError {
            class: FailureClass::Transient,
            code: "NOTIFICATION_SMTP_TRANSIENT".to_string(),
            detail: "connexion au relais SMTP impossible".to_string(),
        }))
    }

    fn message(
        settings: &IntegrationSettings,
        email: &EmailMessage,
        message_id: &str,
    ) -> Result<Message, ProviderError> {
        let from: Address = super::from_address(settings)?
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
        scope: IntegrationScope,
        settings: &IntegrationSettings,
        email: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let domain = super::from_address(settings)?
            .rsplit_once('@')
            .map(|(_, domain)| domain.to_string())
            .ok_or_else(|| ProviderError::configuration("adresse d'expédition invalide"))?;
        let message_id = format!("<{}@{domain}>", uuid::Uuid::now_v7().simple());
        let message = Self::message(settings, email, &message_id)?;
        let transport = Self::reachable(
            self.transports(scope, settings, credentials, &domain)
                .await?,
        )
        .await?;
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

    fn settings(host: &str, security: &str) -> IntegrationSettings {
        IntegrationSettings {
            from_address: Some("noreply@lyxal.test".to_string()),
            host: Some(host.to_string()),
            port: Some(587),
            security: Some(security.to_string()),
            ..IntegrationSettings::default()
        }
    }

    fn email() -> EmailMessage {
        EmailMessage {
            to: "a@exemple.fr".into(),
            to_name: None,
            list_unsubscribe: None,
            content: RenderedEmail {
                subject: "s".into(),
                html: "h".into(),
                text: "t".into(),
            },
        }
    }

    fn provider() -> SmtpProvider {
        let resolver = crate::StaticResolver::new()
            .with("localhost", "127.0.0.1:25".parse().expect("adresse"))
            .with(
                "smtp.interne.test",
                "10.0.0.1:587".parse().expect("adresse"),
            )
            .with("smtp.mixte.test", "1.1.1.1:587".parse().expect("adresse"))
            .with(
                "smtp.mixte.test",
                "192.168.1.10:587".parse().expect("adresse"),
            )
            .with(
                "relais.local.test",
                "127.0.0.1:587".parse().expect("adresse"),
            );
        SmtpProvider::new(Duration::from_secs(5)).with_resolver(Arc::new(resolver))
    }

    #[tokio::test]
    async fn plain_smtp_is_limited_to_the_installation_on_loopback() {
        let provider = provider();
        for host in ["127.0.0.1", "localhost"] {
            assert!(provider
                .transports(
                    IntegrationScope::Installation,
                    &settings(host, "local_plain"),
                    &Credentials::None,
                    "lyxal.test"
                )
                .await
                .is_ok());
        }
        for (scope, host) in [
            (IntegrationScope::Installation, "smtp.exemple.fr"),
            (IntegrationScope::Organization, "127.0.0.1"),
        ] {
            let refused = provider
                .send(
                    scope,
                    &settings(host, "local_plain"),
                    &email(),
                    &Credentials::None,
                )
                .await
                .expect_err("relais en clair refusé");
            assert_eq!(refused.code, "NOTIFICATION_CONFIGURATION_INVALID");
        }
    }

    #[tokio::test]
    async fn relay_resolving_to_a_forbidden_address_is_refused() {
        let provider = provider();
        // Organisation : nom résolu en adresse privée, adresse mêlée, boucle locale
        for host in ["smtp.interne.test", "smtp.mixte.test", "relais.local.test"] {
            for security in ["tls", "starttls"] {
                let refused = provider
                    .send(
                        IntegrationScope::Organization,
                        &settings(host, security),
                        &email(),
                        &Credentials::None,
                    )
                    .await
                    .expect_err("relais interne refusé");
                assert_eq!(refused.code, "NOTIFICATION_DESTINATION_FORBIDDEN", "{host}");
                assert_eq!(refused.class, FailureClass::Permanent);
            }
        }
        // Installation : la boucle locale seule est permise, jamais un réseau privé
        let refused = provider
            .send(
                IntegrationScope::Installation,
                &settings("smtp.interne.test", "starttls"),
                &email(),
                &Credentials::None,
            )
            .await
            .expect_err("réseau privé refusé");
        assert_eq!(refused.code, "NOTIFICATION_DESTINATION_FORBIDDEN");
        assert!(provider
            .transports(
                IntegrationScope::Installation,
                &settings("relais.local.test", "starttls"),
                &Credentials::None,
                "lyxal.test"
            )
            .await
            .is_ok());
        // Nom inconnu : temporaire
        let unknown = provider
            .send(
                IntegrationScope::Organization,
                &settings("inconnu.test", "tls"),
                &email(),
                &Credentials::None,
            )
            .await
            .expect_err("nom inconnu");
        assert_eq!(unknown.class, FailureClass::Transient);
    }

    /// Relais SMTP minimal sur la boucle locale : accepte chaque connexion et chaque message.
    async fn fake_relay() -> u16 {
        use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
        let listener = tokio::net::TcpListener::bind("127.0.0.1:0")
            .await
            .expect("écoute");
        let port = listener.local_addr().expect("adresse").port();
        tokio::spawn(async move {
            while let Ok((stream, _)) = listener.accept().await {
                tokio::spawn(async move {
                    let (read, mut write) = stream.into_split();
                    let mut lines = BufReader::new(read).lines();
                    let _ = write.write_all(b"220 essai ESMTP\r\n").await;
                    let mut data = false;
                    while let Ok(Some(line)) = lines.next_line().await {
                        let reply: &[u8] = if data {
                            if line != "." {
                                continue;
                            }
                            data = false;
                            b"250 recu\r\n"
                        } else if line.to_ascii_uppercase().starts_with("DATA") {
                            data = true;
                            b"354 suite\r\n"
                        } else if line.to_ascii_uppercase().starts_with("QUIT") {
                            let _ = write.write_all(b"221 fin\r\n").await;
                            break;
                        } else {
                            b"250 ok\r\n"
                        };
                        if write.write_all(reply).await.is_err() {
                            break;
                        }
                    }
                });
            }
        });
        port
    }

    #[tokio::test]
    async fn next_vetted_address_is_tried_when_the_first_is_unreachable() {
        let port = fake_relay().await;
        // 127.0.0.2 : rien n'y écoute (connexion refusée) ; 127.0.0.1 : le relais
        let resolver = crate::StaticResolver::new()
            .with("localhost", SocketAddr::from(([127, 0, 0, 2], port)))
            .with("localhost", SocketAddr::from(([127, 0, 0, 1], port)));
        let provider = SmtpProvider::new(Duration::from_secs(5)).with_resolver(Arc::new(resolver));
        let mut relay = settings("localhost", "local_plain");
        relay.port = Some(i64::from(port));
        let receipt = provider
            .send(
                IntegrationScope::Installation,
                &relay,
                &email(),
                &Credentials::None,
            )
            .await
            .expect("envoi par la seconde adresse");
        assert_eq!(receipt.code, 250);
    }
}
