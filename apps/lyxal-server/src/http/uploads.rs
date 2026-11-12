//! Envoi reprenable `/storage/uploads` : protocole tus 1.0 (cœur, extensions `creation`,
//! `termination` et `expiration`) sur `lyxal_storage`.
//!
//! Un gros fichier est envoyé en plusieurs requêtes ; après une coupure, le client demande la
//! position de l'envoi (`HEAD`) et reprend à cet endroit (`PATCH`). Même authentification et mêmes
//! droits que les autres routes de fichiers : la session SurrealDB de l'appelant décide. Les
//! réponses de succès suivent le protocole (en-têtes, corps vide) ; les erreurs sont au contrat
//! `LyxalResult`.

use super::auth::{self, ApiError};
use super::storage::{idle, service, with_idle_timeout};
use crate::context::AppContext;
use axum::body::Body;
use axum::extract::{Path, State};
use axum::http::header::{CACHE_CONTROL, CONTENT_TYPE, LOCATION};
use axum::http::{HeaderMap, HeaderName, HeaderValue, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::{options, patch};
use axum::Router;
use base64::Engine;
use lyxal_storage::models::UploadStatus;
use lyxal_storage::{StorageError, UploadRequest};
use lyxal_surreal::ToSql;
use std::collections::HashMap;

/// Version du protocole prise en charge.
const TUS_VERSION: &str = "1.0.0";
/// Extensions du protocole prises en charge.
const TUS_EXTENSIONS: &str = "creation,termination,expiration";
/// Taille maximale d'un fichier, tous buckets confondus (5 Go) ; la limite du bucket s'applique à
/// la création de l'envoi.
const TUS_MAX_SIZE: u64 = 5_368_709_120;
/// Type du corps d'une requête `PATCH`.
const OFFSET_CONTENT_TYPE: &str = "application/offset+octet-stream";

const TUS_RESUMABLE: HeaderName = HeaderName::from_static("tus-resumable");
const TUS_VERSION_HEADER: HeaderName = HeaderName::from_static("tus-version");
const TUS_EXTENSION: HeaderName = HeaderName::from_static("tus-extension");
const TUS_MAX_SIZE_HEADER: HeaderName = HeaderName::from_static("tus-max-size");
const UPLOAD_LENGTH: HeaderName = HeaderName::from_static("upload-length");
const UPLOAD_OFFSET: HeaderName = HeaderName::from_static("upload-offset");
const UPLOAD_METADATA: HeaderName = HeaderName::from_static("upload-metadata");
const UPLOAD_EXPIRES: HeaderName = HeaderName::from_static("upload-expires");

/// En-têtes de requête du protocole, à autoriser pour un client navigateur (CORS).
pub(super) const REQUEST_HEADERS: [HeaderName; 4] =
    [TUS_RESUMABLE, UPLOAD_LENGTH, UPLOAD_OFFSET, UPLOAD_METADATA];
/// En-têtes de réponse du protocole, à rendre lisibles par un client navigateur (CORS).
pub(super) const RESPONSE_HEADERS: [HeaderName; 8] = [
    LOCATION,
    TUS_RESUMABLE,
    TUS_VERSION_HEADER,
    TUS_EXTENSION,
    TUS_MAX_SIZE_HEADER,
    UPLOAD_OFFSET,
    UPLOAD_LENGTH,
    UPLOAD_EXPIRES,
];

/// Routes `/storage/uploads`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/uploads", options(capabilities).post(create))
        .route(
            "/uploads/:upload",
            patch(append).head(status).delete(terminate),
        )
}

// ----------------------------------------------------------------------------------------------
// Protocole
// ----------------------------------------------------------------------------------------------

fn invalid(message: impl Into<String>) -> ApiError {
    StorageError::UploadInvalidRequest(message.into()).into()
}

/// Refuse une requête d'une autre version du protocole.
fn check_version(headers: &HeaderMap) -> Result<(), ApiError> {
    match headers.get(&TUS_RESUMABLE).map(|value| value.to_str()) {
        Some(Ok(TUS_VERSION)) => Ok(()),
        Some(Ok(other)) => Err(StorageError::UploadVersionUnsupported(other.to_string()).into()),
        Some(Err(_)) => Err(StorageError::UploadVersionUnsupported("illisible".to_string()).into()),
        None => Err(StorageError::UploadVersionUnsupported("absente".to_string()).into()),
    }
}

/// Entier non signé d'un en-tête obligatoire.
fn number(headers: &HeaderMap, name: &HeaderName) -> Result<u64, ApiError> {
    headers
        .get(name)
        .and_then(|value| value.to_str().ok())
        .and_then(|value| value.parse().ok())
        .ok_or_else(|| invalid(format!("{name} : entier attendu")))
}

