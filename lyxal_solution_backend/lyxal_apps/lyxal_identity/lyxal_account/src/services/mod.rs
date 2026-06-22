use lyxal_core::Result;
use lyxal_schema::{User, CustomData};
use serde::{Deserialize, Serialize};
use sqlx::{PgPool, query_as};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePasswordRequest {
    pub current_password: String,
    pub new_password: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProfileRequest {
    pub name: Option<String>,
    pub avatar: Option<String>,
}

pub struct AccountService {
    pool: PgPool,
}

impl AccountService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn update_password(&self, _user_id: &str, _payload: UpdatePasswordRequest) -> Result<()> {
        // Logto parity: Verification of current password then update
        // Implementation note: This should verify against password_hash in DB
        Ok(())
    }

    pub async fn update_profile(&self, user_id: &str, payload: UpdateProfileRequest) -> Result<User> {
        let now = chrono::Utc::now().timestamp_millis();
        
        let user = query_as!(
            User,
            r#"
            UPDATE users 
            SET name = COALESCE($1, name), avatar = COALESCE($2, avatar), updated_at = $3
            WHERE id = $4
            RETURNING id, username, primary_email as "primary_email?", is_email_verified, primary_phone as "primary_phone?", is_phone_verified, name as "name?", avatar as "avatar?", custom_data as "custom_data: CustomData", last_sign_in_at, created_at, updated_at, is_suspended, password_hash as "password_hash?"
            "#,
            payload.name, payload.avatar, now, user_id
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(user)
    }

    pub async fn get_mfa_configurations(&self, user_id: &str) -> Result<Vec<serde_json::Value>> {
        let configs = sqlx::query!(
            "SELECT mfa_type, is_enabled, created_at FROM user_mfa_configurations WHERE user_id = $1",
            user_id
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        let result = configs.into_iter().map(|c| {
            serde_json::json!({
                "type": c.mfa_type,
                "enabled": c.is_enabled,
                "createdAt": c.created_at
            })
        }).collect();

        Ok(result)
    }
}
