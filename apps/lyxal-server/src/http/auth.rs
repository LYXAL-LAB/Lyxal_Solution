//! Routes de connexion `/auth/*` (`lyxal_auth`, lots 3 et 4 ; seconds facteurs : `auth_mfa.rs`). Réponses au contrat `LyxalResult`
//! (`{ ok, data, error }`) ; les erreurs sont celles de la master data `AUTH_*`, sans détail sur
//! l'existence d'un compte. Les routes protégées identifient l'appelant par son jeton d'accès
//! (`Authorization: Bearer`) : signature vérifiée avec la clé de son emplacement, session
//! contrôlée par la base.

use crate::context::AppContext;
use crate::error::ServerError;
use crate::http::request_id;
use crate::modules::auth::AuthHost;
use axum::extract::{ConnectInfo, Path, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, post};
use axum::{Json, Router};
use lyxal_auth::models::{
    ClientInfo, IdentityGetParams, OrganizationGetParams, SessionCaller, SessionListParams,
};
use lyxal_auth::{AuthError, CodeProof, IssuedTokens, LoginActions, LoginOutcome, LoginRequest};
use lyxal_crypto::SecretString;
use lyxal_error::{LyxalError, LyxalResult};
use lyxal_i18n::{accept_language, I18nStore, LocaleResolveParams};
use lyxal_storage::StorageError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError, SurrealValue, ToSql};
use serde::Deserialize;
use serde_json::{json, Value};
use std::net::SocketAddr;
use std::sync::Arc;

/// Routes `/auth/*`.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/login", post(login))
        .route("/flows/:flow/actions", post(login_actions))
        .route("/flows/:flow/verification", post(login_verification))
        .route("/token/refresh", post(refresh))
        .route("/logout", post(logout))
        .route("/sessions", get(sessions))
        .route("/sessions/:session", delete(revoke_session))
        .route("/session/organization", post(switch_organization))
        .route("/registration/start", post(registration_start))
        .route("/registration/complete", post(registration_complete))
        .route("/recovery", post(recovery_start))
        .route("/recovery/complete", post(recovery_complete))
        .route("/verification", post(verification_start))
        .route("/verification/complete", post(verification_complete))
        .route("/address-change", post(address_change_start))
        .route("/address-change/complete", post(address_change_complete))
        .route("/password", post(change_password))
        .route("/service/token", post(service_token))
        .route("/api-keys/exchange", post(api_key_exchange))
        .merge(super::auth_mfa::routes())
        .layer(axum::middleware::map_response(no_store))
}

/// Réponses des routes d'authentification (jetons, parcours, sessions) : jamais mises en cache.
async fn no_store(mut response: Response) -> Response {
    let headers = response.headers_mut();
    headers.insert(
        axum::http::header::CACHE_CONTROL,
        axum::http::HeaderValue::from_static("no-store"),
    );
    headers.insert(
        axum::http::header::PRAGMA,
        axum::http::HeaderValue::from_static("no-cache"),
    );
    response
}

// ----------------------------------------------------------------------------------------------
// Réponses
// ----------------------------------------------------------------------------------------------

/// Erreur d'une route de l'API.
pub enum ApiError {
    /// Erreur métier ou du service de connexion.
    Auth(AuthError),
    /// Erreur métier ou du service de stockage.
    Storage(StorageError),
    /// Erreur de l'hôte.
    Server(ServerError),
}

impl From<StorageError> for ApiError {
    fn from(error: StorageError) -> Self {
        Self::Storage(error)
    }
}

impl From<AuthError> for ApiError {
    fn from(error: AuthError) -> Self {
        Self::Auth(error)
    }
}

impl From<ServerError> for ApiError {
    fn from(error: ServerError) -> Self {
        Self::Server(error)
    }
}

pub(super) type ApiResult = Result<Response, ApiError>;

pub(super) fn ok(status: StatusCode, data: Value) -> ApiResult {
    let body: LyxalResult<Value> = LyxalResult {
        ok: true,
        data: Some(data),
        error: None,
    };
    Ok((status, Json(body)).into_response())
}

