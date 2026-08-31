use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetTeamParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ListUserTeamsParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateTeamParams<'a> {
    pub user_id: &'a str,
    pub name: &'a str,
    pub slug: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTeamParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
    pub name: Option<&'a str>,
    pub slug: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteTeamParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AddTeamMemberParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
    pub member_user_id: &'a str,
    pub role: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTeamMemberParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
    pub member_user_id: &'a str,
    pub role: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RemoveTeamMemberParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
    pub member_user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LeaveTeamParams<'a> {
    pub user_id: &'a str,
    pub team_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TeamResponse {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub role: String,
    pub member_count: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateTeamRequest {
    pub name: String,
    pub slug: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTeamRequest {
    pub name: Option<String>,
    pub slug: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteTeamResponse {
    pub deleted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TeamMemberResponse {
    pub team_id: String,
    pub user_id: String,
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AddTeamMemberRequest {
    pub user_id: String,
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTeamMemberRequest {
    pub role: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RemoveTeamMemberResponse {
    pub removed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LeaveTeamResponse {
    pub left: bool,
}
