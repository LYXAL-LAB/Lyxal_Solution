use axum::extract::State;
use axum::routing::get;
use axum::Json;
use axum::Router;

use crate::contracts::settings::{
    GetUserSettingsParams, UpdateUserSettingsParams, UpdateUserSettingsRequest,
    UserSettingsResponse,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(get_settings).patch(update_settings))
}

pub async fn get_settings(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<UserSettingsResponse>, WebError> {
    let response = crate::services::settings::get_user_settings(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to fetch settings: {}", e)))?;

    Ok(Json(response))
}

pub async fn update_settings(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<UpdateUserSettingsRequest>,
) -> Result<Json<UserSettingsResponse>, WebError> {
    if request.name.trim().is_empty() {
        return Err(WebError::BadRequest("User name cannot be empty".to_string()));
    }

    if request.name.len() > 100 {
        return Err(WebError::BadRequest("User name is too long (max 100 chars)".to_string()));
    }

    if request.timezone.parse::<chrono_tz::Tz>().is_err() {
        return Err(WebError::BadRequest(format!("Invalid timezone: {}", request.timezone)));
    }

    let response = crate::services::settings::update_user_settings(&state.store, &auth, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to update settings: {}", e)))?;

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_name_validation() {
        let req = UpdateUserSettingsRequest {
            name: "   ".to_string(),
            timezone: "Europe/Paris".to_string(),
        };
        assert!(req.name.trim().is_empty());
    }

    #[test]
    fn test_oversized_name_validation() {
        let req = UpdateUserSettingsRequest {
            name: "a".repeat(101),
            timezone: "Europe/Paris".to_string(),
        };
        assert!(req.name.len() > 100);
    }

    #[test]
    fn test_invalid_timezone_validation() {
        let req = UpdateUserSettingsRequest {
            name: "Alice".to_string(),
            timezone: "Invalid/Timezone_Name".to_string(),
        };
        assert!(req.timezone.parse::<chrono_tz::Tz>().is_err());
    }

    #[test]
    fn test_valid_timezone_validation() {
        let req = UpdateUserSettingsRequest {
            name: "Alice".to_string(),
            timezone: "Europe/Paris".to_string(),
        };
        assert!(req.timezone.parse::<chrono_tz::Tz>().is_ok());
    }
}
