//! Routes du coffre-fort `/secrets/*` (`lyxal_secrets`) : réglages, fiches, valeurs, versions,
//! journal, rotation, clés, accès, demandes, protections et partages à usage unique.
//!
//! L'appelant est identifié par son jeton d'accès (`Authorization: Bearer`) : chaque requête ouvre
//! une session SurrealDB à son nom (comme les routes des fichiers). Les fonctions `fn::secrets_*`
//! et les permissions des tables décident des droits ; l'hôte n'en recopie aucun. La session
//! système ne sert qu'au service des valeurs (enveloppe contre un ticket tracé, clés
//! d'organisation) et à l'ouverture d'un lien de partage, seule route sans jeton.
//!
//! Une valeur ne passe jamais dans une adresse : seulement dans le corps JSON d'une requête
//! (`{ "value": "texte" }` ou `{ "value_base64": "…" }`) ou d'une réponse (`value` si c'est de
//! l'UTF-8, sinon `value_base64`). Toute réponse qui porte une valeur ou une clé de partage est
//! marquée `Cache-Control: no-store` et `Pragma: no-cache`. Aucune valeur, clé ni mot de passe
//! n'est écrit dans la trace. Réponses au contrat `LyxalResult` (`{ ok, data, error }`).

use super::auth::{self, ok, ApiError, ApiResult};
use crate::context::AppContext;
use crate::error::ServerError;
use crate::modules::secrets::SecretsHost;
use axum::body::Bytes;
use axum::extract::{Path, Query, State};
use axum::http::header::{CACHE_CONTROL, PRAGMA};
use axum::http::{HeaderMap, HeaderValue, StatusCode};
use axum::response::Response;
use axum::routing::{delete, get, post};
use axum::Router;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{SecretBytes, SecretString};
use lyxal_secrets::models::{
    AuditListParams, AuditVerifyParams, EmergencyAccessParams, GrantCreateParams, GrantListParams,
    GrantRevokeParams, PolicyDeleteParams, PolicyListParams, PolicySetParams, RequestAccessParams,
    RequestApplyParams, RequestChangeParams, RequestDecisionParams, RequestListParams,
    RequestRefParams, RequestRejectParams, RotationGetParams, RotationRefParams,
    SecretCreateParams, SecretGetParams, SecretListParams, SecretRefParams, SecretUpdateParams,
    SecretsDuration, SettingsGetParams, SettingsSetParams, ShareListParams, ShareRefParams, Stage,
    VersionLabelParams, VersionListParams, VersionRefParams,
};
use lyxal_secrets::{
    OpenerContext, ProposeRequest, PutValue, RevealRequest, RotateRequest, SecretsError,
    SecretsService, SecretsStore, ShareOpen, ShareRequest, ShareSource,
};
use lyxal_surreal::{LyxalSurrealError, SurrealValue, ToSql};
use serde_json::{json, Map, Value};
use std::collections::HashMap;
use surrealdb::types::{Datetime, Duration, Value as SurrealDbValue};

/// Champs de durée (`"1h"`, `"7d"`) convertis en durées SurrealDB.
const DURATION_FIELDS: [&str; 9] = [
    "ttl",
    "duration",
    "rotation_period",
    "max_grant_duration",
    "grant_default_duration",
    "grant_max_duration",
    "request_ttl",
    "share_default_ttl",
    "share_max_ttl",
];
/// Champs de date (RFC 3339) convertis en dates SurrealDB.
const DATETIME_FIELDS: [&str; 2] = ["expires_at", "since"];
/// Paramètres d'adresse numériques.
const NUMBER_QUERY: [&str; 3] = ["limit", "start", "from_seq"];
/// Paramètres d'adresse booléens.
const BOOLEAN_QUERY: [&str; 2] = ["active_only", "mine"];

