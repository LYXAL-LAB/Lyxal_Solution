//! Notifications push (lot 6, décisions G2 à G6) : **Web Push** (navigateurs, RFC 8030, 8291,
//! 8292), **Firebase Cloud Messaging** (API HTTP v1) et **Apple Push Notification service**
//! (HTTP/2). Toute la cryptographie passe par `lyxal_crypto` (décision K8) : jetons ES256 (VAPID,
//! APNs) et RS256 (compte de service Google), chiffrement `aes128gcm` de Web Push.
//!
//! * **Web Push** : jeton VAPID ES256 (`aud` : origine de l'adresse du service push, `exp` à
//!   12 h, `sub` : contact de l'intégration) dans `Authorization: vapid t=<jeton>, k=<clé
//!   publique>` ; corps chiffré pour les clés du navigateur, en-têtes `Content-Encoding:
//!   aes128gcm`, `TTL`, `Urgency`. L'adresse donnée par le navigateur passe par le client
//!   contrôlé du lot 4 ([`OutboundClient`]) : HTTPS, services push connus seulement, adresses
//!   résolues vérifiées, aucune redirection. 404 et 410 : appareil retiré.
//! * **FCM** : jeton RS256 du compte de service (portée `firebase.messaging`) échangé à
//!   `oauth2.googleapis.com/token` contre un jeton d'accès gardé en mémoire jusqu'à son échéance
//!   (une minute de marge), puis `POST fcm.googleapis.com/v1/projects/{projet}/messages:send`.
//!   `UNREGISTERED`, `NOT_FOUND`, ou `INVALID_ARGUMENT` sur le jeton : appareil retiré ; 401 :
//!   jeton d'accès oublié et un nouvel essai aussitôt.
//! * **APNs** : jeton ES256 du fournisseur (`kid`, `iss` : équipe, `iat`) gardé en mémoire et
//!   renouvelé toutes les 50 minutes ; HTTP/2 vers `api.push.apple.com` ou
//!   `api.sandbox.push.apple.com`, en-têtes `apns-topic`, `apns-push-type: alert`,
//!   `apns-priority`, `apns-expiration`. 410 `Unregistered` ou 400 `BadDeviceToken` : appareil
//!   retiré ; 403 `ExpiredProviderToken` : jeton renouvelé et un nouvel essai.
//!
//! Contenu (décision G4) : `{ title, body, link, icon, data }`, 4 Kio au plus une fois chiffré
//! ([`MAX_PUSH_PAYLOAD_BYTES`] avant chiffrement), texte tronqué proprement (`…`) au-delà ;
//! impossible même texte vide : `NOTIFICATION_PUSH_TOO_LARGE`. Adresses de FCM et d'APNs fixées
//! dans le code ; [`PushEndpoints::local`] et [`PushApi::for_local_tests`] servent les faux
//! services des tests. L'heure vient d'une horloge injectée ([`PushClock`]).

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{
    webpush_encrypt, EcdsaP256SigningKey, RsaSigningKey, SecretBytes, SecretString,
    WEBPUSH_OVERHEAD_BYTES,
};
use reqwest::header::{HeaderMap, HeaderName, HeaderValue, ACCEPT, AUTHORIZATION, CONTENT_TYPE};
use reqwest::redirect::Policy;
use reqwest::{Client, RequestBuilder, Url};
use serde::Deserialize;
use serde_json::{json, Map, Value};
use std::collections::HashMap;
use std::fmt;
use std::net::IpAddr;
use std::sync::{Arc, Mutex};

use super::{classify_status, read_bounded, ProviderError, ProviderReceipt, REQUEST_TIMEOUT};
use crate::error::{NotificationError, NotificationResult};
use crate::models::{ClaimedIntegration, FailureClass};
use crate::outbound::{HostRule, OutboundClient};

/// Adresse d'échange du jeton du compte de service Google.
pub const FCM_TOKEN_URL: &str = "https://oauth2.googleapis.com/token";
/// Base de l'API HTTP v1 de FCM (`{base}{projet}/messages:send`).
pub const FCM_SEND_URL: &str = "https://fcm.googleapis.com/v1/projects/";
/// Portée OAuth de l'envoi FCM.
pub const FCM_SCOPE: &str = "https://www.googleapis.com/auth/firebase.messaging";
/// APNs de production (`{base}{jeton de l'appareil}`).
pub const APNS_PRODUCTION_URL: &str = "https://api.push.apple.com/3/device/";
/// APNs du bac à sable.
pub const APNS_SANDBOX_URL: &str = "https://api.sandbox.push.apple.com/3/device/";
/// Taille maximale du contenu JSON d'une notification avant chiffrement : 4 096 octets une fois
/// chiffré pour Web Push (limite commune des services push), aussi appliquée à FCM et APNs.
pub const MAX_PUSH_PAYLOAD_BYTES: usize = 4096 - WEBPUSH_OVERHEAD_BYTES;
/// Durée de conservation d'une notification par le service push (TTL, expiration APNs).
pub const PUSH_TTL_SECONDS: i64 = 86_400;
/// Durée de vie d'un jeton VAPID (24 h au plus, RFC 8292).
pub const VAPID_LIFETIME_SECONDS: i64 = 12 * 3600;
/// Durée de vie demandée pour le jeton du compte de service Google.
pub const FCM_ASSERTION_SECONDS: i64 = 3600;
/// Renouvellement du jeton du fournisseur APNs (Apple : entre 20 et 60 minutes).
pub const APNS_TOKEN_RENEWAL_SECONDS: i64 = 50 * 60;

/// Services push connus de Web Push (mêmes listes que `fn::notification_endpoint_official_hosts`).
pub const WEBPUSH_HOSTS: HostRule = HostRule::Official {
    exact: &[
        "fcm.googleapis.com",
        "updates.push.services.mozilla.com",
        "web.push.apple.com",
    ],
    suffixes: &[".push.services.mozilla.com", ".notify.windows.com"],
};

/// Horloge des jetons : secondes Unix (injectée par les tests).
pub type PushClock = Arc<dyn Fn() -> i64 + Send + Sync>;

/// Horloge du système.
pub fn system_clock() -> PushClock {
    Arc::new(|| {
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|elapsed| i64::try_from(elapsed.as_secs()).unwrap_or(i64::MAX))
            .unwrap_or_default()
    })
}

