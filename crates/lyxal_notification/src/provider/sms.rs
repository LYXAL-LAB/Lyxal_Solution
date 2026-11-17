//! Fournisseurs de SMS (décision K5) : API transactionnelle SMS de Brevo, API Messages de Twilio
//! et API SMS de Vonage, par `reqwest` (K10 : rustls, délai de 10 s, aucune redirection, réponse
//! lue sur 64 Kio au plus). Adresses des API fixées dans le code ; numéro du destinataire au format
//! E.164 (`+` retiré pour Brevo et Vonage).
//!
//! Classement : 2xx accepté ; 429 et 5xx temporaires ; numéro invalide ou inexistant refusé par
//! le fournisseur : destinataire refusé (numéro supprimé, rejet définitif) ; destinataire
//! désinscrit chez l'opérateur (Twilio 21610, STOP ; Vonage 7, numéro bloqué) : désinscrit
//! (numéro supprimé, plainte) ; autres refus définitifs.

use lyxal_crypto::{SecretBytes, SecretString};
use reqwest::header::{HeaderValue, ACCEPT};
use reqwest::redirect::Policy;
use reqwest::{Client, RequestBuilder, Url};
use serde::Deserialize;
use serde_json::{json, Value};
use std::fmt;
use std::net::IpAddr;

use super::{classify_status, read_bounded, ProviderError, ProviderReceipt, REQUEST_TIMEOUT};
use crate::error::{NotificationError, NotificationResult};
use crate::models::{FailureClass, IntegrationSettings};

const BREVO_SMS_URL: &str = "https://api.brevo.com/v3/transactionalSMS/sms";
const TWILIO_URL: &str = "https://api.twilio.com/2010-04-01/Accounts/";
const VONAGE_URL: &str = "https://rest.nexmo.com/sms/json";

/// Fournisseur de SMS.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SmsProvider {
    /// Brevo (SMS transactionnels).
    Brevo,
    /// Twilio (API Messages).
    Twilio,
    /// Vonage (API SMS).
    Vonage,
}

impl SmsProvider {
    /// Fournisseur d'après sa valeur en base.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "brevo" => Some(Self::Brevo),
            "twilio" => Some(Self::Twilio),
            "vonage" => Some(Self::Vonage),
            _ => None,
        }
    }
}

/// Identifiants d'une intégration SMS (valeur JSON du coffre-fort) : Brevo `{ api_key }` ;
/// Twilio `{ account_sid, auth_token }` ; Vonage `{ api_key, api_secret }`.
pub enum SmsCredentials {
    /// Brevo : clé d'API.
    ApiKey(SecretString),
    /// Twilio : identifiant du compte et jeton d'authentification.
    Twilio {
        /// Identifiant du compte (`AC…`).
        account_sid: SecretString,
        /// Jeton d'authentification.
        auth_token: SecretString,
    },
    /// Vonage : clé et secret d'API.
    Vonage {
        /// Clé d'API.
        api_key: SecretString,
        /// Secret d'API.
        api_secret: SecretString,
    },
}