/// Erreur métier de SurrealQL : définition relue dans la langue de la requête, détails
/// d'origine conservés ; toute autre erreur de la base : rien.
async fn business(
    context: &AppContext,
    error: &LyxalSurrealError,
    language: &str,
) -> Option<LyxalError> {
    let LyxalSurrealError::Call(LyxalCallError::Business(business)) = error else {
        return None;
    };
    Some(match resolve(context, &business.code, language).await {
        Some(mut localized) => {
            localized.details = business.details.clone();
            localized
        }
        None => business.clone(),
    })
}

/// Erreur rendue au client : définition de master data résolue par la base pour un code
/// `AUTH_*` ou `STORAGE_*` ; erreur de l'hôte sinon. Aucun détail interne.
pub(super) async fn render_error(
    context: &AppContext,
    error: ApiError,
    language: &str,
) -> Response {
    let trace_id = request_id::current();
    let (resolved, code, message) = match &error {
        ApiError::Server(_) => (None, String::new(), String::new()),
        ApiError::Auth(error) => {
            let resolved = match error {
                AuthError::Surreal(inner) => business(context, inner, language).await,
                AuthError::Rejected(code) => resolve(context, code, language).await,
                AuthError::InvalidParameter(_) => {
                    resolve(context, "AUTH_INVALID_PARAMETERS", language).await
                }
                AuthError::Crypto(_) | AuthError::Dns(_) => None,
            };
            (resolved, error.code().to_string(), error.to_string())
        }
        ApiError::Storage(error) => {
            let resolved = match error {
                StorageError::Surreal(inner) => business(context, inner, language).await,
                // Erreurs du service Rust : leur définition est dans la master data du module
                _ => resolve(context, &error.code(), language).await,
            };
            (resolved, error.code(), error.to_string())
        }
    };
    if let ApiError::Server(error) = error {
        return error.into_response();
    }
    let Some(mut resolved) = resolved else {
        tracing::error!(trace_id = %trace_id, code = %code, error = %message, "requête en échec");
        return ServerError::Database { message }.into_response();
    };
    tracing::info!(trace_id = %trace_id, code = %resolved.code, "requête refusée");
    resolved.details = json!({ "trace_id": trace_id, "fields": resolved.details.get("fields").cloned().unwrap_or(Value::Null) });
    let status = resolved
        .http_status
        .and_then(|code| StatusCode::from_u16(code).ok())
        .unwrap_or(StatusCode::BAD_REQUEST);
    let body: LyxalResult<Value> = LyxalResult {
        ok: false,
        data: None,
        error: Some(resolved),
    };
    (status, Json(body)).into_response()
}

#[derive(SurrealValue)]
struct Resolved {
    error: Option<LyxalError>,
}

async fn resolve(context: &AppContext, code: &str, language: &str) -> Option<LyxalError> {
    let mut response = context
        .database
        .query("RETURN fn::error_result($code, $language, {})")
        .bind(("code", code.to_string()))
        .bind(("language", language.to_string()))
        .await
        .ok()?;
    let resolved: Option<Resolved> = response.take(0).ok()?;
    resolved?.error
}

/// Langue des messages, choisie par `fn::i18n_locale_resolve` parmi les langues de l'appelant
/// (identité, puis organisation active) et celles de `Accept-Language` (par poids) ; langue par
/// défaut de l'installation si aucune n'est active.
pub(super) async fn language(
    context: &AppContext,
    headers: &HeaderMap,
) -> Result<String, ApiError> {
    let mut candidates = caller_locales(context, headers).await?;
    if let Some(header) = headers.get("accept-language").and_then(|v| v.to_str().ok()) {
        candidates.extend(accept_language::candidates(header));
    }
    candidates.truncate(accept_language::MAX_CANDIDATES);
    let resolved = I18nStore::new(context.database.as_ref().clone())
        .locale_resolve(LocaleResolveParams {
            candidates,
            language: None,
        })
        .await
        .map_err(|error| {
            ApiError::Server(ServerError::Database {
                message: format!("choix de la langue : {error}"),
            })
        })?;
    Ok(resolved.language)
}