/// Service push d'une intégration ou d'un appareil.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PushService {
    /// Web Push (navigateurs).
    WebPush,
    /// Firebase Cloud Messaging (Android).
    Fcm,
    /// Apple Push Notification service.
    Apns,
}

impl PushService {
    /// Service d'après sa valeur en base.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "webpush" => Some(Self::WebPush),
            "fcm" => Some(Self::Fcm),
            "apns" => Some(Self::Apns),
            _ => None,
        }
    }
}

/// Motif du retrait d'un appareil déclaré invalide par son service (décision G5).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeviceRemoval {
    /// Désinscrit ou expiré (Web Push 404 / 410, FCM `UNREGISTERED` / `NOT_FOUND`, APNs 410).
    Expired,
    /// Jeton refusé (FCM `INVALID_ARGUMENT` sur le jeton, APNs `BadDeviceToken`).
    Invalid,
}

impl DeviceRemoval {
    /// Valeur attendue par `fn::notification_device_remove`.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Expired => "expired",
            Self::Invalid => "invalid",
        }
    }
}

/// Échec d'un envoi push : erreur classée et, pour un appareil invalide, le motif de son retrait.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PushFailure {
    /// Erreur classée (temporaire : nouvel essai ; définitive : sans nouvel essai).
    pub error: ProviderError,
    /// Appareil à retirer.
    pub removal: Option<DeviceRemoval>,
}

impl From<ProviderError> for PushFailure {
    fn from(error: ProviderError) -> Self {
        Self {
            error,
            removal: None,
        }
    }
}

impl PushFailure {
    fn device(removal: DeviceRemoval, detail: &str) -> Self {
        Self {
            error: ProviderError {
                class: FailureClass::Permanent,
                code: "NOTIFICATION_DEVICE_INVALID".to_string(),
                detail: detail.to_string(),
            },
            removal: Some(removal),
        }
    }
}

/// Contenu trop grand même texte vide (décision G4).
fn too_large() -> ProviderError {
    ProviderError {
        class: FailureClass::Permanent,
        code: "NOTIFICATION_PUSH_TOO_LARGE".to_string(),
        detail: "titre, lien, icône et données au-delà de 4 Kio".to_string(),
    }
}

/// Notification prête à partir : titre, texte, lien, icône, données (décision G4).
#[derive(Clone, PartialEq)]
pub struct PushMessage {
    /// Titre.
    pub title: String,
    /// Texte.
    pub body: String,
    /// Lien ouvert au clic (chemin de l'application ou adresse HTTPS, contrôlé).
    pub link: Option<String>,
    /// Icône.
    pub icon: Option<String>,
    /// Données (textes).
    pub data: Map<String, Value>,
    /// Parcours critique : priorité haute (`Urgency: high`, FCM `HIGH`, APNs 10).
    pub urgent: bool,
}

impl fmt::Debug for PushMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("PushMessage")
            .field("urgent", &self.urgent)
            .finish_non_exhaustive()
    }
}

impl PushMessage {
    /// Contenu commun `{ title, body, link, icon, data }` (corps chiffré de Web Push).
    pub fn content(&self) -> Value {
        let mut content = Map::new();
        content.insert("title".into(), json!(self.title));
        content.insert("body".into(), json!(self.body));
        if let Some(link) = &self.link {
            content.insert("link".into(), json!(link));
        }
        if let Some(icon) = &self.icon {
            content.insert("icon".into(), json!(icon));
        }
        if !self.data.is_empty() {
            content.insert("data".into(), Value::Object(self.data.clone()));
        }
        Value::Object(content)
    }

    fn content_len(&self) -> usize {
        serde_json::to_vec(&self.content()).map_or(usize::MAX, |bytes| bytes.len())
    }

    /// Message tenant en [`MAX_PUSH_PAYLOAD_BYTES`] : texte tronqué au caractère près et terminé
    /// par `…` s'il le faut ; titre, lien, icône et données trop grands à eux seuls :
    /// `NOTIFICATION_PUSH_TOO_LARGE`.
    pub fn fitted(mut self) -> Result<Self, ProviderError> {
        if self.content_len() <= MAX_PUSH_PAYLOAD_BYTES {
            return Ok(self);
        }
        let chars: Vec<char> = self.body.chars().collect();
        let with = |kept: usize| {
            let mut text: String = chars[..kept].iter().collect();
            text = text.trim_end().to_string();
            text.push('…');
            text
        };
        // Plus long préfixe qui tient (recherche dichotomique sur le nombre de caractères)
        let (mut low, mut high) = (0usize, chars.len());
        self.body = with(0);
        if self.content_len() > MAX_PUSH_PAYLOAD_BYTES {
            return Err(too_large());
        }
        while low < high {
            let middle = (low + high).div_ceil(2);
            self.body = with(middle);
            if self.content_len() <= MAX_PUSH_PAYLOAD_BYTES {
                low = middle;
            } else {
                high = middle - 1;
            }
        }
        self.body = with(low);
        Ok(self)
    }
}

/// Destinataire d'un envoi : valeurs de l'appareil ouvertes en mémoire le temps de l'envoi.
pub enum PushTarget<'a> {
    /// Web Push : adresse du service push et clés du navigateur.
    WebPush {
        /// Adresse donnée par le navigateur (secret : elle seule permet d'envoyer).
        endpoint: &'a SecretString,
        /// Clé publique du navigateur (`p256dh`).
        p256dh: [u8; 65],
        /// Secret d'authentification du navigateur (`auth`).
        auth: zeroize::Zeroizing<[u8; 16]>,
    },
    /// FCM : jeton d'enregistrement.
    Fcm {
        /// Jeton.
        token: &'a SecretString,
    },
    /// APNs : jeton de l'appareil (hexadécimal).
    Apns {
        /// Jeton.
        token: &'a SecretString,
    },
}

impl fmt::Debug for PushTarget<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::WebPush { .. } => "PushTarget::WebPush([REDACTED])",
            Self::Fcm { .. } => "PushTarget::Fcm([REDACTED])",
            Self::Apns { .. } => "PushTarget::Apns([REDACTED])",
        })
    }
}

