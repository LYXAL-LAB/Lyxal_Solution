//! Messageries d'équipe (Slack, Microsoft Teams, Discord, Mattermost, Google Chat, Telegram) et
//! appel signé d'une adresse web (décision E4), par le client contrôlé
//! [`OutboundClient`](crate::outbound::OutboundClient) (décision E3 : HTTPS, hôtes officiels ou
//! publics, résolution vérifiée à chaque envoi, aucune redirection).
//!
//! Corps envoyés (texte simple ; le Markdown du service est laissé tel quel, décision E5) :
//! * **Slack** (webhook entrant) : `{ "text" }` ;
//! * **Teams** (connecteur `*.webhook.office.com` ou flux Power Automate) : message portant une
//!   carte adaptative (`TextBlock` du titre, puis du texte) ;
//! * **Discord** (webhook) : `{ "content", "allowed_mentions": { "parse": [] } }` (2 000
//!   caractères au plus ; aucune mention déclenchée) ;
//! * **Mattermost** (webhook entrant) : `{ "text" }` ;
//! * **Google Chat** (webhook d'un espace) : `{ "text" }` ;
//! * **Telegram** : `https://api.telegram.org/bot<jeton>/sendMessage`, `{ "chat_id", "text" }`
//!   (4 096 caractères au plus) ; jeton du robot lu dans `lyxal_secrets` (`{ bot_token }`).
//!
//! Adresse web : corps JSON `{ id, type, workflow, step, run, subscriber_id, payload, text,
//! sent_at }`, en-têtes `Lyxal-Signature: t=<secondes>,v1=<hex>` (HMAC-SHA256 de
//! `<t>.<corps>` sous la clé de signature de l'adresse, `lyxal_crypto`) et
//! `Lyxal-Delivery: <id>`. Réponse 2xx : livré ; 4xx sauf 408 et 429 : refus définitif ; sinon
//! nouvel essai.

use lyxal_crypto::{sign_hmac_sha256_hex, HmacKey, SecretBytes, SecretString};
use reqwest::header::{HeaderMap, HeaderName, HeaderValue};
use reqwest::Url;
use serde::Deserialize;
use serde_json::{json, Value};

use super::{classify_status, ProviderError, ProviderReceipt};
use crate::outbound::{HostRule, OutboundClient, OutboundResponse};

/// Adresse de l'API des robots Telegram.
pub const TELEGRAM_API: &str = "https://api.telegram.org/";
/// Longueur maximale d'un message Discord.
pub const DISCORD_MAX_CHARS: usize = 2000;
/// Longueur maximale d'un message Telegram.
pub const TELEGRAM_MAX_CHARS: usize = 4096;
/// En-tête de signature d'un appel d'adresse web.
pub const SIGNATURE_HEADER: &str = "lyxal-signature";
/// En-tête de l'identifiant de livraison d'un appel d'adresse web (dédoublonnage).
pub const DELIVERY_HEADER: &str = "lyxal-delivery";

/// Service de messagerie.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ChatService {
    /// Slack.
    Slack,
    /// Microsoft Teams.
    Teams,
    /// Discord.
    Discord,
    /// Mattermost (auto-hébergé).
    Mattermost,
    /// Google Chat.
    GoogleChat,
    /// Telegram.
    Telegram,
}

