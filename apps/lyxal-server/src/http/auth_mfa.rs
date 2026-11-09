//! Routes du double facteur `/auth/*` (`lyxal_auth`, lot 4) : second facteur d'une connexion,
//! connexion sans mot de passe par passkey, gestion de ses facteurs (TOTP, passkeys, codes de
//! secours), réauthentification, remise à zéro par un administrateur.
//!
//! Gestion des facteurs : au nom de la session interactive du jeton (`Authorization: Bearer`),
//! ou, pour configurer le double facteur exigé avant toute session, au nom du parcours de
//! connexion (`login_flow` dans le corps). La base revérifie l'acteur, l'AAL et l'ancienneté de
//! l'authentification à chaque écriture.

use crate::context::AppContext;
use crate::http::auth::{
    caller, client_info, host, identity_of, ok, outcome_json, respond, secret, tokens_json,
    ApiError, ApiResult,
};
use crate::modules::auth::AuthHost;
use axum::extract::{ConnectInfo, Path, State};
use axum::http::{HeaderMap, StatusCode};
use axum::response::Response;
use axum::routing::{get, patch, post};
use axum::{Json, Router};
use lyxal_auth::models::{FactorRemoveParams, MfaResetParams, PasskeyRenameParams};
use lyxal_auth::{AccessService, AuthError, MfaActor, MfaProof, ReauthProof};
use lyxal_crypto::StaticKeyResolver;
use lyxal_surreal::ToSql;
use serde::Deserialize;
use serde_json::{json, Value};
use std::net::SocketAddr;

/// Routes du double facteur.
pub fn routes() -> Router<AppContext> {
    Router::new()
        .route("/flows/:flow/mfa", post(login_mfa))
        .route(
            "/flows/:flow/mfa/passkey/options",
            post(login_passkey_options),
        )
        .route("/passkey/login/options", post(passkey_login_options))
        .route("/passkey/login", post(passkey_login))
        .route("/mfa", get(factors))
        .route("/mfa/totp", post(totp_begin).delete(totp_remove))
        .route("/mfa/totp/confirm", post(totp_confirm))
        .route("/mfa/passkeys/options", post(passkey_registration_options))
        .route("/mfa/passkeys", post(passkey_register))
        .route(
            "/mfa/passkeys/:credential",
            patch(passkey_rename).delete(passkey_remove),
        )
        .route("/mfa/recovery-codes", post(recovery_codes))
        .route(
            "/session/reauthenticate/options",
            post(reauthenticate_options),
        )
        .route("/session/reauthenticate", post(reauthenticate))
        .route("/identities/:identity/mfa/reset", post(mfa_reset))
}

/// Second facteur présenté dans un corps JSON.
#[derive(Deserialize)]
struct ProofBody {
    /// `totp`, `recovery_code`, `passkey` (ou `password` pour une réauthentification).
    method: String,
    /// Code (TOTP ou de secours) ou mot de passe.
    code: Option<String>,
    /// Parcours qui garde le défi passkey.
    flow: Option<String>,
    /// Réponse WebAuthn du navigateur.
    response: Option<Value>,
}

fn invalid() -> ApiError {
    ApiError::Auth(AuthError::Rejected("AUTH_INVALID_PARAMETERS"))
}

fn mfa_proof(body: ProofBody, flow: Option<&str>) -> Result<MfaProof, ApiError> {
    match body.method.as_str() {
        "totp" => Ok(MfaProof::Totp(secret(body.code.ok_or_else(invalid)?)?)),
        "recovery_code" => Ok(MfaProof::RecoveryCode(secret(
            body.code.ok_or_else(invalid)?,
        )?)),
        "passkey" => Ok(MfaProof::Passkey {
            flow: flow.map(str::to_string).or(body.flow).ok_or_else(invalid)?,
            response: body.response.ok_or_else(invalid)?,
        }),
        _ => Err(invalid()),
    }
}

/// Acteur de la gestion des facteurs : parcours de connexion désigné, sinon session du jeton.
async fn actor(
    host: &AuthHost,
    headers: &HeaderMap,
    login_flow: Option<String>,
) -> Result<MfaActor, ApiError> {
    match login_flow {
        Some(flow) => Ok(host.access.login_actor(&flow).await?),
        None => {
            let caller = caller(host, headers).await?;
            Ok(AccessService::<StaticKeyResolver>::session_actor(&caller)?)
        }
    }
}

