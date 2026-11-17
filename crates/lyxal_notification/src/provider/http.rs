//! API HTTP des fournisseurs d'e-mail (Brevo, Mailgun, Postmark, Resend) par `reqwest` (K10) :
//! TLS rustls, délai borné (10 s), aucune redirection suivie, réponse lue sur 64 Kio au plus.
//! Les adresses des API sont fixées dans le code : aucune valeur de la base ni d'une personne ne
//! choisit l'hôte appelé (le domaine Mailgun n'est qu'un segment de chemin, encodé).

use reqwest::header::{HeaderValue, ACCEPT};
use reqwest::redirect::Policy;
use reqwest::{Client, RequestBuilder, Url};
use serde_json::{json, Map, Value};
use std::net::IpAddr;
use std::time::Duration;

use super::{
    header_address, mailbox, missing, normalize_message_id, unsubscribe_header, Credentials,
    EmailMessage, ProviderError, ProviderReceipt,
};
use crate::error::{NotificationError, NotificationResult};
use crate::models::IntegrationSettings;

/// Délai d'une requête à un fournisseur (connexion, envoi et réponse).
pub const REQUEST_TIMEOUT: Duration = Duration::from_secs(10);
/// Taille maximale d'une réponse lue.
pub const MAX_RESPONSE_BYTES: usize = 64 * 1024;

const BREVO_URL: &str = "https://api.brevo.com/v3/smtp/email";
const MAILGUN_US_URL: &str = "https://api.mailgun.net/v3/";
const MAILGUN_EU_URL: &str = "https://api.eu.mailgun.net/v3/";
const POSTMARK_URL: &str = "https://api.postmarkapp.com/email";
const RESEND_URL: &str = "https://api.resend.com/emails";

/// Adresses des API.
#[derive(Debug, Clone)]
pub struct ApiEndpoints {
    brevo: Url,
    mailgun_us: Url,
    mailgun_eu: Url,
    postmark: Url,
    resend: Url,
}

fn parse(url: &str) -> NotificationResult<Url> {
    Url::parse(url).map_err(|_| NotificationError::Configuration("adresse d'API invalide".into()))
}

impl ApiEndpoints {
    /// Adresses de production des fournisseurs (constantes du code).
    pub fn production() -> NotificationResult<Self> {
        Ok(Self {
            brevo: parse(BREVO_URL)?,
            mailgun_us: parse(MAILGUN_US_URL)?,
            mailgun_eu: parse(MAILGUN_EU_URL)?,
            postmark: parse(POSTMARK_URL)?,
            resend: parse(RESEND_URL)?,
        })
    }

    /// Réservé aux tests : faux fournisseurs servis sous `base` (`http://127.0.0.1:<port>`) :
    /// `/brevo/v3/smtp/email`, `/mailgun-us/v3/<domaine>/messages`,
    /// `/mailgun-eu/v3/<domaine>/messages`, `/postmark/email`, `/resend/emails`. Toute adresse
    /// hors de la boucle locale est refusée.
    pub fn local(base: &str) -> NotificationResult<Self> {
        let base = parse(base)?;
        let loopback = match base.host_str() {
            Some("localhost") => true,
            Some(host) => host
                .trim_start_matches('[')
                .trim_end_matches(']')
                .parse::<IpAddr>()
                .is_ok_and(|ip| ip.is_loopback()),
            None => false,
        };
        if base.scheme() != "http" || !loopback {
            return Err(NotificationError::Configuration(
                "faux fournisseurs : http://127.0.0.1 seulement".into(),
            ));
        }
        let at = |path: &str| parse(&format!("{}{path}", base.as_str().trim_end_matches('/')));
        Ok(Self {
            brevo: at("/brevo/v3/smtp/email")?,
            mailgun_us: at("/mailgun-us/v3/")?,
            mailgun_eu: at("/mailgun-eu/v3/")?,
            postmark: at("/postmark/email")?,
            resend: at("/resend/emails")?,
        })
    }
}

/// Client des API.
pub(crate) struct HttpApi {
    client: Client,
    endpoints: ApiEndpoints,
}