/// Identifiants d'une intégration push, lus dans `lyxal_secrets` (valeur JSON) : Web Push
/// `{ private_key }` (clé VAPID PKCS#8 en PEM) ; FCM : fichier du compte de service Google
/// (`client_email`, `private_key` en PEM, `private_key_id` facultatif ; les autres champs du
/// fichier sont ignorés) ; APNs `{ key_id, private_key }` (contenu du fichier `.p8`).
pub enum PushCredentials {
    /// Web Push : clé privée VAPID.
    WebPush(EcdsaP256SigningKey),
    /// FCM : compte de service.
    Fcm {
        /// Adresse du compte de service (`iss`).
        client_email: String,
        /// Identifiant de la clé (`kid`), facultatif.
        key_id: Option<String>,
        /// Clé privée RSA.
        key: RsaSigningKey,
    },
    /// APNs : clé du fournisseur.
    Apns {
        /// Identifiant de la clé (`kid`).
        key_id: String,
        /// Clé privée ES256 (`.p8`).
        key: EcdsaP256SigningKey,
    },
}

impl fmt::Debug for PushCredentials {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::WebPush(_) => "PushCredentials::WebPush([REDACTED])",
            Self::Fcm { .. } => "PushCredentials::Fcm([REDACTED])",
            Self::Apns { .. } => "PushCredentials::Apns([REDACTED])",
        })
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct VapidValue {
    private_key: String,
}

/// Fichier du compte de service Google : seuls ces champs sont lus.
#[derive(Deserialize)]
struct ServiceAccountValue {
    client_email: String,
    private_key: String,
    #[serde(default)]
    private_key_id: Option<String>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct ApnsValue {
    key_id: String,
    private_key: String,
}

fn key_bytes(text: String) -> Result<SecretBytes, ProviderError> {
    SecretBytes::new(text.into_bytes()).map_err(|_| ProviderError::secret("clé trop longue"))
}

/// Identifiant non secret (adresse du compte, identifiant de clé) : texte court sans caractère de
/// contrôle ni guillemet.
fn identifier(text: &str) -> Result<String, ProviderError> {
    if text.is_empty()
        || text.len() > 256
        || text
            .chars()
            .any(|c| c.is_control() || c == '"' || c == '\\')
    {
        return Err(ProviderError::secret("identifiant inattendu"));
    }
    Ok(text.to_string())
}

impl PushCredentials {
    /// Identifiants du service lus dans la valeur du coffre-fort ; une autre forme est refusée
    /// sans rien en dire (`NOTIFICATION_INTEGRATION_SECRET_INVALID`).
    pub fn parse(service: PushService, value: &SecretBytes) -> Result<Self, ProviderError> {
        let shape = || ProviderError::secret("forme des identifiants inattendue");
        let raw = value.expose_secret();
        let unreadable = |_| ProviderError::secret("clé privée illisible");
        match service {
            PushService::WebPush => {
                let value: VapidValue = serde_json::from_slice(raw).map_err(|_| shape())?;
                let key = EcdsaP256SigningKey::import_pkcs8(key_bytes(value.private_key)?)
                    .map_err(unreadable)?;
                Ok(Self::WebPush(key))
            }
            PushService::Fcm => {
                let value: ServiceAccountValue =
                    serde_json::from_slice(raw).map_err(|_| shape())?;
                let client_email = identifier(&value.client_email)?;
                let key_id = value
                    .private_key_id
                    .as_deref()
                    .map(identifier)
                    .transpose()?;
                let key = RsaSigningKey::import_pkcs8(key_bytes(value.private_key)?)
                    .map_err(unreadable)?;
                Ok(Self::Fcm {
                    client_email,
                    key_id,
                    key,
                })
            }
            PushService::Apns => {
                let value: ApnsValue = serde_json::from_slice(raw).map_err(|_| shape())?;
                let key_id = identifier(&value.key_id)?;
                let key = EcdsaP256SigningKey::import_pkcs8(key_bytes(value.private_key)?)
                    .map_err(unreadable)?;
                Ok(Self::Apns { key_id, key })
            }
        }
    }
}

/// Jeton JWS compact (`en-tête.revendications.signature`, Base64url sans remplissage).
fn jws(
    header: &Value,
    claims: &Value,
    sign: impl FnOnce(&[u8]) -> Result<Vec<u8>, ProviderError>,
) -> Result<SecretString, ProviderError> {
    let encode = |value: &Value| {
        serde_json::to_vec(value)
            .map(|bytes| URL_SAFE_NO_PAD.encode(bytes))
            .map_err(|_| ProviderError::configuration("jeton impossible à encoder"))
    };
    let signing_input = format!("{}.{}", encode(header)?, encode(claims)?);
    let signature = sign(signing_input.as_bytes())?;
    SecretString::new(format!(
        "{signing_input}.{}",
        URL_SAFE_NO_PAD.encode(signature)
    ))
    .map_err(|_| ProviderError::configuration("jeton trop long"))
}

fn es256(key: &EcdsaP256SigningKey) -> impl FnOnce(&[u8]) -> Result<Vec<u8>, ProviderError> + '_ {
    move |data| {
        key.sign_es256(data)
            .map(|signature| signature.to_vec())
            .map_err(|_| ProviderError::secret("signature ES256 impossible"))
    }
}

/// Jeton VAPID (RFC 8292) pour l'origine `audience` du service push.
pub fn vapid_token(
    key: &EcdsaP256SigningKey,
    audience: &str,
    subject: &str,
    now: i64,
) -> Result<SecretString, ProviderError> {
    jws(
        &json!({ "typ": "JWT", "alg": "ES256" }),
        &json!({ "aud": audience, "exp": now + VAPID_LIFETIME_SECONDS, "sub": subject }),
        es256(key),
    )
}

/// Jeton du fournisseur APNs (`kid`, `iss` : équipe, `iat`).
pub fn apns_token(
    key: &EcdsaP256SigningKey,
    key_id: &str,
    team_id: &str,
    now: i64,
) -> Result<SecretString, ProviderError> {
    jws(
        &json!({ "alg": "ES256", "kid": key_id }),
        &json!({ "iss": team_id, "iat": now }),
        es256(key),
    )
}

