use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetUserParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateUserProfileParams<'a> {
    pub user_id: &'a str,
    pub name: Option<&'a str>,
    pub avatar_url: Option<&'a str>,
    pub bio: Option<&'a str>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InviteUserParams<'a> {
    pub email: &'a str,
    pub role: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteUserParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserResponse {
    pub id: String,
    pub name: String,
    pub email: String,
    pub role: String,
    pub enabled: bool,
    pub avatar_url: Option<String>,
    pub bio: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateCurrentUserRequest {
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub bio: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InviteUserRequest {
    pub email: String,
    pub name: Option<String>,
    pub role: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InviteUserResponse {
    pub invitation_id: String,
    pub invited: bool,
    pub email_sent: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeleteUserResponse {
    pub deleted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserProfileResponse {
    pub id: String,
    pub user_id: String,
    pub name: String,
    pub email: String,
    pub booking_email: Option<String>,
    pub time_zone: String,
    pub avatar_path: Option<String>,
    pub role: String,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateUserProfileRequest {
    pub name: Option<String>,
    pub booking_email: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTimezoneRequest {
    pub time_zone: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTimezoneResponse {
    pub user_id: String,
    pub time_zone: String,
    pub updated: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UploadAvatarResponse {
    pub user_id: String,
    pub avatar_url: String,
    pub uploaded: bool,
}
