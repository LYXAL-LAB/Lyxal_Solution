//! Fournisseurs d'e-mail (décision K5) : SMTP (`lettre`) et API HTTP de Brevo, Mailgun, Postmark
//! et Resend (`reqwest`, décision K10). Chaque fournisseur implémente [`EmailProvider`] ;
//! [`EmailProviders`] choisit celui d'une intégration et [`EmailDispatcher`] lit ses
//! identifiants dans `lyxal_secrets` (chemin tracé, module annoncé comme consommateur) avant
//! l'envoi. Les identifiants restent en [`SecretString`] : jamais journalisés, jamais dans un
//! `Debug`, jamais écrits dans une table du module.
//!
//! Classement d'un échec (plan du lot 3, §6) : réponse 2xx acceptée ; 400, 401, 403, 422 et
//! tout autre refus du client définitifs (aucune bascule) ; 429, 5xx, réseau ou délai dépassé
//! temporaires (bascule vers l'intégration suivante, D3).

mod http;
mod smtp;

use async_trait::async_trait;
use lyxal_crypto::{SecretBytes, SecretString};
use lyxal_secrets::{ClientRead, SecretsClient};
use lyxal_surreal::ToSql;
use serde::Deserialize;
use std::fmt;
use std::sync::Arc;
use std::time::Duration;

use crate::error::NotificationResult;
use crate::models::{ClaimedIntegration, FailureClass, IntegrationSettings};
use crate::render::RenderedEmail;
use crate::webhook::{ProviderEvent, ProviderWebhook, WebhookError, WebhookRequest};

pub use self::http::{ApiEndpoints, MAX_RESPONSE_BYTES, REQUEST_TIMEOUT};
pub use self::smtp::{classify_smtp_code, SmtpProvider, SmtpSecurity};

/// Module annoncé à `lyxal_secrets` comme consommateur des identifiants.
pub const SECRETS_CONSUMER: &str = "lyxal_notification";

/// Fournisseur d'une intégration.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Provider {
    /// Relais SMTP.
    Smtp,
    /// Brevo (API HTTP).
    Brevo,
    /// Mailgun (API HTTP).
    Mailgun,
    /// Postmark (API HTTP).
    Postmark,
    /// Resend (API HTTP).
    Resend,
}

impl Provider {
    /// Fournisseur d'après sa valeur en base.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "smtp" => Some(Self::Smtp),
            "brevo" => Some(Self::Brevo),
            "mailgun" => Some(Self::Mailgun),
            "postmark" => Some(Self::Postmark),
            "resend" => Some(Self::Resend),
            _ => None,
        }
    }

    /// Valeur en base.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Smtp => "smtp",
            Self::Brevo => "brevo",
            Self::Mailgun => "mailgun",
            Self::Postmark => "postmark",
            Self::Resend => "resend",
        }
    }
}

/// Identifiants d'une intégration, lus du coffre-fort (valeur JSON) : SMTP
/// `{ username, password }` (ou `{}` pour un relais sans authentification) ; Brevo, Mailgun,
/// Postmark, Resend `{ api_key }`.
pub enum Credentials {
    /// Relais SMTP sans authentification.
    None,
    /// Identifiant et mot de passe SMTP.
    Login {
        /// Identifiant.
        username: SecretString,
        /// Mot de passe.
        password: SecretString,
    },
    /// Clé d'API.
    ApiKey(SecretString),
}

