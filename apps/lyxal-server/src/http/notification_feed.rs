//! Routes du fil de notifications dans l'application (décisions F2 à F6), au nom de la personne
//! connectée : son jeton d'accès (`Authorization: Bearer`) ouvre une session SurrealDB à son nom,
//! et les fonctions `fn::notification_feed_*` comme les `PERMISSIONS` de `notification_inbox` ne
//! lui laissent voir et changer que **son** fil (organisation active). Un message d'une autre
//! personne reçoit la même réponse qu'un message absent (404, `NOTIFICATION_FEED_ITEM_NOT_FOUND`).
//!
//! * `GET /api/v1/notification/feed/stream` : flux SSE (`text/event-stream`). Premier événement
//!   `counts` (`{ unseen, unread, total }`), puis `notification` (nouveau message, même vue que
//!   la liste) et `counts` à chaque changement de son fil, et toutes les minutes ; commentaire
//!   `: keep-alive` toutes les 25 s, à chaque fois la session est revérifiée (expirée, révoquée
//!   ou jeton expiré : le flux se ferme, le client se reconnecte avec un jeton frais). 5 flux au
//!   plus par personne (429, `NOTIFICATION_FEED_STREAM_LIMIT`) ; session sans compte : 403
//!   (`NOTIFICATION_FEED_NO_ACCOUNT`). Un `EventSource` de navigateur n'envoie pas d'en-tête
//!   `Authorization` : le client lit le flux par `fetch` (ou une bibliothèque SSE qui pose
//!   l'en-tête).
//! * `GET /feed` (`limit`, `cursor`, onglet : `tags` et `severity` séparés par des virgules,
//!   `archived`, `read`, `data.<clé>=<valeur>`) et `GET /feed/counts` (mêmes filtres).
//! * `POST /feed/mark` (`{ ids | all, filter, state }`), `/feed/snooze` (`{ id, until }` : date
//!   RFC 3339 de 3 minutes à 90 jours ; `until` absent ou nul : réveil immédiat),
//!   `/feed/delete` (`{ id | all, filter }`), `/feed/{id}/action` (`{ action, status }`).

use super::auth::{self, ApiError, ApiResult};
use crate::context::AppContext;
use crate::error::ServerError;
use crate::modules::notification_feed::{FeedConnection, FeedEvent, FeedHub, TickStream};
use axum::body::Bytes;
use axum::extract::{DefaultBodyLimit, Path, Query, State};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::sse::{Event, Sse};
use axum::response::{IntoResponse, Response};
use axum::routing::{get, post};
use axum::Router;
use futures::StreamExt;
use lyxal_crypto::SecretString;
use lyxal_notification::models::{
    FeedActionParams, FeedCounts, FeedCountsParams, FeedDeleteParams, FeedFilter,
    FeedItemRefParams, FeedListParams, FeedMarkParams, FeedSnoozeParams, NotificationDatetime,
};
use lyxal_notification::{NotificationError, NotificationStore};
use lyxal_surreal::SurrealValue;
use serde::Deserialize;
use serde_json::{json, Map, Value};
use std::collections::HashMap;
use std::convert::Infallible;
use std::sync::Arc;

/// Taille maximale du corps d'une action sur le fil.
const FEED_BODY_LIMIT: usize = 16 * 1024;

/// Routes `/notification/feed*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/feed/stream", get(stream))
        .route("/feed", get(list))
        .route("/feed/counts", get(counts))
        .route(
            "/feed/mark",
            post(mark).layer(DefaultBodyLimit::max(FEED_BODY_LIMIT)),
        )
        .route(
            "/feed/snooze",
            post(snooze).layer(DefaultBodyLimit::max(FEED_BODY_LIMIT)),
        )
        .route(
            "/feed/delete",
            post(delete).layer(DefaultBodyLimit::max(FEED_BODY_LIMIT)),
        )
        .route(
            "/feed/:id/action",
            post(action).layer(DefaultBodyLimit::max(FEED_BODY_LIMIT)),
        )
}

fn invalid(message: &str) -> ApiError {
    ApiError::Server(ServerError::InvalidRequest {
        message: message.to_string(),
    })
}

/// Données d'un résultat, en JSON.
fn data<T: SurrealValue>(value: T) -> Value {
    value.into_value().into_json_value()
}

/// Session SurrealDB de la personne connectée.
async fn person(context: &AppContext, headers: &HeaderMap) -> Result<NotificationStore, ApiError> {
    let (_, session) = auth::caller_session(context, headers).await?;
    Ok(NotificationStore::new(session))
}

/// Liste de valeurs séparées par des virgules.
fn list_param(query: &HashMap<String, String>, key: &str) -> Option<Vec<String>> {
    query.get(key).map(|value| {
        value
            .split(',')
            .map(str::trim)
            .filter(|item| !item.is_empty())
            .map(str::to_string)
            .collect()
    })
}