impl HttpApi {
    pub(crate) fn new(endpoints: ApiEndpoints, https_only: bool) -> NotificationResult<Self> {
        let mut builder = Client::builder()
            .use_rustls_tls()
            .https_only(https_only)
            .redirect(Policy::none())
            .timeout(REQUEST_TIMEOUT)
            .connect_timeout(REQUEST_TIMEOUT)
            .user_agent("lyxal-notification");
        if !https_only {
            // Faux fournisseurs de la boucle locale : jamais par un mandataire
            builder = builder.no_proxy();
        }
        let client = builder.build().map_err(|_| {
            NotificationError::Configuration("client HTTP des fournisseurs impossible".into())
        })?;
        Ok(Self { client, endpoints })
    }

    pub(crate) async fn brevo(
        &self,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let mut sender = Map::new();
        sender.insert(
            "email".into(),
            json!(header_address(&settings.from_address)?),
        );
        if let Some(name) = clean_name(settings.from_name.as_deref()) {
            sender.insert("name".into(), json!(name));
        }
        let mut to = Map::new();
        to.insert("email".into(), json!(header_address(&message.to)?));
        if let Some(name) = clean_name(message.to_name.as_deref()) {
            to.insert("name".into(), json!(name));
        }
        let mut body = Map::new();
        body.insert("sender".into(), Value::Object(sender));
        body.insert("to".into(), json!([Value::Object(to)]));
        body.insert("subject".into(), json!(message.content.subject));
        body.insert("htmlContent".into(), json!(message.content.html));
        body.insert("textContent".into(), json!(message.content.text));
        if let Some(reply_to) = &settings.reply_to {
            body.insert(
                "replyTo".into(),
                json!({ "email": header_address(reply_to)? }),
            );
        }
        let headers = unsubscribe_headers(message)?;
        if !headers.is_empty() {
            body.insert("headers".into(), Value::Object(headers));
        }
        let request = self
            .client
            .post(self.endpoints.brevo.clone())
            .header(
                "api-key",
                sensitive(credentials.api_key()?.expose_secret())?,
            )
            .json_body(&Value::Object(body))?;
        post(request, "messageId").await
    }

    pub(crate) async fn mailgun(
        &self,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let domain = settings
            .domain
            .as_deref()
            .ok_or_else(|| missing("domain"))?;
        let mut url = match settings.region.as_deref() {
            Some("eu") => self.endpoints.mailgun_eu.clone(),
            _ => self.endpoints.mailgun_us.clone(),
        };
        // Domaine : un segment de chemin encodé, jamais l'hôte
        url.path_segments_mut()
            .map_err(|_| ProviderError::configuration("adresse Mailgun invalide"))?
            .pop_if_empty()
            .push(domain)
            .push("messages");
        let mut form: Vec<(&str, String)> = vec![
            (
                "from",
                mailbox(settings.from_name.as_deref(), &settings.from_address)?,
            ),
            ("to", mailbox(message.to_name.as_deref(), &message.to)?),
            ("subject", message.content.subject.clone()),
            ("text", message.content.text.clone()),
            ("html", message.content.html.clone()),
        ];
        if let Some(reply_to) = &settings.reply_to {
            form.push(("h:Reply-To", header_address(reply_to)?.to_string()));
        }
        if let Some(link) = &message.list_unsubscribe {
            form.push((
                "h:List-Unsubscribe",
                format!("<{}>", unsubscribe_header(link)?),
            ));
            form.push((
                "h:List-Unsubscribe-Post",
                "List-Unsubscribe=One-Click".into(),
            ));
        }
        let request = self
            .client
            .post(url)
            .basic_auth("api", Some(credentials.api_key()?.expose_secret()))
            .header(ACCEPT, HeaderValue::from_static("application/json"))
            .form(&form);
        post(request, "id").await
    }