/// Langues de l'appelant : trait `locale` de l'identité du jeton, puis langue de son organisation
/// active. Pas de jeton, jeton refusé, identité ou organisation introuvable : rien ; une panne
/// (transport, désérialisation, cryptographie) est propagée.
async fn caller_locales(
    context: &AppContext,
    headers: &HeaderMap,
) -> Result<Vec<String>, ApiError> {
    let Some(host) = context.auth.clone() else {
        return Ok(Vec::new());
    };
    let caller = match caller(&host, headers).await {
        Ok(caller) => caller,
        Err(error) if is_refusal(&error) => return Ok(Vec::new()),
        Err(error) => return Err(error),
    };
    let store = host.access.store();
    let mut locales = Vec::new();
    if let Some(identity) = caller.identity {
        let found = store
            .identity_get(IdentityGetParams {
                identity: identity.to_sql(),
            })
            .await;
        if let Some(identity) = absent_if_refused(found)? {
            if let Some(locale) = identity.traits.into_json_value()["locale"].as_str() {
                locales.push(locale.to_string());
            }
        }
    }
    if let Some(organization) = caller.organization {
        let found = store
            .organization_get(OrganizationGetParams {
                organization: Some(organization.to_sql()),
                slug: None,
            })
            .await;
        if let Some(locale) = absent_if_refused(found)?.and_then(|o| o.locale) {
            locales.push(locale);
        }
    }
    Ok(locales)
}

/// Erreur métier (introuvable, refusé) : absent ; toute autre erreur est propagée.
fn absent_if_refused<T>(result: Result<T, LyxalSurrealError>) -> Result<Option<T>, ApiError> {
    match result {
        Ok(found) => Ok(Some(found)),
        Err(LyxalSurrealError::Call(LyxalCallError::Business(_))) => Ok(None),
        Err(error) => Err(ApiError::Auth(AuthError::Surreal(Box::new(error)))),
    }
}

/// Refus décidé par le service ou la base (code `AUTH_*`), par opposition à une panne.
fn is_refusal(error: &ApiError) -> bool {
    match error {
        ApiError::Auth(AuthError::Rejected(_) | AuthError::InvalidParameter(_)) => true,
        ApiError::Auth(AuthError::Surreal(error)) => matches!(
            error.as_ref(),
            LyxalSurrealError::Call(LyxalCallError::Business(_))
        ),
        _ => false,
    }
}

/// Contexte client : adresse (derrière un proxy de confiance, lue dans `X-Forwarded-For`, cf.
/// `crate::net`) et agent utilisateur.
pub(super) fn client_info(
    context: &AppContext,
    headers: &HeaderMap,
    address: Option<ConnectInfo<SocketAddr>>,
) -> ClientInfo {
    let forwarded_for = headers.get("x-forwarded-for").and_then(|v| v.to_str().ok());
    ClientInfo {
        ip: address.map(|ConnectInfo(address)| {
            crate::net::client_ip(
                address.ip(),
                forwarded_for,
                &context.config.server.trusted_proxies,
            )
            .to_string()
        }),
        user_agent: headers
            .get("user-agent")
            .and_then(|v| v.to_str().ok())
            .map(|v| v.chars().take(512).collect()),
    }
}

pub(super) fn host(context: &AppContext) -> Result<Arc<AuthHost>, ApiError> {
    context
        .auth
        .clone()
        .ok_or(ApiError::Server(ServerError::AuthDisabled))
}

pub(super) fn secret(value: String) -> Result<SecretString, ApiError> {
    SecretString::new(value)
        .map_err(|_| ApiError::Auth(AuthError::Rejected("AUTH_INVALID_PARAMETERS")))
}