impl ChatService {
    /// Service d'après sa valeur en base.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "slack" => Some(Self::Slack),
            "teams" => Some(Self::Teams),
            "discord" => Some(Self::Discord),
            "mattermost" => Some(Self::Mattermost),
            "google_chat" => Some(Self::GoogleChat),
            "telegram" => Some(Self::Telegram),
            _ => None,
        }
    }

    /// Hôtes acceptés (mêmes listes que `fn::notification_endpoint_official_hosts`) : Teams
    /// accepte les connecteurs Office 365 (`<locataire>.webhook.office.com`) et les flux de
    /// travail Power Automate (`*.logic.azure.com`, `*.environment.api.powerplatform.com`).
    pub fn rule(self) -> HostRule {
        match self {
            Self::Slack => HostRule::Official {
                exact: &["hooks.slack.com"],
                suffixes: &[],
            },
            Self::Teams => HostRule::Official {
                exact: &[],
                suffixes: &[
                    ".webhook.office.com",
                    ".logic.azure.com",
                    ".environment.api.powerplatform.com",
                ],
            },
            Self::Discord => HostRule::Official {
                exact: &["discord.com", "discordapp.com"],
                suffixes: &[],
            },
            Self::GoogleChat => HostRule::Official {
                exact: &["chat.googleapis.com"],
                suffixes: &[],
            },
            Self::Telegram => HostRule::Official {
                exact: &["api.telegram.org"],
                suffixes: &[],
            },
            Self::Mattermost => HostRule::AnyPublic,
        }
    }
}

/// Destination d'un message de messagerie.
pub enum ChatTarget<'a> {
    /// Adresse de webhook ouverte en mémoire (Slack, Teams, Discord, Mattermost, Google Chat).
    Webhook(&'a SecretString),
    /// Telegram : jeton du robot (coffre-fort) et identifiant du salon.
    Telegram {
        /// Jeton du robot.
        bot_token: &'a SecretString,
        /// Identifiant du salon.
        chat_id: &'a str,
    },
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TelegramValue {
    bot_token: String,
}

/// Jeton du robot Telegram lu dans la valeur du coffre-fort (`{ bot_token }`).
pub fn telegram_token(value: &SecretBytes) -> Result<SecretString, ProviderError> {
    let parsed: TelegramValue = serde_json::from_slice(value.expose_secret())
        .map_err(|_| ProviderError::secret("forme des identifiants inattendue"))?;
    // Jeton « <nombre>:<texte> » : jamais d'autre caractère dans le chemin de l'adresse
    let valid = !parsed.bot_token.is_empty()
        && parsed
            .bot_token
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || matches!(b, b':' | b'_' | b'-'));
    if !valid {
        return Err(ProviderError::secret("jeton du robot invalide"));
    }
    SecretString::new(parsed.bot_token).map_err(|_| ProviderError::secret("jeton trop long"))
}

/// Texte borné à `max` caractères (`…` final s'il est coupé).
fn bounded(text: &str, max: usize) -> String {
    if text.chars().count() <= max {
        return text.to_string();
    }
    let mut cut: String = text.chars().take(max.saturating_sub(1)).collect();
    cut.push('…');
    cut
}

/// Corps du message pour un service (titre facultatif en gras, puis le texte).
pub fn chat_body(
    service: ChatService,
    title: Option<&str>,
    text: &str,
    chat_id: Option<&str>,
) -> Value {
    let with_title = |bold: &str| match title {
        Some(title) => format!("{bold}{title}{bold}\n{text}"),
        None => text.to_string(),
    };
    match service {
        ChatService::Slack | ChatService::GoogleChat => json!({ "text": with_title("*") }),
        ChatService::Mattermost => json!({ "text": with_title("**") }),
        ChatService::Discord => json!({
            "content": bounded(&with_title("**"), DISCORD_MAX_CHARS),
            "allowed_mentions": { "parse": [] }
        }),
        ChatService::Telegram => json!({
            "chat_id": chat_id.unwrap_or_default(),
            "text": bounded(&with_title(""), TELEGRAM_MAX_CHARS)
        }),
        ChatService::Teams => {
            let mut blocks = Vec::new();
            if let Some(title) = title {
                blocks.push(json!({ "type": "TextBlock", "text": title, "weight": "Bolder", "size": "Medium", "wrap": true }));
            }
            blocks.push(json!({ "type": "TextBlock", "text": text, "wrap": true }));
            json!({
                "type": "message",
                "attachments": [{
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "contentUrl": null,
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.4",
                        "body": blocks
                    }
                }]
            })
        }
    }
}