    pub(crate) async fn postmark(
        &self,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let mut body = Map::new();
        body.insert(
            "From".into(),
            json!(mailbox(
                settings.from_name.as_deref(),
                &settings.from_address
            )?),
        );
        body.insert(
            "To".into(),
            json!(mailbox(message.to_name.as_deref(), &message.to)?),
        );
        body.insert("Subject".into(), json!(message.content.subject));
        body.insert("HtmlBody".into(), json!(message.content.html));
        body.insert("TextBody".into(), json!(message.content.text));
        body.insert("MessageStream".into(), json!("outbound"));
        if let Some(reply_to) = &settings.reply_to {
            body.insert("ReplyTo".into(), json!(header_address(reply_to)?));
        }
        let headers: Vec<Value> = unsubscribe_headers(message)?
            .into_iter()
            .map(|(name, value)| json!({ "Name": name, "Value": value }))
            .collect();
        if !headers.is_empty() {
            body.insert("Headers".into(), Value::Array(headers));
        }
        let request = self
            .client
            .post(self.endpoints.postmark.clone())
            .header(
                "X-Postmark-Server-Token",
                sensitive(credentials.api_key()?.expose_secret())?,
            )
            .json_body(&Value::Object(body))?;
        post(request, "MessageID").await
    }

    pub(crate) async fn resend(
        &self,
        settings: &IntegrationSettings,
        message: &EmailMessage,
        credentials: &Credentials,
    ) -> Result<ProviderReceipt, ProviderError> {
        let mut body = Map::new();
        body.insert(
            "from".into(),
            json!(mailbox(
                settings.from_name.as_deref(),
                &settings.from_address
            )?),
        );
        body.insert(
            "to".into(),
            json!([mailbox(message.to_name.as_deref(), &message.to)?]),
        );
        body.insert("subject".into(), json!(message.content.subject));
        body.insert("html".into(), json!(message.content.html));
        body.insert("text".into(), json!(message.content.text));
        if let Some(reply_to) = &settings.reply_to {
            body.insert("reply_to".into(), json!(header_address(reply_to)?));
        }
        let headers = unsubscribe_headers(message)?;
        if !headers.is_empty() {
            body.insert("headers".into(), Value::Object(headers));
        }
        let request = self
            .client
            .post(self.endpoints.resend.clone())
            .bearer_auth(credentials.api_key()?.expose_secret())
            .json_body(&Value::Object(body))?;
        post(request, "id").await
    }
}

/// Corps JSON d'une requête.
trait JsonBody: Sized {
    fn json_body(self, body: &Value) -> Result<Self, ProviderError>;
}

impl JsonBody for RequestBuilder {
    fn json_body(self, body: &Value) -> Result<Self, ProviderError> {
        let bytes = serde_json::to_vec(body)
            .map_err(|_| ProviderError::configuration("message impossible à encoder"))?;
        Ok(self
            .header(
                reqwest::header::CONTENT_TYPE,
                HeaderValue::from_static("application/json"),
            )
            .header(ACCEPT, HeaderValue::from_static("application/json"))
            .body(bytes))
    }
}

/// Valeur d'en-tête marquée sensible (jamais affichée par `reqwest`).
fn sensitive(value: &str) -> Result<HeaderValue, ProviderError> {
    let mut header = HeaderValue::from_str(value)
        .map_err(|_| ProviderError::secret("clé d'API inutilisable dans un en-tête"))?;
    header.set_sensitive(true);
    Ok(header)
}

/// Nom affiché sans caractère de contrôle (vide : absent).
fn clean_name(name: Option<&str>) -> Option<String> {
    name.map(|n| n.chars().filter(|c| !c.is_control()).collect::<String>())
        .map(|n| n.trim().to_string())
        .filter(|n| !n.is_empty())
}

/// En-têtes `List-Unsubscribe` et `List-Unsubscribe-Post` (RFC 8058) d'un message non critique.
fn unsubscribe_headers(message: &EmailMessage) -> Result<Map<String, Value>, ProviderError> {
    let mut headers = Map::new();
    if let Some(link) = &message.list_unsubscribe {
        headers.insert(
            "List-Unsubscribe".into(),
            json!(format!("<{}>", unsubscribe_header(link)?)),
        );
        headers.insert(
            "List-Unsubscribe-Post".into(),
            json!("List-Unsubscribe=One-Click"),
        );
    }
    Ok(headers)
}