/// `Upload-Metadata` : paires `clé valeur-en-base64` séparées par des virgules.
fn metadata(headers: &HeaderMap) -> Result<HashMap<String, String>, ApiError> {
    let Some(header) = headers.get(&UPLOAD_METADATA) else {
        return Ok(HashMap::new());
    };
    let header = header
        .to_str()
        .map_err(|_| invalid("upload-metadata : texte attendu"))?;
    let mut values = HashMap::new();
    for pair in header
        .split(',')
        .map(str::trim)
        .filter(|pair| !pair.is_empty())
    {
        let (key, encoded) = pair.split_once(' ').unwrap_or((pair, ""));
        let decoded = base64::engine::general_purpose::STANDARD
            .decode(encoded.trim())
            .ok()
            .and_then(|bytes| String::from_utf8(bytes).ok())
            .ok_or_else(|| invalid(format!("upload-metadata : valeur de {key} illisible")))?;
        values.insert(key.to_string(), decoded);
    }
    Ok(values)
}

/// Identifiant de fiche pour la clé d'envoi de l'adresse (lettres et chiffres seulement).
fn upload_id(key: &str) -> Result<String, ApiError> {
    if key.is_empty() || !key.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(invalid("identifiant d'envoi invalide"));
    }
    Ok(format!("storage_object:{key}"))
}

fn set(headers: &mut HeaderMap, name: HeaderName, value: String) {
    if let Ok(value) = HeaderValue::from_str(&value) {
        headers.insert(name, value);
    }
}

/// En-têtes d'état d'un envoi : position, taille, délai.
fn status_headers(status: &UploadStatus) -> HeaderMap {
    let mut headers = HeaderMap::new();
    set(&mut headers, UPLOAD_OFFSET, status.offset.to_string());
    set(&mut headers, UPLOAD_LENGTH, status.length.to_string());
    if let Some(expires_at) = &status.expires_at {
        set(
            &mut headers,
            UPLOAD_EXPIRES,
            expires_at.format("%a, %d %b %Y %H:%M:%S GMT").to_string(),
        );
    }
    headers
}

/// Réponse d'une route : version du protocole sur toute réponse ; versions prises en charge sur
/// un refus de version (`412`) ; type du corps refusé (`415`).
async fn respond(
    context: &AppContext,
    headers: &HeaderMap,
    result: Result<Response, ApiError>,
) -> Response {
    let unsupported = matches!(
        &result,
        Err(ApiError::Storage(StorageError::UploadVersionUnsupported(_)))
    );
    let mut response = auth::respond(context, headers, result).await;
    let response_headers = response.headers_mut();
    response_headers.insert(TUS_RESUMABLE, HeaderValue::from_static(TUS_VERSION));
    if unsupported {
        response_headers.insert(TUS_VERSION_HEADER, HeaderValue::from_static(TUS_VERSION));
    }
    response
}

// ----------------------------------------------------------------------------------------------
// Routes
// ----------------------------------------------------------------------------------------------

/// `OPTIONS /uploads` : ce que le serveur sait faire. Sans authentification, comme le prévoit le
/// protocole.
async fn capabilities() -> Response {
    let mut headers = HeaderMap::new();
    headers.insert(TUS_RESUMABLE, HeaderValue::from_static(TUS_VERSION));
    headers.insert(TUS_VERSION_HEADER, HeaderValue::from_static(TUS_VERSION));
    headers.insert(TUS_EXTENSION, HeaderValue::from_static(TUS_EXTENSIONS));
    headers.insert(TUS_MAX_SIZE_HEADER, HeaderValue::from(TUS_MAX_SIZE));
    (StatusCode::NO_CONTENT, headers).into_response()
}

/// `POST /uploads` : ouvre un envoi. `Upload-Length` : taille du fichier ; `Upload-Metadata` :
/// `bucket` (clé du bucket), `key` (clé du fichier), `filename` et `filetype` facultatifs.
async fn create(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        check_version(&headers)?;
        let service = service(&context, &headers).await?;
        let size = number(&headers, &UPLOAD_LENGTH)?;
        let mut metadata = metadata(&headers)?;
        let mut required = |name: &str| {
            metadata
                .remove(name)
                .filter(|value| !value.is_empty())
                .ok_or_else(|| invalid(format!("upload-metadata : {name} attendu")))
        };
        let bucket = required("bucket")?;
        let key = required("key")?;
        let filename = metadata
            .remove("filename")
            .filter(|value| !value.is_empty())
            .unwrap_or_else(|| key.rsplit('/').next().unwrap_or(&key).to_string());
        let status = service
            .upload_create(UploadRequest {
                bucket: format!("storage_bucket:{bucket}"),
                key,
                filename,
                content_type: metadata
                    .remove("filetype")
                    .and_then(|value| value.split(';').next().map(|kind| kind.trim().to_string()))
                    .filter(|value| !value.is_empty()),
                size,
            })
            .await?;
        let mut response_headers = status_headers(&status);
        response_headers.remove(&UPLOAD_OFFSET);
        response_headers.remove(&UPLOAD_LENGTH);
        let id = status.id.to_sql();
        set(
            &mut response_headers,
            LOCATION,
            format!(
                "/api/v1/storage/uploads/{}",
                id.strip_prefix("storage_object:").unwrap_or(&id)
            ),
        );
        Ok((StatusCode::CREATED, response_headers).into_response())
    }
    .await;
    respond(&context, &headers, result).await
}

