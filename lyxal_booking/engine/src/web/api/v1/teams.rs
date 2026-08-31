use axum::extract::{Path, State};
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::routing::{delete, get, patch, post};
use axum::Json;
use axum::Router;
use surrealdb::RecordId;

use crate::contracts::teams::{
    AddTeamMemberParams, AddTeamMemberRequest, CreateTeamParams, CreateTeamRequest,
    DeleteTeamParams, DeleteTeamResponse, GetTeamParams, LeaveTeamParams, LeaveTeamResponse,
    ListUserTeamsParams, RemoveTeamMemberParams, RemoveTeamMemberResponse, TeamMemberResponse,
    TeamResponse, UpdateTeamMemberParams, UpdateTeamMemberRequest, UpdateTeamParams,
    UpdateTeamRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::web::WebError;
use crate::web::middleware::auth::AuthenticatedUser;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_user_teams).post(create_team))
        .route(
            "/{id}",
            get(get_team)
                .patch(update_team)
                .delete(delete_team),
        )
        .route("/{id}/leave", post(leave_team))
        .route("/{id}/members", get(get_team_members).post(add_team_member))
        .route(
            "/{id}/members/{user_id}",
            patch(update_team_member).delete(remove_team_member),
        )
}

pub fn parse_team_id(raw: &str) -> Result<RecordId, WebError> {
    let clean = raw.trim();

    if let Some((table, id)) = clean.split_once(':') {
        if table != "booking_team" || id.is_empty() {
            return Err(WebError::BadRequest(
                "INVALID_TEAM_ID: Expected booking_team:<id>".to_string(),
            ));
        }
        return Ok(RecordId::from(("booking_team", id)));
    }

    if clean.is_empty() {
        return Err(WebError::BadRequest(
            "INVALID_TEAM_ID: Team identifier is required".to_string(),
        ));
    }

    Ok(RecordId::from(("booking_team", clean)))
}

pub fn validate_team_name(name: &str) -> Result<(), WebError> {
    let clean = name.trim();
    if clean.is_empty() || clean.chars().count() > 100 {
        return Err(WebError::BadRequest(
            "INVALID_TEAM_NAME: Team name must be between 1 and 100 characters".to_string(),
        ));
    }
    if clean.chars().any(char::is_control) {
        return Err(WebError::BadRequest(
            "INVALID_TEAM_NAME: Team name contains invalid control characters".to_string(),
        ));
    }
    Ok(())
}

pub fn validate_team_role(role: &str) -> Result<(), WebError> {
    let clean = role.trim().to_lowercase();
    if clean != "owner" && clean != "admin" && clean != "member" {
        return Err(WebError::BadRequest(
            "INVALID_TEAM_ROLE: Role must be owner, admin, or member".to_string(),
        ));
    }
    Ok(())
}

pub async fn list_user_teams(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
) -> Result<Json<Vec<TeamResponse>>, WebError> {
    let teams = crate::services::teams::list_user_teams(&state.store, &auth)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(teams))
}

pub async fn create_team(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Json(request): Json<CreateTeamRequest>,
) -> Result<Response, WebError> {
    validate_team_name(&request.name)?;
    crate::web::api::v1::event_types::validate_slug(&request.slug)?;

    let team = crate::services::teams::create_team(&state.store, &auth, &request)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(team)).into_response())
}

pub async fn get_team(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<TeamResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;

    let team = crate::services::teams::get_team_details(&state.store, &auth, &team_rec)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(team))
}

pub async fn update_team(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<UpdateTeamRequest>,
) -> Result<Json<TeamResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;

    if request.name.is_none() && request.slug.is_none() {
        return Err(WebError::BadRequest(
            "NO_TEAM_FIELDS: At least one field (name or slug) must be updated".to_string(),
        ));
    }

    if let Some(ref name) = request.name {
        validate_team_name(name)?;
    }
    if let Some(ref slug) = request.slug {
        crate::web::api::v1::event_types::validate_slug(slug)?;
    }

    let team = crate::services::teams::update_team(&state.store, &auth, &team_rec, &request)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(team))
}

pub async fn delete_team(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<DeleteTeamResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;

    let response = crate::services::teams::delete_team(&state.store, &auth, &team_rec)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    if !response.deleted {
        return Err(WebError::Conflict(
            "TEAM_DELETE_FORBIDDEN: Team cannot be deleted (only owner can delete or active dependencies exist)".to_string(),
        ));
    }

    Ok(Json(response))
}

pub async fn leave_team(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<LeaveTeamResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;
    let response = crate::services::teams::leave_team(&state.store, &auth, &team_rec)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    if !response.left {
        return Err(WebError::Conflict(
            "TEAM_LEAVE_FORBIDDEN: Cannot leave team (last owner cannot leave without transferring ownership)".to_string(),
        ));
    }

    Ok(Json(response))
}

pub async fn get_team_members(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
) -> Result<Json<Vec<TeamMemberResponse>>, WebError> {
    let team_rec = parse_team_id(&id)?;
    let members = crate::services::teams::get_team_members(&state.store, &auth, &team_rec)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(members))
}

pub async fn add_team_member(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path(id): Path<String>,
    Json(request): Json<AddTeamMemberRequest>,
) -> Result<Response, WebError> {
    let team_rec = parse_team_id(&id)?;
    validate_team_role(&request.role)?;

    let member = crate::services::teams::add_team_member(&state.store, &auth, &team_rec, &request)
        .await
        .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok((StatusCode::CREATED, Json(member)).into_response())
}

pub async fn update_team_member(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path((id, member_user_id)): Path<(String, String)>,
    Json(request): Json<UpdateTeamMemberRequest>,
) -> Result<Json<TeamMemberResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;
    validate_team_role(&request.role)?;

    let member = crate::services::teams::update_team_member(
        &state.store,
        &auth,
        &team_rec,
        &member_user_id,
        &request,
    )
    .await
    .map_err(|e| WebError::Internal(e.to_string()))?;

    Ok(Json(member))
}

pub async fn remove_team_member(
    State(state): State<AppState>,
    auth: AuthenticatedUser,
    Path((id, user_id)): Path<(String, String)>,
) -> Result<Json<RemoveTeamMemberResponse>, WebError> {
    let team_rec = parse_team_id(&id)?;

    let response: RemoveTeamMemberResponse = crate::services::teams::remove_team_member(&state.store, &auth, &team_rec, &user_id)
        .await
        .map_err(|e| WebError::Internal(format!("Failed to remove team member: {}", e)))?;

    if !response.removed {
        return Err(WebError::Conflict(
            "TEAM_MEMBER_REMOVE_FORBIDDEN: Cannot remove team member (last owner cannot be removed)".to_string(),
        ));
    }

    Ok(Json(response))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_team_id_valid() {
        let parsed = parse_team_id("booking_team:devs123").unwrap();
        assert_eq!(parsed.to_string(), "booking_team:devs123");
    }

    #[test]
    fn test_parse_team_id_rejects_other_table() {
        let err = parse_team_id("booking_account:admin");
        assert!(err.is_err());
    }

    #[test]
    fn test_validate_team_name() {
        assert!(validate_team_name("Équipe Commerciale").is_ok());
        assert!(validate_team_name("").is_err());
        assert!(validate_team_name(&"a".repeat(101)).is_err());
    }

    #[test]
    fn test_validate_team_role() {
        assert!(validate_team_role("admin").is_ok());
        assert!(validate_team_role("member").is_ok());
        assert!(validate_team_role("superhero").is_err());
    }
}