/// Envoie la requête et classe la réponse ; l'identifiant du message est lu dans le champ
/// `id_field` d'une réponse acceptée.
async fn post(request: RequestBuilder, id_field: &str) -> Result<ProviderReceipt, ProviderError> {
    let response = request.send().await.map_err(|error| {
        if error.is_builder() || error.is_request() && !error.is_connect() && !error.is_timeout() {
            ProviderError::configuration("requête refusée avant l'envoi")
        } else if error.is_timeout() {
            ProviderError::unavailable("délai dépassé")
        } else {
            ProviderError::unavailable("fournisseur injoignable")
        }
    })?;
    let status = response.status().as_u16();
    if !(200..300).contains(&status) {
        return Err(classify_status(status));
    }
    // Accepté : le message est parti ; une réponse illisible ou trop grande ne le renvoie pas
    let message_id = match read_bounded(response).await {
        Some(body) => serde_json::from_slice::<Value>(&body)
            .ok()
            .and_then(|value| {
                value
                    .get(id_field)
                    .and_then(Value::as_str)
                    .map(str::to_string)
            })
            .and_then(|id| normalize_message_id(&id)),
        None => None,
    };
    if message_id.is_none() {
        tracing::warn!(
            status,
            "envoi accepté sans identifiant lisible : ses retours ne seront pas rattachés"
        );
    }
    Ok(ProviderReceipt {
        message_id,
        code: status,
    })
}

/// Corps d'une réponse, 64 Kio au plus (`None` au-delà ou en cas d'erreur de lecture).
async fn read_bounded(mut response: reqwest::Response) -> Option<Vec<u8>> {
    if response
        .content_length()
        .is_some_and(|length| length > MAX_RESPONSE_BYTES as u64)
    {
        return None;
    }
    let mut body = Vec::new();
    loop {
        match response.chunk().await {
            Ok(Some(chunk)) => {
                if body.len() + chunk.len() > MAX_RESPONSE_BYTES {
                    return None;
                }
                body.extend_from_slice(&chunk);
            }
            Ok(None) => return Some(body),
            Err(_) => return None,
        }
    }
}

/// Classe d'une réponse refusée : 429 et 5xx temporaires, tout le reste définitif (400, 401,
/// 403, 422, autre 4xx, redirection non suivie).
pub(crate) fn classify_status(status: u16) -> ProviderError {
    let detail = format!("HTTP {status}");
    match status {
        429 | 500..=599 => ProviderError::unavailable(detail),
        _ => ProviderError::rejected(detail),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::FailureClass;

    #[test]
    fn statuses_are_classified() {
        for status in [429, 500, 502, 503] {
            assert_eq!(
                classify_status(status).class,
                FailureClass::Transient,
                "{status}"
            );
        }
        for status in [301, 302, 400, 401, 403, 404, 413, 422] {
            assert_eq!(
                classify_status(status).class,
                FailureClass::Permanent,
                "{status}"
            );
        }
        assert_eq!(classify_status(422).code, "NOTIFICATION_PROVIDER_REJECTED");
        assert_eq!(
            classify_status(503).code,
            "NOTIFICATION_PROVIDER_UNAVAILABLE"
        );
    }

    #[test]
    fn production_endpoints_are_fixed_https_and_tests_stay_local() {
        let production = ApiEndpoints::production().expect("adresses");
        for url in [
            &production.brevo,
            &production.mailgun_us,
            &production.mailgun_eu,
            &production.postmark,
            &production.resend,
        ] {
            assert_eq!(url.scheme(), "https");
        }
        assert_eq!(production.brevo.as_str(), BREVO_URL);
        assert_eq!(production.mailgun_eu.host_str(), Some("api.eu.mailgun.net"));
        assert!(ApiEndpoints::local("http://127.0.0.1:8080").is_ok());
        assert!(ApiEndpoints::local("http://localhost:8080/").is_ok());
        for refused in [
            "https://127.0.0.1:8080",
            "http://10.0.0.1",
            "http://api.brevo.com",
            "pas une url",
        ] {
            assert!(ApiEndpoints::local(refused).is_err(), "{refused}");
        }
    }
}