/// Jeton du compte de service Google (RFC 7523), échangé contre un jeton d'accès FCM.
pub fn fcm_assertion(
    key: &RsaSigningKey,
    key_id: Option<&str>,
    client_email: &str,
    audience: &str,
    now: i64,
) -> Result<SecretString, ProviderError> {
    let mut header = json!({ "alg": "RS256", "typ": "JWT" });
    if let Some(kid) = key_id {
        header["kid"] = json!(kid);
    }
    jws(
        &header,
        &json!({
            "iss": client_email,
            "scope": FCM_SCOPE,
            "aud": audience,
            "iat": now,
            "exp": now + FCM_ASSERTION_SECONDS,
        }),
        |data| {
            key.sign_rs256(data)
                .map_err(|_| ProviderError::secret("signature RS256 impossible"))
        },
    )
}

/// Origine (`schéma://hôte[:port]`) d'une adresse : audience du jeton VAPID.
fn origin(url: &Url) -> String {
    url.origin().ascii_serialization()
}

/// Adresses des services push.
#[derive(Debug, Clone)]
pub struct PushEndpoints {
    fcm_token: Url,
    fcm_send: Url,
    apns_production: Url,
    apns_sandbox: Url,
}

fn parse(url: &str) -> NotificationResult<Url> {
    Url::parse(url).map_err(|_| NotificationError::Configuration("adresse d'API invalide".into()))
}

impl PushEndpoints {
    /// Adresses de production (constantes du code).
    pub fn production() -> NotificationResult<Self> {
        Ok(Self {
            fcm_token: parse(FCM_TOKEN_URL)?,
            fcm_send: parse(FCM_SEND_URL)?,
            apns_production: parse(APNS_PRODUCTION_URL)?,
            apns_sandbox: parse(APNS_SANDBOX_URL)?,
        })
    }

    /// Réservé aux tests : faux services sous `base` (FCM, `http://127.0.0.1:<port>`) et
    /// `apns_base` (APNs, HTTP/2 sans chiffrement) : `/fcm-oauth/token`,
    /// `/fcm/v1/projects/<projet>/messages:send`, `/apns/3/device/<jeton>` et
    /// `/apns-sandbox/3/device/<jeton>`. Toute adresse hors de la boucle locale est refusée.
    pub fn local(base: &str, apns_base: &str) -> NotificationResult<Self> {
        let check = |text: &str| -> NotificationResult<Url> {
            let parsed = parse(text)?;
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
                    "faux services push : http://127.0.0.1 seulement".into(),
                ));
            }
            Ok(parsed)
        };
        let base = check(base)?;
        let apns = check(apns_base)?;
        let at = |root: &Url, path: &str| {
            parse(&format!("{}{path}", root.as_str().trim_end_matches('/')))
        };
        Ok(Self {
            fcm_token: at(&base, "/fcm-oauth/token")?,
            fcm_send: at(&base, "/fcm/v1/projects/")?,
            apns_production: at(&apns, "/apns/3/device/")?,
            apns_sandbox: at(&apns, "/apns-sandbox/3/device/")?,
        })
    }
}

/// Jeton gardé en mémoire avec son échéance (secondes Unix).
struct CachedToken {
    value: SecretString,
    until: i64,
}

/// Client des services push : jetons d'accès FCM et jetons du fournisseur APNs gardés en
/// mémoire.
pub struct PushApi {
    endpoints: PushEndpoints,
    /// FCM (HTTPS ; HTTP/1.1 ou HTTP/2 selon le serveur).
    http: Client,
    /// APNs : HTTP/2 seulement.
    apns: Client,
    /// Web Push : client contrôlé (SSRF).
    outbound: Arc<OutboundClient>,
    clock: PushClock,
    fcm_tokens: Mutex<HashMap<String, CachedToken>>,
    apns_tokens: Mutex<HashMap<String, CachedToken>>,
}

impl fmt::Debug for PushApi {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("PushApi")
            .field("endpoints", &self.endpoints)
            .finish_non_exhaustive()
    }
}

fn client(https_only: bool, http2_only: bool) -> NotificationResult<Client> {
    let mut builder = Client::builder()
        .use_rustls_tls()
        .https_only(https_only)
        .redirect(Policy::none())
        .timeout(REQUEST_TIMEOUT)
        .connect_timeout(REQUEST_TIMEOUT)
        .user_agent("lyxal-notification");
    if http2_only {
        builder = builder.http2_prior_knowledge();
    }
    if !https_only {
        builder = builder.no_proxy();
    }
    builder.build().map_err(|_| {
        NotificationError::Configuration("client HTTP des services push impossible".into())
    })
}

/// Valeur d'en-tête marquée sensible.
fn sensitive(value: &str) -> Result<HeaderValue, ProviderError> {
    let mut header = HeaderValue::from_str(value)
        .map_err(|_| ProviderError::secret("jeton inutilisable dans un en-tête"))?;
    header.set_sensitive(true);
    Ok(header)
}

/// Réponse lue : code, en-tête `apns-id`, corps JSON (64 Kio au plus).
struct Answer {
    status: u16,
    apns_id: Option<String>,
    body: Option<Value>,
}

/// Envoie la requête ; l'erreur de transport n'est jamais affichée (elle peut contenir le jeton).
async fn exchange(request: RequestBuilder) -> Result<Answer, ProviderError> {
    let response = request.send().await.map_err(|error| {
        if error.is_builder() {
            ProviderError::configuration("requête refusée avant l'envoi")
        } else if error.is_timeout() {
            ProviderError::unavailable("délai dépassé")
        } else {
            ProviderError::unavailable("service push injoignable")
        }
    })?;
    let status = response.status().as_u16();
    let apns_id = response
        .headers()
        .get("apns-id")
        .and_then(|value| value.to_str().ok())
        .and_then(super::normalize_message_id);
    let body = read_bounded(response)
        .await
        .and_then(|bytes| serde_json::from_slice::<Value>(&bytes).ok());
    Ok(Answer {
        status,
        apns_id,
        body,
    })
}

/// Réglage requis de l'intégration.
fn setting<'a>(value: &'a Option<String>, name: &str) -> Result<&'a str, ProviderError> {
    value.as_deref().ok_or_else(|| super::missing(name))
}