impl fmt::Debug for Credentials {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::None => "Credentials::None",
            Self::Login { .. } => "Credentials::Login([REDACTED])",
            Self::ApiKey(_) => "Credentials::ApiKey([REDACTED])",
        })
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct LoginValue {
    #[serde(default)]
    username: Option<String>,
    #[serde(default)]
    password: Option<String>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct ApiKeyValue {
    api_key: String,
}

fn secret(text: String) -> Result<SecretString, ProviderError> {
    if text.is_empty() {
        return Err(ProviderError::secret("identifiant vide"));
    }
    SecretString::new(text).map_err(|_| ProviderError::secret("identifiant trop long"))
}

impl Credentials {
    /// Identifiants du fournisseur lus dans la valeur du coffre-fort ; une valeur d'une autre
    /// forme est refusée sans rien en dire.
    pub fn parse(provider: Provider, value: &SecretBytes) -> Result<Self, ProviderError> {
        let shape = || ProviderError::secret("forme des identifiants inattendue");
        match provider {
            Provider::Smtp => {
                let login: LoginValue =
                    serde_json::from_slice(value.expose_secret()).map_err(|_| shape())?;
                match (login.username, login.password) {
                    (Some(username), Some(password)) => Ok(Self::Login {
                        username: secret(username)?,
                        password: secret(password)?,
                    }),
                    (None, None) => Ok(Self::None),
                    _ => Err(shape()),
                }
            }
            _ => {
                let key: ApiKeyValue =
                    serde_json::from_slice(value.expose_secret()).map_err(|_| shape())?;
                Ok(Self::ApiKey(secret(key.api_key)?))
            }
        }
    }

    fn api_key(&self) -> Result<&SecretString, ProviderError> {
        match self {
            Self::ApiKey(key) => Ok(key),
            _ => Err(ProviderError::secret("clé d'API attendue")),
        }
    }
}

/// Message prêt à partir.
pub struct EmailMessage {
    /// Destinataire.
    pub to: String,
    /// Nom du destinataire.
    pub to_name: Option<String>,
    /// Lien de désabonnement en un clic : en-têtes `List-Unsubscribe` et
    /// `List-Unsubscribe-Post: List-Unsubscribe=One-Click` (RFC 8058) ; absent pour un parcours
    /// critique.
    pub list_unsubscribe: Option<String>,
    /// Message rendu.
    pub content: RenderedEmail,
}

impl fmt::Debug for EmailMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("EmailMessage")
            .field("to", &"[REDACTED]")
            .field("list_unsubscribe", &self.list_unsubscribe.is_some())
            .field("content", &self.content)
            .finish()
    }
}

/// Envoi accepté par le fournisseur.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProviderReceipt {
    /// Identifiant du message chez le fournisseur, sans chevrons (absent si la réponse
    /// acceptée ne l'a pas donné lisiblement).
    pub message_id: Option<String>,
    /// Code de réponse (SMTP ou HTTP).
    pub code: u16,
}

/// Échec d'envoi classé ; le détail ne contient ni contenu ni identifiant.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProviderError {
    /// Classe.
    pub class: FailureClass,
    /// Code (SMTP à trois chiffres, ou `NOTIFICATION_*`).
    pub code: String,
    /// Détail court.
    pub detail: String,
}

impl ProviderError {
    /// Échec temporaire du fournisseur (réseau, 429, 5xx).
    pub fn unavailable(detail: impl Into<String>) -> Self {
        Self {
            class: FailureClass::Transient,
            code: "NOTIFICATION_PROVIDER_UNAVAILABLE".to_string(),
            detail: detail.into(),
        }
    }

    /// Refus définitif du fournisseur.
    pub fn rejected(detail: impl Into<String>) -> Self {
        Self {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_PROVIDER_REJECTED".to_string(),
            detail: detail.into(),
        }
    }

    /// Réglage ou message refusé avant l'envoi.
    pub fn configuration(detail: impl Into<String>) -> Self {
        Self {
            class: FailureClass::Permanent,
            code: "NOTIFICATION_CONFIGURATION_INVALID".to_string(),
            detail: detail.into(),
        }
    }

    /// Identifiants illisibles ou absents du coffre-fort : temporaire (la tentative suivante
    /// passe à l'intégration éligible suivante, et un secret corrigé sert au tour d'après).
    pub fn secret(detail: impl Into<String>) -> Self {
        Self {
            class: FailureClass::Transient,
            code: "NOTIFICATION_INTEGRATION_SECRET_INVALID".to_string(),
            detail: detail.into(),
        }
    }
}

/// Fournisseur d'e-mail.
#[async_trait]
pub trait EmailProvider: Send + Sync {
    /// Envoie un message avec les réglages de l'intégration et ses identifiants.
    async fn send(
        &self,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError>;
}

/// Les cinq fournisseurs, avec leurs adresses d'API fixées dans le code.
pub struct EmailProviders {
    smtp: SmtpProvider,
    api: Arc<http::HttpApi>,
}

impl EmailProviders {
    /// Fournisseurs de production : API en HTTPS seulement, adresses fixes.
    pub fn new() -> NotificationResult<Self> {
        Ok(Self {
            smtp: SmtpProvider::new(REQUEST_TIMEOUT),
            api: Arc::new(http::HttpApi::new(ApiEndpoints::production()?, true)?),
        })
    }

    /// Réservé aux tests : API servies par de faux fournisseurs locaux sous `base`
    /// (`http://127.0.0.1:<port>`, boucle locale seulement : toute autre adresse est refusée) ;
    /// voir [`ApiEndpoints::local`].
    pub fn for_local_tests(base: &str) -> NotificationResult<Self> {
        Ok(Self {
            smtp: SmtpProvider::new(Duration::from_secs(5)),
            api: Arc::new(http::HttpApi::new(ApiEndpoints::local(base)?, false)?),
        })
    }

