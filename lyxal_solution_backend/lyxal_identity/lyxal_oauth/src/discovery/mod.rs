use axum::{Json, response::IntoResponse};
use crate::OidcConfig;

pub async fn get_oidc_config() -> impl IntoResponse {
    let config = OidcConfig {
        issuer: "https://auth.lyxal.com".to_string(),
        authorization_endpoint: "https://auth.lyxal.com/oidc/auth".to_string(),
        token_endpoint: "https://auth.lyxal.com/oidc/token".to_string(),
        userinfo_endpoint: "https://auth.lyxal.com/oidc/me".to_string(),
        jwks_uri: "https://auth.lyxal.com/.well-known/jwks.json".to_string(),
        registration_endpoint: None,
        scopes_supported: vec!["openid", "profile", "email", "phone", "address", "offline_access"].into_iter().map(String::from).collect(),
        response_types_supported: vec!["code", "id_token", "token id_token"].into_iter().map(String::from).collect(),
        response_modes_supported: vec!["query", "fragment"].into_iter().map(String::from).collect(),
        grant_types_supported: vec!["authorization_code", "client_credentials", "refresh_token", "urn:ietf:params:oauth:grant-type:token-exchange"].into_iter().map(String::from).collect(),
        subject_types_supported: vec!["public"].into_iter().map(String::from).collect(),
        id_token_signing_alg_values_supported: vec!["RS256", "PS256", "ES256"].into_iter().map(String::from).collect(),
        token_endpoint_auth_methods_supported: vec!["client_secret_post", "client_secret_basic", "private_key_jwt"].into_iter().map(String::from).collect(),
        claims_supported: vec!["sub", "name", "email", "email_verified", "username", "picture"].into_iter().map(String::from).collect(),
    };
    Json(config)
}