#[derive(Deserialize, Default)]
struct ActorBody {
    login_flow: Option<String>,
}

// ----------------------------------------------------------------------------------------------
// Connexion
// ----------------------------------------------------------------------------------------------

async fn login_mfa(
    State(context): State<AppContext>,
    Path(flow): Path<String>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<ProofBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let proof = mfa_proof(body, Some(&flow))?;
        let outcome = host
            .access
            .complete_login_mfa(&flow, proof, client_info(&context, &headers, address))
            .await?;
        ok(StatusCode::OK, outcome_json(&outcome))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn login_passkey_options(
    State(context): State<AppContext>,
    Path(flow): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let options = host.access.login_passkey_options(&flow).await?;
        ok(StatusCode::OK, json!({ "flow": flow, "options": options }))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn passkey_login_options(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let challenge = host.access.passkey_login_options().await?;
        ok(
            StatusCode::OK,
            json!({ "flow": challenge.flow, "options": challenge.options }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct PasskeyResponseBody {
    flow: String,
    response: Value,
    label: Option<String>,
    login_flow: Option<String>,
}

async fn passkey_login(
    State(context): State<AppContext>,
    address: Option<ConnectInfo<SocketAddr>>,
    headers: HeaderMap,
    Json(body): Json<PasskeyResponseBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let outcome = host
            .access
            .passkey_login(
                &body.flow,
                body.response,
                client_info(&context, &headers, address),
            )
            .await?;
        ok(StatusCode::OK, outcome_json(&outcome))
    }
    .await;
    respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Gestion de ses facteurs
// ----------------------------------------------------------------------------------------------

async fn factors(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let actor = actor(&host, &headers, None).await?;
        let factors = host.access.mfa().factors(&actor).await?;
        ok(
            StatusCode::OK,
            json!({
                "totp": factors.totp.as_ref().map(|t| json!({
                    "id": t.id.to_sql(),
                    "state": t.state,
                    "created_at": t.created_at.to_string(),
                    "last_used_at": t.last_used_at.as_ref().map(ToString::to_string),
                })),
                "passkeys": factors.passkeys.iter().map(|p| json!({
                    "id": p.id.to_sql(),
                    "label": p.label,
                    "created_at": p.created_at.to_string(),
                    "last_used_at": p.last_used_at.as_ref().map(ToString::to_string),
                    "synced": p.backup_state.unwrap_or(false),
                })).collect::<Vec<_>>(),
                "recovery_codes": factors.recovery_codes.as_ref().map(|r| json!({
                    "total": r.total,
                    "remaining": r.remaining,
                    "created_at": r.created_at.to_string(),
                })),
                "available_aal": factors.available_aal,
                "passkeys_enabled": host.access.mfa().passkeys_enabled(),
            }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn totp_begin(
    State(context): State<AppContext>,
    headers: HeaderMap,
    body: Option<Json<ActorBody>>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let body = body.map(|Json(b)| b).unwrap_or_default();
        let actor = actor(&host, &headers, body.login_flow).await?;
        let enrollment = host.access.mfa().totp_begin(&actor).await?;
        ok(
            StatusCode::OK,
            json!({
                "credential": enrollment.credential,
                "otpauth_uri": enrollment.otpauth_uri.expose_secret(),
            }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct CodeBody {
    code: String,
    login_flow: Option<String>,
}

async fn totp_confirm(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<CodeBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let actor = actor(&host, &headers, body.login_flow).await?;
        let activated = host.access.mfa().totp_confirm(&actor, &secret(body.code)?).await?;
        ok(
            StatusCode::OK,
            json!({ "credential": activated.credential.to_sql(), "recovery_codes": activated.recovery_codes }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn totp_remove(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let removed = host
            .access
            .store()
            .mfa_factor_remove(FactorRemoveParams {
                session: caller.session.to_sql(),
                credential: None,
                method: "totp".to_string(),
            })
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            json!({ "removed": removed.removed.to_sql(), "available_aal": removed.available_aal }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn passkey_registration_options(
    State(context): State<AppContext>,
    headers: HeaderMap,
    body: Option<Json<ActorBody>>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let body = body.map(|Json(b)| b).unwrap_or_default();
        let actor = actor(&host, &headers, body.login_flow).await?;
        let challenge = host
            .access
            .mfa()
            .passkey_registration_options(&actor)
            .await?;
        ok(
            StatusCode::OK,
            json!({ "flow": challenge.flow, "options": challenge.options }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn passkey_register(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<PasskeyResponseBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let actor = actor(&host, &headers, body.login_flow).await?;
        let saved = host
            .access
            .mfa()
            .passkey_register(&actor, &body.flow, body.response, body.label)
            .await?;
        ok(
            StatusCode::CREATED,
            json!({ "credential": saved.credential.to_sql(), "label": saved.label }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

#[derive(Deserialize)]
struct LabelBody {
    label: String,
}

async fn passkey_rename(
    State(context): State<AppContext>,
    Path(credential): Path<String>,
    headers: HeaderMap,
    Json(body): Json<LabelBody>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let renamed = host
            .access
            .store()
            .mfa_passkey_rename(PasskeyRenameParams {
                session: caller.session.to_sql(),
                credential,
                label: body.label,
            })
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            json!({ "credential": renamed.credential.to_sql(), "label": renamed.label }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn passkey_remove(
    State(context): State<AppContext>,
    Path(credential): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let removed = host
            .access
            .store()
            .mfa_factor_remove(FactorRemoveParams {
                session: caller.session.to_sql(),
                credential: Some(credential),
                method: "passkey".to_string(),
            })
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            json!({ "removed": removed.removed.to_sql(), "available_aal": removed.available_aal }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn recovery_codes(
    State(context): State<AppContext>,
    headers: HeaderMap,
    body: Option<Json<ActorBody>>,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let body = body.map(|Json(b)| b).unwrap_or_default();
        let actor = actor(&host, &headers, body.login_flow).await?;
        let codes = host.access.mfa().recovery_codes(&actor).await?;
        // Affichés une seule fois : seule leur empreinte est conservée
        ok(
            StatusCode::OK,
            json!({ "codes": codes.iter().map(|c| c.expose_secret().to_string()).collect::<Vec<_>>() }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

// ----------------------------------------------------------------------------------------------
// Réauthentification et remise à zéro
// ----------------------------------------------------------------------------------------------

async fn reauthenticate_options(State(context): State<AppContext>, headers: HeaderMap) -> Response {
    let result = async {
        let host = host(&context)?;
        let caller = caller(&host, &headers).await?;
        let challenge = host.access.reauthenticate_options(&caller).await?;
        ok(
            StatusCode::OK,
            json!({ "flow": challenge.flow, "options": challenge.options }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}

async fn reauthenticate(
    State(context): State<AppContext>,
    headers: HeaderMap,
    Json(body): Json<ProofBody>,
) -> Response {
    let result: ApiResult = async {
        let host = host(&context)?;
        let caller = caller(&host, &headers).await?;
        let proof = if body.method == "password" {
            ReauthProof::Password(secret(body.code.ok_or_else(invalid)?)?)
        } else {
            ReauthProof::Mfa(mfa_proof(body, None)?)
        };
        let tokens = host.access.reauthenticate(&caller, proof).await?;
        ok(StatusCode::OK, tokens_json(&tokens))
    }
    .await;
    respond(&context, &headers, result).await
}

async fn mfa_reset(
    State(context): State<AppContext>,
    Path(identity): Path<String>,
    headers: HeaderMap,
) -> Response {
    let result = async {
        let host = host(&context)?;
        let (caller, _) = identity_of(&host, &headers).await?;
        let reset = host
            .access
            .store()
            .mfa_reset(MfaResetParams {
                session: caller.session.to_sql(),
                identity,
            })
            .await
            .map_err(AuthError::from)?;
        ok(
            StatusCode::OK,
            json!({ "identity": reset.identity.to_sql(), "removed": reset.removed, "sessions_revoked": reset.sessions_revoked }),
        )
    }
    .await;
    respond(&context, &headers, result).await
}