    /// Envoie par le fournisseur `provider`.
    pub async fn send(
        &self,
        provider: Provider,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        match provider {
            Provider::Smtp => self.smtp.send(settings, message, credentials).await,
            Provider::Brevo => self.api.brevo(settings, message, credentials).await,
            Provider::Mailgun => self.api.mailgun(settings, message, credentials).await,
            Provider::Postmark => self.api.postmark(settings, message, credentials).await,
            Provider::Resend => self.api.resend(settings, message, credentials).await,
        }
    }
}

/// Envoi par une intégration : identifiants lus dans `lyxal_secrets` (session système de
/// l'hôte, `lyxal_notification` annoncé comme consommateur), puis fournisseur de l'intégration.
#[derive(Clone)]
pub struct EmailDispatcher {
    providers: Arc<EmailProviders>,
    secrets: SecretsClient,
}

impl EmailDispatcher {
    /// Envoi sur les fournisseurs `providers` et le client du coffre-fort `secrets`.
    pub fn new(providers: Arc<EmailProviders>, secrets: SecretsClient) -> Self {
        Self { providers, secrets }
    }

    /// Valeur d'un secret de l'intégration (portée de l'intégration, étiquette `current`).
    pub async fn read_secret(
        &self,
        integration: &ClaimedIntegration,
        path: &str,
    ) -> Result<SecretBytes, ProviderError> {
        self.secrets
            .read(ClientRead {
                tenant: integration.tenant.as_ref().map(ToSql::to_sql),
                path: path.to_string(),
                label: None,
            })
            .await
            .map(|revealed| revealed.value)
            .map_err(|error| ProviderError::secret(format!("lecture refusée ({})", error.code())))
    }

    /// Envoie un message par l'intégration.
    pub async fn send(
        &self,
        integration: &ClaimedIntegration,
        message: &EmailMessage,
    ) -> Result<ProviderReceipt, ProviderError> {
        let provider = Provider::parse(&integration.provider)
            .ok_or_else(|| ProviderError::configuration("fournisseur inconnu"))?;
        let value = self
            .read_secret(integration, &integration.credentials_path)
            .await?;
        let credentials = Credentials::parse(provider, &value)?;
        drop(value);
        self.providers
            .send(provider, &integration.settings, message, &credentials)
            .await
    }

    /// Vérifie un retour reçu pour l'intégration avec son secret des retours (lu dans
    /// `lyxal_secrets`) et rend ses événements retenus ; `now` : heure du serveur en secondes Unix.
    pub async fn verify_webhook(
        &self,
        integration: &ClaimedIntegration,
        request: &WebhookRequest<'_>,
        now: i64,
    ) -> Result<Vec<ProviderEvent>, WebhookError> {
        let provider = Provider::parse(&integration.provider).ok_or(WebhookError::Secret)?;
        let path = integration
            .webhook_path
            .as_deref()
            .ok_or(WebhookError::Secret)?;
        let secret = self
            .read_secret(integration, path)
            .await
            .map_err(|_| WebhookError::Secret)?;
        ProviderWebhook::verify(provider, &secret, request, now)
    }

    /// Essai d'une intégration (D6) : un court e-mail en français et en anglais à `to`.
    pub async fn send_test(
        &self,
        integration: &ClaimedIntegration,
        to: &str,
    ) -> Result<ProviderReceipt, ProviderError> {
        let message = EmailMessage {
            to: to.to_string(),
            to_name: None,
            list_unsubscribe: None,
            content: RenderedEmail {
                subject: "Lyxal : e-mail d'essai / test email".to_string(),
                html: "<p>Cet e-mail d'essai confirme que l'intégration fonctionne.</p>\n<p lang=\"en\">This test email confirms that the integration works.</p>".to_string(),
                text: "Cet e-mail d'essai confirme que l'intégration fonctionne.\n\nThis test email confirms that the integration works.\n".to_string(),
            },
        };
        self.send(integration, &message).await
    }
}

impl fmt::Debug for EmailDispatcher {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("EmailDispatcher")
            .field("secrets", &self.secrets)
            .finish_non_exhaustive()
    }
}

