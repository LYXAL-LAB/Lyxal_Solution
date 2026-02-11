//! Lyxal OAuth Module
//!
//! This module implements the OAuth 2.0 and OpenID Connect (OIDC) protocols.
//! It handles token issuance, validation, and various authorization flows.
//!
//! Inspired by Logto's OIDC implementation in `packages/core/src/oidc`.

pub mod discovery;
pub mod endpoints;
pub mod grants;
pub mod oidc;
pub mod tokens;

use axum::{
    routing::{get, post},
    Router,
};
use lyxal_core::LyxalConfig;
use std::sync::Arc;

pub use discovery::DiscoveryResponse;
pub use oidc::{IdTokenClaims, AccessTokenClaims};
pub use tokens::jwt::JwtService;

/// Standard OAuth2 response types
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ResponseType {
    Code,
    Token,
    IdToken,
}

/// Core configuration for the OAuth/OIDC provider
#[derive(Debug, Clone)]
pub struct OAuthConfig {
    pub issuer: String,
    pub jwks_uri: String,
    pub authorization_endpoint: String,
    pub token_endpoint: String,
    pub userinfo_endpoint: String,
}

/// Shared state for the OAuth module
#[derive(Clone)]
pub struct OAuthState {
    pub jwt_service: JwtService,
    pub config: Arc<LyxalConfig>,
    pub oauth_config: Arc<OAuthConfig>,
}

/// Creates the OAuth2/OIDC router
pub fn router(state: OAuthState) -> Router {
    Router::new()
        // OIDC Discovery
        .route("/.well-known/openid-configuration", get(discovery::get_discovery))
        .route("/oidc/jwks", get(endpoints::jwks))

        // OAuth2 Endpoints
        .route("/oidc/auth", get(endpoints::authorize))
        .route("/oidc/token", post(endpoints::token))
        .route("/oidc/me", get(endpoints::userinfo))
        .route("/oidc/introspect", post(endpoints::introspect))
        .route("/oidc/revoke", post(endpoints::revoke))

        .with_state(state)
}

/// Result type for OAuth operations
pub type OAuthResult<T> = Result<T, lyxal_core::CoreError>;
