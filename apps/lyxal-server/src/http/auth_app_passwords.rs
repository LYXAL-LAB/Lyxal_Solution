//! Routes des mots de passe d'application `/auth/app-passwords` et
//! `/auth/identities/{identity}/app-passwords` (`lyxal_auth`, lot 1 du programme courrier,
//! agendas et contacts) : création (action sensible, mot de passe rendu une seule fois), liste,
//! permissions utilisables, journal des connexions et révocation par le titulaire ; liste et
//! révocation par un administrateur.
//!
//! Toutes les routes exigent le jeton d'une session **interactive** (`identity_of`) : une clé
//! d'API, un compte de service ou un mot de passe d'application n'y ont pas accès. Les lectures
//! passent par une session SurrealDB au nom de l'appelant (règles des tables) ; création et
//! révocation par la session système, qui transmet l'acteur dont la base revérifie les droits,
//! l'AAL et l'ancienneté de l'authentification. Aucune authentification HTTP Basic n'est
//! ajoutée à l'hôte (A15) : un mot de passe d'application n'ouvre pas l'API de la plateforme.

use crate::context::AppContext;
use crate::http::auth::{caller_session, host, identity_of, ok, respond, ApiError, ApiResult};
use axum::extract::{Path, Query, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::Response;
use axum::routing::get;
use axum::{Json, Router};
use lyxal_auth::models::{
    AppPasswordEligibleParams, AppPasswordListParams, AppPasswordSummary, AppPasswordUsesParams,
    AuthDatetime,
};
use lyxal_auth::{AppPasswordTarget, AuthError, AuthStore};
use lyxal_surreal::ToSql;
use serde::Deserialize;
use serde_json::{json, Value};

/// Routes des mots de passe d'application (montées sous `/auth`).
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route(
            "/app-passwords",
            get(list_own).post(create).delete(revoke_all_own),
        )
        .route("/app-passwords/permissions", get(eligible))
        .route(
            "/app-passwords/:app_password",
            axum::routing::delete(revoke_own),
        )
        .route("/app-passwords/:app_password/uses", get(uses))
        .route(
            "/identities/:identity/app-passwords",
            get(list_of).delete(revoke_all_of),
        )
        .route(
            "/identities/:identity/app-passwords/:app_password",
            axum::routing::delete(revoke_one_of),
        )
}

fn invalid() -> ApiError {
    ApiError::Auth(AuthError::Rejected("AUTH_INVALID_PARAMETERS"))
}

fn summary_json(summary: &AppPasswordSummary) -> Value {
    json!({
        "id": summary.id.to_sql(),
        "name": summary.name,
        "organization": summary.organization.to_sql(),
        "permissions": summary.permissions,
        "expires_at": summary.expires_at.as_ref().map(ToString::to_string),
        "state": summary.state,
        "last_used_at": summary.last_used_at.as_ref().map(ToString::to_string),
        "last_used_protocol": summary.last_used_protocol,
        "last_used_ip": summary.last_used_ip,
        "revoked_at": summary.revoked_at.as_ref().map(ToString::to_string),
        "revoked_reason": summary.revoked_reason,
        "created_at": summary.created_at.to_string(),
    })
}

/// Store au nom de l'appelant (session interactive exigée) : les règles des tables décident.
async fn person(context: &AppContext, headers: &HeaderMap) -> Result<AuthStore, ApiError> {
    identity_of(host(context)?.as_ref(), headers).await?;
    let (_, session) = caller_session(context, headers).await?;
    Ok(AuthStore::new(session))
}

async fn list(context: &AppContext, headers: &HeaderMap, identity: Option<String>) -> ApiResult {
    let store = person(context, headers).await?;
    let list = store
        .app_password_list(AppPasswordListParams {
            identity,
            organization: None,
        })
        .await
        .map_err(AuthError::from)?;
    ok(
        StatusCode::OK,
        Value::Array(list.iter().map(summary_json).collect()),
    )
}

/// `GET /app-passwords` : ses mots de passe d'application (sans secret).
async fn list_own(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = list(&context, &headers, None).await;
    respond(&context, &headers, result).await
}

/// `GET /identities/{identity}/app-passwords` : administrateur (installation, ou organisation
/// active pour les mots de passe de cette organisation).
async fn list_of(
    State(context): State<AppContext>,
    Path(identity): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = list(&context, &headers, Some(identity)).await;
    respond(&context, &headers, result).await
}

