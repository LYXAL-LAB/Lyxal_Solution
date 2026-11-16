//! Routes de `lyxal_notification` : désabonnement en un clic (RFC 8058, décision B6) et aperçu
//! d'une étape de parcours (décision C7).
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

use super::auth::{self, no_store, ApiError};
use crate::context::AppContext;
use crate::error::ServerError;
use axum::body::Bytes;
use axum::extract::{DefaultBodyLimit, Query, State};
use axum::http::header::{
    ACCEPT, CONTENT_SECURITY_POLICY, CONTENT_TYPE, REFERRER_POLICY, X_FRAME_OPTIONS,
};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::{get, post};
use axum::Router;
use lyxal_notification::models::{DigestVars, StepPreviewParams};
use lyxal_notification::{
    NotificationError, NotificationPreview, NotificationStore, UnsubscribeLinks,
};
use serde::Deserialize;
use serde_json::json;
use std::collections::HashMap;
use std::sync::Arc;

/// Taille maximale du corps d'une demande d'aperçu.
const PREVIEW_BODY_LIMIT: usize = 64 * 1024;

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

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;

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
