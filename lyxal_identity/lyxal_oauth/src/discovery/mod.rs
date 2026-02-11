use crate::{OAuthResult, OAuthState};
use axum::{extract::State, Json};
use serde::{Deserialize, Serialize};

/// OpenID Connect Discovery Response
/// See: https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata
#[derive(Debug, Serialize, Deserialize)]
pub struct DiscoveryResponse {
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
    pub claims_supported: Vec<String>,
    pub token_endpoint_auth_methods_supported: Vec<String>,
}

/// Handler for the OIDC Discovery endpoint: GET /.well-known/openid-configuration
pub async fn get_discovery(
    State(state): State<OAuthState>,
) -> OAuthResult<Json<DiscoveryResponse>> {
    let config = &state.oauth_config;

    let response = DiscoveryResponse {
        issuer: config.issuer.clone(),
        authorization_endpoint: config.authorization_endpoint.clone(),
        token_endpoint: config.token_endpoint.clone(),
        userinfo_endpoint: config.userinfo_endpoint.clone(),
        jwks_uri: config.jwks_uri.clone(),
        registration_endpoint: None,
        scopes_supported: vec![
            "openid".to_string(),
            "profile".to_string(),
            "email".to_string(),
            "phone".to_string(),
            "offline_access".to_string(),
        ],
        response_types_supported: vec![
            "code".to_string(),
            "id_token".to_string(),
            "token id_token".to_string(),
        ],
        response_modes_supported: vec![
            "query".to_string(),
            "fragment".to_string(),
            "form_post".to_string(),
        ],
        grant_types_supported: vec![
            "authorization_code".to_string(),
            "refresh_token".to_string(),
            "client_credentials".to_string(),
            "urn:ietf:params:oauth:grant-type:device_code".to_string(),
        ],
        subject_types_supported: vec!["public".to_string()],
        id_token_signing_alg_values_supported: vec!["RS256".to_string()],
        claims_supported: vec![
            "sub".to_string(),
            "iss".to_string(),
            "auth_time".to_string(),
            "name".to_string(),
            "given_name".to_string(),
            "family_name".to_string(),
            "preferred_username".to_string(),
            "email".to_string(),
            "picture".to_string(),
        ],
        token_endpoint_auth_methods_supported: vec![
            "client_secret_basic".to_string(),
            "client_secret_post".to_string(),
            "none".to_string(),
        ],
    };

    Ok(Json(response))
}
