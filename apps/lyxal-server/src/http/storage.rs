//! Routes des fichiers `/storage/*` (`lyxal_storage`) : envoi, téléchargement, fiche, liste et
//! suppression, en flux.
//!
//! L'appelant est identifié par son jeton d'accès (`Authorization: Bearer`). Chaque requête ouvre
//! une session SurrealDB à son nom (client de l'hôte cloné, authentifié par le jeton) : les
//! fonctions `fn::storage_*` et les permissions des tables décident des droits ; l'hôte n'en
//! recopie aucun et n'utilise jamais sa session système ici. Réponses au contrat `LyxalResult`
//! (`{ ok, data, error }`), sauf le contenu d'un fichier.

use super::auth::{self, ok, ApiError};
use crate::context::AppContext;
use axum::body::Body;
use axum::extract::{Path, Query, State};
use axum::http::header::{
    ACCEPT_RANGES, CACHE_CONTROL, CONTENT_DISPOSITION, CONTENT_LENGTH, CONTENT_RANGE, CONTENT_TYPE,
    ETAG, IF_NONE_MATCH, IF_RANGE, LAST_MODIFIED, RANGE, X_CONTENT_TYPE_OPTIONS,
};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::get;
use axum::Router;
use bytes::Bytes;
use futures::{Stream, StreamExt};
use lyxal_auth::AuthError;
use lyxal_storage::models::{ObjectGetParams, ObjectListParams, ObjectState, StoredObject};
use lyxal_storage::{ByteRange, PutRequest, StorageError, StorageService, StorageStore};
use lyxal_surreal::ToSql;
use percent_encoding::{percent_decode_str, utf8_percent_encode, NON_ALPHANUMERIC};
use serde::Deserialize;
use serde_json::{json, Value};
use std::time::Duration;

/// Nom d'origine du fichier envoyé (texte encodé en pourcent).
const FILENAME_HEADER: &str = "x-lyxal-filename";

/// Routes `/storage/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/buckets/:bucket/objects", get(list))
        .route(
            "/buckets/:bucket/objects/*key",
            get(download).head(head).put(upload).delete(remove),
        )
}

// ----------------------------------------------------------------------------------------------
// Session de l'appelant
// ----------------------------------------------------------------------------------------------

/// Service de stockage sur une session SurrealDB au nom de l'appelant.
async fn service(context: &AppContext, headers: &HeaderMap) -> Result<StorageService, ApiError> {
    let host = auth::host(context)?;
    // Signature du jeton et session contrôlées (révocation, expiration, version des droits)
    auth::caller(&host, headers).await?;
    let token = headers
        .get("authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "))
        .ok_or(ApiError::Auth(AuthError::Rejected("AUTH_SESSION_REQUIRED")))?;
    let session = context.database.as_ref().clone();
    session
        .authenticate(token.to_string())
        .await
        .map_err(|error| {
            tracing::warn!(error = %error, "session SurrealDB de l'appelant refusée");
            ApiError::Auth(AuthError::Rejected("AUTH_SESSION_REQUIRED"))
        })?;
    Ok(StorageService::new(
        StorageStore::new(session),
        context.storage.clone(),
    ))
}

fn bucket_id(bucket: &str) -> String {
    format!("storage_bucket:{bucket}")
}

// ----------------------------------------------------------------------------------------------
// Fiche et en-têtes
// ----------------------------------------------------------------------------------------------

/// Fiche rendue au client, sans l'emplacement interne des octets.
fn object_json(object: &StoredObject) -> Value {
    json!({
        "id": object.id.to_sql(),
        "bucket": object.bucket.to_sql(),
        "tenant": object.tenant.as_ref().map(|tenant| tenant.to_sql()),
        "key": object.key,
        "filename": object.filename,
        "content_type": object.content_type,
        "size": object.size,
        "blake3": object.blake3,
        "state": object.state.as_str(),
        "owner": object.owner.as_ref().map(|owner| owner.to_sql()),
        "created_at": object.created_at.to_string(),
        "updated_at": object.updated_at.to_string(),
    })
}

fn etag(object: &StoredObject) -> String {
    format!("\"{}\"", object.blake3.as_deref().unwrap_or_default())
}

/// `Content-Disposition: attachment` : nom ASCII de repli et nom complet encodé (RFC 6266).
fn content_disposition(filename: &str) -> String {
    let fallback: String = filename
        .chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || "-_. ".contains(c) {
                c
            } else {
                '_'
            }
        })
        .collect();
    format!(
        "attachment; filename=\"{fallback}\"; filename*=UTF-8''{}",
        utf8_percent_encode(filename, NON_ALPHANUMERIC)
    )
}

