//! Retours des fournisseurs (décision D4) : vérification et lecture d'un webhook reçu par
//! l'hôte, avec `lyxal_crypto` seulement.
//!
//! * **Mailgun** : `signature: { timestamp, token, signature }` dans le corps JSON ;
//!   HMAC-SHA256(clé de signature, `timestamp` + `token`) en hexadécimal.
//! * **Resend** (Svix) : en-têtes `svix-id`, `svix-timestamp`, `svix-signature`
//!   (`v1,<base64>`, plusieurs séparées par une espace) ; secret `whsec_<base64>` ;
//!   HMAC-SHA256 de `<id>.<horodatage>.<corps>`.
//! * **Postmark**, **Brevo** : identifiants d'authentification HTTP (Basic) réglés chez le
//!   fournisseur, comparés en temps constant (étiquettes HMAC-SHA256 sous une clé éphémère,
//!   `verify_hmac_sha256`).
//!
//! Horodatage signé (Mailgun, Resend) à moins de 5 minutes ; corps de 256 Kio au plus. Un retour
//! rejoué est dédoublonné en base par l'identifiant de l'événement chez le fournisseur.
//! Retenus : délivré, rejet définitif, rejet temporaire, plainte ; ouvertures et clics ignorés.
//!
//! Clé de signature du fournisseur, de longueur quelconque : `lyxal_crypto::ExternalHmacKey`,
//! utilisée telle quelle (extension de `lyxal_crypto` validée par le CTO), vérifiée en temps
//! constant par `verify_external_hmac_sha256`.
//!
//! Retours des SMS (décision E6) :
//! * **Twilio** : rappel d'état (`StatusCallback`, formulaire) signé par `X-Twilio-Signature` :
//!   Base64 du HMAC-SHA1, sous le jeton d'authentification du compte, de l'adresse complète
//!   appelée suivie des paramètres triés par nom (nom et valeur accolés) ; vérifié par
//!   `verify_external_hmac_sha1` (extension K8, vérification seulement) ; aucun horodatage signé
//!   (dédoublonnage par `MessageSid:MessageStatus`) ;
//! * **Vonage** : accusé de livraison signé (méthode « HMAC SHA-256 » du compte) : paramètres
//!   triés par nom, `&` et `=` des valeurs remplacés par `_`, chaîne `&nom=valeur…`, HMAC-SHA256
//!   hexadécimal sous le secret de signature (`ExternalHmacKey`), paramètre `sig` ; horodatage
//!   signé (`timestamp`) à moins de 5 minutes ;
//! * **Brevo** : authentification Basic, comme l'e-mail.
//!
//! Numéro invalide ou inexistant : rejet définitif (numéro supprimé) ; destinataire désinscrit
//! chez l'opérateur (STOP, Twilio 21610 ou 30004, Vonage 4) : plainte (numéro supprimé).

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{
    sign_hmac_sha256, verify_external_hmac_sha1, verify_external_hmac_sha256, verify_hmac_sha256,
};
use lyxal_crypto::{ExternalHmacKey, HmacKey, SecretBytes, SecretString};
use serde::Deserialize;
use serde_json::Value;
use std::collections::BTreeMap;
use std::fmt;

use crate::models::{NotificationDatetime, ProviderEventParams};
use crate::provider::{normalize_message_id, Provider, SmsProvider};

/// Taille maximale du corps d'un retour.
pub const MAX_WEBHOOK_BYTES: usize = 256 * 1024;
/// Écart maximal entre un horodatage signé et l'heure du serveur (secondes).
pub const TIMESTAMP_TOLERANCE_SECONDS: i64 = 300;

/// Ce que l'hôte transmet d'une requête de retour.
#[derive(Default)]
pub struct WebhookRequest<'a> {
    /// En-tête `Authorization` (Postmark, Brevo).
    pub authorization: Option<&'a str>,
    /// En-tête `svix-id` (Resend).
    pub svix_id: Option<&'a str>,
    /// En-tête `svix-timestamp` (Resend).
    pub svix_timestamp: Option<&'a str>,
    /// En-tête `svix-signature` (Resend).
    pub svix_signature: Option<&'a str>,
    /// En-tête `X-Twilio-Signature` (Twilio).
    pub twilio_signature: Option<&'a str>,
    /// Adresse complète appelée par le fournisseur (adresse publique de l'hôte, chemin et
    /// requête), signée par Twilio.
    pub url: Option<&'a str>,
    /// Corps brut.
    pub body: &'a [u8],
}

/// Type normalisé d'un retour.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProviderEventKind {
    /// Message délivré.
    Delivered,
    /// Rejet définitif : adresse supprimée.
    Bounced,
    /// Rejet temporaire.
    SoftBounced,
    /// Plainte : adresse supprimée.
    Complained,
}

impl ProviderEventKind {
    /// Valeur attendue par `fn::notification_provider_event_record`.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Delivered => "delivered",
            Self::Bounced => "bounced",
            Self::SoftBounced => "soft_bounced",
            Self::Complained => "complained",
        }
    }
}

/// Retour vérifié et normalisé (aucune adresse : le message est retrouvé par son identifiant).
#[derive(Debug, Clone, PartialEq)]
pub struct ProviderEvent {
    /// Identifiant de l'événement chez le fournisseur (dédoublonnage).
    pub event_id: String,
    /// Type.
    pub kind: ProviderEventKind,
    /// Identifiant du message chez le fournisseur.
    pub provider_message_id: Option<String>,
    /// Date de l'événement chez le fournisseur.
    pub occurred_at: Option<NotificationDatetime>,
}