pub(super) fn tokens_json(tokens: &IssuedTokens) -> Value {
    json!({
        "status": "authenticated",
        "token_type": "Bearer",
        "access_token": tokens.access_token.expose_secret(),
        "refresh_token": tokens.refresh_token.as_ref().map(|t| t.expose_secret().to_string()),
        "expires_in": tokens.expires_in,
        "session": tokens.session.session.to_sql(),
        "organization": tokens.session.organization.as_ref().map(|o| o.to_sql()),
        "permissions": tokens.session.permissions,
    })
}

pub(super) fn outcome_json(outcome: &LoginOutcome) -> Value {
    match outcome {
        LoginOutcome::Authenticated(tokens) => tokens_json(tokens),
        LoginOutcome::ActionRequired { flow, actions } => json!({
            "status": "action_required",
            "flow": flow,
            "actions": actions,
        }),
        LoginOutcome::MfaRequired { flow, methods } => json!({
            "status": "mfa_required",
            "flow": flow,
            "methods": methods,
        }),
    }
}

/// Appelant du jeton d'accès (`Authorization: Bearer`).
pub(super) async fn caller(
    host: &AuthHost,
    headers: &HeaderMap,
) -> Result<SessionCaller, ApiError> {
    let token = headers
        .get("authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "))
        .ok_or(ApiError::Auth(AuthError::Rejected("AUTH_SESSION_REQUIRED")))?;
    Ok(host
        .access
        .authenticate(&secret(token.to_string())?)
        .await?)
}

/// Appelant d'une route de gestion de son compte (sessions, mot de passe, adresses,
/// organisation active) : session **interactive** d'une identité. Une session de clé d'API ou
/// de compte de service n'y a pas accès, quelles que soient ses permissions : une clé limitée
/// à quelques droits ne doit pas pouvoir gérer le compte de son propriétaire.
pub(super) async fn identity_of(
    host: &AuthHost,
    headers: &HeaderMap,
) -> Result<(SessionCaller, String), ApiError> {
    let caller = caller(host, headers).await?;
    if caller.kind != "interactive" {
        return Err(ApiError::Auth(AuthError::Rejected(
            "AUTH_PERMISSION_DENIED",
        )));
    }
    let identity = caller
        .identity
        .as_ref()
        .map(|id| id.to_sql())
        .ok_or(ApiError::Auth(AuthError::Rejected(
            "AUTH_PERMISSION_DENIED",
        )))?;
    Ok((caller, identity))
}

/// Exécute une route et rend son erreur éventuelle.
pub(super) async fn respond(
    context: &AppContext,
    headers: &HeaderMap,
    result: ApiResult,
) -> Response {
    match result {
        Ok(response) => response,
        Err(error) => match language(context, headers).await {
            Ok(language) => render_error(context, error, &language).await,
            // Panne pendant la lecture de la langue : elle est rendue (et journalisée) à la
            // place de l'erreur d'origine, journalisée ici ; langue des définitions faute de mieux
            Err(failure) => {
                let original = match &error {
                    ApiError::Auth(error) => error.to_string(),
                    ApiError::Storage(error) => error.to_string(),
                    ApiError::Server(error) => error.to_string(),
                };
                tracing::warn!(error = %original, "erreur d'origine remplacée par une panne de lecture de la langue");
                render_error(context, failure, "fr").await
            }
        },
    }
}

fn proof(
    flow: Option<String>,
    code: Option<String>,
    token: Option<String>,
) -> Result<CodeProof, ApiError> {
    match (flow, code, token) {
        (_, _, Some(token)) => Ok(CodeProof::Link(secret(token)?)),
        (Some(flow), Some(code), None) => Ok(CodeProof::Code {
            flow,
            code: secret(code)?,
        }),
        _ => Err(ApiError::Auth(AuthError::Rejected(
            "AUTH_INVALID_PARAMETERS",
        ))),
    }
}

// ----------------------------------------------------------------------------------------------
// Connexion et sessions
// ----------------------------------------------------------------------------------------------

#[derive(Deserialize)]
struct LoginBody {
    identifier: String,
    password: String,
    organization: Option<String>,
}

