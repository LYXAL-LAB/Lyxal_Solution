use axum::extract::{Path, Query, State};
use axum::routing::get;
use axum::Json;
use axum::Router;

use crate::contracts::oauth::{
    OAuthAuthorizeResponse, OAuthCallbackQuery, OAuthCallbackResponse, OAuthProviderResponse,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/providers", get(list_oauth_providers))
        .route("/authorize/{provider}", get(initiate_authorize))
        .route("/callback/{provider}", get(handle_callback))
}

pub fn validate_oauth_provider(provider: &str) -> Result<(), WebError> {
    let clean = provider.trim().to_lowercase();
    if clean != "google" && clean != "outlook" && clean != "bluemind" && clean != "nextcloud" {
        return Err(WebError::BadRequest(
            "INVALID_OAUTH_PROVIDER: Provider must be google, outlook, bluemind, or nextcloud".to_string(),
        ));
    }
    Ok(())
}

pub async fn list_oauth_providers(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
) -> Result<Json<Vec<OAuthProviderResponse>>, WebError> {
    let providers = crate::services::oauth::list_oauth_providers(&state.store)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to list OAuth providers: {}", e)))?;

    Ok(Json(providers))
}

pub async fn initiate_authorize(
    State(state): State<AppState>,
    _auth: AuthenticatedUser,
    Path(provider): Path<String>,
) -> Result<Json<OAuthAuthorizeResponse>, WebError> {
    validate_oauth_provider(&provider)?;

    let response = crate::services::oauth::initiate_auth(&state.store, &provider)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to initiate OAuth: {}", e)))?;

    Ok(Json(response))
}

pub async fn handle_callback(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(provider): Path<String>,
    Query(query): Query<OAuthCallbackQuery>,
) -> Result<Json<OAuthCallbackResponse>, WebError> {
    validate_oauth_provider(&provider)?;

    if query.state.trim().is_empty() {
        return Err(WebError::BadRequest("INVALID_OAUTH_STATE: State parameter is required".to_string()));
    }

    let response = crate::services::oauth::handle_callback(
        &state.store,
        &state.crypto,
        &auth,
        &provider,
        &query,
    )
    .await
    .map_err(|e| WebError::BadRequest(format!("OAuth callback error: {}", e)))?;

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_oauth_provider() {
        assert!(validate_oauth_provider("google").is_ok());
        assert!(validate_oauth_provider("outlook").is_ok());
        assert!(validate_oauth_provider("invalid").is_err());
    }

    #[test]
    fn test_validate_redirect_url_safe() {
        use crate::services::oauth::validate_redirect_url;
        assert_eq!(validate_redirect_url("/calendars").unwrap(), "/calendars");
        assert_eq!(validate_redirect_url("https://attacker.com").unwrap(), "/settings/integrations");
    }
}
