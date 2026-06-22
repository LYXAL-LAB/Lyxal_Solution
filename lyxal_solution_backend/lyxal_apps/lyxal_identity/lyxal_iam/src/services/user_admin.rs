use crate::Result;
use lyxal_schema::User;
use sqlx::{PgPool, query, query_as};

pub struct UserAdminService {
    pool: PgPool,
}

impl UserAdminService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn list_users(&self, limit: i64, offset: i64) -> Result<Vec<User>> {
        let users = query_as!(
            User,
            r#"SELECT id, username, primary_email, is_email_verified, primary_phone, is_phone_verified, name, avatar, custom_data as "custom_data: _", last_sign_in_at, created_at, updated_at, is_suspended, password_hash FROM users LIMIT $1 OFFSET $2"#,
            limit, offset
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(users)
    }

    pub async fn delete_user(&self, id: &str) -> Result<()> {
        query!("DELETE FROM users WHERE id = $1", id)
            .execute(&self.pool)
            .await
            .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn suspend_user(&self, id: &str, suspended: bool) -> Result<()> {
        query!("UPDATE users SET is_suspended = $1, updated_at = $2 WHERE id = $3", suspended, chrono::Utc::now().timestamp_millis(), id)
            .execute(&self.pool)
            .await
            .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }
}