impl fmt::Debug for SmsCredentials {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::ApiKey(_) => "SmsCredentials::ApiKey([REDACTED])",
            Self::Twilio { .. } => "SmsCredentials::Twilio([REDACTED])",
            Self::Vonage { .. } => "SmsCredentials::Vonage([REDACTED])",
        })
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct ApiKeyValue {
    api_key: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TwilioValue {
    account_sid: String,
    auth_token: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct VonageValue {
    api_key: String,
    api_secret: String,
}

fn secret(text: String) -> Result<SecretString, ProviderError> {
    if text.is_empty() {
        return Err(ProviderError::secret("identifiant vide"));
    }
    SecretString::new(text).map_err(|_| ProviderError::secret("identifiant trop long"))
}

impl SmsCredentials {
    /// Identifiants du fournisseur lus dans la valeur du coffre-fort ; une autre forme est
    /// refusée sans rien en dire.
    pub fn parse(provider: SmsProvider, value: &SecretBytes) -> Result<Self, ProviderError> {
        let shape = || ProviderError::secret("forme des identifiants inattendue");
        let raw = value.expose_secret();
        match provider {
            SmsProvider::Brevo => {
                let key: ApiKeyValue = serde_json::from_slice(raw).map_err(|_| shape())?;
                Ok(Self::ApiKey(secret(key.api_key)?))
            }
            SmsProvider::Twilio => {
                let value: TwilioValue = serde_json::from_slice(raw).map_err(|_| shape())?;
                Ok(Self::Twilio {
                    account_sid: secret(value.account_sid)?,
                    auth_token: secret(value.auth_token)?,
                })
            }
            SmsProvider::Vonage => {
                let value: VonageValue = serde_json::from_slice(raw).map_err(|_| shape())?;
                Ok(Self::Vonage {
                    api_key: secret(value.api_key)?,
                    api_secret: secret(value.api_secret)?,
                })
            }
        }
    }
}

/// SMS prêt à partir.
pub struct SmsMessage {
    /// Numéro du destinataire (E.164).
    pub to: String,
    /// Texte rendu.
    pub text: String,
    /// Texte en Unicode (UCS-2) : hors de l'alphabet GSM.
    pub unicode: bool,
    /// Adresse des retours de livraison de ce message (Twilio `StatusCallback`, Vonage
    /// `callback`, Brevo `webUrl`), quand l'intégration a un secret des retours.
    pub status_callback: Option<String>,
}

impl fmt::Debug for SmsMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("SmsMessage")
            .field("to", &"[REDACTED]")
            .field("unicode", &self.unicode)
            .field("status_callback", &self.status_callback.is_some())
            .finish_non_exhaustive()
    }
}

/// Adresses des API de SMS.
#[derive(Debug, Clone)]
pub struct SmsEndpoints {
    brevo: Url,
    twilio: Url,
    vonage: Url,
}

fn parse(url: &str) -> NotificationResult<Url> {
    Url::parse(url).map_err(|_| NotificationError::Configuration("adresse d'API invalide".into()))
}

impl SmsEndpoints {
    /// Adresses de production (constantes du code).
    pub fn production() -> NotificationResult<Self> {
        Ok(Self {
            brevo: parse(BREVO_SMS_URL)?,
            twilio: parse(TWILIO_URL)?,
            vonage: parse(VONAGE_URL)?,
        })
    }

    /// Réservé aux tests : faux fournisseurs sous `base` (`http://127.0.0.1:<port>`) :
    /// `/brevo-sms/v3/transactionalSMS/sms`, `/twilio/2010-04-01/Accounts/<compte>/Messages.json`,
    /// `/vonage/sms/json`. Toute adresse hors de la boucle locale est refusée.
    pub fn local(base: &str) -> NotificationResult<Self> {
        let parsed = parse(base)?;
        let loopback = match parsed.host_str() {
            Some("localhost") => true,
            Some(host) => host
                .trim_start_matches('[')
                .trim_end_matches(']')
                .parse::<IpAddr>()
                .is_ok_and(|ip| ip.is_loopback()),
            None => false,
        };
        if parsed.scheme() != "http" || !loopback {
            return Err(NotificationError::Configuration(
                "faux fournisseurs : http://127.0.0.1 seulement".into(),
            ));
        }
        let at = |path: &str| parse(&format!("{}{path}", parsed.as_str().trim_end_matches('/')));
        Ok(Self {
            brevo: at("/brevo-sms/v3/transactionalSMS/sms")?,
            twilio: at("/twilio/2010-04-01/Accounts/")?,
            vonage: at("/vonage/sms/json")?,
        })
    }
}

/// Client des API de SMS.
pub struct SmsApi {
    client: Client,
    endpoints: SmsEndpoints,
}

impl SmsApi {
    /// Client de production : HTTPS seulement, adresses fixes.
    pub fn new() -> NotificationResult<Self> {
        Self::build(SmsEndpoints::production()?, true)
    }

