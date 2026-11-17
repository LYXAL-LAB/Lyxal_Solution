//! Routes de `lyxal_notification` : désabonnement en un clic (RFC 8058, décision B6), aperçu
//! d'une étape de parcours (décision C7), retours des fournisseurs (D4) et essai d'une
//! intégration (D6).
//!
//! `GET /api/v1/notification/unsubscribe?t=<jeton>` : petite page de confirmation qui ne change
//! rien (un lien ouvert par un antivirus de messagerie ne désabonne pas) ; son bouton fait le
//! `POST`. `POST /api/v1/notification/unsubscribe?t=<jeton>` : désabonnement, appelé par le
//! client de messagerie (`List-Unsubscribe-Post: List-Unsubscribe=One-Click`) ou par la page ;
//! réponse 200 sans contenu (une petite page pour un navigateur). Sans session : le jeton signé
//! (HMAC-SHA256, clé dérivée de la clé applicative) est vérifié en temps constant avant toute
//! lecture de la base ; jeton refusé, ou abonné, catégorie ou parcours supprimés : 400. Liens non
//! configurés (clé applicative ou `notification.public_url` absente) : 404. Les requêtes sont
//! bornées par la concurrence de l'hôte ; aucune réponse n'est mise en cache ni ne transmet le
//! jeton à un autre site (`Referrer-Policy: no-referrer`).
//!
//! `POST /api/v1/notification/preview` : objet, HTML et texte d'une étape de canal rendus avec
//! des données d'exemple (`{ workflow, step_key, payload, locale, digest }`, 64 Kio au plus,
//! aucun autre champ, donc aucun secret). L'appelant est identifié par son jeton d'accès
//! (`Authorization: Bearer`) : la session SurrealDB est à son nom et
//! `fn::notification_step_preview` exige `notification.read`. Rien n'est écrit. Réponse au
//! contrat `LyxalResult` ; corps illisible : `SERVER_INVALID_REQUEST`.
//!
//! `POST /api/v1/notification/webhooks/{integration}` : retour d'un fournisseur, sans session.
//! L'intégration (clé de son enregistrement) est lue par la session système ; son secret des
//! retours est lu dans `lyxal_secrets` et le retour vérifié par `ProviderWebhook` (signature
//! HMAC-SHA256 de Mailgun et de Resend, identifiants Basic de Postmark et de Brevo comparés en
//! temps constant, horodatage signé à moins de 5 minutes), puis enregistré
//! (`fn::notification_provider_event_record`, dédoublonné). Réponses sans corps ni détail :
//! 200 (enregistré, déjà connu ou ignoré), 400 (corps illisible), 401 (signature, identifiants
//! ou horodatage refusés), 404 (intégration inconnue ou sans secret des retours), 413 (plus de
//! 256 Kio), 503 (secret illisible, coffre-fort ou base indisponible : le fournisseur réessaie).
//!
//! `POST /api/v1/notification/integrations/{integration}/test` : essai d'une intégration
//! (`{ to }`), au nom de l'appelant (`fn::notification_integration_test` : droit de gestion de
//! sa portée), envoyé avec le vrai fournisseur ; réponse `{ accepted, code }` (code
//! `NOTIFICATION_*` d'un refus), jamais de secret ; l'issue est notée sur l'intégration.

use super::auth::{self, no_store, ApiError};
use crate::context::AppContext;
use crate::error::ServerError;
use axum::body::Bytes;
use axum::extract::rejection::BytesRejection;
use axum::extract::{DefaultBodyLimit, Path, Query, State};
use axum::http::header::{
    ACCEPT, CONTENT_SECURITY_POLICY, CONTENT_TYPE, REFERRER_POLICY, X_FRAME_OPTIONS,
};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::{get, post};
use axum::Router;
use lyxal_notification::models::{
    DigestVars, IntegrationGetParams, IntegrationTestParams, IntegrationTestRecordParams,
    StepPreviewParams,
};
use lyxal_notification::{
    NotificationError, NotificationPreview, NotificationStore, UnsubscribeLinks, WebhookError,
    WebhookRequest, MAX_WEBHOOK_BYTES,
};
use serde::Deserialize;
use serde_json::json;
use std::collections::HashMap;
use std::sync::Arc;