fn bool_param(query: &HashMap<String, String>, key: &str) -> Result<Option<bool>, ApiError> {
    match query.get(key).map(String::as_str) {
        None => Ok(None),
        Some("true") => Ok(Some(true)),
        Some("false") => Ok(Some(false)),
        Some(_) => Err(invalid(&format!("{key} : true ou false attendu"))),
    }
}

/// Onglet lu dans la requête : `tags`, `severity`, `archived`, `read`, `data.<clé>`.
fn filter_from_query(query: &HashMap<String, String>) -> Result<Option<FeedFilter>, ApiError> {
    let data: Map<String, Value> = query
        .iter()
        .filter_map(|(key, value)| {
            key.strip_prefix("data.")
                .map(|key| (key.to_string(), Value::String(value.clone())))
        })
        .collect();
    let filter = FeedFilter {
        tags: list_param(query, "tags"),
        severity: list_param(query, "severity"),
        data: (!data.is_empty()).then_some(Value::Object(data)),
        archived: bool_param(query, "archived")?,
        read: bool_param(query, "read")?,
    };
    Ok((filter != FeedFilter::default()).then_some(filter))
}

/// Onglet d'un corps JSON.
#[derive(Deserialize, Default)]
#[serde(deny_unknown_fields)]
struct FilterBody {
    tags: Option<Vec<String>>,
    severity: Option<Vec<String>>,
    data: Option<Map<String, Value>>,
    archived: Option<bool>,
    read: Option<bool>,
}

impl From<FilterBody> for FeedFilter {
    fn from(body: FilterBody) -> Self {
        FeedFilter {
            tags: body.tags,
            severity: body.severity,
            data: body.data.map(Value::Object),
            archived: body.archived,
            read: body.read,
        }
    }
}

fn body<T: for<'de> Deserialize<'de>>(bytes: &Bytes, expected: &str) -> Result<T, ApiError> {
    serde_json::from_slice(bytes).map_err(|_| invalid(&format!("corps attendu : {expected}")))
}

