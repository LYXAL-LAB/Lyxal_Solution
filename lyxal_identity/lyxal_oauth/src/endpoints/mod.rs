use crate::{OAuthResult, OAuthState};
use axum::{
    extract::{Query, State},
    http::StatusCode,
    response::{IntoResponse, Redirect, Response},
    Json,
};
use lyxal_core::CoreError;
use lyxal_session::AuthContext;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Request parameters for the /oidc/auth endpoint (Authorization Request)
/// See: https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest
#[derive(Debug, Deserialize, utoipa::ToSchema, utoipa::IntoParams)]
pub struct AuthorizeRequest {
    pub client_id: Uuid,
    pub response_type: String,
    pub scope: String,
    pub redirect_uri: String,
    pub state: Option<String>,
    pub nonce: Option<String>,
    pub code_challenge: Option<String>,
    pub code_challenge_method: Option<String>,
}

/// Request parameters for the /oidc/token endpoint (Token Request)
/// See: https://openid.net/specs/openid-connect-core-1_0.html#TokenRequest
#[derive(Debug, Deserialize, utoipa::ToSchema)]
pub struct TokenRequest {
    pub grant_type: String,
    pub code: Option<String>,
    pub redirect_uri: Option<String>,
    pub client_id: Option<Uuid>,
    pub client_secret: Option<String>,
    pub code_verifier: Option<String>,
    pub refresh_token: Option<String>,
}

/// Successful Token Response
#[derive(Debug, Serialize, utoipa::ToSchema)]
pub struct TokenResponse {
    pub access_token: String,
    pub token_type: String,
    pub expires_in: i64,
    pub id_token: Option<String>,
    pub refresh_token: Option<String>,
    pub scope: String,
}

/// OIDC JWKS endpoint
#[utoipa::path(
    get,
    path = "/oidc/jwks",
    responses(
        (status = 200, description = "JSON Web Key Set")
    ),
    tag = "OAuth2 / OIDC"
)]
pub async fn jwks(State(_state): State<OAuthState>) -> impl IntoResponse {
    // In a production environment, this would return the public keys
    // for RS256 signature verification.
    Json(serde_json::json!({
        "keys": []
    }))
}

/// OAuth2 Authorize endpoint
#[utoipa::path(
    get,
    path = "/oidc/auth",
    params(AuthorizeRequest),
    responses(
        (status = 302, description = "Redirect to client callback"),
        (status = 401, description = "Unauthorized")
    ),
    tag = "OAuth2 / OIDC"
)]
pub async fn authorize(
    State(_state): State<OAuthState>,
    auth_context: Option<axum::Extension<AuthContext>>,
    Query(params): Query<AuthorizeRequest>,
) -> OAuthResult<Response> {
    // 1. Check if user is authenticated
    let auth_ctx = match auth_context {
        Some(ctx) => ctx.0,
        None => {
            return Err(CoreError::Unauthorized(
                "User session required. Please log in first.".to_string(),
            ));
        }
    };

    // 2. Handle Authorization Code flow
    if params.response_type == "code" {
        let code = lyxal_core::Crypto::generate_random_token();

        tracing::info!(
            "OIDC: Generated code for user {} (Client: {})",
            auth_ctx.user_id,
            params.client_id
        );

        let mut redirect_url = format!("{}?code={}", params.redirect_uri, code);
        if let Some(state_param) = params.state {
            redirect_url.push_str(&format!("&state={}", state_param));
        }

        return Ok(Redirect::temporary(&redirect_url).into_response());
    }

    Err(CoreError::Validation(
        "Unsupported response_type. Only 'code' is supported currently.".to_string(),
    ))
}

/// OAuth2 Token endpoint
#[utoipa::path(
    post,
    path = "/oidc/token",
    request_body = TokenRequest,
    responses(
        (status = 200, description = "Tokens issued", body = TokenResponse),
        (status = 400, description = "Invalid grant")
    ),
    tag = "OAuth2 / OIDC"
)]
pub async fn token(
    State(state): State<OAuthState>,
    Json(payload): Json<TokenRequest>,
) -> OAuthResult<Json<TokenResponse>> {
    match payload.grant_type.as_str() {
        "authorization_code" => {
            let _code = payload
                .code
                .ok_or_else(|| CoreError::Validation("code is required".to_string()))?;

            // Replace with real user lookup from stored code in a real scenario
            let user_id = Uuid::new_v4();
            let client_id = payload
                .client_id
                .map(|id| id.to_string())
                .unwrap_or_else(|| "unknown".to_string());
            let scopes = vec!["openid".to_string(), "profile".to_string()];

            let access_token =
                state
                    .jwt_service
                    .generate_access_token(user_id, &client_id, scopes.clone(), 1)?;

            let id_token = state
                .jwt_service
                .generate_id_token(user_id, &client_id, None, 1)?;

            Ok(Json(TokenResponse {
                access_token,
                token_type: "Bearer".to_string(),
                expires_in: 3600,
                id_token: Some(id_token),
                refresh_token: Some(lyxal_core::Crypto::generate_random_token()),
                scope: scopes.join(" "),
            }))
        }
        "refresh_token" => Err(CoreError::Validation(
            "refresh_token grant not implemented yet".to_string(),
        )),
        _ => Err(CoreError::Validation("unsupported_grant_type".to_string())),
    }
}

/// OIDC UserInfo endpoint
#[utoipa::path(
    get,
    path = "/oidc/me",
    responses(
        (status = 200, description = "User claims")
    ),
    tag = "OAuth2 / OIDC",
    security(
        ("bearer_auth" = [])
    )
)]
pub async fn userinfo(
    State(_state): State<OAuthState>,
    auth_context: axum::Extension<AuthContext>,
) -> OAuthResult<impl IntoResponse> {
    Ok(Json(serde_json::json!({
        "sub": auth_context.user_id.to_string(),
        "name": "Lyxal User",
        "email_verified": true,
    })))
}

/// OAuth2 Token Introspection
#[utoipa::path(
    post,
    path = "/oidc/introspect",
    responses(
        (status = 501, description = "Not implemented")
    ),
    tag = "OAuth2 / OIDC"
)]
pub async fn introspect(State(_state): State<OAuthState>) -> impl IntoResponse {
    StatusCode::NOT_IMPLEMENTED
}

/// OAuth2 Token Revocation
#[utoipa::path(
    post,
    path = "/oidc/revoke",
    responses(
        (status = 501, description = "Not implemented")
    ),
    tag = "OAuth2 / OIDC"
)]
pub async fn revoke(State(_state): State<OAuthState>) -> impl IntoResponse {
    StatusCode::NOT_IMPLEMENTED
}