impl PushApi {
    /// Client de production : HTTPS seulement, adresses fixes, client contrôlé pour Web Push.
    pub fn new(outbound: Arc<OutboundClient>) -> NotificationResult<Self> {
        Self::build(PushEndpoints::production()?, true, outbound, system_clock())
    }

    /// Réservé aux tests : faux services de la boucle locale ([`PushEndpoints::local`]), client
    /// Web Push des tests ([`OutboundClient::for_local_tests`]) et horloge `clock`.
    pub fn for_local_tests(
        endpoints: PushEndpoints,
        outbound: Arc<OutboundClient>,
        clock: PushClock,
    ) -> NotificationResult<Self> {
        Self::build(endpoints, false, outbound, clock)
    }

    fn build(
        endpoints: PushEndpoints,
        https_only: bool,
        outbound: Arc<OutboundClient>,
        clock: PushClock,
    ) -> NotificationResult<Self> {
        Ok(Self {
            endpoints,
            http: client(https_only, false)?,
            apns: client(https_only, true)?,
            outbound,
            clock,
            fcm_tokens: Mutex::new(HashMap::new()),
            apns_tokens: Mutex::new(HashMap::new()),
        })
    }

    /// Heure de l'horloge (secondes Unix).
    pub fn now(&self) -> i64 {
        (self.clock)()
    }

    /// Envoie une notification à un appareil par l'intégration de son service.
    pub async fn send(
        &self,
        integration: &ClaimedIntegration,
        credentials: &PushCredentials,
        target: &PushTarget<'_>,
        message: &PushMessage,
    ) -> Result<ProviderReceipt, PushFailure> {
        match (credentials, target) {
            (
                PushCredentials::WebPush(key),
                PushTarget::WebPush {
                    endpoint,
                    p256dh,
                    auth,
                },
            ) => {
                self.send_webpush(integration, key, endpoint, p256dh, auth, message)
                    .await
            }
            (
                PushCredentials::Fcm {
                    client_email,
                    key_id,
                    key,
                },
                PushTarget::Fcm { token },
            ) => {
                let account = FcmAccount {
                    client_email,
                    key_id: key_id.as_deref(),
                    key,
                };
                self.send_fcm(integration, &account, token, message).await
            }
            (PushCredentials::Apns { key_id, key }, PushTarget::Apns { token }) => {
                self.send_apns(integration, key_id, key, token, message)
                    .await
            }
            _ => Err(ProviderError::configuration("appareil d'un autre service").into()),
        }
    }

    async fn send_webpush(
        &self,
        integration: &ClaimedIntegration,
        key: &EcdsaP256SigningKey,
        endpoint: &SecretString,
        p256dh: &[u8; 65],
        auth: &[u8; 16],
        message: &PushMessage,
    ) -> Result<ProviderReceipt, PushFailure> {
        let subject = setting(&integration.settings.vapid_subject, "vapid_subject")?;
        let public = URL_SAFE_NO_PAD.encode(key.public_key_uncompressed());
        // La clé donnée aux navigateurs doit être celle de la clé privée du coffre-fort
        if integration
            .settings
            .vapid_public_key
            .as_deref()
            .is_some_and(|configured| configured != public)
        {
            return Err(ProviderError::configuration(
                "clé publique VAPID différente de la clé privée du coffre-fort",
            )
            .into());
        }
        let url = Url::parse(endpoint.expose_secret())
            .map_err(|_| ProviderError::configuration("adresse Web Push illisible"))?;
        let token = vapid_token(key, &origin(&url), subject, self.now())?;
        let plaintext = serde_json::to_vec(&message.content())
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        let body = webpush_encrypt(p256dh, auth, &plaintext).map_err(|error| match error {
            lyxal_crypto::CryptoError::InputTooLarge => PushFailure::from(too_large()),
            // Clés du navigateur inutilisables : l'abonnement ne peut plus servir
            _ => PushFailure::device(DeviceRemoval::Invalid, "clés du navigateur refusées"),
        })?;
        let mut headers = HeaderMap::new();
        headers.insert(
            AUTHORIZATION,
            sensitive(&format!("vapid t={}, k={public}", token.expose_secret()))?,
        );
        headers.insert(
            HeaderName::from_static("content-encoding"),
            HeaderValue::from_static("aes128gcm"),
        );
        headers.insert(
            HeaderName::from_static("ttl"),
            HeaderValue::from(PUSH_TTL_SECONDS),
        );
        headers.insert(
            HeaderName::from_static("urgency"),
            HeaderValue::from_static(if message.urgent { "high" } else { "normal" }),
        );
        let response = self
            .outbound
            .post(
                endpoint.expose_secret(),
                WEBPUSH_HOSTS,
                &[],
                headers,
                HeaderValue::from_static("application/octet-stream"),
                body,
            )
            .await?;
        match response.status {
            200..=299 => Ok(ProviderReceipt {
                message_id: None,
                code: response.status,
            }),
            404 | 410 => Err(PushFailure::device(
                DeviceRemoval::Expired,
                &format!("abonnement expiré (HTTP {})", response.status),
            )),
            413 => Err(too_large().into()),
            status => Err(classify_status(status).into()),
        }
    }

    /// Jeton d'accès FCM : celui gardé en mémoire s'il vaut encore une minute, sinon un nouveau
    /// (jeton du compte de service échangé).
    async fn fcm_access(
        &self,
        cache_key: &str,
        account: &FcmAccount<'_>,
    ) -> Result<HeaderValue, ProviderError> {
        let now = self.now();
        if let Some(header) = self.cached(&self.fcm_tokens, cache_key, now, "Bearer ")? {
            return Ok(header);
        }
        let audience = self.endpoints.fcm_token.as_str().to_string();
        let assertion = fcm_assertion(
            account.key,
            account.key_id,
            account.client_email,
            &audience,
            now,
        )?;
        let form = zeroize::Zeroizing::new(format!(
            "grant_type={}&assertion={}",
            "urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer",
            assertion.expose_secret()
        ));
        let answer = exchange(
            self.http
                .post(self.endpoints.fcm_token.clone())
                .header(
                    CONTENT_TYPE,
                    HeaderValue::from_static("application/x-www-form-urlencoded"),
                )
                .header(ACCEPT, HeaderValue::from_static("application/json"))
                .body(form.to_string()),
        )
        .await?;
        if !(200..300).contains(&answer.status) {
            let mut error = classify_status(answer.status);
            error.detail = format!("jeton d'accès FCM refusé (HTTP {})", answer.status);
            return Err(error);
        }
        let body = answer.body.unwrap_or(Value::Null);
        let token = body
            .get("access_token")
            .and_then(Value::as_str)
            .filter(|token| !token.is_empty())
            .ok_or_else(|| ProviderError::unavailable("jeton d'accès FCM absent"))?;
        let lifetime = body
            .get("expires_in")
            .and_then(Value::as_i64)
            .unwrap_or(3600)
            .clamp(60, 86_400);
        let header = sensitive(&format!("Bearer {token}"))?;
        let value = SecretString::new(token.to_string())
            .map_err(|_| ProviderError::unavailable("jeton d'accès FCM trop long"))?;
        if let Ok(mut cache) = self.fcm_tokens.lock() {
            cache.insert(
                cache_key.to_string(),
                CachedToken {
                    value,
                    until: now + lifetime - 60,
                },
            );
        }
        Ok(header)
    }