/// Routes `/secrets/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/settings", get(settings_get).put(settings_set))
        .route("/secrets", get(secret_list).post(secret_create))
        .route("/secrets/:id", get(secret_get).patch(secret_update))
        .route("/secrets/:id/:action", post(secret_action))
        .route("/secrets/:id/versions", get(version_list).post(value_put))
        .route(
            "/secrets/:id/versions/:number/:action",
            post(version_action),
        )
        .route("/secrets/:id/reveal", post(value_reveal))
        .route("/secrets/:id/propose", post(value_propose))
        .route("/secrets/:id/labels", post(version_label))
        .route(
            "/secrets/:id/rotations",
            get(rotation_list).post(rotation_start),
        )
        .route("/secrets/:id/check", post(rotation_check))
        .route("/rotations/:id/cancel", post(rotation_cancel))
        .route("/tenant-key/rotate", post(tenant_key_rotate))
        .route("/audit", get(audit_list))
        .route("/audit/verify", post(audit_verify))
        .route("/grants", get(grant_list).post(grant_create))
        .route("/grants/:id/revoke", post(grant_revoke))
        .route("/access/emergency", post(access_emergency))
        .route("/requests", get(request_list))
        .route("/requests/access", post(request_access))
        .route("/requests/change", post(request_change))
        .route("/requests/:id", get(request_get))
        .route("/requests/:id/:action", post(request_action))
        .route("/policies", get(policy_list).put(policy_set))
        .route("/policies/:id", delete(policy_delete))
        .route("/shares", get(share_list).post(share_create))
        .route("/shares/:id/revoke", post(share_revoke))
        .route("/shares/:id/open", post(share_open))
}

// ----------------------------------------------------------------------------------------------
// Session, paramètres et réponses
// ----------------------------------------------------------------------------------------------

fn secrets_host(context: &AppContext) -> Result<&SecretsHost, ApiError> {
    context.secrets.as_ref().ok_or_else(|| {
        ApiError::Server(ServerError::Configuration {
            message: "coffre-fort des secrets non hébergé".to_string(),
        })
    })
}

/// Service du coffre-fort sur une session SurrealDB au nom de l'appelant.
async fn service(context: &AppContext, headers: &HeaderMap) -> Result<SecretsService, ApiError> {
    let host = secrets_host(context)?;
    let (_, session) = auth::caller_session(context, headers).await?;
    Ok(host.service(SecretsStore::new(session)))
}

/// Paramètres invalides (corps illisible, champ du mauvais type) : `SECRETS_INVALID_PARAMETERS`,
/// sans reprendre la donnée reçue.
fn invalid(what: &str) -> ApiError {
    ApiError::Secrets(SecretsError::InvalidRecord(what.to_string()))
}

/// Identifiant d'enregistrement : `table:clé` tel quel, sinon la clé dans cette table.
fn record(table: &str, id: &str) -> String {
    if id.contains(':') {
        id.to_string()
    } else {
        format!("{table}:{id}")
    }
}

/// Corps JSON (objet) ; un corps vide vaut un objet vide.
fn body(bytes: &Bytes) -> Result<Map<String, Value>, ApiError> {
    if bytes.iter().all(u8::is_ascii_whitespace) {
        return Ok(Map::new());
    }
    match serde_json::from_slice(bytes) {
        Ok(Value::Object(object)) => Ok(object),
        _ => Err(invalid("corps de la requête : objet JSON attendu")),
    }
}

/// Paramètres d'adresse typés (nombres, booléens, textes).
fn query(raw: HashMap<String, String>) -> Map<String, Value> {
    raw.into_iter()
        .map(|(key, text)| {
            let value = if NUMBER_QUERY.contains(&key.as_str()) {
                text.parse::<i64>().map_or(Value::String(text), Value::from)
            } else if BOOLEAN_QUERY.contains(&key.as_str()) {
                text.parse::<bool>()
                    .map_or(Value::String(text), Value::Bool)
            } else {
                Value::String(text)
            };
            (key, value)
        })
        .collect()
}

/// Paramètres d'une fonction `fn::secrets_*` : valeurs par défaut (`defaults`), puis champs
/// reçus (un `null` vaut un champ absent), durées et dates converties.
fn params<T: SurrealValue>(input: Map<String, Value>, defaults: Value) -> Result<T, ApiError> {
    let mut merged = match defaults {
        Value::Object(object) => object,
        _ => Map::new(),
    };
    merged.extend(input.into_iter().filter(|(_, value)| !value.is_null()));
    let mut value = Value::Object(merged).into_value();
    if let SurrealDbValue::Object(object) = &mut value {
        for (key, field) in object.iter_mut() {
            let SurrealDbValue::String(text) = field else {
                continue;
            };
            if DURATION_FIELDS.contains(&key.as_str()) {
                let parsed: Duration = text.parse().map_err(|_| invalid(key))?;
                *field = SurrealDbValue::Duration(parsed);
            } else if DATETIME_FIELDS.contains(&key.as_str()) {
                let parsed: Datetime = text.parse().map_err(|_| invalid(key))?;
                *field = SurrealDbValue::Datetime(parsed);
            }
        }
    }
    T::from_value(value).map_err(|_| invalid("paramètres"))
}