/// `HEAD /uploads/{id}` : position et taille de l'envoi.
async fn status(
    State(context): State<AppContext>,
    Path(upload): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        check_version(&headers)?;
        let service = service(&context, &headers).await?;
        let status = service.upload_status(&upload_id(&upload)?).await?;
        let mut response_headers = status_headers(&status);
        response_headers.insert(CACHE_CONTROL, HeaderValue::from_static("no-store"));
        Ok((StatusCode::OK, response_headers).into_response())
    }
    .await;
    respond(&context, &headers, result).await
}

/// `PATCH /uploads/{id}` : écrit le corps à la position `Upload-Offset`. La requête qui apporte
/// le dernier octet assemble le fichier, le contrôle et le rend disponible.
async fn append(
    State(context): State<AppContext>,
    Path(upload): Path<String>,
    headers: HeaderMap,
    body: Body,
) -> Response {
    let wrong_type = headers
        .get(CONTENT_TYPE)
        .and_then(|value| value.to_str().ok())
        .is_none_or(|value| value.split(';').next().map(str::trim) != Some(OFFSET_CONTENT_TYPE));
    let result = async {
        check_version(&headers)?;
        // Type du corps contrôlé avant toute écriture
        if wrong_type {
            return Err(invalid(format!(
                "content-type : {OFFSET_CONTENT_TYPE} attendu"
            )));
        }
        let service = service(&context, &headers).await?;
        let id = upload_id(&upload)?;
        let offset = number(&headers, &UPLOAD_OFFSET)?;
        let content = with_idle_timeout(body.into_data_stream(), idle(&context));
        match service.upload_append(&id, offset, content).await {
            Ok(appended) => {
                let mut response_headers = HeaderMap::new();
                set(
                    &mut response_headers,
                    UPLOAD_OFFSET,
                    appended.offset.to_string(),
                );
                if appended.object.is_none() {
                    // Envoi encore en cours : son délai est rappelé
                    if let Some(expires) = service
                        .upload_status(&id)
                        .await
                        .ok()
                        .map(|status| status_headers(&status))
                        .and_then(|mut headers| headers.remove(&UPLOAD_EXPIRES))
                    {
                        response_headers.insert(UPLOAD_EXPIRES, expires);
                    }
                }
                Ok((StatusCode::NO_CONTENT, response_headers).into_response())
            }
            Err(error) => Err(ApiError::from(error)),
        }
    }
    .await;
    // Mauvaise position : la position courante est rendue pour que le client reprenne
    let current = match &result {
        Err(ApiError::Storage(StorageError::UploadOffsetMismatch(offset))) => Some(*offset),
        _ => None,
    };
    let refused = result.is_err();
    let mut response = respond(&context, &headers, result).await;
    // Refus du type du corps : statut `415` du protocole
    if wrong_type && refused && response.status() == StatusCode::BAD_REQUEST {
        *response.status_mut() = StatusCode::UNSUPPORTED_MEDIA_TYPE;
    }
    if let Some(offset) = current {
        response
            .headers_mut()
            .insert(UPLOAD_OFFSET, HeaderValue::from(offset));
    }
    response
}

/// `DELETE /uploads/{id}` : abandonne l'envoi ; les octets reçus sont retirés par le worker.
async fn terminate(
    State(context): State<AppContext>,
    Path(upload): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        check_version(&headers)?;
        let service = service(&context, &headers).await?;
        service.upload_terminate(&upload_id(&upload)?).await?;
        Ok(StatusCode::NO_CONTENT.into_response())
    }
    .await;
    respond(&context, &headers, result).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn upload_metadata_is_decoded() {
        let mut headers = HeaderMap::new();
        headers.insert(
            UPLOAD_METADATA,
            HeaderValue::from_static("bucket cGxhbnM=, key MjAyNi9maWxtLm1wNA==,vide"),
        );
        let values = metadata(&headers).ok().unwrap_or_default();
        let value = |key: &str| values.get(key).map(String::as_str);
        assert_eq!(value("bucket"), Some("plans"));
        assert_eq!(value("key"), Some("2026/film.mp4"));
        assert_eq!(value("vide"), Some(""));

        headers.insert(
            UPLOAD_METADATA,
            HeaderValue::from_static("bucket pas-du-base64!"),
        );
        assert!(metadata(&headers).is_err());
    }

    #[test]
    fn upload_identifier_is_a_plain_key() {
        assert_eq!(
            upload_id("abc123").ok().as_deref(),
            Some("storage_object:abc123")
        );
        assert!(upload_id("").is_err());
        assert!(upload_id("a:b").is_err());
        assert!(upload_id("a/b").is_err());
    }
}