    /// Jeton gardé en mémoire encore valable à `now`, en en-tête (`prefix` + jeton).
    fn cached(
        &self,
        cache: &Mutex<HashMap<String, CachedToken>>,
        key: &str,
        now: i64,
        prefix: &str,
    ) -> Result<Option<HeaderValue>, ProviderError> {
        let guard = cache
            .lock()
            .map_err(|_| ProviderError::unavailable("mémoire des jetons inutilisable"))?;
        match guard.get(key) {
            Some(token) if token.until > now => Ok(Some(sensitive(&format!(
                "{prefix}{}",
                token.value.expose_secret()
            ))?)),
            _ => Ok(None),
        }
    }

    fn forget(cache: &Mutex<HashMap<String, CachedToken>>, key: &str) {
        if let Ok(mut guard) = cache.lock() {
            guard.remove(key);
        }
    }

    async fn send_fcm(
        &self,
        integration: &ClaimedIntegration,
        account: &FcmAccount<'_>,
        token: &SecretString,
        message: &PushMessage,
    ) -> Result<ProviderReceipt, PushFailure> {
        let project = setting(&integration.settings.project_id, "project_id")?;
        let mut url = self.endpoints.fcm_send.clone();
        url.path_segments_mut()
            .map_err(|_| ProviderError::configuration("adresse FCM invalide"))?
            .pop_if_empty()
            .push(project)
            .push("messages:send");
        let body = serde_json::to_vec(&fcm_body(token.expose_secret(), message))
            .map(zeroize::Zeroizing::new)
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        let cache_key = format!(
            "{}|{}",
            lyxal_surreal::ToSql::to_sql(&integration.id),
            account.client_email
        );
        // Un jeton d'accès refusé (401) est oublié et l'envoi refait une fois avec un neuf
        for attempt in 0..2 {
            let access = self.fcm_access(&cache_key, account).await?;
            let answer = exchange(
                self.http
                    .post(url.clone())
                    .header(AUTHORIZATION, access)
                    .header(CONTENT_TYPE, HeaderValue::from_static("application/json"))
                    .header(ACCEPT, HeaderValue::from_static("application/json"))
                    .body(body.to_vec()),
            )
            .await?;
            if (200..300).contains(&answer.status) {
                return Ok(ProviderReceipt {
                    message_id: answer
                        .body
                        .as_ref()
                        .and_then(|b| b.get("name")?.as_str())
                        .and_then(super::normalize_message_id),
                    code: answer.status,
                });
            }
            if answer.status == 401 && attempt == 0 {
                Self::forget(&self.fcm_tokens, &cache_key);
                continue;
            }
            return Err(fcm_refusal(answer.status, answer.body.as_ref()));
        }
        Err(ProviderError::unavailable("jeton d'accès FCM refusé").into())
    }

    async fn send_apns(
        &self,
        integration: &ClaimedIntegration,
        key_id: &str,
        key: &EcdsaP256SigningKey,
        token: &SecretString,
        message: &PushMessage,
    ) -> Result<ProviderReceipt, PushFailure> {
        let settings = &integration.settings;
        let team_id = setting(&settings.team_id, "team_id")?;
        let topic = setting(&settings.bundle_id, "bundle_id")?;
        let base = match setting(&settings.environment, "environment")? {
            "sandbox" => &self.endpoints.apns_sandbox,
            _ => &self.endpoints.apns_production,
        };
        let mut url = base.clone();
        url.path_segments_mut()
            .map_err(|_| ProviderError::configuration("adresse APNs invalide"))?
            .pop_if_empty()
            .push(token.expose_secret());
        let url = zeroize::Zeroizing::new(url.to_string());
        let body = serde_json::to_vec(&apns_body(message))
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        let cache_key = format!("{team_id}|{key_id}");
        // Jeton du fournisseur expiré ou refusé (403) : renouvelé et l'envoi refait une fois
        for attempt in 0..2 {
            let now = self.now();
            let authorization = match self.cached(&self.apns_tokens, &cache_key, now, "bearer ")? {
                Some(header) => header,
                None => {
                    let fresh = apns_token(key, key_id, team_id, now)?;
                    let header = sensitive(&format!("bearer {}", fresh.expose_secret()))?;
                    if let Ok(mut cache) = self.apns_tokens.lock() {
                        cache.insert(
                            cache_key.clone(),
                            CachedToken {
                                value: fresh,
                                until: now + APNS_TOKEN_RENEWAL_SECONDS,
                            },
                        );
                    }
                    header
                }
            };
            let answer = exchange(
                self.apns
                    .post(url.as_str())
                    .header(AUTHORIZATION, authorization)
                    .header("apns-topic", sensitive(topic)?)
                    .header("apns-push-type", HeaderValue::from_static("alert"))
                    .header(
                        "apns-priority",
                        HeaderValue::from_static(if message.urgent { "10" } else { "5" }),
                    )
                    .header("apns-expiration", HeaderValue::from(now + PUSH_TTL_SECONDS))
                    .header(CONTENT_TYPE, HeaderValue::from_static("application/json"))
                    .body(body.clone()),
            )
            .await?;
            if answer.status == 200 {
                return Ok(ProviderReceipt {
                    message_id: answer.apns_id,
                    code: 200,
                });
            }
            let reason = answer
                .body
                .as_ref()
                .and_then(|b| b.get("reason")?.as_str())
                .unwrap_or_default()
                .to_string();
            if answer.status == 403
                && matches!(
                    reason.as_str(),
                    "ExpiredProviderToken" | "InvalidProviderToken"
                )
            {
                Self::forget(&self.apns_tokens, &cache_key);
                if attempt == 0 && reason == "ExpiredProviderToken" {
                    continue;
                }
            }
            return Err(apns_refusal(answer.status, &reason));
        }
        Err(ProviderError::unavailable("jeton du fournisseur APNs refusé").into())
    }
}

