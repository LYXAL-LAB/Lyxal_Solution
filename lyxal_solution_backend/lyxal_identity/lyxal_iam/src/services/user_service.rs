use crate::Result;
use lyxal_schema::User;
use std::sync::Arc;
use sqlx::{PgPool, query_as};
use serde_json::json;

#[derive(Clone)]
pub struct UserService {
    pool: PgPool,
}

impl UserService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn create_user(
        &self,
        username: Option<String>,
        primary_email: Option<String>,
        password_hash: Option<String>,
    ) -> Result<User> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis();

        let user = query_as!(
            User,
            r#"
            INSERT INTO users (id, username, primary_email, password_hash, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, username, primary_email as "primary_email?", is_email_verified, primary_phone as "primary_phone?", is_phone_verified, name as "name?", avatar as "avatar?", custom_data, last_sign_in_at, created_at, updated_at, is_suspended, password_hash as "password_hash?"
            "#,
            id, username, primary_email, password_hash, now, now
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(user)
    }

    pub async fn get_user_by_email(&self, email: String) -> Result<User> {
        query_as!(
            User,
            r#"
            SELECT id, username, primary_email, is_email_verified, primary_phone, is_phone_verified, name, avatar, custom_data as "custom_data: _", last_sign_in_at, created_at, updated_at, is_suspended, password_hash
            FROM users WHERE primary_email = $1
            "#,
            email
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|_| lyxal_core::error::CoreError::NotFound)
    }

    pub async fn get_user_by_id(&self, id: String) -> Result<User> {
        query_as!(
            User,
            r#"
            SELECT id, username, primary_email, is_email_verified, primary_phone, is_phone_verified, name, avatar, custom_data as "custom_data: _", last_sign_in_at, created_at, updated_at, is_suspended, password_hash
            FROM users WHERE id = $1
            "#,
            id
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|_| lyxal_core::error::CoreError::NotFound)
    }

    pub async fn update_user_last_sign_in(&self, id: String) -> Result<()> {
        let now = chrono::Utc::now();
        sqlx::query!(
            "UPDATE users SET last_sign_in_at = $1, updated_at = $2 WHERE id = $3",
            now,
            now.timestamp_millis(),
            id
        )
        .execute(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn has_user_with_email(&self, email: &str) -> Result<bool> {
        let exists = sqlx::query!(
            "SELECT EXISTS(SELECT 1 FROM users WHERE primary_email = $1) as exists",
            email
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        
        Ok(exists.exists.unwrap_or(false))
    }
}