    /// Réservé aux tests : faux fournisseurs de la boucle locale (voir [`SmsEndpoints::local`]).
    pub fn for_local_tests(base: &str) -> NotificationResult<Self> {
        Self::build(SmsEndpoints::local(base)?, false)
    }

    fn build(endpoints: SmsEndpoints, https_only: bool) -> NotificationResult<Self> {
        let mut builder = Client::builder()
            .use_rustls_tls()
            .https_only(https_only)
            .redirect(Policy::none())
            .timeout(REQUEST_TIMEOUT)
            .connect_timeout(REQUEST_TIMEOUT)
            .user_agent("lyxal-notification");
        if !https_only {
            builder = builder.no_proxy();
        }
        let client = builder.build().map_err(|_| {
            NotificationError::Configuration(
                "client HTTP des fournisseurs de SMS impossible".into(),
            )
        })?;
        Ok(Self { client, endpoints })
    }

    /// Envoie un SMS par le fournisseur `provider`, avec l'expéditeur de l'intégration.
    pub async fn send(
        &self,
        provider: SmsProvider,
        settings: &IntegrationSettings,
        message: &SmsMessage,
        credentials: &SmsCredentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let sender = settings
            .sender
            .as_deref()
            .ok_or_else(|| super::missing("sender"))?;
        let digits = message
            .to
            .strip_prefix('+')
            .filter(|digits| !digits.is_empty() && digits.bytes().all(|b| b.is_ascii_digit()))
            .ok_or_else(|| ProviderError {
                class: FailureClass::RecipientRejected,
                code: "NOTIFICATION_PROVIDER_REJECTED".to_string(),
                detail: "numéro hors du format E.164".to_string(),
            })?;
        match (provider, credentials) {
            (SmsProvider::Brevo, SmsCredentials::ApiKey(key)) => {
                let mut body = json!({
                    "sender": sender,
                    "recipient": digits,
                    "content": message.text,
                    "type": "transactional",
                    "unicodeEnabled": message.unicode,
                });
                if let Some(callback) = &message.status_callback {
                    body["webUrl"] = json!(callback);
                }
                let request = self
                    .client
                    .post(self.endpoints.brevo.clone())
                    .header("api-key", sensitive(key.expose_secret())?)
                    .header(ACCEPT, HeaderValue::from_static("application/json"))
                    .json_bytes(&body)?;
                let (status, body) = exchange(request).await?;
                if !(200..300).contains(&status) {
                    return Err(classify_status(status));
                }
                Ok(ProviderReceipt {
                    message_id: body.as_ref().and_then(|b| scalar(b.get("messageId")?)),
                    code: status,
                })
            }
            (
                SmsProvider::Twilio,
                SmsCredentials::Twilio {
                    account_sid,
                    auth_token,
                },
            ) => {
                let mut url = self.endpoints.twilio.clone();
                url.path_segments_mut()
                    .map_err(|_| ProviderError::configuration("adresse Twilio invalide"))?
                    .pop_if_empty()
                    .push(account_sid.expose_secret())
                    .push("Messages.json");
                let mut form = vec![
                    ("To", message.to.clone()),
                    ("From", sender.to_string()),
                    ("Body", message.text.clone()),
                ];
                if let Some(callback) = &message.status_callback {
                    form.push(("StatusCallback", callback.clone()));
                }
                let request = self
                    .client
                    .post(url)
                    .basic_auth(
                        account_sid.expose_secret(),
                        Some(auth_token.expose_secret()),
                    )
                    .header(ACCEPT, HeaderValue::from_static("application/json"))
                    .form(&form);
                let (status, body) = exchange(request).await?;
                if !(200..300).contains(&status) {
                    return Err(twilio_refusal(status, body.as_ref()));
                }
                Ok(ProviderReceipt {
                    message_id: body.as_ref().and_then(|b| scalar(b.get("sid")?)),
                    code: status,
                })
            }
            (
                SmsProvider::Vonage,
                SmsCredentials::Vonage {
                    api_key,
                    api_secret,
                },
            ) => {
                let mut form = vec![
                    ("api_key", api_key.expose_secret().to_string()),
                    ("api_secret", api_secret.expose_secret().to_string()),
                    ("from", sender.to_string()),
                    ("to", digits.to_string()),
                    ("text", message.text.clone()),
                ];
                if message.unicode {
                    form.push(("type", "unicode".to_string()));
                }
                if let Some(callback) = &message.status_callback {
                    form.push(("callback", callback.clone()));
                }
                let request = self
                    .client
                    .post(self.endpoints.vonage.clone())
                    .header(ACCEPT, HeaderValue::from_static("application/json"))
                    .form(&form);
                let (status, body) = exchange(request).await?;
                if !(200..300).contains(&status) {
                    return Err(classify_status(status));
                }
                vonage_receipt(status, body.as_ref())
            }
            _ => Err(ProviderError::secret("identifiants d'un autre fournisseur")),
        }
    }
}

