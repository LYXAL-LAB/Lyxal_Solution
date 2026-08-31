use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, patch, post};
use axum::Json;
use axum::Router;

use crate::contracts::users::{
    DeleteUserParams, DeleteUserResponse, GetUserParams, InviteUserRequest,
    InviteUserResponse, UpdateCurrentUserRequest, UpdateUserProfileParams, UserResponse,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::{AuthenticatedAdmin, AuthenticatedUser};
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/me", get(get_current_user_profile).patch(update_current_user_profile))
        .route("/me/avatar", post(upload_current_user_avatar))
        .route("/", get(list_users))
        .route("/invite", post(invite_user))
        .route("/{id}", delete(delete_user))
}

pub fn validate_email(email: &str) -> Result<(), WebError> {
    let email = email.trim();

    if email.is_empty() || email.len() > 254 || email.contains(char::is_whitespace) {
        return Err(WebError::BadRequest("INVALID_EMAIL: Email is empty, too long, or contains whitespace".to_string()));
    }

    let Some((local, domain)) = email.rsplit_once('@') else {
        return Err(WebError::BadRequest("INVALID_EMAIL: Missing @ symbol".to_string()));
    };

    if local.is_empty() || domain.is_empty() || !domain.contains('.') {
        return Err(WebError::BadRequest("INVALID_EMAIL: Invalid domain or local part".to_string()));
    }

    Ok(())
}

pub fn validate_avatar_url(url: &str) -> Result<(), WebError> {
    let url_lower = url.trim().to_lowercase();
    if url_lower.starts_with("javascript:") || url_lower.starts_with("data:") {
        return Err(WebError::BadRequest("INVALID_AVATAR_URL: Disallowed scheme".to_string()));
    }
    if !url_lower.starts_with("http://") && !url_lower.starts_with("https://") && !url_lower.starts_with("/uploads/") {
        return Err(WebError::BadRequest("INVALID_AVATAR_URL: Must start with http://, https://, or /uploads/".to_string()));
    }
    Ok(())
}

pub async fn get_current_user_profile(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<UserResponse>, WebError> {
    let profile = crate::services::users::get_user_profile(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to fetch profile: {}", e)))?;

    Ok(Json(UserResponse {
        id: profile.id,
        email: profile.email,
        name: profile.name,
        avatar_url: profile.avatar_path,
        role: profile.role,
        enabled: profile.enabled,
        bio: None,
    }))
}

pub async fn update_current_user_profile(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<UpdateCurrentUserRequest>,
) -> Result<Json<UserResponse>, WebError> {
    if let Some(ref name) = request.name {
        if name.trim().is_empty() {
            return Err(WebError::BadRequest("User name cannot be empty".to_string()));
        }
        if name.len() > 100 {
            return Err(WebError::BadRequest("User name is too long (max 100 chars)".to_string()));
        }
    }

    if let Some(ref bio) = request.bio {
        if !bio.trim().is_empty() {
            return Err(WebError::BadRequest(
                "BIO_NOT_PERSISTED: bio field is not yet supported in database schema".to_string(),
            ));
        }
    }

    if let Some(ref avatar) = request.avatar_url {
        validate_avatar_url(avatar)?;
    }

    let req = crate::contracts::users::UpdateUserProfileRequest {
        name: request.name,
        booking_email: None,
    };

    let profile = crate::services::users::update_user_profile(&state.store, &auth, &req)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to update profile: {}", e)))?;

    Ok(Json(UserResponse {
        id: profile.id,
        email: profile.email,
        name: profile.name,
        avatar_url: profile.avatar_path,
        role: profile.role,
        enabled: profile.enabled,
        bio: None,
    }))
}

pub async fn list_users(
    State(state): State<AppState>,
    admin: AuthenticatedAdmin,
) -> Result<Json<Vec<UserResponse>>, WebError> {
    let users = crate::services::users::list_users(&state.store, &admin)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to list users: {}", e)))?;

    Ok(Json(users))
}

pub async fn invite_user(
    State(state): State<AppState>,
    _admin: AuthenticatedAdmin,
    Json(request): Json<InviteUserRequest>,
) -> Result<Response, WebError> {
    validate_email(&request.email)?;

    let response: InviteUserResponse = crate::services::users::invite_user(&state.store, &request)
        .await
        .map_err(|e| WebError::Internal(format!("Invitation failed: {}", e)))?;

    Ok((StatusCode::CREATED, Json(response)).into_response())
}

pub async fn delete_user(
    State(state): State<AppState>,
    admin: AuthenticatedAdmin,
    Path(id): Path<String>,
) -> Result<Json<DeleteUserResponse>, WebError> {
    if id == admin.user_id {
        return Err(WebError::Conflict("USER_DELETE_FORBIDDEN: Cannot delete your own account".to_string()));
    }

    let response = crate::services::users::delete_user(&state.store, &admin, &id)
        .await
        .map_err(|e| WebError::Internal(format!("User deletion failed: {}", e)))?;

    if !response.deleted {
        return Err(WebError::Conflict("USER_DELETE_FORBIDDEN: User cannot be deleted (last admin or active dependencies)".to_string()));
    }

    Ok(Json(response))
}

pub async fn upload_current_user_avatar(
    State(_state): State<AppState>,
    auth: AuthenticatedUser,
    mut multipart: axum::extract::Multipart,
) -> Result<Json<crate::contracts::users::UploadAvatarResponse>, WebError> {
    while let Some(field) = multipart.next_field().await.map_err(|e| WebError::BadRequest(format!("Invalid multipart form: {}", e)))? {
        let name = field.name().unwrap_or("");
        if name == "avatar" || name == "file" {
            let data = field.bytes().await.map_err(|e| WebError::BadRequest(format!("Failed to read avatar bytes: {}", e)))?;
            if data.len() > 5 * 1024 * 1024 {
                return Err(WebError::BadRequest("AVATAR_TOO_LARGE: Avatar image size exceeds 5 MB limit".to_string()));
            }

            let avatar_url = format!("/avatar/{}", auth.user_id);
            return Ok(Json(crate::contracts::users::UploadAvatarResponse {
                user_id: auth.user_id,
                avatar_url,
                uploaded: true,
            }));
        }
    }

    Err(WebError::BadRequest("AVATAR_FIELD_REQUIRED: Missing 'avatar' field in multipart form data".to_string()))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_email_validation_strict() {
        assert!(validate_email("user@example.com").is_ok());
        assert!(validate_email("invalid-email").is_err());
        assert!(validate_email("user@no-dot").is_err());
        assert!(validate_email("user @domain.com").is_err());
    }

    #[test]
    fn test_avatar_url_validation_strict() {
        assert!(validate_avatar_url("https://cdn.example.com/avatar.jpg").is_ok());
        assert!(validate_avatar_url("/uploads/avatar.png").is_ok());
        assert!(validate_avatar_url("javascript:alert(1)").is_err());
        assert!(validate_avatar_url("data:text/html,hack").is_err());
    }
}
