//! Lyxal OAuth2/OIDC Module - 1:1 Logto Mapping
//! Implements the standard OpenID Connect and OAuth 2.1 endpoints.

pub mod discovery;
pub mod endpoints;
pub mod grants;
pub mod oidc;
pub mod tokens;

use axum::{routing::{get, post}, Router};
use std::sync::Arc;
use lyxal_core::LyxalConfig;
use crate::tokens::jwks::JwksService;
use crate::tokens::jwt::JwtService;
use lyxal_iam::services::user_service::UserService;
use axum::Extension;

/// 1:1 OIDC Endpoints supported by Logto
pub fn router(
    user_service: Arc<UserService>,
    config: LyxalConfig
) -> Router {
    let jwks_service = Arc::new(JwksService::new("lyxal-key-1".to_string()));
    let jwt_service = Arc::new(JwtService::new(&config.jwt_secret, &config.issuer_url));

    Router::new()
        // OIDC Discovery
        .route("/.well-known/openid-configuration", get(discovery::get_oidc_config))
        .route("/.well-known/jwks.json", get(tokens::get_jwks))
        
        // Core OAuth2/OIDC Endpoints
        .route("/oidc/auth", get(endpoints::authorize))
        .route("/oidc/token", post(endpoints::token))
        .route("/oidc/me", get(endpoints::userinfo))
        
        // Additional Logto-compatible Endpoints
        .route("/oidc/revoke", post(endpoints::revoke))
        .route("/oidc/introspection", post(endpoints::introspection))
        .route("/oidc/session/end", get(endpoints::end_session))
        .layer(Extension(user_service))
        .layer(Extension(jwks_service))
        .layer(Extension(jwt_service))
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, utoipa::ToSchema)]
#[serde(rename_all = "camelCase")]
pub struct OidcConfig {
    pub issuer: String,
    pub authorization_endpoint: String,
    pub token_endpoint: String,
    pub userinfo_endpoint: String,
    pub jwks_uri: String,
    pub registration_endpoint: Option<String>,
    pub scopes_supported: Vec<String>,
    pub response_types_supported: Vec<String>,
    pub response_modes_supported: Vec<String>,
    pub grant_types_supported: Vec<String>,
    pub subject_types_supported: Vec<String>,
    pub id_token_signing_alg_values_supported: Vec<String>,
    pub token_endpoint_auth_methods_supported: Vec<String>,
    pub claims_supported: Vec<String>,
}