/// En-têtes communs à `GET` et `HEAD` : le fichier est toujours proposé à l'enregistrement,
/// jamais interprété par le navigateur.
fn object_headers(object: &StoredObject) -> HeaderMap {
    let mut headers = HeaderMap::new();
    let mut set = |name, value: String| {
        if let Ok(value) = HeaderValue::from_str(&value) {
            headers.insert(name, value);
        }
    };
    set(
        CONTENT_TYPE,
        object
            .content_type
            .clone()
            .unwrap_or_else(|| "application/octet-stream".to_string()),
    );
    set(ETAG, etag(object));
    set(
        LAST_MODIFIED,
        object
            .updated_at
            .format("%a, %d %b %Y %H:%M:%S GMT")
            .to_string(),
    );
    set(CONTENT_DISPOSITION, content_disposition(&object.filename));
    set(ACCEPT_RANGES, "bytes".to_string());
    set(X_CONTENT_TYPE_OPTIONS, "nosniff".to_string());
    set(CACHE_CONTROL, "private, no-store".to_string());
    headers
}

/// Plage d'un en-tête `Range` : une seule plage en octets. Un en-tête d'une autre forme est
/// ignoré (fichier entier), comme le prévoit HTTP.
fn parse_range(header: &str) -> Option<ByteRange> {
    let spec = header.strip_prefix("bytes=")?.trim();
    if spec.contains(',') {
        return None;
    }
    let (first, last) = spec.split_once('-')?;
    match (first.trim(), last.trim()) {
        ("", count) => count.parse().ok().map(ByteRange::Last),
        (first, "") => first.parse().ok().map(ByteRange::From),
        (first, last) => Some(ByteRange::FromTo(first.parse().ok()?, last.parse().ok()?)),
    }
}

/// Plage demandée, si `If-Range` (s'il est présent) désigne bien la version actuelle du fichier.
fn requested_range(headers: &HeaderMap, object: &StoredObject) -> Option<ByteRange> {
    let range = parse_range(headers.get(RANGE)?.to_str().ok()?)?;
    match headers.get(IF_RANGE).map(|value| value.to_str()) {
        None => Some(range),
        Some(Ok(condition)) if condition == etag(object) => Some(range),
        Some(_) => None,
    }
}

fn not_modified(headers: &HeaderMap, object: &StoredObject) -> bool {
    headers
        .get(IF_NONE_MATCH)
        .and_then(|value| value.to_str().ok())
        .is_some_and(|value| {
            value
                .split(',')
                .any(|tag| tag.trim() == "*" || tag.trim().trim_start_matches("W/") == etag(object))
        })
}

/// Coupe un flux qui ne transmet plus rien pendant `idle`.
fn with_idle_timeout<S, T, E>(
    stream: S,
    idle: Duration,
) -> impl Stream<Item = Result<T, std::io::Error>> + Send
where
    S: Stream<Item = Result<T, E>> + Send + 'static,
    E: std::fmt::Display,
{
    futures::stream::unfold(Box::pin(stream), move |mut stream| async move {
        let item = match tokio::time::timeout(idle, stream.next()).await {
            Ok(None) => return None,
            Ok(Some(Ok(item))) => Ok(item),
            Ok(Some(Err(error))) => Err(std::io::Error::other(error.to_string())),
            Err(_) => Err(std::io::Error::new(
                std::io::ErrorKind::TimedOut,
                format!("aucune donnée transmise pendant {} s", idle.as_secs()),
            )),
        };
        Some((item, stream))
    })
}

fn idle(context: &AppContext) -> Duration {
    Duration::from_secs(context.config.storage.idle_timeout_seconds)
}

// ----------------------------------------------------------------------------------------------
// Routes
// ----------------------------------------------------------------------------------------------