/// Envoi aux messageries et aux adresses web par le client contrôlé.
pub struct ChatSender {
    client: OutboundClient,
    telegram: Url,
}

impl std::fmt::Debug for ChatSender {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ChatSender")
            .field("client", &self.client)
            .finish_non_exhaustive()
    }
}

impl ChatSender {
    /// Envoi par le client contrôlé `client`.
    pub fn new(client: OutboundClient) -> Result<Self, ProviderError> {
        Ok(Self {
            client,
            telegram: Url::parse(TELEGRAM_API)
                .map_err(|_| ProviderError::configuration("adresse Telegram invalide"))?,
        })
    }

    /// Message à une adresse de messagerie : 2xx accepté ; 429 et 5xx temporaires ; autres
    /// refus définitifs (redirection comprise : jamais suivie).
    pub async fn send_chat(
        &self,
        service: ChatService,
        target: ChatTarget<'_>,
        title: Option<&str>,
        text: &str,
        allowed_hosts: &[String],
    ) -> Result<ProviderReceipt, ProviderError> {
        let (url, chat_id) = match target {
            ChatTarget::Webhook(url) if service != ChatService::Telegram => {
                (url.expose_secret().to_string(), None)
            }
            ChatTarget::Telegram { bot_token, chat_id } if service == ChatService::Telegram => {
                let mut url = self.telegram.clone();
                url.path_segments_mut()
                    .map_err(|_| ProviderError::configuration("adresse Telegram invalide"))?
                    .pop_if_empty()
                    .push(&format!("bot{}", bot_token.expose_secret()))
                    .push("sendMessage");
                (url.to_string(), Some(chat_id))
            }
            _ => {
                return Err(ProviderError::configuration(
                    "destination d'un autre service",
                ))
            }
        };
        // L'adresse (secret) n'est gardée que le temps de l'appel
        let url = zeroize::Zeroizing::new(url);
        let body = serde_json::to_vec(&chat_body(service, title, text, chat_id))
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        let response = self
            .client
            .post_json(&url, service.rule(), allowed_hosts, HeaderMap::new(), body)
            .await?;
        if !(200..300).contains(&response.status) {
            return Err(classify_status(response.status));
        }
        Ok(ProviderReceipt {
            message_id: chat_message_id(service, chat_id, &response),
            code: response.status,
        })
    }

    /// Appel signé d'une adresse web (E4) : `Lyxal-Signature` et `Lyxal-Delivery` ; `now` :
    /// heure du serveur en secondes Unix.
    pub async fn call_webhook(
        &self,
        url: &SecretString,
        key: &HmacKey,
        delivery_id: &str,
        body: &Value,
        allowed_hosts: &[String],
        now: i64,
    ) -> Result<ProviderReceipt, ProviderError> {
        let bytes = serde_json::to_vec(body)
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        let mut headers = HeaderMap::new();
        headers.insert(
            HeaderName::from_static(SIGNATURE_HEADER),
            HeaderValue::from_str(&signature(key, now, &bytes)?)
                .map_err(|_| ProviderError::configuration("signature invalide"))?,
        );
        headers.insert(
            HeaderName::from_static(DELIVERY_HEADER),
            HeaderValue::from_str(delivery_id)
                .map_err(|_| ProviderError::configuration("identifiant de livraison invalide"))?,
        );
        let response = self
            .client
            .post_json(
                url.expose_secret(),
                HostRule::AnyPublic,
                allowed_hosts,
                headers,
                bytes,
            )
            .await?;
        if (200..300).contains(&response.status) {
            return Ok(ProviderReceipt {
                message_id: None,
                code: response.status,
            });
        }
        Err(classify_webhook_status(response.status))
    }
}