/// Taille maximale du corps d'une demande d'aperçu.
const PREVIEW_BODY_LIMIT: usize = 64 * 1024;
/// Taille maximale du corps d'une demande d'essai.
const TEST_BODY_LIMIT: usize = 4 * 1024;

/// Routes `/notification/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route(
            "/unsubscribe",
            get(unsubscribe_page).post(unsubscribe_confirm),
        )
        .route(
            "/preview",
            post(preview).layer(DefaultBodyLimit::max(PREVIEW_BODY_LIMIT)),
        )
        .route(
            "/webhooks/:integration",
            post(webhook).layer(DefaultBodyLimit::max(MAX_WEBHOOK_BYTES)),
        )
        .route(
            "/integrations/:integration/test",
            post(integration_test).layer(DefaultBodyLimit::max(TEST_BODY_LIMIT)),
        )
        .layer(axum::middleware::map_response(no_store))
}

/// Liens configurés, ou `None` (404).
fn links(context: &AppContext) -> Option<Arc<UnsubscribeLinks>> {
    context.notification.as_ref()?.links.clone()
}

/// Jeton de la requête : caractères Base64url et un point seulement (repris dans la page).
fn token(query: &HashMap<String, String>) -> Option<&str> {
    query.get("t").map(String::as_str).filter(|token| {
        !token.is_empty()
            && token
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b == b'-' || b == b'_' || b == b'.')
    })
}

/// Page HTML sans script ni ressource externe.
fn page(status: StatusCode, body: String) -> Response {
    let mut response = (status, body).into_response();
    let headers = response.headers_mut();
    headers.insert(
        CONTENT_TYPE,
        HeaderValue::from_static("text/html; charset=utf-8"),
    );
    headers.insert(
        CONTENT_SECURITY_POLICY,
        HeaderValue::from_static(
            "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'",
        ),
    );
    headers.insert(REFERRER_POLICY, HeaderValue::from_static("no-referrer"));
    headers.insert(X_FRAME_OPTIONS, HeaderValue::from_static("DENY"));
    response
}

fn document(title: &str, content: &str) -> String {
    format!(
        "<!DOCTYPE html>\n<html lang=\"fr\">\n<head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>{title}</title></head>\n<body style=\"font-family:Arial,Helvetica,sans-serif;max-width:32rem;margin:3rem auto;padding:0 1rem;\">\n{content}\n</body>\n</html>\n"
    )
}

fn invalid_page() -> Response {
    page(
        StatusCode::BAD_REQUEST,
        document(
            "Lien invalide",
            "<h1>Lien invalide</h1>\n<p>Ce lien de désabonnement n'est pas valide.</p>\n<p lang=\"en\">This unsubscribe link is not valid.</p>",
        ),
    )
}

/// `GET` : confirmation, sans effet.
async fn unsubscribe_page(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
) -> Response {
    let Some(links) = links(&context) else {
        return StatusCode::NOT_FOUND.into_response();
    };
    let Some(token) = token(&query).filter(|token| links.verify(token).is_ok()) else {
        return invalid_page();
    };
    page(
        StatusCode::OK,
        document(
            "Désabonnement",
            &format!(
                "<h1>Désabonnement</h1>\n<p>Ne plus recevoir ces e-mails ?</p>\n<p lang=\"en\">Stop receiving these emails?</p>\n<form method=\"post\" action=\"?t={token}\">\n<input type=\"hidden\" name=\"List-Unsubscribe\" value=\"One-Click\">\n<button type=\"submit\">Me désabonner / Unsubscribe</button>\n</form>"
            ),
        ),
    )
}

/// `POST` : désabonnement en un clic.
async fn unsubscribe_confirm(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let (Some(host), Some(links)) = (context.notification.as_ref(), links(&context)) else {
        return StatusCode::NOT_FOUND.into_response();
    };
    let browser = headers
        .get(ACCEPT)
        .and_then(|accept| accept.to_str().ok())
        .is_some_and(|accept| accept.contains("text/html"));
    let refused = || {
        if browser {
            invalid_page()
        } else {
            StatusCode::BAD_REQUEST.into_response()
        }
    };
    let Some(params) = token(&query).and_then(|token| links.verify(token).ok()) else {
        return refused();
    };
    match host.store.unsubscribe(params).await {
        Ok(_) if browser => page(
            StatusCode::OK,
            document(
                "Désabonnement enregistré",
                "<h1>Désabonnement enregistré</h1>\n<p>Vous ne recevrez plus ces e-mails.</p>\n<p lang=\"en\">You will no longer receive these emails.</p>",
            ),
        ),
        Ok(_) => StatusCode::OK.into_response(),
        Err(error) => {
            let error = NotificationError::from(error);
            if error.code() == "NOTIFICATION_UNSUBSCRIBE_INVALID" {
                return refused();
            }
            tracing::warn!(code = %error.code(), "désabonnement impossible");
            StatusCode::SERVICE_UNAVAILABLE.into_response()
        }
    }
}

