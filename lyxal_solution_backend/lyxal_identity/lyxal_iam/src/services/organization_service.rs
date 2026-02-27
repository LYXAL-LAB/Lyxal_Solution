use crate::Result;
use lyxal_schema::{Role, RoleType};
use sqlx::{PgPool, query_as};
use serde_json::json;

#[derive(Clone)]
pub struct OrganizationService {
    pool: PgPool,
}

impl OrganizationService {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn create_organization(&self, name: String) -> Result<serde_json::Value> {
        let id = uuid::Uuid::new_v4().to_string();
        let now = chrono::Utc::now().timestamp_millis();
        
        sqlx::query!(
            "INSERT INTO organizations (id, name, created_at, updated_at) VALUES ($1, $2, $3, $4)",
            id, name, now, now
        )
        .execute(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        
        Ok(json!({ "id": id, "name": name }))
    }

    pub async fn add_user_to_organization(&self, organization_id: &str, user_id: &str) -> Result<()> {
        sqlx::query!(
            "INSERT INTO organization_users (organization_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
            organization_id, user_id
        )
        .execute(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;
        Ok(())
    }

    pub async fn get_user_organizations(&self, user_id: &str) -> Result<Vec<serde_json::Value>> {
        let orgs = sqlx::query!(
            "SELECT o.id, o.name FROM organizations o JOIN organization_users ou ON o.id = ou.organization_id WHERE ou.user_id = $1",
            user_id
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| lyxal_core::error::CoreError::Database(e.to_string()))?;

        Ok(orgs.into_iter().map(|o| json!({"id": o.id, "name": o.name})).collect())
    }
}
