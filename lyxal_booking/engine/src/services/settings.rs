use anyhow::Result;
use serde::Serialize;
use surrealdb::RecordId;

use crate::contracts::auth::AuthenticatedUser;
use crate::contracts::settings::{UpdateUserSettingsRequest, UserSettingsResponse};
use lyxal_surreal::LyxalSurrealCall;
use crate::db::SurrealBookingStore;

#[derive(Debug, Clone, Serialize)]
struct GetUserSettingsParams {
    user_id: RecordId,
}

#[derive(Debug, Clone, Serialize)]
struct UpdateUserSettingsParams {
    user_id: RecordId,
    name: String,
    timezone: String,
}

pub async fn get_user_settings(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
) -> Result<UserSettingsResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = GetUserSettingsParams { user_id: auth_rec };
    let response: UserSettingsResponse = store
        .call_fn("booking_get_user_settings", params)
        .await?;

    Ok(response)
}

pub async fn update_user_settings(
    store: &SurrealBookingStore,
    auth: &AuthenticatedUser,
    request: &UpdateUserSettingsRequest,
) -> Result<UserSettingsResponse> {
    let auth_rec = RecordId::from(("booking_account", auth.user_id.as_str()));
    let params = UpdateUserSettingsParams {
        user_id: auth_rec,
        name: request.name.clone(),
        timezone: request.timezone.clone(),
    };
    let response: UserSettingsResponse = store
        .call_fn("booking_update_user_settings", params)
        .await?;

    Ok(response)
}