/// Regroupement d'exemple d'un aperçu.
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct PreviewDigest {
    count: i64,
    #[serde(default)]
    events: Vec<serde_json::Value>,
}

/// Corps d'une demande d'aperçu : aucun champ en plus (aucun secret accepté).
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct PreviewBody {
    workflow: String,
    step_key: String,
    #[serde(default)]
    payload: Option<serde_json::Map<String, serde_json::Value>>,
    locale: Option<String>,
    digest: Option<PreviewDigest>,
}

/// `POST /preview` : aperçu d'une étape au nom de l'appelant.
async fn preview(State(context): State<AppContext>, headers: HeaderMap, body: Bytes) -> Response {
    let result = async {
        let (_, session) = auth::caller_session(&context, &headers).await?;
        let body: PreviewBody = serde_json::from_slice(&body).map_err(|_| {
            ApiError::Server(ServerError::InvalidRequest {
                message:
                    "corps de l'aperçu : { workflow, step_key, payload, locale, digest } attendu"
                        .to_string(),
            })
        })?;
        let rendered = NotificationPreview::new(NotificationStore::new(session))
            .render(StepPreviewParams {
                workflow: body.workflow,
                step_key: body.step_key,
                payload: serde_json::Value::Object(body.payload.unwrap_or_default()),
                locale: body.locale,
                digest: body.digest.map(|digest| DigestVars {
                    count: digest.count,
                    events: serde_json::Value::Array(digest.events),
                }),
            })
            .await?;
        auth::ok(
            StatusCode::OK,
            json!({ "subject": rendered.subject, "html": rendered.html, "text": rendered.text }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Clé d'enregistrement d'une intégration dans le chemin : lettres, chiffres et `_` seulement.
fn integration_id(key: &str) -> Option<String> {
    (!key.is_empty()
        && key.len() <= 64
        && key.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'_'))
    .then(|| format!("notification_integration:{key}"))
}

/// Réponse sans corps.
fn bare(status: StatusCode) -> Response {
    status.into_response()
}

/// `POST /webhooks/{integration}` : retour d'un fournisseur, sans session.
async fn webhook(
    State(context): State<AppContext>,
    Path(key): Path<String>,
    headers: HeaderMap,
    body: Result<Bytes, BytesRejection>,
) -> Response {
    let Some(host) = context.notification.as_ref() else {
        return bare(StatusCode::NOT_FOUND);
    };
    let Some(id) = integration_id(&key) else {
        return bare(StatusCode::NOT_FOUND);
    };
    let body = match body {
        Ok(body) => body,
        Err(rejection) if rejection.status() == StatusCode::PAYLOAD_TOO_LARGE => {
            return bare(StatusCode::PAYLOAD_TOO_LARGE)
        }
        Err(_) => return bare(StatusCode::BAD_REQUEST),
    };
    let Some(dispatcher) = host.dispatcher.as_ref() else {
        return bare(StatusCode::SERVICE_UNAVAILABLE);
    };
    let integration = match host
        .store
        .integration_get(IntegrationGetParams { integration: id })
        .await
    {
        Ok(integration) if integration.webhook_path.is_some() => integration,
        Ok(_) => return bare(StatusCode::NOT_FOUND),
        Err(error) => {
            let error = NotificationError::from(error);
            if matches!(
                error.code().as_str(),
                "NOTIFICATION_INTEGRATION_NOT_FOUND" | "NOTIFICATION_INVALID_INPUT"
            ) {
                return bare(StatusCode::NOT_FOUND);
            }
            tracing::warn!(code = %error.code(), "retour d'un fournisseur : intégration illisible");
            return bare(StatusCode::SERVICE_UNAVAILABLE);
        }
    };
    let header = |name: &str| headers.get(name).and_then(|value| value.to_str().ok());
    let request = WebhookRequest {
        authorization: header("authorization"),
        svix_id: header("svix-id"),
        svix_timestamp: header("svix-timestamp"),
        svix_signature: header("svix-signature"),
        body: &body,
    };
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|elapsed| i64::try_from(elapsed.as_secs()).unwrap_or(i64::MAX))
        .unwrap_or_default();
    let events = match dispatcher.verify_webhook(&integration, &request, now).await {
        Ok(events) => events,
        Err(error) => {
            tracing::warn!(integration = %key, code = error.code(), "retour d'un fournisseur refusé");
            return bare(match error {
                WebhookError::TooLarge => StatusCode::PAYLOAD_TOO_LARGE,
                WebhookError::Unauthorized => StatusCode::UNAUTHORIZED,
                WebhookError::Invalid => StatusCode::BAD_REQUEST,
                WebhookError::Secret => StatusCode::SERVICE_UNAVAILABLE,
            });
        }
    };
    for event in events {
        if let Err(error) = host
            .store
            .provider_event_record(
                event.record_params(lyxal_surreal::ToSql::to_sql(&integration.id)),
            )
            .await
        {
            // Le fournisseur réessaie ; les retours déjà enregistrés sont dédoublonnés
            tracing::warn!(code = %NotificationError::from(error).code(), "retour d'un fournisseur non enregistré");
            return bare(StatusCode::SERVICE_UNAVAILABLE);
        }
    }
    bare(StatusCode::OK)
}

/// Corps d'une demande d'essai.
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct TestBody {
    to: String,
}

/// `POST /integrations/{integration}/test` : essai d'une intégration au nom de l'appelant.
async fn integration_test(
    State(context): State<AppContext>,
    Path(key): Path<String>,
    headers: HeaderMap,
    body: Bytes,
) -> Response {
    let result = async {
        let (_, session) = auth::caller_session(&context, &headers).await?;
        let body: TestBody = serde_json::from_slice(&body).map_err(|_| {
            ApiError::Server(ServerError::InvalidRequest {
                message: "corps de l'essai : { to } attendu".to_string(),
            })
        })?;
        let unavailable = || {
            ApiError::Notification(NotificationError::Configuration(
                "envoi par les intégrations indisponible (clé maîtresse du coffre-fort absente)"
                    .to_string(),
            ))
        };
        let host = context.notification.as_ref().ok_or_else(unavailable)?;
        let dispatcher = host.dispatcher.as_ref().ok_or_else(unavailable)?;
        let integration = integration_id(&key).ok_or_else(|| {
            ApiError::Server(ServerError::InvalidRequest {
                message: "intégration : identifiant invalide".to_string(),
            })
        })?;
        // Droit de gestion et adresse contrôlés au nom de l'appelant
        let target = NotificationStore::new(session)
            .integration_test(IntegrationTestParams {
                integration,
                to: body.to,
            })
            .await
            .map_err(NotificationError::from)?;
        let code = match dispatcher.send_test(&target.integration, &target.to).await {
            Ok(_) => None,
            Err(error) => Some(error.code),
        };
        host.store
            .integration_test_record(IntegrationTestRecordParams {
                integration: lyxal_surreal::ToSql::to_sql(&target.integration.id),
                ok: code.is_none(),
                code: code.clone(),
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(
            StatusCode::OK,
            json!({ "accepted": code.is_none(), "code": code }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn only_simple_integration_keys_are_read() {
        assert_eq!(
            integration_id("ab12_cd").as_deref(),
            Some("notification_integration:ab12_cd")
        );
        for bad in ["", "a:b", "a/b", "⟨x⟩", "a b", &"x".repeat(65)] {
            assert_eq!(integration_id(bad), None, "{bad}");
        }
    }

    #[test]
    fn only_base64url_tokens_are_read() {
        let query = |value: &str| HashMap::from([("t".to_string(), value.to_string())]);
        assert_eq!(token(&query("abc-_.XYZ09")), Some("abc-_.XYZ09"));
        for bad in ["", "a b", "a\"b", "<script>", "a&b=c"] {
            assert_eq!(token(&query(bad)), None, "{bad}");
        }
        assert_eq!(token(&HashMap::new()), None);
    }
}
