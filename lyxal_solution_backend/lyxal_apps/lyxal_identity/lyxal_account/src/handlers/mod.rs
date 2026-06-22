use axum::{Json, response::IntoResponse, extract::State};
use crate::services::AccountService;
use lyxal_core::Result;

pub async fn get_profile() -> impl IntoResponse {
    "User Profile (1:1 Logto Account Center)"
}

pub async fn update_profile() -> impl IntoResponse {
    "Profile Updated"
}

pub async fn change_password() -> impl IntoResponse {
    "Password Changed"
}

pub async fn list_mfa() -> impl IntoResponse {
    "MFA List"
}