/// Corps JSON d'une requête.
trait JsonBytes: Sized {
    fn json_bytes(self, body: &Value) -> Result<Self, ProviderError>;
}

impl JsonBytes for RequestBuilder {
    fn json_bytes(self, body: &Value) -> Result<Self, ProviderError> {
        let bytes = serde_json::to_vec(body)
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        Ok(self
            .header(
                reqwest::header::CONTENT_TYPE,
                HeaderValue::from_static("application/json"),
            )
            .body(bytes))
    }
}

/// Valeur d'en-tête marquée sensible.
fn sensitive(value: &str) -> Result<HeaderValue, ProviderError> {
    let mut header = HeaderValue::from_str(value)
        .map_err(|_| ProviderError::secret("clé d'API inutilisable dans un en-tête"))?;
    header.set_sensitive(true);
    Ok(header)
}

/// Texte d'un identifiant donné en nombre ou en texte.
fn scalar(value: &Value) -> Option<String> {
    let text = match value {
        Value::String(text) => text.clone(),
        Value::Number(number) => number.to_string(),
        _ => return None,
    };
    super::normalize_message_id(&text)
}

/// Envoie la requête : code et corps JSON lu (64 Kio au plus). L'erreur de transport n'est
/// jamais affichée (elle peut contenir l'adresse).
async fn exchange(request: RequestBuilder) -> Result<(u16, Option<Value>), ProviderError> {
    let response = request.send().await.map_err(|error| {
        if error.is_builder() {
            ProviderError::configuration("requête refusée avant l'envoi")
        } else if error.is_timeout() {
            ProviderError::unavailable("délai dépassé")
        } else {
            ProviderError::unavailable("fournisseur injoignable")
        }
    })?;
    let status = response.status().as_u16();
    let body = read_bounded(response)
        .await
        .and_then(|bytes| serde_json::from_slice::<Value>(&bytes).ok());
    Ok((status, body))
}

/// Refus de Twilio : numéro invalide (21211, 21614, 21217, 21401, 21407, 21408) : destinataire
/// refusé ; désinscrit (21610) : désinscrit ; sinon selon le code HTTP.
pub(crate) fn twilio_refusal(status: u16, body: Option<&Value>) -> ProviderError {
    let code = body.and_then(|b| b.get("code")).and_then(Value::as_i64);
    let detail = match code {
        Some(code) => format!("HTTP {status}, Twilio {code}"),
        None => format!("HTTP {status}"),
    };
    match code {
        Some(21610) => ProviderError {
            class: FailureClass::RecipientOptedOut,
            code: "NOTIFICATION_PROVIDER_REJECTED".to_string(),
            detail,
        },
        Some(21211 | 21614 | 21217 | 21401 | 21407 | 21408) => ProviderError {
            class: FailureClass::RecipientRejected,
            code: "NOTIFICATION_PROVIDER_REJECTED".to_string(),
            detail,
        },
        _ => ProviderError {
            detail,
            ..classify_status(status)
        },
    }
}