/// Données d'un résultat, en JSON.
fn data<T: SurrealValue>(value: T) -> Value {
    value.into_value().into_json_value()
}

/// Résultat d'une fonction SurrealQL rendu au client.
fn done<T: SurrealValue>(result: Result<T, LyxalSurrealError>) -> ApiResult {
    ok(StatusCode::OK, data(result.map_err(SecretsError::from)?))
}

/// Réponse qui porte une valeur ou une clé : jamais mise en cache.
fn no_store(result: ApiResult) -> ApiResult {
    let mut response = result?;
    let headers = response.headers_mut();
    headers.insert(CACHE_CONTROL, HeaderValue::from_static("no-store"));
    headers.insert(PRAGMA, HeaderValue::from_static("no-cache"));
    Ok(response)
}

/// Valeur reçue : `value` (texte) ou `value_base64` (octets), retirée du corps.
fn take_value(input: &mut Map<String, Value>) -> Result<SecretBytes, ApiError> {
    let bytes = match (input.remove("value"), input.remove("value_base64")) {
        (Some(Value::String(text)), None) => text.into_bytes(),
        (None, Some(Value::String(encoded))) => STANDARD
            .decode(encoded.as_bytes())
            .map_err(|_| invalid("value_base64"))?,
        _ => return Err(invalid("value ou value_base64 attendu")),
    };
    SecretBytes::new(bytes).map_err(|_| invalid("valeur trop grande"))
}

/// Texte secret facultatif (clé, mot de passe), retiré du corps.
fn take_secret(
    input: &mut Map<String, Value>,
    key: &str,
) -> Result<Option<SecretString>, ApiError> {
    match input.remove(key) {
        None | Some(Value::Null) => Ok(None),
        Some(Value::String(text)) => SecretString::new(text).map(Some).map_err(|_| invalid(key)),
        Some(_) => Err(invalid(key)),
    }
}

/// Valeur rendue : `value` si c'est de l'UTF-8, sinon `value_base64`.
fn value_json(value: &SecretBytes) -> Value {
    match std::str::from_utf8(value.expose_secret()) {
        Ok(text) => json!({ "value": text }),
        Err(_) => json!({ "value_base64": STANDARD.encode(value.expose_secret()) }),
    }
}

fn text_field(input: &Map<String, Value>, key: &str) -> Result<Option<String>, ApiError> {
    match input.get(key) {
        None | Some(Value::Null) => Ok(None),
        Some(Value::String(text)) => Ok(Some(text.clone())),
        Some(_) => Err(invalid(key)),
    }
}

fn integer_field(input: &Map<String, Value>, key: &str) -> Result<Option<i64>, ApiError> {
    match input.get(key) {
        None | Some(Value::Null) => Ok(None),
        Some(value) => value.as_i64().map(Some).ok_or_else(|| invalid(key)),
    }
}

fn bool_field(input: &Map<String, Value>, key: &str) -> Result<bool, ApiError> {
    match input.get(key) {
        None | Some(Value::Null) => Ok(false),
        Some(Value::Bool(flag)) => Ok(*flag),
        Some(_) => Err(invalid(key)),
    }
}

// ----------------------------------------------------------------------------------------------
// Réglages
// ----------------------------------------------------------------------------------------------