/// Signature d'un appel d'adresse web : `t=<secondes>,v1=<HMAC-SHA256 hexadécimal de
/// "<t>.<corps>">`.
pub fn signature(key: &HmacKey, timestamp: i64, body: &[u8]) -> Result<String, ProviderError> {
    let mut signed = Vec::with_capacity(body.len() + 24);
    signed.extend_from_slice(timestamp.to_string().as_bytes());
    signed.push(b'.');
    signed.extend_from_slice(body);
    let tag = sign_hmac_sha256_hex(key, &signed)
        .map_err(|_| ProviderError::configuration("signature impossible"))?;
    Ok(format!("t={timestamp},v1={tag}"))
}

/// Classe d'une réponse refusée par une adresse web (E4) : 4xx sauf 408 et 429 définitifs ;
/// toute autre réponse (3xx, 408, 429, 5xx) temporaire.
pub fn classify_webhook_status(status: u16) -> ProviderError {
    let detail = format!("HTTP {status}");
    match status {
        408 | 429 => ProviderError::unavailable(detail),
        400..=499 => ProviderError::rejected(detail),
        _ => ProviderError::unavailable(detail),
    }
}

/// Identifiant du message chez le service : Google Chat (`name`), Telegram
/// (`<salon>:<message_id>`, unique par intégration) ; aucun pour les webhooks sans réponse.
fn chat_message_id(
    service: ChatService,
    chat_id: Option<&str>,
    response: &OutboundResponse,
) -> Option<String> {
    let body: Value = serde_json::from_slice(response.body.as_deref()?).ok()?;
    let id = match service {
        ChatService::GoogleChat => body.get("name")?.as_str()?.to_string(),
        ChatService::Telegram => format!(
            "{}:{}",
            chat_id?,
            body.get("result")?.get("message_id")?.as_i64()?
        ),
        _ => return None,
    };
    super::normalize_message_id(&id)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bodies_follow_each_service() {
        assert_eq!(
            chat_body(ChatService::Slack, Some("Devis"), "Prêt", None),
            json!({ "text": "*Devis*\nPrêt" })
        );
        assert_eq!(
            chat_body(ChatService::Mattermost, None, "Prêt", None),
            json!({ "text": "Prêt" })
        );
        let discord = chat_body(ChatService::Discord, None, &"x".repeat(3000), None);
        assert_eq!(
            discord["content"].as_str().map(|t| t.chars().count()),
            Some(2000)
        );
        assert_eq!(discord["allowed_mentions"], json!({ "parse": [] }));
        assert_eq!(
            chat_body(ChatService::Telegram, Some("Devis"), "Prêt", Some("-1001")),
            json!({ "chat_id": "-1001", "text": "Devis\nPrêt" })
        );
        let teams = chat_body(ChatService::Teams, Some("Devis"), "Prêt", None);
        assert_eq!(
            teams["attachments"][0]["content"]["body"][1]["text"],
            "Prêt"
        );
    }

    #[test]
    fn webhook_statuses_and_signature() {
        assert_eq!(
            classify_webhook_status(404).class,
            crate::models::FailureClass::Permanent
        );
        for status in [302, 408, 429, 500, 503] {
            assert_eq!(
                classify_webhook_status(status).class,
                crate::models::FailureClass::Transient,
                "{status}"
            );
        }
        let key = HmacKey::import(SecretBytes::new(vec![7; 32]).expect("clé")).expect("clé");
        let header = signature(&key, 1_700_000_000, b"{}").expect("signature");
        assert!(header.starts_with("t=1700000000,v1="));
        assert_eq!(header.len(), "t=1700000000,v1=".len() + 64);
    }

    #[test]
    fn telegram_tokens_are_checked() {
        let value = |text: &str| SecretBytes::new(text.as_bytes().to_vec()).expect("valeur");
        assert!(telegram_token(&value(r#"{"bot_token":"123:essai_jeton-x"}"#)).is_ok());
        assert!(telegram_token(&value(r#"{"bot_token":"123/../x"}"#)).is_err());
        assert!(telegram_token(&value(r#"{"api_key":"x"}"#)).is_err());
    }
}
