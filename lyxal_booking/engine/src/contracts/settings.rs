use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GetUserSettingsParams<'a> {
    pub user_id: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateUserSettingsParams<'a> {
    pub user_id: &'a str,
    pub name: &'a str,
    pub timezone: &'a str,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSettingsResponse {
    pub user_id: String,
    pub name: String,
    pub email: String,
    pub timezone: String,
    pub avatar_url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateUserSettingsRequest {
    pub name: String,
    pub timezone: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateTimezoneRequest {
    pub timezone: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrganizationSettingsResponse {
    pub company_link: Option<String>,
    pub theme_css: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateOrganizationSettingsRequest {
    pub company_link: Option<String>,
}