/// Compte de service Google lu du coffre-fort.
struct FcmAccount<'a> {
    client_email: &'a str,
    key_id: Option<&'a str>,
    key: &'a RsaSigningKey,
}

/// Données d'un message FCM ou APNs : textes seulement (FCM n'accepte que des chaînes).
fn string_data(message: &PushMessage) -> Map<String, Value> {
    let mut data: Map<String, Value> = message
        .data
        .iter()
        .map(|(key, value)| {
            let text = match value {
                Value::String(text) => text.clone(),
                other => other.to_string(),
            };
            (key.clone(), Value::String(text))
        })
        .collect();
    if let Some(link) = &message.link {
        data.insert("link".into(), json!(link));
    }
    if let Some(icon) = &message.icon {
        data.insert("icon".into(), json!(icon));
    }
    data
}

/// Corps d'un envoi FCM (API HTTP v1).
pub fn fcm_body(token: &str, message: &PushMessage) -> Value {
    let mut body = json!({
        "message": {
            "token": token,
            "notification": { "title": message.title, "body": message.body },
            "android": {
                "priority": if message.urgent { "HIGH" } else { "NORMAL" },
                "ttl": format!("{PUSH_TTL_SECONDS}s"),
            },
        }
    });
    let data = string_data(message);
    if !data.is_empty() {
        body["message"]["data"] = Value::Object(data);
    }
    body
}

/// Corps d'un envoi APNs : `aps.alert` (titre, texte), puis lien, icône et données.
pub fn apns_body(message: &PushMessage) -> Value {
    let mut body = json!({
        "aps": { "alert": { "title": message.title, "body": message.body }, "sound": "default" }
    });
    for (key, value) in string_data(message) {
        // `aps` est réservé par Apple
        if key != "aps" {
            body[key] = value;
        }
    }
    body
}

/// Refus de FCM : appareil désinscrit ou jeton invalide (retiré), jeton d'accès, quota, panne.
pub fn fcm_refusal(status: u16, body: Option<&Value>) -> PushFailure {
    let error = body.and_then(|b| b.get("error"));
    let state = error
        .and_then(|e| e.get("status")?.as_str())
        .unwrap_or_default();
    let details = error
        .and_then(|e| e.get("details")?.as_array())
        .cloned()
        .unwrap_or_default();
    let fcm_code = details
        .iter()
        .find_map(|d| d.get("errorCode")?.as_str())
        .unwrap_or_default();
    let on_token = details.iter().any(|d| {
        d.get("fieldViolations")
            .and_then(Value::as_array)
            .is_some_and(|violations| {
                violations
                    .iter()
                    .any(|v| v.get("field").and_then(Value::as_str) == Some("message.token"))
            })
    }) || error
        .and_then(|e| e.get("message")?.as_str())
        .is_some_and(|text| text.to_ascii_lowercase().contains("registration token"));
    if fcm_code == "UNREGISTERED" || state == "NOT_FOUND" {
        return PushFailure::device(DeviceRemoval::Expired, "jeton FCM désinscrit");
    }
    if (fcm_code == "INVALID_ARGUMENT" || state == "INVALID_ARGUMENT") && on_token {
        return PushFailure::device(DeviceRemoval::Invalid, "jeton FCM invalide");
    }
    let mut error = classify_status(status);
    if !fcm_code.is_empty() || !state.is_empty() {
        let code = if fcm_code.is_empty() { state } else { fcm_code };
        error.detail = format!(
            "HTTP {status} {}",
            code.chars().take(64).collect::<String>()
        );
    }
    error.into()
}