/// `GET /feed` : fil paginé de la personne.
async fn list(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result: ApiResult = async {
        let limit = match query.get("limit") {
            Some(limit) => Some(
                limit
                    .parse::<i64>()
                    .map_err(|_| invalid("limit : entier attendu"))?,
            ),
            None => None,
        };
        let page = person(&context, &headers)
            .await?
            .feed_list(FeedListParams {
                filter: filter_from_query(&query)?,
                cursor: query.get("cursor").cloned(),
                limit,
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(page))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// `GET /feed/counts` : compteurs de la personne pour un onglet.
async fn counts(
    State(context): State<AppContext>,
    Query(query): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result: ApiResult = async {
        let counts = person(&context, &headers)
            .await?
            .feed_counts(FeedCountsParams {
                filter: filter_from_query(&query)?,
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(counts))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct MarkBody {
    ids: Option<Vec<String>>,
    all: Option<bool>,
    filter: Option<FilterBody>,
    state: String,
}

/// `POST /feed/mark` : états d'un ou plusieurs messages.
async fn mark(State(context): State<AppContext>, headers: HeaderMap, bytes: Bytes) -> Response {
    let result: ApiResult = async {
        let body: MarkBody = body(&bytes, "{ ids | all, filter, state }")?;
        let marked = person(&context, &headers)
            .await?
            .feed_mark(FeedMarkParams {
                ids: body.ids,
                all: body.all,
                filter: body.filter.map(FeedFilter::from),
                state: body.state,
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(marked))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct SnoozeBody {
    id: String,
    until: Option<String>,
}

/// `POST /feed/snooze` : sommeil jusqu'à `until`, ou réveil immédiat sans `until`.
async fn snooze(State(context): State<AppContext>, headers: HeaderMap, bytes: Bytes) -> Response {
    let result: ApiResult = async {
        let body: SnoozeBody = body(&bytes, "{ id, until }")?;
        let store = person(&context, &headers).await?;
        let item = match body.until {
            Some(until) => {
                let until = until
                    .parse::<NotificationDatetime>()
                    .map_err(|_| invalid("until : date RFC 3339 attendue"))?;
                store
                    .feed_snooze(FeedSnoozeParams { id: body.id, until })
                    .await
            }
            None => store.feed_unsnooze(FeedItemRefParams { id: body.id }).await,
        }
        .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(item))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct DeleteBody {
    id: Option<String>,
    all: Option<bool>,
    filter: Option<FilterBody>,
}

/// `POST /feed/delete` : un message, ou tous ceux d'un onglet.
async fn delete(State(context): State<AppContext>, headers: HeaderMap, bytes: Bytes) -> Response {
    let result: ApiResult = async {
        let body: DeleteBody = body(&bytes, "{ id | all, filter }")?;
        let deleted = person(&context, &headers)
            .await?
            .feed_delete(FeedDeleteParams {
                id: body.id,
                all: body.all,
                filter: body.filter.map(FeedFilter::from),
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(deleted))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct ActionBody {
    action: String,
    status: String,
}

/// `POST /feed/{id}/action` : état d'un bouton (`{ action, status }`).
async fn action(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result: ApiResult = async {
        let body: ActionBody = body(&bytes, "{ action, status }")?;
        let item = person(&context, &headers)
            .await?
            .feed_action(FeedActionParams {
                id,
                action: body.action,
                status: body.status,
            })
            .await
            .map_err(NotificationError::from)?;
        auth::ok(StatusCode::OK, data(item))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Contrôle de la session d'un flux à chaque signe de vie : jeton revérifié par le service de
/// connexion (signature, expiration, session révoquée ou expirée, version des droits).
struct SessionCheck {
    context: AppContext,
    token: SecretString,
}

impl SessionCheck {
    async fn valid(&self) -> bool {
        match auth::host(&self.context) {
            Ok(host) => host.access.authenticate(&self.token).await.is_ok(),
            Err(_) => false,
        }
    }
}

/// État d'un flux SSE.
struct StreamState {
    connection: FeedConnection,
    ticks: TickStream,
    session: Arc<SessionCheck>,
}

fn sse_event(event: FeedEvent) -> Event {
    match event {
        FeedEvent::Notification(view) => Event::default()
            .event("notification")
            .data(view.to_string()),
        FeedEvent::Counts(counts) => Event::default()
            .event("counts")
            .data(counts_json(counts).to_string()),
    }
}

fn counts_json(counts: FeedCounts) -> Value {
    json!({ "unseen": counts.unseen, "unread": counts.unread, "total": counts.total })
}

/// Prochain élément d'un flux : événement du hub, ou signe de vie après contrôle de la
/// session ; `None` ferme le flux (hub fermé, session finie).
async fn next_event(mut state: StreamState) -> Option<(Result<Event, Infallible>, StreamState)> {
    tokio::select! {
        event = state.connection.recv() => event.map(|event| (Ok(sse_event(event)), state)),
        tick = state.ticks.next() => {
            tick?;
            if !state.session.valid().await {
                tracing::info!("flux du fil fermé : session terminée");
                return None;
            }
            Some((Ok(Event::default().comment("keep-alive")), state))
        }
    }
}

/// `GET /feed/stream` : flux SSE du fil de la personne connectée.
async fn stream(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result: Result<Response, ApiError> = async {
        let hub: FeedHub = context
            .notification
            .as_ref()
            .and_then(|host| host.feed.clone())
            .ok_or_else(|| {
                ApiError::Notification(NotificationError::Configuration(
                    "temps réel du fil indisponible".to_string(),
                ))
            })?;
        let (caller, session) = auth::caller_session(&context, &headers).await?;
        let identity = caller
            .identity
            .as_ref()
            .map(lyxal_surreal::ToSql::to_sql)
            .ok_or(ApiError::Notification(NotificationError::Refused(
                "NOTIFICATION_FEED_NO_ACCOUNT",
            )))?;
        let store = NotificationStore::new(session);
        // Premiers compteurs, lus dans la session de la personne (fil vide sans abonné)
        let initial = match store.feed_counts(FeedCountsParams::default()).await {
            Ok(counts) => counts,
            Err(error) => {
                let error = NotificationError::from(error);
                if error.code() != "NOTIFICATION_FEED_NO_ACCOUNT" {
                    return Err(error.into());
                }
                FeedCounts::default()
            }
        };
        let tenant = caller
            .organization
            .as_ref()
            .map(lyxal_surreal::ToSql::to_sql);
        let connection = hub.register(identity, tenant, store)?;
        let token = headers
            .get("authorization")
            .and_then(|value| value.to_str().ok())
            .and_then(|value| value.strip_prefix("Bearer "))
            .map(str::to_string)
            .ok_or(ApiError::Notification(NotificationError::Refused(
                "NOTIFICATION_FEED_NO_ACCOUNT",
            )))?;
        let token = auth::secret(token)?;
        let state = StreamState {
            connection,
            ticks: hub.ticks(),
            session: Arc::new(SessionCheck {
                context: context.clone(),
                token,
            }),
        };
        let first = futures::stream::once(async move {
            Ok::<_, Infallible>(sse_event(FeedEvent::Counts(initial)))
        });
        let events = first.chain(futures::stream::unfold(state, next_event));
        let mut response = Sse::new(events).into_response();
        // Aucun tampon d'un mandataire inverse entre la base et le navigateur
        response
            .headers_mut()
            .insert("x-accel-buffering", HeaderValue::from_static("no"));
        Ok(response)
    }
    .await;
    match result {
        Ok(response) => response,
        Err(error) => auth::respond(&context, &headers, Err(error)).await,
    }
}