impl ProviderEvent {
    /// Paramètres de `fn::notification_provider_event_record` pour l'intégration `integration`.
    pub fn record_params(&self, integration: String) -> ProviderEventParams {
        ProviderEventParams {
            integration,
            event_id: self.event_id.clone(),
            kind: self.kind.as_str().to_string(),
            provider_message_id: self.provider_message_id.clone(),
            occurred_at: self.occurred_at,
        }
    }
}

/// Refus d'un retour ; la réponse de l'hôte n'en dit rien.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WebhookError {
    /// Corps de plus de 256 Kio.
    TooLarge,
    /// Signature, identifiants ou horodatage refusés.
    Unauthorized,
    /// Corps illisible.
    Invalid,
    /// Secret des retours absent, illisible ou d'une forme inattendue, ou fournisseur sans
    /// retours (SMTP).
    Secret,
}

impl WebhookError {
    /// Code d'erreur.
    pub fn code(self) -> &'static str {
        match self {
            Self::Secret => "NOTIFICATION_INTEGRATION_SECRET_INVALID",
            _ => "NOTIFICATION_WEBHOOK_INVALID",
        }
    }
}

impl fmt::Display for WebhookError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.code())
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct MailgunSecret {
    signing_key: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct SvixSecret {
    signing_secret: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct BasicSecret {
    username: String,
    password: String,
}

/// Secret des retours Twilio : le jeton d'authentification du compte (le secret des
/// identifiants `{ account_sid, auth_token }` convient aussi).
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TwilioSecret {
    #[serde(default, rename = "account_sid")]
    _account_sid: Option<String>,
    auth_token: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct VonageSecret {
    signature_secret: String,
}

/// Clé de signature du fournisseur, telle quelle (`ExternalHmacKey`, 1 à 1024 octets).
fn hmac_key(raw: &[u8]) -> Result<ExternalHmacKey, WebhookError> {
    SecretBytes::new(raw.to_vec())
        .and_then(ExternalHmacKey::import)
        .map_err(|_| WebhookError::Secret)
}

/// Étiquette hexadécimale de 64 caractères (minuscules ou majuscules), sinon `None`.
fn hex_tag(encoded: &str) -> Option<[u8; 32]> {
    if encoded.len() != 64 {
        return None;
    }
    let mut tag = [0u8; 32];
    for (index, pair) in encoded.as_bytes().chunks(2).enumerate() {
        let high = char::from(pair[0]).to_digit(16)?;
        let low = char::from(pair[1]).to_digit(16)?;
        tag[index] = u8::try_from(high * 16 + low).ok()?;
    }
    Some(tag)
}

/// Égalité en temps constant : étiquettes HMAC-SHA256 sous une clé éphémère tirée par
/// `lyxal_crypto`, comparées par `verify_hmac_sha256`.
fn same(expected: &[u8], provided: &[u8]) -> bool {
    let Ok(key) = HmacKey::generate() else {
        return false;
    };
    let Ok(tag) = sign_hmac_sha256(&key, expected) else {
        return false;
    };
    verify_hmac_sha256(&key, provided, &tag).unwrap_or(false)
}

fn within_window(timestamp: &str, now: i64) -> bool {
    timestamp
        .trim()
        .parse::<i64>()
        .is_ok_and(|ts| (now - ts).abs() <= TIMESTAMP_TOLERANCE_SECONDS)
}

fn datetime_from_seconds(seconds: i64) -> Option<NotificationDatetime> {
    jiff::Timestamp::from_second(seconds)
        .ok()
        .and_then(|ts| ts.to_string().parse().ok())
}

fn datetime_from_text(text: &str) -> Option<NotificationDatetime> {
    text.parse::<jiff::Timestamp>()
        .ok()
        .and_then(|ts| ts.to_string().parse().ok())
}

fn text<'a>(value: &'a Value, path: &[&str]) -> Option<&'a str> {
    path.iter()
        .try_fold(value, |current, key| current.get(key))
        .and_then(Value::as_str)
}

/// Texte d'un identifiant donné en nombre ou en texte.
fn scalar(value: &Value) -> Option<String> {
    match value {
        Value::String(text) => Some(text.clone()),
        Value::Number(number) => Some(number.to_string()),
        _ => None,
    }
}

fn event_id(value: String) -> Option<String> {
    let trimmed = value.trim();
    (!trimmed.is_empty() && trimmed.len() <= 256 && !trimmed.chars().any(char::is_control))
        .then(|| trimmed.to_string())
}

/// Vérification et lecture des retours des fournisseurs.
pub struct ProviderWebhook;

impl ProviderWebhook {
    /// Vérifie un retour de `provider` avec la valeur de son secret des retours, puis rend ses
    /// événements retenus (vide : événement ignoré, comme une ouverture). `now` : heure du
    /// serveur en secondes Unix.
    pub fn verify(
        provider: Provider,
        secret: &SecretBytes,
        request: &WebhookRequest<'_>,
        now: i64,
    ) -> Result<Vec<ProviderEvent>, WebhookError> {
        if request.body.len() > MAX_WEBHOOK_BYTES {
            return Err(WebhookError::TooLarge);
        }
        match provider {
            Provider::Mailgun => mailgun(secret, request, now),
            Provider::Resend => resend(secret, request, now),
            Provider::Postmark | Provider::Brevo => {
                basic(secret, request)?;
                let body: Value =
                    serde_json::from_slice(request.body).map_err(|_| WebhookError::Invalid)?;
                Ok(if provider == Provider::Postmark {
                    postmark_event(&body).into_iter().collect()
                } else {
                    match &body {
                        Value::Array(items) => items.iter().filter_map(brevo_event).collect(),
                        single => brevo_event(single).into_iter().collect(),
                    }
                })
            }
            Provider::Smtp => Err(WebhookError::Secret),
        }
    }

    /// Vérifie un retour de livraison d'un SMS (décision E6) avec la valeur du secret des
    /// retours de l'intégration, puis rend ses événements retenus.
    pub fn verify_sms(
        provider: SmsProvider,
        secret: &SecretBytes,
        request: &WebhookRequest<'_>,
        now: i64,
    ) -> Result<Vec<ProviderEvent>, WebhookError> {
        if request.body.len() > MAX_WEBHOOK_BYTES {
            return Err(WebhookError::TooLarge);
        }
        match provider {
            SmsProvider::Twilio => twilio(secret, request),
            SmsProvider::Vonage => vonage(secret, request, now),
            SmsProvider::Brevo => {
                basic(secret, request)?;
                let body: Value =
                    serde_json::from_slice(request.body).map_err(|_| WebhookError::Invalid)?;
                Ok(match &body {
                    Value::Array(items) => items.iter().filter_map(brevo_sms_event).collect(),
                    single => brevo_sms_event(single).into_iter().collect(),
                })
            }
        }
    }
}

/// Paramètres d'un corps en formulaire.
fn form_params(body: &[u8]) -> Vec<(String, String)> {
    form_urlencoded::parse(body)
        .map(|(k, v)| (k.into_owned(), v.into_owned()))
        .collect()
}

fn twilio(
    secret: &SecretBytes,
    request: &WebhookRequest<'_>,
) -> Result<Vec<ProviderEvent>, WebhookError> {
    let secret: TwilioSecret =
        serde_json::from_slice(secret.expose_secret()).map_err(|_| WebhookError::Secret)?;
    let token = SecretString::new(secret.auth_token).map_err(|_| WebhookError::Secret)?;
    let key = hmac_key(token.expose_secret().as_bytes())?;
    let (Some(url), Some(signature)) = (request.url, request.twilio_signature) else {
        return Err(WebhookError::Unauthorized);
    };
    let tag = STANDARD
        .decode(signature.trim())
        .map_err(|_| WebhookError::Unauthorized)?;
    if tag.len() != 20 {
        return Err(WebhookError::Unauthorized);
    }
    let mut params = form_params(request.body);
    // Tri par nom (ordre des octets) ; valeurs d'un même nom dans leur ordre d'arrivée
    params.sort_by(|a, b| a.0.cmp(&b.0));
    let mut signed = url.as_bytes().to_vec();
    for (name, value) in &params {
        signed.extend_from_slice(name.as_bytes());
        signed.extend_from_slice(value.as_bytes());
    }
    if !verify_external_hmac_sha1(&key, &signed, &tag).unwrap_or(false) {
        return Err(WebhookError::Unauthorized);
    }
    let field = |name: &str| {
        params
            .iter()
            .find(|(key, _)| key == name)
            .map(|(_, value)| value.as_str())
    };
    let sid = field("MessageSid")
        .or_else(|| field("SmsSid"))
        .ok_or(WebhookError::Invalid)?;
    let status = field("MessageStatus")
        .or_else(|| field("SmsStatus"))
        .ok_or(WebhookError::Invalid)?;
    let kind = match (status, field("ErrorCode")) {
        ("delivered", _) => ProviderEventKind::Delivered,
        ("undelivered" | "failed", Some("21610" | "30004")) => ProviderEventKind::Complained,
        ("undelivered" | "failed", Some("21211" | "21614" | "30005" | "30006")) => {
            ProviderEventKind::Bounced
        }
        ("undelivered" | "failed", _) => ProviderEventKind::SoftBounced,
        _ => return Ok(Vec::new()),
    };
    Ok(vec![ProviderEvent {
        event_id: event_id(format!("{sid}:{status}")).ok_or(WebhookError::Invalid)?,
        kind,
        provider_message_id: normalize_message_id(sid),
        occurred_at: None,
    }])
}

fn vonage(
    secret: &SecretBytes,
    request: &WebhookRequest<'_>,
    now: i64,
) -> Result<Vec<ProviderEvent>, WebhookError> {
    let secret: VonageSecret =
        serde_json::from_slice(secret.expose_secret()).map_err(|_| WebhookError::Secret)?;
    let signing = SecretString::new(secret.signature_secret).map_err(|_| WebhookError::Secret)?;
    let key = hmac_key(signing.expose_secret().as_bytes())?;
    // Accusé en JSON ou en formulaire : paramètres texte
    let params: BTreeMap<String, String> = match serde_json::from_slice::<Value>(request.body) {
        Ok(Value::Object(map)) => map
            .into_iter()
            .filter_map(|(k, v)| scalar(&v).map(|v| (k, v)))
            .collect(),
        _ => form_params(request.body).into_iter().collect(),
    };
    let signature = params.get("sig").ok_or(WebhookError::Unauthorized)?;
    let timestamp = params.get("timestamp").ok_or(WebhookError::Unauthorized)?;
    let mut signed = String::new();
    for (name, value) in params.iter().filter(|(name, _)| name.as_str() != "sig") {
        signed.push('&');
        signed.push_str(name);
        signed.push('=');
        signed.push_str(&value.replace(['&', '='], "_"));
    }
    let tag = hex_tag(signature).ok_or(WebhookError::Unauthorized)?;
    if !verify_external_hmac_sha256(&key, signed.as_bytes(), &tag).unwrap_or(false)
        || !within_window(timestamp, now)
    {
        return Err(WebhookError::Unauthorized);
    }
    let message_id = params
        .get("messageId")
        .or_else(|| params.get("message-id"))
        .ok_or(WebhookError::Invalid)?;
    let status = params.get("status").map(String::as_str).unwrap_or_default();
    let kind = match (status, params.get("err-code").map(String::as_str)) {
        ("delivered", _) => ProviderEventKind::Delivered,
        ("failed" | "rejected" | "expired", Some("4")) => ProviderEventKind::Complained,
        ("failed" | "rejected" | "expired", Some("3" | "9")) => ProviderEventKind::Bounced,
        ("failed" | "rejected" | "expired", _) => ProviderEventKind::SoftBounced,
        _ => return Ok(Vec::new()),
    };
    let at = params
        .get("message-timestamp")
        .map(String::as_str)
        .unwrap_or_default();
    Ok(vec![ProviderEvent {
        event_id: event_id(format!("{message_id}:{status}:{at}")).ok_or(WebhookError::Invalid)?,
        kind,
        provider_message_id: normalize_message_id(message_id),
        occurred_at: datetime_from_seconds(timestamp.parse().unwrap_or_default()),
    }])
}

/// Retour d'un SMS Brevo (`msg_status` ou `event`).
fn brevo_sms_event(body: &Value) -> Option<ProviderEvent> {
    let status = text(body, &["msg_status"])
        .or_else(|| text(body, &["event"]))?
        .to_ascii_lowercase()
        .replace(['_', ' '], "");
    let kind = match status.as_str() {
        "delivered" => ProviderEventKind::Delivered,
        "hardbounce" | "rejected" | "invalidnumber" => ProviderEventKind::Bounced,
        "softbounce" => ProviderEventKind::SoftBounced,
        "unsubscribe" | "unsubscribed" | "stop" => ProviderEventKind::Complained,
        _ => return None,
    };
    let message_id = body.get("messageId").and_then(scalar)?;
    let at = body.get("ts_event").and_then(Value::as_i64);
    Some(ProviderEvent {
        event_id: event_id(format!(
            "sms:{}:{message_id}:{}",
            kind.as_str(),
            at.map(|ts| ts.to_string()).unwrap_or_default()
        ))?,
        kind,
        provider_message_id: normalize_message_id(&message_id),
        occurred_at: at.and_then(datetime_from_seconds),
    })
}

fn mailgun(
    secret: &SecretBytes,
    request: &WebhookRequest<'_>,
    now: i64,
) -> Result<Vec<ProviderEvent>, WebhookError> {
    let secret: MailgunSecret =
        serde_json::from_slice(secret.expose_secret()).map_err(|_| WebhookError::Secret)?;
    let key = hmac_key(
        SecretString::new(secret.signing_key)
            .map_err(|_| WebhookError::Secret)?
            .expose_secret()
            .as_bytes(),
    )?;
    let body: Value = serde_json::from_slice(request.body).map_err(|_| WebhookError::Invalid)?;
    let timestamp = text(&body, &["signature", "timestamp"]).ok_or(WebhookError::Unauthorized)?;
    let token = text(&body, &["signature", "token"]).ok_or(WebhookError::Unauthorized)?;
    let signature = text(&body, &["signature", "signature"]).ok_or(WebhookError::Unauthorized)?;
    let signed = format!("{timestamp}{token}");
    let tag = hex_tag(signature).ok_or(WebhookError::Unauthorized)?;
    if !verify_external_hmac_sha256(&key, signed.as_bytes(), &tag).unwrap_or(false) {
        return Err(WebhookError::Unauthorized);
    }
    if !within_window(timestamp, now) {
        return Err(WebhookError::Unauthorized);
    }
    let data = body.get("event-data").ok_or(WebhookError::Invalid)?;
    let kind = match (text(data, &["event"]), text(data, &["severity"])) {
        (Some("delivered"), _) => ProviderEventKind::Delivered,
        (Some("failed"), Some("permanent")) => ProviderEventKind::Bounced,
        (Some("failed"), _) => ProviderEventKind::SoftBounced,
        (Some("complained"), _) => ProviderEventKind::Complained,
        _ => return Ok(Vec::new()),
    };
    let event_id = text(data, &["id"])
        .map(str::to_string)
        .and_then(event_id)
        .ok_or(WebhookError::Invalid)?;
    Ok(vec![ProviderEvent {
        event_id,
        kind,
        provider_message_id: text(data, &["message", "headers", "message-id"])
            .and_then(normalize_message_id),
        occurred_at: data
            .get("timestamp")
            .and_then(Value::as_f64)
            .and_then(|seconds| datetime_from_seconds(seconds as i64)),
    }])
}

fn resend(
    secret: &SecretBytes,
    request: &WebhookRequest<'_>,
    now: i64,
) -> Result<Vec<ProviderEvent>, WebhookError> {
    let secret: SvixSecret =
        serde_json::from_slice(secret.expose_secret()).map_err(|_| WebhookError::Secret)?;
    let secret = SecretString::new(secret.signing_secret).map_err(|_| WebhookError::Secret)?;
    let encoded = secret
        .expose_secret()
        .strip_prefix("whsec_")
        .ok_or(WebhookError::Secret)?;
    let raw = SecretBytes::new(STANDARD.decode(encoded).map_err(|_| WebhookError::Secret)?)
        .map_err(|_| WebhookError::Secret)?;
    let key = hmac_key(raw.expose_secret())?;
    let (Some(id), Some(timestamp), Some(signatures)) = (
        request.svix_id,
        request.svix_timestamp,
        request.svix_signature,
    ) else {
        return Err(WebhookError::Unauthorized);
    };
    let mut signed = Vec::with_capacity(id.len() + timestamp.len() + request.body.len() + 2);
    signed.extend_from_slice(id.as_bytes());
    signed.push(b'.');
    signed.extend_from_slice(timestamp.as_bytes());
    signed.push(b'.');
    signed.extend_from_slice(request.body);
    // Toutes les signatures sont essayées (pas d'arrêt à la première)
    let valid = signatures
        .split(' ')
        .filter_map(|entry| entry.strip_prefix("v1,"))
        .filter_map(|tag| STANDARD.decode(tag).ok())
        .filter(|tag| tag.len() == 32)
        .fold(false, |found, tag| {
            verify_external_hmac_sha256(&key, &signed, &tag).unwrap_or(false) | found
        });
    if !valid || !within_window(timestamp, now) {
        return Err(WebhookError::Unauthorized);
    }
    let body: Value = serde_json::from_slice(request.body).map_err(|_| WebhookError::Invalid)?;
    let data = body.get("data").unwrap_or(&Value::Null);
    let kind = match text(&body, &["type"]) {
        Some("email.delivered") => ProviderEventKind::Delivered,
        Some("email.bounced") => match text(data, &["bounce", "type"]) {
            Some("Transient") | Some("transient") => ProviderEventKind::SoftBounced,
            _ => ProviderEventKind::Bounced,
        },
        Some("email.delivery_delayed") => ProviderEventKind::SoftBounced,
        Some("email.complained") => ProviderEventKind::Complained,
        _ => return Ok(Vec::new()),
    };
    Ok(vec![ProviderEvent {
        event_id: event_id(id.to_string()).ok_or(WebhookError::Invalid)?,
        kind,
        provider_message_id: text(data, &["email_id"]).and_then(normalize_message_id),
        occurred_at: text(&body, &["created_at"]).and_then(datetime_from_text),
    }])
}

/// Identifiants Basic de la requête comparés en temps constant à ceux du secret.
fn basic(secret: &SecretBytes, request: &WebhookRequest<'_>) -> Result<(), WebhookError> {
    let expected: BasicSecret =
        serde_json::from_slice(secret.expose_secret()).map_err(|_| WebhookError::Secret)?;
    let username = SecretString::new(expected.username).map_err(|_| WebhookError::Secret)?;
    let password = SecretString::new(expected.password).map_err(|_| WebhookError::Secret)?;
    let encoded = request
        .authorization
        .and_then(|value| value.strip_prefix("Basic "))
        .ok_or(WebhookError::Unauthorized)?;
    let decoded = SecretBytes::new(
        STANDARD
            .decode(encoded.trim())
            .map_err(|_| WebhookError::Unauthorized)?,
    )
    .map_err(|_| WebhookError::Unauthorized)?;
    let provided = decoded.expose_secret();
    let split = provided
        .iter()
        .position(|byte| *byte == b':')
        .ok_or(WebhookError::Unauthorized)?;
    let (user, pass) = (&provided[..split], &provided[split + 1..]);
    // Les deux comparaisons sont toujours faites
    let user_ok = same(username.expose_secret().as_bytes(), user);
    let pass_ok = same(password.expose_secret().as_bytes(), pass);
    if user_ok & pass_ok {
        Ok(())
    } else {
        Err(WebhookError::Unauthorized)
    }
}

fn postmark_event(body: &Value) -> Option<ProviderEvent> {
    let record = text(body, &["RecordType"])?;
    let message_id = text(body, &["MessageID"]).and_then(normalize_message_id);
    let (kind, id, at) = match record {
        "Delivery" => (
            ProviderEventKind::Delivered,
            format!(
                "Delivery:{}:{}",
                message_id.as_deref()?,
                text(body, &["Recipient"]).unwrap_or_default()
            ),
            text(body, &["DeliveredAt"]),
        ),
        "Bounce" => {
            let kind = match text(body, &["Type"])? {
                "HardBounce" | "BadEmailAddress" => ProviderEventKind::Bounced,
                "SoftBounce" | "Transient" | "DnsError" => ProviderEventKind::SoftBounced,
                "SpamComplaint" => ProviderEventKind::Complained,
                _ => return None,
            };
            (
                kind,
                format!("Bounce:{}", scalar(body.get("ID")?)?),
                text(body, &["BouncedAt"]),
            )
        }
        "SpamComplaint" => (
            ProviderEventKind::Complained,
            format!("SpamComplaint:{}", scalar(body.get("ID")?)?),
            text(body, &["BouncedAt"]),
        ),
        _ => return None,
    };
    Some(ProviderEvent {
        event_id: event_id(id)?,
        kind,
        provider_message_id: message_id,
        occurred_at: at.and_then(datetime_from_text),
    })
}

fn brevo_event(body: &Value) -> Option<ProviderEvent> {
    let kind = match text(body, &["event"])? {
        "delivered" => ProviderEventKind::Delivered,
        "hard_bounce" | "invalid_email" => ProviderEventKind::Bounced,
        "soft_bounce" => ProviderEventKind::SoftBounced,
        "spam" | "complaint" => ProviderEventKind::Complained,
        _ => return None,
    };
    let message_id = text(body, &["message-id"]).and_then(normalize_message_id);
    let at = body
        .get("ts_event")
        .or_else(|| body.get("ts"))
        .and_then(Value::as_i64);
    Some(ProviderEvent {
        event_id: event_id(format!(
            "{}:{}:{}",
            kind.as_str(),
            message_id.as_deref()?,
            at.map(|ts| ts.to_string()).unwrap_or_default()
        ))?,
        kind,
        provider_message_id: message_id,
        occurred_at: at.and_then(datetime_from_seconds),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn secret(value: &str) -> SecretBytes {
        SecretBytes::new(value.as_bytes().to_vec()).expect("secret")
    }

    #[test]
    fn provider_keys_of_any_length_are_used_as_given() {
        // RFC 4231, cas 2 : clé "Jefe" (4 octets)
        let key = hmac_key(b"Jefe").expect("clé");
        let tag = lyxal_crypto::sign_external_hmac_sha256(&key, b"what do ya want for nothing?")
            .expect("étiquette");
        assert_eq!(
            hex_tag("5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"),
            Some(tag)
        );
        // Clé de 36 octets (de 33 à 64 octets, comme certaines clés Mailgun) : acceptée
        let key = hmac_key(b"essai_signature_retours_36_octets_xy").expect("clé");
        let tag =
            lyxal_crypto::sign_external_hmac_sha256(&key, b"1700000000token").expect("étiquette");
        assert!(verify_external_hmac_sha256(&key, b"1700000000token", &tag).expect("vérification"));
        assert_eq!(hmac_key(&[]).err(), Some(WebhookError::Secret));
        // Étiquette hexadécimale : 64 caractères, majuscules admises
        assert_eq!(hex_tag(&"AB".repeat(32)), Some([0xab; 32]));
        assert_eq!(hex_tag(&"ab".repeat(31)), None);
        assert_eq!(hex_tag(&"zz".repeat(32)), None);
    }

    #[test]
    fn svix_reference_vector_is_verified() {
        // Exemple de référence publié par Svix (secret de 24 octets, complété selon RFC 2104)
        let value = secret(r#"{"signing_secret":"whsec_MfKQ9r8GKYqrTwjUPD8ILPZIo2LaLaSw"}"#);
        let body = br#"{"test": 2432232314}"#;
        let request = |signature: &'static str| WebhookRequest {
            svix_id: Some("msg_p5jXN8AQM9LWM0D4loKWxJek"),
            svix_timestamp: Some("1614265330"),
            svix_signature: Some(signature),
            body,
            ..Default::default()
        };
        assert_eq!(
            ProviderWebhook::verify(
                Provider::Resend,
                &value,
                &request("v1,g0hM9SsE+OTPJTGt/tmIKtSyZlE3uFJELVlNIOLJ1OE="),
                1_614_265_330
            ),
            Ok(Vec::new()),
            "signature valide, type d'événement non retenu"
        );
        assert_eq!(
            ProviderWebhook::verify(
                Provider::Resend,
                &value,
                &request("v1,g0hM9SsE+OTPJTGt/tmIKtSyZlE3uFJELVlNIOLJ1OE="),
                1_614_265_330 + TIMESTAMP_TOLERANCE_SECONDS + 1
            ),
            Err(WebhookError::Unauthorized)
        );
        assert_eq!(
            ProviderWebhook::verify(
                Provider::Resend,
                &value,
                &request("v1,h0hM9SsE+OTPJTGt/tmIKtSyZlE3uFJELVlNIOLJ1OE="),
                1_614_265_330
            ),
            Err(WebhookError::Unauthorized)
        );
    }

    #[test]
    fn constant_time_equality() {
        assert!(same(b"motdepasse", b"motdepasse"));
        assert!(!same(b"motdepasse", b"motdepassf"));
        assert!(!same(b"motdepasse", b"motdepass"));
        assert!(!same(b"", b"x"));
    }

    #[test]
    fn basic_credentials_are_checked() {
        let value = secret(r#"{"username":"lyxal","password":"pass:avec:deux-points"}"#);
        let header =
            |user: &str, pass: &str| format!("Basic {}", STANDARD.encode(format!("{user}:{pass}")));
        let ok = header("lyxal", "pass:avec:deux-points");
        assert!(basic(
            &value,
            &WebhookRequest {
                authorization: Some(&ok),
                ..Default::default()
            }
        )
        .is_ok());
        for bad in [
            header("lyxal", "faux"),
            header("autre", "pass:avec:deux-points"),
            "Bearer x".to_string(),
            "Basic !!".to_string(),
        ] {
            assert_eq!(
                basic(
                    &value,
                    &WebhookRequest {
                        authorization: Some(&bad),
                        ..Default::default()
                    }
                ),
                Err(WebhookError::Unauthorized),
                "{bad}"
            );
        }
        assert_eq!(
            basic(&value, &WebhookRequest::default()),
            Err(WebhookError::Unauthorized)
        );
        assert_eq!(
            basic(
                &secret(r#"{"api_key":"x"}"#),
                &WebhookRequest {
                    authorization: Some(&ok),
                    ..Default::default()
                }
            ),
            Err(WebhookError::Secret)
        );
    }

    #[test]
    fn oversized_bodies_and_smtp_are_refused() {
        let body = vec![b' '; MAX_WEBHOOK_BYTES + 1];
        let request = WebhookRequest {
            body: &body,
            ..Default::default()
        };
        assert_eq!(
            ProviderWebhook::verify(Provider::Brevo, &secret("{}"), &request, 0),
            Err(WebhookError::TooLarge)
        );
        assert_eq!(
            ProviderWebhook::verify(Provider::Smtp, &secret("{}"), &WebhookRequest::default(), 0),
            Err(WebhookError::Secret)
        );
    }

    /// Vecteurs calculés indépendamment (module `hmac` de Python, HMAC-SHA1 et HMAC-SHA256).
    const TWILIO_URL: &str = "https://lyxal.exemple.fr/api/v1/notification/webhooks/twilio_essai";
    const TWILIO_BODY: &[u8] = b"MessageSid=SMessai0001&MessageStatus=undelivered&ErrorCode=30005&AccountSid=essai_compte&To=%2B33612345678&From=%2B33700000000";
    const TWILIO_SIGNATURE: &str = "I8mBN8PSNl9BeI5t7qfuh2EB7xg=";

    #[test]
    fn twilio_status_callbacks_are_verified() {
        let value = secret(r#"{"auth_token":"essai_jeton_twilio"}"#);
        let request =
            |url: &'static str, signature: &'static str, body: &'static [u8]| WebhookRequest {
                twilio_signature: Some(signature),
                url: Some(url),
                body,
                ..Default::default()
            };
        let events = ProviderWebhook::verify_sms(
            SmsProvider::Twilio,
            &value,
            &request(TWILIO_URL, TWILIO_SIGNATURE, TWILIO_BODY),
            0,
        )
        .expect("signature valide");
        assert_eq!(
            events,
            vec![ProviderEvent {
                event_id: "SMessai0001:undelivered".to_string(),
                kind: ProviderEventKind::Bounced,
                provider_message_id: Some("SMessai0001".to_string()),
                occurred_at: None,
            }]
        );
        // Les identifiants du compte conviennent aussi comme secret des retours
        let credentials =
            secret(r#"{"account_sid":"essai_compte","auth_token":"essai_jeton_twilio"}"#);
        assert!(ProviderWebhook::verify_sms(
            SmsProvider::Twilio,
            &credentials,
            &request(TWILIO_URL, TWILIO_SIGNATURE, TWILIO_BODY),
            0
        )
        .is_ok());
        // Fausse signature, autre adresse, paramètre modifié, signature absente : refusés
        for refused in [
            request(TWILIO_URL, "J8mBN8PSNl9BeI5t7qfuh2EB7xg=", TWILIO_BODY),
            request("https://autre.exemple.fr/api/v1/notification/webhooks/twilio_essai", TWILIO_SIGNATURE, TWILIO_BODY),
            request(TWILIO_URL, TWILIO_SIGNATURE, b"MessageSid=SMessai0001&MessageStatus=delivered&ErrorCode=30005&AccountSid=essai_compte&To=%2B33612345678&From=%2B33700000000"),
            request(TWILIO_URL, "pas du base64", TWILIO_BODY),
        ] {
            assert_eq!(
                ProviderWebhook::verify_sms(SmsProvider::Twilio, &value, &refused, 0),
                Err(WebhookError::Unauthorized)
            );
        }
        assert_eq!(
            ProviderWebhook::verify_sms(
                SmsProvider::Twilio,
                &value,
                &WebhookRequest {
                    url: Some(TWILIO_URL),
                    body: TWILIO_BODY,
                    ..Default::default()
                },
                0
            ),
            Err(WebhookError::Unauthorized)
        );
        assert_eq!(
            ProviderWebhook::verify_sms(
                SmsProvider::Twilio,
                &secret(r#"{"api_key":"x"}"#),
                &request(TWILIO_URL, TWILIO_SIGNATURE, TWILIO_BODY),
                0
            ),
            Err(WebhookError::Secret)
        );
    }

    const VONAGE_BODY: &[u8] = b"messageId=0A00essai&msisdn=33612345678&to=Alpha&status=failed&err-code=4&message-timestamp=2026-11-17+10%3A00%3A00&timestamp=1700000000&nonce=essai-nonce";
    const VONAGE_SIG: &str = "0665fa748dc4a481aab538ca09632911389e91cb10c5d88ae953689d0ec511d4";

    #[test]
    fn vonage_receipts_are_verified() {
        let value = secret(r#"{"signature_secret":"essai_secret_vonage"}"#);
        let signed = |sig: &str| {
            let mut body = VONAGE_BODY.to_vec();
            body.extend_from_slice(format!("&sig={sig}").as_bytes());
            body
        };
        let body = signed(VONAGE_SIG);
        let request = WebhookRequest {
            body: &body,
            ..Default::default()
        };
        let events =
            ProviderWebhook::verify_sms(SmsProvider::Vonage, &value, &request, 1_700_000_000)
                .expect("signature valide");
        // Code 4 (appel bloqué par l'abonné) : plainte
        assert_eq!(events.len(), 1);
        assert_eq!(events[0].kind, ProviderEventKind::Complained);
        assert_eq!(events[0].provider_message_id.as_deref(), Some("0A00essai"));
        // Majuscules admises
        let upper = signed(&VONAGE_SIG.to_uppercase());
        assert!(ProviderWebhook::verify_sms(
            SmsProvider::Vonage,
            &value,
            &WebhookRequest {
                body: &upper,
                ..Default::default()
            },
            1_700_000_000
        )
        .is_ok());
        // Horodatage trop ancien, signature fausse ou absente : refusés
        assert_eq!(
            ProviderWebhook::verify_sms(
                SmsProvider::Vonage,
                &value,
                &request,
                1_700_000_000 + TIMESTAMP_TOLERANCE_SECONDS + 1
            ),
            Err(WebhookError::Unauthorized)
        );
        let forged = signed(&"0".repeat(64));
        assert_eq!(
            ProviderWebhook::verify_sms(
                SmsProvider::Vonage,
                &value,
                &WebhookRequest {
                    body: &forged,
                    ..Default::default()
                },
                1_700_000_000
            ),
            Err(WebhookError::Unauthorized)
        );
        assert_eq!(
            ProviderWebhook::verify_sms(
                SmsProvider::Vonage,
                &value,
                &WebhookRequest {
                    body: VONAGE_BODY,
                    ..Default::default()
                },
                1_700_000_000
            ),
            Err(WebhookError::Unauthorized)
        );
        // Même accusé en JSON
        let json = serde_json::json!({
            "messageId": "0A00essai", "msisdn": "33612345678", "to": "Alpha", "status": "failed", "err-code": "4",
            "message-timestamp": "2026-11-17 10:00:00", "timestamp": "1700000000", "nonce": "essai-nonce", "sig": VONAGE_SIG
        })
        .to_string();
        assert!(ProviderWebhook::verify_sms(
            SmsProvider::Vonage,
            &value,
            &WebhookRequest {
                body: json.as_bytes(),
                ..Default::default()
            },
            1_700_000_000
        )
        .is_ok());
    }

    #[test]
    fn brevo_sms_events_are_normalized() {
        let event = brevo_sms_event(&serde_json::json!({ "msg_status": "hardBounce", "messageId": 1_511_882_900_176_220_i64, "ts_event": 1_700_000_000 }))
            .expect("événement");
        assert_eq!(event.kind, ProviderEventKind::Bounced);
        assert_eq!(
            event.provider_message_id.as_deref(),
            Some("1511882900176220")
        );
        let stop =
            brevo_sms_event(&serde_json::json!({ "event": "unsubscribe", "messageId": "42" }))
                .expect("événement");
        assert_eq!(stop.kind, ProviderEventKind::Complained);
        assert!(
            brevo_sms_event(&serde_json::json!({ "msg_status": "sent", "messageId": "42" }))
                .is_none()
        );
    }

    #[test]
    fn postmark_and_brevo_events_are_normalized() {
        let delivery = serde_json::json!({ "RecordType": "Delivery", "MessageID": "pm-1", "Recipient": "a@b.test", "DeliveredAt": "2026-11-16T10:00:00Z" });
        let event = postmark_event(&delivery).expect("événement");
        assert_eq!(
            (
                event.kind,
                event.event_id.as_str(),
                event.provider_message_id.as_deref()
            ),
            (
                ProviderEventKind::Delivered,
                "Delivery:pm-1:a@b.test",
                Some("pm-1")
            )
        );
        let bounce = serde_json::json!({ "RecordType": "Bounce", "Type": "HardBounce", "ID": 42, "MessageID": "pm-1" });
        assert_eq!(
            postmark_event(&bounce).map(|e| (e.kind, e.event_id)),
            Some((ProviderEventKind::Bounced, "Bounce:42".to_string()))
        );
        assert!(
            postmark_event(&serde_json::json!({ "RecordType": "Open", "MessageID": "pm-1" }))
                .is_none()
        );
        let brevo = serde_json::json!({ "event": "hard_bounce", "message-id": "<br-1@smtp-relay.mailin.fr>", "ts_event": 1_700_000_000 });
        let event = brevo_event(&brevo).expect("événement");
        assert_eq!(
            (event.kind, event.provider_message_id.as_deref()),
            (
                ProviderEventKind::Bounced,
                Some("br-1@smtp-relay.mailin.fr")
            )
        );
        assert!(event.occurred_at.is_some());
        assert!(
            brevo_event(&serde_json::json!({ "event": "opened", "message-id": "x" })).is_none()
        );
    }
}