/// Refus d'APNs : appareil désinscrit (410) ou jeton refusé (`BadDeviceToken`) retirés ; message
/// trop grand ; 429 et 5xx temporaires.
pub fn apns_refusal(status: u16, reason: &str) -> PushFailure {
    match (status, reason) {
        (410, _) => PushFailure::device(DeviceRemoval::Expired, "appareil désinscrit (410)"),
        (400, "BadDeviceToken") => {
            PushFailure::device(DeviceRemoval::Invalid, "jeton APNs refusé (BadDeviceToken)")
        }
        (413, _) | (_, "PayloadTooLarge") => too_large().into(),
        _ => {
            let mut error = classify_status(status);
            if !reason.is_empty() {
                error.detail = format!(
                    "HTTP {status} {}",
                    reason.chars().take(64).collect::<String>()
                );
            }
            error.into()
        }
    }
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    use super::*;

    fn message(body: &str) -> PushMessage {
        PushMessage {
            title: "Devis".into(),
            body: body.into(),
            link: Some("/devis/7".into()),
            icon: None,
            data: Map::new(),
            urgent: false,
        }
    }

    #[test]
    fn a_long_text_is_truncated_to_fit_four_kib() {
        let short = message("Votre devis est prêt").fitted().expect("court");
        assert_eq!(short.body, "Votre devis est prêt");
        let long = message(&"é".repeat(5000)).fitted().expect("tronqué");
        assert!(long.body.ends_with('…'));
        let size = serde_json::to_vec(&long.content()).expect("json").len();
        assert!(size <= MAX_PUSH_PAYLOAD_BYTES, "{size}");
        // Le plus long texte possible : un caractère de plus ne tiendrait pas
        assert!(size + "é".len() > MAX_PUSH_PAYLOAD_BYTES);
        let mut data = Map::new();
        data.insert("n".into(), json!("x".repeat(4000)));
        let crowded = PushMessage {
            data,
            ..message("texte")
        };
        assert_eq!(
            crowded.fitted().expect_err("trop grand").code,
            "NOTIFICATION_PUSH_TOO_LARGE"
        );
    }

    #[test]
    fn refusals_are_classified() {
        let unregistered = json!({ "error": { "code": 404, "status": "NOT_FOUND", "details": [{ "@type": "type.googleapis.com/google.firebase.fcm.v1.FcmError", "errorCode": "UNREGISTERED" }] } });
        assert_eq!(
            fcm_refusal(404, Some(&unregistered)).removal,
            Some(DeviceRemoval::Expired)
        );
        let invalid = json!({ "error": { "code": 400, "status": "INVALID_ARGUMENT", "details": [{ "@type": "type.googleapis.com/google.rpc.BadRequest", "fieldViolations": [{ "field": "message.token" }] }] } });
        assert_eq!(
            fcm_refusal(400, Some(&invalid)).removal,
            Some(DeviceRemoval::Invalid)
        );
        // INVALID_ARGUMENT sur un autre champ : refus définitif, appareil gardé
        let other = json!({ "error": { "code": 400, "status": "INVALID_ARGUMENT", "message": "Invalid value at 'message.data'" } });
        let refused = fcm_refusal(400, Some(&other));
        assert_eq!(refused.removal, None);
        assert_eq!(refused.error.class, FailureClass::Permanent);
        let quota = fcm_refusal(429, None);
        assert_eq!(quota.error.class, FailureClass::Transient);
        assert_eq!(fcm_refusal(503, None).error.class, FailureClass::Transient);
        assert_eq!(
            apns_refusal(410, "Unregistered").removal,
            Some(DeviceRemoval::Expired)
        );
        assert_eq!(
            apns_refusal(400, "BadDeviceToken").removal,
            Some(DeviceRemoval::Invalid)
        );
        assert_eq!(apns_refusal(400, "BadTopic").removal, None);
        assert_eq!(
            apns_refusal(413, "PayloadTooLarge").error.code,
            "NOTIFICATION_PUSH_TOO_LARGE"
        );
        assert_eq!(
            apns_refusal(429, "TooManyRequests").error.class,
            FailureClass::Transient
        );
    }

    #[test]
    fn bodies_carry_strings_and_never_the_reserved_aps_key() {
        let mut data = Map::new();
        data.insert("n".into(), json!(7));
        data.insert("aps".into(), json!("pirate"));
        let message = PushMessage {
            data,
            urgent: true,
            ..message("Texte")
        };
        let fcm = fcm_body("jeton", &message);
        assert_eq!(fcm["message"]["data"]["n"], json!("7"));
        assert_eq!(fcm["message"]["data"]["link"], json!("/devis/7"));
        assert_eq!(fcm["message"]["android"]["priority"], json!("HIGH"));
        let apns = apns_body(&message);
        assert_eq!(apns["aps"]["alert"]["title"], json!("Devis"));
        assert_eq!(apns["link"], json!("/devis/7"));
        assert!(apns["aps"].get("sound").is_some());
        assert_eq!(apns["aps"].as_object().map(|o| o.len()), Some(2));
    }

    #[test]
    fn credentials_are_read_by_service_and_never_shown() {
        let key = EcdsaP256SigningKey::generate().expect("clé");
        let der = key.export_pkcs8();
        let pem = format!(
            "-----BEGIN PRIVATE KEY-----\n{}\n-----END PRIVATE KEY-----\n",
            base64::engine::general_purpose::STANDARD.encode(der.expose_secret())
        );
        let bytes =
            |value: Value| SecretBytes::new(value.to_string().into_bytes()).expect("valeur");
        let web =
            PushCredentials::parse(PushService::WebPush, &bytes(json!({ "private_key": pem })))
                .expect("Web Push");
        assert_eq!(format!("{web:?}"), "PushCredentials::WebPush([REDACTED])");
        let apns = PushCredentials::parse(
            PushService::Apns,
            &bytes(json!({ "key_id": "ABC123DEFG", "private_key": pem })),
        )
        .expect("APNs");
        assert!(matches!(apns, PushCredentials::Apns { .. }));
        for (service, value) in [
            (
                PushService::WebPush,
                json!({ "private_key": "pas une clé" }),
            ),
            (
                PushService::WebPush,
                json!({ "private_key": pem, "extra": 1 }),
            ),
            (PushService::Apns, json!({ "private_key": pem })),
            (
                PushService::Fcm,
                json!({ "client_email": "x@y.test", "private_key": pem }),
            ),
        ] {
            let error = PushCredentials::parse(service, &bytes(value)).expect_err("refus");
            assert_eq!(error.code, "NOTIFICATION_INTEGRATION_SECRET_INVALID");
        }
    }

    #[test]
    fn tokens_have_the_expected_claims() {
        let key = EcdsaP256SigningKey::generate().expect("clé");
        let claims = |token: &SecretString| -> (Value, Value) {
            let parts: Vec<&str> = token.expose_secret().split('.').collect();
            assert_eq!(parts.len(), 3);
            let decode = |part: &str| {
                serde_json::from_slice(&URL_SAFE_NO_PAD.decode(part).expect("base64"))
                    .expect("json")
            };
            assert_eq!(
                URL_SAFE_NO_PAD.decode(parts[2]).expect("signature").len(),
                64
            );
            (decode(parts[0]), decode(parts[1]))
        };
        let url =
            Url::parse("https://updates.push.services.mozilla.com/wpush/v2/abc").expect("url");
        let vapid =
            vapid_token(&key, &origin(&url), "mailto:contact@alpha.test", 1_000).expect("jeton");
        let (header, body) = claims(&vapid);
        assert_eq!(header, json!({ "typ": "JWT", "alg": "ES256" }));
        assert_eq!(
            body,
            json!({ "aud": "https://updates.push.services.mozilla.com", "exp": 1_000 + 12 * 3600, "sub": "mailto:contact@alpha.test" })
        );
        let apns = apns_token(&key, "ABC123DEFG", "ABCDE12345", 2_000).expect("jeton");
        let (header, body) = claims(&apns);
        assert_eq!(header, json!({ "alg": "ES256", "kid": "ABC123DEFG" }));
        assert_eq!(body, json!({ "iss": "ABCDE12345", "iat": 2_000 }));
    }
}