async fn settings_get(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: SettingsGetParams = params(query(raw), json!({}))?;
        done(service.store().settings_get(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn settings_set(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let settings: SettingsSetParams = params(body(&bytes)?, json!({ "clear": [] }))?;
        done(service.store().settings_set(settings).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Fiches
// ----------------------------------------------------------------------------------------------

async fn secret_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: SecretListParams = params(query(raw), json!({}))?;
        done(service.store().secret_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn secret_create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: SecretCreateParams =
            params(body(&bytes)?, json!({ "consumers": [], "tags": [] }))?;
        let created = service
            .store()
            .secret_create(params)
            .await
            .map_err(SecretsError::from)?;
        ok(StatusCode::CREATED, data(created))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn secret_get(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .secret_get(SecretGetParams::by_id(record("secrets_secret", &id)))
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn secret_update(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = body(&bytes)?;
        input.insert("secret".into(), record("secrets_secret", &id).into());
        let params: SecretUpdateParams = params(input, json!({ "clear": [] }))?;
        done(service.store().secret_update(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// `disable`, `enable`, `delete`, `restore`, `purge`.
async fn secret_action(
    State(context): State<AppContext>,
    Path((id, action)): Path<(String, String)>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let store = service.store();
        let params = SecretRefParams {
            secret: record("secrets_secret", &id),
        };
        match action.as_str() {
            "disable" => done(store.secret_disable(params).await),
            "enable" => done(store.secret_enable(params).await),
            "delete" => done(store.secret_delete(params).await),
            "restore" => done(store.secret_restore(params).await),
            "purge" => done(store.secret_purge(params).await),
            _ => Err(invalid("action")),
        }
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Valeurs et versions
// ----------------------------------------------------------------------------------------------

/// Nouvelle version : `{ value | value_base64, expected_version, stage }`.
async fn value_put(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = body(&bytes)?;
        let value = take_value(&mut input)?;
        let stage = match input.remove("stage") {
            None | Some(Value::Null) => Stage::Current,
            Some(stage) => Stage::from_value(stage.into_value()).map_err(|_| invalid("stage"))?,
        };
        let added = service
            .put(PutValue {
                secret: record("secrets_secret", &id),
                value,
                expected_version: integer_field(&input, "expected_version")?,
                stage,
            })
            .await?;
        ok(StatusCode::CREATED, data(added))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Lecture d'une valeur : `{ label, number }` ; droits, double facteur et journal décidés par la
/// base.
async fn value_reveal(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let input = body(&bytes)?;
        let revealed = service
            .reveal(RevealRequest {
                secret: record("secrets_secret", &id),
                label: text_field(&input, "label")?,
                number: integer_field(&input, "number")?,
            })
            .await?;
        let mut reply = value_json(&revealed.value);
        reply["number"] = revealed.number.into();
        no_store(ok(StatusCode::OK, reply))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Valeur proposée pour un secret protégé : `{ value | value_base64, reason }`.
async fn value_propose(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = body(&bytes)?;
        let value = take_value(&mut input)?;
        let proposed = service
            .propose(ProposeRequest {
                secret: record("secrets_secret", &id),
                value,
                reason: text_field(&input, "reason")?.unwrap_or_default(),
            })
            .await?;
        ok(
            StatusCode::CREATED,
            json!({ "version": data(proposed.version), "request": data(proposed.request) }),
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn version_list(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = query(raw);
        input.insert("secret".into(), record("secrets_secret", &id).into());
        let params: VersionListParams = params(input, json!({}))?;
        done(service.store().version_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Étiquette posée ou retirée : `{ label, number, remove }`.
async fn version_label(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = body(&bytes)?;
        input.insert("secret".into(), record("secrets_secret", &id).into());
        let params: VersionLabelParams = params(input, json!({ "remove": false }))?;
        done(service.store().version_label(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// `disable`, `enable`, `destroy` d'une version.
async fn version_action(
    State(context): State<AppContext>,
    Path((id, number, action)): Path<(String, i64, String)>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let store = service.store();
        let params = VersionRefParams {
            secret: record("secrets_secret", &id),
            number,
        };
        match action.as_str() {
            "disable" => done(store.version_disable(params).await),
            "enable" => done(store.version_enable(params).await),
            "destroy" => done(store.version_destroy(params).await),
            _ => Err(invalid("action")),
        }
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Journal
// ----------------------------------------------------------------------------------------------

async fn audit_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: AuditListParams = params(query(raw), json!({}))?;
        done(service.store().audit_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn audit_verify(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: AuditVerifyParams = params(body(&bytes)?, json!({}))?;
        done(service.store().audit_verify(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Rotation et clés
// ----------------------------------------------------------------------------------------------

/// Rotation demandée maintenant : `{ emergency, reason }`.
async fn rotation_start(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let input = body(&bytes)?;
        let rotation = service
            .rotate_now(RotateRequest {
                secret: record("secrets_secret", &id),
                emergency: bool_field(&input, "emergency")?,
                reason: text_field(&input, "reason")?,
            })
            .await?;
        ok(StatusCode::CREATED, data(rotation))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn rotation_list(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = query(raw);
        input.insert("secret".into(), record("secrets_secret", &id).into());
        let params: RotationGetParams = params(input, json!({}))?;
        done(service.store().rotation_get(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn rotation_cancel(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .rotation_cancel(RotationRefParams {
                    rotation: record("secrets_rotation", &id),
                })
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Essai sans bascule de la valeur en service par son rotateur.
async fn rotation_check(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let checked = service
            .check_rotation(&record("secrets_secret", &id))
            .await?;
        ok(StatusCode::OK, data(checked))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Nouvelle clé active d'une organisation : `{ tenant }` (absent : l'installation).
async fn tenant_key_rotate(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let input = body(&bytes)?;
        let created = service
            .rotate_tenant_key(text_field(&input, "tenant")?)
            .await?;
        ok(StatusCode::CREATED, data(created))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Accès, demandes et protections
// ----------------------------------------------------------------------------------------------

async fn grant_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: GrantListParams = params(query(raw), json!({}))?;
        done(service.store().grant_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn grant_create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: GrantCreateParams = params(body(&bytes)?, json!({ "folder": false }))?;
        let grant = service
            .store()
            .grant_create(params)
            .await
            .map_err(SecretsError::from)?;
        ok(StatusCode::CREATED, data(grant))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn grant_revoke(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .grant_revoke(GrantRevokeParams {
                    grant: record("secrets_grant", &id),
                })
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn access_emergency(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: EmergencyAccessParams = params(body(&bytes)?, json!({ "folder": false }))?;
        let grant = service
            .store()
            .access_emergency(params)
            .await
            .map_err(SecretsError::from)?;
        ok(StatusCode::CREATED, data(grant))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn request_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: RequestListParams = params(query(raw), json!({ "mine": false }))?;
        done(service.store().request_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn request_get(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .request_get(RequestRefParams {
                    request: record("secrets_request", &id),
                })
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn request_access(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: RequestAccessParams = params(body(&bytes)?, json!({ "folder": false }))?;
        let request = service
            .store()
            .request_access(params)
            .await
            .map_err(SecretsError::from)?;
        ok(StatusCode::CREATED, data(request))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn request_change(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: RequestChangeParams = params(body(&bytes)?, json!({}))?;
        let request = service
            .store()
            .request_change(params)
            .await
            .map_err(SecretsError::from)?;
        ok(StatusCode::CREATED, data(request))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// `approve` (`{ comment }`), `reject` (`{ reason }`), `cancel`, `apply` (`{ emergency, reason }`).
async fn request_action(
    State(context): State<AppContext>,
    Path((id, action)): Path<(String, String)>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let store = service.store();
        let mut input = body(&bytes)?;
        input.insert("request".into(), record("secrets_request", &id).into());
        match action.as_str() {
            "approve" => {
                let params: RequestDecisionParams = params(input, json!({}))?;
                done(store.request_approve(params).await)
            }
            "reject" => {
                let params: RequestRejectParams = params(input, json!({}))?;
                done(store.request_reject(params).await)
            }
            "cancel" => {
                let params: RequestRefParams = params(input, json!({}))?;
                done(store.request_cancel(params).await)
            }
            "apply" => {
                let params: RequestApplyParams = params(input, json!({ "emergency": false }))?;
                done(store.request_apply(params).await)
            }
            _ => Err(invalid("action")),
        }
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn policy_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: PolicyListParams = params(query(raw), json!({}))?;
        done(service.store().policy_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn policy_set(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: PolicySetParams = params(body(&bytes)?, json!({ "folder": false }))?;
        done(service.store().policy_set(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn policy_delete(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .policy_delete(PolicyDeleteParams {
                    policy: record("secrets_policy", &id),
                })
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Partages à usage unique
// ----------------------------------------------------------------------------------------------

async fn share_list(
    State(context): State<AppContext>,
    Query(raw): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let params: ShareListParams = params(query(raw), json!({}))?;
        done(service.store().share_list(params).await)
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Partage créé : `{ tenant, secret, label, number }` (copie d'un secret) ou
/// `{ tenant, value | value_base64 }` (texte), avec `max_views`, `ttl`, `passphrase`,
/// `members_only`, `note`. La clé du lien n'est rendue qu'ici.
async fn share_create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        let mut input = body(&bytes)?;
        let passphrase = take_secret(&mut input, "passphrase")?;
        let source = match text_field(&input, "secret")? {
            Some(secret) => ShareSource::Secret {
                secret: record("secrets_secret", &secret),
                label: text_field(&input, "label")?,
                number: integer_field(&input, "number")?,
            },
            None => ShareSource::Text(take_value(&mut input)?),
        };
        let max_views = integer_field(&input, "max_views")?
            .map(|views| u8::try_from(views).map_err(|_| invalid("max_views")))
            .transpose()?;
        let ttl = text_field(&input, "ttl")?
            .map(|ttl| ttl.parse::<SecretsDuration>().map_err(|_| invalid("ttl")))
            .transpose()?;
        let created = service
            .share_create(ShareRequest {
                tenant: text_field(&input, "tenant")?,
                source,
                max_views,
                ttl,
                passphrase,
                members_only: bool_field(&input, "members_only")?,
                note: text_field(&input, "note")?,
            })
            .await?;
        no_store(ok(
            StatusCode::CREATED,
            json!({ "share": data(created.share), "key": created.key.expose_secret() }),
        ))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

async fn share_revoke(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let service = service(&context, &headers).await?;
        done(
            service
                .store()
                .share_revoke(ShareRefParams {
                    share: record("secrets_share", &id),
                })
                .await,
        )
    }
    .await;
    auth::respond(&context, &headers, result).await
}

/// Ouverture d'un lien : `{ key, passphrase }`. Sans jeton ; un jeton présent est contrôlé et
/// désigne l'ouvreur (organisation et identité), exigé pour un lien réservé à l'organisation.
async fn share_open(
    State(context): State<AppContext>,
    Path(id): Path<String>,
    headers: HeaderMap,
    bytes: Bytes,
) -> Response {
    let result = async {
        let host = secrets_host(&context)?;
        let opener = if headers.contains_key("authorization") {
            let auth_host = auth::host(&context)?;
            let caller = auth::caller(&auth_host, &headers).await?;
            Some(OpenerContext {
                identity: caller.identity.as_ref().map(ToSql::to_sql),
                organization: caller.organization.as_ref().map(ToSql::to_sql),
            })
        } else {
            None
        };
        let mut input = body(&bytes)?;
        let key = take_secret(&mut input, "key")?.ok_or_else(|| invalid("key"))?;
        let passphrase = take_secret(&mut input, "passphrase")?;
        let value = host
            .share_opener()
            .share_open(ShareOpen {
                share: record("secrets_share", &id),
                key,
                passphrase,
                opener,
            })
            .await?;
        no_store(ok(StatusCode::OK, value_json(&value)))
    }
    .await;
    auth::respond(&context, &headers, result).await
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;

    fn object(value: Value) -> Map<String, Value> {
        value.as_object().cloned().unwrap_or_default()
    }

    #[test]
    fn query_values_are_typed_and_records_completed() {
        let raw = HashMap::from([
            ("limit".to_string(), "5".to_string()),
            ("active_only".to_string(), "false".to_string()),
            ("tenant".to_string(), "auth_organization:alpha".to_string()),
        ]);
        let typed = query(raw);
        assert_eq!(typed["limit"], 5);
        assert_eq!(typed["active_only"], false);
        let listed: ShareListParams =
            params(typed, json!({})).unwrap_or_else(|_| panic!("paramètres"));
        assert_eq!(listed.limit, Some(5));
        assert_eq!(listed.active_only, Some(false));
        assert_eq!(listed.tenant.as_deref(), Some("auth_organization:alpha"));
        assert_eq!(record("secrets_share", "abc"), "secrets_share:abc");
        assert_eq!(
            record("secrets_share", "secrets_share:abc"),
            "secrets_share:abc"
        );
    }

    #[test]
    fn durations_and_defaults_are_converted() {
        let input = object(json!({ "share_max_ttl": "2d", "max_versions": 5 }));
        let settings: SettingsSetParams =
            params(input, json!({ "clear": [] })).unwrap_or_else(|_| panic!("réglages"));
        assert_eq!(
            settings.share_max_ttl.map(|ttl| ttl.to_string()),
            Some("2d".to_string())
        );
        assert_eq!(settings.max_versions, Some(5));
        assert!(settings.clear.is_empty());
        let wrong = object(json!({ "share_max_ttl": "deux jours" }));
        assert!(params::<SettingsSetParams>(wrong, json!({ "clear": [] })).is_err());
    }
}