/// Identifiant d'un message sans espaces ni chevrons (`<id@domaine>` → `id@domaine`) : même
/// forme à l'envoi et dans les retours.
pub fn normalize_message_id(value: &str) -> Option<String> {
    let trimmed = value
        .trim()
        .trim_start_matches('<')
        .trim_end_matches('>')
        .trim();
    if trimmed.is_empty() || trimmed.len() > 512 || trimmed.chars().any(char::is_control) {
        return None;
    }
    Some(trimmed.to_string())
}

/// Adresse sûre dans un en-tête : sans espace, chevron, guillemet ni caractère de contrôle.
pub(crate) fn header_address(address: &str) -> Result<&str, ProviderError> {
    if address.is_empty()
        || !address.contains('@')
        || address.chars().any(|c| {
            c.is_control() || c.is_whitespace() || matches!(c, '<' | '>' | '"' | ',' | ';')
        })
    {
        return Err(ProviderError::configuration("adresse invalide"));
    }
    Ok(address)
}

/// Nom affiché d'une adresse, entre guillemets (contrôles retirés, `"` et `\` échappés) :
/// `"Nom" <adresse>`, ou l'adresse seule.
pub(crate) fn mailbox(name: Option<&str>, address: &str) -> Result<String, ProviderError> {
    let address = header_address(address)?;
    let name = name
        .map(|n| n.chars().filter(|c| !c.is_control()).collect::<String>())
        .map(|n| n.trim().to_string())
        .filter(|n| !n.is_empty());
    Ok(match name {
        Some(name) => format!(
            "\"{}\" <{address}>",
            name.replace('\\', "\\\\").replace('"', "\\\"")
        ),
        None => address.to_string(),
    })
}

/// Lien de désabonnement sûr dans un en-tête (fait par `UnsubscribeLinks` : ASCII sans espace ni
/// chevron).
pub(crate) fn unsubscribe_header(url: &str) -> Result<&str, ProviderError> {
    if !url.is_ascii() || url.contains(|c: char| c.is_whitespace() || c == '<' || c == '>') {
        return Err(ProviderError::configuration(
            "lien de désabonnement invalide",
        ));
    }
    Ok(url)
}

/// Valeur d'erreur de configuration pour un réglage absent.
pub(crate) fn missing(field: &str) -> ProviderError {
    ProviderError::configuration(format!("réglage {field} absent"))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn bytes(value: &str) -> SecretBytes {
        SecretBytes::new(value.as_bytes().to_vec()).expect("valeur")
    }

    #[test]
    fn credentials_are_read_by_provider_and_never_shown() {
        let login = Credentials::parse(
            Provider::Smtp,
            &bytes(r#"{"username":"relais","password":"motdepasse-tres-secret"}"#),
        )
        .expect("identifiants");
        assert!(matches!(login, Credentials::Login { .. }));
        assert!(!format!("{login:?}").contains("motdepasse"));
        assert!(matches!(
            Credentials::parse(Provider::Smtp, &bytes("{}")).expect("sans authentification"),
            Credentials::None
        ));
        let key = Credentials::parse(Provider::Brevo, &bytes(r#"{"api_key":"xkeysib-123"}"#))
            .expect("clé");
        assert!(!format!("{key:?}").contains("xkeysib"));
        for (provider, value) in [
            (Provider::Smtp, r#"{"username":"seul"}"#),
            (Provider::Brevo, r#"{"api_key":"k","extra":1}"#),
            (Provider::Resend, "pas du json"),
            (Provider::Postmark, r#"{"api_key":""}"#),
        ] {
            let error = Credentials::parse(provider, &bytes(value)).expect_err(value);
            assert_eq!(error.code, "NOTIFICATION_INTEGRATION_SECRET_INVALID");
            assert!(!error.detail.contains("xkeysib"));
        }
    }

    #[test]
    fn mailboxes_and_ids_are_safe_in_headers() {
        assert_eq!(
            mailbox(Some("Alpha \"BTP\"\r\nBcc: x"), "devis@alpha.test").expect("adresse"),
            "\"Alpha \\\"BTP\\\"Bcc: x\" <devis@alpha.test>"
        );
        assert_eq!(mailbox(None, "a@b.test").expect("adresse"), "a@b.test");
        assert!(mailbox(None, "a@b.test\r\nBcc: c@d.test").is_err());
        assert!(mailbox(None, "a@b.test, c@d.test").is_err());
        assert_eq!(
            normalize_message_id(" <abc@mg.test> ").as_deref(),
            Some("abc@mg.test")
        );
        assert_eq!(normalize_message_id("<>"), None);
        assert!(unsubscribe_header("https://lyxal.test/u?t=a b").is_err());
    }
}
