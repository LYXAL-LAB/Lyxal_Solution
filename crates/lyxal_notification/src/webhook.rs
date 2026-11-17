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
//! Clé HMAC d'une longueur quelconque : HMAC (RFC 2104) complète une clé de 64 octets au plus par
//! des zéros, et remplace une clé plus longue par son SHA-256. Une clé de 32 octets au plus est
//! donc complétée par des zéros jusqu'aux 32 octets de `HmacKey` (même HMAC), une clé de plus de
//! 64 octets remplacée par `lyxal_crypto::sha256` ; une clé de 33 à 64 octets n'est pas
//! représentable par l'API figée de `lyxal_crypto` et est refusée (`NOTIFICATION_INTEGRATION_SECRET_INVALID`).

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{sha256, sign_hmac_sha256, verify_hmac_sha256, verify_hmac_sha256_hex};
use lyxal_crypto::{HmacKey, SecretBytes, SecretString};
use serde::Deserialize;
use serde_json::Value;
use std::fmt;

use crate::models::{NotificationDatetime, ProviderEventParams};
use crate::provider::{normalize_message_id, Provider};

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

/// Clé HMAC-SHA256 d'une clé brute de longueur quelconque, équivalente selon RFC 2104 (voir
/// l'en-tête du module).
fn hmac_key(raw: &[u8]) -> Result<HmacKey, WebhookError> {
    let material = match raw.len() {
        0 => return Err(WebhookError::Secret),
        1..=32 => {
            let mut padded = vec![0u8; 32];
            padded[..raw.len()].copy_from_slice(raw);
            padded
        }
        33..=64 => return Err(WebhookError::Secret),
        _ => sha256(raw).to_vec(),
    };
    SecretBytes::new(material)
        .and_then(HmacKey::import)
        .map_err(|_| WebhookError::Secret)
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
    if !verify_hmac_sha256_hex(&key, signed.as_bytes(), signature).unwrap_or(false) {
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
            verify_hmac_sha256(&key, &signed, &tag).unwrap_or(false) | found
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
    fn short_and_long_hmac_keys_match_rfc_2104() {
        // RFC 4231, cas 2 : clé "Jefe" (4 octets)
        let key = hmac_key(b"Jefe").expect("clé");
        let tag = sign_hmac_sha256(&key, b"what do ya want for nothing?").expect("étiquette");
        let hex: String = tag.iter().map(|b| format!("{b:02x}")).collect();
        assert_eq!(
            hex,
            "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"
        );
        // RFC 4231, cas 6 : clé de 131 octets 0xaa (plus longue qu'un bloc)
        let key = hmac_key(&[0xaa; 131]).expect("clé");
        let tag = sign_hmac_sha256(
            &key,
            b"Test Using Larger Than Block-Size Key - Hash Key First",
        )
        .expect("étiquette");
        let hex: String = tag.iter().map(|b| format!("{b:02x}")).collect();
        assert_eq!(
            hex,
            "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54"
        );
        assert_eq!(hmac_key(&[1; 40]).err(), Some(WebhookError::Secret));
        assert_eq!(hmac_key(&[]).err(), Some(WebhookError::Secret));
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
