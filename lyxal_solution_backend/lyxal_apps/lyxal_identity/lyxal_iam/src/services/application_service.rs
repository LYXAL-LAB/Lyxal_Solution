use crate::Result;
use lyxal_schema::{Application, ApplicationType};
use sqlx::{PgPool, query_as};
use serde_json::json;

#[derive(Clone)]
pub struct ApplicationService {
    pool: PgPool,
}

impl ApplicationService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn create_application(
        &self,
        name: String,
        app_type: ApplicationType,
        redirect_uris: Vec<String>,
    ) -> Result<Application> {
        let id = uuid::Uuid::new_v4().to_string();
        let secret = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis();

        let app = query_as!(
            Application,
            r#"
            INSERT INTO applications (id, name, secret, app_type, redirect_uris, created_at, updated_at, post_logout_redirect_uris, allowed_cors_origins)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING id, name, secret, description, is_first_party, app_type as "app_type: _", 
                      redirect_uris as "redirect_uris: _", post_logout_redirect_uris as "post_logout_redirect_uris: _", 
                      allowed_cors_origins as "allowed_cors_origins: _", created_at, updated_at
            "#,
            id, name, secret, app_type as _, json!(redirect_uris), now, now, json!([] as Vec<String>), json!([] as Vec<String>)
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(app)
    }

    pub async fn get_application_by_id(&self, id: String) -> Result<Application> {
        query_as!(
            Application,
            r#"SELECT id, name, secret, description, is_first_party, app_type as "app_type: _", 
                      redirect_uris as "redirect_uris: _", post_logout_redirect_uris as "post_logout_redirect_uris: _", 
                      allowed_cors_origins as "allowed_cors_origins: _", created_at, updated_at 
               FROM applications WHERE id = $1"#,
            id
        )
        .fetch_one(&self.pool)
        .await
        .map_err(|_| lyxal_core::error::CoreError::NotFound)
    }

    pub async fn rotate_client_secret(&self, id: String) -> Result<String> {
        let new_secret = uuid::Uuid::new_v4().to_string();
        sqlx::query!("UPDATE applications SET secret = $1, updated_at = $2 WHERE id = $3", 
                     new_secret, chrono::Utc::now().timestamp_millis(), id)
            .execute(&self.pool)
            .await
            .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(new_secret)
    }
}