/// `GET /app-passwords/permissions` : permissions qu'il peut donner (aide de l'interface).
async fn eligible(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let store = person(&context, &headers).await?;
        let permissions = store
            .app_password_eligible(AppPasswordEligibleParams::default())
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            Value::Array(
                permissions
                    .into_iter()
                    .map(|p| {
                        json!({
                            "code": p.code,
                            "module": p.module,
                            "description": p.description.into_json_value(),
                        })
                    })
                    .collect(),
            ),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct CreateBody {
    name: String,
    permissions: Vec<String>,
    expires_at: Option<String>,
}

/// `POST /app-passwords` : action sensible ; le mot de passe n'est rendu qu'ici, une seule fois.
async fn create(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<CreateBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let expires_at = body
            .expires_at
            .map(|value| value.parse::<AuthDatetime>().map_err(|_| invalid()))
            .transpose()?;
        let issued = host
            .access
            .app_passwords()
            .create(&caller, &body.name, body.permissions, expires_at)
            .await?;
        ok(
            StatusCode::CREATED,
            json!({
                "app_password": summary_json(&issued.summary),
                "username": issued.username,
                "password": issued.password.expose_secret(),
            }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct UsesQuery {
    limit: Option<i64>,
}

/// `GET /app-passwords/{id}/uses` : journal des connexions (titulaire ou administrateur).
async fn uses(
    State(context): State<AppContext>,
    Path(app_password): Path<String>,
    Query(query): Query<UsesQuery>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let store = person(&context, &headers).await?;
        let uses = store
            .app_password_uses(AppPasswordUsesParams {
                app_password,
                limit: query.limit,
            })
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            Value::Array(
                uses.iter()
                    .map(|u| {
                        json!({
                            "protocol": u.protocol,
                            "ip": u.ip,
                            "client_name": u.client_name,
                            "first_seen_at": u.first_seen_at.to_string(),
                            "last_seen_at": u.last_seen_at.to_string(),
                            "count": u.count,
                        })
                    })
                    .collect(),
            ),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn revoke(context: &AppContext, headers: &HeaderMap, target: AppPasswordTarget) -> ApiResult {
    let host = host(context)?;
    let (caller, _) = identity_of(&host, headers).await?;
    let revoked = host.access.app_passwords().revoke(&caller, target).await?;
    ok(StatusCode::OK, json!({ "revoked": revoked }))
}

/// `DELETE /app-passwords/{id}` : révoque un de ses mots de passe (pas une action sensible).
async fn revoke_own(
    State(context): State<AppContext>,
    Path(app_password): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = revoke(&context, &headers, AppPasswordTarget::One(app_password)).await;
    respond(&context, &headers, result).await
}

/// `DELETE /app-passwords` : révoque tous ses mots de passe de l'organisation active (tous sans
/// organisation active).
async fn revoke_all_own(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, identity) = identity_of(&host, &headers).await?;
        let organization = caller.organization.as_ref().map(|o| o.to_sql());
        revoke(
            &context,
            &headers,
            AppPasswordTarget::Identity {
                identity,
                organization,
            },
        )
        .await
    }
    .await;
    respond(&context, &headers, result).await
}

/// `DELETE /identities/{identity}/app-passwords/{id}` : administrateur (action sensible). Le
/// mot de passe doit appartenir à l'identité du chemin et être visible de l'administrateur.
async fn revoke_one_of(
    State(context): State<AppContext>,
    Path((identity, app_password)): Path<(String, String)>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let store = person(&context, &headers).await?;
        let visible = store
            .app_password_list(AppPasswordListParams {
                identity: Some(identity),
                organization: None,
            })
            .await
            .map_err(AuthError::from)?;
        if !visible.iter().any(|a| a.id.to_sql() == app_password) {
            return Err(ApiError::Auth(AuthError::Rejected(
                "AUTH_APP_PASSWORD_NOT_FOUND",
            )));
        }
        revoke(&context, &headers, AppPasswordTarget::One(app_password)).await
    }
    .await;
    respond(&context, &headers, result).await
}

/// `DELETE /identities/{identity}/app-passwords` : administrateur (action sensible) ; un
/// administrateur d'organisation ne révoque que ceux de son organisation active.
async fn revoke_all_of(
    State(context): State<AppContext>,
    Path(identity): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = revoke(
        &context,
        &headers,
        AppPasswordTarget::Identity {
            identity,
            organization: None,
        },
    )
    .await;
    respond(&context, &headers, result).await
}