/// Réponse de Vonage (HTTP 200) : état de la première partie. `0` accepté ; `1` (débit) et `5`
/// (erreur interne) temporaires ; `7` (numéro bloqué) désinscrit ; autres refus définitifs.
pub(crate) fn vonage_receipt(
    status: u16,
    body: Option<&Value>,
) -> Result<ProviderReceipt, ProviderError> {
    let first = body
        .and_then(|b| b.get("messages"))
        .and_then(Value::as_array)
        .and_then(|messages| messages.first());
    let state = first.and_then(|m| m.get("status")).and_then(scalar);
    let detail = |state: &str| format!("Vonage {state}");
    match state.as_deref() {
        Some("0") => Ok(ProviderReceipt {
            message_id: first.and_then(|m| scalar(m.get("message-id")?)),
            code: status,
        }),
        Some(state @ ("1" | "5")) => Err(ProviderError::unavailable(detail(state))),
        Some(state @ "7") => Err(ProviderError {
            class: FailureClass::RecipientOptedOut,
            code: "NOTIFICATION_PROVIDER_REJECTED".to_string(),
            detail: detail(state),
        }),
        Some(state) => Err(ProviderError::rejected(detail(state))),
        None => Err(ProviderError::unavailable("réponse de Vonage illisible")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn bytes(value: &str) -> SecretBytes {
        SecretBytes::new(value.as_bytes().to_vec()).expect("valeur")
    }

    #[test]
    fn credentials_are_read_by_provider_and_never_shown() {
        let twilio = SmsCredentials::parse(
            SmsProvider::Twilio,
            &bytes(r#"{"account_sid":"essai_compte","auth_token":"essai_jeton_secret"}"#),
        )
        .expect("identifiants");
        assert!(!format!("{twilio:?}").contains("essai_jeton"));
        assert!(SmsCredentials::parse(SmsProvider::Vonage, &bytes(r#"{"api_key":"k"}"#)).is_err());
        assert!(matches!(
            SmsCredentials::parse(SmsProvider::Brevo, &bytes(r#"{"api_key":"essai_cle"}"#)),
            Ok(SmsCredentials::ApiKey(_))
        ));
    }

    #[test]
    fn twilio_and_vonage_refusals_are_classified() {
        let invalid = twilio_refusal(400, Some(&json!({ "code": 21211, "message": "invalid" })));
        assert_eq!(invalid.class, FailureClass::RecipientRejected);
        let stop = twilio_refusal(400, Some(&json!({ "code": 21610 })));
        assert_eq!(stop.class, FailureClass::RecipientOptedOut);
        assert_eq!(twilio_refusal(429, None).class, FailureClass::Transient);
        assert_eq!(
            twilio_refusal(401, Some(&json!({ "code": 20003 }))).class,
            FailureClass::Permanent
        );
        let ok = vonage_receipt(
            200,
            Some(&json!({ "messages": [{ "status": "0", "message-id": "0A00" }] })),
        )
        .expect("accepté");
        assert_eq!(ok.message_id.as_deref(), Some("0A00"));
        let throttled = vonage_receipt(200, Some(&json!({ "messages": [{ "status": "1" }] })));
        assert_eq!(throttled.map_err(|e| e.class), Err(FailureClass::Transient));
        let barred = vonage_receipt(200, Some(&json!({ "messages": [{ "status": "7" }] })));
        assert_eq!(
            barred.map_err(|e| e.class),
            Err(FailureClass::RecipientOptedOut)
        );
        let refused = vonage_receipt(200, Some(&json!({ "messages": [{ "status": "4" }] })));
        assert_eq!(refused.map_err(|e| e.class), Err(FailureClass::Permanent));
    }

    #[test]
    fn production_endpoints_are_fixed_https_and_tests_stay_local() {
        let production = SmsEndpoints::production().expect("adresses");
        for url in [&production.brevo, &production.twilio, &production.vonage] {
            assert_eq!(url.scheme(), "https");
        }
        assert_eq!(production.vonage.host_str(), Some("rest.nexmo.com"));
        assert!(SmsEndpoints::local("http://127.0.0.1:9").is_ok());
        assert!(SmsEndpoints::local("http://10.0.0.1:9").is_err());
        assert!(SmsEndpoints::local("https://127.0.0.1:9").is_err());
    }
}