async fn login(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<LoginBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let outcome = host
            .access
            .login(LoginRequest {
                identifier: body.identifier,
                password: secret(body.password)?,
                organization: body.organization,
                client: client_info(&context, &headers, address),
            })
            .await?;
        ok(StatusCode::OK, outcome_json(&outcome))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct LoginActionsBody {
    new_password: Option<String>,
    #[serde(default)]
    accept_terms: bool,
}

async fn login_actions(
    State(context): State<AppContext>,
    Path(flow): Path<String>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<LoginActionsBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let outcome = host
            .access
            .complete_login_actions(
                &flow,
                LoginActions {
                    new_password: body.new_password.map(secret).transpose()?,
                    accept_terms: body.accept_terms,
                },
                client_info(&context, &headers, address),
            )
            .await?;
        ok(StatusCode::OK, outcome_json(&outcome))
    }
    .await;
    respond(&context, &headers, result).await
}

/// Code de vérification d'adresse pour un parcours de connexion qui attend `verify_email`.
async fn login_verification(
    State(context): State<AppContext>,
    Path(flow): Path<String>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let verification = host
            .access
            .start_login_verification(&flow, client_info(&context, &headers, address))
            .await?;
        ok(StatusCode::ACCEPTED, json!({ "flow": verification }))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct RefreshBody {
    refresh_token: String,
}

async fn refresh(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<RefreshBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let tokens = host.access.refresh(&secret(body.refresh_token)?).await?;
        ok(StatusCode::OK, tokens_json(&tokens))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn logout(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let caller = caller(&host, &headers).await?;
        host.access
            .revoke(&caller.session.to_sql(), "logout")
            .await?;
        ok(StatusCode::OK, json!({ "revoked": true }))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn sessions(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, identity) = identity_of(&host, &headers).await?;
        let sessions = host
            .access
            .store()
            .session_list(SessionListParams {
                limit: None,
                organization: None,
                identity: Some(identity),
            })
            .await
            .map_err(AuthError::from)?;
        let current = caller.session.to_sql();
        ok(
            StatusCode::OK,
            Value::Array(
                sessions
                    .iter()
                    .map(|s| {
                        json!({
                            "session": s.id.to_sql(),
                            "kind": s.kind,
                            "organization": s.organization.as_ref().map(|o| o.to_sql()),
                            "ip": s.client.ip,
                            "user_agent": s.client.user_agent,
                            "created_at": s.created_at.to_string(),
                            "last_seen_at": s.last_seen_at.to_string(),
                            "current": s.id.to_sql() == current,
                        })
                    })
                    .collect(),
            ),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn revoke_session(
    State(context): State<AppContext>,
    Path(session): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, identity) = identity_of(&host, &headers).await?;
        // Action sensible : AAL la plus haute disponible et authentification récente
        host.access.require_fresh(&caller.session.to_sql()).await?;
        // Une identité ne révoque que ses propres sessions
        let own = host
            .access
            .store()
            .session_list(SessionListParams {
                limit: None,
                organization: None,
                identity: Some(identity),
            })
            .await
            .map_err(AuthError::from)?;
        if !own.iter().any(|s| s.id.to_sql() == session) {
            return Err(ApiError::Auth(AuthError::Rejected(
                "AUTH_PERMISSION_DENIED",
            )));
        }
        host.access.revoke(&session, "revoked_by_owner").await?;
        ok(StatusCode::OK, json!({ "revoked": true }))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct SwitchBody {
    organization: Option<String>,
}

async fn switch_organization(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<SwitchBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let tokens = host
            .access
            .switch_organization(&caller.session.to_sql(), body.organization)
            .await?;
        ok(StatusCode::OK, tokens_json(&tokens))
    }
    .await;
    respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Inscription, récupération, vérification, adresse, mot de passe
// ----------------------------------------------------------------------------------------------

#[derive(Deserialize)]
struct RegistrationStartBody {
    token: String,
    #[serde(default)]
    setup: bool,
}

async fn registration_start(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<RegistrationStartBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let started = host
            .access
            .start_registration(
                &secret(body.token)?,
                body.setup,
                client_info(&context, &headers, address),
            )
            .await?;
        ok(
            StatusCode::OK,
            json!({
                "flow": started.flow.to_sql(),
                "email": started.email,
                "organization": started.organization.as_ref().map(|o| o.to_sql()),
                "kind": started.kind,
            }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct RegistrationCompleteBody {
    flow: String,
    password: String,
    #[serde(default)]
    traits: Value,
}

async fn registration_complete(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<RegistrationCompleteBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let traits = if body.traits.is_null() {
            json!({})
        } else {
            body.traits
        };
        let outcome = host
            .access
            .complete_registration(
                &body.flow,
                traits.into_value(),
                &secret(body.password)?,
                client_info(&context, &headers, address),
            )
            .await?;
        // Identité créée : session ouverte, ou double facteur à configurer avant
        ok(StatusCode::CREATED, outcome_json(&outcome))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct EmailBody {
    email: String,
}

async fn recovery_start(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<EmailBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let flow = host
            .access
            .start_recovery(&body.email, client_info(&context, &headers, address))
            .await?;
        // Même réponse que l'adresse existe ou non
        ok(StatusCode::ACCEPTED, json!({ "flow": flow }))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct ProofBody {
    flow: Option<String>,
    code: Option<String>,
    token: Option<String>,
    new_password: Option<String>,
}

async fn recovery_complete(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<ProofBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let password = secret(body.new_password.clone().unwrap_or_default())?;
        host.access
            .complete_recovery(proof(body.flow, body.code, body.token)?, &password)
            .await?;
        ok(StatusCode::OK, json!({ "completed": true }))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn verification_start(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (_, identity) = identity_of(&host, &headers).await?;
        let flow = host
            .access
            .start_verification(&identity, client_info(&context, &headers, address))
            .await?;
        ok(StatusCode::ACCEPTED, json!({ "flow": flow }))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn verification_complete(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<ProofBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        host.access
            .complete_verification(proof(body.flow, body.code, body.token)?)
            .await?;
        ok(StatusCode::OK, json!({ "completed": true }))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct AddressChangeBody {
    password: String,
    new_address: String,
}

async fn address_change_start(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<AddressChangeBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, identity) = identity_of(&host, &headers).await?;
        let flow = host
            .access
            .start_address_change(
                &identity,
                &caller.session.to_sql(),
                &secret(body.password)?,
                &body.new_address,
                client_info(&context, &headers, address),
            )
            .await?;
        ok(StatusCode::ACCEPTED, json!({ "flow": flow }))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn address_change_complete(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<ProofBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let address = host
            .access
            .complete_address_change(proof(body.flow, body.code, body.token)?)
            .await?;
        ok(StatusCode::OK, json!({ "address": address }))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct PasswordBody {
    current_password: String,
    new_password: String,
}

async fn change_password(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<PasswordBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, identity) = identity_of(&host, &headers).await?;
        host.access
            .change_password(
                &identity,
                &caller.session.to_sql(),
                &secret(body.current_password)?,
                &secret(body.new_password)?,
            )
            .await?;
        ok(StatusCode::OK, json!({ "changed": true }))
    }
    .await;
    respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Comptes de service et clés d'API
// ----------------------------------------------------------------------------------------------

#[derive(Deserialize)]
struct ServiceTokenBody {
    client_id: String,
    client_secret: String,
}

async fn service_token(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<ServiceTokenBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let tokens = host
            .access
            .service_token(
                &body.client_id,
                &secret(body.client_secret)?,
                client_info(&context, &headers, address),
            )
            .await?;
        ok(StatusCode::OK, tokens_json(&tokens))
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct ApiKeyBody {
    api_key: String,
}

async fn api_key_exchange(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<ApiKeyBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let tokens = host
            .access
            .api_key_token(
                &secret(body.api_key)?,
                client_info(&context, &headers, address),
            )
            .await?;
        ok(StatusCode::OK, tokens_json(&tokens))
    }
    .await;
    respond(&context, &headers, result).await
}