async fn upload(
    State(context): State<AppContext>,
    Path((bucket, key)): Path<(String, String)>,
    headers: HeaderMap,
    body: Body,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let text = |name: &str| headers.get(name).and_then(|value| value.to_str().ok());
        let filename = match text(FILENAME_HEADER) {
            Some(encoded) => percent_decode_str(encoded)
                .decode_utf8()
                .map_err(|_| {
                    StorageError::ContentMismatch(format!("{FILENAME_HEADER} : UTF-8 invalide"))
                })?
                .into_owned(),
            None => key.rsplit('/').next().unwrap_or(&key).to_string(),
        };
        let request = PutRequest {
            bucket: bucket_id(&bucket),
            key,
            filename,
            // Type sans ses paramètres (`text/plain; charset=utf-8` → `text/plain`)
            content_type: text("content-type")
                .and_then(|value| value.split(';').next())
                .map(|value| value.trim().to_string()),
            size: text("content-length").and_then(|value| value.parse().ok()),
        };
        let content = with_idle_timeout(body.into_data_stream(), idle(&context));
        let stored = service.put(request, content).await?;
        ok(StatusCode::CREATED, object_json(&stored))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct DownloadQuery {
    /// Présent : la fiche du fichier est rendue, quel que soit son état, à la place du contenu.
    metadata: Option<String>,
}

async fn download(
    State(context): State<AppContext>,
    Path((bucket, key)): Path<(String, String)>,
    Query(query): Query<DownloadQuery>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let address = ObjectGetParams::by_address(bucket_id(&bucket), key);
        if query.metadata.is_some() {
            let object = service
                .store()
                .object_get(address)
                .await
                .map_err(StorageError::from)?;
            return ok(StatusCode::OK, object_json(&object));
        }
        let object = service.stat(address).await?;
        let mut response_headers = object_headers(&object);
        if not_modified(&headers, &object) {
            return Ok((StatusCode::NOT_MODIFIED, response_headers).into_response());
        }
        let range = requested_range(&headers, &object);
        let opened = match service
            .open(ObjectGetParams::by_id(object.id.to_sql()), range)
            .await
        {
            Ok(opened) => opened,
            Err(StorageError::RangeNotSatisfiable(size)) => {
                let mut response = auth::respond(
                    &context,
                    &headers,
                    Err(StorageError::RangeNotSatisfiable(size).into()),
                )
                .await;
                if let Ok(value) = HeaderValue::from_str(&format!("bytes */{size}")) {
                    response.headers_mut().insert(CONTENT_RANGE, value);
                }
                return Ok(response);
            }
            Err(error) => return Err(error.into()),
        };
        let length = opened.range.end - opened.range.start;
        response_headers.insert(CONTENT_LENGTH, HeaderValue::from(length));
        let status = if range.is_some() {
            let size = object.size.unwrap_or_default();
            if let Ok(value) = HeaderValue::from_str(&format!(
                "bytes {}-{}/{size}",
                opened.range.start,
                opened.range.end.saturating_sub(1)
            )) {
                response_headers.insert(CONTENT_RANGE, value);
            }
            StatusCode::PARTIAL_CONTENT
        } else {
            StatusCode::OK
        };
        let content: std::pin::Pin<Box<dyn Stream<Item = Result<Bytes, StorageError>> + Send>> =
            opened.content;
        let body = Body::from_stream(with_idle_timeout(content, idle(&context)));
        Ok((status, response_headers, body).into_response())
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn head(
    State(context): State<AppContext>,
    Path((bucket, key)): Path<(String, String)>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let object = service
            .stat(ObjectGetParams::by_address(bucket_id(&bucket), key))
            .await?;
        let mut response_headers = object_headers(&object);
        response_headers.insert(
            CONTENT_LENGTH,
            HeaderValue::from(object.size.unwrap_or_default()),
        );
        Ok((StatusCode::OK, response_headers).into_response())
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn remove(
    State(context): State<AppContext>,
    Path((bucket, key)): Path<(String, String)>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let object = service
            .store()
            .object_get(ObjectGetParams::by_address(bucket_id(&bucket), key))
            .await
            .map_err(StorageError::from)?;
        let deleted = service.delete(&object.id.to_sql()).await?;
        ok(StatusCode::OK, object_json(&deleted))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct ListQuery {
    prefix: Option<String>,
    limit: Option<i64>,
    start: Option<i64>,
}

async fn list(
    State(context): State<AppContext>,
    Path(bucket): Path<String>,
    Query(query): Query<ListQuery>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let listed = service
            .store()
            .object_list(ObjectListParams {
                bucket: bucket_id(&bucket),
                prefix: query.prefix,
                state: ObjectState::Available,
                limit: query.limit.unwrap_or(100),
                start: query.start.unwrap_or(0),
            })
            .await
            .map_err(StorageError::from)?;
        ok(
            StatusCode::OK,
            json!({
                "items": listed.items.iter().map(object_json).collect::<Vec<_>>(),
                "total": listed.total,
            }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn range_header_is_parsed_or_ignored() {
        assert_eq!(parse_range("bytes=0-9"), Some(ByteRange::FromTo(0, 9)));
        assert_eq!(parse_range("bytes=5-"), Some(ByteRange::From(5)));
        assert_eq!(parse_range("bytes=-3"), Some(ByteRange::Last(3)));
        // Plusieurs plages, autre unité, forme invalide : en-tête ignoré
        assert_eq!(parse_range("bytes=0-1,4-5"), None);
        assert_eq!(parse_range("lignes=0-9"), None);
        assert_eq!(parse_range("bytes=a-b"), None);
        assert_eq!(parse_range("bytes=-"), None);
    }

    #[test]
    fn attachment_name_is_safe_and_complete() {
        assert_eq!(
            content_disposition("Plan \"été\".pdf"),
            "attachment; filename=\"Plan __t__.pdf\"; filename*=UTF-8''Plan%20%22%C3%A9t%C3%A9%22%2Epdf"
        );
    }
}
