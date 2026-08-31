use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::teams::{
    AddTeamMemberRequest, CreateTeamRequest, DeleteTeamResponse, RemoveTeamMemberResponse,
    TeamMemberResponse, TeamResponse, UpdateTeamRequest,
};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct CreateTeamParams {
    user_id: String,
    name: String,
    slug: String,
}

#[derive(Debug, Clone, Serialize)]
struct ListUserTeamsParams {
    user_id: String,
}

#[derive(Debug, Clone, Serialize)]
struct GetTeamDetailsParams {
    user_id: String,
    team_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateTeamParams {
    user_id: String,
    team_id: RecordId,
    name: Option<String>,
    slug: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
struct DeleteTeamParams {
    user_id: String,
    team_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct GetTeamMembersParams {
    user_id: String,
    team_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct AddTeamMemberParams {
    user_id: String,
    team_id: RecordId,
    member_user_id: String,
    role: String,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateTeamMemberParams {
    user_id: String,
    team_id: RecordId,
    member_user_id: String,
    role: String,
}

#[derive(Debug, Clone, Serialize)]
struct LeaveTeamParams {
    user_id: String,
    team_id: RecordId,
}

/// Crée une nouvelle équipe.
pub async fn create_team(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &CreateTeamRequest,
) -> Result<TeamResponse> {
    let params = CreateTeamParams {
        user_id: auth.user_id.clone(),
        name: request.name.clone(),
        slug: request.slug.clone(),
    };
    let team: TeamResponse = store.call_fn("booking_create_team", params).await?;

    Ok(team)
}

/// Liste les équipes auxquelles l'utilisateur appartient.
pub async fn list_user_teams(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<Vec<TeamResponse>> {
    let params = ListUserTeamsParams {
        user_id: auth.user_id.clone(),
    };
    let teams: Vec<TeamResponse> = store.call_fn("booking_get_teams_for_user", params).await?;

    Ok(teams)
}

/// Récupère les détails d'une équipe.
pub async fn get_team_details(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
) -> Result<TeamResponse> {
    let params = GetTeamDetailsParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
    };
    let team: TeamResponse = store.call_fn("booking_get_team_details", params).await?;

    Ok(team)
}

/// Met à jour les informations d'une équipe.
pub async fn update_team(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
    request: &UpdateTeamRequest,
) -> Result<TeamResponse> {
    let params = UpdateTeamParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
        name: request.name.clone(),
        slug: request.slug.clone(),
    };
    let team: TeamResponse = store.call_fn("booking_update_team", params).await?;

    Ok(team)
}

/// Supprime une équipe.
pub async fn delete_team(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
) -> Result<DeleteTeamResponse> {
    let params = DeleteTeamParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
    };
    let response: DeleteTeamResponse = store.call_fn("booking_delete_team", params).await?;

    Ok(response)
}

/// Récupère la liste des membres d'une équipe.
pub async fn get_team_members(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
) -> Result<Vec<TeamMemberResponse>> {
    let params = GetTeamMembersParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
    };
    let members: Vec<TeamMemberResponse> = store.call_fn("booking_get_team_members", params).await?;

    Ok(members)
}

/// Ajoute un membre dans une équipe.
pub async fn add_team_member(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
    request: &AddTeamMemberRequest,
) -> Result<TeamMemberResponse> {
    let params = AddTeamMemberParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
        member_user_id: request.user_id.clone(),
        role: request.role.clone(),
    };
    let member: TeamMemberResponse = store.call_fn("booking_add_team_member", params).await?;

    Ok(member)
}

/// Supprime un membre d'une équipe via primitive scalaire fn::booking_remove_team_member.
pub async fn remove_team_member(
    store: &SurrealBookingStore,
    _auth: &AuthenticatedUser,
    team_id: &RecordId,
    member_user_id: &str,
) -> Result<RemoveTeamMemberResponse> {
    let member_rec = RecordId::from(("booking_account", member_user_id));
    let mut response = store
        .client()
        .query("RETURN fn::booking_remove_team_member($team_id, $account_id);")
        .bind(("team_id", team_id.clone()))
        .bind(("account_id", member_rec))
        .await?;
    let raw: Option<lyxal_error::LyxalResult<bool>> = response.take(0)?;
    let removed = match raw {
        Some(res) => res.into_result("booking_remove_team_member")?,
        None => false,
    };
    Ok(RemoveTeamMemberResponse { removed })
}

/// Met à jour le rôle d'un membre d'équipe.
pub async fn update_team_member(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
    member_user_id: &str,
    request: &crate::contracts::teams::UpdateTeamMemberRequest,
) -> Result<TeamMemberResponse> {
    let params = UpdateTeamMemberParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
        member_user_id: member_user_id.to_string(),
        role: request.role.clone(),
    };
    let member: TeamMemberResponse = store.call_fn("booking_upsert_team_member", params).await?;

    Ok(member)
}

/// Quitte une équipe.
pub async fn leave_team(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    team_id: &RecordId,
) -> Result<crate::contracts::teams::LeaveTeamResponse> {
    let params = LeaveTeamParams {
        user_id: auth.user_id.clone(),
        team_id: team_id.clone(),
    };
    let response: crate::contracts::teams::LeaveTeamResponse = store.call_fn("booking_remove_team_member", params).await?;

    Ok(response)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_team_request_payload() {
        let req = CreateTeamRequest {
            name: "Équipe Produit".to_string(),
            slug: "equipe-produit".to_string(),
        };
        assert_eq!(req.name, "Équipe Produit");
        assert_eq!(req.slug, "equipe-produit");
    }

    #[test]
    fn test_add_team_member_request_payload() {
        let req = AddTeamMemberRequest {
            user_id: "usr_42".to_string(),
            role: "admin".to_string(),
        };
        assert_eq!(req.user_id, "usr_42");
        assert_eq!(req.role, "admin");
    }
}
